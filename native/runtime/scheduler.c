#include "scheduler.h"
#include "arm32.h"
#include "execution.h"
#include "metadata_init.h"
#include "roots.h"
#include "isolate.h"
#include "../compiler/vm/vm_scheduler.h"
#include "../platform/vm/vm_os.h"
#if defined(__ANDROID__)
#include "../platform/android/android_jni.h"
#endif

#include <pthread.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>

enum {
    STACK_GUARD_BYTES = 256, STACK_OVERFLOW_BYTES = 512, ARRAY_DATA = 16,
    NCSS_BYTES = 256, NCSS_BASE = 12, NCSS_LIMIT = 16,
    NCSS_ADDRESS = 20, NCSS_FRAME = 24, NCSS_BUFFER = 28
};
static const uint32_t stack_guard_pattern = UINT32_C(0x1eab11fa);
static volatile sig_atomic_t preemption_pending;
static JbedVm *timer_owner;

void Jbed_timerEntry(void) { preemption_pending = 1; }
void *Scheduling_preemptionPendingField(void *runtime)
{
    (void)runtime;
    return (void *)&preemption_pending;
}

typedef struct Continuation {
    struct Continuation *next;
    JbedVm *vm;
    JbedAddress scheduled, isolate, statics, pending_exception;
    int32_t isolate_id;
    JbedArm32Context context, *arm;
    JbedVmNativeFrames native_frames;
    JbedAddress stack_limit, reserved_stack_limit, extended_stack_limit;
    JbedVmHeapRoot *temporary_roots;
    void **roots_base, **roots_top, **roots_limit;
    JbRef *parameters;
    pthread_t thread;
    bool worker, finished;
    void *root_storage[1024];
    JbRef argument_storage[257];
} Continuation;

struct JbedVmScheduler {
    pthread_mutex_t mutex;
    pthread_cond_t changed;
    Continuation *threads, *active;
    bool shutdown;
};

static void capture(JbedVm *vm, Continuation *thread)
{
    thread->arm = vm->arm;
    thread->statics = vm->isolate_statics;
    thread->isolate = vm->heap.current_isolate;
    thread->isolate_id = vm->isolate_id;
    thread->temporary_roots = vm->heap.temporary_roots;
    thread->native_frames = vm->native_frames;
    thread->stack_limit = vm->exceptions.stack_limit;
    thread->reserved_stack_limit = vm->exceptions.reserved_stack_limit;
    JbedAddress extended = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Base", "extendedStackLimit");
    thread->extended_stack_limit = extended ? jbed_vm_word(vm->heap.memory, extended) : 0;
    thread->pending_exception = vm->pending_exception;
    thread->roots_base = vm->native_roots_base;
    thread->roots_limit = vm->native_roots_limit;
    thread->roots_top = Jbed_nativeCallStateAdr;
    thread->parameters = Jbed_ParamPtr;
    vm->heap.no_allocation = (int32_t)Jbed_noAllocation;
    JbedAddress ncss = jbed_vm_word(vm->heap.memory, thread->scheduled + SCHEDULED_FIELD(ncss));
    if (ncss) {
        jbed_vm_put_word(vm->heap.memory, ncss + NCSS_ADDRESS, vm->native_frames.address);
        jbed_vm_put_word(vm->heap.memory, ncss + NCSS_FRAME, vm->native_frames.frame);
    }
    JbedAddress reserve_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Base", "runtimeReservedStackNesting");
    JbedAddress exception_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/DebugVm", "noException");
    uint32_t reserve = reserve_slot ? jbed_vm_word(vm->heap.memory, reserve_slot) : 0;
    jbed_vm_put_word(vm->heap.memory, thread->scheduled + SCHEDULED_FIELD(runtimeReservedStackNesting), reserve);
    jbed_vm_put_word(vm->heap.memory, thread->scheduled + SCHEDULED_FIELD(assertingStackLimit),
        reserve ? vm->exceptions.stack_limit : 0);
    if (exception_slot) jbed_vm_put_word(vm->heap.memory,
        thread->scheduled + SCHEDULED_FIELD(noExceptionNesting), jbed_vm_word(vm->heap.memory, exception_slot));
}

static void restore(JbedVm *vm, Continuation *thread)
{
    vm->arm = thread->arm;
    jbed_vm_switch_statics(vm, thread->statics);
    vm->heap.current_isolate = thread->isolate;
    vm->isolate_id = thread->isolate_id;
    vm->heap.temporary_roots = thread->temporary_roots;
    vm->native_frames = thread->native_frames;
    JbedAddress ncss_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/NativeCallStateStack", "currentNcss");
    if (ncss_slot) jbed_vm_put_word(vm->heap.memory, ncss_slot,
        jbed_vm_word(vm->heap.memory, thread->scheduled + SCHEDULED_FIELD(ncss)));
    vm->exceptions.stack_limit = thread->stack_limit;
    vm->exceptions.reserved_stack_limit = thread->reserved_stack_limit;
    JbedAddress extended = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Base", "extendedStackLimit");
    if (extended) jbed_vm_put_word(vm->heap.memory, extended, thread->extended_stack_limit);
    vm->pending_exception = thread->pending_exception;
    vm->native_roots_base = thread->roots_base;
    vm->native_roots_limit = thread->roots_limit;
    vm->native_roots_top = Jbed_nativeCallStateAdr = thread->roots_top;
    vm->parameters = Jbed_ParamPtr = thread->parameters;
    JbedAddress reserve_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/Base", "runtimeReservedStackNesting");
    JbedAddress exception_slot = jbed_vm_static_field_slot(vm, "com/jbed/runtime/DebugVm", "noException");
    if (reserve_slot) jbed_vm_put_word(vm->heap.memory, reserve_slot,
        jbed_vm_word(vm->heap.memory, thread->scheduled + SCHEDULED_FIELD(runtimeReservedStackNesting)));
    if (exception_slot) jbed_vm_put_word(vm->heap.memory, exception_slot,
        jbed_vm_word(vm->heap.memory, thread->scheduled + SCHEDULED_FIELD(noExceptionNesting)));
}

static JbedVmScheduler *scheduler(JbedVm *vm)
{
    if (vm->scheduler) return vm->scheduler;
    JbedVmScheduler *result = calloc(1, sizeof(*result));
    Continuation *main = calloc(1, sizeof(*main));
    if (!result || !main) {
        free(result); free(main);
        jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, "Cannot allocate scheduler continuation");
    }
    pthread_mutex_init(&result->mutex, NULL);
    pthread_cond_init(&result->changed, NULL);
    main->vm = vm;
    main->thread = pthread_self();
    main->scheduled = jbed_vm_word(vm->heap.memory, vm->monitors.image.current_slot);
    capture(vm, main);
    result->threads = result->active = main;
    vm->scheduler = result;
    return result;
}

static void *run_thread(void *context);

static void reap_finished(JbedVmScheduler *state)
{
    pthread_mutex_lock(&state->mutex);
    Continuation **link = &state->threads;
    while (*link) {
        Continuation *thread = *link;
        if (!thread->finished || thread == state->active) {
            link = &thread->next;
            continue;
        }
        *link = thread->next;
        pthread_mutex_unlock(&state->mutex);
        if (thread->worker) pthread_join(thread->thread, NULL);
        free(thread);
        pthread_mutex_lock(&state->mutex);
    }
    pthread_mutex_unlock(&state->mutex);
}

static Continuation *find_thread(JbedVm *vm, JbedAddress scheduled)
{
    JbedVmScheduler *state = vm->scheduler;
    for (Continuation *thread = state->threads; thread; thread = thread->next)
        if (thread->scheduled == scheduled) return thread;
    Continuation *thread = calloc(1, sizeof(*thread));
    if (!thread) return NULL;
    JbedBuffer memory = vm->heap.memory;
    JbedAddress saved = jbed_vm_word(memory, scheduled + SCHEDULED_FIELD(context));
    if (!saved) { free(thread); return NULL; }
    thread->vm = vm;
    thread->scheduled = scheduled;
    thread->statics = vm->isolate_statics;
    thread->isolate = vm->heap.current_isolate;
    thread->isolate_id = vm->isolate_id;
    thread->context = *vm->arm;
    thread->context.host_sp = thread->context.host_depth = 0;
    thread->context.frame = NULL;
    thread->context.activations = NULL;
    thread->context.stack_top = jbed_vm_word(memory, scheduled + SCHEDULED_FIELD(stackBase));
    thread->context.stack_limit = jbed_vm_word(memory, saved);
    thread->arm = &thread->context;
    thread->native_frames = vm->native_frames;
    JbedAddress ncss = jbed_vm_word(memory, scheduled + SCHEDULED_FIELD(ncss));
    if (ncss) {
        thread->native_frames.base = jbed_vm_word(memory, ncss + NCSS_BASE);
        thread->native_frames.limit = jbed_vm_word(memory, ncss + NCSS_LIMIT);
        thread->native_frames.address = jbed_vm_word(memory, ncss + NCSS_ADDRESS);
    }
    thread->native_frames.frame = thread->native_frames.base;
    thread->stack_limit = thread->reserved_stack_limit = (JbedAddress)thread->context.stack_limit;
    thread->extended_stack_limit = jbed_vm_word(memory, scheduled + SCHEDULED_FIELD(stackLimit));
    thread->roots_base = thread->roots_top = thread->root_storage;
    thread->roots_limit = thread->root_storage + 1024;
    thread->parameters = thread->argument_storage + 1;
    thread->worker = true;
    if (pthread_create(&thread->thread, NULL, run_thread, thread)) {
        free(thread); return NULL;
    }
    thread->next = state->threads;
    state->threads = thread;
    return thread;
}

static JbedAddress static_slot(JbedVm *vm, const char *owner, const char *name)
{
    JbedAddress slot = jbed_vm_static_field_slot(vm, owner, name);
    if (!slot) jbed_vm_raise(vm, JBED_ERROR_NO_SUCH_FIELD, name);
    return slot;
}

static uint64_t read_long(JbedBuffer memory, JbedAddress address)
{
    return jbed_vm_word(memory, address) | (uint64_t)jbed_vm_word(memory, address + 4) << 32;
}

static JbedAddress select_ready(JbedVm *vm)
{
    JbedVmMonitors *monitors = &vm->monitors;
    JbedBuffer memory = vm->heap.memory;
    JbedAddress current = jbed_vm_word(memory, monitors->image.current_slot);
    JbedAddress root = jbed_vm_word(memory, monitors->image.ready_root_slot);
    JbedAddress dummy = jbed_vm_word(memory,
        static_slot(vm, "com/jbed/runtime/Scheduler", "dummy"));
    xElapsed(monitors);
    uint64_t time = read_long(memory, monitors->image.time_slot);
    bool dummy_expired = false;
    for (JbedAddress thread = jbed_vm_word(memory, root + SCHEDULED_FIELD(nextTimeout)); thread;) {
        JbedAddress next = jbed_vm_word(memory, thread + SCHEDULED_FIELD(nextTimeout));
        if ((int64_t)read_long(memory, thread + SCHEDULED_FIELD(timeout)) <= (int64_t)time) {
            if (!*jbed_vm_at(memory, thread + SCHEDULED_FIELD(schedF)))
                xRTInsertSched(monitors, thread);
            xRTRemoveTimeout(memory, thread);
            if (thread == dummy) dummy_expired = true;
        }
        thread = next;
    }
    if (vm->signals.pending_slot) {
        JbedAddress isolate = vm->heap.current_isolate;
        if (vm->signals.hub && isolate && jbed_vm_take_signal_flags(vm->signals.hub,
            jbed_vm_word(memory, isolate + offsetof(JbedRomIsolate, listIndex))))
            *jbed_vm_at(memory, vm->signals.pending_slot) = 1;
        jbed_vm_process_signals(vm);
    }
    int32_t fairness = (int32_t)jbed_vm_word(memory, current + SCHEDULED_FIELD(fairness));
    if (fairness > 9) {
        JbedAddress next = jbed_vm_word(memory, current + SCHEDULED_FIELD(nextScheduled));
        if (next && next != current &&
            jbed_vm_word(memory, next + SCHEDULED_FIELD(prio)) ==
                jbed_vm_word(memory, current + SCHEDULED_FIELD(prio))) {
            xRTReSched(monitors, current);
            jbed_vm_put_word(memory, current + SCHEDULED_FIELD(fairness), 0);
        }
    } else {
        jbed_vm_put_word(memory, current + SCHEDULED_FIELD(fairness), (uint32_t)(fairness + 1));
    }
    if (dummy_expired) {
        uint32_t priority = jbed_vm_word(memory, dummy + SCHEDULED_FIELD(prio));
        jbed_vm_put_word(memory, dummy + SCHEDULED_FIELD(prio), 11);
        xRTReSched(monitors, dummy);
        jbed_vm_put_word(memory, dummy + SCHEDULED_FIELD(prio), priority);
    }
    return jbed_vm_word(memory, root + SCHEDULED_FIELD(nextScheduled));
}

static void wait_for_ready(JbedVm *vm, JbedVmScheduler *state)
{
    JbedBuffer memory = vm->heap.memory;
    JbedAddress root = jbed_vm_word(memory, vm->monitors.image.ready_root_slot);
    uint64_t earliest = UINT64_MAX;
    for (JbedAddress thread = jbed_vm_word(memory, root + SCHEDULED_FIELD(nextTimeout)); thread;
         thread = jbed_vm_word(memory, thread + SCHEDULED_FIELD(nextTimeout))) {
        uint64_t timeout = read_long(memory, thread + SCHEDULED_FIELD(timeout));
        if (timeout < earliest) earliest = timeout;
    }
    if (earliest == UINT64_MAX) {
        pthread_cond_wait(&state->changed, &state->mutex);
        return;
    }
    uint64_t now = vm->monitors.scheduling.elapsed_micros(vm->monitors.scheduling.context);
    if (earliest <= now) return;
    uint64_t delay = earliest - now;
    struct timespec deadline;
    clock_gettime(CLOCK_REALTIME, &deadline);
    deadline.tv_sec += (time_t)(delay / 1000000);
    deadline.tv_nsec += (long)(delay % 1000000) * 1000;
    if (deadline.tv_nsec >= 1000000000) {
        ++deadline.tv_sec; deadline.tv_nsec -= 1000000000;
    }
    pthread_cond_timedwait(&state->changed, &state->mutex, &deadline);
}

void jbed_vm_schedule(void *context)
{
    JbedVm *vm = context;
    JbedBuffer memory = vm->heap.memory;
    JbedAddress previous = jbed_vm_word(memory, vm->monitors.image.current_slot);
    JbedAddress next = select_ready(vm);
    if (next && next == previous) {
        jbed_vm_put_word(memory, next + SCHEDULED_FIELD(status), S_READY);
        uint64_t now = vm->monitors.scheduling.elapsed_micros(vm->monitors.scheduling.context);
        jbed_vm_put_word(memory, vm->monitors.image.time_slot, (uint32_t)now);
        jbed_vm_put_word(memory, vm->monitors.image.time_slot + 4, (uint32_t)(now >> 32));
        return;
    }
    JbedVmScheduler *state = scheduler(vm);
    pthread_mutex_lock(&state->mutex);
    Continuation *old = state->active;
    old->scheduled = previous;
    capture(vm, old);
    while (!next && !state->shutdown) {
        wait_for_ready(vm, state);
        next = select_ready(vm);
    }
    if (state->shutdown) {
        pthread_mutex_unlock(&state->mutex);
        pthread_exit(NULL);
    }
    Continuation *target = find_thread(vm, next);
    if (!target || target->finished) {
        pthread_mutex_unlock(&state->mutex);
        jbed_vm_fatal(vm, "Runnable Scheduled has no resumable context");
    }
    bool completed = jbed_vm_word(memory, previous + SCHEDULED_FIELD(status)) == S_HALTED;
    old->finished = completed;
    if (completed) {
        old->temporary_roots = NULL;
        old->scheduled = 0;
    }
    jbed_vm_put_word(memory, previous + SCHEDULED_FIELD(paramPtr), (uint32_t)(uintptr_t)old->parameters);
    restore(vm, target);
    jbed_vm_put_word(memory, vm->monitors.image.current_slot, next);
    jbed_vm_put_word(memory, next + SCHEDULED_FIELD(status), S_READY);
    uint64_t now = vm->monitors.scheduling.elapsed_micros(vm->monitors.scheduling.context);
    jbed_vm_put_word(memory, vm->monitors.image.time_slot, (uint32_t)now);
    jbed_vm_put_word(memory, vm->monitors.image.time_slot + 4, (uint32_t)(now >> 32));
    state->active = target;
    pthread_cond_broadcast(&state->changed);
    if (completed) {
        pthread_mutex_unlock(&state->mutex);
#if defined(__ANDROID__)
        jbed_android_detach_thread();
#endif
        pthread_exit(NULL);
    }
    while (state->active != old && !state->shutdown)
        pthread_cond_wait(&state->changed, &state->mutex);
    bool shutdown = state->shutdown;
    pthread_mutex_unlock(&state->mutex);
    if (shutdown) {
#if defined(__ANDROID__)
        jbed_android_detach_thread();
#endif
        pthread_exit(NULL);
    }
    reap_finished(state);
}

static void *run_thread(void *context)
{
    Continuation *thread = context;
    JbedVm *vm = thread->vm;
    JbedVmScheduler *state = vm->scheduler;
    pthread_mutex_lock(&state->mutex);
    while (state->active != thread && !state->shutdown)
        pthread_cond_wait(&state->changed, &state->mutex);
    bool shutdown = state->shutdown;
    pthread_mutex_unlock(&state->mutex);
    if (shutdown) return NULL;
    reap_finished(state);
#if defined(__ANDROID__)
    if (!jbed_android_attach_thread()) jbed_vm_fatal(vm, "Cannot attach a scheduled thread to Android");
#endif
    jbed_vm_bind(vm);
    JbedAddress saved = jbed_vm_word(vm->heap.memory, thread->scheduled + SCHEDULED_FIELD(context));
    JbedAddress entry = jbed_vm_word(vm->heap.memory, saved + 20);
    uint64_t result;
    if (!jbed_vm_invoke(vm, entry, NULL, 0, &result)) {
        /* Preserve the uncaught exception for the Scheduled's handler. */
        jbed_vm_put_word(vm->heap.memory, thread->scheduled + SCHEDULED_FIELD(exception), vm->pending_exception);
    }
    if (*jbed_vm_at(vm->heap.memory, thread->scheduled + SCHEDULED_FIELD(schedF)))
        xRTRemoveSched(&vm->monitors, thread->scheduled);
    jbed_vm_put_word(vm->heap.memory, thread->scheduled + SCHEDULED_FIELD(status), S_HALTED);
    jbed_vm_schedule(vm);
    return NULL;
}

void jbed_vm_scheduler_wake(JbedVm *vm)
{
    JbedVmScheduler *state = vm ? vm->scheduler : NULL;
    if (!state) return;
    pthread_mutex_lock(&state->mutex);
    pthread_cond_broadcast(&state->changed);
    pthread_mutex_unlock(&state->mutex);
}

void jbed_vm_scheduler_dispose(JbedVm *vm)
{
    if (timer_owner == vm) {
        struct itimerval stopped = {0};
        setitimer(ITIMER_VIRTUAL, &stopped, NULL);
        preemption_pending = 0;
        timer_owner = NULL;
    }
    JbedVmScheduler *state = vm->scheduler;
    if (!state) return;
    pthread_mutex_lock(&state->mutex);
    state->shutdown = true;
    pthread_cond_broadcast(&state->changed);
    pthread_mutex_unlock(&state->mutex);
    for (Continuation *thread = state->threads; thread;) {
        Continuation *next = thread->next;
        if (thread->worker) pthread_join(thread->thread, NULL);
        free(thread);
        thread = next;
    }
    pthread_cond_destroy(&state->changed);
    pthread_mutex_destroy(&state->mutex);
    free(state);
    vm->scheduler = NULL;
}

void jbed_vm_scheduler_rebase_statics(JbedVm *vm, JbedAddress old_base, JbedAddress new_base)
{
    JbedVmScheduler *state = vm->scheduler;
    for (Continuation *thread = state ? state->threads : NULL; thread; thread = thread->next) {
        if (thread->finished) continue;
        if (thread->statics != old_base) continue;
        thread->statics = new_base;
        thread->arm->statics = (void *)(uintptr_t)new_base;
        if (thread->arm->frame && thread->arm->frame->r[9] == old_base)
            thread->arm->frame->r[9] = new_base;
        for (JbedArm32Activation *call = thread->arm->activations; call; call = call->previous)
            if (call->caller_frame && call->caller_frame->r[9] == old_base)
                call->caller_frame->r[9] = new_base;
    }
}

static void visit_slot(const JbedVmRootVisitor *visitor, JbedAddress *slot)
{
    visitor->stack_reference(visitor->context, (JbedAddress)(uintptr_t)slot);
}

void jbed_vm_scheduler_visit_roots(JbedVm *vm, const JbedVmRootVisitor *local,
                                   const JbedVmRootVisitor *global)
{
    JbedVmScheduler *state = vm->scheduler;
    for (Continuation *thread = state ? state->threads : NULL; thread; thread = thread->next) {
        const JbedVmRootVisitor *visitor = thread->isolate ? local : global;
        visit_slot(visitor, &thread->scheduled);
        if (thread == state->active || thread->finished) continue;
        visit_slot(visitor, &thread->isolate);
        visit_slot(visitor, &thread->pending_exception);
        jbed_vm_visit_arm_roots(vm, thread->arm, visitor);
        for (JbedVmHeapRoot *root = thread->temporary_roots; root; root = root->previous)
            visit_slot(visitor, &root->value);
        JbedVmNativeRoot handle;
        void **cursor = thread->roots_base;
        while (jbed_vm_next_native_root(vm, &cursor, thread->roots_top, &handle)) {
            bool duplicate = false;
            for (JbedVmHeapRoot *root = thread->temporary_roots; root; root = root->previous)
                if (!handle.interior && handle.slot == &root->value) duplicate = true;
            JbedVmNativeRoot earlier;
            void **previous = thread->roots_base;
            while (jbed_vm_next_native_root(vm, &previous, handle.record, &earlier))
                if (earlier.slot == handle.slot ||
                    (handle.interior && earlier.interior == handle.interior)) duplicate = true;
            if (duplicate) continue;
            if (handle.interior)
                visitor->internal_pointer(visitor->context, (JbedAddress)(uintptr_t)(handle.record + 1));
            else
                visit_slot(visitor, handle.slot);
        }
    }
}

void jbed_vm_scheduler_fix_native_pointers(JbedVm *vm)
{
    JbedVmScheduler *state = vm->scheduler;
    for (Continuation *thread = state ? state->threads : NULL; thread; thread = thread->next)
        if (thread != state->active && !thread->finished)
            jbed_vm_fix_native_pointers(vm, thread->roots_base, thread->roots_top);
}

void Base_setStackArray(JbedAddress scheduled, JbedAddress array, uint32_t reserved)
{
    JbedVm *vm = jbed_vm_current();
    JbedBuffer memory = vm->heap.memory;
    if (!scheduled) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    jbed_vm_put_word(memory, scheduled + SCHEDULED_FIELD(stack), array);
    if (!array) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    JbedAddress base = array + ARRAY_DATA + jbed_vm_word(memory, array + 12);
    jbed_vm_put_word(memory, scheduled + SCHEDULED_FIELD(stackBase), base);
    jbed_vm_put_word(memory, scheduled + SCHEDULED_FIELD(stackLimit),
        array + ARRAY_DATA + STACK_GUARD_BYTES + STACK_OVERFLOW_BYTES);
    jbed_vm_put_word(memory, scheduled + SCHEDULED_FIELD(context), base - reserved);
    for (uint32_t offset = 0; offset < STACK_GUARD_BYTES; offset += 4)
        jbed_vm_put_word(memory, array + ARRAY_DATA + offset, stack_guard_pattern);
}

static JbedAddress named_method(JbedVm *vm, const char *owner, const char *method_name)
{
    JbedAddress descriptor = jbed_vm_find_class(vm, owner);
    JbedClass *klass = descriptor ? jbed_class_object(&vm->classes,
        jbed_vm_word(vm->heap.memory, descriptor + 16)) : NULL;
    JbedNameId name = jbed_reflection_id(&vm->method_names, (const uint8_t *)method_name,
        strlen(method_name), false);
    for (JbedMethod *method = klass ? klass->methods : NULL; method; method = method->next)
        if (method->name_id == name && method->code_address)
            return method->code_address;
    jbed_vm_raise(vm, JBED_ERROR_NO_SUCH_METHOD, method_name);
}

void Scheduler_RTOneshotRun(void)
{
    JbedVm *vm = jbed_vm_current();
    JbedBuffer memory = vm->heap.memory;
    JbedAddress current = jbed_vm_word(memory, vm->monitors.image.current_slot);
    JbedAddress dummy = jbed_vm_word(memory,
        static_slot(vm, "com/jbed/runtime/Scheduler", "dummy"));
    if (current == dummy) jbed_vm_fatal(vm, "The scheduler dummy cannot run a Java Thread");
    JbedVmHeapRoot root = {current, current, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbedAddress thread = jbed_vm_word(memory, current + SCHEDULED_FIELD(thread));
    if (!thread) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    enum { THREAD_RUN_SLOT = 20 };
    JbedAddress entry = jbed_vm_word(memory, jbed_vm_word(memory, thread) + THREAD_RUN_SLOT);
    uint64_t ignored;
    if (!jbed_vm_invoke(vm, entry, &thread, 1, &ignored)) {
        JbedAddress throwable = vm->pending_exception;
        vm->pending_exception = 0;
        entry = named_method(vm, "com/jbed/runtime/Isolate", "uncaughtException");
        (void)jbed_vm_invoke(vm, entry, &throwable, 1, &ignored);
        vm->pending_exception = 0;
    }
    entry = named_method(vm, "com/jbed/runtime/Scheduled", "destroy0");
    current = root.value;
    (void)jbed_vm_invoke(vm, entry, &current, 1, &ignored);
    vm->heap.temporary_roots = root.previous;
}

void SchedulerInlines_createNewThreadState(JbedAddress scheduled)
{
    JbedVm *vm = jbed_vm_current();
    JbedBuffer memory = vm->heap.memory;
    JbedAddress base = jbed_vm_word(memory, scheduled + SCHEDULED_FIELD(stackBase));
    JbedAddress limit = jbed_vm_word(memory, scheduled + SCHEDULED_FIELD(stackLimit));
    uint32_t reserved = jbed_vm_word(memory,
        static_slot(vm, "com/jbed/runtime/SysInfo", "reservedStackSpace"));
    jbed_vm_put_word(memory, base - 4, (JbedAddress)(uintptr_t)jbed_arm32_run_thread | 1);
    jbed_vm_put_word(memory, base - 8, 0);
    jbed_vm_put_word(memory, base - 24, limit + reserved);
    jbed_vm_put_word(memory, scheduled + SCHEDULED_FIELD(context), base - 24);
}

void Scheduling_createNewThreadState(JbedAddress scheduled)
{
    JbedVm *vm = jbed_vm_current();
    JbedVmHeapRoot root = {scheduled, scheduled, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    uint32_t size = jbed_vm_word(vm->heap.memory,
        static_slot(vm, "com/jbed/runtime/SysInfo", "initialStackSize"));
    jbed_vm_next_allocate_locked(&vm->heap);
    JbedAddress array = jbed_vm_allocate_array(vm,
        vm->primitive_array_classes[JBED_TYPE_BYTE], (int32_t)(size + 256), false);
    scheduled = root.value;
    Base_setStackArray(scheduled, array, 0);
    SchedulerInlines_createNewThreadState(scheduled);
    /* A parked native call retains its own state buffer as well as its host stack. */
    JbedAddress ncss = jbed_vm_allocate_object(vm,
        jbed_vm_find_class(vm, "com/jbed/runtime/NativeCallStateStack"), false);
    jbed_vm_put_word(vm->heap.memory, root.value + SCHEDULED_FIELD(ncss), ncss);
    jbed_vm_next_allocate_locked(&vm->heap);
    JbedAddress buffer = jbed_vm_allocate_array(vm,
        vm->primitive_array_classes[JBED_TYPE_BYTE], NCSS_BYTES, false);
    ncss = jbed_vm_word(vm->heap.memory, root.value + SCHEDULED_FIELD(ncss));
    JbedAddress base = buffer + ARRAY_DATA;
    jbed_vm_put_word(vm->heap.memory, ncss + NCSS_BUFFER, buffer);
    jbed_vm_put_word(vm->heap.memory, ncss + NCSS_BASE, base);
    jbed_vm_put_word(vm->heap.memory, ncss + NCSS_LIMIT, base + NCSS_BYTES);
    jbed_vm_put_word(vm->heap.memory, ncss + NCSS_ADDRESS, base + 4);
    jbed_vm_put_word(vm->heap.memory, ncss + NCSS_FRAME, base + 4);
    vm->heap.temporary_roots = root.previous;
}

void Scheduling_yieldToScheduler(bool preemption)
{
    (void)preemption;
    jbed_vm_schedule(jbed_vm_current());
}

void Scheduling_schedule(void)
{
    JbedVm *vm = jbed_vm_current();
    JbedBuffer memory = vm->heap.memory;
    JbedAddress pending = static_slot(vm, "com/jbed/runtime/Scheduling", "preemptionPending");
    JbedAddress ticks = static_slot(vm, "com/jbed/runtime/Scheduling", "rttickCounter");
    jbed_vm_put_word(memory, pending, 0);
    preemption_pending = 0;
    OPL_os_resetTimer();
    jbed_vm_put_word(memory, ticks, jbed_vm_word(memory, ticks) + 1);
    jbed_vm_schedule(vm);
}

void jbed_vm_scheduler_checkpoint(JbedVm *vm)
{
    if (!preemption_pending || timer_owner != vm) return;
    if (jbed_vm_word(vm->heap.memory, vm->monitors.image.current_slot) &&
        jbed_vm_word(vm->heap.memory, vm->monitors.image.ready_root_slot))
        Scheduling_schedule();
}

void jbed_vm_scheduler_initialize_timer(JbedVm *vm)
{
    uint32_t period = jbed_vm_word(vm->heap.memory,
        static_slot(vm, "com/jbed/runtime/SysInfo", "schedulerPeriod"));
    preemption_pending = 0;
    timer_owner = vm;
    if (OPL_os_initTimer((int)period))
        jbed_vm_raise(vm, JBED_ERROR_INTERNAL, "Cannot initialize the VM scheduler timer");
}

void jbed_vm_scheduler_start_timer(JbedVm *vm)
{
    if (timer_owner != vm) jbed_vm_scheduler_initialize_timer(vm);
    if (OPL_os_startTimer())
        jbed_vm_raise(vm, JBED_ERROR_INTERNAL, "Cannot start the VM scheduler timer");
}

int32_t jbed_vm_scheduler_iterate(JbedVm *vm, int32_t milliseconds)
{
    JbedBuffer memory = vm->heap.memory;
    JbedAddress dummy = jbed_vm_word(memory,
        static_slot(vm, "com/jbed/runtime/Scheduler", "dummy"));
    if (jbed_vm_word(memory, vm->monitors.image.current_slot) != dummy || milliseconds > INT32_MAX / 1000) {
        JbedAddress throwable = jbed_vm_new_throwable(vm, "java/lang/RuntimeException");
        JbedError error = {.kind = JBED_ERROR_THROWABLE,
            .runtime_throwable = jbed_vm_at(memory, throwable)};
        jbed_raise(&vm->services, &error);
    }
    JbedVmHeapRoot root = {dummy, dummy, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbedAddress force = static_slot(vm, "com/jbed/runtime/Scheduler", "forceYield");
    JbedAddress pending = static_slot(vm, "com/jbed/runtime/Scheduler", "signalPending");
    *jbed_vm_at(memory, force) = 0;
    xRTReSched(&vm->monitors, root.value);
    if (milliseconds > 0) xRTInsertTO(&vm->monitors, root.value, (uint32_t)milliseconds * UINT64_C(1000));
    do {
        jbed_vm_schedule(vm);
    } while (*jbed_vm_at(memory, pending) &&
        (*jbed_vm_at(memory, root.value + SCHEDULED_FIELD(timeoutF)) || milliseconds <= 0));

    int32_t delay;
    if (*jbed_vm_at(memory, root.value + SCHEDULED_FIELD(timeoutF)) || milliseconds <= 0) {
        xRTRemoveTimeout(memory, root.value);
        JbedAddress queue = jbed_vm_word(memory, vm->monitors.image.ready_root_slot);
        int64_t earliest = INT64_MAX;
        bool has_timeout = false;
        for (JbedAddress thread = jbed_vm_word(memory, queue + SCHEDULED_FIELD(nextTimeout)); thread;
             thread = jbed_vm_word(memory, thread + SCHEDULED_FIELD(nextTimeout))) {
            int64_t timeout = (int64_t)read_long(memory, thread + SCHEDULED_FIELD(timeout));
            if (timeout < earliest) earliest = timeout;
            has_timeout = true;
        }
        int64_t left = has_timeout ?
            (int64_t)((uint64_t)earliest - read_long(memory, vm->monitors.image.time_slot)) / 1000 : INT32_MAX;
        delay = left < 0 ? 0 : left > INT32_MAX ? INT32_MAX : (int32_t)left;
    } else {
        delay = *jbed_vm_at(memory, force) ? -4 : -1;
    }
    JbedAddress count = static_slot(vm, "com/jbed/runtime/Scheduler", "scheduledCount");
    if (!jbed_vm_word(memory, count))
        *jbed_vm_at(memory, static_slot(vm, "com/jbed/runtime/Isolate", "doExit")) = 1;
    vm->heap.temporary_roots = root.previous;
    return delay;
}

int32_t Scheduler_xWaitToBecomeIdle(int32_t milliseconds)
{
    return jbed_vm_scheduler_iterate(jbed_vm_current(), milliseconds);
}

void Scheduler_forceYieldToDummy(void)
{
    JbedVm *vm = jbed_vm_current();
    JbedBuffer memory = vm->heap.memory;
    JbedAddress dummy = jbed_vm_word(memory,
        static_slot(vm, "com/jbed/runtime/Scheduler", "dummy"));
    if (jbed_vm_word(memory, vm->monitors.image.current_slot) == dummy) return;
    *jbed_vm_at(memory, static_slot(vm, "com/jbed/runtime/Scheduler", "forceYield")) = 1;
    xRTRemoveTimeout(memory, dummy);
    xRTInsertTO(&vm->monitors, dummy, 0);
    jbed_vm_schedule(vm);
}

bool DebugVm_checkStackPattern(void)
{
    JbedVm *vm = jbed_vm_current();
    JbedBuffer memory = vm->heap.memory;
    JbedAddress thread = jbed_vm_word(memory, vm->monitors.image.current_slot);
    JbedAddress array = thread ? jbed_vm_word(memory, thread + SCHEDULED_FIELD(stack)) : 0;
    if (!array) return true;
    for (uint32_t offset = 0; offset < STACK_GUARD_BYTES; offset += 4)
        if (jbed_vm_word(memory, array + ARRAY_DATA + offset) != stack_guard_pattern)
            return false;
    return true;
}

static void set_stack_limit(JbedVm *vm, JbedAddress limit)
{
    vm->exceptions.stack_limit = limit;
    vm->arm->stack_limit = limit;
    if (vm->arm->frame) vm->arm->frame->r[10] = limit;
}

void Base_useRuntimeReservedStackSpace(void)
{
    JbedVm *vm = jbed_vm_current();
    JbedBuffer memory = vm->heap.memory;
    JbedAddress nesting = static_slot(vm, "com/jbed/runtime/Base", "runtimeReservedStackNesting");
    uint32_t count = jbed_vm_word(memory, nesting);
    if (!count) {
        if (!vm->exceptions.stack_limit)
            jbed_vm_fatal(vm, "Cannot reserve runtime stack without a stack limit");
        JbedAddress limit = vm->arm->frame->r[7] - STACK_OVERFLOW_BYTES;
        uint32_t reserve = jbed_vm_word(memory,
            static_slot(vm, "com/jbed/runtime/SysInfo", "reservedStackSpace"));
        bool native = vm->native_frames.frame != vm->native_frames.base;
        vm->exceptions.reserved_stack_limit = native ? limit + reserve : limit;
        jbed_vm_put_word(memory, static_slot(vm, "com/jbed/runtime/Base", "extendedStackLimit"),
                         native ? limit : limit - reserve);
        set_stack_limit(vm, limit);
    }
    jbed_vm_put_word(memory, nesting, count + 1);
}

void Base_endUseRuntimeReservedStackSpace(void)
{
    JbedVm *vm = jbed_vm_current();
    JbedBuffer memory = vm->heap.memory;
    JbedAddress nesting = static_slot(vm, "com/jbed/runtime/Base", "runtimeReservedStackNesting");
    uint32_t count = jbed_vm_word(memory, nesting);
    if (!count) jbed_vm_fatal(vm, "Runtime stack reserve is not active");
    jbed_vm_put_word(memory, nesting, --count);
    if (count) return;
    JbedAddress thread = jbed_vm_word(memory, vm->monitors.image.current_slot);
    JbedAddress extended = jbed_vm_word(memory, thread + SCHEDULED_FIELD(stackLimit));
    jbed_vm_put_word(memory, static_slot(vm, "com/jbed/runtime/Base", "extendedStackLimit"), extended);
    uint32_t reserve = jbed_vm_word(memory,
        static_slot(vm, "com/jbed/runtime/SysInfo", "reservedStackSpace"));
    vm->exceptions.reserved_stack_limit = extended + reserve;
    int32_t common = (int32_t)jbed_vm_word(memory,
        static_slot(vm, "com/jbed/runtime/Base", "commonStackNesting"));
    JbedAddress limit = common > 0 ? jbed_vm_word(memory,
        static_slot(vm, "com/jbed/runtime/Base", "commonStackLimit")) :
        vm->native_frames.frame != vm->native_frames.base ? extended : extended + reserve;
    set_stack_limit(vm, limit);
}
