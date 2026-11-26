#include "arch.h"
#include "arm32.h"
#include "trace.h"
#include "../compiler/vm/vm_words.h"

#include <string.h>

enum { OBJECT_TAG = 0, ARRAY_LENGTH = 12, ARRAY_DATA = 16, TAG_KIND = 4 };

static uint32_t word(JbedAddress address)
{
    uint32_t value;
    memcpy(&value, (const void *)(uintptr_t)address, sizeof(value));
    return value;
}

void ArchBase_move(JbedAddress source, JbedAddress destination, uint32_t bytes)
{
    if (bytes)
        memmove((void *)(uintptr_t)destination, (const void *)(uintptr_t)source, bytes);
}

void ArchBase_moveRev(JbedAddress source, JbedAddress destination, uint32_t bytes)
{
    ArchBase_move(source, destination, bytes);
}

void ArchBase_zero(JbedAddress destination, uint32_t bytes)
{
    bytes &= ~3u;
    if (bytes)
        memset((void *)(uintptr_t)destination, 0, bytes);
}

void ArchBase_fill(JbedAddress destination, uint32_t pattern, uint32_t bytes)
{
    uint8_t *next = (uint8_t *)(uintptr_t)destination;
    while (bytes && ((uintptr_t)next & 3u)) {
        *next++ = (uint8_t)pattern;
        pattern = pattern >> 8 | pattern << 24;
        --bytes;
    }
    while (bytes >= sizeof(pattern)) {
        memcpy(next, &pattern, sizeof(pattern));
        next += sizeof(pattern);
        bytes -= sizeof(pattern);
    }
    while (bytes--) {
        *next++ = (uint8_t)pattern;
        pattern >>= 8;
    }
}

bool Base_compare(JbedAddress left, JbedAddress right, int32_t bytes)
{
    return bytes <= 0 || !memcmp((const void *)(uintptr_t)left,
                                 (const void *)(uintptr_t)right, (uint32_t)bytes);
}

int32_t Base_arrayLength(JbedAddress array) { return (int32_t)word(array + ARRAY_LENGTH); }
bool Base_isArray(JbedAddress object) { return (int32_t)word(word(object + OBJECT_TAG) - TAG_KIND) < 0; }

int32_t Base_objectSize(JbedAddress object)
{
    uint32_t kind = word(word(object + OBJECT_TAG) - TAG_KIND);
    return (int32_t)((int32_t)kind < 0
        ? (word(object + ARRAY_LENGTH) << (kind & JBED_ARRAY_ELEMENT_SHIFT_MASK)) + ARRAY_DATA
        : kind);
}

static JbedVm *active(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "Runtime operation outside a Jbed VM");
    return vm;
}

bool Base_InstanceOf(JbedAddress object, JbedAddress klass)
{
    JbedVm *vm = active();
    return object && jbed_vm_instance_of(&vm->resident, word(object),
                                         jbed_vm_class_at(&vm->resident, klass));
}

void Base_arraystore(JbedAddress array, int32_t index, JbedAddress value)
{
    JbedVm *vm = active();
    jbed_vm_store_array_ref(&vm->resident, vm->heap.memory, array, index, value, true);
}

int32_t Base_getHashCode(JbedAddress object)
{
    return jbed_vm_identity_hash(&active()->heap, object);
}

bool Base_exceptionInstanceOf(JbedAddress tag, JbedAddress klass)
{
    return jbed_vm_exception_instance_of(active()->exceptions.memory, tag, klass);
}

JbedAddress Base_baseOfJavaStack(void)
{
    JbedVm *vm = active();
    JbedArm32Frame *frame = vm->arm->frame;
    JbedArm32Activation *activation = vm->arm->activations;
    JbedAddress fp = frame->r[7], slot = frame->sp - 8;
    for (;;) {
        while (fp) {
            slot = (fp & ~7u) - 8;
            fp = word(slot);
        }
        while (activation && !activation->caller_frame)
            activation = activation->previous;
        if (!activation) return slot;
        fp = activation->caller_frame->r[7];
        activation = activation->previous;
    }
}

void Base_fillTrace(JbedAddress throwable)
{
    JbedVm *vm = active();
    JbedVmHeapRoot root = {throwable, throwable, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    jbed_vm_fill_throwable_trace(vm, &root.value);
    vm->heap.temporary_roots = root.previous;
}

void Base_fillTraceAt(JbedAddress throwable, JbedAddress pc, JbedAddress fp)
{
    JbedVm *vm = active();
    JbedVmHeapRoot root = {throwable, throwable, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    jbed_vm_fill_trace_at(vm, &root.value, pc, fp);
    vm->heap.temporary_roots = root.previous;
}

static void monitor_result(JbedVm *vm, JbedVmMonitorResult result)
{
    switch (result) {
    case JBED_MONITOR_DONE: return;
    case JBED_MONITOR_NULL_POINTER: jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    case JBED_MONITOR_ALLOCATION_FAILED: jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, NULL);
    default: jbed_vm_fatal(vm, "Synchronizer operation did not resume");
    }
}

JbedAddress Base_getSynchronizer(JbedAddress object, bool allocate)
{
    JbedVm *vm = active();
    JbedAddress result;
    monitor_result(vm, jbed_vm_get_synchronizer(&vm->monitors, object, allocate, &result));
    return result;
}

JbedAddress Base_allocSynchronizer(JbedAddress object)
{
    JbedVm *vm = active();
    JbedAddress result;
    monitor_result(vm, jbed_vm_alloc_synchronizer(&vm->monitors, &object, &result));
    return result;
}

bool Base_lockedByCurrent(JbedAddress object)
{
    JbedVm *vm = active();
    if (!object) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    return jbed_vm_locked_by_current(&vm->monitors, object);
}

JbedAddress Base_tryExit(JbedAddress throwable, JbedAddress monitor)
{
    JbedVm *vm = active();
    JbedVmExceptionTransfer transfer = {.throwable = throwable, .handler_or_monitor = monitor};
    monitor_result(vm, jbed_vm_monitor_unwind(&vm->monitors, &transfer));
    return transfer.throwable;
}

void *Base_hashSeedField(void *runtime) { return &((JbedVm *)runtime)->heap.identity_hash_state; }
void *Base_staticsBaseField(void *runtime) { return &((JbedVm *)runtime)->isolate_statics; }
void *Base_paramPtrField(void *runtime) { (void)runtime; return &Jbed_ParamPtr; }
void *Base_noCatchField(void *runtime) { return &((JbedVm *)runtime)->exceptions.no_catch; }
void *Base_noCatchTagField(void *runtime) { return &((JbedVm *)runtime)->exceptions.no_catch_tag; }
void *Base_stackOVField(void *runtime) { return &((JbedVm *)runtime)->exceptions.stack_overflow; }
void *Base_stackLimitField(void *runtime) { return &((JbedVm *)runtime)->exceptions.stack_limit; }
void *Base_reservedStackLimitField(void *runtime) { return &((JbedVm *)runtime)->exceptions.reserved_stack_limit; }
void *Base_nativeCallStateBaseField(void *runtime) { return &((JbedVm *)runtime)->native_frames.base; }
void *Base_nativeCallStateLimitField(void *runtime) { return &((JbedVm *)runtime)->native_frames.limit; }
void *Base_nativeCallStateAdrField(void *runtime) { return &((JbedVm *)runtime)->native_frames.address; }
void *Base_nativeCallStateFrameField(void *runtime) { return &((JbedVm *)runtime)->native_frames.frame; }
