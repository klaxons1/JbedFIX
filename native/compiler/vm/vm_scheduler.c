#include "vm_scheduler.h"

#include <stdlib.h>

static int32_t priority(JbedBuffer m, JbedAddress thread)
{
    return (int32_t)jbed_vm_word(m, thread + SCHEDULED_FIELD(prio));
}

static void halt(JbedVmMonitors *vm, JbedAddress thread, const char *message)
{
    if (vm->scheduling.runtime)
        jbed_halt(vm->scheduling.runtime, (int32_t)thread, message);
    abort();
}

/* Scheduler.xRTInsertSched, 0xe5a28. rtroot is a sentinel Scheduled. */
void xRTInsertSched(JbedVmMonitors *vm, JbedAddress thread)
{
    JbedBuffer m = vm->heap->memory;
    if (*jbed_vm_at(m, thread + SCHEDULED_FIELD(schedF)))
        halt(vm, thread, "xRTInsertSched: Attempting to re-insert in ready list");
    JbedAddress prev = jbed_vm_word(m, vm->image.ready_root_slot);
    JbedAddress next = jbed_vm_word(m, prev + SCHEDULED_FIELD(nextScheduled));
    while (next) {
        if (thread == next)
            halt(vm, thread, "xRTInsertSched: Re-inserting in ready list");
        if (priority(m, next) < priority(m, thread))
            break;
        prev = next;
        next = jbed_vm_word(m, prev + SCHEDULED_FIELD(nextScheduled));
    }
    *jbed_vm_at(m, thread + SCHEDULED_FIELD(schedF)) = 1;
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(nextScheduled), next);
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(prevScheduled), prev);
    jbed_vm_put_word(m, prev + SCHEDULED_FIELD(nextScheduled), thread);
    if (next)
        jbed_vm_put_word(m, next + SCHEDULED_FIELD(prevScheduled), thread);
}

/* Scheduler.xRTRemoveSched, 0xe5ca0. */
void xRTRemoveSched(JbedVmMonitors *vm, JbedAddress thread)
{
    JbedBuffer m = vm->heap->memory;
    if (!*jbed_vm_at(m, thread + SCHEDULED_FIELD(schedF)))
        halt(vm, thread, "xRTRemoveSched: t.schedF == false");
    *jbed_vm_at(m, thread + SCHEDULED_FIELD(schedF)) = 0;
    JbedAddress prev = jbed_vm_word(m, thread + SCHEDULED_FIELD(prevScheduled));
    JbedAddress next = jbed_vm_word(m, thread + SCHEDULED_FIELD(nextScheduled));
    jbed_vm_put_word(m, prev + SCHEDULED_FIELD(nextScheduled), next);
    if (next)
        jbed_vm_put_word(m, next + SCHEDULED_FIELD(prevScheduled), prev);
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(nextScheduled), 0);
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(prevScheduled), 0);
}

void xRTReSched(JbedVmMonitors *vm, JbedAddress thread)
{
    xRTRemoveSched(vm, thread);
    xRTInsertSched(vm, thread);
}

/* Scheduler.xRTInsertBlocking, 0xe58ec. */
void xRTInsertBlocking(JbedBuffer m, JbedAddress thread, JbedAddress sync)
{
    JbedAddress previous = jbed_vm_word(m, sync + SYNC_FIELD(blockedQ));
    if (!previous || priority(m, thread) > priority(m, previous)) {
        jbed_vm_put_word(m, thread + SCHEDULED_FIELD(blockingQ), previous);
        jbed_vm_put_word(m, sync + SYNC_FIELD(blockedQ), thread);
    } else {
        JbedAddress next;
        while ((next = jbed_vm_word(m, previous + SCHEDULED_FIELD(blockingQ))) &&
               priority(m, thread) <= priority(m, next))
            previous = next;
        jbed_vm_put_word(m, thread + SCHEDULED_FIELD(blockingQ), next);
        jbed_vm_put_word(m, previous + SCHEDULED_FIELD(blockingQ), thread);
    }
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(blockedBy), sync);
}

/* Scheduler.xRemoveBlocking, 0xe5bf0. */
static void xRemoveBlocking(JbedBuffer m, JbedAddress thread, JbedAddress sync)
{
    JbedAddress previous = jbed_vm_word(m, sync + SYNC_FIELD(blockedQ));
    if (previous == thread) {
        jbed_vm_put_word(m, sync + SYNC_FIELD(blockedQ), jbed_vm_word(m, thread + SCHEDULED_FIELD(blockingQ)));
    } else {
        while (previous && jbed_vm_word(m, previous + SCHEDULED_FIELD(blockingQ)) != thread)
            previous = jbed_vm_word(m, previous + SCHEDULED_FIELD(blockingQ));
        if (!previous)
            return;
        jbed_vm_put_word(m, previous + SCHEDULED_FIELD(blockingQ), jbed_vm_word(m, thread + SCHEDULED_FIELD(blockingQ)));
    }
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(blockedBy), 0);
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(blockingQ), 0);
}

/* Scheduler.xRTInsertWaiting, 0xe5b70. */
void xRTInsertWaiting(JbedBuffer m, JbedAddress thread, JbedAddress sync)
{
    JbedAddress previous = jbed_vm_word(m, sync + SYNC_FIELD(waitedQ));
    if (!previous || priority(m, thread) > priority(m, previous)) {
        jbed_vm_put_word(m, thread + SCHEDULED_FIELD(waitingQ), previous);
        jbed_vm_put_word(m, sync + SYNC_FIELD(waitedQ), thread);
    } else {
        JbedAddress next;
        while ((next = jbed_vm_word(m, previous + SCHEDULED_FIELD(waitingQ))) &&
               priority(m, thread) <= priority(m, next))
            previous = next;
        jbed_vm_put_word(m, thread + SCHEDULED_FIELD(waitingQ), next);
        jbed_vm_put_word(m, previous + SCHEDULED_FIELD(waitingQ), thread);
    }
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(waitingFor), sync);
}

/* 0xe5d5a. The original reads previous.waitingQ on entering the search. */
void xRTRemoveWaiting(JbedVmMonitors *vm, JbedAddress thread, JbedAddress sync)
{
    JbedBuffer m = vm->heap->memory;
    JbedAddress previous = jbed_vm_word(m, sync + SYNC_FIELD(waitedQ));
    if (previous == thread) {
        jbed_vm_put_word(m, sync + SYNC_FIELD(waitedQ), jbed_vm_word(m, thread + SCHEDULED_FIELD(waitingQ)));
    } else {
        if (!previous) {
            const JbedError e = {.kind = JBED_ERROR_NULL_POINTER};
            if (vm->scheduling.runtime)
                jbed_raise(vm->scheduling.runtime, &e);
            abort();
        }
        JbedAddress next;
        while ((next = jbed_vm_word(m, previous + SCHEDULED_FIELD(waitingQ))) && next != thread)
            previous = next;
        if (!next)
            return;
        jbed_vm_put_word(m, previous + SCHEDULED_FIELD(waitingQ), jbed_vm_word(m, thread + SCHEDULED_FIELD(waitingQ)));
    }
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(waitingFor), 0);
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(waitingQ), 0);
}

/* Scheduler.xSetPriority, 0xe5e94. */
void xSetPriority(JbedVmMonitors *vm, JbedAddress thread, int32_t value)
{
    JbedBuffer m = vm->heap->memory;
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(prio), (uint32_t)value);
    if (*jbed_vm_at(m, thread + SCHEDULED_FIELD(schedF)))
        xRTReSched(vm, thread);
    JbedAddress waiting = jbed_vm_word(m, thread + SCHEDULED_FIELD(waitingFor));
    if (waiting) {
        xRTRemoveWaiting(vm, thread, waiting);
        xRTInsertWaiting(m, thread, waiting);
    }
    JbedAddress blocking = jbed_vm_word(m, thread + SCHEDULED_FIELD(blockedBy));
    if (blocking) {
        xRemoveBlocking(m, thread, blocking);
        xRTInsertBlocking(m, thread, blocking);
    }
}

static void xRTInsertTimeout(JbedVmMonitors *vm, JbedAddress thread)
{
    JbedBuffer m = vm->heap->memory;
    if (*jbed_vm_at(m, thread + SCHEDULED_FIELD(timeoutF)))
        return;
    JbedAddress head = jbed_vm_word(m, vm->image.ready_root_slot);
    JbedAddress next = jbed_vm_word(m, head + SCHEDULED_FIELD(nextTimeout));
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(nextTimeout), next);
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(prevTimeout), head);
    jbed_vm_put_word(m, head + SCHEDULED_FIELD(nextTimeout), thread);
    if (next)
        jbed_vm_put_word(m, next + SCHEDULED_FIELD(prevTimeout), thread);
    *jbed_vm_at(m, thread + SCHEDULED_FIELD(timeoutF)) = 1;
}

void xRTRemoveTimeout(JbedBuffer m, JbedAddress thread)
{
    if (!*jbed_vm_at(m, thread + SCHEDULED_FIELD(timeoutF)))
        return;
    JbedAddress prev = jbed_vm_word(m, thread + SCHEDULED_FIELD(prevTimeout));
    JbedAddress next = jbed_vm_word(m, thread + SCHEDULED_FIELD(nextTimeout));
    jbed_vm_put_word(m, prev + SCHEDULED_FIELD(nextTimeout), next);
    if (next)
        jbed_vm_put_word(m, next + SCHEDULED_FIELD(prevTimeout), prev);
    *jbed_vm_at(m, thread + SCHEDULED_FIELD(timeoutF)) = 0;
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(nextTimeout), 0);
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(prevTimeout), 0);
}

static uint64_t read_long(JbedBuffer m, JbedAddress address)
{
    return jbed_vm_word(m, address) | ((uint64_t)jbed_vm_word(m, address + 4) << 32);
}

static void write_long(JbedBuffer m, JbedAddress address, uint64_t value)
{
    jbed_vm_put_word(m, address, (uint32_t)value);
    jbed_vm_put_word(m, address + 4, (uint32_t)(value >> 32));
}

/* Scheduler.xRTInsertTO, 0xe5b00. Scheduled.setEvent at 0x1301de stores the deadline. */
void xRTInsertTO(JbedVmMonitors *vm, JbedAddress thread, uint64_t delay)
{
    JbedBuffer m = vm->heap->memory;
    uint64_t deadline = vm->scheduling.elapsed_micros(vm->scheduling.context) + delay;
    if (deadline > INT64_MAX)
        deadline = INT64_MAX;
    write_long(m, thread + SCHEDULED_FIELD(timeout), deadline);
    if (!*jbed_vm_at(m, thread + SCHEDULED_FIELD(timeoutF)))
        xRTInsertTimeout(vm, thread);
}

/* Scheduler.xElapsed, 0xe5e26. */
void xElapsed(JbedVmMonitors *vm)
{
    JbedBuffer m = vm->heap->memory;
    JbedAddress thread = jbed_vm_word(m, vm->image.current_slot);
    uint64_t time = vm->scheduling.elapsed_micros(vm->scheduling.context);
    uint64_t elapsed = time - read_long(m, vm->image.time_slot);
    write_long(m, thread + SCHEDULED_FIELD(running), read_long(m, thread + SCHEDULED_FIELD(running)) + elapsed);
    write_long(m, vm->image.time_slot, time);
    jbed_vm_put_word(m, vm->image.timer_high_slot, (uint32_t)(time >> 32));
    jbed_vm_put_word(m, vm->image.timer_low_slot, (uint32_t)time);
}

JbedVmMonitorResult xWait(JbedVmMonitors *vm)
{
    if (vm->scheduling.elapsed_micros)
        xElapsed(vm);
    JbedBuffer m = vm->heap->memory;
    JbedAddress thread = jbed_vm_word(m, vm->image.current_slot);
    xRTRemoveSched(vm, thread);
    jbed_vm_put_word(m, thread + SCHEDULED_FIELD(status), S_WAIT);
    if (!vm->scheduling.yield_to_scheduler)
        return JBED_MONITOR_BLOCKED;
    vm->scheduling.yield_to_scheduler(vm->scheduling.context);
    return JBED_MONITOR_DONE;
}

JbedVmMonitorResult xYield(JbedVmMonitors *vm)
{
    if (vm->scheduling.elapsed_micros)
        xElapsed(vm);
    JbedBuffer m = vm->heap->memory;
    JbedAddress thread = jbed_vm_word(m, vm->image.current_slot);
    if (jbed_vm_word(m, thread + SCHEDULED_FIELD(status)) == S_READY)
        jbed_vm_put_word(m, thread + SCHEDULED_FIELD(status), S_SCHED);
    if (!vm->scheduling.yield_to_scheduler)
        return JBED_MONITOR_YIELD;
    vm->scheduling.yield_to_scheduler(vm->scheduling.context);
    return JBED_MONITOR_DONE;
}
