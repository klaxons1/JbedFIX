#ifndef JBED_VM_LIFECYCLE_H
#define JBED_VM_LIFECYCLE_H

enum {
    VM_STATE_DOWN, VM_STATE_IDLE, VM_STATE_ACTIVE, VM_STATE_ACTIVE_FOREGROUND
};

typedef int (*VmStateNotifier)(int isolate, int commit, int old_state, int new_state,
                               int status, void *arg);

void Jbed_setVmArguments(int argc, char **argv);
void Jbed_initVmLifeCycle(int argc, char **argv, VmStateNotifier notify);
void Jbed_setVmStateNotifier(VmStateNotifier notify);
int Jbed_requestState(int state, void *user_data, void **previous);
int Jbed_initialize(int argc, char **argv);
int Jbed_newIsolate(int a, int b, int c);
int Jbed_run(int slice);
int Jbed_upcall_poll(void);
int Jbed_upcall_check(void);
int Jbed_upcall_receiver_isReady(void);
void vm_event_forwarder_start(void);
void vm_event_forwarder_shutdown(void);
void vm_event_forwarder_sendCachedEvent(void);

#endif
