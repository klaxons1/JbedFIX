#ifndef JBED_PLATFORM_MEDIA_H
#define JBED_PLATFORM_MEDIA_H

#include "jbni_objects.h"

typedef struct {
    int32_t id, type;
    uint8_t empty;
    VmNotifier *notifier;
    uint8_t flag;
    int32_t position, state;
} MediaContext;

int android_media_createPlayer(MediaContext *, const char *source);
int android_media_getMetaData(MediaContext *, int *count, char **strings);
int android_media_operation(MediaContext *, int type, unsigned op, int p1, int p2, int p3);
int android_media_openStreamDev(int handle, int type);

int android_media_getSnapshot(MediaContext *player, const char *format);

int CPL_media_init(void);
void CPL_media_term(void);
int CPL_media_getConst(int type, int key);
int CPL_media_openWavStreamDev(void);
int CPL_media_streamWrite(int type, int handle, const void *data, int length, unsigned chunk);
void CPL_media_sendShortMidi(void);
int CPL_media_sendLongMidi(void);
int CPL_media_midiOperation(void);
int CPL_media_openStreamDev(int type, int mode, int handle, const JbArray *data, int length);
MediaContext *CPL_media_prepareDev(int type, int mode, const JbArray *data, int length);
int CPL_media_operation(MediaContext *, int type, unsigned op, int p1, int p2, int p3, JbArray *out);
void jbed_handle_media_createPlayer(MediaContext *);
int jbed_handle_media_finishPlay(int player);
const char *getOperationName(int op);
int dir_exits(const char *path);
int createdir(const char *path);
int Jbed_mediaSendSimpleCustomizedEvent(int event, int value);
int Jbed_mediaSendProprietaryStringEvent(int player, const uint16_t *name, int name_length,
                                         const uint16_t *value, int value_length);
int Jbed_mediaSendEvent(int player, int event, int value);
int JbniS_com_jbed_tina_media_player_NativeCoreStreamPlayer_nWrite(
    void *player, int type, int handle, const JbArray *data, int offset, int count, unsigned chunk);
int JbniS_com_jbed_tina_media_player_NativeCoreStreamPlayer_nOpen(
    void *player, int type, int mode, int handle, const JbArray *data, int length);
MediaContext *JbniS_com_jbed_tina_media_player_NativeCoreStreamPlayer_nPrepare(
    void *player, int type, int mode, const JbArray *data, int length);
int JbniS_com_jbed_tina_media_player_NativePlayer_nGetMediaConstant(int type, int key);
int JbniS_com_jbed_tina_media_player_NativePlayer_nMediaOperation(
    MediaContext *, int type, unsigned op, int p1, int p2, int p3, JbArray *out);
int JbniS_com_jbed_tina_media_NativeMediaSystem_nInitializeMedia(void);
int JbniS_com_jbed_tina_media_NativeMediaSystem_nFinalizeMedia(void);
#endif
