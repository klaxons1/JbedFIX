#include "bundle.h"
#include "class_init.h"
#include "execution.h"
#include "metadata_init.h"
#include "../compiler/vm/vm_words.h"

extern void OPL_trace_traceInit(void);

void Isolate_initBundle(int32_t bundle)
{
    JbedVm *vm = jbed_vm_current();
    if (bundle != 0)
        jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, "Unknown initializer bundle");
    for (uint32_t i = 0; i < vm->bundle_initializer_count; ++i) {
        JbedAddress klass = jbed_vm_word(vm->heap.memory, vm->bundle_initializers + 4 * i);
        if (!jbed_vm_static_initialize_class(vm, klass)) return;
        OPL_trace_traceInit();
    }
}

void Isolate_runMain(JbedAddress isolate, JbedAddress arguments)
{
    (void)isolate;
    JbedVm *vm = jbed_vm_current();
    JbedAddress slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/SysInfo", "mainMethod");
    JbedAddress entry = slot ? jbed_vm_word(vm->heap.memory, slot) : 0;
    if (!entry) jbed_vm_raise(vm, JBED_ERROR_NO_SUCH_METHOD, "No main method in the boot image");
    uint64_t ignored;
    (void)jbed_vm_invoke(vm, entry, &arguments, 1, &ignored);
}
