#include "collector_init.h"
#include "execution.h"
#include "metadata_init.h"
#include "roots.h"
#include "scheduler.h"
#include "isolate.h"
#include "../compiler/vm/vm_words.h"

#include <stdio.h>

enum { SAVED_REGISTERS = 8, HOLE_WORDS = 18 };

JbedAddress jbed_vm_switch_statics(JbedVm *vm, JbedAddress statics)
{
    JbedAddress previous = vm->isolate_statics;
    vm->isolate_statics = vm->classes.isolate_statics = statics;
    vm->collector.stacks.current_statics = statics;
    if (vm->arm) {
        vm->arm->statics = (void *)(uintptr_t)statics;
        if (vm->arm->frame) vm->arm->frame->r[9] = statics;
    }
    if (vm == jbed_vm_current())
        Jbed_relativeStaticsBase = statics ? jbed_vm_at(vm->heap.memory, statics) : NULL;

    if (vm->monitors.heap) {
        JbedVmMonitorImage *image = &vm->monitors.image;
        vm->monitors.isolate_statics = statics;
        image->table_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Isolate", "synchArray");
        image->current_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Scheduler", "current");
        image->ready_root_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Scheduler", "rtroot");
        image->time_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Scheduler", "time");
        image->timer_low_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Scheduler", "timerLow");
        image->timer_high_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Scheduler", "timerHigh");
    }
    if (vm->strings.heap) {
        vm->strings.image.static_table_slot = jbed_vm_static_field_slot(vm, "java/lang/String", "staticHashtable");
        vm->strings.image.dynamic_table_slot = jbed_vm_static_field_slot(vm, "java/lang/String", "hashtable");
    }
    if (vm->classes.guest_root) {
        bool published = vm->classes.guest_root == vm->classes.heap_image.registered_root;
        vm->classes.heap_image.registered_root = jbed_vm_static_field_slot(vm, "java/lang/Class", "classes");
        vm->classes.heap_image.compiler_root = jbed_vm_static_field_slot(vm, "com/jbed/tbcc/Compiler", "classes");
        vm->classes.guest_root = published ? vm->classes.heap_image.registered_root : vm->classes.heap_image.compiler_root;
    }
    if (vm->signals.queue_slot) {
        vm->signals.queue_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Scheduler", "signalList");
        vm->signals.pending_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Scheduler", "signalPending");
        vm->signals.current_thread_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Scheduler", "current");
    }
    const char *reflection_owners[] = {"com/jbed/reflect/ClassAccess", "com/jbed/reflect/ClassAccess",
        "com/jbed/reflect/Method", "com/jbed/reflect/Field", "com/jbed/reflect/SignatureEncoder"};
    const char *reflection_names[] = {"packageNameTable", "baseNameTable", "reflTable", "reflTable", "reflTable"};
    for (size_t i = 0; i < sizeof(vm->reflection_roots) / sizeof(*vm->reflection_roots); ++i)
        vm->reflection_roots[i] = statics ? jbed_vm_static_field_slot(vm, reflection_owners[i], reflection_names[i]) : 0;
    return previous;
}

/* Finalized.finalize uses the same interface chain as generated invokeinterface. */
static void invoke_finalizer(void *context, JbedAddress isolate, JbedAddress object)
{
    JbedVm *vm = context;
    JbedBuffer memory = vm->heap.memory;
    JbedAddress interface = jbed_vm_find_class(vm, "com/jbed/runtime/Finalized");
    if (!interface) jbed_vm_fatal(vm, "Finalized interface is absent");
    JbedClass *klass = jbed_class_object(&vm->classes, jbed_vm_word(memory, interface + 16));
    JbedNameId name = jbed_reflection_id(&vm->method_names, (const uint8_t *)"finalize", 8, false);
    JbedMethod *method = klass ? klass->methods : NULL;
    while (method && (method->name_id != name || method->signature_id != JBED_SIGNATURE_VOID_NO_ARGS))
        method = method->next;
    if (!method || method->dispatch_slot < 0)
        jbed_vm_fatal(vm, "Finalized.finalize has no interface slot");
    JbedAddress table = jbed_vm_word(memory, object);
    while ((table = jbed_vm_word(memory, table + 4)) != 0)
        if (jbed_vm_word(memory, table) == interface) break;
    if (!table) jbed_vm_raise(vm, JBED_ERROR_ERROR, "Finalizer interface is not implemented");
    JbedAddress entry = jbed_vm_word(memory, table + 8 + 4u * (unsigned)method->dispatch_slot);
    JbedAddress finalizing = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Collector", "finalizingIsolateId");
    JbedAddress downcall = jbed_vm_static_field_slot(vm, "com/jbed/runtime/CollectorBase", "inCollectorDownCall");
    if (finalizing) jbed_vm_put_word(memory, finalizing, (uint32_t)vm->collector.finalizing_isolate);
    uint8_t previous_downcall = downcall ? *jbed_vm_at(memory, downcall) : 0;
    if (downcall) *jbed_vm_at(memory, downcall) = 1;
    JbRef *parameters = Jbed_ParamPtr;
    JbedAddress previous = jbed_vm_switch_statics(vm,
        isolate ? jbed_vm_word(memory, isolate + JBED_ISOLATE_STATICS) + 16 : 0);
    uint64_t ignored;
    bool returned = jbed_vm_invoke(vm, entry, &object, 1, &ignored);
    jbed_vm_switch_statics(vm, previous);
    Jbed_ParamPtr = parameters;
    if (finalizing) jbed_vm_put_word(memory, finalizing, UINT32_MAX);
    if (downcall) *jbed_vm_at(memory, downcall) = previous_downcall;
    if (!returned) {
        JbedError error = {.kind = JBED_ERROR_THROWABLE,
            .runtime_throwable = jbed_vm_at(memory, vm->pending_exception)};
        jbed_raise(&vm->services, &error);
    }
}

typedef enum CollectionKind { COLLECT, COMPACT, SHUTDOWN } CollectionKind;

typedef struct Collection {
    JbedVm *vm;
    CollectionKind kind;
    bool option;
} Collection;

static void collect_body(void *context)
{
    Collection *operation = context;
    if (operation->kind == COMPACT)
        jbed_vm_compact(&operation->vm->compactor, operation->option);
    else if (operation->kind == SHUTDOWN)
        jbed_vm_collector_shutdown(&operation->vm->collector);
    else
        jbed_vm_collect(&operation->vm->collector, operation->option);
}

/* The native handle stack contains host addresses of managed references.
 * Temporary roots keep those references writable by the moving collector. */
static void collect_with_roots(JbedVm *vm, CollectionKind kind, bool option)
{
    void **top = vm == jbed_vm_current() ? Jbed_nativeCallStateAdr : vm->native_roots_top;
    size_t native_count = 0;
    if (top) {
        if (!vm->native_roots_base || top < vm->native_roots_base || top > vm->native_roots_limit)
            jbed_vm_fatal(vm, "Native root stack outside its frame");
        native_count = (size_t)(top - vm->native_roots_base);
    }
    JbedVmNativeRoot native[native_count ? native_count : 1];
    uint32_t displacement[native_count ? native_count : 1];
    size_t native_roots = 0;
    void **cursor = top ? vm->native_roots_base : top;
    while (jbed_vm_next_native_root(vm, &cursor, top, &native[native_roots])) {
        JbedVmNativeRoot *root = &native[native_roots];
        if (root->interior)
            displacement[native_roots] = *root->interior - *root->slot;
        ++native_roots;
    }
    JbedAddress *host_slots[] = {
        &vm->pending_exception, &vm->out_of_memory, &vm->exceptions.stack_overflow, &vm->heap.first_chunk,
        &vm->heap.current_isolate, &vm->collector.isolates, &vm->collector.stacks.vm_dummy,
        &vm->lifecycle.control_signal
    };
    size_t host_count = sizeof(host_slots) / sizeof(*host_slots);
    size_t count = native_roots + host_count + vm->native_static_root_count;
    JbedAddress *slots[count];
    for (size_t i = 0; i < native_roots; ++i)
        slots[i] = native[i].slot;
    for (size_t i = 0; i < host_count; ++i)
        slots[native_roots + i] = host_slots[i];
    for (size_t i = 0; i < vm->native_static_root_count; ++i)
        slots[native_roots + host_count + i] = vm->native_static_roots[i];
    JbedVmHeapRoot roots[count];
    JbedVmHeapRoot *previous = vm->heap.temporary_roots;
    for (size_t i = 0; i < count; ++i) {
        roots[i] = (JbedVmHeapRoot){*slots[i], *slots[i], vm->heap.temporary_roots};
        vm->heap.temporary_roots = &roots[i];
    }
    Collection operation = {vm, kind, option};
    JbedError caught;
    bool returned = vm->services.protected_call(vm->services.context, collect_body, &operation, &caught);
    vm->heap.temporary_roots = previous;
    for (size_t i = 0; i < count; ++i)
        *slots[i] = roots[i].value;
    for (size_t i = 0; i < native_roots; ++i)
        if (native[i].interior)
            *native[i].interior = roots[i].value + displacement[i];
    if (returned && kind == COMPACT)
        jbed_vm_scheduler_fix_native_pointers(vm);
    if (!returned) {
        vm->heap.collecting = false;
        jbed_raise(&vm->services, &caught);
    }
}

void jbed_vm_run_collector(JbedVm *vm, bool clear_soft_references)
{
    collect_with_roots(vm, COLLECT, clear_soft_references);
}

void jbed_vm_run_compactor(JbedVm *vm, bool oldest_hole)
{
    collect_with_roots(vm, COMPACT, oldest_hole);
}

void jbed_vm_shutdown_collector(JbedVm *vm)
{
    collect_with_roots(vm, SHUTDOWN, false);
}

static void collect(void *context, JbedVmHeap *heap, bool clear_soft_references)
{
    (void)heap;
    jbed_vm_run_collector(context, clear_soft_references);
}

static void compact(void *context, JbedVmHeap *heap)
{
    (void)heap;
    jbed_vm_run_compactor(context, false);
}

static bool fail(char *error, size_t size, const char *message)
{
    if (error && size) snprintf(error, size, "%s", message);
    return false;
}

static JbedAddress allocate_pinned(JbedVm *vm, JbedAddress klass, int32_t count)
{
    if (!jbed_vm_next_allocate_locked(&vm->heap)) return 0;
    return count < 0 ? jbed_vm_new_object(&vm->heap, klass)
                     : jbed_vm_new_array(&vm->heap, count, klass);
}

bool jbed_vm_collector_bootstrap(JbedVm *vm, char *error, size_t error_size)
{
    const char *scheduler = "com/jbed/runtime/SuperScheduler";
    const char *collector = "com/jbed/runtime/Collector";
    const char *compactor = "com/jbed/runtime/Compactor";
    JbedAddress collector_class = jbed_vm_find_class(vm, collector);
    JbedAddress compactor_class = jbed_vm_find_class(vm, compactor);
    JbedAddress ints = vm->primitive_array_classes[JBED_TYPE_INT];
    JbedAddress isolates = jbed_vm_static_field_slot(vm, scheduler, "isolates");
    JbedAddress dummy = jbed_vm_static_field_slot(vm, scheduler, "dummy");
    JbedAddress finalized = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Memory", "finList");
    JbedAddress first_chunk = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Memory", "firstChunk");
    JbedAddress csr = jbed_vm_static_field_slot(vm, "com/jbed/runtime/CollectorBase", "csr");
    JbedAddress collector_instance = jbed_vm_static_field_slot(vm, collector, "instance");
    JbedAddress compactor_instance = jbed_vm_static_field_slot(vm, compactor, "instance");
    JbedAddress holes = jbed_vm_static_field_slot(vm, compactor, "holes");
    JbedAddress collector_initialized = jbed_vm_static_field_slot(vm, collector, "initialized");
    JbedAddress compactor_initialized = jbed_vm_static_field_slot(vm, compactor, "initialized");
    JbedAddress finalizing = jbed_vm_static_field_slot(vm, collector, "finalizingIsolateId");
    if (!vm->heap.first_chunk || !vm->services.protected_call ||
        !collector_class || !compactor_class || !ints || !isolates || !dummy || !finalized ||
        !first_chunk || !csr || !collector_instance || !compactor_instance || !holes ||
        !collector_initialized || !compactor_initialized || !finalizing)
        return fail(error, error_size, "Collector bootstrap requires runtime classes, static roots and an initialized heap");
    if (vm->collector.marker.heap)
        return fail(error, error_size, "Collector is already initialized");

    struct InitialObject { JbedAddress slot, klass; int32_t count; } initial[] = {
        {csr, ints, SAVED_REGISTERS},
        {collector_instance, collector_class, -1},
        {compactor_instance, compactor_class, -1},
        {holes, ints, HOLE_WORDS}
    };
    for (size_t i = 0; i < sizeof(initial) / sizeof(*initial); ++i) {
        JbedAddress object = allocate_pinned(vm, initial[i].klass, initial[i].count);
        if (!object) return fail(error, error_size, "Cannot allocate collector bootstrap objects");
        jbed_vm_put_word(vm->heap.memory, initial[i].slot, object);
    }
    if (!jbed_vm_word(vm->heap.memory, isolates)) jbed_vm_isolate_registry_init(vm);
    JbedAddress table = jbed_vm_word(vm->heap.memory, isolates);
    jbed_vm_put_word(vm->heap.memory, first_chunk, vm->heap.first_chunk);
    jbed_vm_put_word(vm->heap.memory, finalizing, UINT32_MAX);
    *jbed_vm_at(vm->heap.memory, collector_initialized) = 1;
    *jbed_vm_at(vm->heap.memory, compactor_initialized) = 1;

    vm->collector = (JbedVmCollector){
        .marker = {&vm->heap, &vm->services, false},
        .stacks = {.maps = &vm->stack_maps, .native_frames = &vm->native_frames,
            .current_statics = vm->isolate_statics, .vm_dummy = jbed_vm_word(vm->heap.memory, dummy),
            .provider_context = vm, .stack_provider = jbed_vm_visit_source_stacks},
        .isolates = table, .finalizing_isolate = -1, .default_ttl = 2,
        .context = vm, .visit_roots = jbed_vm_visit_runtime_roots,
        .invoke_finalizer = invoke_finalizer
    };
    jbed_vm_compactor_init(&vm->compactor, &vm->collector, finalized);
    vm->heap.collector = NULL;
    vm->heap.compactor = NULL;
    vm->heap.services.context = vm;
    vm->heap.services.collect = collect;
    vm->heap.services.compact = compact;
    return true;
}
