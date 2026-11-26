#include "vm_async.h"

#include <poll.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int (*call)(void *);
    void *arg;
} FdCallback;

static struct pollfd *fds;
static FdCallback *callbacks;
static int count, capacity, awake;

int aioc_init(void) { return 1; }
int aioc_awake(void) { return awake; }

void aioc_term(void)
{
    free(fds);
    free(callbacks);
    fds = NULL;
    callbacks = NULL;
    capacity = count = 0;
}

int aioc_register_fd(int fd, short events, int (*call)(void *), void *arg)
{
    if (count >= capacity) {
        struct pollfd *new_fds = malloc((capacity + 10u) * sizeof(*fds));
        if (!new_fds)
            return 0;
        FdCallback *new_callbacks = malloc((capacity + 10u) * sizeof(*callbacks));
        if (!new_callbacks) {
            free(new_fds);
            return 0;
        }
        if (count > 0) {
            memcpy(new_fds, fds, count * sizeof(*fds));
            memcpy(new_callbacks, callbacks, count * sizeof(*callbacks));
            free(fds);
            free(callbacks);
        }
        fds = new_fds;
        callbacks = new_callbacks;
        capacity += 10;
    }
    fds[count] = (struct pollfd){.fd = fd, .events = events};
    callbacks[count++] = (FdCallback){call, arg};
    return 1;
}

static void remove_at(int i)
{
    if (i < --count) {
        fds[i] = fds[count];
        callbacks[i] = callbacks[count];
    }
}

int aioc_unregister_fd_filter(int fd, int notify, int events)
{
    int removed = 0;
    for (int i = 0; i < count;) {
        if (fds[i].fd == fd && (events & fds[i].events)) {
            if (notify)
                callbacks[i].call(callbacks[i].arg);
            ++removed;
            remove_at(i);
        } else {
            ++i;
        }
    }
    return removed;
}

int aioc_unregister_fd(int fd, int notify)
{
    return aioc_unregister_fd_filter(fd, notify, 0xffff);
}

int aioc_poll(int timeout)
{
    if (!timeout && !count)
        return -1;
    if (poll(fds, count, timeout) <= 0)
        return count ? 0 : -1;
    awake = 1;
    int called = 0;
    for (int i = 0; i < count;) {
        if (fds[i].revents) {
            ++called;
            if (callbacks[i].call(callbacks[i].arg) != 1) {
                remove_at(i);
                continue;
            }
        }
        ++i;
    }
    awake = 0;
    return called;
}

static int notify_ready(void *notifier)
{
    ASYNC_notify(notifier);
    return 0;
}

int aioc_when_fd_ready_or_timeout(int fd, short events, int timeout)
{
    if (!aioc_register_fd(fd, events, notify_ready, vm_current_notifier()))
        return 0;
    VmNotifier *n = vm_current_notifier();
    n->timeout = timeout;
    n->state = VM_BUSY;
    return 1;
}

int aioc_when_fd_ready(int fd, short events)
{
    if (!aioc_register_fd(fd, events, notify_ready, vm_current_notifier()))
        return 0;
    vm_current_notifier()->state = VM_BUSY;
    return 1;
}
