#include "pim.h"

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#define REF(type, ref) ((type *)(uintptr_t)(ref))
enum { FIELD_SLOTS = 10 };

enum {
    CONTACT_ADDR = 100, CONTACT_EMAIL = 103, CONTACT_FORMATTED_ADDR = 104,
    CONTACT_FORMATTED_NAME = 105, CONTACT_NAME = 106, CONTACT_NOTE = 108,
    CONTACT_ORG = 109, CONTACT_PHOTO = 110, CONTACT_TEL = 115,
    CONTACT_TITLE = 116, CONTACT_URL = 118,
    EVENT_ALARM = 100, EVENT_CLASS = 101, EVENT_END = 102, EVENT_LOCATION = 103,
    EVENT_NOTE = 104, EVENT_START = 106, EVENT_SUMMARY = 107, EVENT_UID = 108,
    TODO_COMPLETED = 101, TODO_SUMMARY = 107, TODO_UID = 108,
    ATTR_FAX = 4, ATTR_HOME = 8, ATTR_MOBILE = 16, ATTR_OTHER = 32,
    ATTR_PAGER = 64, ATTR_PREFERRED = 128, ATTR_WORK = 512,
    REPEAT_DAILY = 16, REPEAT_YEARLY = 19,
    REPEAT_COUNT = 32, REPEAT_END = 64, REPEAT_INTERVAL = 128
};

_Static_assert(offsetof(PimArray, data) == 16, "Jbed array layout");
_Static_assert(offsetof(PimString, length) == 20, "Jbed string layout");
_Static_assert(offsetof(PimField, values) == 32, "PIM field layout");
_Static_assert(offsetof(PimList, type) == 40, "PIM list layout");
_Static_assert(offsetof(PimItem, revision) == 48, "PIM item layout");
_Static_assert(offsetof(PimEvent, repeat_rule) == 56, "PIM event layout");
_Static_assert(offsetof(PimRepeatRule, end) == 56, "PIM recurrence layout");

extern void Jbni_intern_raiseCommonException(int);
extern void Jbni_intern_raiseException(const char *);
typedef struct { const uint16_t *chars; int length; } Text;
typedef struct {
    int32_t attributes[FIELD_SLOTS];
    const uint16_t *chars[FIELD_SLOTS];
    int32_t lengths[FIELD_SLOTS];
} ContactValues;

static PimResult result;
static const char *const names[] = {NULL, "Contact List", "Event List", "ToDo List"};

static Text text(const PimString *s)
{
    if (!s) return (Text){0};
    return (Text){jb_string_chars(s), s->length};
}

static PimArray *result_array(PimResult *r, bool ints)
{
    PimArray *a = ints ? Jbni_newIntArray((int)r->length / 4) : Jbni_newByteArray((int)r->length);
    if (a && r->length) memcpy(a->data, r->bytes, r->length);
    free(r->bytes);
    r->bytes = NULL;
    if (!a) Jbni_intern_raiseCommonException(JBED_EXCEPTION_OUT_OF_MEMORY);
    return a;
}

PimArray *getIntArrayFromPIMResult(PimResult *r) { return result_array(r, true); }
PimArray *getByteArrayFromPIMResult(PimResult *r) { return result_array(r, false); }

static PimValue ints(const int32_t *data, int n)
{
    PimArray *a = Jbni_newIntArray(n);
    if (a && n) memcpy(a->data, data, (size_t)n * sizeof(*data));
    return (PimValue)a;
}

int CPL_pim_startUp(void) { return 0; }
int CPL_pim_shutDown(void) { free(result.bytes); result.bytes = NULL; return 0; }
int CPL_pim_closePIMList(int handle) { (void)handle; return 0; }

int CPL_pim_maxValues(int type, int field)
{
    switch (type) {
    case PIM_CONTACT:
        return field == CONTACT_EMAIL || field == CONTACT_FORMATTED_ADDR || field == CONTACT_TEL
            ? FIELD_SLOTS : 1;
    case PIM_EVENT: return field == EVENT_ALARM ? FIELD_SLOTS : 1;
    case PIM_TODO: return 1;
    default: return 0;
    }
}

int CPL_pim_itemMaxCategories(const PimItem *item) { (void)item; return PIM_ERROR; }
int CPL_pim_maxCategories(int handle) { (void)handle; return PIM_ERROR; }
int CPL_pim_addCategory(int handle, const PimString *s) { (void)handle; (void)s; return PIM_ERROR; }
int CPL_pim_deleteCategory(int handle, const PimString *s) { return CPL_pim_addCategory(handle, s); }
int CPL_pim_renameCategory(int handle, const PimString *s, const PimString *to)
{
    (void)to; return CPL_pim_addCategory(handle, s);
}
PimValue CPL_pim_getCategories(int handle) { (void)handle; return ints(NULL, 0); }
PimValue CPL_pim_getItemCategories(const PimItem *item) { (void)item; return ints(NULL, 0); }

PimValue CPL_pim_getSuppFields(int type)
{
    static const int32_t contact[] = {CONTACT_FORMATTED_NAME, CONTACT_NAME, CONTACT_ADDR, CONTACT_TITLE,
        CONTACT_ORG, CONTACT_NOTE, CONTACT_TEL, CONTACT_EMAIL, CONTACT_PHOTO};
    static const int32_t event[] = {EVENT_SUMMARY, EVENT_LOCATION, EVENT_NOTE, EVENT_END,
        EVENT_START, EVENT_ALARM, EVENT_CLASS, EVENT_UID};
    static const int32_t todo[] = {TODO_SUMMARY, TODO_COMPLETED, TODO_UID};
    PimValue fields;
    switch (type) {
    case PIM_CONTACT: fields = ints(contact, 9); break;
    case PIM_EVENT: fields = ints(event, 8); break;
    case PIM_TODO: fields = ints(todo, 3); break;
    default: fields = ints(NULL, 0);
    }
    return fields ? fields : PIM_ERROR;
}

PimValue CPL_pim_getSuppAttrs(int type, int field)
{
    static const int32_t phone[] = {ATTR_PREFERRED, ATTR_HOME, ATTR_MOBILE, ATTR_WORK,
        ATTR_FAX, ATTR_PAGER, ATTR_OTHER};
    static const int32_t address[] = {ATTR_PREFERRED, ATTR_HOME, ATTR_WORK, ATTR_OTHER};
    if (type == PIM_CONTACT) {
        if (field == CONTACT_TEL) return ints(phone, 7);
        if (field == CONTACT_EMAIL || field == CONTACT_FORMATTED_ADDR) return ints(address, 4);
    }
    return ints(NULL, 0);
}

PimValue CPL_pim_getSuppRRuleFields(int handle, int frequency)
{
    (void)handle;
    if (frequency < REPEAT_DAILY || frequency > REPEAT_YEARLY) return ints(NULL, 0);
    /* Jbed rounds heap allocations to 32 bytes. The last store occupies the
     * padding in the three-element array, leaving element zero untouched. */
    PimArray *a = Jbni_newIntArray(3);
    a->data[1] = REPEAT_INTERVAL;
    a->data[2] = REPEAT_COUNT;
    a->data[3] = REPEAT_END;
    return (PimValue)a;
}

PimValue getSuppElems(const PimElement *options, int count)
{
    int n = 0;
    for (int i = 0; i < count; ++i) n += options[i].supported != 0;
    PimArray *a = Jbni_newIntArray(n);
    if (a) {
        int out = 0;
        for (int i = 0; i < count; ++i)
            if (options[i].supported) a->data[out++] = (uint32_t)options[i].element;
    }
    return (PimValue)a;
}
PimValue getNameSuppElems(const PimElement *options, int count) { return getSuppElems(options, count); }

PimValue getContactSuppArrElems(int field)
{
    static const PimElement options[] = {{0,1},{1,1},{2,1},{3,1},{4,1},{5,1},{6,1}};
    return getSuppElems(options, field == CONTACT_ADDR ? 7 : field == CONTACT_NAME ? 5 : 0);
}
PimValue CPL_pim_getSuppArrElems(int type, int field)
{
    if (type == PIM_CONTACT) return getContactSuppArrElems(field);
    return type == PIM_EVENT || type == PIM_TODO ? ints(NULL, 0) : PIM_ERROR;
}

int CPL_pim_removePIMItem(int handle, const PimString *uid)
{
    Text id = text(uid);
    return uid && android_pim_remove(handle, id.chars, id.length) >= 0 ? 0 : PIM_ERROR;
}

PimValue CPL_pim_openPIMList(int type, const PimString *requested)
{
    if (!android_pim_isSupported(type) || type < PIM_CONTACT || type > PIM_TODO) return PIM_ERROR;
    const char *name = names[type];
    size_t n = strlen(name);
    if (requested) {
        Text s = text(requested);
        for (size_t i = 0; i < n; ++i)
            if (s.chars[i] != (uint8_t)name[i]) return PIM_ERROR;
    }
    result.status = type;
    result.length = (uint32_t)n;
    result.bytes = malloc(n);
    if (!result.bytes) return PIM_ERROR;
    memcpy(result.bytes, name, n);
    return (PimValue)&result;
}

PimValue CPL_pim_listPIMLists(int type)
{
    if (!android_pim_isSupported(type)) return (PimValue)Jbni_newByteArray(0);
    if (type < PIM_CONTACT || type > PIM_TODO) return PIM_ERROR;
    const char *name = names[type];
    size_t n = strlen(name);
    PimArray *a = Jbni_newByteArray((int)n + 8);
    if (a) {
        uint8_t *p = (uint8_t *)a->data;
        memset(p, 0, 8);
        p[3] = 1;
        p[7] = (uint8_t)n;
        memcpy(p + 8, name, n);
        return (PimValue)a;
    }
    a = Jbni_newByteArray(0);
    if (a) return (PimValue)a;
    Jbni_intern_raiseCommonException(JBED_EXCEPTION_OUT_OF_MEMORY);
    return PIM_ERROR;
}

PimValue CPL_pim_getNextItem(const PimItem *previous, int handle)
{
    Text id = text(previous ? REF(PimString, previous->uid) : NULL);
    void *bytes = NULL;
    size_t n = 0;
    if (android_pim_getNextItem(handle, id.chars, id.length, &bytes, &n) < 0 || !bytes) return PIM_ERROR;
    PimArray *a = Jbni_newByteArray((int)n);
    if (a && n) memcpy(a->data, bytes, n);
    free(bytes);
    return (PimValue)a;
}

static PimArray *values(const PimField *f) { return REF(PimArray, f->values); }
static Text field_text(const PimField *f) { return text(REF(PimString, values(f)->data[0])); }
PimArray *getBinaryDataFromField(const PimField *f, int slot)
{
    return REF(PimArray, values(f)->data[slot]);
}

static void contact_values(ContactValues *dest, const PimField *f, int nested, int fallback)
{
    PimArray *a = values(f);
    int count = f->count;
    if (nested) {
        a = REF(PimArray, a->data[0]);
        count = a->length;
    }
    for (int i = 0; i < count; ++i) {
        const PimString *s = REF(PimString, a->data[i]);
        if (!s) continue;
        int attr = (int)REF(PimArray, f->attributes)->data[i];
        dest->attributes[i] = attr ? attr : fallback;
        dest->chars[i] = jb_string_chars(s);
        dest->lengths[i] = s->length;
    }
}

static PimValue store_result(int status, void *bytes, size_t size)
{
    if (status < 0) return PIM_ERROR;
    result.length = (uint32_t)size;
    result.bytes = malloc(size);
    if (size) memcpy(result.bytes, bytes, size);
    free(bytes);
    return (PimValue)&result;
}

static PimValue store_contact(const PimItem *item)
{
    ContactValues name = {0}, address = {0}, phone = {0}, email = {0}, url = {0};
    Text formatted = {0}, title = {0}, org = {0}, note = {0};
    const void *photo = NULL;
    int photo_size = 0;
    PimArray *fields = REF(PimArray, item->fields);
    for (int i = 0; i < fields->length; ++i) {
        PimField *f = REF(PimField, fields->data[i]);
        if (f->count <= 0) continue;
        switch (f->id) {
        case CONTACT_ADDR: contact_values(&address, f, 1, ATTR_WORK); break;
        case CONTACT_NAME: contact_values(&name, f, 1, ATTR_WORK); break;
        case CONTACT_TEL: contact_values(&phone, f, 0, ATTR_MOBILE); break;
        case CONTACT_EMAIL: contact_values(&email, f, 0, ATTR_WORK); break;
        case CONTACT_URL: contact_values(&url, f, 0, ATTR_WORK); break;
        case CONTACT_FORMATTED_NAME: formatted = field_text(f); break;
        case CONTACT_TITLE: title = field_text(f); break;
        case CONTACT_ORG: org = field_text(f); break;
        case CONTACT_NOTE: note = field_text(f); break;
        case CONTACT_PHOTO: {
            PimArray *a = getBinaryDataFromField(f, 0);
            if (a && a->length > 0) {
                photo = a->data;
                photo_size = a->length;
            }
            break;
        }
        }
    }
    Text uid = text(REF(PimString, item->uid));
    size_t size = 0;
    void *out = NULL;
    int status = android_pim_storeContact(uid.chars, uid.length, formatted.chars, formatted.length,
        name.attributes, name.chars, name.lengths, title.chars, title.length, org.chars, org.length,
        note.chars, note.length, phone.attributes, phone.chars, phone.lengths, email.attributes,
        email.chars, email.lengths, address.attributes, address.chars, address.lengths,
        url.attributes, url.chars, url.lengths, photo, (size_t)photo_size, &out, &size, FIELD_SLOTS);
    return store_result(status, out, size);
}

static PimValue store_event(const PimEvent *event)
{
    const PimItem *item = &event->item;
    int32_t alarms[FIELD_SLOTS] = {0}, classification = 0;
    int64_t start = 0, end = 0;
    Text summary = {0}, note = {0}, location = {0};
    PimArray *fields = REF(PimArray, item->fields);
    for (int i = 0; i < fields->length; ++i) {
        PimField *f = REF(PimField, fields->data[i]);
        if (f->count <= 0) continue;
        switch (f->id) {
        case EVENT_ALARM: memcpy(alarms, values(f)->data, (size_t)f->count * sizeof(*alarms)); break;
        case EVENT_CLASS: classification = (int32_t)values(f)->data[0]; break;
        case EVENT_END: memcpy(&end, values(f)->data, sizeof(end)); break;
        case EVENT_START: memcpy(&start, values(f)->data, sizeof(start)); break;
        case EVENT_LOCATION: location = field_text(f); break;
        case EVENT_NOTE: note = field_text(f); break;
        case EVENT_SUMMARY: summary = field_text(f); break;
        }
    }
    const PimRepeatRule *r = REF(PimRepeatRule, event->repeat_rule);
    Text uid = text(REF(PimString, item->uid));
    size_t size = 0;
    void *out = NULL;
    int status = android_pim_storeEvent(uid.chars, uid.length, summary.chars, summary.length,
        note.chars, note.length, location.chars, location.length, classification, start, end,
        alarms, FIELD_SLOTS, r ? r->frequency : 0, r ? r->interval : 0, r ? r->count : 0,
        r ? r->end : 0, &out, &size);
    return store_result(status, out, size);
}

static PimValue store_todo(const PimItem *item)
{
    uint8_t completed = 0;
    Text summary = {0};
    PimArray *fields = REF(PimArray, item->fields);
    for (int i = 0; i < fields->length; ++i) {
        PimField *f = REF(PimField, fields->data[i]);
        if (f->count <= 0) continue;
        if (f->id == TODO_SUMMARY) summary = field_text(f);
        if (f->id == TODO_COMPLETED) completed = *(const uint8_t *)values(f)->data;
    }
    Text uid = text(REF(PimString, item->uid));
    size_t size = 0;
    void *out = NULL;
    int status = android_pim_storeTodo(uid.chars, uid.length, summary.chars, summary.length,
                                       completed, &out, &size);
    return store_result(status, out, size);
}

PimValue CPL_pim_storeItem(const PimItem *item)
{
    switch (REF(PimList, item->list)->handle) {
    case PIM_CONTACT: return store_contact(item);
    case PIM_EVENT: return store_event((const PimEvent *)item);
    case PIM_TODO: return store_todo(item);
    default: return PIM_ERROR;
    }
}

static bool first_call(void) { return vm_current_notifier()->state == VM_DONE0; }
static PimResult *completion(void) { return ASYNC_getStateFromNotifier(vm_current_notifier()); }
static void suspend_call(void) { vm_current_notifier()->state = VM_BUSY; }
static void pim_exception(void) { Jbni_intern_raiseException("javax/microedition/pim/PIMException"); }

PimString *JbniV_com_jbed_pim_PIMItemImpl_storeItem0(PimItem *item)
{
    PimResult *r;
    if (first_call()) {
        PimValue value = CPL_pim_storeItem(item);
        if (value == PIM_PENDING) { suspend_call(); return NULL; }
        if (value == PIM_ERROR) { pim_exception(); return NULL; }
        r = (PimResult *)value;
    } else {
        r = completion();
        if (r->status == PIM_ERROR) { pim_exception(); return NULL; }
    }
    PimArray *a = getByteArrayFromPIMResult(r);
    memcpy(&item->revision, a->data, sizeof(item->revision));
    return Jbni_intern_newStringExc((char *)a->data + 8);
}

static void finish_update(int status)
{
    if (status == PIM_PENDING) suspend_call();
    else if (status == PIM_ERROR) pim_exception();
}

static void remove_item(const PimList *list, const PimItem *item)
{
    if (first_call()) finish_update(CPL_pim_removePIMItem(list->handle, REF(PimString, item->uid)));
    else if (completion()->status == -1) pim_exception();
}

void JbniV_com_jbed_pim_ToDoListImpl_removeToDo0(const PimList *l, const PimItem *i) { remove_item(l, i); }
void JbniV_com_jbed_pim_EventListImpl_removeEvent0(const PimList *l, const PimItem *i) { remove_item(l, i); }
void JbniV_com_jbed_pim_ContactListImpl_removeContact0(const PimList *l, const PimItem *i) { remove_item(l, i); }

static int finish_limit(int value, int pending_value)
{
    if (value == PIM_PENDING) {
        suspend_call();
        return pending_value;
    }
    return value == PIM_ERROR ? 0 : value;
}

int JbniV_com_jbed_pim_PIMItemImpl_maxCategories0(const PimItem *item)
{
    return first_call() ? finish_limit(CPL_pim_itemMaxCategories(item), 0) : completion()->status;
}

int JbniV_com_jbed_pim_PIMListImpl_maxValues0(const PimList *list, int field)
{
    return first_call() ? finish_limit(CPL_pim_maxValues(list->handle, field), PIM_PENDING) : completion()->status;
}

int JbniV_com_jbed_pim_PIMListImpl_maxCategories0(const PimList *list)
{
    return first_call() ? finish_limit(CPL_pim_maxCategories(list->handle), 0) : completion()->status;
}

static PimArray *finish_array(PimValue value, bool throw_on_error)
{
    if (value == PIM_PENDING) { suspend_call(); return NULL; }
    if (value == PIM_ERROR) {
        if (throw_on_error) pim_exception();
        return NULL;
    }
    return (PimArray *)value;
}

static PimArray *resume_array(bool ints)
{
    PimResult *r = completion();
    if (r->status == -1) return NULL;
    return result_array(r, ints);
}

PimArray *JbniV_com_jbed_pim_PIMItemEnumerationImpl_getNextItem0(void *enumeration, const PimItem *item,
                                                                const PimList *list)
{
    (void)enumeration;
    return first_call() ? finish_array(CPL_pim_getNextItem(item, list->handle), false) : resume_array(false);
}

PimArray *JbniV_com_jbed_pim_PIMListImpl_getSuppArrElems0(const PimList *list, int field)
{
    return first_call() ? finish_array(CPL_pim_getSuppArrElems(list->handle, field), false) : resume_array(true);
}
PimArray *JbniV_com_jbed_pim_PIMListImpl_getSuppAttrs0(const PimList *list, int field)
{
    return first_call() ? finish_array(CPL_pim_getSuppAttrs(list->handle, field), false) : resume_array(true);
}
PimArray *JbniV_com_jbed_pim_EventListImpl_getSuppRRuleFields0(const PimList *list, int frequency)
{
    return first_call() ? finish_array(CPL_pim_getSuppRRuleFields(list->handle, frequency), false) : resume_array(true);
}
PimArray *JbniV_com_jbed_pim_PIMListImpl_getSuppFields0(const PimList *list)
{
    return first_call() ? finish_array(CPL_pim_getSuppFields(list->handle), false) : resume_array(true);
}

static PimArray *resume_categories(void)
{
    PimResult *r = completion();
    if (r->status == PIM_ERROR) { pim_exception(); return NULL; }
    return getByteArrayFromPIMResult(r);
}

PimArray *JbniV_com_jbed_pim_PIMItemImpl_getCategories0(const PimItem *item)
{
    return first_call() ? finish_array(CPL_pim_getItemCategories(item), true) : resume_categories();
}
PimArray *JbniV_com_jbed_pim_PIMListImpl_getCategories0(const PimList *list)
{
    return first_call() ? finish_array(CPL_pim_getCategories(list->handle), true) : resume_categories();
}

void JbniV_com_jbed_pim_PIMListImpl_renameCategory0(const PimList *list, const PimString *from, const PimString *to)
{
    if (first_call()) finish_update(CPL_pim_renameCategory(list->handle, from, to));
    else if (completion()->status == -1) pim_exception();
}
void JbniV_com_jbed_pim_PIMListImpl_addCategory0(const PimList *list, const PimString *s)
{
    if (first_call()) finish_update(CPL_pim_addCategory(list->handle, s));
    else if (completion()->status == -1) pim_exception();
}
void JbniV_com_jbed_pim_PIMListImpl_deleteCategory0(const PimList *list, const PimString *s)
{
    if (first_call()) finish_update(CPL_pim_deleteCategory(list->handle, s));
    else if (completion()->status == -1) pim_exception();
}

PimArray *JbniV_com_jbed_pim_PIMImpl_listPIMLists0(void *self, int type)
{
    (void)self;
    return first_call() ? finish_array(CPL_pim_listPIMLists(type), true) : getByteArrayFromPIMResult(completion());
}

static VmMutex list_mutexes[3];
static VmNotifier **waiting;
static int waiting_capacity, open_instances, next_list_id = 1;

static VmMutex *list_mutex(int type)
{
    return type >= PIM_CONTACT && type <= PIM_TODO ? &list_mutexes[type - 1] : NULL;
}

static int retain_pim(void)
{
    if (!open_instances) {
        int status = CPL_pim_startUp();
        if (status) return status;
    }
    ++open_instances;
    return 0;
}

static int release_pim(void)
{
    if (--open_instances) return 0;
    free(waiting);
    return CPL_pim_shutDown();
}

int JbniV_com_jbed_pim_PIMImpl_open0(void *self) { (void)self; return retain_pim(); }
void JbniV_com_jbed_pim_PIMImpl_finalize(void *self) { (void)self; release_pim(); }

static int close_list(PimList *list)
{
    if (!list->valid) return 0;
    Jbed_async_mutex_notify(list_mutex(list->type), list->handle, list->mode);
    int status;
    if (first_call()) {
        status = CPL_pim_closePIMList(list->handle);
        if (status == PIM_PENDING) suspend_call();
    } else {
        status = completion()->status;
    }
    if (status == PIM_PENDING) return status;
    list->valid = 0;
    return release_pim();
}

void JbniV_com_jbed_pim_PIMListImpl_close0(PimList *list) { close_list(list); }

static int complete_close(VmCallback *callback, void *context)
{
    (void)callback;
    (void)completion();
    free(context);
    release_pim();
    return 1;
}

void JbniV_com_jbed_pim_PIMListImpl_finalize(PimList *list)
{
    if (!list->valid) return;
    VmCallback *cb = malloc(sizeof(*cb));
    VmNotifier *n = ASYNC_initCallbackNotifier(cb, complete_close, cb);
    VmNotifier *previous = JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier;
    JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier = n;
    int status = close_list(list);
    JbniF_com_jbed_runtime_AsyncIO_ASYNC_currentNotifier = previous;
    list->valid = 0;
    if (status != PIM_PENDING) {
        ASYNC_deregisterCallbackNotifier(cb);
        free(cb);
    }
}

static int remember_waiter(VmNotifier *n)
{
    int unused = -1;
    for (int i = 0; i < waiting_capacity; ++i) {
        if (waiting[i] == n) return 0;
        if (!waiting[i] && unused < 0) unused = i;
    }
    if (unused < 0) {
        unused = waiting_capacity;
        VmNotifier **slots = calloc((size_t)waiting_capacity + 16, sizeof(*slots));
        if (!slots) return PIM_ERROR;
        if (waiting_capacity) memcpy(slots, waiting, (size_t)waiting_capacity * sizeof(*slots));
        waiting_capacity += 16;
        waiting = slots;
    }
    waiting[unused] = n;
    return 0;
}

PimString *JbniV_com_jbed_pim_PIMListImpl_open0(PimList *list)
{
    Text name = text(REF(PimString, list->name));
    VmNotifier *n = vm_current_notifier();
    if (!list->id) list->id = next_list_id++;
    VmMutex *mutex = list_mutex(list->type);
    switch (Jbed_async_mutex_check(mutex, name.chars, name.length, list->mode)) {
    case 0:
        if (remember_waiter(n) == PIM_ERROR) {
            Jbed_async_mutex_notify(mutex, 0, list->mode);
            pim_exception();
            return NULL;
        }
        suspend_call();
        return NULL;
    case 3:
        pim_exception();
        return NULL;
    }

    int i = 0;
    while (i < waiting_capacity && waiting[i] != n) ++i;
    PimValue value;
    if (first_call() || i < waiting_capacity) {
        if (i < waiting_capacity) waiting[i] = NULL;
        value = CPL_pim_openPIMList(list->type, REF(PimString, list->name));
        if (value == PIM_PENDING) { suspend_call(); return NULL; }
    } else {
        PimResult *r = completion();
        value = r->status == PIM_ERROR ? PIM_ERROR : (PimValue)r;
    }
    if (value == PIM_ERROR) {
        Jbed_async_mutex_notify(mutex, 0, list->mode);
        pim_exception();
        return NULL;
    }
    PimResult *r = (PimResult *)value;
    list->valid = 1;
    list->handle = r->status;
    Jbed_async_mutex_mapHandleToName(mutex, name.chars, name.length, list->handle);
    PimArray *a = getByteArrayFromPIMResult(r);
    PimString *s = Jbni_intern_newStringExc((const char *)a->data);
    retain_pim();
    return s;
}
