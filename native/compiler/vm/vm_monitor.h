#ifndef JBED_VM_MONITOR_H
#define JBED_VM_MONITOR_H

#include "vm_exception.h"
#include "vm_memory.h"

typedef struct JbedVmMonitorImage {
    JbedAddress synchronizer_class, synchronizer_array_class;
    JbedAddress synchronizer_tag_slot, illegal_monitor_error_slot, out_of_memory_error_slot;
    JbedAddress table_slot;
    uint32_t rom_slots;
    JbedAddress current_slot, ready_root_slot, time_slot, timer_low_slot, timer_high_slot;
} JbedVmMonitorImage;

typedef struct JbedVmMonitors {
    JbedVmHeap *heap;
    JbedAddress isolate_statics;
    JbedVmMonitorImage image;
    struct {
        void *context;
        uint64_t (*elapsed_micros)(void *);
        /* Returns when the suspended guest thread runs again. */
        void (*yield_to_scheduler)(void *);
        JbedRuntime *runtime;
    } scheduling;
} JbedVmMonitors;

typedef enum JbedVmMonitorResult {
    JBED_MONITOR_DONE,
    JBED_MONITOR_YIELD,
    JBED_MONITOR_BLOCKED,
    JBED_MONITOR_NULL_POINTER,
    JBED_MONITOR_ILLEGAL_STATE,
    JBED_MONITOR_ALLOCATION_FAILED,
    JBED_MONITOR_ILLEGAL_ARGUMENT,
    JBED_MONITOR_INTERRUPTED
} JbedVmMonitorResult;

bool jbed_vm_monitors_init_image(JbedVmMonitors *, JbedVmHeap *, JbedAddress isolate_statics,
                                 JbedVmMonitorImage);
bool jbed_vm_monitors_init(JbedVmMonitors *, JbedVmHeap *, JbedAddress rom_base,
                           JbedAddress isolate_statics);
uint32_t jbed_vm_monitor_rom_slots(const JbedVmMonitors *);
JbedVmMonitorResult jbed_vm_get_synchronizer(JbedVmMonitors *, JbedAddress object,
                                             bool allocate, JbedAddress *result);
JbedVmMonitorResult jbed_vm_alloc_synchronizer(JbedVmMonitors *, JbedAddress *object,
                                               JbedAddress *result);
bool jbed_vm_locked_by_current(JbedVmMonitors *, JbedAddress object);
JbedErrorKind jbed_vm_monitor_extend_table(JbedVmMonitors *, int32_t delta);

/* Without a scheduler hook these two methods stop at the context switch and
 * return BLOCKED or YIELD with the guest queues already updated. */
JbedVmMonitorResult jbed_vm_monitor_enter(JbedVmMonitors *, JbedAddress object);
JbedVmMonitorResult jbed_vm_monitor_exit(JbedVmMonitors *, JbedAddress object);
JbedVmMonitorResult jbed_vm_monitor_notify(JbedVmMonitors *, JbedAddress object, bool all);
/* Object.wait(long, int). A yielding wait requires a synchronous scheduler hook.
 * Timed waits also need the OPL elapsed-microseconds clock. */
JbedVmMonitorResult jbed_vm_monitor_wait(JbedVmMonitors *, JbedAddress object,
                                        int64_t millis, int32_t nanos);
/* Handles a RELEASE_MONITOR transfer and updates its throwable for the next
 * unwind step. A failed release preserves the preallocated OutOfMemoryError. */
JbedVmMonitorResult jbed_vm_monitor_unwind(JbedVmMonitors *, JbedVmExceptionTransfer *);

#endif
