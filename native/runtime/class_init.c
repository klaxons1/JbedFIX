#include "class_init.h"
#include "execution.h"
#include "../compiler/vm/vm_words.h"

enum {
    CLASS_FLAGS = 12,
    CLASS_SUPER = 20,
    CLASS_INITIALIZER = 44,
    CLASS_INIT_FLAGS = 48,
    INIT_COMPLETE = -1,
    INIT_NOT_STARTED = 0,
    INIT_IN_PROGRESS = 1,
    INIT_FAILED = 2
};

static int8_t *init_flags(JbedVm *vm, JbedAddress klass)
{
    uint32_t offset = jbed_vm_word(vm->heap.memory, klass + CLASS_INIT_FLAGS);
    return offset ? (int8_t *)jbed_vm_at(vm->heap.memory, vm->isolate_statics + offset) : NULL;
}

static bool throw_new(JbedVm *vm, const char *name)
{
    JbedAddress exception = jbed_vm_new_throwable(vm, name);
    if (exception)
        vm->pending_exception = exception;
    return false;
}

static bool monitor_result(JbedVm *vm, JbedVmMonitorResult result)
{
    switch (result) {
    case JBED_MONITOR_DONE: return true;
    case JBED_MONITOR_NULL_POINTER: return throw_new(vm, "java/lang/NullPointerException");
    case JBED_MONITOR_ILLEGAL_STATE: return throw_new(vm, "java/lang/IllegalMonitorStateException");
    case JBED_MONITOR_ALLOCATION_FAILED: return throw_new(vm, "java/lang/OutOfMemoryError");
    case JBED_MONITOR_ILLEGAL_ARGUMENT: return throw_new(vm, "java/lang/IllegalArgumentException");
    case JBED_MONITOR_INTERRUPTED: return throw_new(vm, "java/lang/InterruptedException");
    case JBED_MONITOR_YIELD:
    case JBED_MONITOR_BLOCKED:
        jbed_vm_fatal(vm, "Class initialization requires a resuming scheduler");
    }
    jbed_vm_fatal(vm, "Invalid class initialization monitor result");
}

static bool run_initializer(JbedVm *vm, JbedAddress klass)
{
    JbedAddress superclass = jbed_vm_word(vm->heap.memory, klass + CLASS_SUPER);
    if (superclass && !jbed_vm_initialize_class(vm, superclass))
        return false;
    JbedAddress initializer = jbed_vm_word(vm->heap.memory, klass + CLASS_INITIALIZER);
    uint64_t ignored;
    return !initializer || jbed_vm_invoke(vm, initializer, NULL, 0, &ignored);
}

static bool initialization_failed(JbedVm *vm, JbedAddress klass)
{
    JbedBuffer memory = vm->heap.memory;
    int8_t *state = init_flags(vm, klass);
    if (state)
        *state = INIT_FAILED;
    else
        jbed_vm_put_word(memory, klass + CLASS_FLAGS,
                         jbed_vm_word(memory, klass + CLASS_FLAGS) & ~JBED_CLASS_PREPARED);
    if (!monitor_result(vm, jbed_vm_monitor_exit(&vm->monitors, klass)))
        return false;

    JbedAddress error_class = jbed_vm_find_class(vm, "java/lang/Error");
    if (!error_class || !vm->pending_exception)
        jbed_vm_fatal(vm, "Class initialization failed without an Error class or throwable");
    JbedAddress tag = jbed_vm_word(memory, vm->pending_exception);
    if (jbed_vm_exception_instance_of(vm->exceptions.memory, tag, error_class))
        return false;
    /* Base.init discards a non-Error throwable and throws a new plain Error. */
    return throw_new(vm, "java/lang/Error");
}

bool jbed_vm_initialize_class(JbedVm *vm, JbedAddress klass)
{
    JbedBuffer memory = vm->heap.memory;
    uint32_t flags = jbed_vm_word(memory, klass + CLASS_FLAGS);
    if (flags & JBED_CLASS_SKIP_INIT_IN_CURRENT_IMAGE)
        return true;
    int8_t *state = init_flags(vm, klass);
    if (state && *state < INIT_NOT_STARTED)
        return true;
    if (!monitor_result(vm, jbed_vm_monitor_enter(&vm->monitors, klass)))
        return initialization_failed(vm, klass);

    state = init_flags(vm, klass);
    if (state) {
        if (*state == INIT_NOT_STARTED) {
            *state = INIT_IN_PROGRESS;
            if (!run_initializer(vm, klass))
                return initialization_failed(vm, klass);
            /* Compiling from an initializer can replace the isolate statics. */
            *init_flags(vm, klass) = INIT_COMPLETE;
        } else if (*state > INIT_IN_PROGRESS) {
            throw_new(vm, "java/lang/NoClassDefFoundError");
            return initialization_failed(vm, klass);
        }
    } else {
        flags = jbed_vm_word(memory, klass + CLASS_FLAGS);
        if (!(flags & JBED_CLASS_INIT_STARTED)) {
            jbed_vm_put_word(memory, klass + CLASS_FLAGS, flags | JBED_CLASS_INIT_STARTED);
            if (!run_initializer(vm, klass))
                return initialization_failed(vm, klass);
            jbed_vm_put_word(memory, klass + CLASS_FLAGS,
                             jbed_vm_word(memory, klass + CLASS_FLAGS) |
                                 JBED_CLASS_SKIP_INIT_IN_CURRENT_IMAGE);
        } else if (!(flags & JBED_CLASS_PREPARED)) {
            throw_new(vm, "java/lang/NoClassDefFoundError");
            return initialization_failed(vm, klass);
        }
    }
    if (!monitor_result(vm, jbed_vm_monitor_exit(&vm->monitors, klass)))
        return initialization_failed(vm, klass);
    return true;
}

bool jbed_vm_static_initialize_class(JbedVm *vm, JbedAddress klass)
{
    JbedBuffer memory = vm->heap.memory;
    if (!klass)
        return throw_new(vm, "java/lang/NullPointerException");
    JbedAddress initializer = jbed_vm_word(memory, klass + CLASS_INITIALIZER);
    if (!initializer)
        jbed_vm_fatal(vm, "Static initialization requires an initializer");
    JbedAddress ancestor = klass;
    while (ancestor && (jbed_vm_word(memory, ancestor + CLASS_FLAGS) &
                        JBED_CLASS_SKIP_INIT_IN_CURRENT_IMAGE))
        ancestor = jbed_vm_word(memory, ancestor + CLASS_SUPER);
    if (ancestor && !jbed_vm_initialize_class(vm, ancestor))
        return false;
    uint64_t ignored;
    return ancestor == klass || jbed_vm_invoke(vm, initializer, NULL, 0, &ignored);
}
