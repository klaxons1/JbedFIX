#include "instance.h"
#include "execution.h"
#include "native_call.h"
#include "roots.h"
#include "monitor_init.h"
#include "metadata_init.h"
#include "collector_init.h"
#include "trace.h"
#include "isolate.h"
#include "compiler.h"
#include "scheduler.h"
#include "../compiler/vm/vm_scheduler.h"
#include "../compiler/vm/vm_words.h"

#include <setjmp.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

typedef struct Allocation {
    struct Allocation *next;
    max_align_t data[];
} Allocation;

typedef struct ExceptionBoundary {
    jmp_buf jump;
    JbedInstance *owner;
    struct ExceptionBoundary *previous;
} ExceptionBoundary;

static _Thread_local ExceptionBoundary *exception_boundaries;

typedef struct HeapExtent {
    JbedAddress address;
    uint32_t size;
    bool available;
    struct HeapExtent *next;
} HeapExtent;

enum {
    SUPPORT_BYTES = 4096,
    SUPPORT_FREE_LIST = 64,
    SUPPORT_CHARACTERS = 96,
    STACK_RESERVE = 512,
    RUNTIME_STACK_RESERVE = 6000,
    SCHEDULER_PERIOD_MICROS = 10000,
    MEMORY_ALIGNMENT = 8,
    INITIAL_HEAP_BYTES = 2 * 1024 * 1024,
    HEAP_INCREMENT = 256 * 1024
};

struct JbedInstance {
    JbedVm vm;
    JbedArm32Context arm;
    JbedLoadedBoot boot;
    JbedVmSignalHub signals;
    JbedAddress support, main_method;
    Allocation *allocations;
    HeapExtent *heap_extents, *spare_extents;
    JbedError error;
    bool boot_started, initialized, exited;
    int32_t exit_code;
    void *native_roots[1024];
    uint32_t native_arguments[257];
};

static void *allocate(void *context, size_t size)
{
    JbedInstance *instance = context;
    if (size > SIZE_MAX - sizeof(Allocation))
        return NULL;
    Allocation *allocation = calloc(1, sizeof(*allocation) + size);
    if (!allocation)
        return NULL;
    allocation->next = instance->allocations;
    instance->allocations = allocation;
    return allocation->data;
}

static bool reserve_heap(void *context, uint32_t requested, JbedAddress *address, uint32_t *size)
{
    JbedVm *vm = context;
    JbedInstance *instance = vm->services.context;
    uint64_t preferred = requested ? ((uint64_t)requested + HEAP_INCREMENT - 1) &
                                     ~(uint64_t)(HEAP_INCREMENT - 1) : INITIAL_HEAP_BYTES;
    for (HeapExtent *extent = instance->heap_extents; extent; extent = extent->next) {
        if (!extent->available || extent->size < requested)
            continue;
        uint32_t bytes = preferred < extent->size ? (uint32_t)preferred : extent->size;
        if (bytes < extent->size) {
            HeapExtent *tail = instance->spare_extents;
            if (tail)
                instance->spare_extents = tail->next;
            else
                tail = allocate(instance, sizeof(*tail));
            if (!tail) return false;
            *tail = (HeapExtent){extent->address + bytes, extent->size - bytes, true, extent->next};
            extent->next = tail;
            extent->size = bytes;
        }
        extent->available = false;
        *address = extent->address;
        *size = bytes;
        return true;
    }
    return false;
}

static void release_heap(void *context, JbedAddress address, uint32_t size)
{
    (void)size;
    JbedVm *vm = context;
    JbedInstance *instance = vm->services.context;
    HeapExtent *previous = NULL;
    for (HeapExtent *extent = instance->heap_extents; extent; previous = extent, extent = extent->next) {
        if (extent->address != address)
            continue;
        if (extent->available)
            jbed_vm_fatal(vm, "Heap region was already released");
        extent->available = true;
        long page = sysconf(_SC_PAGESIZE);
        if (page > 0) {
            uintptr_t start = ((uintptr_t)address + (uintptr_t)page - 1) / (uintptr_t)page * (uintptr_t)page;
            uintptr_t end = ((uintptr_t)address + extent->size) / (uintptr_t)page * (uintptr_t)page;
            if (end > start)
                (void)madvise((void *)start, end - start, MADV_DONTNEED);
        }
        if (extent->next && extent->next->available) {
            HeapExtent *tail = extent->next;
            extent->size += tail->size;
            extent->next = tail->next;
            tail->next = instance->spare_extents;
            instance->spare_extents = tail;
        }
        if (previous && previous->available) {
            previous->size += extent->size;
            previous->next = extent->next;
            extent->next = instance->spare_extents;
            instance->spare_extents = extent;
        }
        return;
    }
    jbed_vm_fatal(vm, "Heap region belongs to another VM");
}

static _Noreturn void raise_error(void *context, const JbedError *error)
{
    JbedInstance *instance = context;
    instance->error = *error;
    for (ExceptionBoundary *boundary = exception_boundaries; boundary; boundary = boundary->previous)
        if (boundary->owner == instance)
            longjmp(boundary->jump, 1);
    fprintf(stderr, "Jbed: %s\n", error->message ? error->message : "Uncaught native VM error");
    abort();
}

static _Noreturn void halt(void *context, int32_t code, const char *message)
{
    (void)context;
    (void)code;
    fprintf(stderr, "Jbed fatal error: %s\n", message ? message : "Unrecoverable VM failure");
    exit(1);
}

static bool protected_call(void *context, void (*body)(void *), void *argument, JbedError *error)
{
    JbedInstance *instance = context;
    ExceptionBoundary boundary;
    boundary.owner = instance;
    boundary.previous = exception_boundaries;
    exception_boundaries = &boundary;
    if (setjmp(boundary.jump)) {
        exception_boundaries = boundary.previous;
        *error = instance->error;
        return false;
    }
    body(argument);
    exception_boundaries = boundary.previous;
    return true;
}

static uint32_t read_word(void *context, JbedAddress address)
{
    JbedVm *vm = context;
    return jbed_vm_word(vm->heap.memory, address);
}

static void load_metadata(void *context)
{
    JbedInstance *instance = context;
    JbedVm *vm = &instance->vm;
    const JbedBootImage *image = instance->boot.image;
    JbedImageView view = {instance->boot.memory.data, image->size, instance->boot.memory.address};
    vm->bundle_initializers = image->initializers ? view.base + image->initializers : 0;
    vm->bundle_initializer_count = image->initializer_count;
    if (!image->class_index)
        jbed_raise_internal(&vm->services, "Boot image has no class metadata");
    const uint32_t offsets[] = {image->packages, image->base_names, image->method_names,
                                image->field_names, image->signatures};
    JbedReflectionTable *tables[] = {&vm->packages, &vm->base_names, &vm->method_names,
                                     &vm->field_names, &vm->signatures};
    for (size_t i = 0; i < sizeof(offsets) / sizeof(*offsets); ++i)
        if (!offsets[i] || !jbed_reflection_init(tables[i], &vm->services, view, view.base + offsets[i]))
            jbed_raise_internal(&vm->services, "Boot image has an invalid reflection table");
    jbed_vm_class_table_init(&vm->resident, &vm->services, view, view.base + image->class_index);
    jbed_class_access_init(&vm->classes, &vm->services, &vm->resident, &vm->packages, &vm->base_names, true);
    vm->classes.heap = &vm->heap;
    vm->classes.isolate_statics = vm->isolate_statics;
    vm->services.registered_classes = &vm->classes;
    vm->class_class = jbed_vm_find_class(vm, "java/lang/Class");
    vm->string_class = jbed_vm_find_class(vm, "java/lang/String");
    vm->object_array_class = jbed_vm_find_class(vm, "[Ljava/lang/Object;");
    const char *descriptors[] = {"[Z", "[C", "[F", "[D", "[B", "[S", "[I", "[J"};
    for (unsigned i = 0; i < sizeof(descriptors) / sizeof(*descriptors); ++i)
        vm->primitive_array_classes[JBED_TYPE_BOOLEAN + i] = jbed_vm_find_class(vm, descriptors[i]);
    vm->exceptions.memory = (JbedVmMemoryReader){vm, read_word};
    vm->exceptions.native_frames = &vm->native_frames;
    vm->exceptions.stack_limit = (uint32_t)instance->arm.stack_limit;
    vm->exceptions.reserved_stack_limit = (uint32_t)instance->arm.stack_limit;
    jbed_vm_stack_maps_init(&vm->stack_maps, &vm->services, vm->exceptions.memory);
    for (JbedAddress header = image->stack_maps ? view.base + image->stack_maps : 0; header;) {
        jbed_vm_stack_map_add(&vm->stack_maps, header, 0);
        header = read_word(vm, header + JBED_STACK_MAP_HEADER_NEXT);
    }
    jbed_vm_bind_static_roots(vm, image);
}

void jbed_instance_destroy(JbedInstance *instance)
{
    if (!instance)
        return;
    jbed_vm_scheduler_dispose(&instance->vm);
    if (jbed_vm_current() == &instance->vm)
        jbed_vm_bind(NULL);
    jbed_vm_signals_uninstall(&instance->signals);
    jbed_vm_compiler_dispose(&instance->vm);
    jbed_vm_native_methods_dispose(&instance->vm);
    jbed_boot_unload(&instance->boot);
    while (instance->allocations) {
        Allocation *allocation = instance->allocations;
        instance->allocations = allocation->next;
        free(allocation);
    }
    free(instance);
}

JbedInstance *jbed_instance_create(const JbedBootImage *image, uint32_t heap_bytes,
                                   uint32_t stack_bytes, char *error, size_t error_size)
{
    uint64_t statics_bytes = image ? (uint64_t)image->statics_size + image->globals_size : 0;
    uint64_t support_offset = (statics_bytes + MEMORY_ALIGNMENT - 1) &
                              ~(uint64_t)(MEMORY_ALIGNMENT - 1);
    uint64_t heap_span = ((uint64_t)heap_bytes + MEMORY_ALIGNMENT - 1) &
                         ~(uint64_t)(MEMORY_ALIGNMENT - 1);
    uint64_t writable = support_offset + SUPPORT_BYTES + heap_span + stack_bytes;
    if (!image || writable > UINT32_MAX || stack_bytes <= STACK_RESERVE) {
        if (error && error_size)
            snprintf(error, error_size, "Invalid VM memory sizes");
        return NULL;
    }
    JbedInstance *instance = calloc(1, sizeof(*instance));
    if (!instance) {
        if (error && error_size)
            snprintf(error, error_size, "Cannot allocate VM instance");
        return NULL;
    }
    if (!jbed_boot_load(&instance->boot, image, (uint32_t)writable, &instance->vm, error, error_size)) {
        free(instance);
        return NULL;
    }
    JbedVm *vm = &instance->vm;
    instance->main_method = image->main_method ? instance->boot.memory.address + image->main_method : 0;
    uint32_t statics = instance->boot.memory.address + instance->boot.executable_size;
    uint32_t support = statics + (uint32_t)support_offset;
    uint32_t heap = support + SUPPORT_BYTES;
    uint32_t stack = heap + (uint32_t)heap_span;
    vm->services = (JbedRuntime){.context = instance, .allocate_zeroed = allocate,
        .raise_error = raise_error, .halt = halt, .protected_call = protected_call};
    vm->heap.memory = instance->boot.memory;
    vm->isolate_statics = statics;
    vm->stack_space = stack_bytes;
    vm->arm = &instance->arm;
    vm->native_roots_base = vm->native_roots_top = instance->native_roots;
    vm->native_roots_limit = instance->native_roots + sizeof(instance->native_roots) / sizeof(void *);
    vm->parameters = instance->native_arguments + 1;
    instance->support = support;
    instance->signals.memory = instance->boot.memory;
    for (unsigned i = 0; i < JBED_MAX_ISOLATES; ++i)
        atomic_init(&instance->signals.pending[i], 0);
    vm->signals.hub = &instance->signals;
    vm->native_frames = (JbedVmNativeFrames){.base = support, .frame = support, .address = support};
    instance->arm = (JbedArm32Context){.statics = (void *)(uintptr_t)statics,
        .stack_limit = stack + STACK_RESERVE, .stack_top = stack + stack_bytes,
        .checkpoint_budget = 1000, .service = jbed_vm_dispatch, .user = vm};
    JbedError caught;
    if (!protected_call(instance, load_metadata, instance, &caught)) {
        if (error && error_size)
            snprintf(error, error_size, "%s", caught.message ? caught.message : "Invalid boot metadata");
        jbed_instance_destroy(instance);
        return NULL;
    }
    if (!jbed_vm_native_methods_init(vm, image, error, error_size)) {
        jbed_instance_destroy(instance);
        return NULL;
    }
    if (heap_bytes) {
        JbedAddress chunk = jbed_vm_find_class(vm, "com/jbed/runtime/HeapChunk");
        JbedAddress ints = vm->primitive_array_classes[JBED_TYPE_INT];
        if (!chunk || !ints) {
            if (error && error_size)
                snprintf(error, error_size, "Heap boot requires HeapChunk and int[] classes");
            jbed_instance_destroy(instance);
            return NULL;
        }
        JbedVmHeapImage layout = {read_word(vm, chunk + 36), read_word(vm, ints + 36),
                                  support + SUPPORT_FREE_LIST};
        jbed_vm_heap_init_image(&vm->heap, instance->boot.memory, layout);
        vm->heap.services.context = vm;
        vm->heap.services.fill_trace = jbed_vm_fill_throwable_trace;
        vm->heap.services.reserve_chunk = reserve_heap;
        vm->heap.services.release_chunk = release_heap;
        instance->heap_extents = allocate(instance, sizeof(*instance->heap_extents));
        if (instance->heap_extents)
            *instance->heap_extents = (HeapExtent){heap, heap_bytes, true, NULL};
        JbedAddress raw;
        uint32_t bytes;
        if (!instance->heap_extents || !reserve_heap(vm, 0, &raw, &bytes) ||
            !jbed_vm_heap_add_chunk(&vm->heap, raw, bytes, true)) {
            if (error && error_size)
                snprintf(error, error_size, "Cannot initialize the Java heap");
            jbed_instance_destroy(instance);
            return NULL;
        }
    }
    return instance;
}

typedef struct RuntimeBootstrap {
    JbedInstance *instance;
    char *error;
    size_t error_size;
} RuntimeBootstrap;

static void initialize_runtime(void *context)
{
    RuntimeBootstrap *request = context;
    JbedInstance *instance = request->instance;
    JbedVm *vm = &instance->vm;
    const JbedBootImage *image = instance->boot.image;
    char *error = request->error;
    size_t size = request->error_size;
    JbedAddress intern = image->intern_table ? instance->boot.memory.address + image->intern_table : 0;
    JbedAddress characters = instance->support + SUPPORT_CHARACTERS;
    if (!jbed_vm_base_bootstrap(vm, image->sync_slots, error, size) ||
        !jbed_vm_monitor_bootstrap(vm, image->sync_slots, error, size) ||
        !jbed_vm_metadata_bootstrap(vm, intern, characters, error, size) ||
        !jbed_vm_collector_bootstrap(vm, error, size))
        return;
    instance->initialized = true;
}

bool jbed_instance_initialize(JbedInstance *instance, char *error, size_t error_size)
{
    if (instance->initialized)
        return true;
    if (instance->boot_started || !instance->vm.heap.first_chunk) {
        if (error && error_size)
            snprintf(error, error_size, "%s", instance->boot_started
                ? "VM initialization previously failed" : "VM initialization requires a Java heap");
        return false;
    }
    instance->boot_started = true;
    RuntimeBootstrap request = {instance, error, error_size};
    JbedVm *previous = jbed_vm_bind(&instance->vm);
    JbedError caught;
    bool returned = protected_call(instance, initialize_runtime, &request, &caught);
    jbed_vm_bind(previous);
    if (!returned && error && error_size)
        snprintf(error, error_size, "%s", caught.message ? caught.message : "VM initialization failed");
    return instance->initialized;
}

static void image_configuration(JbedInstance *instance)
{
    JbedVm *vm = &instance->vm;
    const JbedBootImage *image = instance->boot.image;
    struct Configuration { const char *name; uint32_t value; } values[] = {
        {"firstString", instance->boot.memory.address + image->intern_table},
        {"propertiesHash", instance->boot.memory.address + image->properties},
        {"mainMethod", instance->main_method},
        {"staticVarSize", image->statics_size},
        {"synchTableSize", image->sync_slots},
        {"initialStackSize", vm->stack_space},
        {"maxStackSize", vm->stack_space},
        {"reservedStackSpace", RUNTIME_STACK_RESERVE},
        {"schedulerPeriod", SCHEDULER_PERIOD_MICROS}
    };
    for (size_t i = 0; i < sizeof(values) / sizeof(*values); ++i) {
        JbedAddress slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/SysInfo", values[i].name);
        if (!slot) jbed_vm_fatal(vm, "Source image is missing SysInfo configuration");
        jbed_vm_put_word(vm->heap.memory, slot, values[i].value);
    }
}

typedef struct IsolateStartup {
    RuntimeBootstrap bootstrap;
    JbedAddress *arguments;
    int32_t id;
} IsolateStartup;

static void start_isolate(void *context)
{
    IsolateStartup *request = context;
    JbedInstance *instance = request->bootstrap.instance;
    JbedVm *vm = &instance->vm;
    const JbedBootImage *image = instance->boot.image;
    char *error = request->bootstrap.error;
    size_t error_size = request->bootstrap.error_size;
    Main_notifyStateChange(0, false, JBED_VM_DOWN, JBED_VM_IDLE, 0);
    jbed_vm_switch_statics(vm, 0);
    vm->isolate_id = -1;
    jbed_vm_bind_global_roots(vm, image);
    image_configuration(instance);
    jbed_vm_scheduler_initialize_timer(vm);
    if (!jbed_vm_base_bootstrap(vm, image->sync_slots, error, error_size) ||
        !jbed_vm_collector_bootstrap(vm, error, error_size))
        return;
    JbedAddress root_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Main", "rootIsolate");
    if (!root_slot) jbed_vm_fatal(vm, "Source image has no Main.rootIsolate");
    JbedAddress root = jbed_vm_isolate_start_root(vm, image, *request->arguments);
    if (!root) return;
    jbed_vm_put_word(vm->heap.memory, root_slot, root);
    jbed_vm_scheduler_start_timer(vm);
    Main_notifyStateChange(0, true, JBED_VM_DOWN, JBED_VM_IDLE, 0);
    if (!jbed_vm_isolate_activate_first(vm, root, image->sync_slots,
            instance->boot.memory.address + image->intern_table,
            instance->support + SUPPORT_CHARACTERS, error, error_size))
        return;
    root = jbed_vm_word(vm->heap.memory, root_slot);
    request->id = (int32_t)jbed_vm_word(vm->heap.memory, root + JBED_ISOLATE_ID);
    instance->initialized = true;
}

bool jbed_instance_start(JbedInstance *instance, JbedAddress arguments, int32_t *root_id,
                         char *error, size_t error_size)
{
    if (root_id) *root_id = -1;
    if (instance->boot_started || !instance->vm.heap.first_chunk ||
        !instance->boot.image->intern_table || !instance->boot.image->properties ||
        instance->vm.stack_space <= RUNTIME_STACK_RESERVE) {
        if (error && error_size)
            snprintf(error, error_size, "Isolate startup requires a fresh VM, runtime image, boot properties and managed stack");
        return false;
    }
    instance->boot_started = true;
    JbedVm *vm = &instance->vm;
    vm->lifecycle.requested_state = JBED_VM_ACTIVE;
    JbedVm *previous = jbed_vm_bind(vm);
    jbed_vm_signals_install(&instance->signals);
    JbedVmHeapRoot argv = {arguments, arguments, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &argv;
    IsolateStartup request = {{instance, error, error_size}, &argv.value, -1};
    JbedError caught;
    bool returned = protected_call(instance, start_isolate, &request, &caught);
    vm->heap.temporary_roots = argv.previous;
    jbed_vm_bind(previous);
    if (!returned && error && error_size)
        snprintf(error, error_size, "%s", caught.message ? caught.message : "Isolate startup failed");
    if (instance->initialized && root_id) *root_id = request.id;
    return instance->initialized;
}

static bool utf8_character(const uint8_t **cursor, const uint8_t *end, uint32_t *value)
{
    const uint8_t *p = *cursor;
    uint32_t ch = *p++;
    unsigned extra;
    uint32_t minimum;
    if (ch < 0x80) { extra = 0; minimum = 0; }
    else if (ch >= 0xc2 && ch <= 0xdf) { ch &= 0x1f; extra = 1; minimum = 0x80; }
    else if (ch >= 0xe0 && ch <= 0xef) { ch &= 0x0f; extra = 2; minimum = 0x800; }
    else if (ch >= 0xf0 && ch <= 0xf4) { ch &= 7; extra = 3; minimum = 0x10000; }
    else return false;
    if ((size_t)(end - p) < extra) return false;
    while (extra--) {
        if ((*p & 0xc0) != 0x80) return false;
        ch = (ch << 6) | (*p++ & 0x3f);
    }
    if (ch < minimum || ch > 0x10ffff || (ch >= 0xd800 && ch <= 0xdfff)) return false;
    *cursor = p;
    *value = ch;
    return true;
}

typedef struct MainArguments {
    JbedVm *vm;
    int count;
    const char *const *text;
    JbedVmHeapRoot *array;
} MainArguments;

static void make_main_arguments(void *context)
{
    MainArguments *arguments = context;
    JbedVm *vm = arguments->vm;
    JbedAddress strings = jbed_vm_find_class(vm, "[Ljava/lang/String;");
    arguments->array->value = jbed_vm_allocate_array(vm, strings, arguments->count, false);
    for (int i = 0; i < arguments->count; ++i) {
        const uint8_t *text = (const uint8_t *)arguments->text[i];
        const uint8_t *end = text + strlen(arguments->text[i]), *p = text;
        uint32_t length = 0, ch;
        while (p < end) {
            (void)utf8_character(&p, end, &ch);
            length += ch >= 0x10000 ? 2 : 1;
        }
        JbedAddress characters = jbed_vm_allocate_array(vm,
            vm->primitive_array_classes[JBED_TYPE_CHAR], (int32_t)length, false);
        uint16_t *output = (uint16_t *)jbed_vm_at(vm->heap.memory, characters + 16);
        for (p = text; p < end;) {
            (void)utf8_character(&p, end, &ch);
            if (ch >= 0x10000) {
                ch -= 0x10000;
                *output++ = (uint16_t)(0xd800 + (ch >> 10));
                ch = 0xdc00 + (ch & 0x3ff);
            }
            *output++ = (uint16_t)ch;
        }
        JbedVmHeapRoot root = {characters, characters, vm->heap.temporary_roots};
        vm->heap.temporary_roots = &root;
        JbedAddress string = jbed_vm_allocate_object(vm, vm->string_class, false);
        vm->heap.temporary_roots = root.previous;
        JbString *object = (JbString *)jbed_vm_at(vm->heap.memory, string);
        object->chars = root.value;
        object->offset = 16;
        object->length = (int32_t)length;
        jbed_vm_put_word(vm->heap.memory, arguments->array->value + 16 + 4u * (unsigned)i, string);
    }
}

bool jbed_instance_start_main(JbedInstance *instance, const char *owner, int argc,
                              const char *const *utf8_argv, int32_t *root_id,
                              char *error, size_t error_size)
{
    const char *problem = NULL;
    JbedAddress main_method = instance->main_method;
    if (root_id) *root_id = -1;
    if (instance->boot_started || argc < 0 || (argc && !utf8_argv))
        problem = "Main startup requires a fresh VM and valid arguments";
    for (int i = 0; !problem && i < argc; ++i) {
        if (!utf8_argv[i]) { problem = "A main argument is null"; break; }
        size_t size = strlen(utf8_argv[i]);
        if (size > INT32_MAX) { problem = "A main argument is too large"; break; }
        const uint8_t *p = (const uint8_t *)utf8_argv[i], *end = p + size;
        uint32_t ch;
        while (p < end)
            if (!utf8_character(&p, end, &ch)) { problem = "A main argument is not valid UTF-8"; break; }
    }
    if (!problem && owner) {
        const JbedBootImage *image = instance->boot.image;
        main_method = 0;
        for (size_t i = 0; i < image->method_count; ++i) {
            const JbedBootMethod *method = &image->methods[i];
            if (!strcmp(method->owner, owner) && !strcmp(method->name, "main") &&
                !strcmp(method->descriptor, "([Ljava/lang/String;)V") &&
                (method->flags & (JBED_ACC_PUBLIC | JBED_ACC_STATIC)) ==
                    (JBED_ACC_PUBLIC | JBED_ACC_STATIC)) {
                main_method = instance->boot.memory.address + method->offset;
                break;
            }
        }
    }
    if (!problem && !main_method) problem = "The boot image has no matching public static main(String[])";
    if (problem) {
        if (error && error_size) snprintf(error, error_size, "%s", problem);
        return false;
    }
    instance->main_method = main_method;
    JbedVm *vm = &instance->vm, *previous = jbed_vm_bind(vm);
    JbedVmHeapRoot argv = {0, 0, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &argv;
    MainArguments arguments = {vm, argc, utf8_argv, &argv};
    JbedError caught;
    bool ready = protected_call(instance, make_main_arguments, &arguments, &caught);
    if (ready) ready = jbed_instance_start(instance, argv.value, root_id, error, error_size);
    else if (error && error_size)
        snprintf(error, error_size, "%s", caught.message ? caught.message : "Cannot create main arguments");
    vm->heap.temporary_roots = argv.previous;
    jbed_vm_bind(previous);
    return ready;
}

typedef struct Iteration {
    JbedInstance *instance;
    int32_t slice, delay;
    JbedAddress activate, deactivate;
} Iteration;

static void iterate_isolate(void *context)
{
    Iteration *iteration = context;
    JbedInstance *instance = iteration->instance;
    JbedVm *vm = &instance->vm;
    JbedAddress slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Main", "rootIsolate");
    JbedAddress address = jbed_vm_word(vm->heap.memory, slot);
    JbedVmHeapRoot root = {address, address, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbedRomIsolate *isolate = (JbedRomIsolate *)jbed_vm_at(vm->heap.memory, root.value);
    vm->heap.current_isolate = root.value;
    vm->isolate_id = isolate->id;
    uint64_t result;
    if (!isolate->active && !jbed_vm_invoke(vm, iteration->activate, &root.value, 1, &result))
        goto finished;
    JbedAddress current = jbed_vm_word(vm->heap.memory, vm->monitors.image.current_slot);
    JbedAddress dummy = vm->collector.stacks.vm_dummy;
    jbed_vm_put_word(vm->heap.memory, current + SCHEDULED_FIELD(stackBase),
        jbed_vm_word(vm->heap.memory, dummy + SCHEDULED_FIELD(stackBase)));
    jbed_vm_put_word(vm->heap.memory, current + SCHEDULED_FIELD(stackLimit),
        jbed_vm_word(vm->heap.memory, dummy + SCHEDULED_FIELD(stackLimit)));
    iteration->delay = jbed_vm_scheduler_iterate(vm, iteration->slice < 20 ? 20 : iteration->slice);
    JbedAddress time_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/SuperScheduler", "time");
    uint64_t micros = jbed_vm_word(vm->heap.memory, vm->monitors.image.time_slot) |
        (uint64_t)jbed_vm_word(vm->heap.memory, vm->monitors.image.time_slot + 4) << 32;
    uint64_t millis = micros / 1000;
    jbed_vm_put_word(vm->heap.memory, time_slot, (uint32_t)millis);
    jbed_vm_put_word(vm->heap.memory, time_slot + 4, (uint32_t)(millis >> 32));
    if (jbed_vm_invoke(vm, iteration->deactivate, &root.value, 1, &result) && (uint32_t)result) {
        JbedAddress exit_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Main", "exitCode");
        instance->exit_code = (int32_t)jbed_vm_word(vm->heap.memory, exit_slot);
        instance->exited = true;
        iteration->delay = -3;
    }
finished:
    vm->heap.temporary_roots = root.previous;
}

bool jbed_instance_iterate(JbedInstance *instance, int32_t slice_ms, int32_t *delay,
                           int32_t *exit_code, char *error, size_t error_size)
{
    if (delay) *delay = 0;
    if (exit_code) *exit_code = instance->exit_code;
    if (instance->exited) {
        if (delay) *delay = -3;
        return true;
    }
    Iteration iteration = {instance, slice_ms, 0,
        jbed_boot_method(&instance->boot, "com/jbed/runtime/Isolate", "activate", "()V"),
        jbed_boot_method(&instance->boot, "com/jbed/runtime/Isolate", "deactivate", "()Z")};
    JbedVm *vm = &instance->vm;
    JbedAddress root_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Main", "rootIsolate");
    if (!instance->initialized || !root_slot || !jbed_vm_word(vm->heap.memory, root_slot) ||
        !iteration.activate || !iteration.deactivate) {
        if (error && error_size) snprintf(error, error_size, "Iteration requires a started isolate and its lifecycle methods");
        return false;
    }
    JbedVm *previous = jbed_vm_bind(vm);
    JbedVmHeapRoot *roots = vm->heap.temporary_roots;
    vm->pending_exception = 0;
    JbedError caught;
    bool success = protected_call(instance, iterate_isolate, &iteration, &caught);
    vm->heap.temporary_roots = roots;
    if (success && vm->pending_exception) {
        if (error && error_size) snprintf(error, error_size, "Isolate scheduling threw a Java exception");
        success = false;
    } else if (!success && error && error_size) {
        snprintf(error, error_size, "%s", caught.message ? caught.message : "Isolate scheduling failed");
    }
    jbed_vm_bind(previous);
    if (delay) *delay = iteration.delay;
    if (exit_code) *exit_code = instance->exit_code;
    return success;
}

bool jbed_instance_request_state(JbedInstance *instance, JbedInstanceState state)
{
    JbedVmLifecycle *lifecycle = &instance->vm.lifecycle;
    lifecycle->requested_state = state;
    if (lifecycle->control_signal) {
        extern void Jbed_signalArg(VmSignal *, int);
        Jbed_signalArg((VmSignal *)(uintptr_t)lifecycle->control_signal, state);
    }
    return lifecycle->committed_state == (int32_t)state && lifecycle->last_state == (int32_t)state;
}

JbedVm *jbed_instance_runtime(JbedInstance *instance) { return &instance->vm; }

const JbedLoadedBoot *jbed_instance_image(const JbedInstance *instance)
{
    return &instance->boot;
}

bool jbed_instance_call(JbedInstance *instance, const char *owner, const char *name,
                        const char *descriptor, const uint32_t *arguments, size_t count,
                        uint64_t *result, JbedAddress *throwable)
{
    JbedAddress entry = jbed_boot_method(&instance->boot, owner, name, descriptor);
    if (throwable)
        *throwable = 0;
    if (!entry)
        return false;
    instance->vm.pending_exception = 0;
    bool success = jbed_vm_invoke(&instance->vm, entry, arguments, count, result);
    if (throwable)
        *throwable = instance->vm.pending_exception;
    return success;
}
