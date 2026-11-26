#include "push.h"
#include "jbni_objects.h"
#include "vm_async.h"

#include <pthread.h>
#include <stdlib.h>
#include <string.h>

extern int android_sms_register(int);
extern int android_sms_deregister(int);
extern int android_sms_send(VmNotifier *, const uint16_t *, int, int, const void *, int, int);
extern int android_LOGD(const char *, ...);
extern void Jbni_intern_raiseCommonException(int);

typedef struct SmsPort {
    struct SmsPort *next;
    SmsMessage *messages;
    int info, port;
    PushEntry *checkout;
} SmsPort;

typedef struct {
    uint32_t header[3];
    JbRef sched, target;
    JbRef sender;
    int32_t sender_length;
    JbRef data;
    int32_t source_port, destination_port, type, sequence_id, sequence_index, sequence_length;
    int64_t timestamp;
    int32_t is_cbs;
} SmsReader;

typedef struct {
    uint32_t header[3];
    JbRef next;
    uint8_t open, server;
    JbRef msisdn;
    int32_t local_port, info;
} SmsProtocol;

typedef struct {
    VmFinalizer base;
    int port, info;
} SmsFinalizer;

/* Push registrations survive a VM restart and are closed during subsystem teardown. */
static pthread_mutex_t sms_lock = PTHREAD_MUTEX_INITIALIZER;
static SmsPort *ports;
static VmNotifier *reader_waiter;
static uint8_t send_result;
static JbUpcallQueue *wma_queue;
uint8_t exitSmsThread;

_Static_assert(offsetof(SmsReader, timestamp) == 56, "SMS receiver object layout");
#if UINTPTR_MAX == UINT32_MAX
_Static_assert(offsetof(SmsMessage, data) == 64, "incoming message payload pointer");
_Static_assert(offsetof(SmsFinalizer, port) == 192, "async finalizer extension");
#endif

static SmsPort **port_slot(int port)
{
    SmsPort **slot = &ports;
    while (*slot && (*slot)->port != port) slot = &(*slot)->next;
    return slot;
}

static SmsMessage *take_message(SmsMessage **head)
{
    SmsMessage *msg = *head;
    if (msg) {
        *head = msg->next;
        msg->next = NULL;
    }
    return msg;
}

const char *CPL_sms_msisdn(const SmsMessage *msg)
{
    return msg->sender;
}

void CPL_sms_free(SmsMessage *msg)
{
    free(msg->data);
    free(msg);
}

void jbed_handle_sms_sendresult(VmNotifier *notifier, uint8_t result)
{
    send_result = result;
    if (notifier && !exitSmsThread) ASYNC_notify(notifier);
}

void CPL_sms_notifyReader(void)
{
    if (reader_waiter) {
        ASYNC_notify(reader_waiter);
        reader_waiter = NULL;
    }
}

SmsMessage *CPL_sms_poll(int port)
{
    pthread_mutex_lock(&sms_lock);
    SmsPort *p = *port_slot(port);
    SmsMessage *msg = p ? take_message(&p->messages) : NULL;
    pthread_mutex_unlock(&sms_lock);
    return msg;
}

int jbed_handle_newSms(const char *sender, size_t sender_length, uint16_t source_port,
                       int destination_port, uint8_t type, int64_t timestamp,
                       const void *data, uint16_t length)
{
    if (sender_length >= sizeof(((SmsMessage *)0)->sender)) return -1;
    SmsMessage *msg = malloc(sizeof(*msg));
    if (!msg) {
        android_LOGD("ERROR:WMA:jbed_handle_newSms() smsMsg == NULL\n");
        return -1;
    }
    msg->sender_length = (int32_t)sender_length;
    memcpy(msg->sender, sender, sender_length);
    msg->sender[sender_length] = '\0';
    msg->source_port = source_port;
    msg->destination_port = (uint16_t)destination_port;
    msg->type = type;
    msg->timestamp = timestamp;
    msg->length = length;
    msg->data = malloc(length);
    if (!msg->data) {
        android_LOGD("ERROR:WMA:jbed_handle_newSms() smsMsg->data == NULL\n");
        free(msg);
        return -1;
    }
    memcpy(msg->data, data, length);
    pthread_mutex_lock(&sms_lock);
    SmsPort *p = *port_slot(destination_port);
    int push = 0;
    if (p) {
        msg->next = p->messages;
        p->messages = msg;
        push = p->info & SMS_PUSH;
    }
    pthread_mutex_unlock(&sms_lock);
    if (!p) CPL_sms_free(msg);
    else if (push) Jbed_push_io_activity();
    else CPL_sms_notifyReader();
    return 0;
}

void CPL_wma_init(void)
{
    exitSmsThread = 0;
}

int CPL_sms_register(int port, int info)
{
    if (android_sms_register(port) < 0) return -1;
    SmsPort *p = malloc(sizeof(*p));
    if (!p) {
        android_sms_deregister(port);
        return -1;
    }
    pthread_mutex_lock(&sms_lock);
    *p = (SmsPort){.port = port | (info & SMS_CBS), .info = info, .next = ports};
    ports = p;
    pthread_mutex_unlock(&sms_lock);
    return 0;
}

void CPL_sms_deregister(int port)
{
    android_sms_deregister(port);
    pthread_mutex_lock(&sms_lock);
    SmsPort **slot = port_slot(port);
    SmsPort *p = *slot;
    if (p) *slot = p->next;
    pthread_mutex_unlock(&sms_lock);
    if (p) {
        while (p->messages) CPL_sms_free(take_message(&p->messages));
        free(p);
    }
}

void CPL_wma_shutdown(void)
{
    for (SmsPort *p = ports, *next; p; p = next) {
        next = p->next;
        if (p->checkout) {
            Jbed_push_hand_back(p->checkout);
            p->checkout = NULL;
        } else if (!(p->info & SMS_PUSH)) {
            CPL_sms_deregister(p->port);
        }
    }
}

int JbniS_javax_microedition_io_SmsConnectionThread_nRegisterPort(int port, int info)
{
    PushEntry *entry = Jbed_push_sms_get_open_port(port);
    if (!entry) return CPL_sms_register(port, info) == 0;
    SmsPort *p = *port_slot(port);
    if (!p) return 0;
    p->checkout = entry;
    return 1;
}

void JbniS_javax_microedition_io_SmsConnectionThread_nDeregisterPort(int port, int info)
{
    (void)info;
    SmsPort *p = *port_slot(port);
    if (p && p->checkout) {
        Jbed_push_hand_back(p->checkout);
        p->checkout = NULL;
    } else {
        CPL_sms_deregister(port);
    }
}

int JbniV_javax_microedition_io_SmsConnectionThread_nReadMessage(SmsReader *reader)
{
    SmsMessage *msg = NULL;
    pthread_mutex_lock(&sms_lock);
    for (SmsPort *p = ports; p && !msg; p = p->next) {
        if (p->checkout) msg = Jbed_push_sms_get_queued(p->checkout);
        else if (!(p->info & SMS_PUSH)) msg = take_message(&p->messages);
    }
    pthread_mutex_unlock(&sms_lock);
    if (!msg) {
        reader_waiter = vm_current_notifier();
        reader_waiter->state = VM_BUSY;
        return 0;
    }

    void **roots = Jbed_nativeCallStateAdr;
    *Jbed_nativeCallStateAdr++ = &reader;
    JbArray *sender = (JbArray *)(uintptr_t)reader->sender;
    if (msg->sender_length > sender->length) {
        CPL_sms_free(msg);
        Jbed_nativeCallStateAdr = roots;
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT);
        return 0;
    }
    reader->sender_length = msg->sender_length;
    memcpy(sender->data, msg->sender, (size_t)msg->sender_length);
    JbArray *payload = Jbni_newByteArray(msg->length);
    if (!payload) {
        CPL_sms_free(msg);
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_OUT_OF_MEMORY);
        Jbed_nativeCallStateAdr = roots;
        return 0;
    }
    reader->data = jb_ref(payload);
    memcpy(payload->data, msg->data, msg->length);
    reader->is_cbs = 0;
    reader->source_port = msg->source_port;
    reader->destination_port = msg->destination_port;
    reader->timestamp = msg->timestamp;
    reader->type = msg->type;
    reader->sequence_id = -1;
    reader->sequence_index = reader->sequence_length = 1;
    CPL_sms_free(msg);
    Jbed_nativeCallStateAdr = roots;
    return 1;
}

void JbniV_javax_microedition_io_SmsConnectionThread_nDeleteMessage(SmsReader *reader)
{
    (void)reader;
}

int JbniV_javax_microedition_io_sms_1Protocol_open0(void)
{
    exitSmsThread = 0;
    return 0;
}

int JbniS_javax_microedition_io_sms_1Protocol_nSend(const JbString *address, int source_port,
                                                     int port, int type, const JbArray *payload, int length)
{
    (void)source_port;
    if (vm_current_notifier()->state != VM_DONE0) return send_result;
    android_sms_send(vm_current_notifier(), jb_string_chars(address), address->length, port,
                     payload->data, length, type);
    vm_current_notifier()->state = VM_BUSY;
    return 0;
}

void wma_initialize(void)
{
    if (!wma_queue) wma_queue = Jbed_upcall_createQueue(12, 10);
}

void wma_finalize(void)
{
    if (wma_queue) {
        Jbed_upcall_deleteQueue(wma_queue);
        wma_queue = NULL;
    }
}

void JbniS_javax_microedition_io_SmsConnectionThread_nInitializeWma(void)
{
    wma_initialize();
}

void JbniV_javax_microedition_io_SmsConnectionThread_finalize(SmsReader *reader)
{
    (void)reader;
    wma_finalize();
}

static void notify_deregister(int port, int info)
{
    if (wma_queue) Jbed_upcall_sendSimple(wma_queue, -1, JBED_UPCALL_SMS, (info & SMS_CBS) ? -port : port);
}

static void finish_sms_port(VmFinalizer *finalizer)
{
    SmsFinalizer *task = (SmsFinalizer *)finalizer;
    CPL_sms_deregister(task->port);
    if (!ASYNC_pendingCall()) notify_deregister(task->port, task->info);
}

void JbniV_javax_microedition_io_sms_1Protocol_finalize(SmsProtocol *self)
{
    exitSmsThread = 1;
    if (!self->open || self->local_port < 0) return;
    if (Jbed_push_sms_is_push_port(self->local_port)) {
        notify_deregister(self->local_port, self->info);
    } else {
        SmsFinalizer *task = malloc(sizeof(*task));
        if (!task) return;
        task->port = self->local_port;
        task->info = self->info;
        Jbed_asyncFinalizer_call(&task->base, finish_sms_port, 1, NULL);
        self->open = 0;
    }
}
