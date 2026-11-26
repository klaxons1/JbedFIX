#include "vm_async.h"
#include "jbni_objects.h"

#include <limits.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

extern VmSignal *JbedExp_getCurrentSignal(void);
extern void Jbed_signal(VmSignal *);
extern void Jbed_signalFast(VmSignal *);
extern int64_t CPL_os_getMillisElapsed(void);

#if UINTPTR_MAX == UINT32_MAX
_Static_assert(offsetof(VmSignal, notifier) == 36, "Java signal notifier");
_Static_assert(offsetof(VmSignal, asyncBuffer) == 52, "Java signal async buffer");
_Static_assert(offsetof(VmCallback, notifier) == 24, "native notifier");
_Static_assert(offsetof(VmCallback, signalled) == 168, "native callback signal flag");
_Static_assert(offsetof(VmFinalizer, run) == 184, "async finalizer");
_Static_assert(offsetof(VmMutex, next) == 32, "async mutex list");
#endif

static VmCallback *callbacks;

VmNotifier *vm_current_notifier(void)
{
    VmNotifier *n = JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier;
    return n ? n : &JbedExp_getCurrentSignal()->notifier;
}

static VmSignal *notifier_signal(VmNotifier *n)
{
    return (VmSignal *)((char *)n - offsetof(VmSignal, notifier));
}

static VmCallback *notifier_callback(VmNotifier *n)
{
    return (VmCallback *)((char *)n - offsetof(VmCallback, notifier));
}

void *ASYNC_getStateFromNotifier(VmNotifier *n)
{
    if (n->notify)
        return notifier_callback(n)->state_data;
    return notifier_signal(n)->asyncBuffer->data;
}

static void mark_signalled(VmNotifier *n)
{
    notifier_callback(n)->signalled = 1;
}

static VmCallback **find_callback(VmCallback *item)
{
    VmCallback **link = &callbacks;
    while (*link && *link != item)
        link = &(*link)->next;
    return link;
}

/* 0x2bd49c. A reset of a registered item retains its position in the list. */
VmNotifier *ASYNC_initCallbackNotifier(VmCallback *item, int (*resume)(VmCallback *, void *), void *context)
{
    VmCallback **link = find_callback(item);
    if (!*link) {
        *link = item;
        item->next = NULL;
    }
    item->context = context;
    item->resume = resume;
    item->signalled = 0;
    item->deadline = 0;
    item->notifier = (VmNotifier){.state = VM_DONE0, .notify = mark_signalled};
    return &item->notifier;
}

static void invalidate(VmNotifier *n)
{
    if (n->invalidate) {
        n->invalidate(n);
        n->invalidate = NULL;
    }
}

void ASYNC_deregisterCallbackNotifier(VmCallback *item)
{
    VmCallback **link = find_callback(item);
    invalidate(&item->notifier);
    if (*link == item)
        *link = item->next;
}

int JbniS_com_jbed_runtime_AsyncIO_getAsyncStateSize(void)
{
    return VM_ASYNC_STATE_BYTES;
}

void JbniV_com_jbed_runtime_Signal_nativeInvalidate(VmSignal *s)
{
    invalidate(&s->notifier);
}

static void update_deadline(VmCallback *item, int64_t now)
{
    if (item->notifier.timeout) {
        item->deadline = now + item->notifier.timeout;
        item->notifier.timeout = 0;
    }
}

int ASYNC_nextUpdateDelay(void)
{
    VmCallback *item = callbacks;
    int64_t now = CPL_os_getMillisElapsed();
    int delay = INT_MAX;
    for (; item; item = item->next) {
        if (item->signalled)
            return 0;
        update_deadline(item, now);
        if (item->deadline) {
            uint64_t remaining = (uint64_t)item->deadline - (uint64_t)now;
            if (remaining < (unsigned)delay)
                delay = (int)remaining;
        }
    }
    return delay;
}

void ASYNC_handleCallbacks(void)
{
    VmCallback *item = callbacks;
    int64_t now = CPL_os_getMillisElapsed();
    while (item) {
        VmCallback *next = item->next;
        update_deadline(item, now);
        if (item->signalled) {
            item->notifier.state = VM_DONE;
            item->signalled = 0;
        } else if (item->deadline && item->deadline <= now) {
            item->notifier.state = VM_TIMEOUT;
            item->deadline = 0;
        } else if (item->notifier.state == VM_BUSY) {
            item = next;
            continue;
        }
        VmNotifier *saved = JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier;
        JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier = &item->notifier;
        int complete = item->resume(item, item->context);
        JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier = saved;
        if (complete)
            *find_callback(item) = next;
        item = next;
    }
}

int ASYNC_pendingCall(void)
{
    int state = vm_current_notifier()->state;
    return state != VM_DONE0 && state != VM_DONE;
}

void ASYNC_notify(VmNotifier *n)
{
    if (n->notify) n->notify(n);
    else Jbed_signal(notifier_signal(n));
}

void ASYNC_notifyFast(VmNotifier *n)
{
    if (n->notify) n->notify(n);
    else Jbed_signalFast(notifier_signal(n));
}

void Jbed_asyncWaiter_init(VmWaiter *w)
{
    w->notifier = NULL;
    w->count = 0;
}

void Jbed_asyncWaiter_inc(VmWaiter *w) { ++w->count; }
int Jbed_asyncWaiter_count(VmWaiter *w) { return w->count; }

int Jbed_asyncWaiter_wait(VmWaiter *w, int timeout)
{
    if (w->count > 0) {
        VmNotifier *n = vm_current_notifier();
        if (timeout) n->timeout = timeout;
        n->state = VM_BUSY;
    }
    return w->count == 0;
}

void Jbed_asyncWaiter_dec(VmWaiter *w)
{
    if (!--w->count && w->notifier)
        ASYNC_notify(w->notifier);
}

static int resume_finalizer(VmCallback *callback, void *context)
{
    (void)callback;
    VmFinalizer *f = context;
    f->run(f);
    if (ASYNC_pendingCall())
        return 0;
    if (f->waiter)
        Jbed_asyncWaiter_dec(f->waiter);
    if (f->free_on_completion)
        free(f);
    return 1;
}

void Jbed_asyncFinalizer_reset(VmFinalizer *f)
{
    ASYNC_initCallbackNotifier(&f->callback, resume_finalizer, f);
}

void Jbed_asyncFinalizer_call(VmFinalizer *f, void (*run)(VmFinalizer *), int free_when_done, VmWaiter *waiter)
{
    f->free_on_completion = free_when_done;
    f->waiter = waiter;
    f->run = run;
    VmNotifier *n = ASYNC_initCallbackNotifier(&f->callback, resume_finalizer, f);
    VmNotifier *saved = JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier;
    JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier = n;
    run(f);
    if (ASYNC_pendingCall()) {
        if (waiter) Jbed_asyncWaiter_inc(waiter);
    } else {
        ASYNC_deregisterCallbackNotifier(&f->callback);
        if (free_when_done) free(f);
    }
    JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier = saved;
}

static int name_matches(VmMutex *m, const uint16_t *name, int length)
{
    return m->length == length && (length <= 0 || memcmp(m->name, name, (size_t)length * 2) == 0);
}

void Jbed_async_mutex_mapHandleToName(VmMutex *head, const uint16_t *name, int length, int handle)
{
    for (VmMutex *m = head->next; m; m = m->next)
        if (name_matches(m, name, length)) {
            m->handle = handle;
            break;
        }
}

int Jbed_async_mutex_exists(VmMutex *head, int handle, int operation)
{
    for (VmMutex *m = head->next; m; m = m->next)
        if (m->handle == handle && m->operation == operation)
            return 1;
    return 0;
}

void Jbed_async_mutex_notify(VmMutex *head, int handle, int operation)
{
    for (VmMutex **link = &head->next; *link; link = &(*link)->next) {
        VmMutex *m = *link;
        if (m->handle != handle || m->operation != operation)
            continue;
        for (int i = 0; i < m->count; ++i)
            ASYNC_notify(m->waiters[i]);
        *link = m->next;
        free(m->name);
        free(m->waiters);
        free(m);
        return;
    }
}

int Jbed_async_mutex_check(VmMutex *head, const uint16_t *name, int length, int operation)
{
    VmNotifier *owner = vm_current_notifier();
    for (VmMutex *m = head->next; m; m = m->next) {
        if (m->operation != operation || !name_matches(m, name, length))
            continue;
        if (m->owner == owner)
            return 1;
        if (m->count == m->capacity) {
            VmNotifier **p = malloc((size_t)(m->count + 10) * sizeof(*p));
            if (!p) return 3;
            m->capacity += 10;
            memcpy(p, m->waiters, m->count * sizeof(*p));
            free(m->waiters);
            m->waiters = p;
        }
        m->waiters[m->count++] = owner;
        return 0;
    }

    VmMutex *m = malloc(sizeof(*m));
    if (!m) return 3;
    *m = (VmMutex){.operation = operation, .owner = owner, .capacity = 10};
    if (name && length > 0) {
        m->name = malloc((size_t)length * 2);
        if (!m->name) {
            free(m);
            return 3;
        }
        memcpy(m->name, name, (size_t)length * 2);
        m->length = length;
    }
    m->waiters = malloc(m->capacity * sizeof(*m->waiters));
    if (!m->waiters) {
        free(m->name);
        free(m);
        return 3;
    }
    m->next = head->next;
    head->next = m;
    return 1;
}
