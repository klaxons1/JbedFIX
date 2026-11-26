#include "runtime.h"
#include "scheduler.h"
#include "memory.h"
#include "../compiler/vm/vm_scheduler.h"
#include "../compiler/vm/vm_words.h"

#include <stddef.h>

typedef struct JbedRomSignal {
    uint32_t tag, flags, sync_link;
    JbedAddress next, previous;
    uint8_t waiting, signalled, queued, padding;
    JbedAddress synchronizer, object_argument;
    int32_t argument;
    uint32_t notifier_state, notifier_notify, notifier_invalidate, notifier_timeout;
    JbedAddress async_buffer;
    uint32_t vm_ref;
} JbedRomSignal;

typedef struct JbedRomSignalQueue {
    JbedRomSignal signal;
    JbedAddress events, event_data;
    uint32_t write_index, read_index;
} JbedRomSignalQueue;

_Static_assert(sizeof(JbedRomSignal) == 60, "Signal managed layout");
_Static_assert(offsetof(JbedRomSignalQueue, read_index) == 72, "SignalQueue managed layout");

static JbedVmSignalHub *native_signals;
VmNotifier *JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier;

void jbed_vm_signals_install(JbedVmSignalHub *hub) { native_signals = hub; }
void jbed_vm_signals_uninstall(JbedVmSignalHub *hub)
{
    if (native_signals == hub) native_signals = NULL;
}

static void signal_isolate(JbedVmSignalHub *hub, unsigned vm_ref, unsigned flags)
{
    if (!hub || vm_ref >= JBED_MAX_ISOLATES)
        jbed_vm_fatal(jbed_vm_current(), "Signal refers to an invalid isolate slot");
    atomic_fetch_or_explicit(&hub->pending[vm_ref], (unsigned char)flags, memory_order_release);
    jbed_vm_scheduler_wake(hub->isolates[vm_ref]);
}

unsigned jbed_vm_take_signal_flags(JbedVmSignalHub *hub, unsigned vm_ref)
{
    if (vm_ref >= JBED_MAX_ISOLATES)
        jbed_vm_fatal(jbed_vm_current(), "Invalid isolate slot");
    return atomic_exchange_explicit(&hub->pending[vm_ref], 0, memory_order_acquire);
}

static void send_signal(JbedRomSignal *signal, bool fast)
{
    signal->signalled = 1;
    signal_isolate(native_signals, signal->vm_ref, fast ? JBED_SIGNAL_FAST : JBED_SIGNAL_NORMAL);
}

JbedAddress SignalQueue_getAsyncRef(JbedAddress address)
{
    JbedVm *vm = jbed_vm_current();
    JbedRomSignalQueue *queue = (JbedRomSignalQueue *)jbed_vm_at(vm->heap.memory, address);
    if (!Memory_isLocked(queue->events))
        jbed_vm_fatal(vm, "Signal queue event array is not locked");
    if (!Memory_isLocked(address))
        jbed_vm_fatal(vm, "Signal queue is not locked");
    queue->event_data = queue->events + sizeof(JbArray);
    return address;
}

void SuperScheduler_asyncSignalIsolate(int32_t isolate, bool fast)
{
    JbedVm *vm = jbed_vm_current();
    signal_isolate(vm->signals.hub, (unsigned)isolate, fast ? JBED_SIGNAL_FAST : JBED_SIGNAL_NORMAL);
}

void Jbed_signal(VmSignal *signal) { send_signal((JbedRomSignal *)signal, false); }
void Jbed_signalFast(VmSignal *signal) { send_signal((JbedRomSignal *)signal, true); }

void Jbed_signalArg(VmSignal *signal, int argument)
{
    JbedRomSignal *s = (JbedRomSignal *)signal;
    s->argument = argument;
    send_signal(s, false);
}

void Jbed_signalArgFast(VmSignal *signal, int argument)
{
    JbedRomSignal *s = (JbedRomSignal *)signal;
    s->argument = argument;
    send_signal(s, true);
}

void Jbed_signalObjectArg(VmSignal *signal, JbRef argument)
{
    JbedRomSignal *s = (JbedRomSignal *)signal;
    s->object_argument = argument;
    send_signal(s, false);
}

void Jbed_signalObjectArgFast(VmSignal *signal, JbRef argument)
{
    JbedRomSignal *s = (JbedRomSignal *)signal;
    s->object_argument = argument;
    send_signal(s, true);
}

VmSignal *JbedExp_getCurrentSignal(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm || !vm->signals.current_thread_slot)
        jbed_vm_fatal(vm, "Signal requested outside a scheduled thread");
    JbedAddress thread = jbed_vm_word(vm->heap.memory, vm->signals.current_thread_slot);
    if (!thread)
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, "No current scheduled thread");
    JbedAddress signal = jbed_vm_word(vm->heap.memory, thread + SCHEDULED_FIELD(signal));
    return signal ? (VmSignal *)jbed_vm_at(vm->heap.memory, signal) : NULL;
}

static JbedRomSignal *signal_at(JbedVm *vm, JbedAddress address)
{
    return (JbedRomSignal *)jbed_vm_at(vm->heap.memory, address);
}

void jbed_vm_signal_insert(JbedVm *vm, JbedAddress address)
{
    JbedRomSignal *signal = signal_at(vm, address);
    if (!signal->queued) {
        JbedAddress previous = jbed_vm_word(vm->heap.memory, vm->signals.queue_slot);
        if (previous)
            signal_at(vm, previous)->previous = address;
        signal->next = previous;
        jbed_vm_put_word(vm->heap.memory, vm->signals.queue_slot, address);
        signal->queued = 1;
    }
}

JbedAddress jbed_vm_signal_remove(JbedVm *vm, JbedAddress address)
{
    JbedRomSignal *signal = signal_at(vm, address);
    JbedAddress next = signal->next, previous = signal->previous;
    if (next)
        signal_at(vm, next)->previous = previous;
    if (previous)
        signal_at(vm, previous)->next = next;
    if (jbed_vm_word(vm->heap.memory, vm->signals.queue_slot) == address)
        jbed_vm_put_word(vm->heap.memory, vm->signals.queue_slot, next);
    signal->next = signal->previous = 0;
    signal->queued = 0;
    return next;
}

static void wake_waiters(JbedVm *vm, JbedAddress synchronizer)
{
    JbedBuffer map = vm->heap.memory;
    JbedAddress thread;
    while ((thread = jbed_vm_word(map, synchronizer + SYNC_FIELD(waitedQ))) != 0) {
        jbed_vm_put_word(map, synchronizer + SYNC_FIELD(waitedQ),
                         jbed_vm_word(map, thread + SCHEDULED_FIELD(waitingQ)));
        jbed_vm_put_word(map, thread + SCHEDULED_FIELD(waitingFor), 0);
        jbed_vm_put_word(map, thread + SCHEDULED_FIELD(waitingQ), 0);
        if (*jbed_vm_at(map, thread + SCHEDULED_FIELD(timeoutF)))
            xRTRemoveTimeout(map, thread);
        if (!*jbed_vm_at(map, thread + SCHEDULED_FIELD(schedF)))
            xRTInsertSched(&vm->monitors, thread);
    }
}

/* RTScheduler leaves an early signal pending until its waiter has entered Wait. */
void jbed_vm_process_signals(JbedVm *vm)
{
    JbedBuffer map = vm->heap.memory;
    uint8_t *pending = jbed_vm_at(map, vm->signals.pending_slot);
    if (!*pending)
        return;
    *pending = 0;
    JbedAddress address = jbed_vm_word(map, vm->signals.queue_slot);
    while (address) {
        JbedRomSignal *signal = signal_at(vm, address);
        if (signal->signalled) {
            if (!signal->synchronizer)
                jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, "Signal has no synchronizer");
            if (jbed_vm_word(map, signal->synchronizer + SYNC_FIELD(waitedQ))) {
                wake_waiters(vm, signal->synchronizer);
                address = jbed_vm_signal_remove(vm, address);
                continue;
            }
            *pending = 1;
        }
        address = signal->next;
    }
}

void jbed_vm_enqueue_raw_event(JbedVmSignalHub *hub, JbedAddress address, uint32_t event)
{
    if (!address)
        return;
    JbedRomSignalQueue *queue = (JbedRomSignalQueue *)jbed_vm_at(hub->memory, address);
    uint32_t write = queue->write_index;
    jbed_vm_put_word(hub->memory, queue->event_data + write * sizeof(uint32_t), event);
    uint32_t next = (write + 1) & (JBED_SIGNAL_EVENT_CAPACITY - 1);
    if (next != queue->read_index) {
        queue->write_index = next;
        if (queue->read_index == write) {
            queue->signal.signalled = 1;
            signal_isolate(hub, queue->signal.vm_ref, JBED_SIGNAL_NORMAL);
        }
    }
}

void Jbed_doRawEvent(void *signal, int event)
{
    (void)signal;
    JbedVmSignalHub *hub = native_signals;
    if (!hub)
        jbed_vm_fatal(jbed_vm_current(), "Raw event delivered before VM initialization");
    uint32_t word = (uint32_t)event;
    JbedAddress queue = hub->raw_event_queue;
    enum { EVENT_TYPE_MASK = 15, TARGETED_EVENT = 8, TARGET_SHIFT = 28 };
    if ((word & EVENT_TYPE_MASK) == TARGETED_EVENT && hub->targeted_event_queues)
        queue = jbed_vm_word(hub->memory,
            hub->targeted_event_queues + 16 + (word >> TARGET_SHIFT) * sizeof(JbedAddress));
    jbed_vm_enqueue_raw_event(hub, queue, word);
}
