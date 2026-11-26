#include "arm32.h"
#include "arithmetic.h"
#include "bytecode.h"
#include "vm_scheduler.h"

#include <assert.h>
#include <stdlib.h>

_Static_assert(sizeof(JbedArm32Frame) == 64, "managed register frame");
_Static_assert(offsetof(JbedArm32Frame, sp) == 52, "managed SP slot");
_Static_assert(offsetof(JbedArm32Frame, pc) == 60, "managed continuation slot");
_Static_assert(offsetof(JbedRomScheduled, context) == 20, "ARM Scheduled.context slot");
#if defined(__arm__)
_Static_assert(offsetof(JbedArm32Context, statics) == 4, "ARM statics slot");
_Static_assert(offsetof(JbedArm32Context, stack_limit) == 8, "ARM stack-limit slot");
_Static_assert(offsetof(JbedArm32Context, stack_top) == 12, "ARM stack-top slot");
_Static_assert(offsetof(JbedArm32Context, checkpoint_budget) == 16, "ARM budget slot");
#endif

extern uint64_t jbed_arm32_enter(JbedArm32Context *, uintptr_t, const uint32_t *, size_t);

uint64_t jbed_arm32_call(JbedArm32Context *context, uintptr_t entry,
                        const uint32_t *arguments, size_t count)
{
    assert(context && entry && (arguments || !count));
    assert(context->stack_top > context->stack_limit && context->checkpoint_budget);
    uintptr_t host_sp = context->host_sp, stack_top = context->stack_top;
    unsigned host_depth = context->host_depth;
    JbedArm32Frame *frame = context->frame;
    JbedArm32Activation activation = {frame, context->activations};
    /* A Java upcall from a native service grows below its suspended caller. */
    if (frame)
        context->stack_top = (uintptr_t)frame;
    context->frame = NULL;
    context->host_depth = 0;
    context->activations = &activation;
    uint64_t result = jbed_arm32_enter(context, entry, arguments, count);
    context->host_sp = host_sp;
    context->stack_top = stack_top;
    context->frame = frame;
    context->host_depth = host_depth;
    context->activations = activation.previous;
    return result;
}

/* Called only after the assembler gate has selected the native thread stack. */
void jbed_arm32_dispatch(JbedArm32Context *context, JbedArm32Operation operation,
                         JbedArm32Frame *frame)
{
    JbedArm32Frame *previous = context->frame;
    context->frame = frame;
    ++context->host_depth;
    if (operation == JBED_ARM32_SAVE_FRAME) {
        /* Native methods capture their frame at the host-stack gate. */
        frame->r[8] = 1;
    } else if (operation == JBED_ARM32_INTERFACE_STUB) {
        const uint32_t *table = (const uint32_t *)(uintptr_t)
                                   *(const uint32_t *)(uintptr_t)frame->r[0];
        do {
            table = (const uint32_t *)(uintptr_t)table[1];
        } while (table && table[0] != frame->r[3]);
        if (table)
            frame->r[3] = (uint32_t)(uintptr_t)table;
        else if (context->service)
            context->service(context, JBED_ARM32_THROW_ABSTRACT, frame);
        else
            abort();
    } else {
        if (operation == JBED_ARM32_CHECKPOINT)
            frame->r[8] = context->checkpoint_budget;
        if (!context->service)
            abort();
        context->service(context, operation, frame);
    }
    --context->host_depth;
    context->frame = previous;
}

#define ADDRESS(name) ((uint32_t)(uintptr_t)jbed_arm32_##name)
JbedThumbRuntimeAddresses jbed_arm32_thumb_helpers(void)
{
    return (JbedThumbRuntimeAddresses){
        .compiler_code = ADDRESS(call),
        .throw_null = ADDRESS(throw_null), .throw_index = ADDRESS(throw_index),
        .throw_stack = ADDRESS(throw_stack), .throw_large_stack = ADDRESS(throw_large_stack),
        .throw_abstract = ADDRESS(throw_abstract), .throw_no_class = ADDRESS(throw_no_class),
        .interface_stub = ADDRESS(interface_stub), .initialize = ADDRESS(initialize),
        .monitor_enter = ADDRESS(monitor_enter), .monitor_exit = ADDRESS(monitor_exit),
        .checkpoint = ADDRESS(checkpoint), .save_frame = ADDRESS(save_frame),
        .integer_divide = ADDRESS(integer_divide), .integer_remainder = ADDRESS(integer_remainder)
    };
}

JbedCoderRuntimeAddresses jbed_arm32_coder_helpers(void)
{
    JbedCoderRuntimeAddresses helpers = {
        .new_object = ADDRESS(new_object), .new_array = ADDRESS(new_array),
        .new_array_n = ADDRESS(new_array_n), .array_store = ADDRESS(array_store),
        .check_cast = ADDRESS(check_cast), .instance_of = ADDRESS(instance_of),
        .throw_exception = ADDRESS(throw_exception),
        .monitor_enter = ADDRESS(monitor_enter), .monitor_exit = ADDRESS(monitor_exit),
        .class_for_name = ADDRESS(class_for_name), .checked_class_for_name = ADDRESS(checked_class_for_name),
        .class_new_instance = ADDRESS(class_new_instance),
        .checked_class_new_instance = ADDRESS(checked_class_new_instance)
    };
#define ARITHMETIC(upper, lower) helpers.arithmetic[JBED_BC_##upper] = ADDRESS(lower)
    ARITHMETIC(LADD, ladd); ARITHMETIC(LSUB, lsub); ARITHMETIC(LMUL, lmul);
    ARITHMETIC(LDIV, ldiv); ARITHMETIC(LREM, lrem); ARITHMETIC(LNEG, lneg);
    ARITHMETIC(LSHL, lshl); ARITHMETIC(LSHR, lshr); ARITHMETIC(LUSHR, lushr);
    ARITHMETIC(LAND, land); ARITHMETIC(LOR, lor); ARITHMETIC(LXOR, lxor);
    ARITHMETIC(LCMP, lcmp);
    ARITHMETIC(FADD, fadd); ARITHMETIC(FSUB, fsub); ARITHMETIC(FMUL, fmul);
    ARITHMETIC(FDIV, fdiv); ARITHMETIC(FREM, frem); ARITHMETIC(FNEG, fneg);
    ARITHMETIC(I2F, i2f); ARITHMETIC(L2F, l2f); ARITHMETIC(F2I, f2i);
    ARITHMETIC(F2L, f2l); ARITHMETIC(FCMPL, fcmpl); ARITHMETIC(FCMPG, fcmpg);
    ARITHMETIC(DADD, dadd); ARITHMETIC(DSUB, dsub); ARITHMETIC(DMUL, dmul);
    ARITHMETIC(DDIV, ddiv); ARITHMETIC(DREM, drem); ARITHMETIC(DNEG, dneg);
    ARITHMETIC(I2D, i2d); ARITHMETIC(L2D, l2d); ARITHMETIC(F2D, f2d);
    ARITHMETIC(D2I, d2i); ARITHMETIC(D2L, d2l); ARITHMETIC(D2F, d2f);
    ARITHMETIC(DCMPL, dcmpl); ARITHMETIC(DCMPG, dcmpg);
#undef ARITHMETIC
    return helpers;
}
#undef ADDRESS
