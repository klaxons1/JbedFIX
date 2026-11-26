#include "memory.h"
#include "arithmetic.h"
#include "collector_init.h"
#include "execution.h"
#include "metadata_init.h"
#include "../compiler/signatures.h"
#include "../compiler/vm/vm_words.h"
#include "../platform/vm/vm_os.h"

#include <limits.h>
#include <stdio.h>
#include <string.h>

extern void CPL_os_logChar(int);

void *Memory_allocatedField(void *runtime) { return &((JbedVm *)runtime)->heap.allocated; }
void *Memory_firstChunkField(void *runtime) { return &((JbedVm *)runtime)->heap.first_chunk; }
void *Memory_heapTraceEnabledField(void *runtime) { return &((JbedVm *)runtime)->heap.trace_usage; }
void *Memory_maxTotalHeapUsageField(void *runtime) { return &((JbedVm *)runtime)->heap.max_total_usage; }
void *Memory_totalHeapUsageField(void *runtime) { return &((JbedVm *)runtime)->heap.usage; }
void *Memory_noAllocationField(void *runtime) { (void)runtime; return &Jbed_noAllocation; }
void *Memory_outOfMemoryField(void *runtime) { return &((JbedVm *)runtime)->out_of_memory; }
void *Memory_stackSpaceField(void *runtime) { return &((JbedVm *)runtime)->stack_space; }

static void log_message(const char *message)
{
    for (; *message; ++message) CPL_os_logChar((unsigned char)*message);
}

static JbedVm *active(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "Memory call outside a Jbed VM");
    vm->heap.no_allocation = (int32_t)Jbed_noAllocation;
    return vm;
}

void MemSupport_getHeapBlock(JbedAddress address_slot, JbedAddress size_slot)
{
    JbedVmHeap *heap = &active()->heap;
    uint32_t *address = (uint32_t *)(uintptr_t)address_slot;
    uint32_t *size = (uint32_t *)(uintptr_t)size_slot;
    uint32_t requested = *size, bytes = 0;
    JbedAddress raw = 0;
    if (!heap->services.reserve_chunk)
        jbed_vm_fatal(active(), "Heap block provider is not initialized");
    if (!heap->services.reserve_chunk(heap->services.context, requested, &raw, &bytes))
        raw = bytes = 0;
    *address = raw;
    *size = bytes;
}

void MemSupport_freeHeapBlock(JbedAddress address)
{
    JbedVm *vm = active();
    if (!vm->heap.services.release_chunk)
        jbed_vm_fatal(vm, "Heap block provider is not initialized");
    vm->heap.services.release_chunk(vm->heap.services.context, address, 0);
}

int32_t MemSupport_getStackSpace(void) { return (int32_t)active()->stack_space; }

static JbedAddress allocated(JbedVm *vm, JbedAddress object)
{
    if (object) return object;
    switch (vm->heap.fault) {
    case JBED_HEAP_NULL_POINTER:
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    case JBED_HEAP_NEGATIVE_ARRAY:
        jbed_vm_raise(vm, JBED_ERROR_NEGATIVE_ARRAY_SIZE, NULL);
    case JBED_HEAP_OK:
    case JBED_HEAP_OUT_OF_MEMORY:
        if (vm->out_of_memory) {
            vm->pending_exception = vm->out_of_memory;
            return 0;
        }
        jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, NULL);
    case JBED_HEAP_INSTANTIATION_ERROR:
        jbed_vm_raise(vm, JBED_ERROR_ERROR, NULL);
    default:
        jbed_vm_fatal(vm, "Invalid Memory allocation state");
    }
}

JbedAddress Memory_newObject(JbedAddress klass)
{
    JbedVm *vm = active();
    if (!klass) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    return allocated(vm, jbed_vm_new_object(&vm->heap, klass));
}

JbedAddress Memory_newArray(int32_t length, JbedAddress klass)
{
    JbedVm *vm = active();
    if (!klass) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    return allocated(vm, jbed_vm_new_array(&vm->heap, length, klass));
}

JbedAddress Memory_xKniNewObject(JbedAddress klass)
{
    return jbed_vm_allocate_object(active(), klass, true);
}

JbedAddress Memory_xKniNewArray(int32_t length, JbedAddress klass)
{
    return jbed_vm_allocate_array(active(), klass, length, true);
}

JbedAddress Memory_newArrayN(int32_t length, JbedAddress prototype, JbedAddress klass)
{
    JbedVm *vm = active();
    return allocated(vm, jbed_vm_new_array_n(&vm->heap, length, prototype, klass));
}

JbedAddress Memory_structCopy(JbedAddress object)
{
    JbedVm *vm = active();
    return allocated(vm, jbed_vm_struct_copy(&vm->heap, object));
}

JbedAddress Memory_resize(JbedAddress array, int32_t length)
{
    JbedVm *vm = active();
    return allocated(vm, jbed_vm_resize_array(&vm->heap, array, (uint32_t)length));
}

void Memory_lock(JbedAddress object)
{
    JbedVm *vm = active();
    if (!jbed_vm_lock_object(&vm->heap, object))
        jbed_vm_fatal(vm, "Memory.lock: too many locks");
}

void Memory_unlock(JbedAddress object)
{
    JbedVm *vm = active();
    if (!jbed_vm_unlock_object(&vm->heap, object))
        jbed_vm_fatal(vm, "Memory.unlock: object is not locked");
}

void Memory_nextAllocateLocked(void)
{
    JbedVm *vm = active();
    if (!jbed_vm_next_allocate_locked(&vm->heap))
        jbed_vm_fatal(vm, "Memory.nextAllocateLocked: allocation mode is already set");
}

static uint32_t object_flags(JbedVm *vm, JbedAddress object)
{
    if (!object) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    return jbed_vm_word(vm->heap.memory, object + 4);
}

bool Memory_isLocked(JbedAddress object)
{
    return (object_flags(active(), object) & (JBED_OBJECT_PINNED | JBED_OBJECT_LOCK_MASK)) != 0;
}

bool Memory_isReadOnlyObject(JbedAddress object)
{
    return (object_flags(active(), object) & 3) == 3;
}

bool Memory_isStaticReadOnlyObject(JbedAddress object)
{
    return (object_flags(active(), object) & 7) == 3;
}

bool Memory_allocateFromHeapEnd(bool from_end)
{
    JbedVmHeap *heap = &active()->heap;
    bool previous = heap->allocation_end < 0;
    heap->allocation_end = from_end ? -1 : 0;
    return previous;
}

void Memory_disableAccounting(bool disabled) { active()->heap.accounting_disabled = disabled; }
int32_t Memory_getFinalizingIsolateId(void) { return active()->collector.finalizing_isolate; }

int32_t Memory_nextFinalizedOffset(JbedAddress object)
{
    JbedVm *vm = active();
    if (!object) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    return (int32_t)(jbed_vm_finalizer_link(&vm->heap, object) - object);
}

JbedAddress Memory_nextFinalized(JbedAddress object)
{
    JbedVm *vm = active();
    JbedAddress next = jbed_vm_word(vm->heap.memory,
        object + (uint32_t)Memory_nextFinalizedOffset(object));
    JbedAddress klass = jbed_vm_find_class(vm, "com/jbed/runtime/Finalized");
    return jbed_vm_checkcast(&vm->resident, vm->heap.memory, next,
                             jbed_vm_class_at(&vm->resident, klass));
}

void Memory_runGC(void) { jbed_vm_run_collector(active(), false); }

void Memory_runCompactorOldest(bool oldest_hole)
{
    JbedVm *vm = active();
    jbed_vm_run_collector(vm, false);
    jbed_vm_run_compactor(vm, oldest_hole);
}

void Memory_runCompactor(void) { Memory_runCompactorOldest(false); }

void Memory_runCompactorPercent(int32_t percent)
{
    if (percent >= 100 || jbed_arm32_integer_divide(
            (int32_t)(100u * (uint32_t)Memory_heapAvail()), Memory_heapSize()) <= percent)
        Memory_runCompactor();
}

int32_t Memory_heapAvail(void)
{
    JbedVmHeap *heap = &active()->heap;
    return (int32_t)(heap->heap_size - heap->allocated);
}

int32_t Memory_heapSize(void) { return (int32_t)active()->heap.heap_size; }
int32_t Memory_totalAllocated(void) { return (int32_t)active()->heap.allocated; }
int32_t Memory_quotaAvail(void) { return (int32_t)(INT32_MAX - active()->heap.allocated); }
void Memory_incrementTotalHeapSize(int32_t delta) { active()->heap.heap_size += (uint32_t)delta; }
int32_t Memory_largestFreeBlock(void) { return (int32_t)jbed_vm_heap_largest_free(&active()->heap); }
JbedAddress Memory_findBlockTable(JbedAddress address) { return jbed_vm_heap_find_table(&active()->heap, address); }
JbedAddress Memory_tryAlloc(int32_t bytes) { return jbed_vm_heap_try_alloc(&active()->heap, (uint32_t)bytes); }
JbedAddress Memory_getFreeList(void) { return active()->heap.free_list; }
void Memory_freeListChanged(void) { active()->heap.last_size = INT32_MAX; }

void Memory_setFreeList(JbedAddress first)
{
    JbedVmHeap *heap = &active()->heap;
    heap->free_list = first;
    heap->last_size = INT32_MAX;
}

int32_t Memory_getBlockAlign(void) { return JBED_HEAP_BLOCK_BYTES; }

bool Memory_initHeapBlock(JbedAddress address, int32_t bytes, bool lockable)
{
    return jbed_vm_heap_add_chunk(&active()->heap, address, (uint32_t)bytes, lockable);
}

bool Memory_addHeapBlock(int32_t bytes)
{
    JbedVmHeap *heap = &active()->heap;
    JbedAddress raw;
    uint32_t size;
    uint32_t requested = bytes > 0 ? (uint32_t)bytes + 2 * JBED_HEAP_BLOCK_BYTES : (uint32_t)bytes;
    return heap->services.reserve_chunk &&
        heap->services.reserve_chunk(heap->services.context, requested, &raw, &size) &&
        jbed_vm_heap_add_chunk(heap, raw, size, true);
}

void Memory_setCollectorTestProbabilities(int32_t allocations, int32_t runtime)
{
    JbedVmHeap *heap = &active()->heap;
    int32_t old_allocation = heap->collector_test_threshold;
    int32_t old_runtime = heap->runtime_collector_test_threshold;
    heap->collector_test_threshold = allocations > 0 ? INT32_MAX / allocations : 0;
    heap->runtime_collector_test_threshold = runtime > 0 ? INT32_MAX / runtime : 0;
    char text[80];
    if (allocations > 0) {
        snprintf(text, sizeof(text), "GC test on with probability 1/%d\n", allocations);
        log_message(text);
    } else if (old_allocation > 0) {
        log_message("GC test off\n");
    }
    if (runtime > 0) {
        snprintf(text, sizeof(text), "Runtime collector test probability: 1/%d\n", runtime);
        log_message(text);
    } else if (old_runtime > 0) {
        log_message("Runtime collector test off\n");
    }
}

static bool invoke_string_method(JbedVm *vm, const char *owner, const char *name,
                                 unsigned result_type, JbedAddress argument, uint32_t *result)
{
    JbedAddress address = jbed_vm_find_class(vm, owner);
    JbedClass *klass = address ? jbed_class_object(&vm->classes,
        jbed_vm_word(vm->heap.memory, address + 16)) : NULL;
    JbedNameId name_id = jbed_reflection_id(&vm->method_names,
        (const uint8_t *)name, strlen(name), false);
    JbedSignatureId signature = 0xf000 | JBED_SIGNATURE_STRING |
        (result_type << 4) | (JBED_SIGNATURE_END << 8);
    for (JbedMethod *method = klass ? klass->methods : NULL; method; method = method->next)
        if (method->name_id == name_id && method->signature_id == signature) {
            uint64_t value;
            if (!jbed_vm_invoke(vm, method->code_address, &argument, 1, &value)) return false;
            *result = (uint32_t)value;
            return true;
        }
    jbed_vm_fatal(vm, "Collector test requires System.getProperty and Integer.parseInt");
}

static bool property(JbedVm *vm, const char *name, int32_t fallback, int32_t *result)
{
    JbString *string = Jbni_intern_newStringExc(name);
    uint32_t value;
    if (!invoke_string_method(vm, "java/lang/System", "getProperty", JBED_SIGNATURE_STRING,
                              (JbedAddress)(uintptr_t)string, &value)) return false;
    if (!value) {
        *result = fallback;
        return true;
    }
    if (!invoke_string_method(vm, "java/lang/Integer", "parseInt", JBED_TYPE_INT,
                              value, &value)) return false;
    *result = (int32_t)value;
    return true;
}

void Memory_initCollectorTest(void)
{
    JbedVm *vm = active();
    if (vm->heap.collector_test_initialized) return;
    int32_t allocations, runtime, seed;
    if (!property(vm, "GC.TEST.PROB", 0, &allocations) ||
        !property(vm, "GC.TEST.RUNTIMEPROB", 2, &runtime)) return;
    Memory_setCollectorTestProbabilities(allocations, runtime);
    if (!property(vm, "GC.TEST.SEED", (int32_t)CPL_os_getMillisSince1970(), &seed)) return;
    char text[64];
    snprintf(text, sizeof(text), "GC test seed: %d\n", seed);
    log_message(text);
    vm->heap.collector_test_seed = (uint64_t)(int64_t)seed;
    vm->heap.collector_test_initialized = true;
}

void Memory_runtimeCollectorTest(void)
{
    JbedVmHeap *heap = &active()->heap;
    jbed_vm_collector_test(heap, heap->runtime_collector_test_threshold);
}

void Memory_enableHeapTracing(void) { active()->heap.trace_usage = true; }

void Memory_sampleHeapUsage(void)
{
    JbedVmHeap *heap = &active()->heap;
    if (heap->trace_usage && heap->usage > heap->max_total_usage)
        heap->max_total_usage = heap->usage;
}

void Memory_resetHeapUsageMaximums(void)
{
    JbedVmHeap *heap = &active()->heap;
    heap->max_total_usage = heap->max_vm_usage = 0;
}

/* These two switches have no effect in this collector configuration. */
void Memory_setGCRunning(bool running) { (void)running; }
bool Memory_setYGAllocation(bool enabled) { (void)enabled; return false; }

void Memory_shrinkHeap(void)
{
    JbedVm *vm = active();
    JbedVmHeap *heap = &vm->heap;
    if (!jbed_vm_heap_sort_chunks(heap, true))
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    Memory_runCompactorOldest(true);
    for (JbedAddress chunk = heap->first_chunk; chunk;) {
        JbedAddress next = jbed_vm_word(heap->memory, chunk + 24);
        if (!jbed_vm_heap_release_empty_chunk(heap, chunk) && heap->fault)
            jbed_vm_fatal(vm, "HeapChunk.release: inconsistent free list");
        chunk = next;
    }
    if (!jbed_vm_heap_sort_chunks(heap, false))
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
}

void Memory_shutdownGC(void) { jbed_vm_shutdown_collector(active()); }

void Memory_shutdownMemory(void)
{
    JbedVm *vm = active();
    JbedAddress frame = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Base", "nativeCallStateFrame");
    if (frame) jbed_vm_put_word(vm->heap.memory, frame, 0);
    Jbed_nativeCallStateAdr = NULL;
    vm->native_roots_top = NULL;
    jbed_vm_heap_shutdown(&vm->heap);
}
