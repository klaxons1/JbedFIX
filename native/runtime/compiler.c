#include "compiler.h"
#include "class_access.h"
#include "code_cache.h"
#include "execution.h"
#include "isolate.h"
#include "metadata_init.h"
#include "rom_reflection.h"
#include "../compiler/coder.h"
#include "../compiler/thumb.h"
#include "../compiler/verifier.h"
#include "../compiler/vm/vm_words.h"

#include <stdio.h>
#include <string.h>

typedef struct CompilerStream {
    JbedVmCompiler *compiler;
    JbedCompilerSwap io;
    JbedAddress root;
    bool output;
} CompilerStream;

struct JbedVmCompiler {
    JbedVm *vm;
    JbedVmCompiler *next;
    JbedAddress isolate_statics;
    JbedCompiler driver;
    JbedClassAccess classes;
    JbedSignatureEncoder signatures;
    JbedSignatureServices signature_services;
    JbedEmitter emitter;
    JbedEmitterNames names;
    JbedPoolServices pool_services;
    JbedPool metadata;
    JbedCompilerLayout layout;
    JbedCoder coder;
    JbedCoderServices coder_services;
    JbedThumbCoder thumb;
    JbedVerifier verifier;
    JbedVerifierServices verifier_services;
    CompilerStream input, output;
    JbedCodeCache *cache;
    JbedAddress progress_root, signature_root, sanity_slot, monitor;
    bool writer_configured, external_writer, locked;
};

static JbedVm *active(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "Compiler call outside a Jbed VM");
    return vm;
}

static JbedAddress slot(JbedVm *vm, const char *name)
{
    JbedAddress address = jbed_vm_static_field_slot(vm, "com/jbed/tbcc/Compiler", name);
    if (!address) jbed_vm_fatal(vm, "Compiler static field is absent");
    return address;
}

static JbedAddress root_value(JbedVmCompiler *c, JbedAddress root)
{
    return jbed_vm_word(c->vm->heap.memory, root);
}

static void set_root(JbedVmCompiler *c, JbedAddress root, JbedAddress value)
{
    jbed_vm_put_word(c->vm->heap.memory, root, value);
}

static void *allocate(void *context, size_t bytes, JbedError *error)
{
    JbedVmCompiler *c = context;
    void *result = c->vm->services.allocate_zeroed(c->vm->services.context, bytes);
    if (!result) *error = (JbedError){.kind = JBED_ERROR_OUT_OF_MEMORY, .is_java_error = true};
    return result;
}

static void raise_error(void *context, const JbedError *error)
{
    jbed_raise(&((JbedVmCompiler *)context)->vm->services, error);
}

static void checkpoint(void *context)
{
    JbedVm *vm = ((JbedVmCompiler *)context)->vm;
    if (vm->checkpoint) vm->checkpoint(vm);
}

static const char *class_name(void *context, JbedTypeId id)
{
    return jbed_class_name(&((JbedVmCompiler *)context)->classes, id);
}

static const char *member_name(JbedVmCompiler *c, JbedReflectionTable *table, JbedNameId id)
{
    int32_t count = jbed_reflection_data(table, id, NULL, 0);
    if (count < 0) return "<unknown>";
    char *text = jbed_alloc(&c->vm->services, (size_t)count + 1);
    jbed_reflection_data(table, id, (uint8_t *)text, (size_t)count);
    return text;
}

static const char *method_name(void *context, JbedNameId id)
{
    JbedVmCompiler *c = context;
    return member_name(c, &c->vm->method_names, id);
}

static const char *field_name(void *context, JbedNameId id)
{
    JbedVmCompiler *c = context;
    return member_name(c, &c->vm->field_names, id);
}

static const char *signature_name(void *context, JbedSignatureId id)
{
    return jbed_signature_descriptor(jbed_signature_copy_if_busy(
        &((JbedVmCompiler *)context)->signatures), id);
}

static void report_error(void *context, const JbedError *error, const JbedClass *klass,
                          const char *phase)
{
    const char *name = class_name(context, klass ? klass->id : error->class_id);
    fprintf(stderr, "Jbed compiler %s: %s: %s\n", phase, name ? name : "<unknown>",
            error->message ? error->message : "compilation failed");
}

static void report_unresolved(void *context, JbedTypeId id, const char *name)
{
    (void)context;
    fprintf(stderr, "Jbed compiler: unresolved class %u (%s)\n", id, name ? name : "<unknown>");
}

static void report_oom(void *context, JbedTypeId id)
{
    const char *name = class_name(context, id);
    fprintf(stderr, "Jbed compiler: out of memory reading %s\n", name ? name : "<unknown>");
}

static void report_statistics(void *context, bool final)
{
    (void)context;
    (void)final;
}

static void drop_signatures(void *context)
{
    JbedVmCompiler *c = context;
    jbed_signature_init(&c->signatures, &c->signature_services);
    set_root(c, c->signature_root, 0);
}

static bool register_classes(void *context, JbedError *error)
{
    (void)error;
    JbedVmCompiler *c = context;
    jbed_vm_class_access_publish(c->vm, &c->classes);
    return true;
}

static void create_signature_identity(void *context)
{
    JbedVmCompiler *c = context;
    set_root(c, c->signature_root, jbed_vm_signature_encoder_new(c->vm, &c->classes));
}

static bool new_signatures(void *context, JbedError *error)
{
    JbedVmCompiler *c = context;
    jbed_signature_init(&c->signatures, &c->signature_services);
    return c->vm->services.protected_call(c->vm->services.context,
        create_signature_identity, c, error);
}

static void clear_dynamic_reflection(void *context)
{
    JbedVmCompiler *c = context;
    static const unsigned order[] = {3, 2, 4}; /* Field, Method, SignatureEncoder. */
    for (size_t i = 0; i < sizeof(order) / sizeof(*order); ++i)
        ReflectionTable_clearDynamicHash(root_value(c, c->vm->reflection_roots[order[i]]));
}

static void reset_class_tables(void *context)
{
    JbedVmCompiler *c = context;
    ClassAccess_resetTables();
    c->classes.dynamic_bundle = c->vm->classes.dynamic_bundle;
}

static void store_class_error(void *context, JbedClass *klass)
{
    enum { CLASS_SIZE = 28, CLASS_ANCHOR = 76, THROWABLE_MESSAGE = 16 };
    JbedVmCompiler *c = context;
    JbedVm *vm = c->vm;
    JbedAddress throwable = jbed_vm_error_throwable(vm, &klass->error);
    if (!throwable) jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, NULL);
    JbedVmHeapRoot root = {throwable, throwable, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    if (!klass->error.runtime_throwable && klass->error.message &&
        klass->error.kind != JBED_ERROR_OUT_OF_MEMORY) {
        JbString *message = Jbni_intern_newStringExc(klass->error.message);
        jbed_vm_put_word(vm->heap.memory, root.value + THROWABLE_MESSAGE, jb_ref(message));
    }
    JbedAddress object = klass->guest_address ? klass->guest_address
                                             : jbed_class_target_address(&c->classes, klass);
    jbed_vm_put_word(vm->heap.memory, object + CLASS_SIZE, (uint32_t)klass->instance_size);
    jbed_vm_put_word(vm->heap.memory, object + CLASS_ANCHOR, root.value);
    klass->error.runtime_throwable = jbed_vm_at(vm->heap.memory, root.value);
    vm->heap.temporary_roots = root.previous;
}

static void enter(void *context)
{
    JbedVmCompiler *c = context;
    JbedVmMonitorResult result = jbed_vm_monitor_enter(&c->vm->monitors, c->monitor);
    if (result != JBED_MONITOR_DONE)
        jbed_vm_raise(c->vm, result == JBED_MONITOR_ALLOCATION_FAILED
            ? JBED_ERROR_OUT_OF_MEMORY : JBED_ERROR_INTERNAL, "Cannot enter compiler monitor");
    c->locked = true;
}

static void leave(void *context)
{
    JbedVmCompiler *c = context;
    if (jbed_vm_monitor_exit(&c->vm->monitors, c->monitor) != JBED_MONITOR_DONE)
        jbed_vm_fatal(c->vm, "Cannot leave compiler monitor");
    c->locked = false;
}

static JbedMethod *find_method(JbedVmCompiler *c, JbedClass *klass, const char *name,
                               const char *descriptor)
{
    JbedNameId id = jbed_reflection_id(&c->vm->method_names,
        (const uint8_t *)name, strlen(name), false);
    for (; klass; klass = klass->superclass)
        for (JbedMethod *m = klass->methods; m; m = m->next) {
            if (m->name_id != id) continue;
            const char *actual = signature_name(c, m->signature_id), *expected = descriptor;
            while (*actual && (*actual == *expected || (*actual == '.' && *expected == '/'))) {
                ++actual;
                ++expected;
            }
            if (!*actual && !*expected) return m;
        }
    return NULL;
}

static bool managed_call(JbedVmCompiler *c, JbRef receiver, const char *owner,
                          const char *name, const char *descriptor, uint32_t *arguments,
                          size_t count, uint64_t *result, JbedError *error)
{
    JbedVm *vm = c->vm;
    JbedAddress tag = receiver ? jbed_vm_word(vm->heap.memory, receiver) : 0;
    JbedAddress address = receiver ? jbed_vm_word(vm->heap.memory, tag)
                                   : jbed_vm_find_class(vm, owner);
    JbedClass *klass = address ? jbed_class_from_target(&vm->classes, address) : NULL;
    if (!klass) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, "Null compiler callback receiver");
    JbedMethod *method = find_method(c, klass, name, descriptor);
    if (!method) jbed_vm_raise(vm, JBED_ERROR_NO_SUCH_METHOD, name);
    JbedAddress entry = receiver && method->dispatch_slot >= 0
        ? jbed_vm_word(vm->heap.memory, tag + 8 + 4u * (unsigned)method->dispatch_slot)
        : method->code_address;
    if (receiver) arguments[0] = receiver;
    if (jbed_vm_invoke(vm, entry, arguments, count, result)) return true;
    JbedAddress thrown_class = jbed_vm_word(vm->heap.memory,
        jbed_vm_word(vm->heap.memory, vm->pending_exception));
    JbedClass *thrown = jbed_class_from_target(&vm->classes, thrown_class);
    JbedClass *error_class = jbed_class_from_target(&vm->classes,
        jbed_vm_find_class(vm, "java/lang/Error"));
    JbedClass *oom_class = jbed_class_from_target(&vm->classes,
        jbed_vm_find_class(vm, "java/lang/OutOfMemoryError"));
    *error = (JbedError){.kind = JBED_ERROR_THROWABLE,
        .is_java_error = error_class && thrown && jbed_vm_assignable(error_class, thrown),
        .runtime_throwable = jbed_vm_at(vm->heap.memory, vm->pending_exception)};
    if (oom_class && thrown && jbed_vm_assignable(oom_class, thrown))
        error->kind = JBED_ERROR_OUT_OF_MEMORY;
    vm->pending_exception = 0;
    return false;
}

static bool progress(void *context, int32_t percent)
{
    JbedVmCompiler *c = context;
    uint32_t arguments[] = {0, (uint32_t)percent};
    uint64_t result;
    JbedError error;
    if (!managed_call(c, root_value(c, c->progress_root), NULL, "progress", "(I)Z",
                      arguments, 2, &result, &error)) raise_error(c, &error);
    return (uint32_t)result != 0;
}

static bool stream_length(void *context, int32_t *length, JbedError *error)
{
    CompilerStream *stream = context;
    uint32_t arguments[1];
    uint64_t result;
    if (!managed_call(stream->compiler, root_value(stream->compiler, stream->root),
                      NULL, "length", "()I", arguments, 1, &result, error)) return false;
    *length = (int32_t)result;
    return true;
}

static bool stream_seek(void *context, int32_t position, JbedError *error)
{
    CompilerStream *stream = context;
    uint32_t arguments[] = {0, (uint32_t)position};
    uint64_t ignored;
    return managed_call(stream->compiler, root_value(stream->compiler, stream->root),
                         NULL, "seek", "(I)V", arguments, 2, &ignored, error);
}

static bool stream_transfer(CompilerStream *stream, void *data, size_t bytes, JbedError *error)
{
    JbedVmCompiler *c = stream->compiler;
    JbedVm *vm = c->vm;
    if (bytes > INT32_MAX) {
        *error = (JbedError){.kind = JBED_ERROR_ARRAY_INDEX};
        return false;
    }
    JbedAddress array = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_BYTE],
                                               (int32_t)bytes, false);
    JbedVmHeapRoot root = {array, array, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    if (stream->output) memcpy(jbed_vm_at(vm->heap.memory, root.value + 16), data, bytes);
    uint32_t arguments[] = {0, root.value, 0, (uint32_t)bytes};
    uint64_t ignored;
    bool success = managed_call(c, root_value(c, stream->root), NULL,
        stream->output ? "write" : "readFully", "([BII)V", arguments, 4, &ignored, error);
    if (success && !stream->output)
        memcpy(data, jbed_vm_at(vm->heap.memory, root.value + 16), bytes);
    vm->heap.temporary_roots = root.previous;
    return success;
}

static bool stream_read(void *context, void *data, size_t bytes, JbedError *error)
{
    if (bytes == 2 || bytes == 4) {
        CompilerStream *stream = context;
        uint32_t arguments[1];
        uint64_t result;
        if (!managed_call(stream->compiler, root_value(stream->compiler, stream->root), NULL,
                          bytes == 2 ? "read16LE" : "read32LE", "()I",
                          arguments, 1, &result, error)) return false;
        for (size_t i = 0; i < bytes; ++i) ((uint8_t *)data)[i] = (uint8_t)(result >> (8 * i));
        return true;
    }
    return stream_transfer(context, data, bytes, error);
}

static bool stream_write(void *context, const void *data, size_t bytes, JbedError *error)
{
    if (bytes == 2 || bytes == 4) {
        CompilerStream *stream = context;
        uint32_t value = 0;
        for (size_t i = 0; i < bytes; ++i) value |= (uint32_t)((const uint8_t *)data)[i] << (8 * i);
        uint32_t arguments[] = {0, value};
        uint64_t ignored;
        return managed_call(stream->compiler, root_value(stream->compiler, stream->root), NULL,
                            bytes == 2 ? "write16LE" : "write32LE", "(I)V",
                            arguments, 2, &ignored, error);
    }
    return stream_transfer(context, (void *)data, bytes, error);
}

static JbedVmCompiler *find_compiler(JbedVm *vm)
{
    for (JbedVmCompiler *c = vm->compiler; c; c = c->next)
        if (c->isolate_statics == vm->isolate_statics) return c;
    return NULL;
}

static JbedVmCompiler *compiler(JbedVm *vm)
{
    JbedVmCompiler *existing = find_compiler(vm);
    if (existing) return existing;
    JbedVmCompiler *c = jbed_alloc(&vm->services, sizeof(*c));
    c->vm = vm;
    c->isolate_statics = vm->isolate_statics;
    c->progress_root = slot(vm, "prog");
    c->signature_root = slot(vm, "sigEnc");
    c->sanity_slot = slot(vm, "ignoreClassSanityCheck");
    c->monitor = jbed_vm_find_class(vm, "com/jbed/tbcc/Compiler");
    jbed_class_access_init(&c->classes, &vm->services, &vm->resident,
                            &vm->packages, &vm->base_names, false);
    c->classes.bundles[1] = vm->classes.bundles[1];
    c->classes.dynamic_bundle = vm->classes.dynamic_bundle;
    c->classes.heap = &vm->heap;
    c->classes.heap_image = vm->classes.heap_image;
    c->classes.heap_image.compiler_root = slot(vm, "classes");
    c->classes.heap_image.registered_root = jbed_vm_static_field_slot(vm, "java/lang/Class", "classes");
    c->classes.isolate_statics = vm->isolate_statics;
    c->signature_services = (JbedSignatureServices){.runtime = &vm->services,
        .reflection_table = &vm->signatures, .types = jbed_signature_rom_types(),
        .class_access = &c->classes};
    jbed_signature_init(&c->signatures, &c->signature_services);
    c->names = (JbedEmitterNames){c, class_name, method_name, field_name, signature_name};
    c->emitter = (JbedEmitter){.runtime = &vm->services, .names = &c->names};
    JbedThumbRuntimeAddresses thumb = jbed_arm32_thumb_helpers();
    JbedCoderRuntimeAddresses calls = jbed_arm32_coder_helpers();
    c->pool_services = (JbedPoolServices){.runtime = &vm->services, .emitter = &c->emitter,
        .class_access = &c->classes, .method_names = &vm->method_names, .field_names = &vm->field_names,
        .signature_encoder = &c->signatures, .vm_strings = &vm->strings,
        .throw_no_class_address = thumb.throw_no_class, .throw_abstract_address = thumb.throw_abstract};
    c->metadata.services = &c->pool_services;
    c->layout = (JbedCompilerLayout){.pool = &c->metadata,
        .array_base_class = jbed_vm_class_by_id(&vm->resident, JBED_ROM_CLASS_OBJECT),
        .throw_abstract_address = thumb.throw_abstract};
    JbedClass *class_class = jbed_vm_class_by_id(&vm->resident, JBED_ROM_CLASS_CLASS);
    c->coder_services.class_for_name_method = find_method(c, class_class, "forName",
                                                         "(Ljava/lang/String;)Ljava/lang/Class;");
    c->coder_services.class_new_instance_method = find_method(c, class_class, "newInstance",
                                                             "()Ljava/lang/Object;");
    jbed_coder_init(&c->coder, &vm->services, &c->coder_services, &c->emitter, NULL, &calls);
    jbed_thumb_init(&c->thumb, &c->coder, &vm->services, &thumb, false);
    c->verifier_services = (JbedVerifierServices){.emitter = &c->emitter,
        .signature_encoder = &c->signatures};
    jbed_verifier_init(&c->verifier, &vm->services, &c->verifier_services);
    JbedCompilerServices services = {.context = c, .emitter = &c->emitter,
        .allocate = allocate, .raise_error = raise_error, .enter = enter, .leave = leave,
        .checkpoint = checkpoint, .report_error = report_error, .report_unresolved = report_unresolved,
        .report_oom_define = report_oom, .report_statistics = report_statistics,
        .drop_signature_encoder = drop_signatures,
        .new_signature_encoder = new_signatures,
        .register_with_runtime = register_classes,
        .clear_dynamic_reflection = clear_dynamic_reflection,
        .reset_class_tables = reset_class_tables,
        .store_class_error = store_class_error,
        .class_layout = &c->layout, .class_access = &c->classes,
        .verifier = &c->verifier, .coder = &c->coder};
    jbed_compiler_init(&c->driver, &services, *jbed_vm_at(vm->heap.memory, c->sanity_slot) != 0);
    c->input = (CompilerStream){.compiler = c, .root = slot(vm, "swapIn")};
    c->output = (CompilerStream){.compiler = c, .root = slot(vm, "swapOut"), .output = true};
    c->input.io = (JbedCompilerSwap){&c->input, stream_length, stream_seek, stream_read, stream_write};
    c->output.io = (JbedCompilerSwap){&c->output, stream_length, stream_seek, stream_read, stream_write};
    c->next = vm->compiler;
    vm->compiler = c;
    return c;
}

JbedCompiler *jbed_vm_compiler_driver(JbedVm *vm) { return &compiler(vm)->driver; }
JbedClassAccess *jbed_vm_compiler_classes(JbedVm *vm)
{
    JbedVmCompiler *c = find_compiler(vm);
    return c ? &c->classes : NULL;
}
JbedSignatureEncoder *jbed_vm_compiler_signatures(JbedVm *vm) { return &compiler(vm)->signatures; }

void jbed_vm_compiler_configure(JbedVm *vm, JbedWriter *writer, const JbedReaderLayout *layout)
{
    JbedVmCompiler *c = compiler(vm);
    c->layout.layout = *layout;
    c->layout.primitive_static_start = layout->primitive_static_top;
    c->layout.writer = writer;
    c->driver.target_writer = writer;
    c->writer_configured = writer != NULL;
    c->external_writer = writer != NULL;
}

static void extend_statics(void *context, uint32_t bytes, const uint32_t *ranges,
                            uint32_t count)
{
    jbed_vm_isolate_extend_statics(context, bytes, ranges, count);
}

static void configure_source_writer(JbedVmCompiler *c)
{
    enum { ARRAY_LENGTH = 12, ARRAY_DATA = 16, INITIAL_STATIC_ARENA = 256 };
    JbedVm *vm = c->vm;
    if (!vm->heap.current_isolate)
        jbed_vm_fatal(vm, "Compilation requires an active isolate");
    JbedRomIsolate *isolate = (JbedRomIsolate *)jbed_vm_at(vm->heap.memory,
                                                       vm->heap.current_isolate);
    if (!isolate->statics || isolate->statics + ARRAY_DATA != vm->isolate_statics)
        jbed_vm_fatal(vm, "Compiler isolate statics are not active");
    uint32_t used = jbed_vm_word(vm->heap.memory, isolate->statics + ARRAY_LENGTH);
    if (used > INT32_MAX - INITIAL_STATIC_ARENA - 3)
        jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, "Isolate static area is too large");
    uint32_t capacity = (used + INITIAL_STATIC_ARENA + 3) & ~3u;
    if (!c->cache) {
        c->cache = jbed_code_cache_create(vm, extend_statics, vm);
        if (!c->cache) jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, "Cannot allocate compiler writer");
    }
    JbedReaderLayout layout;
    jbed_reader_layout_init(&layout, capacity, (int32_t)capacity, 0, 1);
    layout.primitive_static_top = (int32_t)used;
    jbed_vm_compiler_configure(vm, jbed_code_cache_writer(c->cache), &layout);
    c->external_writer = false;
}

void jbed_vm_compiler_dispose(JbedVm *vm)
{
    for (JbedVmCompiler *c = vm->compiler; c; c = c->next) {
        jbed_code_cache_destroy(c->cache);
        c->cache = NULL;
    }
    vm->compiler = NULL;
}

void jbed_vm_compiler_rebase_statics(JbedVm *vm, JbedAddress old_base, JbedAddress new_base)
{
    uint32_t delta = new_base - old_base;
    for (JbedVmCompiler *c = vm->compiler; c; c = c->next) {
        if (c->isolate_statics != old_base) continue;
        c->isolate_statics = new_base;
        c->progress_root += delta;
        c->signature_root += delta;
        c->sanity_slot += delta;
        c->input.root += delta;
        c->output.root += delta;
        c->classes.isolate_statics = new_base;
        c->classes.heap_image.compiler_root += delta;
        c->classes.heap_image.registered_root += delta;
        if (c->classes.guest_root) c->classes.guest_root += delta;
    }
}

void Compiler_initialize(void)
{
    JbedVmCompiler *c = compiler(active());
    JbString *key = Jbni_intern_newStringExc("Compiler.ignoreClassSanityCheck");
    uint32_t arguments[] = {jb_ref(key)};
    uint64_t value;
    JbedError error;
    if (!managed_call(c, 0, "java/lang/System", "getProperty", "(Ljava/lang/String;)Ljava/lang/String;",
                      arguments, 1, &value, &error)) raise_error(c, &error);
    c->driver.ignore_class_sanity = value != 0;
    *jbed_vm_at(c->vm->heap.memory, c->sanity_slot) = value != 0;
    c->driver.swapping = false;
}

void Compiler_startCompile(int32_t options, bool long_jumps, JbRef listener,
                            int32_t classes, int32_t read_weight)
{
    JbedVmCompiler *c = compiler(active());
    c->classes.bundles[1] = c->vm->classes.bundles[1];
    c->classes.dynamic_bundle = c->vm->classes.dynamic_bundle;
    c->classes.heap_image = c->vm->classes.heap_image;
    if (!c->external_writer) configure_source_writer(c);
    set_root(c, c->progress_root, listener);
    JbedError error;
    if (!jbed_compiler_start(&c->driver, (uint32_t)options, long_jumps,
                              listener ? progress : NULL, c, classes, read_weight, &error))
        raise_error(c, &error);
}

typedef struct CompileCall {
    JbedVmCompiler *compiler;
    JbedTypeId id;
    const uint8_t *bytes;
    size_t length;
    bool define, success;
    JbedError error;
} CompileCall;

static void compile_call(void *context)
{
    CompileCall *call = context;
    call->success = call->define
        ? jbed_compiler_define(&call->compiler->driver, call->id, call->bytes, call->length, &call->error)
        : jbed_compiler_compile(&call->compiler->driver, &call->error);
    if (call->success && !call->define)
        for (JbedClass *klass = NULL;
             (klass = jbed_class_next(&call->compiler->classes, klass)) != NULL;)
            jbed_class_target_address(&call->compiler->classes, klass);
}

static void guarded_compile(CompileCall *call)
{
    JbedVmCompiler *c = call->compiler;
    JbedVmHeapRoot *roots = c->vm->heap.temporary_roots;
    bool returned = c->vm->services.protected_call(c->vm->services.context,
        compile_call, call, &call->error);
    c->vm->heap.temporary_roots = roots;
    if (c->locked) leave(c);
    if (!returned || !call->success) raise_error(c, &call->error);
    if (!call->define) {
        set_root(c, c->input.root, 0);
        set_root(c, c->output.root, 0);
    }
}

void Compiler_define(int32_t id, JbRef bytes, int32_t offset, int32_t length)
{
    JbedVmCompiler *c = compiler(active());
    if (!bytes) jbed_vm_raise(c->vm, JBED_ERROR_NULL_POINTER, "Null class bytes");
    uint32_t size = jbed_vm_word(c->vm->heap.memory, bytes + 12);
    if (offset < 0 || length < 0 || (uint32_t)offset > size || (uint32_t)length > size - (uint32_t)offset)
        jbed_vm_raise(c->vm, JBED_ERROR_ARRAY_INDEX, "Class byte range is outside the array");
    uint8_t *copy = jbed_alloc(&c->vm->services, (size_t)length);
    memcpy(copy, jbed_vm_at(c->vm->heap.memory, bytes + 16 + (uint32_t)offset), (size_t)length);
    c->driver.ignore_class_sanity = *jbed_vm_at(c->vm->heap.memory, c->sanity_slot) != 0;
    CompileCall call = {.compiler = c, .id = (uint32_t)id, .bytes = copy,
        .length = (size_t)length, .define = true};
    guarded_compile(&call);
}

void Compiler_compile(void)
{
    JbedVmCompiler *c = compiler(active());
    if (!c->driver.has_coder)
        jbed_vm_raise(c->vm, JBED_ERROR_NULL_POINTER, "Compiler has not been started");
    if (!c->writer_configured) jbed_vm_fatal(c->vm, "Compiler writer is not configured");
    CompileCall call = {.compiler = c};
    guarded_compile(&call);
    if (!c->external_writer) {
        char error[192];
        if (!jbed_code_cache_publish(c->cache, error, sizeof(error))) {
            char *message = jbed_alloc(&c->vm->services, strlen(error) + 1);
            strcpy(message, error);
            jbed_vm_raise(c->vm, JBED_ERROR_ERROR, message);
        }
    }
}

void Compiler_compileDone(bool register_classes)
{
    JbedVmCompiler *c = compiler(active());
    JbedError error;
    jbed_compiler_clear_progress(&c->driver);
    set_root(c, c->progress_root, 0);
    if (!jbed_compiler_done(&c->driver, register_classes, &error)) raise_error(c, &error);
}

void Compiler_reset(void) { Compiler_compileDone(false); }
bool Compiler_isSwapping(void) { return jbed_compiler_is_swapping(&compiler(active())->driver); }
bool Compiler_isCanceled(void) { return jbed_compiler_is_canceled(&compiler(active())->driver); }
bool Compiler_fullDebugInfo(void) { return jbed_compiler_full_debug_info(&compiler(active())->driver); }

void Compiler_enableSwapping(JbRef output, JbRef input)
{
    JbedVmCompiler *c = compiler(active());
    set_root(c, c->output.root, output);
    set_root(c, c->input.root, input);
    jbed_compiler_enable_swapping(&c->driver, output ? &c->output.io : NULL, input ? &c->input.io : NULL);
}

void Compiler_disableSwapping(void)
{
    JbedVmCompiler *c = compiler(active());
    jbed_compiler_disable_swapping(&c->driver);
    set_root(c, c->output.root, 0);
    set_root(c, c->input.root, 0);
}

void Compiler_flushFixups(int32_t boundary)
{
    JbedVmCompiler *c = compiler(active());
    JbedError error;
    if (!jbed_compiler_flush_fixups(&c->driver, (uint32_t)boundary, &error)) raise_error(c, &error);
}
