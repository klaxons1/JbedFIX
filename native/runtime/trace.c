#include "trace.h"
#include "arm32.h"
#include "../compiler/vm/vm_words.h"

enum { THROWABLE_TRACE = 12, TRACE_NEXT = 12, TRACE_PCS = 16, TRACE_LENGTH = 4 };

void jbed_vm_fill_trace_at(JbedVm *vm, JbedAddress *throwable, JbedAddress pc, JbedAddress fp)
{
    JbedBuffer memory = vm->heap.memory;
    JbedArm32Frame *frame;
    jbed_vm_put_word(memory, *throwable + THROWABLE_TRACE, 0);
    JbedAddress trace_class = jbed_vm_find_class(vm, "com/jbed/runtime/Trace");
    if (!trace_class)
        jbed_vm_fatal(vm, "Throwable traces require the Trace class");

    JbedVmHeapRoot chunk = {0, 0, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &chunk;
    JbedArm32Activation *activation = vm->arm->activations;
    unsigned used = TRACE_LENGTH;
    for (;;) {
        if (used == TRACE_LENGTH) {
            JbedAddress next = jbed_vm_new_object(&vm->heap, trace_class);
            if (!next)
                jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, NULL);
            if (chunk.value)
                jbed_vm_put_word(memory, chunk.value + TRACE_NEXT, next);
            else
                jbed_vm_put_word(memory, *throwable + THROWABLE_TRACE, next);
            chunk.relocated = chunk.value = next;
            used = 0;
        }
        jbed_vm_put_word(memory, chunk.value + TRACE_PCS + 4 * used++, pc);
        JbedAddress top = fp & ~7u;
        if (fp) {
            fp = jbed_vm_word(memory, top - 8);
            if (fp) {
                pc = jbed_vm_word(memory, top - 4) - 3;
                continue;
            }
        }
        while (activation && !activation->caller_frame)
            activation = activation->previous;
        if (!activation)
            break;
        frame = activation->caller_frame;
        activation = activation->previous;
        fp = frame->r[7];
        pc = frame->lr;
        if (!fp)
            break;
    }
    vm->heap.temporary_roots = chunk.previous;
}

void jbed_vm_fill_throwable_trace(void *context, JbedAddress *throwable)
{
    JbedVm *vm = context;
    JbedArm32Frame *frame = vm->arm ? vm->arm->frame : NULL;
    if (frame)
        jbed_vm_fill_trace_at(vm, throwable, frame->lr - 3, frame->r[7]);
    else
        jbed_vm_put_word(vm->heap.memory, *throwable + THROWABLE_TRACE, 0);
}
