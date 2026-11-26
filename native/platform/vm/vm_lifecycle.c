#include "vm_lifecycle.h"
#include "ams.h"

#include <limits.h>
#include <stddef.h>

extern void Jbed_signalArg(VmSignal *, int);
extern int Jbed_intern_newIsolate(int, int, int);
extern int Jbed_intern_initialize(int, char **);
extern void Jbed_shutdown(void);
extern int Jbed_getExitCode(void);
extern int Jbed_iterate(int slice);

static int arg_count;
static char **arguments;
static int requested_state, committed_state, last_state;
static VmSignal *control_signal;
static VmStateNotifier state_notifier;
static void *request_arg;
static int receiver_ready;

void Jbed_setVmArguments(int argc, char **argv)
{
    arg_count = argc;
    arguments = argv;
}

void Jbed_initVmLifeCycle(int argc, char **argv, VmStateNotifier notify)
{
    state_notifier = notify;
    requested_state = committed_state = last_state = VM_STATE_DOWN;
    control_signal = NULL;
    request_arg = NULL;
    Jbed_setVmArguments(argc, argv);
}

void Jbed_setVmStateNotifier(VmStateNotifier notify) { state_notifier = notify; }

int JbniS_com_jbed_runtime_Main_notifyStateChange(int isolate, int commit, int old_state,
                                                  int new_state, int status)
{
    int result = state_notifier ? state_notifier(isolate, commit, old_state, new_state, status, request_arg) : 0;
    last_state = new_state;
    if (commit)
        committed_state = new_state;
    return result;
}

int *JbniS_com_jbed_runtime_Main_setControlSignal(VmSignal *signal)
{
    control_signal = signal;
    if (signal) Jbed_signalArg(signal, requested_state);
    return &requested_state;
}

int Jbed_requestState(int state, void *arg, void **previous)
{
    if (previous) *previous = request_arg;
    request_arg = arg;
    requested_state = state;
    if (control_signal) {
        JbUpcallQueue *q = Jbed_ams_event_getUpcallQueue();
        if (q) Jbed_upcall_sendComplex(q, -1, JBED_UPCALL_AMS, AMS_REQUEST_VM_STATE, "i", requested_state);
        Jbed_signalArg(control_signal, requested_state);
    }
    return committed_state == requested_state && last_state == requested_state;
}

int Jbed_newIsolate(int a, int b, int c) { return Jbed_intern_newIsolate(a, b, c); }
int Jbed_initialize(int argc, char **argv) { return Jbed_intern_initialize(argc, argv); }

int Jbed_run(int slice)
{
    if (committed_state == VM_STATE_DOWN && requested_state > VM_STATE_DOWN) {
        JbniS_com_jbed_runtime_Main_notifyStateChange(0, 0, VM_STATE_DOWN, VM_STATE_IDLE, 0);
        Jbed_initialize(arg_count, arguments);
        JbniS_com_jbed_runtime_Main_notifyStateChange(0, 1, VM_STATE_DOWN, VM_STATE_IDLE, 0);
    }
    ASYNC_handleCallbacks();
    int delay = INT_MAX;
    if (committed_state != VM_STATE_DOWN) {
        Jbed_upcall_poll();
        delay = Jbed_iterate(slice);
        if (delay == -3) {
            int status = Jbed_getExitCode();
            JbniS_com_jbed_runtime_Main_notifyStateChange(0, 0, committed_state, VM_STATE_DOWN, status);
            Jbed_shutdown();
            JbniS_com_jbed_runtime_Main_notifyStateChange(0, 1, committed_state, VM_STATE_DOWN, status);
            if (requested_state != VM_STATE_DOWN) return 0;
            delay = INT_MAX;
        } else if (delay <= 0) {
            return delay;
        } else if (Jbed_upcall_check()) {
            return -1;
        }
    } else if (requested_state != VM_STATE_DOWN) {
        return 0;
    }
    int callback_delay = ASYNC_nextUpdateDelay();
    return delay < callback_delay ? delay : callback_delay;
}

void vm_event_forwarder_start(void) {}
void vm_event_forwarder_shutdown(void) {}
void vm_event_forwarder_sendCachedEvent(void) {}

int Jbed_upcall_receiver_isReady(void) { return receiver_ready; }
void JbniS_com_jbed_ams_Scheduler_nativeSetUpcallReceiverReadyState(int state)
{
    receiver_ready = state;
    vm_event_forwarder_sendCachedEvent();
}
