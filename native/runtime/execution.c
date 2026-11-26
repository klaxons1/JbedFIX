#include "execution.h"
#include "class_init.h"
#include "reflection.h"
#include "native_call.h"
#include "trace.h"
#include "metadata_init.h"
#include "scheduler.h"
#include "../compiler/vm/vm_words.h"

#include <stdio.h>

bool jbed_vm_invoke(JbedVm *vm, JbedAddress entry, const uint32_t *arguments,
                    size_t count, uint64_t *result)
{
    if (!entry || !vm->arm)
        jbed_vm_fatal(vm, "Managed method has no execution entry");
    JbedVm *previous = jbed_vm_bind(vm);
    JbedAddress pending = vm->pending_exception;
    vm->pending_exception = 0;
    /* Class constructor/initializer slots are untagged Thumb addresses. */
    uint64_t value = jbed_arm32_call(vm->arm, entry | 1u, arguments, count);
    bool success = vm->pending_exception == 0;
    if (success)
        vm->pending_exception = pending;
    if (result)
        *result = value;
    jbed_vm_bind(previous);
    return success;
}

JbedAddress jbed_vm_new_throwable(JbedVm *vm, const char *name)
{
    JbedAddress klass = jbed_vm_find_class(vm, name);
    if (!klass)
        jbed_vm_fatal(vm, "Required exception class is absent from the boot image");
    JbedAddress object = jbed_vm_allocate_object(vm, klass, true);
    if (!object)
        return vm->out_of_memory;
    JbedVmHeapRoot root = {object, object, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    jbed_vm_fill_throwable_trace(vm, &root.value);
    JbedAddress constructor = jbed_vm_word(vm->heap.memory, klass + 40);
    if (constructor) {
        uint64_t ignored;
        bool success = jbed_vm_invoke(vm, constructor, &root.value, 1, &ignored);
        if (!success) {
            vm->heap.temporary_roots = root.previous;
            return vm->pending_exception;
        }
    }
    vm->heap.temporary_roots = root.previous;
    return root.value;
}

typedef struct ExceptionBootstrap {
    JbedVm *vm;
    JbedAddress overflow_slot;
} ExceptionBootstrap;

static void initialize_exceptions(void *context)
{
    ExceptionBootstrap *boot = context;
    JbedVm *vm = boot->vm;
    JbedAddress overflow = jbed_vm_new_throwable(vm, "com/jbed/runtime/StackOverflowError");
    if (!overflow || vm->pending_exception)
        jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, "Cannot construct the reserved stack exception");
    jbed_vm_put_word(vm->heap.memory, overflow + 12, 0);
    jbed_vm_put_word(vm->heap.memory, boot->overflow_slot, overflow);
    vm->exceptions.stack_overflow = overflow;
}

bool jbed_vm_exceptions_bootstrap(JbedVm *vm, char *error, size_t error_size)
{
    const char *base = "com/jbed/runtime/Base";
    ExceptionBootstrap boot = {vm, jbed_vm_static_field_slot(vm, base, "stackOV")};
    vm->exception_no_catch_slot = jbed_vm_static_field_slot(vm, base, "noCatch");
    vm->exception_no_catch_tag_slot = jbed_vm_static_field_slot(vm, base, "noCatchTag");
    if (!boot.overflow_slot || !vm->exception_no_catch_slot ||
        !vm->exception_no_catch_tag_slot ||
        !jbed_vm_find_class(vm, "com/jbed/runtime/StackOverflowError")) {
        if (error && error_size)
            snprintf(error, error_size, "Exception bootstrap requires Base fields and StackOverflowError");
        return false;
    }
    JbedVmHeapRoot *roots = vm->heap.temporary_roots;
    JbedError caught;
    bool success = vm->services.protected_call(vm->services.context,
        initialize_exceptions, &boot, &caught);
    vm->heap.temporary_roots = roots;
    if (!success && error && error_size)
        snprintf(error, error_size, "%s", caught.message ? caught.message : "Cannot initialize VM exceptions");
    return success;
}

static const char *exception_class(JbedErrorKind kind)
{
    switch (kind) {
    case JBED_ERROR_CLASS_FORMAT: return "java/lang/ClassFormatError";
    case JBED_ERROR_NO_CLASS_DEF: return "java/lang/NoClassDefFoundError";
    case JBED_ERROR_VERIFY: return "java/lang/VerifyError";
    case JBED_ERROR_CLASS_CIRCULARITY: return "java/lang/ClassCircularityError";
    case JBED_ERROR_ILLEGAL_ACCESS: return "java/lang/IllegalAccessError";
    case JBED_ERROR_INCOMPATIBLE_CLASS_CHANGE: return "java/lang/IncompatibleClassChangeError";
    case JBED_ERROR_NO_SUCH_METHOD: return "java/lang/NoSuchMethodError";
    case JBED_ERROR_NO_SUCH_FIELD: return "java/lang/NoSuchFieldError";
    case JBED_ERROR_ABSTRACT_METHOD: return "java/lang/AbstractMethodError";
    case JBED_ERROR_OUT_OF_MEMORY: return "java/lang/OutOfMemoryError";
    case JBED_ERROR_IO: return "java/io/IOException";
    case JBED_ERROR_CLASS_CAST: return "java/lang/ClassCastException";
    case JBED_ERROR_ARITHMETIC: return "java/lang/ArithmeticException";
    case JBED_ERROR_NULL_POINTER: return "java/lang/NullPointerException";
    case JBED_ERROR_ARRAY_INDEX: return "java/lang/ArrayIndexOutOfBoundsException";
    case JBED_ERROR_RUNTIME_EXCEPTION: return "java/lang/RuntimeException";
    case JBED_ERROR_ARRAY_STORE: return "java/lang/ArrayStoreException";
    case JBED_ERROR_NEGATIVE_ARRAY_SIZE: return "java/lang/NegativeArraySizeException";
    default: return "java/lang/Error";
    }
}

JbedAddress jbed_vm_error_throwable(JbedVm *vm, const JbedError *error)
{
    if (error->runtime_throwable)
        return vm->heap.memory.address +
            (uint32_t)((uint8_t *)error->runtime_throwable - vm->heap.memory.data);
    if (error->kind == JBED_ERROR_OUT_OF_MEMORY)
        return vm->out_of_memory;
    return jbed_vm_new_throwable(vm, exception_class(error->kind));
}

static void monitor_result(JbedVm *vm, JbedVmMonitorResult result)
{
    switch (result) {
    case JBED_MONITOR_DONE: return;
    case JBED_MONITOR_NULL_POINTER:
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    case JBED_MONITOR_ALLOCATION_FAILED:
        jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, NULL);
    case JBED_MONITOR_ILLEGAL_STATE:
        vm->pending_exception = jbed_vm_new_throwable(vm, "java/lang/IllegalMonitorStateException");
        return;
    default:
        jbed_vm_fatal(vm, "Scheduler did not resume a managed monitor operation");
    }
}

typedef struct ServiceCall {
    JbedVm *vm;
    JbedArm32Operation operation;
    JbedArm32Frame *frame;
} ServiceCall;

static void run_service(void *argument)
{
    ServiceCall *call = argument;
    JbedVm *vm = call->vm;
    uint32_t *r = call->frame->r;
    switch (call->operation) {
    case JBED_ARM32_RUN_THREAD:
        Scheduler_RTOneshotRun();
        break;
    case JBED_ARM32_SET_STACK_LIMIT:
        r[10] = r[0];
        vm->exceptions.stack_limit = r[0];
        vm->arm->stack_limit = r[0];
        break;
    case JBED_ARM32_SET_STATIC_BASE:
        jbed_vm_switch_statics(vm, r[0]);
        r[9] = r[0];
        break;
    case JBED_ARM32_NATIVE_CALL:
        (void)jbed_vm_call_native(vm, r[12], call->frame);
        break;
    case JBED_ARM32_NEW_OBJECT:
        r[0] = jbed_vm_allocate_object(vm, r[0], false);
        break;
    case JBED_ARM32_NEW_ARRAY:
        r[0] = jbed_vm_allocate_array(vm, r[1], (int32_t)r[0], false);
        break;
    case JBED_ARM32_NEW_ARRAY_N:
        r[0] = jbed_vm_new_array_n(&vm->heap, (int32_t)r[0], r[1], r[2]);
        if (!r[0])
            jbed_vm_raise(vm, vm->heap.fault == JBED_HEAP_NEGATIVE_ARRAY
                ? JBED_ERROR_NEGATIVE_ARRAY_SIZE : JBED_ERROR_OUT_OF_MEMORY, NULL);
        break;
    case JBED_ARM32_ARRAY_STORE:
        jbed_vm_store_array_ref(&vm->resident, vm->heap.memory, r[0], (int32_t)r[1], r[2], true);
        break;
    case JBED_ARM32_CHECK_CAST:
        r[0] = jbed_vm_checkcast(&vm->resident, vm->heap.memory, r[0],
                                jbed_vm_class_at(&vm->resident, r[1]));
        break;
    case JBED_ARM32_INSTANCE_OF:
        r[0] = r[0] && jbed_vm_instance_of(&vm->resident, jbed_vm_word(vm->heap.memory, r[0]),
                                           jbed_vm_class_at(&vm->resident, r[1]));
        break;
    case JBED_ARM32_MONITOR_ENTER:
        monitor_result(vm, jbed_vm_monitor_enter(&vm->monitors, r[0]));
        break;
    case JBED_ARM32_MONITOR_EXIT:
        monitor_result(vm, jbed_vm_monitor_exit(&vm->monitors, r[0]));
        break;
    case JBED_ARM32_INITIALIZE:
        (void)jbed_vm_initialize_class(vm, r[0]);
        break;
    case JBED_ARM32_CLASS_FOR_NAME:
    case JBED_ARM32_CHECKED_CLASS_FOR_NAME:
        r[0] = jbed_vm_class_for_name(vm, r[0], r[1], call->operation == JBED_ARM32_CHECKED_CLASS_FOR_NAME);
        break;
    case JBED_ARM32_CLASS_NEW_INSTANCE:
    case JBED_ARM32_CHECKED_CLASS_NEW_INSTANCE:
        r[0] = jbed_vm_class_new_instance(vm, r[0], r[1], call->operation == JBED_ARM32_CHECKED_CLASS_NEW_INSTANCE);
        break;
    case JBED_ARM32_CHECKPOINT:
        if (vm->checkpoint)
            vm->checkpoint(vm);
        break;
    case JBED_ARM32_THROW_STACK:
    case JBED_ARM32_THROW_LARGE_STACK:
        /* The prologue has not entered its try blocks or acquired its monitor. */
        r[7] &= ~7u;
        vm->pending_exception = vm->exceptions.stack_overflow;
        if (!vm->pending_exception)
            jbed_vm_fatal(vm, "StackOverflowError was not initialized");
        break;
    case JBED_ARM32_THROW_EXCEPTION:
        vm->pending_exception = r[0];
        if (!r[0])
            jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
        break;
    case JBED_ARM32_THROW_NULL: jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    case JBED_ARM32_THROW_INDEX: jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    case JBED_ARM32_THROW_ABSTRACT: jbed_vm_raise(vm, JBED_ERROR_ABSTRACT_METHOD, NULL);
    case JBED_ARM32_THROW_NO_CLASS: jbed_vm_raise(vm, JBED_ERROR_NO_CLASS_DEF, NULL);
    case JBED_ARM32_THROW_ARITHMETIC: jbed_vm_raise(vm, JBED_ERROR_ARITHMETIC, NULL);
    case JBED_ARM32_THROW_CLASS_CAST: jbed_vm_raise(vm, JBED_ERROR_CLASS_CAST, NULL);
    default:
        jbed_vm_fatal(vm, "Unknown managed runtime operation");
    }
}

typedef struct ExceptionRequest {
    JbedVm *vm;
    const char *name;
    JbedAddress result;
} ExceptionRequest;

static void make_exception(void *argument)
{
    ExceptionRequest *request = argument;
    request->result = jbed_vm_new_throwable(request->vm, request->name);
}

static void transfer_exception(JbedVm *vm, JbedArm32Frame *frame)
{
    if (vm->exception_no_catch_slot)
        vm->exceptions.no_catch = *jbed_vm_at(vm->heap.memory, vm->exception_no_catch_slot) != 0;
    if (vm->exception_no_catch_tag_slot)
        vm->exceptions.no_catch_tag = jbed_vm_word(vm->heap.memory, vm->exception_no_catch_tag_slot);
    JbedAddress stack_limit = vm->exceptions.stack_limit;
    JbedVmArmFrame saved = {frame->sp, frame->r[7], frame->lr,
                            frame->r[4], frame->r[5], frame->r[6]};
    JbedVmExceptionTransfer transfer;
    do {
        transfer = jbed_vm_handle_exception(&vm->exceptions, vm->pending_exception, saved);
        if (transfer.action != JBED_VM_RELEASE_MONITOR)
            break;
        monitor_result(vm, jbed_vm_monitor_unwind(&vm->monitors, &transfer));
        saved = transfer.frame;
        vm->pending_exception = transfer.throwable;
    } while (true);
    if (transfer.action == JBED_VM_ENTER_CATCH) {
        frame->r[0] = transfer.throwable;
        frame->r[4] = transfer.frame.r4;
        frame->r[5] = transfer.frame.r5;
        frame->r[6] = transfer.frame.r6;
        frame->r[7] = transfer.frame.fp;
        frame->r[8] = 1;
        frame->sp = transfer.frame.sp;
        frame->lr = transfer.frame.lr;
        frame->pc = transfer.handler_or_monitor;
        vm->pending_exception = 0;
    } else {
        vm->exceptions.stack_limit = stack_limit;
        frame->r[0] = frame->r[1] = 0;
        frame->pc = (uint32_t)(uintptr_t)jbed_arm32_leave;
    }
}

void jbed_vm_dispatch(JbedArm32Context *context, JbedArm32Operation operation,
                       JbedArm32Frame *frame)
{
    JbedVm *vm = context->user;
    ServiceCall call = {vm, operation, frame};
    JbedVmHeapRoot *roots = vm->heap.temporary_roots;
    JbedError error;
    if (!vm->services.protected_call)
        jbed_vm_fatal(vm, "VM has no native exception boundary");
    if (!vm->services.protected_call(vm->services.context, run_service, &call, &error)) {
        vm->heap.temporary_roots = roots;
        if (error.runtime_throwable) {
            vm->pending_exception = vm->heap.memory.address +
                (uint32_t)((uint8_t *)error.runtime_throwable - vm->heap.memory.data);
        } else if (error.kind == JBED_ERROR_OUT_OF_MEMORY) {
            vm->pending_exception = vm->out_of_memory;
        } else {
            ExceptionRequest request = {vm, exception_class(error.kind), 0};
            if (!vm->services.protected_call(vm->services.context, make_exception, &request, &error))
                vm->pending_exception = vm->out_of_memory;
            else
                vm->pending_exception = request.result;
            vm->heap.temporary_roots = roots;
        }
        if (!vm->pending_exception)
            jbed_vm_fatal(vm, "Unable to allocate the pending Java exception");
    }
    if (vm->pending_exception)
        transfer_exception(vm, frame);
}
