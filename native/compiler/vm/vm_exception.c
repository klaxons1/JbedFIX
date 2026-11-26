#include "vm_exception.h"
#include "vm_memory.h"

enum {
    STACK_OVERFLOW_RESERVE_BYTES = 512,
    FRAME_HAS_CONTROL = 4, CONTROL_HAS_HANDLERS = 1, CONTROL_SYNCHRONIZED = 2,
    CONTROL_FLAGS = CONTROL_HAS_HANDLERS | CONTROL_SYNCHRONIZED,
    CLASS_SUPER = 20, CLASS_DEPTH = 32,
    HANDLER_END_PC = 4, HANDLER_CATCH_PC = 8, HANDLER_CLASS = 12, HANDLER_BYTES = 16
};

static uint32_t word(JbedVmMemoryReader memory, JbedAddress address)
{
    return memory.word(memory.context, address);
}

/* Base.exceptionInstanceOf, 0xe2d14. The tag points at the class descriptor;
 * the preceding words cache the first four superclass depths. */
bool jbed_vm_exception_instance_of(JbedVmMemoryReader memory, JbedAddress tag,
                                   JbedAddress catch_class)
{
    if (!catch_class)
        return true;
    JbedAddress actual = word(memory, tag);
    if (actual == catch_class)
        return true;
    int depth = (int16_t)word(memory, catch_class + CLASS_DEPTH);
    if (depth <= JBED_TAG_SUPERCLASS_SLOTS)
        return depth == 0 || word(memory, tag - 4 * (uint32_t)(depth + 1)) == catch_class;
    while ((int16_t)word(memory, actual + CLASS_DEPTH) > depth)
        actual = word(memory, actual + CLASS_SUPER);
    return actual == catch_class;
}

/* ArchBase.handleException, 0xe04fa. Coder.GenHandlerTable retains classfile
 * order. The lookup PC is the last byte of the Thumb BL (tagged LR minus 2). */
static JbedAddress find_handler(JbedVmMemoryReader memory, JbedAddress table, JbedAddress lr,
                                JbedAddress tag)
{
    int32_t pc = (int32_t)((lr - 3) | 1u);
    JbedAddress match = 0;
    for (JbedAddress start; ((start = word(memory, table)) & ~1u); table += HANDLER_BYTES) {
        if (!match && pc >= (int32_t)start && pc < (int32_t)word(memory, table + HANDLER_END_PC) &&
            jbed_vm_exception_instance_of(memory, tag, word(memory, table + HANDLER_CLASS)))
            match = table;
    }
    return match ? word(memory, match + HANDLER_CATCH_PC) | 1u : 0;
}

/* 0xe05a8. Frames save a prefix of r4..r6 directly below the caller's FP/LR.
 * Registers absent from a short frame already carry their caller's values. */
static void pop_managed_frame(JbedVmMemoryReader memory, JbedVmArmFrame *frame)
{
    JbedAddress top = frame->fp & ~7u;
    JbedAddress slot = top - 20;
    if ((int32_t)slot < (int32_t)frame->sp)
        slot = frame->sp;
    JbedAddress fp_slot = top - 8;
    uint32_t *registers[] = {&frame->r4, &frame->r5, &frame->r6};
    for (unsigned i = 0; i < 3 && (int32_t)slot < (int32_t)fp_slot; ++i, slot += 4)
        *registers[i] = word(memory, slot);
    frame->sp = top;
    frame->fp = word(memory, slot);
    frame->lr = word(memory, slot + 4);
}

/* NativeCallStateStack.unwindFrame at 0xf8990 and the resume path at 0xe0684.
 * Previous frames carry six words in the order SP, LR, r4, r5, r6, FP. */
static bool pop_native_frame(JbedVmExceptionState *vm, JbedVmArmFrame *frame)
{
    JbedVmNativeFrames *native = vm->native_frames;
    if (native->frame == native->base || native->frame == native->base + 4)
        return false;
    JbedAddress previous = word(vm->memory, native->frame - 8);
    native->address = native->frame = previous;
    native->no_allocation = previous == native->base || previous == native->base + 4
                                ? 0 : word(vm->memory, previous - 4);
    if (previous == native->base)
        vm->stack_limit = vm->reserved_stack_limit;
    frame->fp = word(vm->memory, previous + JBED_NATIVE_FRAME_FP);
    if (!frame->fp)
        return false;
    frame->sp = word(vm->memory, previous + JBED_NATIVE_FRAME_SP);
    frame->lr = word(vm->memory, previous + JBED_NATIVE_FRAME_LR);
    frame->r4 = word(vm->memory, previous + JBED_NATIVE_FRAME_R4);
    frame->r5 = word(vm->memory, previous + JBED_NATIVE_FRAME_R5);
    frame->r6 = word(vm->memory, previous + JBED_NATIVE_FRAME_R6);
    return true;
}

/* ArchBase.Throw/reThrow reserve 512 bytes for the preallocated StackOverflowError.
 * The two transfer trampolines at 0xe043c/0xe0454 restore the stack and hand
 * these register values to Base.handleFrameUnwind or Base.handleCatchingException. */
JbedVmExceptionTransfer jbed_vm_handle_exception(JbedVmExceptionState *vm, JbedAddress throwable,
                                                 JbedVmArmFrame frame)
{
    JbedVmExceptionTransfer result = {.action = JBED_VM_UNCAUGHT, .throwable = throwable};
    bool overflow = throwable == vm->stack_overflow;
    if (overflow)
        vm->stack_limit -= STACK_OVERFLOW_RESERVE_BYTES;
    if (!vm->native_frames) {
        result.action = JBED_VM_NO_NATIVE_STATE;
        return result;
    }
    JbedAddress tag = word(vm->memory, throwable);
    if (vm->no_catch || tag == vm->no_catch_tag)
        return result;
    for (;;) {
        if (!frame.fp && !pop_native_frame(vm, &frame))
            return result;
        if (frame.fp == frame.sp) {
            result.action = JBED_VM_THROW_FROM_KNI;
            return result;
        }
        uint32_t control = frame.fp & FRAME_HAS_CONTROL ? word(vm->memory, frame.fp - 28) : 0;
        if (control & CONTROL_HAS_HANDLERS) {
            JbedAddress handler = find_handler(vm->memory, control & ~(uint32_t)CONTROL_FLAGS,
                                               frame.lr, tag);
            if (handler) {
                result.action = JBED_VM_ENTER_CATCH;
                result.handler_or_monitor = handler;
                break;
            }
        }
        JbedAddress monitor = control & CONTROL_SYNCHRONIZED ? frame.r4 : 0;
        pop_managed_frame(vm->memory, &frame);
        if (monitor) {
            result.action = JBED_VM_RELEASE_MONITOR;
            result.handler_or_monitor = monitor;
            break;
        }
    }
    if (overflow)
        vm->stack_limit += STACK_OVERFLOW_RESERVE_BYTES;
    result.frame = frame;
    return result;
}

/* Base.fillTrace, 0xe24b8. Trace records hold four PCs. At a native boundary
 * the stored LR is copied verbatim, even though a managed return PC loses 3.
 * The trace walk leaves the native call state and allocation mode untouched. */
void jbed_vm_fill_trace(JbedRuntime *runtime, const JbedVmExceptionState *vm, JbedVmTrace **trace,
                        JbedAddress call_address, JbedAddress fp)
{
    const JbedVmNativeFrames *native = vm->native_frames;
    JbedAddress native_frame = native ? native->frame : 0;
    JbedVmTrace *chunk = NULL;
    unsigned used = JBED_TRACE_PCS_PER_CHUNK;
    for (;;) {
        if (used == JBED_TRACE_PCS_PER_CHUNK) {
            chunk = jbed_alloc(runtime, sizeof *chunk);
            *trace = chunk;
            trace = &chunk->next;
            used = 0;
        }
        chunk->pcs[used++] = call_address;
        JbedAddress top = fp & ~7u;
        fp = word(vm->memory, top - 8);
        if (fp) {
            call_address = word(vm->memory, top - 4) - 3;
            continue;
        }
        if (!native || !native->base || native_frame <= native->base + 4)
            return;
        native_frame = word(vm->memory, native_frame - 8);
        if (!native_frame)
            native_frame = native->base;
        fp = word(vm->memory, native_frame + JBED_NATIVE_FRAME_FP);
        if (!fp)
            return;
        call_address = word(vm->memory, native_frame + JBED_NATIVE_FRAME_LR);
        if (fp == word(vm->memory, native_frame + JBED_NATIVE_FRAME_SP))
            fp += 16;
    }
}

/* Base.stackPos, 0xe2f24. */
JbedAddress jbed_vm_stack_pos(const JbedVmTrace *trace, int32_t depth)
{
    if (depth < 0)
        return 0;
    while (trace && depth >= JBED_TRACE_PCS_PER_CHUNK) {
        trace = trace->next;
        depth -= JBED_TRACE_PCS_PER_CHUNK;
    }
    return trace ? trace->pcs[depth] : 0;
}
