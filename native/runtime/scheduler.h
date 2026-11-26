#ifndef JBED_RUNTIME_SCHEDULER_H
#define JBED_RUNTIME_SCHEDULER_H

#include "runtime.h"

void jbed_vm_schedule(void *context);
void jbed_vm_scheduler_dispose(JbedVm *);
void jbed_vm_scheduler_rebase_statics(JbedVm *, JbedAddress old_base, JbedAddress new_base);
void jbed_vm_scheduler_visit_roots(JbedVm *, const JbedVmRootVisitor *, const JbedVmRootVisitor *);
void jbed_vm_scheduler_fix_native_pointers(JbedVm *);
void jbed_vm_scheduler_wake(JbedVm *);
void jbed_vm_scheduler_start_timer(JbedVm *);
void jbed_vm_scheduler_initialize_timer(JbedVm *);
void jbed_vm_scheduler_checkpoint(JbedVm *);
int32_t jbed_vm_scheduler_iterate(JbedVm *, int32_t milliseconds);
void *Scheduling_preemptionPendingField(void *runtime);
void Base_setStackArray(JbedAddress scheduled, JbedAddress array, uint32_t reserved);
void Scheduling_createNewThreadState(JbedAddress scheduled);
void SchedulerInlines_createNewThreadState(JbedAddress scheduled);
void Scheduling_yieldToScheduler(bool preemption);
void Scheduling_schedule(void);
void Scheduler_RTOneshotRun(void);
int32_t Scheduler_xWaitToBecomeIdle(int32_t milliseconds);
void Scheduler_forceYieldToDummy(void);
bool DebugVm_checkStackPattern(void);
void Base_useRuntimeReservedStackSpace(void);
void Base_endUseRuntimeReservedStackSpace(void);

#endif
