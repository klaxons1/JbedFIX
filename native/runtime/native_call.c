#include "native_call.h"
#include "../compiler/vm/vm_words.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { MAX_PARAMETER_WORDS = 255, C_ALIGNMENT_HOLE = UINT16_MAX };

struct JbedNativePlan {
    const JbedBootNativeMethod *binding;
    JbedAddress declaring_class;
    uint16_t managed_words, parameter_words, c_words, reference_count, result_words;
    uint16_t *c_slots, *reference_slots;
};

extern uint64_t jbed_arm32_call_c(uintptr_t function, const uint32_t *words, size_t count);

static bool fail(char *error, size_t size, const char *message)
{
    if (error && size)
        snprintf(error, size, "%s", message);
    return false;
}

/* Return the number of JVM words and advance past one field descriptor. */
static unsigned argument_type(const char **descriptor, bool *reference)
{
    const char *p = *descriptor;
    bool array = *p == '[';
    while (*p == '[')
        ++p;
    *reference = array || *p == 'L';
    unsigned words = 1;
    if (*p == 'L') {
        const char *end = strchr(p, ';');
        if (!end || end == p + 1)
            return 0;
        p = end + 1;
    } else if (*p && strchr("ZBCSIFJD", *p)) {
        if (!array && (*p == 'J' || *p == 'D'))
            words = 2;
        ++p;
    } else {
        return 0;
    }
    *descriptor = p;
    return words;
}

void jbed_vm_native_methods_dispose(JbedVm *vm)
{
    for (size_t i = 0; i < vm->native_method_count; ++i) {
        free(vm->native_methods[i].c_slots);
        free(vm->native_methods[i].reference_slots);
    }
    free(vm->native_methods);
    vm->native_methods = NULL;
    vm->native_method_count = 0;
}

bool jbed_vm_native_methods_init(JbedVm *vm, const JbedBootImage *image,
                                 char *error, size_t error_size)
{
    if (vm->native_methods)
        return fail(error, error_size, "Native methods are already bound");
    if (!image->native_method_count)
        return true;
    vm->native_methods = calloc(image->native_method_count, sizeof(*vm->native_methods));
    if (!vm->native_methods)
        return fail(error, error_size, "Cannot allocate native call plans");
    vm->native_method_count = image->native_method_count;
    const char *problem = NULL;
    for (size_t i = 0; i < image->native_method_count; ++i) {
        JbedNativePlan *plan = &vm->native_methods[i];
        const JbedBootNativeMethod *binding = plan->binding = &image->native_methods[i];
        if (!binding->entry || !binding->descriptor || binding->descriptor[0] != '(' ||
            (binding->convention != JBED_NATIVE_JBNI && binding->convention != JBED_NATIVE_KNI)) {
            problem = "Invalid native method binding";
            break;
        }
        plan->declaring_class = jbed_vm_find_class(vm, binding->owner);
        if (!plan->declaring_class) {
            problem = "Native method declaring class is absent";
            break;
        }
        bool is_static = (binding->flags & JBED_ACC_STATIC) != 0;
        uint16_t c_slots[MAX_PARAMETER_WORDS * 2], references[MAX_PARAMETER_WORDS + 1];
        unsigned c_count = 0, reference_count = 0;
        unsigned parameter = 1, managed = is_static ? 0 : 1;
        references[reference_count++] = 0; /* receiver, or KNI declaring class */
        if (!is_static)
            c_slots[c_count++] = 0;
        const char *descriptor = binding->descriptor + 1;
        while (*descriptor && *descriptor != ')') {
            bool reference;
            unsigned words = argument_type(&descriptor, &reference);
            if (!words || managed + words > MAX_PARAMETER_WORDS) {
                problem = "Invalid native method arguments";
                break;
            }
            if (reference)
                references[reference_count++] = (uint16_t)parameter;
            /* AAPCS aligns each long/double argument to an even register or
             * stack slot; JVM parameter slots have no such padding. */
            if (words == 2 && (c_count & 1))
                c_slots[c_count++] = C_ALIGNMENT_HOLE;
            for (unsigned word = 0; word < words; ++word)
                c_slots[c_count++] = (uint16_t)parameter++;
            managed += words;
        }
        if (problem)
            break;
        if (*descriptor++ != ')') {
            problem = "Unterminated native method descriptor";
            break;
        }
        bool reference;
        unsigned result = *descriptor == 'V' ? (++descriptor, 0) : argument_type(&descriptor, &reference);
        if (*descriptor || (!result && descriptor[-1] != 'V')) {
            problem = "Invalid native method return type";
            break;
        }
        plan->managed_words = (uint16_t)managed;
        plan->parameter_words = (uint16_t)parameter;
        plan->c_words = binding->convention == JBED_NATIVE_KNI ? 0 : (uint16_t)c_count;
        plan->reference_count = (uint16_t)reference_count;
        plan->result_words = (uint16_t)result;
        plan->c_slots = malloc((c_count ? c_count : 1) * sizeof(*plan->c_slots));
        plan->reference_slots = malloc(reference_count * sizeof(*plan->reference_slots));
        if (!plan->c_slots || !plan->reference_slots) {
            problem = "Cannot allocate native argument layout";
            break;
        }
        memcpy(plan->c_slots, c_slots, c_count * sizeof(*c_slots));
        memcpy(plan->reference_slots, references, reference_count * sizeof(*references));
    }
    if (!problem)
        return true;
    jbed_vm_native_methods_dispose(vm);
    return fail(error, error_size, problem);
}

typedef struct NativeInvocation {
    const JbedNativePlan *plan;
    const uint32_t *arguments;
    uint64_t result;
} NativeInvocation;

static void invoke_native(void *argument)
{
    NativeInvocation *call = argument;
    call->result = jbed_arm32_call_c((uintptr_t)call->plan->binding->entry,
                                    call->arguments, call->plan->c_words);
}

bool jbed_vm_call_native(JbedVm *vm, uint32_t index, JbedArm32Frame *frame)
{
    if (index >= vm->native_method_count)
        jbed_vm_fatal(vm, "Unbound native method");
    const JbedNativePlan *plan = &vm->native_methods[index];
    bool is_static = (plan->binding->flags & JBED_ACC_STATIC) != 0;
    uint32_t storage[plan->parameter_words + 1];
    uint32_t *parameters = storage + 1;
    storage[0] = 0; /* KNI's pending exception precedes parameter slot zero. */
    parameters[0] = plan->declaring_class;
    for (unsigned i = 0; i < plan->managed_words; ++i)
        parameters[i + is_static] = i < 4 ? frame->r[i]
            : jbed_vm_word(vm->heap.memory, frame->sp + (i - 4) * 4);

    void **saved_roots = Jbed_nativeCallStateAdr;
    if (!saved_roots || saved_roots < vm->native_roots_base || saved_roots > vm->native_roots_limit ||
        (size_t)(vm->native_roots_limit - saved_roots) < (size_t)plan->reference_count + 1)
        jbed_vm_fatal(vm, "Native argument roots exceed the native stack");
    *Jbed_nativeCallStateAdr++ = &storage[0];
    for (unsigned i = 0; i < plan->reference_count; ++i)
        *Jbed_nativeCallStateAdr++ = &parameters[plan->reference_slots[i]];

    uint32_t arguments[plan->c_words ? plan->c_words : 1];
    for (unsigned i = 0; i < plan->c_words; ++i)
        arguments[i] = plan->c_slots[i] == C_ALIGNMENT_HOLE ? 0 : parameters[plan->c_slots[i]];
    JbRef *saved_parameters = Jbed_ParamPtr;
    JbRef *saved_vm_parameters = vm->parameters;
    JbedVmHeapRoot *saved_temporary_roots = vm->heap.temporary_roots;
    Jbed_ParamPtr = vm->parameters = parameters;
    NativeInvocation call = {plan, arguments, 0};
    JbedError caught = {0};
    bool returned = vm->services.protected_call(vm->services.context, invoke_native, &call, &caught);
    Jbed_ParamPtr = saved_parameters;
    vm->parameters = saved_vm_parameters;
    Jbed_nativeCallStateAdr = saved_roots;
    vm->heap.temporary_roots = saved_temporary_roots;
    if (!returned)
        jbed_raise(&vm->services, &caught);
    if (storage[0])
        vm->pending_exception = storage[0];
    if (vm->pending_exception)
        return false;
    frame->r[0] = plan->result_words ? (uint32_t)call.result : 0;
    frame->r[1] = plan->result_words == 2 ? (uint32_t)(call.result >> 32) : 0;
    return true;
}
