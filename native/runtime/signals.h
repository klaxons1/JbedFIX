#ifndef JBED_RUNTIME_SIGNALS_H
#define JBED_RUNTIME_SIGNALS_H

#include "../compiler/writer.h"
#include <stdatomic.h>
#include <stdbool.h>

struct JbedVm;

enum {
    JBED_MAX_ISOLATES = 25,
    JBED_SIGNAL_NORMAL = 1,
    JBED_SIGNAL_FAST = 2,
    JBED_RAW_EVENT_TARGETS = 16,
    JBED_SIGNAL_EVENT_CAPACITY = 256
};

typedef struct JbedVmSignalHub {
    JbedBuffer memory;
    struct JbedVm *isolates[JBED_MAX_ISOLATES];
    atomic_uchar pending[JBED_MAX_ISOLATES];
    JbedAddress raw_event_queue, targeted_event_queues;
} JbedVmSignalHub;

typedef struct JbedVmSignals {
    JbedVmSignalHub *hub;
    JbedAddress queue_slot, pending_slot, current_thread_slot;
} JbedVmSignals;

/* Install before native event sources start; registration changes occur while stopped. */
void jbed_vm_signals_install(JbedVmSignalHub *);
void jbed_vm_signals_uninstall(JbedVmSignalHub *);
unsigned jbed_vm_take_signal_flags(JbedVmSignalHub *, unsigned vm_ref);
void jbed_vm_signal_insert(struct JbedVm *, JbedAddress signal);
JbedAddress jbed_vm_signal_remove(struct JbedVm *, JbedAddress signal);
void jbed_vm_process_signals(struct JbedVm *);
void jbed_vm_enqueue_raw_event(JbedVmSignalHub *, JbedAddress queue, uint32_t event);
JbedAddress SignalQueue_getAsyncRef(JbedAddress queue);
void SuperScheduler_asyncSignalIsolate(int32_t isolate, bool fast);

#endif
