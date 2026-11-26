#include "vm_monitor.h"
#include "vm_scheduler.h"
#include <string.h>

enum {
    OBJECT_SYNC = 8, ARRAY_DATA = 16, ROM_SYNC_INDEX = 1,
    NANOS_PER_MILLI = 1000000, MICROS_PER_MILLI = 1000, NANOS_PER_MICRO = 1000,
    SYNC_TABLE = 952, SYNCHRONIZER_TAG = 0x320100,
    SYNC_CLASS = 0x2105a0, SYNC_ARRAY_CLASS = 0x25e580, ROM_SYNC_SLOTS = 0xab394,
    ILLEGAL_MONITOR_ERROR = 0x320050, OUT_OF_MEMORY_ERROR = 0x320078
};

/* SysInfo.init 0xeb036 copies the startup block at 0xab338 to the VM globals.
 * SysInfo.getSyncTableSize 0xeb0a8 reads its fixed field at offset 0x5c. */
uint32_t jbed_vm_monitor_rom_slots(const JbedVmMonitors *vm)
{
    return vm->image.rom_slots;
}

/* Isolate.initIsolate 0xdd0dc creates a fresh monitor array for each isolate. */
bool jbed_vm_monitors_init_image(JbedVmMonitors *vm, JbedVmHeap *heap, JbedAddress statics,
                                 JbedVmMonitorImage image)
{
    *vm = (JbedVmMonitors){.heap = heap, .isolate_statics = statics, .image = image};
    JbedAddress table = jbed_vm_new_array(heap, (int32_t)jbed_vm_monitor_rom_slots(vm),
                                         image.synchronizer_array_class);
    if (table)
        jbed_vm_put_word(heap->memory, image.table_slot, table);
    return table != 0;
}

bool jbed_vm_monitors_init(JbedVmMonitors *vm, JbedVmHeap *heap, JbedAddress base,
                           JbedAddress statics)
{
    JbedVmMonitorImage image = {base + SYNC_CLASS, base + SYNC_ARRAY_CLASS,
        base + SYNCHRONIZER_TAG, base + ILLEGAL_MONITOR_ERROR, base + OUT_OF_MEMORY_ERROR,
        statics + SYNC_TABLE, jbed_vm_word(heap->memory, base + ROM_SYNC_SLOTS),
        statics + CURRENT, statics + RTROOT, statics + SCHEDULER_TIME,
        statics + TIMER_LOW, statics + TIMER_HIGH};
    return jbed_vm_monitors_init_image(vm, heap, statics, image);
}

/* Isolate.extendSynchArray 0xdd180 replaces the array even when delta is zero. */
JbedErrorKind jbed_vm_monitor_extend_table(JbedVmMonitors *vm, int32_t delta)
{
    JbedBuffer m = vm->heap->memory;
    JbedAddress slot = vm->image.table_slot, old = jbed_vm_word(m, slot);
    if (!old)
        return JBED_ERROR_NULL_POINTER;
    uint32_t count = jbed_vm_word(m, old + 12);
    int32_t length = (int32_t)(count + (uint32_t)delta);
    JbedVmHeapRoot source = {old, old, vm->heap->temporary_roots};
    vm->heap->temporary_roots = &source;
    JbedAddress table = jbed_vm_new_array(vm->heap, length, vm->image.synchronizer_array_class);
    vm->heap->temporary_roots = source.previous;
    if (!table) {
        if (vm->heap->fault == JBED_HEAP_NEGATIVE_ARRAY)
            return JBED_ERROR_NEGATIVE_ARRAY_SIZE;
        return vm->heap->fault == JBED_HEAP_OUT_OF_MEMORY ? JBED_ERROR_OUT_OF_MEMORY
                                                         : JBED_ERROR_INTERNAL;
    }
    if (count > (uint32_t)length)
        return JBED_ERROR_ARRAY_INDEX;
    memcpy(jbed_vm_at(m, table + ARRAY_DATA), jbed_vm_at(m, source.value + ARRAY_DATA),
           (size_t)count * 4);
    jbed_vm_put_word(m, slot, table);
    return JBED_ERROR_NONE;
}

static JbedAddress table_slot(const JbedVmMonitors *vm, int32_t index)
{
    JbedBuffer m = vm->heap->memory;
    return jbed_vm_word(m, vm->image.table_slot) + ARRAY_DATA + (uint32_t)index * 4;
}

static JbedAddress sync_link(const JbedVmMonitors *vm, JbedAddress object)
{
    JbedBuffer m = vm->heap->memory;
    uint32_t link = jbed_vm_word(m, object + OBJECT_SYNC);
    return link & ROM_SYNC_INDEX ? jbed_vm_word(m, table_slot(vm, (int32_t)link >> 1)) : link;
}

static bool isSynchronizer(const JbedVmMonitors *vm, JbedAddress link)
{
    JbedBuffer m = vm->heap->memory;
    return link && jbed_vm_word(m, link) == jbed_vm_word(m, vm->image.synchronizer_tag_slot);
}

static void set_recursions(JbedBuffer m, JbedAddress sync, uint16_t depth)
{
    uint8_t *p = jbed_vm_at(m, sync + SYNC_FIELD(recursions));
    p[0] = (uint8_t)depth;
    p[1] = (uint8_t)(depth >> 8);
}

/* Synchronizer.JEnter0, 0x1302fa. */
static JbedVmMonitorResult JEnter0(JbedVmMonitors *vm, JbedAddress sync, JbedAddress thread)
{
    JbedBuffer m = vm->heap->memory;
    if (!(*jbed_vm_at(m, sync + SYNC_FIELD(bitset)) & LOCKED)) {
        *jbed_vm_at(m, sync + SYNC_FIELD(bitset)) |= LOCKED;
        jbed_vm_put_word(m, sync + SYNC_FIELD(owner), thread);
        jbed_vm_put_word(m, sync + SYNC_FIELD(nextOwned), jbed_vm_word(m, thread + SCHEDULED_FIELD(owned)));
        jbed_vm_put_word(m, thread + SCHEDULED_FIELD(owned), sync);
        return JBED_MONITOR_DONE;
    }
    int32_t priority = (int32_t)jbed_vm_word(m, thread + SCHEDULED_FIELD(prio));
    for (JbedAddress held = sync; held;) {
        JbedAddress owner = jbed_vm_word(m, held + SYNC_FIELD(owner));
        if (priority <= (int32_t)jbed_vm_word(m, owner + SCHEDULED_FIELD(prio)))
            break;
        *jbed_vm_at(m, held + SYNC_FIELD(bitset)) |= DI;
        xSetPriority(vm, owner, priority);
        held = jbed_vm_word(m, owner + SCHEDULED_FIELD(blockedBy));
    }
    xRTInsertBlocking(m, thread, sync);
    return xWait(vm);
}

/* Synchronizer.xEnter, 0x1303a6. Clear recursions after JEnter0 resumes. */
static JbedVmMonitorResult xEnter(JbedVmMonitors *vm, JbedAddress sync, JbedAddress thread)
{
    JbedBuffer m = vm->heap->memory;
    if (jbed_vm_word(m, sync + SYNC_FIELD(owner)) == thread) {
        set_recursions(m, sync, jbed_vm_half(m, sync + SYNC_FIELD(recursions)) + 1);
        return JBED_MONITOR_DONE;
    }
    JbedVmHeapRoot self = {sync, sync, vm->heap->temporary_roots};
    vm->heap->temporary_roots = &self;
    JbedVmMonitorResult result = JEnter0(vm, sync, thread);
    vm->heap->temporary_roots = self.previous;
    if (result == JBED_MONITOR_DONE)
        set_recursions(m, self.value, 0);
    return result;
}

/* Base.allocSynchronizer, 0xe2708. A competing allocation can win during newObject.
 * This method then returns null; enter2 reloads the winning lock from the object. */
static JbedVmMonitorResult allocSynchronizer(JbedVmMonitors *vm, JbedAddress *object,
                                              JbedAddress *result)
{
    JbedVmHeap *heap = vm->heap;
    JbedBuffer m = heap->memory;
    uint32_t header = jbed_vm_word(m, *object + OBJECT_SYNC);
    int32_t index = (header & ROM_SYNC_INDEX) ? (int32_t)header >> 1 : -1;
    JbedAddress previous = (header & ROM_SYNC_INDEX) ? jbed_vm_word(m, table_slot(vm, index)) : header;
    if (isSynchronizer(vm, previous)) {
        *result = previous;
        return JBED_MONITOR_DONE;
    }
    JbedVmHeapRoot root = {*object, *object, heap->temporary_roots};
    heap->temporary_roots = &root;
    JbedAddress fresh = jbed_vm_new_object(heap, vm->image.synchronizer_class);
    heap->temporary_roots = root.previous;
    *object = root.value;
    if (!fresh)
        return JBED_MONITOR_ALLOCATION_FAILED;
    JbedAddress slot = index >= 0 ? table_slot(vm, index) : root.value + OBJECT_SYNC;
    previous = jbed_vm_word(m, slot);
    if (previous && isSynchronizer(vm, previous)) {
        *result = 0;
    } else {
        if (previous)
            xEnter(vm, fresh, previous);
        jbed_vm_put_word(m, slot, fresh);
        *result = fresh;
    }
    return JBED_MONITOR_DONE;
}

/* Base.getSynchronizer, 0xe27b4, and Base.lockedByCurrent, 0xe26ac. */
static JbedVmMonitorResult getSynchronizer(JbedVmMonitors *vm, JbedAddress object, bool allocate,
                                            JbedAddress *result)
{
    if (!object)
        return JBED_MONITOR_NULL_POINTER;
    JbedAddress link = sync_link(vm, object);
    if (isSynchronizer(vm, link)) {
        *result = link;
        return JBED_MONITOR_DONE;
    }
    if (allocate)
        return allocSynchronizer(vm, &object, result);
    *result = 0;
    return JBED_MONITOR_DONE;
}

static bool lockedByCurrent(JbedVmMonitors *vm, JbedAddress object)
{
    JbedBuffer m = vm->heap->memory;
    JbedAddress owner = sync_link(vm, object);
    if (!owner)
        return false;
    if (isSynchronizer(vm, owner))
        owner = jbed_vm_word(m, owner + SYNC_FIELD(owner));
    return owner == jbed_vm_word(m, vm->image.current_slot);
}

JbedVmMonitorResult jbed_vm_get_synchronizer(JbedVmMonitors *vm, JbedAddress object,
                                             bool allocate, JbedAddress *result)
{
    return getSynchronizer(vm, object, allocate, result);
}

JbedVmMonitorResult jbed_vm_alloc_synchronizer(JbedVmMonitors *vm, JbedAddress *object,
                                               JbedAddress *result)
{
    return allocSynchronizer(vm, object, result);
}

bool jbed_vm_locked_by_current(JbedVmMonitors *vm, JbedAddress object)
{
    return lockedByCurrent(vm, object);
}

/* Base.enter2, 0xe2840. ROM objects keep their per-isolate slot index in the header. */
static JbedVmMonitorResult enter2(JbedVmMonitors *vm, JbedAddress object, uint32_t header,
                                  JbedAddress thread)
{
    JbedBuffer m = vm->heap->memory;
    int32_t index = (int32_t)header >> 1;
    JbedAddress lock = header;
    if (header & ROM_SYNC_INDEX) {
        JbedAddress slot = table_slot(vm, index);
        lock = jbed_vm_word(m, slot);
        if (!lock) {
            jbed_vm_put_word(m, slot, thread);
            return JBED_MONITOR_DONE;
        }
    }
    if (!isSynchronizer(vm, lock)) {
        JbedVmHeapRoot caller = {thread, thread, vm->heap->temporary_roots};
        vm->heap->temporary_roots = &caller;
        JbedVmMonitorResult allocated = allocSynchronizer(vm, &object, &lock);
        vm->heap->temporary_roots = caller.previous;
        if (allocated != JBED_MONITOR_DONE)
            return allocated;
        thread = caller.value;
    }
    lock = jbed_vm_word(m, (header & ROM_SYNC_INDEX) ? table_slot(vm, index) : object + OBJECT_SYNC);
    return xEnter(vm, lock, thread);
}

/* ArchBase.enter, 0xe03b8. */
JbedVmMonitorResult jbed_vm_monitor_enter(JbedVmMonitors *vm, JbedAddress object)
{
    if (!object)
        return JBED_MONITOR_NULL_POINTER;
    JbedBuffer m = vm->heap->memory;
    JbedAddress thread = jbed_vm_word(m, vm->image.current_slot);
    uint32_t header = jbed_vm_word(m, object + OBJECT_SYNC);
    if (header)
        return enter2(vm, object, header, thread);
    jbed_vm_put_word(m, object + OBJECT_SYNC, thread);
    return JBED_MONITOR_DONE;
}

/* Synchronizer.JExit0, 0x1303d8. The blockingQ link of the new owner survives handoff. */
static void JExit0(JbedVmMonitors *vm, JbedAddress sync)
{
    JbedBuffer m = vm->heap->memory;
    JbedAddress thread = jbed_vm_word(m, vm->image.current_slot);
    JbedAddress held = jbed_vm_word(m, thread + SCHEDULED_FIELD(owned));
    if (held == sync) {
        jbed_vm_put_word(m, thread + SCHEDULED_FIELD(owned), jbed_vm_word(m, sync + SYNC_FIELD(nextOwned)));
        jbed_vm_put_word(m, sync + SYNC_FIELD(nextOwned), 0);
    } else {
        while (held) {
            JbedAddress next = jbed_vm_word(m, held + SYNC_FIELD(nextOwned));
            if (next == sync) {
                jbed_vm_put_word(m, held + SYNC_FIELD(nextOwned), jbed_vm_word(m, sync + SYNC_FIELD(nextOwned)));
                jbed_vm_put_word(m, sync + SYNC_FIELD(nextOwned), 0);
                break;
            }
            held = next;
        }
    }
    if (*jbed_vm_at(m, sync + SYNC_FIELD(bitset)) & DI) {
        *jbed_vm_at(m, sync + SYNC_FIELD(bitset)) &= (uint8_t)~DI;
        int32_t priority = (int32_t)jbed_vm_word(m, thread + SCHEDULED_FIELD(givenPrio));
        for (held = jbed_vm_word(m, thread + SCHEDULED_FIELD(owned)); held; held = jbed_vm_word(m, held + SYNC_FIELD(nextOwned))) {
            JbedAddress blocked = jbed_vm_word(m, held + SYNC_FIELD(blockedQ));
            if (blocked && (int32_t)jbed_vm_word(m, blocked + SCHEDULED_FIELD(prio)) > priority)
                priority = (int32_t)jbed_vm_word(m, blocked + SCHEDULED_FIELD(prio));
        }
        xSetPriority(vm, thread, priority);
    }
    JbedAddress next = jbed_vm_word(m, sync + SYNC_FIELD(blockedQ));
    if (!next) {
        jbed_vm_put_word(m, sync + SYNC_FIELD(owner), 0);
        *jbed_vm_at(m, sync + SYNC_FIELD(bitset)) &= (uint8_t)~LOCKED;
    } else {
        jbed_vm_put_word(m, sync + SYNC_FIELD(blockedQ), jbed_vm_word(m, next + SCHEDULED_FIELD(blockingQ)));
        jbed_vm_put_word(m, next + SCHEDULED_FIELD(blockedBy), 0);
        jbed_vm_put_word(m, sync + SYNC_FIELD(owner), next);
        jbed_vm_put_word(m, sync + SYNC_FIELD(nextOwned), jbed_vm_word(m, next + SCHEDULED_FIELD(owned)));
        jbed_vm_put_word(m, next + SCHEDULED_FIELD(owned), sync);
        xRTInsertSched(vm, next);
    }
}

/* Synchronizer.Exit, 0x130488. */
static JbedVmMonitorResult Exit(JbedVmMonitors *vm, JbedAddress sync)
{
    JbedBuffer m = vm->heap->memory;
    if (jbed_vm_word(m, vm->image.current_slot) != jbed_vm_word(m, sync + SYNC_FIELD(owner)))
        return JBED_MONITOR_ILLEGAL_STATE;
    uint16_t depth = jbed_vm_half(m, sync + SYNC_FIELD(recursions));
    if (depth) {
        set_recursions(m, sync, depth - 1);
        return JBED_MONITOR_DONE;
    }
    JExit0(vm, sync);
    return xYield(vm);
}

/* Base.exit2, 0xe2930. */
static JbedVmMonitorResult exit2(JbedVmMonitors *vm, JbedAddress link, JbedAddress thread)
{
    JbedBuffer m = vm->heap->memory;
    if (link & ROM_SYNC_INDEX) {
        JbedAddress slot = table_slot(vm, (int32_t)link >> 1);
        link = jbed_vm_word(m, slot);
        if (link == thread) {
            jbed_vm_put_word(m, slot, 0);
            return JBED_MONITOR_DONE;
        }
    }
    return isSynchronizer(vm, link) ? Exit(vm, link) : JBED_MONITOR_ILLEGAL_STATE;
}

JbedVmMonitorResult jbed_vm_monitor_exit(JbedVmMonitors *vm, JbedAddress object)
{
    if (!object)
        return JBED_MONITOR_NULL_POINTER;
    JbedBuffer m = vm->heap->memory;
    JbedAddress thread = jbed_vm_word(m, vm->image.current_slot);
    JbedAddress link = jbed_vm_word(m, object + OBJECT_SYNC);
    if (link != thread)
        return exit2(vm, link, thread);
    jbed_vm_put_word(m, object + OBJECT_SYNC, 0);
    return JBED_MONITOR_DONE;
}

/* Base.tryExit, 0xe2a24, uses Synchronizer.TryExit, 0x1304e0. It does not enter
 * the normal exit2 reserved-stack and IllegalMonitorStateException path. */
JbedVmMonitorResult jbed_vm_monitor_unwind(JbedVmMonitors *vm, JbedVmExceptionTransfer *transfer)
{
    JbedBuffer m = vm->heap->memory;
    JbedAddress slot = transfer->handler_or_monitor + OBJECT_SYNC;
    JbedAddress link = jbed_vm_word(m, slot);
    if (link & ROM_SYNC_INDEX) {
        slot = table_slot(vm, (int32_t)link >> 1);
        link = jbed_vm_word(m, slot);
    }
    JbedAddress thread = jbed_vm_word(m, vm->image.current_slot);
    if (link == thread) {
        jbed_vm_put_word(m, slot, 0);
    } else if (isSynchronizer(vm, link) && jbed_vm_word(m, link + SYNC_FIELD(owner)) == thread) {
        return Exit(vm, link);
    } else if (transfer->throwable != jbed_vm_word(m, vm->image.out_of_memory_error_slot)) {
        transfer->throwable = jbed_vm_word(m, vm->image.illegal_monitor_error_slot);
    }
    return JBED_MONITOR_DONE;
}

/* Synchronizer.Notify, 0x1304fe. The priority donation is a direct field store. */
static JbedVmMonitorResult Notify(JbedVmMonitors *vm, JbedAddress sync)
{
    JbedBuffer m = vm->heap->memory;
    JbedAddress current = jbed_vm_word(m, vm->image.current_slot);
    if (current != jbed_vm_word(m, sync + SYNC_FIELD(owner)))
        return JBED_MONITOR_ILLEGAL_STATE;
    JbedAddress waiter = jbed_vm_word(m, sync + SYNC_FIELD(waitedQ));
    if (waiter) {
        jbed_vm_put_word(m, sync + SYNC_FIELD(waitedQ), jbed_vm_word(m, waiter + SCHEDULED_FIELD(waitingQ)));
        jbed_vm_put_word(m, waiter + SCHEDULED_FIELD(waitingFor), 0);
        jbed_vm_put_word(m, waiter + SCHEDULED_FIELD(waitingQ), 0);
        int32_t priority = (int32_t)jbed_vm_word(m, waiter + SCHEDULED_FIELD(prio));
        if ((int32_t)jbed_vm_word(m, current + SCHEDULED_FIELD(prio)) < priority) {
            *jbed_vm_at(m, sync + SYNC_FIELD(bitset)) |= DI;
            jbed_vm_put_word(m, current + SCHEDULED_FIELD(prio), (uint32_t)priority);
        }
        if (*jbed_vm_at(m, waiter + SCHEDULED_FIELD(timeoutF)))
            xRTRemoveTimeout(m, waiter);
        if (!*jbed_vm_at(m, waiter + SCHEDULED_FIELD(schedF)))
            xRTInsertSched(vm, waiter);
    }
    return JBED_MONITOR_DONE;
}

/* java.lang.Object.notify/notifyAll, 0xadcac/0xadce4; Synchronizer.NotifyAll, 0x130584. */
JbedVmMonitorResult jbed_vm_monitor_notify(JbedVmMonitors *vm, JbedAddress object, bool all)
{
    if (!object)
        return JBED_MONITOR_NULL_POINTER;
    if (!lockedByCurrent(vm, object))
        return JBED_MONITOR_ILLEGAL_STATE;
    JbedAddress sync;
    getSynchronizer(vm, object, false, &sync);
    if (!sync)
        return JBED_MONITOR_DONE;
    if (!all)
        return Notify(vm, sync);
    while (jbed_vm_word(vm->heap->memory, sync + SYNC_FIELD(waitedQ))) {
        JbedVmMonitorResult result = Notify(vm, sync);
        if (result != JBED_MONITOR_DONE)
            return result;
    }
    return JBED_MONITOR_DONE;
}

/* Synchronizer.Wait(long, boolean), 0x1305a6. The saved recursions belong to
 * this wait invocation. Other owners can use the synchronizer while it sleeps. */
static JbedVmMonitorResult Wait(JbedVmMonitors *vm, JbedAddress sync, uint64_t timeout,
                                bool interruptible)
{
    JbedVmHeap *heap = vm->heap;
    JbedBuffer m = heap->memory;
    JbedAddress current = jbed_vm_word(m, vm->image.current_slot);
    if (current != jbed_vm_word(m, sync + SYNC_FIELD(owner)))
        return JBED_MONITOR_ILLEGAL_STATE;
    uint16_t depth = jbed_vm_half(m, sync + SYNC_FIELD(recursions));
    if (!*jbed_vm_at(m, current + SCHEDULED_FIELD(interrupted)) || !interruptible) {
        assert(vm->scheduling.yield_to_scheduler);
        JbedVmHeapRoot self = {sync, sync, heap->temporary_roots};
        JbedVmHeapRoot thread = {current, current, &self};
        heap->temporary_roots = &thread;
        *jbed_vm_at(m, current + SCHEDULED_FIELD(interruptible)) = interruptible;
        xRTInsertWaiting(m, current, sync);
        if (timeout)
            xRTInsertTO(vm, current, timeout);
        JExit0(vm, sync);
        xWait(vm);
        if (timeout && jbed_vm_word(m, self.value + SYNC_FIELD(waitedQ)))
            xRTRemoveWaiting(vm, thread.value, self.value);
        JEnter0(vm, self.value, thread.value);
        *jbed_vm_at(m, thread.value + SCHEDULED_FIELD(interruptible)) = 0;
        sync = self.value;
        heap->temporary_roots = self.previous;
    }
    set_recursions(m, sync, depth);
    return JBED_MONITOR_DONE;
}

JbedVmMonitorResult jbed_vm_monitor_wait(JbedVmMonitors *vm, JbedAddress object,
                                        int64_t millis, int32_t nanos)
{
    if (!object)
        return JBED_MONITOR_NULL_POINTER;
    if (millis < 0 || nanos < 0 || nanos >= NANOS_PER_MILLI)
        return JBED_MONITOR_ILLEGAL_ARGUMENT;
    if (!lockedByCurrent(vm, object))
        return JBED_MONITOR_ILLEGAL_STATE;
    if (millis > INT64_MAX / MICROS_PER_MILLI) {
        millis = INT64_MAX / MICROS_PER_MILLI;
        nanos = 0;
    }
    JbedAddress sync;
    JbedVmMonitorResult result = getSynchronizer(vm, object, true, &sync);
    if (result != JBED_MONITOR_DONE)
        return result;
    if (!sync)
        return JBED_MONITOR_NULL_POINTER;
    uint64_t timeout = (uint64_t)millis * MICROS_PER_MILLI + (uint32_t)nanos / NANOS_PER_MICRO;
    result = Wait(vm, sync, timeout, true);
    if (result != JBED_MONITOR_DONE)
        return result;
    JbedBuffer m = vm->heap->memory;
    JbedAddress current = jbed_vm_word(m, vm->image.current_slot);
    if (*jbed_vm_at(m, current + SCHEDULED_FIELD(interrupted))) {
        *jbed_vm_at(m, current + SCHEDULED_FIELD(interrupted)) = 0;
        return JBED_MONITOR_INTERRUPTED;
    }
    return JBED_MONITOR_DONE;
}
