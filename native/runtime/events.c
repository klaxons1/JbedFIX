#include "execution.h"

void Jbed_sendComplexEvent(int isolate, int code, int value, void *payload)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm || !vm->deliver_native_event)
        jbed_vm_fatal(vm, "ROM has no native event delivery method");
    uint32_t arguments[] = {(uint32_t)isolate, (uint32_t)code, (uint32_t)value,
                             (uint32_t)(uintptr_t)payload};
    uint64_t result;
    if (!jbed_vm_invoke(vm, vm->deliver_native_event, arguments, 4, &result)) {
        JbedError error = {.kind = JBED_ERROR_THROWABLE,
                           .runtime_throwable = (void *)(uintptr_t)vm->pending_exception};
        jbed_raise(&vm->services, &error);
    }
}
