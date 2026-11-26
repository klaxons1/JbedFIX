#ifndef JBED_SOURCE_LIFECYCLE_H
#define JBED_SOURCE_LIFECYCLE_H

#include "../compiler/writer.h"

typedef enum JbedVmState {
    JBED_VM_DOWN, JBED_VM_IDLE, JBED_VM_ACTIVE, JBED_VM_ACTIVE_FOREGROUND
} JbedVmState;

typedef struct JbedVmLifecycle {
    int32_t requested_state, committed_state, last_state;
    JbedAddress control_signal;
    int (*notify)(void *, int isolate, bool commit, int old_state, int new_state, int status);
    void *context;
} JbedVmLifecycle;

JbedAddress Main_setControlSignal(JbedAddress signal);
int Main_notifyStateChange(int isolate, bool commit, int old_state, int new_state, int status);
_Noreturn void System_halt(JbedAddress message, JbedAddress object);

#endif
