#ifndef JBED_SOURCE_ISOLATE_H
#define JBED_SOURCE_ISOLATE_H

#include "runtime.h"
#include "../compiler/boot_image.h"

typedef struct JbedRomIsolate {
    JbedAddress tag;
    uint32_t object_flags, sync_link;
    int32_t listIndex, id, state;
    uint8_t active;
    int32_t priority, allocation;
    JbedAddress nextIsolate, prevIsolate, nextRunIsolate;
    uint8_t bumped, idle;
    int32_t remainingAllocation;
    struct { uint32_t low, high; } idleUntil, timeSpent;
    uint8_t isExceptionThrown;
    JbedAddress argv, statics, ptrRanges;
    uint8_t rootIsolate, nativeNotify;
    JbedAddress oldStatics, tmpContext, loadedClassesAnchor, finList, finQueueList, stateSignal;
    int32_t desiredState;
    JbedAddress desiredStateAdr;
    int32_t curState, nextState;
} JbedRomIsolate;

/* Global SuperScheduler initialization precedes creation of any isolate. */
void jbed_vm_isolate_registry_init(JbedVm *);
JbedAddress jbed_vm_isolate_new(JbedVm *, const JbedBootImage *, int32_t priority,
                               bool native_notify);
int32_t jbed_vm_isolate_register(JbedVm *, JbedAddress isolate);
JbedAddress jbed_vm_isolate_start_root(JbedVm *, const JbedBootImage *, JbedAddress arguments);
bool jbed_vm_isolate_activate_first(JbedVm *, JbedAddress isolate, uint32_t sync_slots,
                                    JbedAddress intern_table, JbedAddress character_root,
                                    char *error, size_t error_size);
void jbed_vm_isolate_extend_statics(JbedVm *, uint32_t bytes,
                                    const uint32_t *pointer_ranges, uint32_t range_words);
void Isolate_run(JbedAddress isolate);
JbedAddress Isolate_switchTo(JbedAddress isolate);

void Isolate_extendStatics(int32_t, JbRef);
#endif
