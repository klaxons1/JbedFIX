#include "ams.h"
#include "vm_helpers.h"
#include "vm_lifecycle.h"

#include <stdlib.h>
#include <string.h>
#include <strings.h>

extern int android_LOGD(const char *format, ...);
extern int android_midp_platformRequest(const uint16_t *chars, int length);
extern int Jbni_intern_getStringUtf8(const JbString *, char *output, int capacity);
extern int Jbed_currentIsolate(void);

enum AmsEventId {
    EVENT_NONE = 0,
    EVENT_LIST = 1,
    EVENT_RUN = 2,
    EVENT_UPDATE = 3,
    EVENT_INSTALL_PROGRESS = 4,
    EVENT_INSTALL = 5,
    EVENT_INSTALL_CANCEL = 6,
    EVENT_REMOVE = 7,
    EVENT_PAUSE = 8,
    EVENT_RESUME = 9,
    EVENT_DESTROY = 10,
    EVENT_DESTROYED = 11,
    EVENT_INSTALL_STATUS = 12,
    EVENT_INSTALL_QUERY = 13,
    EVENT_INSTALL_UNSTOPPABLE = 14,
    EVENT_INSTALL_PREVIEW_JAD = 15,
    EVENT_INSTALL_AUTHENTICATION = 16,
    EVENT_PAUSED = 17,
    EVENT_RUNNING = 18,
    EVENT_INSTALL_STEP = 19,
    EVENT_INFO = 20,
    EVENT_RENAME = 21,
    EVENT_GET_ICONS = 22,
    EVENT_PERMISSIONS = 23,
    EVENT_PERMISSIONS_ANSWERS = 24,
    EVENT_QUERY = 25,
    EVENT_REMOVE_ALL = 26,
    EVENT_SET = 27,
    EVENT_INSTALL_STEP_COMPLETE = 28,
    EVENT_SELECT_STORAGE = 29,
    EVENT_REMOVABLE_MEDIA_CHANGED = 30,
    EVENT_MOVE = 31,
    EVENT_LIST_STORAGE = 32,
    EVENT_REQUEST_INSTALL = 33,
    EVENT_LIST_RUNNING_MIDLETS = 34,
    EVENT_JAR_DOWNLOAD_PROGRESS = 35,
    EVENT_JAR_DOWNLOAD = 36,
    EVENT_JAR_DOWNLOAD_COMPLETE = 37,
    EVENT_DRM_ACTIVATE = 38,
    EVENT_DRM_REINSTALL = 39,
    EVENT_RUN_DEBUG = 40,
    EVENT_PERMISSIONS_RESET_ANSWERS = 41,
    EVENT_PLATFORM_RESET = 42,
    EVENT_REQUEST_PUSH = 43,
    EVENT_REQUEST_SATSA = 44,
    EVENT_REQUEST_CHAPI = 45,
    EVENT_PREINSTALL_START = 46,
    EVENT_PREINSTALL_FINISH = 47,
    EVENT_RUNNING_MIDLET_MANAGER = 48,
    EVENT_NOTIFY_LAUNCH = 49,
    EVENT_SANITY_REPORT = 50,
    EVENT_REQUEST_PERMISSION = 51,
    EVENT_LIST_CERTIFICATES = 52,
    EVENT_CHANGE_CERTIFICATE_STATE = 53,
    EVENT_JAD_DOWNLOAD_PROGRESS = 54,
    EVENT_JAD_DOWNLOAD = 55,
    EVENT_JAD_DOWNLOAD_COMPLETE = 56,
    EVENT_INSTALL_QUERY_YES_NO = 57,
    EVENT_RUNTIME_ERROR = 58,
    EVENT_LIST_FOLDER_CONTENTS = 59,
    EVENT_CREATE_FOLDER = 60,
    EVENT_MOVE_FOLDER = 61,
    EVENT_RENAME_FOLDER = 62,
    EVENT_REMOVE_FOLDER = 63,
    EVENT_REMOVE_FOLDER_CONTENTS = 64,
    EVENT_SELECT_INSTALL_FOLDER = 65,
    EVENT_DRM_CHECK_RIGHTS = 66,
    EVENT_DRM_CONSTRAINT = 67,
};

/* The ROM keeps the pending payload, event ID and result in relative statics. */
typedef struct {
    uint8_t before_payload[416];
    JbRef payload;
    uint8_t before_event[1840 - 420];
    int32_t event, result;
} AmsStatics;
extern uint8_t *Jbed_relativeStaticsBase;

static AmsStatics *ams_statics(void) { return (AmsStatics *)Jbed_relativeStaticsBase; }

static int isolate_id = -1;
static JbUpcallQueue *queue;
static uint8_t inline_state[4096], *saved_state;
static int saved_length;

void JPL_ams_wantForeground(void) {}

static JbArray *unpack_strings(const uint8_t *data)
{
    unsigned count = *data++;
    const char *s = (const char *)data;
    void **roots = Jbed_nativeCallStateAdr;
    JbArray *a = Jbni_newObjectArray((int)count);
    *Jbed_nativeCallStateAdr++ = &a;
    for (unsigned i = 0; i < count; ++i) {
        JbString *entry = Jbni_intern_newString(s);
        a->data[i] = jb_ref(entry);
        s += strlen(s) + 1;
    }
    Jbed_nativeCallStateAdr = roots;
    return a;
}

void JbniS_com_jbed_ams_NativeAms_nativeGetEvent(void)
{
    int event, result;
    size_t size;
    void *data;
    if (jbed_ams_fetchAmsEvent(&event, &result, &data, &size) < 0 || !event) {
        android_LOGD("ERROR: JPL_ams_postEvent: failed to call jbed_ams_fetchAmsEvent\n");
        ams_statics()->event = EVENT_NONE;
        return;
    }

    AmsStatics *s = ams_statics();
    s->event = event;
    s->result = result;
    const uint8_t *bytes = data;
    switch (event) {
    case EVENT_LIST_FOLDER_CONTENTS:
        android_LOGD("JPL_ams_getEvent: EVENT_LIST_FOLDER_CONTENTS");
        /* fall through */
    case EVENT_RUN: case EVENT_UPDATE: case EVENT_INSTALL: case EVENT_REMOVE:
    case EVENT_PAUSE: case EVENT_RESUME: case EVENT_DESTROY: case EVENT_INSTALL_QUERY:
    case EVENT_INFO: case EVENT_GET_ICONS: case EVENT_PERMISSIONS: case EVENT_SELECT_STORAGE:
    case EVENT_DRM_ACTIVATE: case EVENT_DRM_REINSTALL: case EVENT_REMOVE_FOLDER:
    case EVENT_REMOVE_FOLDER_CONTENTS: case EVENT_SELECT_INSTALL_FOLDER:
    case EVENT_DRM_CHECK_RIGHTS: case EVENT_DRM_CONSTRAINT:
        s->payload = jb_ref(Jbni_intern_newString(data));
        break;
    case EVENT_REQUEST_SATSA:
        if (!data) return;
        goto strings;
    case EVENT_REMOVE_ALL:
        if (!data) { s->payload = 0; break; }
        goto strings;
    case EVENT_JAR_DOWNLOAD_COMPLETE:
        if (result != 24) break;
        /* fall through */
    case EVENT_INSTALL_AUTHENTICATION: case EVENT_RENAME: case EVENT_MOVE:
    case EVENT_CREATE_FOLDER: case EVENT_MOVE_FOLDER: case EVENT_RENAME_FOLDER:
    strings:
        s->payload = jb_ref(unpack_strings(bytes));
        break;
    case EVENT_PERMISSIONS_ANSWERS: case EVENT_SET: {
        if (event == EVENT_PERMISSIONS_ANSWERS && result != 1) break;
        if (event == EVENT_SET) s->result = (int)size;
        void **roots = Jbed_nativeCallStateAdr;
        JbArray *pair = Jbni_newIntArray(2);
        *Jbed_nativeCallStateAdr++ = &pair;
        if (event == EVENT_SET) {
            JbString *name = Jbni_intern_newString(data);
            pair->data[0] = jb_ref(name);
            pair->data[1] = (uint32_t)result;
        } else {
            pair->data[0] = bytes[0];
            pair->data[1] = bytes[1];
        }
        ams_statics()->payload = jb_ref(pair);
        Jbed_nativeCallStateAdr = roots;
        break;
    }
    case EVENT_REQUEST_PUSH: case EVENT_REQUEST_PERMISSION: {
        void **roots = Jbed_nativeCallStateAdr;
        JbArray *a = Jbni_newIntArray(1);
        *Jbed_nativeCallStateAdr = &a;
        a->data[0] = (uint32_t)result;
        ams_statics()->payload = jb_ref(a);
        Jbed_nativeCallStateAdr = roots;
        ams_statics()->result = bytes[0];
        break;
    }
    }
    free(data);
}

typedef struct { int length; void *bytes; } Payload;

static Payload copy_array(const JbArray *a)
{
    int length = a->length;
    void *bytes = malloc((size_t)length);
    memcpy(bytes, a->data, (size_t)length);
    return (Payload){length, bytes};
}

static Payload copy_string(const JbString *s)
{
    if (!s) return (Payload){0};
    int length = Jbni_intern_getStringUtf8(s, NULL, 0);
    void *bytes = malloc((size_t)length);
    Jbni_intern_getStringUtf8(s, bytes, length);
    return (Payload){length, bytes};
}

void JbniS_com_jbed_ams_NativeAms_nativePostEvent(int event, int result, void *arg)
{
    Payload p = {0};
    switch (event) {
    case EVENT_LIST: case EVENT_INSTALL_PREVIEW_JAD: case EVENT_INFO: case EVENT_GET_ICONS:
        if (arg) p = copy_array(arg);
        break;
    case EVENT_RUN:
        if (arg && result == 27) arg = (void *)(uintptr_t)((JbArray *)arg)->data[0];
        /* fall through */
    case EVENT_INSTALL: case EVENT_DRM_ACTIVATE:
    case EVENT_DESTROYED: case EVENT_INSTALL_QUERY: case EVENT_INSTALL_AUTHENTICATION:
    case EVENT_PAUSED: case EVENT_RUNNING: case EVENT_QUERY: case EVENT_REMOVE_ALL:
    case EVENT_REMOVABLE_MEDIA_CHANGED: case EVENT_REQUEST_INSTALL: case EVENT_DRM_REINSTALL:
    case EVENT_PREINSTALL_FINISH: case EVENT_INSTALL_QUERY_YES_NO: case EVENT_DRM_CHECK_RIGHTS:
        p = copy_string(arg);
        break;
    case EVENT_PERMISSIONS: case EVENT_SELECT_STORAGE: case EVENT_JAR_DOWNLOAD:
    case EVENT_REQUEST_PUSH: case EVENT_REQUEST_SATSA: case EVENT_REQUEST_CHAPI:
    case EVENT_NOTIFY_LAUNCH: case EVENT_SANITY_REPORT: case EVENT_REQUEST_PERMISSION:
    case EVENT_LIST_CERTIFICATES: case EVENT_RUNTIME_ERROR:
        p = copy_array(arg);
        break;
    case EVENT_MOVE: case EVENT_CREATE_FOLDER: case EVENT_MOVE_FOLDER:
    case EVENT_RENAME_FOLDER: case EVENT_REMOVE_FOLDER: case EVENT_REMOVE_FOLDER_CONTENTS:
        if (result == 15) p = copy_string(arg);
        break;
    case EVENT_LIST_STORAGE:
        if (result != 19) p = copy_array(arg);
        break;
    case EVENT_LIST_RUNNING_MIDLETS:
        if (result != 20) p = copy_array(arg);
        break;
    case EVENT_LIST_FOLDER_CONTENTS:
        android_LOGD("JPL_ams_postEvent: EVENT_LIST_FOLDER_CONTENTS");
        p = result == 1 ? copy_array(arg) : copy_string(arg);
        break;
    case EVENT_SELECT_INSTALL_FOLDER:
        android_LOGD("JPL_ams_postEvent: EVENT_SELECT_INSTALL_FOLDER");
        p = copy_string(arg);
        break;
    case EVENT_DRM_CONSTRAINT:
        if (arg) p = result == 15 ? copy_string(arg) : copy_array(arg);
        break;
    }
    android_handle_ams_event(event, result, p.bytes, p.length);
    free(p.bytes);
}

int Jbed_ams_event_getIsolateId(void) { return isolate_id; }
JbUpcallQueue *Jbed_ams_event_getUpcallQueue(void) { return queue; }

void Jbed_ams_event_requestRemove(const char *suite)
{
    if (queue && suite)
        Jbed_upcall_sendComplex(queue, isolate_id, JBED_UPCALL_AMS, AMS_REQUEST_REMOVE, "aa", suite, "");
}

void Jbed_ams_event_requestLocalInstall(const char *path, const char *extra)
{
    if (!queue || !path) return;
    size_t length = strlen(path);
    int count = Jbni_convertUtf8ToUcs2(path, -1, NULL, 0);
    uint16_t *name = malloc(2u * (size_t)count);
    if (!name) return;
    Jbni_convertUtf8ToUcs2(path, -1, name, 2 * count);
    if (!strcasecmp(path + length - 4, ".jad"))
        Jbed_upcall_sendComplex(queue, isolate_id, JBED_UPCALL_AMS, AMS_REQUEST_INSTALL, "saa", name, count, "", extra);
    else
        Jbed_upcall_sendComplex(queue, isolate_id, JBED_UPCALL_AMS, AMS_REQUEST_INSTALL, "asa", "", name, count, extra);
    free(name);
}

void Jbed_ams_event_requestInstall(const char *url)
{
    if (!queue || !url) return;
    size_t length = strlen(url);
    void **roots = Jbed_nativeCallStateAdr;
    JbString *s = Jbni_intern_newStringExc(url);
    *Jbed_nativeCallStateAdr++ = &s;
    if (!strcasecmp(url + length - 4, ".jad"))
        Jbed_upcall_sendComplex(queue, isolate_id, JBED_UPCALL_AMS, AMS_REQUEST_INSTALL, "sa", jb_string_chars(s), s->length, "");
    else
        Jbed_upcall_sendComplex(queue, isolate_id, JBED_UPCALL_AMS, AMS_REQUEST_INSTALL, "as", "", jb_string_chars(s), s->length);
    Jbed_nativeCallStateAdr = roots;
}

int Jbed_ams_event_sendEvent(int event)
{
    return queue && Jbed_upcall_sendSimple(queue, isolate_id, JBED_UPCALL_AMS, event) != 0;
}

int JbniS_com_jbed_ams_AmsCallHandler_nativeAmsListenerUp(void)
{
    if (!queue) {
        queue = Jbed_upcall_createQueue(1032, 0);
        if (!queue) return 0;
        isolate_id = Jbed_currentIsolate();
    }
    return 1;
}

int JbniS_com_jbed_ams_AmsCallHandler_nativeAmsListenerDown(void)
{
    if (queue) {
        Jbed_upcall_deleteQueue(queue);
        queue = NULL;
    }
    return 1;
}

JbArray *OPL_ams_getCommandStateBuffer(void)
{
    JbArray *a = NULL;
    if (saved_length > 0) {
        a = Jbni_newByteArray(saved_length);
        memcpy(a->data, saved_state, (size_t)saved_length);
        if (saved_state != inline_state) free(saved_state);
    }
    saved_state = NULL;
    saved_length = 0;
    return a;
}

int OPL_ams_saveCommandStateBuffer(const JbArray *a)
{
    if (a->length <= (int)sizeof(inline_state)) {
        saved_state = inline_state;
    } else {
        if (saved_state != inline_state) free(saved_state);
        saved_state = malloc((size_t)a->length);
        if (!saved_state) return 0;
    }
    if (a->length > 0) memcpy(saved_state, a->data, (size_t)a->length);
    saved_length = a->length;
    return 1;
}

int CPL_conc_setAppUserRequest(int request)
{
    return request == 3 || request == 4 ? Jbed_ams_event_sendEvent(request) : request;
}

int JbniS_com_jbed_ams_AmsToolkitBase_nSignalAsyncEvent(int event, int result, void *data)
{
    (void)result;
    if (event == 21) return 2;
    if (event == 29) JbniS_com_jbed_ams_NativeAms_nativePostEvent(EVENT_RUNTIME_ERROR, 0, data);
    return 0;
}

int JbniS_com_jbed_ams_AmsToolkitBase_signalEvent(int event, int result, void *data)
{
    if (event == 10) {
        JbString *s = data;
        if (s->length > 0 && !android_midp_platformRequest(jb_string_chars(s), s->length))
            return 9;
    } else if (event == 14) {
        if (result == 14) {
            android_LOGD("JPL_AMS_EVENT_AMS_LAUNCH_NOTIFICATION:JPL_AMS_LAUNCH_FOR_CHAPI\n");
            Jbed_requestState(VM_STATE_ACTIVE_FOREGROUND, NULL, NULL);
        } else if (result == 16) {
            android_LOGD("JPL_AMS_EVENT_AMS_LAUNCH_NOTIFICATION:JPL_AMS_LAUNCH_FROM_NATIVE_AMS\n");
        } else {
            android_LOGD("JPL_AMS_EVENT_AMS_LAUNCH_NOTIFICATION:[Unknown Result:%d]\n", result);
        }
    }
    return 0;
}
