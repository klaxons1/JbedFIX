#ifndef JBED_VM_ASYNC_H
#define JBED_VM_ASYNC_H

#include <stdint.h>

typedef struct VmNotifier VmNotifier;
typedef struct VmCallback VmCallback;
typedef struct VmSignal VmSignal;
typedef struct VmMutex VmMutex;
typedef struct VmFinalizer VmFinalizer;

enum { VM_IDLE, VM_BUSY, VM_DONE0, VM_DONE, VM_TIMEOUT, VM_LOOP };
enum { VM_ASYNC_STATE_BYTES = 128 };

struct VmNotifier {
    int state;
    void (*notify)(VmNotifier *);
    void (*invalidate)(VmNotifier *);
    int timeout;
};

struct VmSignal {
    uint32_t header[3];
    uint32_t next, last;
    uint8_t waiting, signalled, queued;
    uint32_t synch, objArg;
    int32_t arg;
    VmNotifier notifier;
    struct JbArray *asyncBuffer;
    int32_t vmRef;
};

struct VmCallback {
    VmCallback *next;
    void *context;
    int (*resume)(VmCallback *, void *);
    int64_t deadline;
    VmNotifier notifier;
    uint8_t state_data[VM_ASYNC_STATE_BYTES];
    int signalled;
};

typedef struct {
    VmNotifier *notifier;
    int count;
} VmWaiter;

struct VmFinalizer {
    VmCallback callback;
    int free_on_completion;
    VmWaiter *waiter;
    void (*run)(VmFinalizer *);
};

struct VmMutex {
    uint16_t *name;
    int length, operation, handle;
    VmNotifier *owner;
    VmNotifier **waiters;
    int capacity, count;
    VmMutex *next;
};

extern VmNotifier *JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier;
VmNotifier *vm_current_notifier(void);
VmNotifier *ASYNC_initCallbackNotifier(VmCallback *, int (*)(VmCallback *, void *), void *);
void ASYNC_deregisterCallbackNotifier(VmCallback *);
void *ASYNC_getStateFromNotifier(VmNotifier *);
void ASYNC_notify(VmNotifier *);
void ASYNC_notifyFast(VmNotifier *);
int ASYNC_pendingCall(void);
int ASYNC_nextUpdateDelay(void);
void ASYNC_handleCallbacks(void);
int JbniS_com_jbed_runtime_AsyncIO_getAsyncStateSize(void);
void JbniV_com_jbed_runtime_Signal_nativeInvalidate(VmSignal *);
void Jbed_asyncWaiter_init(VmWaiter *);
void Jbed_asyncWaiter_inc(VmWaiter *);
void Jbed_asyncWaiter_dec(VmWaiter *);
int Jbed_asyncWaiter_count(VmWaiter *);
int Jbed_asyncWaiter_wait(VmWaiter *, int timeout);
void Jbed_asyncFinalizer_reset(VmFinalizer *);
void Jbed_asyncFinalizer_call(VmFinalizer *, void (*run)(VmFinalizer *), int free_when_done, VmWaiter *);
void Jbed_async_mutex_mapHandleToName(VmMutex *, const uint16_t *, int length, int handle);
int Jbed_async_mutex_exists(VmMutex *, int handle, int operation);
void Jbed_async_mutex_notify(VmMutex *, int handle, int operation);
int Jbed_async_mutex_check(VmMutex *, const uint16_t *, int length, int operation);
int aioc_init(void);
void aioc_term(void);
int aioc_awake(void);
int aioc_poll(int timeout);
int aioc_register_fd(int fd, short events, int (*callback)(void *), void *arg);
int aioc_unregister_fd_filter(int fd, int notify, int events);
int aioc_unregister_fd(int fd, int notify);
int aioc_when_fd_ready(int fd, short events);
int aioc_when_fd_ready_or_timeout(int fd, short events, int timeout);

#endif
