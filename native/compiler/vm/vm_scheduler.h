#ifndef JBED_VM_SCHEDULER_H
#define JBED_VM_SCHEDULER_H

#include "vm_monitor.h"
#include "vm_words.h"

/* Managed references stay 32-bit when the compiler runs on a 64-bit host. */
typedef struct JbedRomSynchronizer {
    JbedAddress tag;
    uint32_t object_flags, sync_link;
    int8_t bitset;
    int16_t recursions;
    JbedAddress owner, waitedQ, blockedQ, nextOwned;
} JbedRomSynchronizer;

typedef struct JbedRomScheduled {
    JbedAddress tag;
    uint32_t object_flags, sync_link;
    JbedAddress stackBase;
    int32_t ofm;
    JbedAddress context, excpFP, excpPC, ssp, stackLimit;
    JbedAddress stack, ncss, thread, handler, exception, synchronizer, name;
    int32_t givenPrio, prio, visiblePrio, id, status;
    struct { uint32_t low, high; } timeout, running;
    int32_t suspendCount;
    uint8_t schedF, timeoutF, interrupted, interruptible, triggerable, stopped, daemon, overrun, miss;
    int32_t fairness, posPS;
    JbedAddress parent, nextTimeout, prevTimeout, nextScheduled, prevScheduled;
    JbedAddress nextjinsert, waitingQ, blockingQ, blockedBy, waitingFor, owned;
    int32_t statusS;
    uint8_t timeoutFS, schedFS;
    JbedAddress waitingForS, blockedByS;
    int32_t runtimeReservedStackNesting, noExceptionNesting, assertingStackLimit;
    int32_t lower, upper, pendingExitEvents;
    JbedAddress groupID;
    int8_t changes;
    int32_t paramPtr;
    JbedAddress signal;
} JbedRomScheduled;

_Static_assert(sizeof(JbedRomSynchronizer) == 32, "Synchronizer layout");
_Static_assert(sizeof(JbedRomScheduled) == 228, "Scheduled layout");
#define SCHEDULED_FIELD(name) offsetof(JbedRomScheduled, name)
#define SYNC_FIELD(name) offsetof(JbedRomSynchronizer, name)

enum {
    DI = 1, LOCKED = 8,
    S_INITED = 0, S_STARTED = 1, S_WAIT = 2, S_READY = 3, S_HALTED = 4, S_SCHED = 5,
    RTROOT = 972, CURRENT = 976, SCHEDULER_DUMMY = 980, SCHEDULED_THREADS = 984,
    SCHEDULER_TIME = 2016, TIMER_LOW = 2036, TIMER_HIGH = 2040
};

void xRTInsertSched(JbedVmMonitors *, JbedAddress thread);
void xRTRemoveSched(JbedVmMonitors *, JbedAddress thread);
void xRTReSched(JbedVmMonitors *, JbedAddress thread);
void xElapsed(JbedVmMonitors *);
void xRTInsertBlocking(JbedBuffer, JbedAddress thread, JbedAddress sync);
void xRTInsertWaiting(JbedBuffer, JbedAddress thread, JbedAddress sync);
void xRTRemoveWaiting(JbedVmMonitors *, JbedAddress thread, JbedAddress sync);
void xRTInsertTO(JbedVmMonitors *, JbedAddress thread, uint64_t delay);
void xRTRemoveTimeout(JbedBuffer, JbedAddress thread);
void xSetPriority(JbedVmMonitors *, JbedAddress thread, int32_t priority);
JbedVmMonitorResult xWait(JbedVmMonitors *);
JbedVmMonitorResult xYield(JbedVmMonitors *);

#endif
