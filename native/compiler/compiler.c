#include "compiler.h"
#include "coder.h"
#include "thumb.h"
#include "verifier.h"
#include "class_access.h"
#include "vm_strings.h"
#include "method_ranges.h"
#include "runtime.h"

#include <limits.h>
#include <string.h>

static bool fail(JbedError *out, JbedErrorKind kind, bool java_error, JbedTypeId id,
                 const char *message)
{
    *out =
        (JbedError){.kind = kind, .is_java_error = java_error, .class_id = id, .message = message};
    return false;
}

static uint32_t rom_word(const uint8_t *p)
{
    return (uint32_t)p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
}

bool jbed_compiler_layout_android(JbedCompilerLayout *config, JbedPool *pool, JbedWriter *writer,
                                  const JbedVmClassTable *rom, JbedAddress code_base)
{
    /* Memory.initMemory passes Jbed_start + 0x10 to SysInfo.init. Reader uses
     * three adjacent words at SysInfo + 0x30 to place fields in isolate statics. */
    const size_t offset = 0xab338 + 0x30;
    if (!rom || !rom->image.bytes || rom->image.size < offset + 12)
        return false;
    JbedClass *class_class = jbed_vm_class_by_id(rom, 38);
    if (!class_class || !class_class->superclass)
        return false;
    const uint8_t *p = rom->image.bytes + offset;
    *config = (JbedCompilerLayout){.pool = pool, .writer = writer,
                                   .array_base_class = class_class->superclass,
                                   .throw_abstract_address = jbed_thumb_rom_helpers(code_base).throw_abstract};
    jbed_reader_layout_init(&config->layout, rom_word(p), (int32_t)rom_word(p + 4),
                            rom_word(p + 8), 1);
    return true;
}

static const char *class_name(const JbedCompiler *c, JbedTypeId id)
{
    return c->services.class_name ? c->services.class_name(c->services.context, id)
                                  : jbed_class_name(c->services.class_access, id);
}

static bool class_error(JbedCompiler *c, JbedTypeId id, const char *prefix, JbedError *error)
{
    const char *name = class_name(c, id);
    if (!name)
        name = "null"; /* StringBuffer.append(String)'s null spelling. */
    size_t prefix_size = strlen(prefix), name_size = strlen(name);
    char *message = c->services.allocate(c->services.context, prefix_size + name_size + 1, error);
    if (!message)
        return false;
    memcpy(message, prefix, prefix_size);
    memcpy(message + prefix_size, name, name_size + 1);
    return fail(error, JBED_ERROR_ERROR, true, id, message);
}

/* Java int arithmetic wraps before signed division. */
static int32_t signed_word(uint32_t value)
{
    return value <= INT32_MAX ? (int32_t)value : -1 - (int32_t)(UINT32_MAX - value);
}

static JbedClass *next_class(const JbedCompiler *c, JbedClass *previous)
{
    return c->services.next_class ? c->services.next_class(c->services.context, previous)
                                  : jbed_class_next(c->services.class_access, previous);
}

static JbedTypeId next_unresolved(const JbedCompiler *c, JbedTypeId previous)
{
    return c->services.next_unresolved ? c->services.next_unresolved(c->services.context, previous)
                                       : jbed_class_next_unresolved(c->services.class_access, previous);
}

static JbedClass *lookup_class(const JbedCompiler *c, JbedTypeId id)
{
    return c->services.lookup_class ? c->services.lookup_class(c->services.context, id)
                                    : jbed_class_object(c->services.class_access, id);
}

typedef struct DefineClass {
    JbedClassAccess *access;
    JbedTypeId id;
    JbedClass *klass;
} DefineClass;

static void get_or_create_class(void *context)
{
    DefineClass *call = context;
    call->klass = jbed_class_get_or_create(call->access, call->id);
}

/* Compiler.<clinit>, 0x147024. The property's presence, not value, matters. */
void jbed_compiler_init(JbedCompiler *c, const JbedCompilerServices *services,
                        bool ignore_sanity_property_present)
{
    *c = (JbedCompiler){.services = *services,
                        .target_writer = services->coder ? services->coder->writer : NULL,
                        .ignore_class_sanity = ignore_sanity_property_present};
}

/* Compiler.setProgress, 0x145a32. */
void jbed_compiler_set_progress(JbedCompiler *c, bool (*listener)(void *, int32_t), void *context,
                                int32_t classes, int32_t read_weight)
{
    c->progress_listener = listener;
    c->progress_context = context;
    c->total = signed_word(100u * (uint32_t)classes);
    c->read_weight = read_weight;
    c->progress = 0;
    c->canceled = false;
}

/* Compiler.clearProgress, 0x145a60. The final callback's result is ignored. */
void jbed_compiler_clear_progress(JbedCompiler *c)
{
    if (c->progress_listener) {
        c->progress_listener(c->progress_context, 100);
        c->progress_listener = NULL;
    }
}

/* Compiler.madeProgress, 0x145aa8. Callers in compile ignore its bool result;
 * cancellation is exposed separately rather than stopping a partial pass. */
bool jbed_compiler_made_progress(JbedCompiler *c, bool post_read_phase)
{
    bool proceed = true;
    if (c->progress_listener) {
        int32_t step =
            post_read_phase ? signed_word(100u - (uint32_t)c->read_weight) / 4 : c->read_weight;
        c->progress = signed_word((uint32_t)c->progress + (uint32_t)step);
        int32_t numerator = signed_word(100u * (uint32_t)c->progress);
        if (c->total == 0) {
            JbedRuntime runtime = {.context = c->services.context,
                                   .raise_error = c->services.raise_error};
            const JbedError error = {.kind = JBED_ERROR_ARITHMETIC, .message = "/ by zero"};
            jbed_raise(&runtime, &error);
        }
        int32_t percent =
            numerator == INT32_MIN && c->total == -1 ? INT32_MIN : numerator / c->total;
        proceed = c->progress_listener(c->progress_context, percent);
        if (!proceed)
            c->canceled = true;
    }
    c->services.checkpoint(c->services.context);
    return proceed;
}

/* 0x145a9c / 0x145b44. */
bool jbed_compiler_is_canceled(const JbedCompiler *c)
{
    return c->canceled;
}
bool jbed_compiler_full_debug_info(const JbedCompiler *c)
{
    return c->has_coder && (c->options & 4) != 0;
}

/* 0x145d68 / 0x145d88 / 0x145da8. */
void jbed_compiler_enable_swapping(JbedCompiler *c, JbedCompilerSwap *output,
                                   JbedCompilerSwap *input)
{
    c->swap_output = output;
    c->swap_input = input;
    c->swapping = true;
}
void jbed_compiler_disable_swapping(JbedCompiler *c)
{
    c->swap_output = NULL;
    c->swap_input = NULL;
    c->swapping = false;
}
bool jbed_compiler_is_swapping(const JbedCompiler *c)
{
    return c->swapping;
}

/* Compiler.checkClassSanity, 0x145b6c. */
bool jbed_compiler_check_class_sanity(JbedCompiler *c, JbedTypeId id, JbedError *error)
{
    if (!c->ignore_class_sanity) {
        const char *package = c->services.package_name
                                  ? c->services.package_name(c->services.context, id)
                                  : jbed_class_package_name(c->services.class_access, id);
        if (!package)
            return fail(error, JBED_ERROR_NULL_POINTER, false, id, NULL);
        if (strncmp(package, "java/", 5) == 0 || strncmp(package, "javax/", 6) == 0)
            return class_error(c, id, "System packages not allowed for loaded class ", error);
    }
    return true;
}

/* Compiler.handleError, 0x145c28. Even a non-Error Throwable poisons the class;
 * only Error subclasses are printed by the original logger. */
void jbed_compiler_handle_error(JbedCompiler *c, const JbedError *error, JbedClass *klass,
                                const char *phase)
{
    if (error->is_java_error)
        c->services.report_error(c->services.context, error, klass, phase);
    if (klass) {
        klass->instance_size = -1;
        klass->has_error = true;
        klass->error = *error;
        if (c->services.store_class_error)
            c->services.store_class_error(c->services.context, klass);
    }
}

/* Compiler.checkError, 0x145d40. Class.anchor is cast to java.lang.Error. */
bool jbed_compiler_check_error(const JbedClass *klass, JbedError *error)
{
    if (klass->instance_size >= 0)
        return true;
    *error = jbed_class_error(klass);
    if (!error->is_java_error)
        return fail(error, JBED_ERROR_CLASS_CAST, false, klass->id,
                    "stored compiler throwable cannot be cast to java.lang.Error");
    return false;
}

static bool write16(JbedCompilerSwap *io, uint32_t value, JbedError *error)
{
    uint8_t b[2] = {(uint8_t)value, (uint8_t)(value >> 8)};
    return io->write(io->context, b, sizeof b, error);
}
static bool write32(JbedCompilerSwap *io, uint32_t value, JbedError *error)
{
    uint8_t b[4] = {(uint8_t)value, (uint8_t)(value >> 8), (uint8_t)(value >> 16),
                    (uint8_t)(value >> 24)};
    return io->write(io->context, b, sizeof b, error);
}
static bool read16(JbedCompilerSwap *io, uint16_t *value, JbedError *error)
{
    uint8_t b[2];
    if (!io->read(io->context, b, sizeof b, error))
        return false;
    *value = (uint16_t)((uint32_t)b[0] | (uint32_t)b[1] << 8);
    return true;
}
static bool read32(JbedCompilerSwap *io, uint32_t *value, JbedError *error)
{
    uint8_t b[4];
    if (!io->read(io->context, b, sizeof b, error))
        return false;
    *value = (uint32_t)b[0] | (uint32_t)b[1] << 8 | (uint32_t)b[2] << 16 | (uint32_t)b[3] << 24;
    return true;
}

typedef struct {
    JbedClass *klass;
    const JbedPoolServices *services;
    JbedCompilerSwap *swap;
    const uint8_t *bytes;
    size_t size;
    JbedError *error;
    bool ok;
} ClassInput;

static void read_class_input(void *argument)
{
    ClassInput *input = argument;
    if (input->swap) {
        JbedPool *pool = jbed_alloc(input->services->runtime, sizeof(*pool));
        jbed_pool_init(pool, input->services, input->klass);
        input->ok = jbed_pool_swap_in(pool, input->swap, input->error);
        if (input->ok)
            input->klass->pool = pool;
    } else {
        JbedReader reader;
        input->ok = jbed_reader_init(&reader, input->services->runtime, input->bytes, input->size,
                                     0, (int32_t)input->size, input->error) &&
                    jbed_reader_class(&reader, input->services, input->klass, input->error);
    }
}

static bool read_class_pool(JbedCompilerLayout *config, JbedClass *klass, JbedCompilerSwap *swap,
                            const uint8_t *bytes, size_t size, JbedError *error)
{
    ClassInput input = {klass, config->pool->services, swap, bytes, size, error, false};
    JbedRuntime *runtime = input.services->runtime;
    return runtime->protected_call(runtime->context, read_class_input, &input, error) && input.ok;
}

/* Compiler.swapClass, 0x145db4. Class.defConstr is temporarily a file offset.
 * IOException is swallowed (handler 0x145fd0). The offset is committed after
 * each method, not after the pool or entire class: preserve this detail. */
bool jbed_compiler_swap_class(JbedCompiler *c, JbedClass *klass, JbedError *error)
{
    JbedCompilerSwap *io = c->swap_output;
    int32_t start;
    klass->swap_offset = -1;
    if (!io->length(io->context, &start, error))
        goto caught;
    if (!klass->pool)
        return fail(error, JBED_ERROR_NULL_POINTER, false, klass->id, "Null compiler pool");
    if (!(c->services.class_layout ? jbed_pool_swap_out(klass->pool, io, error)
                                   : c->services.swap_pool_out(c->services.context, klass->pool,
                                                               io, error)))
        goto caught;
    for (JbedMethod *m = klass->methods; m; m = m->next) {
        if (!write16(io, m->code ? (uint32_t)m->code_length : 0, error))
            goto caught;
        if (m->code) {
            if (!io->write(io->context, m->code, m->code_length, error))
                goto caught;
            if (!write16(io, (uint32_t)m->handler_count * 4, error))
                goto caught;
            for (size_t i = 0; i < m->handler_count; ++i) {
                JbedExceptionHandler *h = &m->handlers[i];
                if (!write32(io, h->start_pc, error) || !write32(io, h->end_pc, error) ||
                    !write32(io, h->handler_pc, error) || !write32(io, h->catch_index, error))
                    goto caught;
            }
            /* Preserve the original compact swap encoding for ordinary maps.
             * 0xffff escapes to wide semantic offsets for lifted methods. */
            bool wide_maps = m->stack_maps.word_count >= UINT16_MAX;
            if (!write16(io, wide_maps ? UINT16_MAX : (uint32_t)m->stack_maps.word_count, error) ||
                (wide_maps && !write32(io, (uint32_t)m->stack_maps.word_count, error)))
                goto caught;
            for (size_t i = 0; i < m->stack_maps.word_count; ++i)
                if (!(wide_maps ? write32(io, m->stack_maps.words[i], error)
                                : write16(io, m->stack_maps.words[i], error)))
                    goto caught;
        }
        klass->swap_offset = start;
    }
    return true;
caught:
    return error->kind == JBED_ERROR_IO;
}

/* Compiler.stripClass, 0x146090. Detaches GC-managed storage, without freeing
 * metadata or allocating replacement arrays. */
void jbed_compiler_strip_class(JbedClass *klass)
{
    klass->pool = NULL;
    for (JbedMethod *m = klass->methods; m; m = m->next) {
        m->code = NULL;
        m->code_length = 0;
        m->handlers = NULL;
        m->handler_count = 0;
        m->stack_maps = (JbedStackMaps){0};
    }
}

/* Compiler.restoreClass, 0x1460b6. IOException becomes a plain java.lang.Error.
 * Length-zero fields are left alone, as in the original (normally stripped). */
bool jbed_compiler_restore_class(JbedCompiler *c, JbedClass *klass, JbedError *error)
{
    JbedCompilerSwap *io = c->swap_input;
    if (klass->swap_offset < 0)
        return fail(error, JBED_ERROR_ERROR, true, klass->id, NULL);
    if (!io->seek(io->context, klass->swap_offset, error))
        goto caught;
    bool restored = c->services.class_layout
                        ? read_class_pool(c->services.class_layout, klass, io, NULL, 0, error)
                        : c->services.swap_pool_in(c->services.context, klass, io, error);
    if (!restored)
        goto caught;
    for (JbedMethod *m = klass->methods; m; m = m->next) {
        uint16_t count;
        if (!read16(io, &count, error))
            goto caught;
        if (count == 0)
            continue;
        m->code = c->services.allocate(c->services.context, count, error);
        if (!m->code)
            return false;
        m->code_length = count;
        if (!io->read(io->context, m->code, count, error))
            goto caught;
        if (!read16(io, &count, error))
            goto caught;
        if (count) {
            m->handler_count = count / 4;
            m->handlers = c->services.allocate(c->services.context,
                                               m->handler_count * sizeof *m->handlers, error);
            if (!m->handlers)
                return false;
            for (size_t i = 0; i < m->handler_count; ++i) {
                JbedExceptionHandler *h = &m->handlers[i];
                if (!read32(io, &h->start_pc, error) || !read32(io, &h->end_pc, error) ||
                    !read32(io, &h->handler_pc, error) || !read32(io, &h->catch_index, error))
                    goto caught;
            }
        }
        if (!read16(io, &count, error))
            goto caught;
        bool wide_maps = count == UINT16_MAX;
        uint32_t map_count = count;
        if (wide_maps && !read32(io, &map_count, error)) goto caught;
        if (map_count) {
            m->stack_maps.words = c->services.allocate(c->services.context,
                (size_t)map_count * sizeof *m->stack_maps.words, error);
            if (!m->stack_maps.words) return false;
            m->stack_maps.word_count = map_count;
            for (size_t i = 0; i < map_count; ++i) {
                if (wide_maps) {
                    if (!read32(io, &m->stack_maps.words[i], error)) goto caught;
                } else {
                    uint16_t word;
                    if (!read16(io, &word, error)) goto caught;
                    m->stack_maps.words[i] = word;
                }
            }
        }
    }
    return true;
caught:
    if (error->kind == JBED_ERROR_IO)
        return fail(error, JBED_ERROR_ERROR, true, klass->id, NULL);
    return false;
}

static bool read_definition(JbedCompiler *c, JbedTypeId id, const uint8_t *bytes, size_t size,
                            JbedClass **klass, JbedError *error)
{
    void *context = c->services.context;
    if (!jbed_compiler_check_class_sanity(c, id, error))
        return false;
    if (c->services.get_or_create_class) {
        *klass = c->services.get_or_create_class(context, id, error);
    } else {
        DefineClass call = {c->services.class_access, id, NULL};
        JbedRuntime *runtime = call.access->runtime;
        if (!runtime->protected_call(runtime->context, get_or_create_class, &call, error))
            return false;
        *klass = call.klass;
    }
    if (!*klass)
        return false;
    if ((*klass)->flags & ~JBED_CLASS_DYNAMIC)
        return true;
    bool read = c->services.class_layout
                    ? read_class_pool(c->services.class_layout, *klass, NULL, bytes, size, error)
                    : c->services.read_class(context, klass, bytes, size, error);
    if (read)
        jbed_compiler_made_progress(c, false);
    return read;
}

/* Compiler.define, 0x1462ec. Only the read phase catches java.lang.Error. */
bool jbed_compiler_define(JbedCompiler *c, JbedTypeId id, const uint8_t *bytes, size_t size,
                          JbedError *error)
{
    void *context = c->services.context;
    JbedClass *klass = NULL;
    c->services.enter(context);
    bool ok = read_definition(c, id, bytes, size, &klass, error);
    if (!ok && error->is_java_error) {
        if (error->kind == JBED_ERROR_OUT_OF_MEMORY) {
            if (c->swapping)
                c->services.report_oom_define(context, id);
        } else {
            jbed_compiler_handle_error(c, error, klass, "define");
            ok = true;
        }
    }
    if (ok && c->swap_output) {
        ok = klass ? jbed_compiler_swap_class(c, klass, error)
                   : fail(error, JBED_ERROR_NULL_POINTER, false, 0, NULL);
        if (ok)
            jbed_compiler_strip_class(klass);
    }
    c->services.leave(context);
    return ok;
}

typedef enum { PREPARE_FIELDS, WRITE_STATICS, REGISTER_CLASS, WRITE_DESCRIPTOR } LayoutOperation;

typedef struct {
    LayoutOperation operation;
    JbedCompilerLayout *config;
    JbedClass *klass;
    JbedError *error;
    bool ok;
} LayoutCall;

static void run_layout(void *argument)
{
    LayoutCall *call = argument;
    JbedCompilerLayout *config = call->config;
    JbedReaderLayoutServices reader = {
        .pool = call->klass && call->klass->pool ? call->klass->pool : config->pool,
        .array_base_class = config->array_base_class,
        .throw_abstract_address = config->throw_abstract_address};
    jbed_reader_layout_use_writer(&reader, config->writer);
    switch (call->operation) {
    case PREPARE_FIELDS:
        call->ok = jbed_reader_prepare(&config->layout, &reader, call->klass, call->error);
        break;
    case WRITE_DESCRIPTOR:
        call->ok = jbed_reader_allocate_descriptor(&config->layout, &reader, call->klass,
                                                   call->error);
        break;
    case WRITE_STATICS: {
        uint32_t ranges[4];
        size_t count = jbed_reader_pointer_ranges(&config->layout, ranges);
        /* RomObjects retains this array until it serializes the finished suite. */
        uint32_t *saved = jbed_alloc(reader.pool->services->runtime, count * sizeof(*saved));
        memcpy(saved, ranges, count * sizeof(*saved));
        uint32_t size = jbed_reader_relative_statics_size(&config->layout);
        jbed_writer_set_relative_statics(config->writer, size, saved, (uint32_t)count);
        call->ok = true;
        break;
    }
    case REGISTER_CLASS:
        jbed_writer_register_class(config->writer, call->klass);
        call->ok = true;
        break;
    }
}

static bool layout_call(JbedCompiler *c, LayoutOperation operation, JbedClass *klass,
                        JbedError *error)
{
    JbedCompilerLayout *config = c->services.class_layout;
    JbedRuntime *runtime = config->pool->services->runtime;
    LayoutCall call = {operation, config, klass, error, false};
    return runtime->protected_call(runtime->context, run_layout, &call, error) && call.ok;
}

/* Compiler.prepare, 0x146474; Error handler 0x1464e6, OOM rethrow 0x146644. */
bool jbed_compiler_prepare(JbedCompiler *c, JbedClass *klass, JbedError *error)
{
    void *context = c->services.context;
    if ((klass->flags & JBED_CLASS_PREPARED) ||
        (klass->instance_size < 0 && !(klass->flags & JBED_CLASS_ARRAY)))
        return true;
    if (klass->flags & JBED_CLASS_ARRAY) {
        JbedClass *element = klass->superclass;
        while (element->flags & JBED_CLASS_ARRAY)
            element = element->superclass;
        klass->flags |= JBED_CLASS_PREPARED | (element->flags & JBED_ACC_PUBLIC);
        klass->instance_size = element->instance_size < 0 ? element->instance_size : 16;
        return true;
    }
    if (klass->flags & JBED_CLASS_PREPARING) {
        klass->superclass = c->services.class_object_base ? c->services.class_object_base(context)
                                                          : lookup_class(c, JBED_ROM_CLASS_OBJECT);
        klass->interfaces = NULL;
        klass->interface_count = 0;
        *error = jbed_emitter_error(c->services.emitter, JBED_EMITTER_CLASS_CIRCULARITY, klass->id,
                                    0, 0, 0);
        goto caught;
    }
    klass->flags |= JBED_CLASS_PREPARING;
    if (!klass->unresolved_super_id) {
        fail(error, JBED_ERROR_ERROR, true, klass->id, "no superclass");
        goto caught;
    }
    JbedClass *super = lookup_class(c, klass->unresolved_super_id);
    if (!super) {
        *error = jbed_emitter_error(c->services.emitter, JBED_EMITTER_NO_CLASS,
                                    klass->unresolved_super_id, 0, 0, 0);
        goto caught;
    }
    klass->unresolved_super_id = 0;
    klass->superclass = super;
    if (!jbed_compiler_prepare(c, super, error) || !jbed_compiler_check_error(super, error))
        goto caught;
    if (klass->unresolved_interface_ids) {
        JbedTypeId *ids = klass->unresolved_interface_ids;
        size_t count = klass->unresolved_interface_count;
        klass->unresolved_interface_ids = NULL;
        klass->unresolved_interface_count = 0;
        klass->interfaces = c->services.allocate(context, count * sizeof *klass->interfaces, error);
        if (!klass->interfaces)
            goto caught;
        klass->interface_count = 0;
        for (size_t i = 0; i < count; ++i) {
            JbedClass *interface = lookup_class(c, ids[i]);
            if (interface) {
                if (!jbed_compiler_prepare(c, interface, error) ||
                    !jbed_compiler_check_error(interface, error))
                    goto caught;
                klass->interfaces[klass->interface_count++] = interface;
            }
        }
        /* The ROM copies to a shorter array if unresolved interfaces were
         * dropped. Preserve that allocation and its possible OOM. */
        if (klass->interface_count != count) {
            JbedClass **trimmed =
                c->services.allocate(context, klass->interface_count * sizeof *trimmed, error);
            if (!trimmed)
                goto caught;
            memcpy(trimmed, klass->interfaces, klass->interface_count * sizeof *trimmed);
            klass->interfaces = trimmed;
        }
    }
    if (c->swap_output && !jbed_compiler_restore_class(c, klass, error))
        goto caught;
    if (!(c->services.class_layout ? layout_call(c, PREPARE_FIELDS, klass, error)
                                   : c->services.prepare_class(context, klass, error)))
        goto caught;
    if (c->swap_output)
        jbed_compiler_strip_class(klass);
    return true;
caught:
    if (!error->is_java_error || error->kind == JBED_ERROR_OUT_OF_MEMORY)
        return false;
    jbed_compiler_handle_error(c, error, klass, "prepare");
    klass->flags &= ~(JBED_CLASS_PREPARING | JBED_CLASS_PREPARED);
    return true;
}

typedef enum {
    VERIFY_CLASS, TRANSLATE_CLASS, FLUSH_CLASS, FLUSH_CURRENT, CLEAN_WRITER, START_CODER, RESET_CODER
} BackendOperation;

typedef struct {
    JbedCompiler *compiler;
    JbedClass *klass;
    BackendOperation operation;
    uint32_t argument;
} BackendCall;

static void run_backend(void *context)
{
    BackendCall *call = context;
    JbedCompiler *c = call->compiler;
    JbedCoder *coder = c->services.coder;
    switch (call->operation) {
    case VERIFY_CLASS:
        jbed_verifier_verify_class(c->services.verifier, call->klass);
        break;
    case TRANSLATE_CLASS:
        coder->writer = c->services.class_layout ? c->services.class_layout->writer : c->target_writer;
        if (!coder->writer)
            jbed_raise_internal(coder->runtime, "Missing compilation writer");
        jbed_coder_translate(coder, call->klass);
        break;
    case FLUSH_CLASS:
        jbed_coder_flush_class_fixups(coder, call->klass, call->argument);
        break;
    case FLUSH_CURRENT:
        jbed_thumb_flush_current_fixups(coder->thumb, call->argument);
        break;
    case CLEAN_WRITER:
        jbed_writer_cleanup(coder->writer);
        break;
    case START_CODER: {
        JbedThumbCoder *thumb = coder->thumb;
        JbedCoderRuntimeAddresses calls = coder->helpers;
        JbedThumbRuntimeAddresses helpers = thumb->helpers;
        jbed_coder_init(coder, coder->runtime, coder->services, coder->emitter, NULL, &calls);
        jbed_thumb_init(thumb, coder, coder->runtime, &helpers, call->argument != 0);
        break;
    }
    case RESET_CODER:
        jbed_thumb_reset(coder->thumb);
        coder->writer = NULL;
        break;
    }
}

static bool backend_call(JbedCompiler *c, BackendOperation op, JbedClass *klass,
                         uint32_t argument, JbedError *error)
{
    BackendCall call = {c, klass, op, argument};
    JbedRuntime *rt = op == VERIFY_CLASS ? c->services.verifier->runtime : c->services.coder->runtime;
    return rt->protected_call(rt->context, run_backend, &call, error);
}

/* Compiler.verify, 0x146730. Recursive superclass verification precedes the
 * per-method verifier. OutOfMemoryError escapes the Throwable catch. */
bool jbed_compiler_verify(JbedCompiler *c, JbedClass *klass, JbedError *error)
{
    if (!klass)
        return fail(error, JBED_ERROR_NULL_POINTER, false, 0, "Null verification class");
    if ((klass->flags & (JBED_CLASS_VERIFIED | JBED_CLASS_ARRAY)) || klass->instance_size < 0)
        return true;
    klass->flags |= JBED_CLASS_VERIFIED;
    if (!jbed_compiler_verify(c, klass->superclass, error))
        return false;
    if (klass->superclass->instance_size < 0) {
        JbedError inherited = jbed_class_error(klass->superclass);
        jbed_compiler_handle_error(c, &inherited, klass, "verify");
        return true;
    }
    if ((c->swap_output && !jbed_compiler_restore_class(c, klass, error)) ||
        !(c->services.verifier ? backend_call(c, VERIFY_CLASS, klass, 0, error)
                               : c->services.verify_class(c->services.context, klass, error))) {
        if (error->kind == JBED_ERROR_OUT_OF_MEMORY)
            return false;
        jbed_compiler_handle_error(c, error, klass, "verify");
        return true;
    }
    if (c->swap_output)
        jbed_compiler_strip_class(klass);
    return true;
}

/* Compiler.translate, 0x146828. OOM recorded by TranslateClass changes the
 * class-size sentinel from -1 to -2; other class errors retain -1. */
bool jbed_compiler_translate(JbedCompiler *c, JbedClass *klass, JbedError *error)
{
    if (!(klass->flags & JBED_CLASS_TRANSLATED) && klass->instance_size >= 0) {
        klass->flags |= JBED_CLASS_TRANSLATED;
        if (klass->superclass && !jbed_compiler_translate(c, klass->superclass, error))
            return false;
        if (!(klass->flags & JBED_CLASS_ARRAY)) {
            for (size_t i = 0; i < klass->interface_count; ++i)
                if (!jbed_compiler_translate(c, klass->interfaces[i], error))
                    return false;
            if (c->swap_output && !jbed_compiler_restore_class(c, klass, error))
                return false;
            klass->swap_offset = 0;
            if (!(c->services.coder ? backend_call(c, TRANSLATE_CLASS, klass, 0, error)
                                    : c->services.translate_class(c->services.context, klass, error)))
                return false;
            jbed_compiler_made_progress(c, true);
        }
        klass->pool = NULL;
    }
    if (klass->instance_size < 0 && klass->error.kind == JBED_ERROR_OUT_OF_MEMORY)
        klass->instance_size = -2;
    return true;
}

/* Compiler.compile, 0x1468e0. Iterate through ClassAccess each time: class
 * resolution can grow its table, so a cached class-list snapshot is wrong. */
bool jbed_compiler_compile(JbedCompiler *c, JbedError *error)
{
    void *context = c->services.context;
    bool ok = false;
    c->services.enter(context);
    JbedCompilerLayout *config = c->services.class_layout;
    if (config) {
        JbedReaderLayout *layout = &config->layout;
        jbed_reader_layout_init(layout, layout->relative_statics_base,
                                layout->initial_static_capacity, layout->static_base,
                                c->method_offset);
        if (config->primitive_static_start)
            layout->primitive_static_top = config->primitive_static_start;
    } else if (!c->services.init_reader(context, c->method_offset, error))
        goto done;
    for (JbedClass *k = NULL; (k = next_class(c, k)) != NULL;) {
        if (k->flags & JBED_CLASS_DYNAMIC) {
            if (!jbed_compiler_prepare(c, k, error))
                goto done;
            jbed_compiler_made_progress(c, true);
        } else {
            JbedError missing;
            fail(&missing, JBED_ERROR_ERROR, true, k->id, "missing class");
            jbed_compiler_handle_error(c, &missing, k, "prepare");
            k->flags |= JBED_CLASS_DYNAMIC;
        }
    }
    for (JbedClass *k = NULL; (k = next_class(c, k)) != NULL;) {
        if (!(k->flags & JBED_CLASS_PREPARED))
            continue;
        if (config)
            jbed_reader_fixup_fields(&config->layout, k);
        else if (!c->services.fixup_relative_fields(context, k, error))
            goto done;
    }
    if (!(config ? layout_call(c, WRITE_STATICS, NULL, error)
                 : c->services.set_relative_statics(context, error)) ||
        (c->services.prepare_done && !c->services.prepare_done(context, error)))
        goto done;
    for (JbedTypeId id = 0; (id = next_unresolved(c, id)) != 0;)
        c->services.report_unresolved(context, id, class_name(c, id));
    for (JbedClass *k = NULL; (k = next_class(c, k)) != NULL;) {
        if (!jbed_compiler_verify(c, k, error))
            goto done;
        jbed_compiler_made_progress(c, true);
    }
    for (JbedClass *k = NULL; (k = next_class(c, k)) != NULL;) {
        if (!jbed_compiler_translate(c, k, error) ||
            !(config ? layout_call(c, REGISTER_CLASS, k, error)
                     : c->services.register_class(context, k, error)))
            goto done;
    }
    for (JbedClass *k = NULL; (k = next_class(c, k)) != NULL;) {
        if (k->instance_size >= 0) {
            if (!(config ? layout_call(c, WRITE_DESCRIPTOR, k, error)
                         : c->services.allocate_descriptor(context, k, error)))
                goto done;
            jbed_compiler_made_progress(c, true);
            k->flags |= JBED_CLASS_DESCRIPTOR_WRITTEN;
        }
    }
    c->services.report_statistics(context, false);
    bool has_writer = c->services.coder ? c->services.coder->writer != NULL
                                        : c->services.coder_has_writer(context);
    if (has_writer && !(c->services.coder ? backend_call(c, CLEAN_WRITER, NULL, 0, error)
                                         : c->services.cleanup_writer(context, error)))
        goto done;
    c->swap_input = c->swap_output = NULL; /* swapping flag is deliberately retained. */
    ok = true;
done:
    c->services.leave(context);
    return ok;
}

/* A new startCompile creates a fresh ClassAccess. If the caller reuses its
 * C storage, keep the published suite and its classes bound to the old view. */
static void keep_published_classes(void *context)
{
    JbedClassAccess *current = context;
    JbedClassAccess *published = jbed_alloc(current->runtime, sizeof *published);
    *published = *current;
    for (uint32_t i = 0; i < published->object_capacity; ++i) {
        JbedClass *klass = published->classes[i];
        if (klass && klass->dynamic_class_access == current)
            klass->dynamic_class_access = published;
    }
    current->runtime->registered_classes = published;
}

static void start_guest_classes(void *context)
{
    JbedClassAccess *a = context;
    jbed_class_bind_heap_image(a, a->heap, a->heap_image);
}

/* Compiler.startCompile, 0x146cb8. */
bool jbed_compiler_start(JbedCompiler *c, uint32_t options, bool long_jumps,
                         bool (*progress)(void *, int32_t), void *progress_context, int32_t classes,
                         int32_t read_weight, JbedError *error)
{
    void *context = c->services.context;
    jbed_compiler_set_progress(c, progress, progress_context, classes, read_weight);
    if (c->services.new_class_access) {
        if (!c->services.new_class_access(context, error))
            return false;
    } else {
        JbedClassAccess *a = c->services.class_access;
        if (!a)
            return fail(error, JBED_ERROR_INTERNAL, true, 0, "Missing compiler ClassAccess");
        if (a->runtime->registered_classes == a &&
            !a->runtime->protected_call(a->runtime->context, keep_published_classes, a, error))
            return false;
        *a = (JbedClassAccess){.heap = a->heap, .heap_image = a->heap_image,
                               .isolate_statics = a->isolate_statics,
                               .runtime = a->runtime, .packages = a->packages,
                               .base_names = a->base_names, .bundles = {a->bundles[0], a->bundles[1]},
                               .dynamic_bundle = a->dynamic_bundle, .next_low_id = 1, .all_classes = false};
        if (a->heap && !a->runtime->protected_call(a->runtime->context, start_guest_classes, a, error))
            return false;
    }
    JbedCompilerLayout *layout = c->services.class_layout;
    JbedSignatureEncoder *encoder = layout ? layout->pool->services->signature_encoder : NULL;
    if (c->services.new_signature_encoder) {
        if (!c->services.new_signature_encoder(context, error))
            return false;
    } else if (encoder)
        jbed_signature_init(encoder, encoder->services);
    else
        return fail(error, JBED_ERROR_INTERNAL, true, 0, "Missing signature encoder");
    if (!(c->services.coder ? backend_call(c, START_CODER, NULL, long_jumps, error)
                            : c->services.new_coder(context, options, long_jumps, error)))
        return false;
    c->options = options;
    if (c->services.coder)
        c->services.coder->debug_mode = options;
    c->has_coder = true;
    c->method_offset = 1;
    if (c->services.init_pool) {
        if (!c->services.init_pool(context, error))
            return false;
    } else if (!layout)
        return fail(error, JBED_ERROR_INTERNAL, true, 0, "Missing compiler pool services");
    if (c->services.verifier) {
        JbedVerifier *v = c->services.verifier;
        jbed_verifier_init(v, v->runtime, v->services);
        return true;
    }
    return c->services.new_verifier(context, error);
}

/* Compiler.compileDone, 0x146d48; reset, 0x146fb0. */
bool jbed_compiler_done(JbedCompiler *c, bool register_classes, JbedError *error)
{
    void *context = c->services.context;
    jbed_compiler_clear_progress(c);
    JbedCoder *coder = c->services.coder;
    if (c->has_coder && (coder ? coder->writer != NULL : c->services.coder_has_writer(context)))
        c->services.report_statistics(context, true);
    if (c->has_coder) {
        if (coder) {
            if (!backend_call(c, RESET_CODER, NULL, 0, error))
                return false;
        } else {
            c->services.reset_coder(context);
            c->services.detach_writer(context);
        }
    }
    if (c->services.verifier) {
        JbedVerifier *v = c->services.verifier;
        jbed_verifier_init(v, v->runtime, v->services);
    } else
        c->services.drop_verifier(context);
    if (c->services.drop_signature_encoder)
        c->services.drop_signature_encoder(context);
    else if (c->services.class_layout) {
        JbedSignatureEncoder *encoder = c->services.class_layout->pool->services->signature_encoder;
        if (encoder)
            jbed_signature_init(encoder, encoder->services);
    }
    if (c->services.reset_pool)
        c->services.reset_pool(context);
    JbedClassAccess *a = c->services.class_access;
    if (register_classes) {
        if (c->services.register_with_runtime)
            return c->services.register_with_runtime(context, error);
        if (!a)
            return fail(error, JBED_ERROR_INTERNAL, true, 0, "Missing compiler ClassAccess");
        jbed_class_publish(a);
        return true;
    }
    const JbedPoolServices *pool =
        c->services.class_layout ? c->services.class_layout->pool->services : NULL;
    if (c->services.reset_string_interning)
        c->services.reset_string_interning(context);
    else if (pool && pool->vm_strings && !jbed_vm_strings_reset(pool->vm_strings))
        return fail(error, pool->vm_strings->heap->fault == JBED_HEAP_OUT_OF_MEMORY
                               ? JBED_ERROR_OUT_OF_MEMORY : JBED_ERROR_INTERNAL,
                    true, 0, "Cannot reset string table");
    if (c->services.clear_dynamic_reflection)
        c->services.clear_dynamic_reflection(context);
    else if (pool) {
        if (pool->field_names)
            jbed_reflection_clear_dynamic(pool->field_names);
        if (pool->method_names)
            jbed_reflection_clear_dynamic(pool->method_names);
        if (pool->signature_encoder && pool->signature_encoder->services->reflection_table)
            jbed_reflection_clear_dynamic(pool->signature_encoder->services->reflection_table);
    }
    if (c->services.reset_class_tables) {
        c->services.reset_class_tables(context);
    } else if (a) {
        jbed_reflection_clear_dynamic(a->base_names);
        jbed_reflection_clear_dynamic(a->packages);
        a->dynamic_bundle = 1;
    }
    if (c->services.discard_code_ranges)
        c->services.discard_code_ranges(context);
    else
        jbed_method_discard_ranges(c->services.emitter->runtime);
    if (c->services.drop_classes_and_coder)
        c->services.drop_classes_and_coder(context);
    jbed_class_release_compiler_root(a);
    c->has_coder = false;
    return true;
}
bool jbed_compiler_reset(JbedCompiler *c, JbedError *error)
{
    return jbed_compiler_done(c, false, error);
}

/* Compiler.flushFixups, 0x146fc4. */
bool jbed_compiler_flush_fixups(JbedCompiler *c, uint32_t boundary, JbedError *error)
{
    void *context = c->services.context;
    for (JbedClass *k = NULL; (k = next_class(c, k)) != NULL;)
        if (!(c->services.coder ? backend_call(c, FLUSH_CLASS, k, boundary, error)
                                : c->services.flush_class_fixups(context, k, boundary, error)))
            return false;
    return c->services.coder ? backend_call(c, FLUSH_CURRENT, NULL, boundary, error)
                             : c->services.flush_current_fixups(context, boundary, error);
}
