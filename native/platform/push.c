#include "push.h"
#include "vm_os.h"
#include "jbni_objects.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern uint8_t *Jbed_relativeStaticsBase;
extern uint32_t Jbed_noAllocation;
extern int Jbed_currentIsolate(void);
extern JbString *Jbni_intern_newStringLenExc(const char *, int);
extern int Jbni_intern_getStringAscii(const JbString *, char *, int);
extern void Jbni_intern_raiseException(const char *);
extern void Jbni_intern_raiseCommonException(int);

enum { REMOVED = 0, ALARM = 1, SMS = 4 };
enum { PUSH_FILTER_FIELD = 1, PUSH_MIDLET_FIELD = 2, PUSH_STORAGE_FIELD = 3, PUSH_OPTIONS_FIELD = 4 };
enum { PUSH_WATCH_PENDING = -100, PUSH_SMS_QUEUE_LIMIT = 20, STORAGE_NAME_STATIC_OFFSET = 480 };
enum { DISCARD = 1, CLOSE = 2, REMOVE = 4, START = 8 };
enum { STOPPED, INITIALIZING, OPENING, PAUSED, ARM_WATCH, WATCHING, READY };
enum { UNCHANGED, OLD_REGISTRATION, NEW_REGISTRATION, KEPT_REGISTRATION, ISOLATE_REGISTRATION };

typedef struct { SmsMessage *head, *incoming; } PushInbox;

struct PushEntry {
    PushEntry *next;
    uint8_t state, transaction, event, type;
    int16_t options;
    int isolate, port, handle;
    VmCallback *callback;
    int (*resume)(VmCallback *, void *);
    int paused, registered;
    VmNotifier *waiter;
    int checked_out;
    union { void *data; int64_t *alarm; PushInbox *sms; } u;
    char record[]; /* 'P' followed by connector, filter, MIDlet, storage name and options */
};

typedef struct {
    int (*create)(PushEntry *);
    int (*add)(PushEntry *, PushEntry **);
    int (*init)(PushEntry *), (*open)(PushEntry *), (*watch)(PushEntry *);
    void (*discard)(PushEntry *), (*close)(PushEntry *);
    int (*filter)(PushEntry *), (*check_port)(PushEntry *, const int *);
    void (*start)(PushEntry *), (*store)(PushEntry *, PushFile *), (*revive)(PushEntry *, const char *);
    int (*match)(const char *, const char *), (*has_connection)(PushEntry *);
    void (*reset)(PushEntry *);
} PushOps;

#if UINTPTR_MAX == UINT32_MAX
_Static_assert(offsetof(PushEntry, record) == 52, "push list entry layout");
_Static_assert(sizeof(PushOps) == 60, "push connection operations");
#endif

extern const PushOps PushConnections[12];
static PushEntry *entries;
static int dirty, queue_ready;
static VmCallback *alarm_callback;
static JbUpcallQueue *queue;

static const PushOps *ops(const PushEntry *e) { return &PushConnections[e->type]; }
static const char *fields(const PushEntry *e) { return e->record + 1; }
static int available(PushEntry *e) { return e->state == READY || ops(e)->has_connection(e); }

void print_push_entry(const PushEntry *e) { (void)e; }
int push_hasConn(PushEntry *e) { (void)e; return 0; }
void push_resetEntry(PushEntry *e) { (void)e; }
PushEntry *push_get_list(void) { return entries; }

PushEntry *push_getPushEntry(int type, int port)
{
    for (PushEntry *e = entries; e; e = e->next)
        if (e->type == type && e->port == port) return e;
    return NULL;
}

int push_checkport(int type, int port)
{
    return push_getPushEntry(type, port) != NULL;
}

JbString *getStorageName(void)
{
    JbRef ref;
    memcpy(&ref, Jbed_relativeStaticsBase + STORAGE_NAME_STATIC_OFFSET, sizeof(ref));
    return (JbString *)(uintptr_t)ref;
}

const char *push_field(const char *s, int index)
{
    while (index) {
        const char *comma = strchr(s, ',');
        if (!comma) return "";
        s = comma + 1;
        --index;
    }
    return s;
}

static int field_equal(const uint16_t *chars, int n, const char *s)
{
    for (int i = 0; i < n; ++i) {
        if (!s[i] || s[i] == ',' || chars[i] != (uint8_t)s[i]) return 0;
    }
    return s[n] == ',' || !s[n];
}

int strings_match(const JbString *text, const char *field)
{
    return field_equal(jb_string_chars(text), text->length, field);
}

static int matches_storage(const PushEntry *e, const JbString *suite)
{
    return suite && strings_match(suite, push_field(fields(e), PUSH_STORAGE_FIELD));
}

int push_matchConn(const char *connection, const char *record)
{
    const char *end = strchr(record, ',');
    size_t length = strlen(connection);
    return end && (size_t)(end - record) == length && !strncmp(connection, record, length);
}

JbString *Jbed_push_get_field_helper(const PushEntry *e, int index)
{
    const char *s = push_field(fields(e), index);
    return Jbni_intern_newStringLenExc(s, (int)strcspn(s, ","));
}

JbString *JbniS_com_jbed_ams_PushRegistryImpl_getField(const PushEntry *e, int index)
{
    return Jbed_push_get_field_helper(e, index);
}

static int prepend(PushEntry *e, PushEntry **list)
{
    e->next = *list;
    *list = e;
    return 1;
}

void push_entry_add(PushEntry *e)
{
    prepend(e, &entries);
    dirty = 1;
}

void push_entry_remove(PushEntry *e)
{
    dirty = 1;
    for (PushEntry **p = &entries; *p; p = &(*p)->next) {
        if (*p == e) {
            *p = e->next;
            free(e);
            break;
        }
    }
}

int push_check_port_isused(PushEntry *candidate)
{
    for (PushEntry *e = entries; e; e = e->next) {
        if (e->port == candidate->port) {
            free(candidate);
            return 1;
        }
    }
    return 0;
}

int Jbed_push_check_next_push(void)
{
    for (PushEntry *e = entries; e; e = e->next)
        if (e->type && available(e) && !e->checked_out && !e->event) return -1;
    return -2;
}

void JbniS_com_jbed_ams_PushRegistryImpl_launch0(PushEntry *e)
{
    if (e->type == ALARM) {
        e->type = REMOVED;
        dirty = 1;
    } else if (e->type > ALARM) {
        e->event = 2;
    }
}

int JbniS_com_jbed_ams_PushRegistryImpl_fullListConnections0(JbArray *out)
{
    int n = 0;
    for (PushEntry *e = entries; e && e->type; e = e->next) {
        if (out && n < out->length) out->data[n] = jb_ref(e);
        ++n;
    }
    return n;
}

int JbniS_com_jbed_ams_PushRegistryImpl_listConnections0(int only_available, int alarms,
                                                          const JbString *suite, JbArray *out)
{
    int n = 0;
    for (PushEntry *e = entries; e; e = e->next) {
        if (!e->type || e->type == 10 || (e->type == ALARM && !alarms)) continue;
        if (!matches_storage(e, suite) || (only_available && !available(e))) continue;
        if (out && n < out->length) out->data[n] = jb_ref(e);
        ++n;
    }
    return n;
}

void Jbed_push_closeQueue(void)
{
    if (queue) Jbed_upcall_deleteQueue(queue);
    queue = NULL;
}

void Jbed_push_openQueue(int capacity, int priority)
{
    if (!queue) queue = Jbed_upcall_createQueue(capacity, priority);
}

int Jbed_push_sendPushEventEx(PushEntry *e)
{
    if (!queue || queue_ready != 1) {
        if (e->event != 2) e->event = 0;
        return 0;
    }
    if (e->event) return 0;
    Jbed_upcall_sendSimple(queue, -1, JBED_UPCALL_PUSH, (int)jb_ref(e));
    e->event = 1;
    return 1;
}

int Jbed_push_sendPushEvent(PushEntry *e)
{
    return Jbed_push_sendPushEventEx(e);
}

void JbniS_com_jbed_ams_PushRegistryCallHandler_handleCachedPushEvents(void)
{
    queue_ready = 1;
    for (PushEntry *e = entries; e; e = e->next)
        if (e->type && available(e) && !e->event) Jbed_push_sendPushEvent(e);
}

int64_t Jbed_push_get_next_alarm_time(void)
{
    int64_t now = CPL_os_getMillisSince1970(), earliest = INT64_MAX;
    for (PushEntry *e = entries; e; e = e->next)
        if (e->type == ALARM && *e->u.alarm < earliest) earliest = *e->u.alarm;
    if (earliest == INT64_MAX) return earliest;
    return earliest > now ? earliest - now : 0;
}

static int resume_alarms(VmCallback *callback, void *context)
{
    (void)callback;
    (void)context;
    int64_t now = CPL_os_getMillisSince1970(), earliest = INT64_MAX;
    for (PushEntry *e = entries; e; e = e->next) {
        if (e->type != ALARM || e->event) continue;
        int64_t time = *e->u.alarm;
        if (time <= now) {
            e->state = READY;
            Jbed_push_sendPushEvent(e);
        } else if (time < earliest) {
            earliest = time;
        }
    }
    if (earliest == INT64_MAX) return 1;
    VmNotifier *n = vm_current_notifier();
    int64_t delay = earliest - now;
    n->timeout = delay > INT32_MAX - 1 ? INT32_MAX - 1 : (int)delay;
    n->state = VM_BUSY;
    return 0;
}

static void start_callback(VmCallback *callback, int (*resume)(VmCallback *, void *), PushEntry *entry)
{
    VmNotifier *n = ASYNC_initCallbackNotifier(callback, resume, entry);
    VmNotifier *previous = JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier;
    JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier = n;
    if (resume(callback, entry)) ASYNC_deregisterCallbackNotifier(callback);
    JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier = previous;
}

int push_alarm_create(PushEntry *e)
{
    const char *s = fields(e);
    if (!strncmp(s, "alarm://,", 9)) {
        const unsigned char *p = (const unsigned char *)s + 9;
        uint64_t time = 0;
        size_t n = 0;
        while (p[n] && p[n] != ',' && p[n] != '\n') {
            unsigned value = p[n] > 96 ? (unsigned)p[n] - 87 : (unsigned)p[n] - 48;
            time = (time << 4) + value;
            ++n;
        }
        if (n == 16 && p[n] == ',') {
            if (!e->u.alarm) e->u.alarm = malloc(sizeof(*e->u.alarm));
            if (e->u.alarm) {
                *e->u.alarm = (int64_t)time;
                e->resume = resume_alarms;
                return 1;
            }
        }
    }
    free(e);
    return 0;
}

int push_alarm_add(PushEntry *e, PushEntry **list) { return prepend(e, list); }
int push_alarm_init(PushEntry *e) { (void)e; return 0; }
int push_alarm_open(PushEntry *e) { (void)e; return 0; }
int push_alarm_watch(PushEntry *e) { (void)e; return PUSH_WATCH_PENDING; }
void push_alarm_close(PushEntry *e) { (void)e; }
void push_alarm_kill(PushEntry *e) { (void)e; }
int push_alarm_check_filter(PushEntry *e) { (void)e; return 1; }
int push_alarm_check_port(PushEntry *e, const int *port) { (void)e; (void)port; return 1; }
void push_alarm_store_info(PushEntry *e, PushFile *f) { (void)e; (void)f; }
void push_alarm_revive_info(PushEntry *e, const char *line) { (void)e; (void)line; }

void push_alarm_discard(PushEntry *e)
{
    free(e->u.alarm);
    e->u.alarm = NULL;
    e->type = REMOVED;
    e->state = STOPPED;
}

void push_start_alarm_connection(PushEntry *e)
{
    if (!alarm_callback) alarm_callback = malloc(sizeof(*alarm_callback));
    if (alarm_callback) start_callback(alarm_callback, e->resume, NULL);
}

void start_connection_op(PushEntry *e)
{
    start_callback(e->callback, e->resume, e);
}

static void reset_connection(PushEntry *e, int flags)
{
    if (e->type == ALARM) {
        if ((flags & START) && !e->state) {
            e->state = WATCHING;
            push_start_alarm_connection(e);
        }
        if ((flags & CLOSE) && e->state && alarm_callback) {
            ASYNC_deregisterCallbackNotifier(alarm_callback);
            free(alarm_callback);
            alarm_callback = NULL;
        }
    } else if (e->type > ALARM) {
        if (e->waiter) ASYNC_notify(e->waiter);
        e->waiter = NULL;
        e->checked_out = 0;
        if ((flags & DISCARD) && available(e)) ops(e)->discard(e);
        if ((flags & CLOSE) && e->state) {
            ops(e)->close(e);
            if (e->registered) ASYNC_deregisterCallbackNotifier(e->callback);
            e->registered = 0;
            free(e->callback);
            e->callback = NULL;
            e->state = STOPPED;
        }
        if (flags & START) {
            if (e->state == STOPPED) {
                e->state = INITIALIZING;
                e->callback = malloc(sizeof(*e->callback));
                if (e->callback) ops(e)->start(e);
                else e->state = STOPPED;
            } else if (e->state == PAUSED) {
                e->state = WATCHING;
                if (e->paused) ASYNC_notify(&e->callback->notifier);
            }
        }
    }
    if (flags & REMOVE) {
        e->type = REMOVED;
        dirty = 1;
    }
}

void JbniS_com_jbed_ams_PushRegistryImpl_cancel(PushEntry *e)
{
    e->event = 0;
    if (e->type == ALARM) {
        e->type = REMOVED;
        dirty = 1;
    } else {
        reset_connection(e, DISCARD);
        if (e->type != 10 && e->type) {
            e->state = ARM_WATCH;
            ops(e)->start(e);
        }
    }
}

void Jbed_push_handle_vm_start(void)
{
    for (PushEntry *e = entries; e; e = e->next) reset_connection(e, START);
}

void Jbed_push_io_activity(void)
{
    for (PushEntry *e = entries; e; e = e->next)
        if (e->type >= 4 && e->type <= 6 && e->callback) ASYNC_notify(&e->callback->notifier);
}

int Jbed_push_hand_back(PushEntry *e)
{
    if (!e->checked_out) return 0;
    if (e->waiter) ASYNC_notify(e->waiter);
    e->waiter = NULL;
    e->checked_out = 0;
    if (e->state == WATCHING) e->state = PAUSED;
    return 1;
}

static PushEntry *checkout(int type, const int *port)
{
    for (PushEntry *e = entries; e; e = e->next) {
        if (e->type != type || !ops(e)->check_port(e, port)) continue;
        if (!matches_storage(e, getStorageName())) {
            Jbni_intern_raiseCommonException(JBED_EXCEPTION_IO);
            return NULL;
        }
        if (e->checked_out) {
            Jbni_intern_raiseException("javax/microedition/io/ConnectionNotFoundException");
            return NULL;
        }
        reset_connection(e, START);
        if (e->event == 2) e->event = 1;
        e->checked_out = 1;
        e->isolate = Jbed_currentIsolate();
        return e;
    }
    return NULL;
}

PushEntry *push_checkout_simple_port(int type, int port) { return checkout(type, &port); }

PushEntry *push_checkout_complex_port(int type, int a, int b)
{
    int pair[2] = {a, b};
    return checkout(type, pair);
}

int Jbed_push_sms_is_push_port(int port) { return push_checkport(SMS, port); }

PushEntry *Jbed_push_sms_get_open_port(int port)
{
    PushEntry *e = push_checkout_simple_port(SMS, port);
    if (e) CPL_sms_notifyReader();
    return e;
}

static PushEntry *find_connector(const JbString *name)
{
    int size = name->length + 1;
    void **saved = Jbed_nativeCallStateAdr;
    JbArray *bytes = Jbni_newByteArray(size);
    *Jbed_nativeCallStateAdr++ = &bytes;
    if (!bytes) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_OUT_OF_MEMORY);
        Jbed_nativeCallStateAdr = saved;
        return NULL;
    }
    Jbni_intern_getStringAscii(name, (char *)bytes->data, size);
    PushEntry *e = entries;
    for (; e; e = e->next)
        if (e->type > ALARM && ops(e)->match((const char *)bytes->data, fields(e))) break;
    Jbed_nativeCallStateAdr = saved;
    return e;
}

int JbniS_com_jbed_ams_PushRegistryImpl_unregisterConnection0(const JbString *name,
                                                               const JbString *suite, const JbString *unused)
{
    (void)unused;
    PushEntry *e = find_connector(name);
    if (!e) return 0;
    if (!matches_storage(e, suite)) {
        Jbni_intern_raiseException("java/lang/SecurityException");
        return 0;
    }
    reset_connection(e, DISCARD | CLOSE | REMOVE);
    return 1;
}

JbString *JbniS_com_jbed_ams_PushRegistryImpl_getFieldByConnector(const JbString *name, int field,
                                                                  const JbString *suite)
{
    PushEntry *e = find_connector(name);
    return e && matches_storage(e, suite) ? Jbed_push_get_field_helper(e, field) : NULL;
}

int push_setup(PushEntry *e)
{
    const char *s = fields(e);
    if (!strncmp(s, "alarm:", 6)) e->type = ALARM;
    else if (!strncmp(s, "sms:", 4)) e->type = SMS;
    else {
        free(e);
        Jbni_intern_raiseException("javax/microedition/io/ConnectionNotFoundException");
        return 0;
    }
    e->state = e->transaction = e->event = 0;
    e->isolate = e->handle = -1;
    e->options = (int16_t)atoi(push_field(s, PUSH_OPTIONS_FIELD));
    e->callback = NULL;
    e->resume = NULL;
    e->paused = e->registered = e->checked_out = 0;
    e->waiter = NULL;
    e->u.data = NULL;
    return ops(e)->create(e);
}

void JbniS_com_jbed_ams_PushRegistryImpl_registerConnection0(const JbString *connector,
    const JbString *filter, const JbString *midlet, const JbString *suite, int options, int per_isolate)
{
    PushEntry *existing = find_connector(connector);
    int isolate = per_isolate ? Jbed_currentIsolate() : -1;
    if (existing) {
        if (per_isolate || !matches_storage(existing, suite) || existing->transaction != OLD_REGISTRATION) {
            Jbni_intern_raiseCommonException(JBED_EXCEPTION_IO);
            return;
        }
        if (strings_match(midlet, push_field(fields(existing), PUSH_MIDLET_FIELD))
            && strings_match(filter, push_field(fields(existing), PUSH_FILTER_FIELD))) {
            existing->transaction = KEPT_REGISTRATION;
            return;
        }
    }

    char option_text[16];
    int n = snprintf(option_text, sizeof(option_text), "%d", options);
    const JbString *parts[] = {connector, filter, midlet, suite};
    size_t size = offsetof(PushEntry, record) + 6 + (size_t)n;
    for (unsigned i = 0; i < 4; ++i) size += (unsigned)parts[i]->length;
    ++Jbed_noAllocation;
    PushEntry *e = malloc(size);
    --Jbed_noAllocation;
    if (!e) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_OUT_OF_MEMORY);
        return;
    }
    e->record[0] = 'P';
    char *p = e->record + 1;
    for (unsigned i = 0; i < 4; ++i) {
        Jbni_intern_getStringAscii(parts[i], p, parts[i]->length + 1);
        p += parts[i]->length;
        *p++ = ',';
    }
    strcpy(p, option_text);
    if (!push_setup(e)) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT);
        return;
    }
    e->transaction = per_isolate ? ISOLATE_REGISTRATION : NEW_REGISTRATION;
    e->isolate = isolate;
    if (!ops(e)->add(e, &entries)) Jbni_intern_raiseCommonException(JBED_EXCEPTION_IO);
    dirty = 1;
}

static int64_t register_alarm(const JbString *identity, int64_t time)
{
    const uint16_t *chars = jb_string_chars(identity);
    int n = identity->length, first = 0;
    while (first < n && chars[first] != ',') ++first;
    int second = first < n ? first + 1 : n, end = second;
    while (end < n && chars[end] != ',') ++end;
    PushEntry *e = entries;
    for (; e; e = e->next) {
        if (e->type == ALARM &&
            field_equal(chars, first, push_field(fields(e), PUSH_MIDLET_FIELD)) &&
            field_equal(chars + second, end - second, push_field(fields(e), PUSH_STORAGE_FIELD))) break;
    }

    int64_t previous = 0;
    int existing = e != NULL;
    if (existing) {
        previous = *e->u.alarm;
        if (!time) {
            e->type = REMOVED;
            dirty = 1;
            return previous;
        }
    } else {
        if (!time) return 0;
        e = malloc(offsetof(PushEntry, record) + 28 + (size_t)n);
        if (!e) return 0;
        e->type = ALARM;
        memcpy(e->record, "Palarm://,", 10);
        e->record[26] = ',';
        Jbni_intern_getStringAscii(identity, e->record + 27, n + 1);
    }
    static const char hex[] = "0123456789abcdef";
    for (unsigned i = 0; i < 16; ++i)
        e->record[10 + i] = hex[((uint64_t)time >> (60 - i * 4)) & 15];
    if (existing) {
        *e->u.alarm = time;
        e->state = STOPPED;
        e->transaction = e->event = 0;
        e->isolate = -1;
    } else {
        if (!push_setup(e)) return 0;
        ops(e)->add(e, &entries);
    }
    reset_connection(e, START);
    dirty = 1;
    return previous;
}

int64_t JbniS_com_jbed_ams_PushRegistryImpl_registerAlarm0(int64_t time, const JbString *identity, int active)
{
    return active ? register_alarm(identity, time) : time;
}

int push_save(void)
{
    dirty = 0;
    PushFile *f = CPL_push_open(1);
    if (f == PUSH_FILE_ERROR) return -1;
    for (PushEntry *e = entries; e; e = e->next) {
        if (!e->type) continue;
        if (CPL_push_write(f, e->record)) break;
        ops(e)->store(e, f);
    }
    return CPL_push_close(f);
}

static void finish_isolate(int isolate)
{
    PushEntry **slot = &entries;
    while (*slot) {
        PushEntry *e = *slot;
        if (isolate != -1 && isolate != e->isolate && !matches_storage(e, getStorageName())) {
            slot = &e->next;
            continue;
        }
        if (!e->type || e->transaction == NEW_REGISTRATION || e->transaction == ISOLATE_REGISTRATION) {
            *slot = e->next;
            free(e->u.data);
            free(e);
            continue;
        }
        e->transaction = UNCHANGED;
        e->isolate = -1;
        ops(e)->reset(e);
        reset_connection(e, START);
        if (e->event == 3) e->event = e->type > ALARM && !e->checked_out ? 2 : 1;
        else if (e->event != 2) e->event = 0;
        slot = &e->next;
    }
    if (dirty) push_save();
}

void JbniS_com_jbed_ams_PushRegistryImpl_notifyMidletDeath(int isolate)
{
    finish_isolate(isolate);
}

void Jbed_push_handle_vm_exit_or_reset(void)
{
    finish_isolate(-1);
    queue_ready = 0;
}

void JbniS_com_jbed_ams_PushRegistryImpl_commit(const JbString *suite, int commit, int per_isolate)
{
    int isolate = per_isolate ? Jbed_currentIsolate() : -1;
    for (PushEntry *e = entries; e; e = e->next) {
        if (!e->transaction || !matches_storage(e, suite) || (per_isolate && e->isolate != isolate)) continue;
        if (per_isolate) {
            reset_connection(e, commit ? START : REMOVE);
        } else if ((commit && e->transaction == OLD_REGISTRATION)
                   || (!commit && e->transaction == NEW_REGISTRATION)) {
            reset_connection(e, DISCARD | CLOSE | REMOVE);
        } else if (commit && e->transaction == NEW_REGISTRATION) {
            reset_connection(e, START);
        }
        e->transaction = UNCHANGED;
    }
    if (dirty) push_save();
}

void JbniS_com_jbed_ams_PushRegistryImpl_deleteSuite(const JbString *suite, int deferred)
{
    for (PushEntry *e = entries; e; e = e->next) {
        if (!matches_storage(e, suite)) continue;
        if (deferred) e->transaction = OLD_REGISTRATION;
        else reset_connection(e, DISCARD | CLOSE | REMOVE);
    }
    if (dirty) push_save();
}

void Jbed_push_handle_shutdown(void)
{
    if (dirty) push_save();
    for (PushEntry *e = entries, *next; e; e = next) {
        next = e->next;
        reset_connection(e, DISCARD | CLOSE);
        free(e->u.data);
        free(e);
    }
    entries = NULL;
    free(alarm_callback);
    alarm_callback = NULL;
    Jbed_push_closeQueue();
}

static void load_registry(void)
{
    PushFile *f = CPL_push_open(0);
    if (f == PUSH_FILE_ERROR) return;
    PushEntry *last = NULL;
    char *line;
    while ((line = CPL_push_read(f)) != NULL) {
        if (*line == '#') continue;
        size_t n = strlen(line);
        if (n > 8 && *line == 'P') {
            last = malloc(offsetof(PushEntry, record) + n + 1);
            if (last) {
                memcpy(last->record, line, n + 1);
                if (push_setup(last)) ops(last)->add(last, &entries);
                else last = NULL;
            }
        } else if (last) {
            ops(last)->revive(last, line);
        }
    }
    CPL_push_close(f);
}

void Jbed_push_handle_boot(int start)
{
    Jbed_push_openQueue(81, 0);
    entries = NULL;
    load_registry();
    if (start) Jbed_push_handle_vm_start();
}

static int sms_wildcard(const char *pattern, const char *address)
{
    while (*pattern && *pattern != ',' && *pattern != '*') {
        if (!*address || (*pattern != '?' && *pattern != *address))
            return 0;
        ++pattern;
        ++address;
    }
    if (*pattern != '*')
        return !*address;

    do { ++pattern; } while (*pattern == '*');
    if (*pattern == ',')
        return 1;
    while (*address) {
        if ((*pattern == '?' || *pattern == *address) && sms_wildcard(pattern + 1, address + 1))
            return 1;
        ++address;
    }
    return 0;
}

SmsMessage *Jbed_push_sms_get_queued(PushEntry *e)
{
    if (!e->checked_out) return NULL;
    SmsMessage *msg = e->u.sms->head;
    if (msg) {
        e->u.sms->head = msg->next;
        msg->next = NULL;
    }
    return msg;
}

int push_sms_add(PushEntry *e, PushEntry **list) { return prepend(e, list); }
int push_sms_init(PushEntry *e) { (void)e; return 0; }
int push_sms_check_port(PushEntry *e, const int *port) { return e->port == *port; }
void push_sms_store_info(PushEntry *e, PushFile *f) { (void)e; (void)f; }
void push_sms_revive_info(PushEntry *e, const char *line) { (void)e; (void)line; }
int push_sms_hasConn(PushEntry *e) { return e->u.sms->head != NULL; }
void push_start_sms_connection(PushEntry *e) { start_connection_op(e); }

void push_sms_close(PushEntry *e)
{
    CPL_sms_deregister(e->port);
    free(e->u.sms);
    e->u.sms = NULL;
}

void push_sms_discard(PushEntry *e)
{
    SmsMessage *m;
    while ((m = e->u.sms->head) != NULL) {
        e->u.sms->head = m->next;
        CPL_sms_free(m);
    }
}

int push_sms_watch(PushEntry *e)
{
    SmsMessage *m = CPL_sms_poll(e->port);
    if (!m) return PUSH_WATCH_PENDING;
    e->u.sms->incoming = m;
    return 0;
}

int push_sms_open(PushEntry *e)
{
    return CPL_sms_register(e->port, SMS_PUSH) == 0 ? 0 : -1;
}

int push_sms_check_filter(PushEntry *e)
{
    return sms_wildcard(push_field(fields(e), PUSH_FILTER_FIELD), CPL_sms_msisdn(e->u.sms->incoming));
}

static void accept_incoming(PushInbox *inbox)
{
    SmsMessage *m = inbox->incoming;
    m->next = NULL;
    SmsMessage **tail = &inbox->head;
    int count = 0;
    while (*tail) {
        ++count;
        tail = &(*tail)->next;
    }
    if (count == PUSH_SMS_QUEUE_LIMIT) {
        SmsMessage *oldest = inbox->head;
        inbox->head = oldest->next;
        CPL_sms_free(oldest);
    }
    *tail = m;
    inbox->incoming = NULL;
}

static int resume_sms(VmCallback *callback, void *context)
{
    PushEntry *e = context;
    const PushOps *op = ops(e);
    int watch;
    switch (e->state) {
    case INITIALIZING:
        if (op->init(e) == -1) goto stopped;
        e->state = OPENING;
        /* fall through */
    case OPENING:
        if (op->open(e) == -1) goto stopped;
        e->state = ARM_WATCH;
        /* fall through */
    case ARM_WATCH:
        ASYNC_initCallbackNotifier(callback, e->resume, e);
        e->state = WATCHING;
        /* fall through */
    case WATCHING:
        watch = op->watch(e);
        if (watch == PUSH_WATCH_PENDING) break;
        if (watch) goto finished;
        if (e->checked_out || op->filter(e)) {
            accept_incoming(e->u.sms);
            e->event = 0;
            if (e->checked_out) CPL_sms_notifyReader();
            else Jbed_push_sendPushEvent(e);
        } else {
            CPL_sms_free(e->u.sms->incoming);
            e->u.sms->incoming = NULL;
        }
        e->state = ARM_WATCH;
        vm_current_notifier()->state = VM_LOOP;
        e->registered = 1;
        return 0;
    case PAUSED:
        e->paused = 1;
        break;
    default:
        goto finished;
    }
    vm_current_notifier()->state = VM_BUSY;
    e->registered = 1;
    return 0;
stopped:
    e->state = STOPPED;
finished:
    e->registered = 0;
    return 1;
}

int push_sms_create(PushEntry *e)
{
    const char *s = fields(e);
    if (!strncmp(s, "sms://:", 7)) {
        e->port = atoi(s + 7);
        e->resume = resume_sms;
        e->u.sms = calloc(1, sizeof(*e->u.sms));
        if (e->u.sms) return 1;
    }
    free(e);
    return 0;
}

const PushOps PushConnections[12] = {
    [ALARM] = {push_alarm_create, push_alarm_add, push_alarm_init, push_alarm_open, push_alarm_watch,
               push_alarm_discard, push_alarm_close, push_alarm_check_filter, push_alarm_check_port,
               push_start_alarm_connection, push_alarm_store_info, push_alarm_revive_info, NULL,
               push_hasConn, push_resetEntry},
    [SMS] = {push_sms_create, push_sms_add, push_sms_init, push_sms_open, push_sms_watch,
             push_sms_discard, push_sms_close, push_sms_check_filter, push_sms_check_port,
             push_start_sms_connection, push_sms_store_info, push_sms_revive_info, push_matchConn,
             push_sms_hasConn, push_resetEntry}
};
