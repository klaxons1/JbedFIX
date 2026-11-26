#ifndef JBED_PLATFORM_AMS_H
#define JBED_PLATFORM_AMS_H

#include "jbni_objects.h"
#include <stddef.h>

enum {
    AMS_REQUEST_INSTALL = 2, AMS_REQUEST_VM_STATE = 5, AMS_REQUEST_REMOVE = 14
};

int jbed_ams_fetchAmsEvent(int *event, int *result, void **data, size_t *length);
void android_handle_ams_event(int event, int result, const void *data, int length);

void JPL_ams_wantForeground(void);
void JbniS_com_jbed_ams_NativeAms_nativeGetEvent(void);
void JbniS_com_jbed_ams_NativeAms_nativePostEvent(int event, int result, void *argument);
int Jbed_ams_event_getIsolateId(void);
JbUpcallQueue *Jbed_ams_event_getUpcallQueue(void);
void Jbed_ams_event_requestRemove(const char *suite);
void Jbed_ams_event_requestInstall(const char *url);
void Jbed_ams_event_requestLocalInstall(const char *path, const char *extra);
int Jbed_ams_event_sendEvent(int event);
int JbniS_com_jbed_ams_AmsCallHandler_nativeAmsListenerUp(void);
int JbniS_com_jbed_ams_AmsCallHandler_nativeAmsListenerDown(void);
JbArray *OPL_ams_getCommandStateBuffer(void);
int OPL_ams_saveCommandStateBuffer(const JbArray *state);
int CPL_conc_setAppUserRequest(int request);
int JbniS_com_jbed_ams_AmsToolkitBase_nSignalAsyncEvent(int event, int result, void *data);
int JbniS_com_jbed_ams_AmsToolkitBase_signalEvent(int event, int result, void *data);
#endif
