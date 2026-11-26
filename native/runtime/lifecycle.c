#include "lifecycle.h"
#include "runtime.h"
#include "metadata_init.h"
#include "../compiler/vm/vm_words.h"

extern void Jbed_signalArg(VmSignal *, int argument);
extern _Noreturn void OPL_os_fatalError(const JbString *message);

static JbedVmLifecycle *lifecycle(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "Lifecycle call outside a Jbed VM");
    return &vm->lifecycle;
}

JbedAddress Main_setControlSignal(JbedAddress signal)
{
    JbedVmLifecycle *state = lifecycle();
    state->control_signal = signal;
    if (signal) Jbed_signalArg((VmSignal *)(uintptr_t)signal, state->requested_state);
    return (JbedAddress)(uintptr_t)&state->requested_state;
}

int Main_notifyStateChange(int isolate, bool commit, int old_state, int new_state, int status)
{
    JbedVmLifecycle *state = lifecycle();
    int result = state->notify ? state->notify(state->context, isolate, commit,
                                               old_state, new_state, status) : 0;
    state->last_state = new_state;
    if (commit) state->committed_state = new_state;
    return result;
}

_Noreturn void System_halt(JbedAddress message, JbedAddress object)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "System.halt outside a Jbed VM");
    JbedAddress info = jbed_vm_static_field_slot(vm, "com/jbed/runtime/System", "inf");
    JbedAddress reference = jbed_vm_static_field_slot(vm, "com/jbed/runtime/System", "ref");
    jbed_vm_put_word(vm->heap.memory, info, message);
    jbed_vm_put_word(vm->heap.memory, reference, object);
    OPL_os_fatalError((const JbString *)(uintptr_t)message);
}
