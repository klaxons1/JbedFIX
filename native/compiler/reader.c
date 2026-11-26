#include "reader.h"
#include "vm_types.h"
#include "vm_memory.h"
#include "rom_objects.h"

#include <limits.h>
#include <string.h>

#define CLASSFILE_MAGIC UINT32_C(0xcafebabe)
enum {
    CLASSFILE_MIN_MAJOR = 45,
    CLASSFILE_MAX_MAJOR = 48,
    OVERFLOW_POINTER_STATICS = 0x400000,
    OVERFLOW_PRIMITIVE_STATICS = 0x800000
};

static bool reader_error(JbedError *error, JbedErrorKind kind, const char *message)
{
    if (error)
        *error = (JbedError){.kind = kind,
                             .is_java_error =
                                 kind != JBED_ERROR_NULL_POINTER && kind != JBED_ERROR_ARRAY_INDEX,
                             .bytecode_offset = -1,
                             .message = message};
    return false;
}

static bool format_error(JbedEmitter *emitter, JbedError *error)
{
    JbedError failure = jbed_emitter_error(emitter, JBED_EMITTER_CLASS_FORMAT, 0, 0, 0, 0);
    if (error)
        *error = failure;
    return false;
}

static int32_t add32(int32_t a, int32_t b)
{
    return (int32_t)((uint32_t)a + (uint32_t)b);
}
static int32_t sub32(int32_t a, int32_t b)
{
    return (int32_t)((uint32_t)a - (uint32_t)b);
}
static uint32_t align4(uint32_t n)
{
    return (n + 3) & ~UINT32_C(3);
}

/* Reader.<init>, 0x149510: wrapping offset+length is compared as signed;
 * only an overlong sum clips length. Invalid offsets remain deferred to reads. */
bool jbed_reader_init(JbedReader *reader, JbedRuntime *runtime, const uint8_t *data, size_t size,
                      int32_t offset, int32_t length, JbedError *error)
{
    if (!data)
        return reader_error(error, JBED_ERROR_NULL_POINTER, "Null classfile bytes");
    if (size > INT32_MAX)
        return reader_error(error, JBED_ERROR_INTERNAL,
                            "Host byte array exceeds Java array length range");
    memset(reader, 0, sizeof(*reader));
    reader->runtime = runtime;
    reader->data = data;
    reader->data_length = size;
    reader->offset = offset;
    reader->bytes_left =
        add32(offset, length) > (int32_t)size ? sub32((int32_t)size, offset) : length;
    return true;
}

/* Reader.readByte 0x149b7e, readU2 0x149e88, readS4 0x149ca8. Exhausted
 * reads return zero and keep reducing bytesLeft; close detects the overread. */
uint8_t jbed_reader_read(JbedReader *reader)
{
    if (reader->bytes_left > 0 &&
        (reader->offset < 0 || (size_t)reader->offset >= reader->data_length)) {
        const JbedError fault = {.kind = JBED_ERROR_ARRAY_INDEX,
                                 .message = "Classfile read outside byte array"};
        jbed_raise(reader->runtime, &fault);
    }
    uint8_t value = reader->bytes_left > 0 ? reader->data[reader->offset++] : 0;
    reader->bytes_left = sub32(reader->bytes_left, 1);
    return value;
}
uint16_t jbed_reader_u2(JbedReader *reader)
{
    uint16_t high = jbed_reader_read(reader);
    return (uint16_t)((high << 8) | jbed_reader_read(reader));
}
uint32_t jbed_reader_s4(JbedReader *reader)
{
    uint32_t value = 0;
    for (unsigned i = 0; i < 4; ++i)
        value = (value << 8) | jbed_reader_read(reader);
    return value;
}

/* Reader.read, 0x149b9e. Failed full reads leave the destination and position
 * untouched. The original exposes failure through bytesLeft, not an EOF throw. */
bool jbed_reader_bytes(JbedReader *reader, void *out, int32_t count, JbedError *error)
{
    reader->bytes_left = sub32(reader->bytes_left, count);
    if (reader->bytes_left >= 0) {
        if (count < 0 || reader->offset < 0 || (size_t)reader->offset > reader->data_length ||
            (size_t)count > reader->data_length - (size_t)reader->offset)
            return reader_error(error, JBED_ERROR_ARRAY_INDEX, "Invalid classfile copy");
        if (count)
            memcpy(out, reader->data + reader->offset, (size_t)count);
        reader->offset = add32(reader->offset, count);
    }
    return true;
}

/* Reader.skip/close/pos/remaining, 0x149eac/0x149b6c/0x149b7a/0x149ea8. */
void jbed_reader_skip(JbedReader *reader, int32_t count)
{
    reader->bytes_left = sub32(reader->bytes_left, count);
    if (reader->bytes_left >= 0)
        reader->offset = add32(reader->offset, count);
}
bool jbed_reader_close(const JbedReader *reader)
{
    return reader->bytes_left != 0;
}
int32_t jbed_reader_position(const JbedReader *reader)
{
    return reader->offset;
}
int32_t jbed_reader_remaining(const JbedReader *reader)
{
    return reader->bytes_left;
}

static void map_capacity(JbedReader *reader, JbedRuntime *runtime, size_t needed)
{
    if (needed <= reader->map_capacity)
        return;
    size_t capacity = reader->map_capacity * 2;
    if (capacity < needed)
        capacity = needed;
    uint32_t *words = jbed_alloc(runtime, capacity * sizeof(*words));
    memcpy(words, reader->map.words, reader->map_capacity * sizeof(*words));
    reader->map.words = words;
    reader->map_capacity = capacity;
}

/* Reader.readTypeList, 0x149cdc. Identical local/operand type vectors share
 * one packed list. Long and double each consume two verifier slots. */
static bool read_type_list(JbedReader *reader, JbedRuntime *runtime, size_t slot, size_t first,
                           size_t *cursor, int32_t limit, JbedError *error)
{
    uint16_t count = jbed_reader_u2(reader);
    if (!count) {
        reader->map.words[slot] = 0;
        return true;
    }
    map_capacity(reader, runtime, *cursor + count + 1);
    uint32_t *words = reader->map.words;
    words[*cursor] = count;
    for (size_t i = 0; i < count; ++i) {
        uint16_t tag = jbed_reader_read(reader);
        if (tag == 7)
            tag = (uint16_t)(jbed_reader_u2(reader) + 7);
        else if (tag == 8)
            tag = (uint16_t)(jbed_reader_u2(reader) + 0x8000);
        else if (tag == 3 || tag == 4)
            --limit;
        else if (tag > 8)
            return format_error(reader->emitter, error);
        words[*cursor + i + 1] = tag;
    }
    if (count > limit)
        return format_error(reader->emitter, error);
    for (size_t previous = first; previous < *cursor; previous += words[previous] + 1) {
        if (words[previous] == count &&
            !memcmp(words + previous + 1, words + *cursor + 1, count * sizeof(*words))) {
            words[slot] = (uint32_t)previous;
            return true;
        }
    }
    words[slot] = (uint32_t)*cursor;
    *cursor += count + 1;
    return true;
}

/* Reader.readMaps, 0x149bd2. */
bool jbed_reader_maps(JbedReader *reader, JbedEmitter *emitter, const JbedMethod *method,
                      JbedStackMaps *out, JbedError *error)
{
    JbedRuntime *runtime = emitter->runtime;
    reader->runtime = runtime;
    reader->emitter = emitter;
    uint16_t count = jbed_reader_u2(reader);
    reader->map_capacity = (size_t)count * 8 + 1;
    reader->map.words = jbed_alloc(runtime, reader->map_capacity * sizeof(*reader->map.words));
    reader->map.words[0] = count;
    size_t first = (size_t)count * 3 + 1, cursor = first;
    for (size_t i = 0; i < count; ++i) {
        reader->map.words[i + 1] = jbed_reader_u2(reader);
        if (!read_type_list(reader, runtime, count + 2 * i + 1, first, &cursor, method->max_locals,
                            error) ||
            !read_type_list(reader, runtime, count + 2 * i + 2, first, &cursor, method->max_stack,
                            error))
            return false;
    }
    out->words = jbed_alloc(runtime, cursor * sizeof(*out->words));
    memcpy(out->words, reader->map.words, cursor * sizeof(*out->words));
    out->word_count = cursor;
    reader->map = (JbedStackMaps){0};
    reader->map_capacity = 0;
    return true;
}

/* Reader.ReadAttributes, 0x14954c. Context distinguishes method attributes
 * from the nested attributes of Code; unknown attributes are skipped exactly. */
static bool read_attributes(JbedReader *reader, JbedClass *owner, JbedField *field,
                            JbedMethod *method, JbedMethod *code_method, JbedError *error)
{
    JbedPool *pool = owner->pool;
    JbedRuntime *runtime = pool->services->runtime;
    uint16_t count = jbed_reader_u2(reader);
    for (size_t i = 0; i < count; ++i) {
        JbedAttribute attribute;
        if (!jbed_pool_attribute(pool, jbed_reader_u2(reader), &attribute, error))
            return false;
        int32_t length = (int32_t)jbed_reader_s4(reader);
        int32_t end = add32(reader->offset, length);
        if (attribute == JBED_ATTRIBUTE_CODE && method) {
            if (method->code)
                return format_error(reader->emitter, error);
            method->max_stack = jbed_reader_u2(reader);
            method->max_locals = jbed_reader_u2(reader);
            int32_t bytes = (int32_t)jbed_reader_s4(reader);
            if (bytes <= 0 || bytes > reader->bytes_left)
                return format_error(reader->emitter, error);
            method->code_length = (size_t)bytes;
            method->code = jbed_alloc(runtime, (size_t)bytes);
            if (!jbed_reader_bytes(reader, method->code, bytes, error))
                return false;
            method->handler_count = jbed_reader_u2(reader);
            if (method->handler_count) {
                if ((int32_t)(method->handler_count * 8) > reader->bytes_left)
                    return format_error(reader->emitter, error);
                method->handlers =
                    jbed_alloc(runtime, method->handler_count * sizeof(*method->handlers));
                for (size_t j = 0; j < method->handler_count; ++j) {
                    JbedExceptionHandler *handler = &method->handlers[j];
                    handler->start_pc = jbed_reader_u2(reader);
                    handler->end_pc = jbed_reader_u2(reader);
                    if (handler->start_pc >= handler->end_pc || handler->end_pc > (uint32_t)bytes)
                        return format_error(reader->emitter, error);
                    handler->handler_pc = jbed_reader_u2(reader);
                    handler->catch_index = jbed_reader_u2(reader);
                }
                method->flags |= JBED_METHOD_HAS_HANDLERS;
            }
            if (!read_attributes(reader, owner, NULL, NULL, method, error))
                return false;
        } else if (attribute == JBED_ATTRIBUTE_CONSTANT_VALUE && field &&
                   (field->flags & JBED_ACC_STATIC)) {
            field->constant_index = jbed_reader_u2(reader);
            if (!field->constant_index ||
                (field->flags & (JBED_FIELD_CONSTANT | JBED_FIELD_INITIALIZE_STATIC)))
                return format_error(reader->emitter, error);
            if (field->flags & JBED_ACC_FINAL)
                field->flags |= JBED_FIELD_CONSTANT;
            else {
                field->flags |= JBED_FIELD_INITIALIZE_STATIC;
                --owner->static_initializer_count;
            }
        } else if (attribute == JBED_ATTRIBUTE_STACK_MAP && code_method) {
            if (code_method->stack_maps.words)
                return format_error(reader->emitter, error);
            if (!jbed_reader_maps(reader, pool->services->emitter, code_method,
                                  &code_method->stack_maps, error))
                return false;
        } else if (attribute == JBED_ATTRIBUTE_EXCEPTIONS && method) {
            uint16_t exceptions = jbed_reader_u2(reader);
            if (exceptions) {
                if ((int32_t)exceptions * 2 > reader->bytes_left ||
                    (method->flags & JBED_METHOD_DECLARED_EXCEPTIONS))
                    return format_error(reader->emitter, error);
                method->flags |= JBED_METHOD_DECLARED_EXCEPTIONS;
                for (size_t j = 0; j < exceptions; ++j) {
                    JbedTypeId ignored;
                    if (!jbed_pool_class_id(pool, jbed_reader_u2(reader), &ignored, error))
                        return false;
                }
            }
        } else {
            if (attribute == JBED_ATTRIBUTE_STACK_MAP && method)
                return format_error(reader->emitter, error);
            jbed_reader_skip(reader, length);
        }
        if (reader->offset != end)
            return format_error(reader->emitter, error);
    }
    return true;
}

/* Reader.ReadClass, 0x149848. Pool resolves after all uses have been marked;
 * duplicate members are compared after their reflection IDs are assigned. */
bool jbed_reader_class(JbedReader *reader, const JbedPoolServices *services, JbedClass *owner,
                       JbedError *error)
{
    reader->runtime = services->runtime;
    reader->emitter = services->emitter;
    uint32_t magic = jbed_reader_s4(reader);
    (void)jbed_reader_u2(reader);
    uint16_t major = jbed_reader_u2(reader);
    if (!owner)
        return reader_error(error, JBED_ERROR_NULL_POINTER, "Null class object");
    if (!services->emitter)
        return reader_error(error, JBED_ERROR_INTERNAL, "Missing emitter import context");
    jbed_emitter_set_import(services->emitter, owner->id, 0, 0);
    unsigned max_major = services->boot_image ? 49 : CLASSFILE_MAX_MAJOR;
    if (magic != CLASSFILE_MAGIC || major < CLASSFILE_MIN_MAJOR || major > max_major)
        return format_error(reader->emitter, error);
    JbedPool *pool = jbed_alloc(services->runtime, sizeof(*pool));
    jbed_pool_init(pool, services, owner);
    if (!jbed_pool_read(pool, reader, error))
        return false;
    uint32_t flags = jbed_reader_u2(reader) | JBED_CLASS_DYNAMIC;
    if (((flags & JBED_ACC_INTERFACE) && !(flags & JBED_ACC_ABSTRACT)) ||
        ((flags & JBED_ACC_FINAL) && (flags & JBED_ACC_ABSTRACT)))
        return format_error(reader->emitter, error);
    uint16_t self = jbed_reader_u2(reader), super = jbed_reader_u2(reader);
    owner->pool = pool;
    owner->flags = flags;
    uint16_t interface_count = jbed_reader_u2(reader);
    uint16_t *interfaces =
        jbed_alloc(services->runtime, (size_t)interface_count * sizeof(*interfaces));
    for (size_t i = 0; i < interface_count; ++i)
        interfaces[i] = jbed_reader_u2(reader);
    owner->field_count = jbed_reader_u2(reader);
    JbedField **field_tail = &owner->fields;
    for (size_t i = 0; i < owner->field_count; ++i) {
        JbedField *field = jbed_alloc(services->runtime, sizeof(*field));
        field->owner = owner;
        uint32_t field_flags = jbed_reader_u2(reader);
        field->name_id = jbed_reader_u2(reader);
        field->type_id = jbed_reader_u2(reader);
        if (!jbed_pool_mark_field(pool, field, error))
            return false;
        field->flags = field_flags;
        if (!read_attributes(reader, owner, field, NULL, NULL, error))
            return false;
        *field_tail = field;
        field_tail = &field->next;
    }
    owner->method_count = jbed_reader_u2(reader);
    JbedMethod **method_tail = &owner->methods;
    for (size_t i = 0; i < owner->method_count; ++i) {
        JbedMethod *method = jbed_alloc(services->runtime, sizeof(*method));
        method->owner = owner;
        uint32_t method_flags = jbed_reader_u2(reader);
        method->name_id = jbed_reader_u2(reader);
        method->signature_id = jbed_reader_u2(reader);
        if (!jbed_pool_mark_method(pool, method, error))
            return false;
        method->flags = method_flags;
        if (!read_attributes(reader, owner, NULL, method, NULL, error))
            return false;
        if (!(method_flags & (JBED_ACC_NATIVE | JBED_ACC_ABSTRACT)) && !method->code)
            return format_error(reader->emitter, error);
        *method_tail = method;
        method_tail = &method->next;
    }
    if (!read_attributes(reader, owner, NULL, NULL, NULL, error))
        return false;
    if (jbed_reader_close(reader))
        return format_error(reader->emitter, error);
    if (!jbed_pool_resolve(pool, error) ||
        !jbed_pool_resolve_class_ids(pool, self, super, interfaces, interface_count, error))
        return false;
    for (JbedField *field = owner->fields; field; field = field->next) {
        if (!jbed_pool_resolve_field_ids(pool, field, error))
            return false;
        for (JbedField *prior = owner->fields; prior != field; prior = prior->next)
            if (prior->name_id == field->name_id && prior->type_id == field->type_id)
                return format_error(reader->emitter, error);
    }
    for (JbedMethod *method = owner->methods; method; method = method->next) {
        if (!jbed_pool_resolve_method_ids(pool, method, error))
            return false;
        for (JbedMethod *prior = owner->methods; prior != method; prior = prior->next)
            if (prior->name_id == method->name_id && prior->signature_id == method->signature_id)
                return format_error(reader->emitter, error);
    }
    jbed_pool_read_complete(pool);
    if (owner->static_initializer_count) {
        JbedMethod *method = jbed_alloc(services->runtime, sizeof(*method));
        method->owner = owner;
        method->flags = JBED_METHOD_CLASS_INITIALIZER | JBED_ACC_STATIC;
        method->name_id = JBED_NAME_CLINIT;
        method->signature_id = JBED_SIGNATURE_VOID_NO_ARGS;
        method->code = jbed_alloc(services->runtime, 1);
        method->code[0] = 177;
        method->code_length = 1;
        method->dispatch_slot = (int16_t)owner->static_initializer_count;
        *method_tail = method;
        owner->static_initializer_count = 0;
    }
    jbed_emitter_set_import(services->emitter, 0, 0, 0);
    return true;
}

/* Reader.initReader, 0x1494c8. Static references grow down into the initial
 * arena; after exhaustion the two kinds use distinct relocation domains. */
void jbed_reader_layout_init(JbedReaderLayout *layout, uint32_t relative_base, int32_t capacity,
                             uint32_t static_base, uint32_t mode_bit)
{
    *layout = (JbedReaderLayout){.next_init_flag = -1,
                                 .first_pointer_range = -1,
                                 .primitive_static_top =
                                     capacity > 0 ? 0 : OVERFLOW_PRIMITIVE_STATICS,
                                 .pointer_static_top =
                                     capacity > 0 ? capacity : OVERFLOW_POINTER_STATICS,
                                 .relative_statics_base = relative_base,
                                 .initial_static_capacity = capacity,
                                 .static_base = static_base,
                                 .code_mode_bit = mode_bit};
}

static bool reference_type(JbedTypeId type)
{
    return type < 4 || type > 11;
}

static bool layout_register(void *ctx, JbedClass *klass, JbedError *error)
{
    (void)error;
    jbed_writer_register_class(ctx, klass);
    return true;
}

static bool layout_allocate(void *ctx, JbedClass *klass, uint32_t size, uint32_t *address,
                            JbedError *error)
{
    (void)error;
    *address = jbed_writer_allocate(ctx, (JbedCodeOwner *)klass, size);
    return true;
}

static bool layout_word(void *ctx, uint32_t address, uint32_t value, JbedError *error)
{
    (void)error;
    jbed_writer_put_word(ctx, address, value);
    return true;
}

static bool layout_halfword(void *ctx, uint32_t address, uint16_t value, JbedError *error)
{
    (void)error;
    jbed_writer_put_halfword(ctx, address, value);
    return true;
}

static bool layout_class(void *ctx, uint32_t address, JbedClass *klass, JbedError *error)
{
    JbedWriter *writer = ctx;
    if (writer->block_writer) {
        jbed_writer_register_class(writer, klass);
        jbed_rom_write_class(writer->block_writer->rom_objects, address, klass);
        return true;
    }
    const JbedRomServices *rom = writer->services->rom_services;
    JbedAddress target = rom ? jbed_rom_class_address(rom, klass) : 0;
    if (klass && !target)
        return reader_error(error, JBED_ERROR_INTERNAL, "Missing direct class address");
    jbed_writer_put_pointer(writer, address, target);
    return true;
}

static bool layout_reloc(void *ctx, uint32_t address, uint32_t value, bool resident,
                         JbedError *error)
{
    (void)error;
    jbed_writer_put_reloc(ctx, address, value, resident);
    return true;
}

void jbed_reader_layout_use_writer(JbedReaderLayoutServices *services, JbedWriter *writer)
{
    services->context = writer;
    services->register_class = layout_register;
    services->allocate_descriptor = layout_allocate;
    services->put_word = layout_word;
    services->put_halfword = layout_halfword;
    services->put_class = layout_class;
    services->put_relocation = layout_reloc;
}

static bool incompatible(JbedEmitter *emitter, JbedError *error, JbedTypeId type)
{
    JbedError failure = jbed_emitter_error(emitter, JBED_EMITTER_INCOMPATIBLE_CLASS, type, 0, 0, 0);
    if (error)
        *error = failure;
    return false;
}

static bool class_accessible(JbedPool *pool, JbedClass *from, JbedClass *to, bool *accessible,
                             JbedError *error)
{
    if (!to)
        return reader_error(error, JBED_ERROR_NULL_POINTER, "Null superclass or interface");
    if (to->flags & JBED_ACC_PUBLIC) {
        *accessible = true;
        return true;
    }
    return jbed_pool_same_package(pool, from, to, accessible, error);
}

/* Reader.PrepareClass, 0x148c48: field storage, inherited flags and virtual
 * slots are assigned before translation. Method slot zero is the original
 * unassigned sentinel, including the ROM's treatment of inherited slot zero. */
bool jbed_reader_prepare(JbedReaderLayout *layout, const JbedReaderLayoutServices *services,
                         JbedClass *klass, JbedError *error)
{
    if (!klass)
        return reader_error(error, JBED_ERROR_NULL_POINTER, "Null class");
    JbedPool *pool = services->pool;
    const JbedPoolServices *ps = pool->services;
    if (!ps->emitter || !services->register_class)
        return reader_error(error, JBED_ERROR_INTERNAL, "Missing Reader preparation service");
    klass->flags |= JBED_CLASS_PREPARED;
    jbed_emitter_set_import(ps->emitter, klass->id, 0, 0);
    JbedClass *base = klass->superclass;
    if (!base)
        return reader_error(error, JBED_ERROR_NULL_POINTER, "Null superclass");
    int32_t size, slots;
    if (klass->flags & JBED_ACC_INTERFACE) {
        if (base->depth > 0)
            return format_error(ps->emitter, error);
        klass->depth = 0;
        size = slots = 0;
    } else {
        bool accessible;
        if (!class_accessible(pool, klass, base, &accessible, error))
            return false;
        if (!accessible || (base->flags & (JBED_ACC_INTERFACE | JBED_ACC_FINAL)))
            return incompatible(ps->emitter, error, base->id);
        if (klass->flags & JBED_CLASS_ARRAY) {
            if (!services->array_base_class)
                return reader_error(error, JBED_ERROR_NULL_POINTER, "Missing array base class");
            klass->depth = 1;
            size = 16;
            slots = services->array_base_class->vtable_size;
        } else {
            klass->depth = (int16_t)(base->depth + 1);
            size = base->instance_size;
            slots = base->vtable_size;
        }
    }
    klass->flags |= base->flags & (JBED_CLASS_TRACE | JBED_CLASS_FINALIZED);
    for (size_t i = klass->interface_count; i > 0; --i) {
        JbedClass *iface = klass->interfaces[i - 1];
        bool accessible;
        if (!class_accessible(pool, klass, iface, &accessible, error))
            return false;
        if (!accessible || !(iface->flags & JBED_ACC_INTERFACE))
            return incompatible(ps->emitter, error, iface->id);
        klass->flags |= iface->flags & JBED_CLASS_FINALIZED;
    }
    for (JbedField *field = klass->fields; field; field = field->next) {
        bool reference = reference_type(field->type_id);
        int32_t width = reference ? 4 : 1 << (field->type_id & 3);
        if (field->flags & JBED_FIELD_CONSTANT)
            continue;
        if (!(field->flags & JBED_ACC_STATIC)) {
            size = add32(size, (int32_t)((0u - (uint32_t)size) & (uint32_t)(width - 1)));
            field->offset = (uint32_t)size;
            size = add32(size, width);
        } else if (reference) {
            int32_t top = layout->pointer_static_top;
            if (top > layout->initial_static_capacity) {
                field->offset = (uint32_t)top;
                layout->pointer_static_top = add32(top, 4);
            } else {
                layout->pointer_static_top = sub32(top, 4);
                if (layout->pointer_static_top < layout->primitive_static_top) {
                    layout->first_pointer_range = top;
                    field->offset = OVERFLOW_POINTER_STATICS;
                    layout->pointer_static_top = OVERFLOW_POINTER_STATICS + 4;
                    layout->primitive_static_top = OVERFLOW_PRIMITIVE_STATICS;
                } else {
                    field->flags |= JBED_FIELD_RELATIVE_STATIC;
                    field->offset = (uint32_t)layout->pointer_static_top;
                }
            }
        } else {
            int32_t top = layout->primitive_static_top;
            int32_t aligned = add32(top, (int32_t)((0u - (uint32_t)top) & (uint32_t)(width - 1)));
            if (top > layout->initial_static_capacity) {
                field->offset = (uint32_t)aligned;
                layout->primitive_static_top = add32(aligned, width);
            } else {
                layout->primitive_static_top = aligned;
                if (add32(aligned, width) > layout->pointer_static_top) {
                    layout->first_pointer_range = layout->pointer_static_top;
                    field->offset = OVERFLOW_PRIMITIVE_STATICS;
                    layout->primitive_static_top = OVERFLOW_PRIMITIVE_STATICS + width;
                    layout->pointer_static_top = OVERFLOW_POINTER_STATICS;
                } else {
                    field->flags |= JBED_FIELD_RELATIVE_STATIC;
                    field->offset = (uint32_t)aligned;
                    layout->primitive_static_top = add32(aligned, width);
                }
            }
        }
    }
    klass->instance_size = size;
    if (!services->register_class(services->context, klass, error))
        return false;
    for (JbedMethod *method = klass->methods; method; method = method->next) {
        if (method->flags & JBED_METHOD_CONSTRUCTOR) {
            method->dispatch_slot = -1;
            if (!(method->flags & JBED_ACC_PRIVATE))
                klass->flags |= JBED_CLASS_INSTANTIABLE;
        } else if (method->flags & JBED_ACC_STATIC) {
            method->dispatch_slot = (int16_t)(method->dispatch_slot - 1);
        } else if (klass->flags & JBED_ACC_INTERFACE) {
            method->dispatch_slot = (int16_t)slots++;
            method->flags |= JBED_METHOD_VIRTUAL_DISPATCH;
        } else {
            if ((klass->flags | method->flags) & JBED_ACC_ABSTRACT)
                method->flags |= JBED_METHOD_VIRTUAL_DISPATCH;
            if (!(method->flags & JBED_ACC_PRIVATE)) {
                for (JbedClass *ancestor = klass->superclass; ancestor;
                     ancestor = ancestor->superclass) {
                    JbedMethod *inherited;
                    if (!jbed_vm_find_method(ps, ancestor, method->name_id,
                                             method->signature_id, &inherited, error))
                        return false;
                    if (!inherited || (inherited->flags & JBED_ACC_STATIC) ||
                        !jbed_vm_method_visible(ps, inherited))
                        continue;
                    bool accessible;
                    if (!jbed_pool_accessible(pool, klass, inherited->owner, inherited->flags,
                                              &accessible, error))
                        return false;
                    if (!accessible)
                        continue;
                    if (inherited->flags & JBED_ACC_FINAL)
                        return incompatible(ps->emitter, error, klass->id);
                    if (inherited->owner->flags & JBED_CLASS_DYNAMIC)
                        inherited->flags |= JBED_METHOD_VIRTUAL_DISPATCH;
                    method->dispatch_slot = inherited->dispatch_slot;
                }
            }
            if (!method->dispatch_slot) {
                if ((method->flags | method->owner->flags) & (JBED_ACC_FINAL | JBED_ACC_PRIVATE))
                    method->dispatch_slot = -1;
                else
                    method->dispatch_slot = (int16_t)slots++;
            }
        }
    }
    klass->vtable_size = (int16_t)slots;
    jbed_emitter_set_import(ps->emitter, 0, 0, 0);
    return true;
}

/* Reader.fixupRelativeFields, 0x149328. */
void jbed_reader_fixup_fields(JbedReaderLayout *layout, JbedClass *klass)
{
    if (layout->next_init_flag == -1) {
        if (layout->first_pointer_range == -1) {
            layout->next_init_flag = layout->primitive_static_top;
            if (!layout->next_init_flag && layout->pointer_static_top)
                layout->next_init_flag = 1;
        } else {
            layout->next_init_flag =
                (int32_t)(align4(layout->relative_statics_base) +
                          (uint32_t)layout->pointer_static_top - OVERFLOW_POINTER_STATICS +
                          (uint32_t)layout->primitive_static_top - OVERFLOW_PRIMITIVE_STATICS);
        }
    }
    if (layout->next_init_flag == layout->pointer_static_top)
        layout->next_init_flag = (int32_t)layout->relative_statics_base;
    klass->init_flags = (uint32_t)layout->next_init_flag;
    layout->next_init_flag = add32(layout->next_init_flag, 1);
    if (layout->first_pointer_range != -1) {
        uint32_t aligned = align4(layout->relative_statics_base);
        uint32_t pointer_delta = aligned - OVERFLOW_POINTER_STATICS;
        uint32_t primitive_delta = (uint32_t)layout->pointer_static_top + aligned -
                                   (OVERFLOW_POINTER_STATICS + OVERFLOW_PRIMITIVE_STATICS);
        for (JbedField *field = klass->fields; field; field = field->next) {
            if ((field->flags & (JBED_ACC_STATIC | JBED_FIELD_RELATIVE_STATIC | JBED_FIELD_CONSTANT)) !=
                JBED_ACC_STATIC)
                continue;
            field->flags |= JBED_FIELD_RELATIVE_STATIC;
            field->offset += reference_type(field->type_id) ? pointer_delta : primitive_delta;
        }
    }
}

/* Reader.getPointerRanges/getRelStaticsSize, 0x149434/0x1494a4. */
size_t jbed_reader_pointer_ranges(const JbedReaderLayout *layout, uint32_t ranges[4])
{
    ranges[1] = (uint32_t)layout->initial_static_capacity + layout->static_base;
    if (layout->first_pointer_range == -1) {
        ranges[0] = (uint32_t)layout->pointer_static_top;
        return 2;
    }
    ranges[0] = (uint32_t)layout->first_pointer_range;
    ranges[2] = align4(layout->relative_statics_base);
    ranges[3] = ranges[2] + (uint32_t)layout->pointer_static_top - OVERFLOW_POINTER_STATICS;
    return 4;
}
uint32_t jbed_reader_relative_statics_size(const JbedReaderLayout *layout)
{
    return layout->next_init_flag > (int32_t)layout->relative_statics_base
               ? (uint32_t)layout->next_init_flag
               : layout->relative_statics_base;
}

/* Reader.CheckDouble, 0x148be0: distinguish the current declaration from a
 * transitive interface already supplied by another class/interface. */
static int check_double(const JbedClass *klass, const JbedClass *target, const JbedClass *origin)
{
    for (size_t i = 0; i < klass->interface_count; ++i) {
        if (klass->interfaces[i] == target)
            return klass == origin ? 1 : 2;
        int found = check_double(klass->interfaces[i], target, origin);
        if (found)
            return found;
    }
    return 0;
}

/* Reader.PutMethods, 0x14911a. Private or package-inaccessible overrides do
 * not replace an inherited table entry. Interface tables require public
 * instance implementations; abstract slots use the runtime throw thunk. */
static bool put_methods(const JbedReaderLayout *layout, const JbedReaderLayoutServices *services,
                        uint32_t address, JbedClass *declaring, JbedClass *implementation,
                        uint32_t *end, JbedError *error)
{
    JbedPool *pool = services->pool;
    const JbedPoolServices *ps = pool->services;
    for (int32_t slot = 0; slot < declaring->vtable_size; ++slot) {
        JbedMethod *method;
        if (services->method_by_number) {
            if (!services->method_by_number(services->context, declaring, slot, &method, error))
                return false;
        } else
            method = jbed_vm_method_by_number(declaring, slot);
        if (method) {
            JbedClass *start = implementation ? implementation : declaring;
            if (!jbed_vm_method_visible(ps, method)) {
                while (start && (start->flags & JBED_CLASS_DYNAMIC))
                    start = start->superclass;
                if (!start)
                    return reader_error(error, JBED_ERROR_NULL_POINTER,
                                        "Missing resident method owner");
            }
            if (implementation) {
                JbedMethod *chosen = NULL;
                for (JbedClass *candidate = start; candidate; candidate = candidate->superclass) {
                    if (!jbed_vm_find_method(ps, candidate, method->name_id,
                                             method->signature_id, &chosen, error))
                        return false;
                    if (chosen &&
                        (!(chosen->flags & JBED_ACC_PUBLIC) || (chosen->flags & JBED_ACC_STATIC)))
                        chosen = NULL;
                    if (chosen)
                        break;
                }
                method = chosen;
            } else {
                if (method->flags & JBED_ACC_PRIVATE)
                    jbed_halt(ps->runtime, 0, "Private method in virtual table");
                for (;;) {
                    JbedMethod *chosen = NULL;
                    for (JbedClass *candidate = start; candidate != method->owner;
                         candidate = candidate->superclass) {
                        if (!candidate)
                            return reader_error(error, JBED_ERROR_NULL_POINTER,
                                                "Broken method ancestry");
                        if (!jbed_vm_find_method(ps, candidate, method->name_id,
                                                 method->signature_id, &chosen, error))
                            return false;
                        if (chosen) {
                            bool same = true;
                            if (!(method->flags & (JBED_ACC_PUBLIC | JBED_ACC_PROTECTED)) &&
                                !jbed_pool_same_package(pool, method->owner, candidate, &same,
                                                        error))
                                return false;
                            if (!same || (chosen->flags & JBED_ACC_PRIVATE))
                                chosen = NULL;
                        }
                        if (chosen)
                            break;
                    }
                    if (!chosen)
                        break;
                    method = chosen;
                }
            }
            if (method && (method->flags & JBED_ACC_ABSTRACT))
                method = NULL;
        }
        uint32_t target = services->throw_abstract_address;
        bool resident = true;
        if (method) {
            target = method->code_address;
            resident = !(method->owner->flags & JBED_CLASS_DYNAMIC) ||
                       (!method->generated_size && !(method->flags & JBED_METHOD_CODE_RANGES));
        }
        if (!services->put_relocation(services->context, address, target | layout->code_mode_bit,
                                      resident, error))
            return false;
        address += 4;
    }
    *end = address;
    return true;
}

/* Reader.PutInterfaceTable, 0x149038. A null writer in the original invokes
 * this same traversal to measure the descriptor before allocating it. */
static bool interface_table(const JbedReaderLayout *layout,
                            const JbedReaderLayoutServices *services, bool write,
                            JbedClass *implementation, JbedClass *scan, uint32_t address,
                            uint32_t *end, JbedError *error)
{
    for (size_t i = 0; i < scan->interface_count; ++i) {
        JbedClass *iface = scan->interfaces[i];
        int duplicate = 0;
        for (JbedClass *base = implementation; base && !duplicate; base = base->superclass)
            duplicate = check_double(base, iface, scan);
        if (!duplicate)
            return reader_error(error, JBED_ERROR_NULL_POINTER, "Interface outside class ancestry");
        if (duplicate != 1)
            continue;
        if (write) {
            if (!services->put_relocation(services->context, implementation->descriptor_address,
                                          address, false, error) ||
                !services->put_class(services->context, address, iface, error))
                return false;
            implementation->descriptor_address = address + 4;
            if (!services->put_word(services->context, address + 4, 0, error) ||
                !put_methods(layout, services, address + 8, iface, implementation, &address, error))
                return false;
        } else
            address += (uint32_t)(4 * iface->vtable_size + 8);
        if (!interface_table(layout, services, write, implementation, iface, address, &address,
                             error))
            return false;
    }
    *end = address;
    return true;
}

static bool pointer_field_addresses(const JbedReaderLayoutServices *services, JbedClass *klass,
                                    uint32_t cursor, bool write, uint32_t *end, JbedError *error)
{
    if (services->pointer_fields)
        return services->pointer_fields(services->context, klass, cursor, write, end, error);

    /* Field.putPtrFieldAddresses, 0x12c444. Resident packed fields and the
     * dynamic field list both visit declarations in order, subclass first. */
    for (; klass && klass->depth > 0; klass = klass->superclass) {
        for (const JbedField *field = klass->fields; field; field = field->next) {
            bool reference = (klass->flags & JBED_CLASS_DYNAMIC)
                                 ? jbed_pool_primitive_type(field->type_id) == 2
                                 : field->type_id >= 16;
            if ((field->flags & JBED_ACC_STATIC) || !reference)
                continue;
            if (write) {
                if (!field->offset || (uint32_t)(int32_t)(int16_t)field->offset != field->offset)
                    jbed_halt(services->pool->services->runtime, 0, "Invalid reference field offset");
                if (!services->put_halfword(services->context, cursor, (uint16_t)field->offset,
                                            error))
                    return false;
            }
            cursor += 2;
        }
    }
    if (!klass)
        return reader_error(error, JBED_ERROR_NULL_POINTER, "Missing base in pointer field map");
    *end = cursor;
    return true;
}

/* Reader.AllocDesc, 0x148a1c. Emits pointer offsets, four ancestry slots,
 * instance/array sizing, class and interface chains, and virtual method slots. */
bool jbed_reader_allocate_descriptor(const JbedReaderLayout *layout,
                                     const JbedReaderLayoutServices *services, JbedClass *klass,
                                     JbedError *error)
{
    if (!klass)
        return reader_error(error, JBED_ERROR_NULL_POINTER, "Null descriptor class");
    if (klass->descriptor_address)
        return true;
    JbedClass *table_class = klass;
    if (klass->flags & JBED_CLASS_ARRAY)
        table_class = services->array_base_class;
    else if ((klass->flags & (JBED_CLASS_INSTANTIABLE | JBED_ACC_INTERFACE | JBED_ACC_ABSTRACT)) !=
             JBED_CLASS_INSTANTIABLE)
        return true;
    if (!table_class)
        return reader_error(error, JBED_ERROR_NULL_POINTER, "Null descriptor table class");
    if (!services->allocate_descriptor || !services->put_word ||
        !services->put_halfword || !services->put_class || !services->put_relocation)
        return reader_error(error, JBED_ERROR_INTERNAL, "Missing descriptor writer service");
    uint32_t size;
    if (!pointer_field_addresses(services, table_class, 22, false, &size, error))
        return false;
    size += 8 + (uint32_t)(4 * table_class->vtable_size);
    for (JbedClass *scan = table_class; scan; scan = scan->superclass)
        if (!interface_table(layout, services, false, table_class, scan, size, &size, error))
            return false;
    uint32_t address;
    if (!services->allocate_descriptor(services->context, klass, size + (size & 3), &address,
                                       error))
        return false;
    address += size & 3;
    uint32_t cursor;
    if (!pointer_field_addresses(services, table_class, address + 2, true, &cursor, error) ||
        !services->put_halfword(services->context, address, (uint16_t)(address - cursor + 2),
                                error))
        return false;
    int32_t depth = 4;
    for (; depth > klass->depth; --depth, cursor += 4)
        if (!services->put_word(services->context, cursor, 0, error))
            return false;
    JbedClass *ancestor = klass;
    while (ancestor && ancestor->depth > depth)
        ancestor = ancestor->superclass;
    if (!ancestor)
        return reader_error(error, JBED_ERROR_NULL_POINTER, "Missing descriptor ancestor");
    for (; depth > 0; --depth, cursor += 4) {
        if (!ancestor)
            return reader_error(error, JBED_ERROR_NULL_POINTER, "Short descriptor ancestry");
        if (!services->put_class(services->context, cursor, ancestor, error))
            return false;
        ancestor = ancestor->superclass;
    }
    uint32_t size_word = (uint32_t)klass->instance_size;
    if (klass->flags & JBED_CLASS_ARRAY) {
        size_word = JBED_ARRAY_TAG | JBED_ARRAY_REFERENCES | 2u;
        JbedClass *component = klass->superclass;
        if (!component)
            return reader_error(error, JBED_ERROR_NULL_POINTER, "Null array component");
        if (component->flags & JBED_CLASS_PRIMITIVE) {
            int32_t width = component->instance_size;
            if (width >= 4) {
                width >>= 2;
                size_word = JBED_ARRAY_TAG | 2u;
            } else
                size_word = JBED_ARRAY_TAG;
            if (width >= 2)
                ++size_word;
        }
    }
    if (!services->put_word(services->context, cursor, size_word, error) ||
        !services->put_class(services->context, cursor + 4, klass, error))
        return false;
    klass->descriptor_address = cursor + 8;
    if (!services->put_word(services->context, cursor + 8, 0, error))
        return false;
    uint32_t end;
    if (!put_methods(layout, services, cursor + 12, table_class, NULL, &end, error))
        return false;
    for (JbedClass *scan = table_class; scan; scan = scan->superclass)
        if (!interface_table(layout, services, true, table_class, scan, end, &end, error))
            return false;
    klass->descriptor_address = cursor + 4;
    return true;
}
