#include "media.h"

#include <dirent.h>
#include <fcntl.h>
#include <limits.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

extern int android_LOGD(const char *format, ...);
#if UINTPTR_MAX == UINT32_MAX
_Static_assert(sizeof(MediaContext) == 28 && offsetof(MediaContext, notifier) == 12,
               "Android media player context layout");
#endif

enum { URI_TYPE = 88, CAPTURE_AMR = 132, CAMERA_SNAPSHOT = 144, CAPTURE_3GP = 149 };
static MediaContext *prepared_player;
static char media_path[257];
static int last_id, init_calls;
static JbUpcallQueue *media_queue;

void CPL_media_term(void) {}
int CPL_media_getConst(int type, int key) { (void)type; return key == 205 ? INT32_MAX : 0; }
int CPL_media_openWavStreamDev(void) { return 0; }

int CPL_media_streamWrite(int type, int handle, const void *data, int length, unsigned chunk)
{
    (void)type; (void)handle; (void)data; (void)length;
    return chunk <= 1 ? 0 : -1;
}

void CPL_media_sendShortMidi(void) {}
int CPL_media_sendLongMidi(void) { return -1; }
int CPL_media_midiOperation(void) { return -1; }

void jbed_handle_media_createPlayer(MediaContext *player)
{
    prepared_player = player;
    if (!player || !player->notifier) return;
    ASYNC_notify(player->notifier);
    prepared_player->notifier = NULL;
}

int jbed_handle_media_finishPlay(int player) { return Jbed_mediaSendEvent(player, 3, 0); }

int CPL_media_openStreamDev(int type, int mode, int handle, const JbArray *data, int length)
{
    (void)mode; (void)data; (void)length;
    return android_media_openStreamDev(handle, type);
}

const char *getOperationName(int op)
{
    static const char *const names[] = {
        NULL, "OP_RESET", "OP_CLOSE", "OP_PLAY", "OP_PAUSE", "OP_STOP", "OP_GETDURATION",
        "OP_GETPOSITION", "OP_SETPOSITION", "OP_GETVOLUME", "OP_SETVOLUME", "OP_GETCHUNKSIZE",
        "OP_DRAIN", NULL, "OP_SETDATASIZE", "OP_RELEASEDEVICE", NULL, "OP_GETSUPPORTEDCONTROLS",
        "OP_GETMETADATA", NULL, "OP_SETMEDIATYPE"
    };
    if ((unsigned)op < sizeof(names) / sizeof(names[0]) && names[op]) return names[op];
    android_LOGD("WARNING: UNKNOW_COMMAND id=%d\n", op);
    return "ERROR_UNKNOW";
}

static int is_capture(int type)
{
    return type == CAPTURE_AMR || type == CAPTURE_3GP || type == CAMERA_SNAPSHOT;
}

static const char *temp_path(const MediaContext *player)
{
    const char *ext;
    switch (player->type) {
    case 1: case 7: case 8: case 12: case 13: case 14: case CAMERA_SNAPSHOT:
        ext = "unspport"; break;
    case 2: ext = "mid"; break;
    case 3: case 131: ext = "wav"; break;
    case 4: case CAPTURE_AMR: ext = "amr"; break;
    case 5: ext = "mp3"; break;
    case 10: case 138: ext = "mpeg"; break;
    case 20: case 21: case CAPTURE_3GP: ext = "3gp"; break;
    case 22: ext = "mp4"; break;
    default: ext = "unknow"; break;
    }
    const char *dir = is_capture(player->type) ? "/sdcard/tmp" : "/data/data/com.esmertec.android.jbed/tmp";
    snprintf(media_path, sizeof(media_path), "%s/tmp_java_media%d.%s", dir, player->id, ext);
    return media_path;
}

static int write_temp(const char *path, const void *data, size_t size)
{
    int fd = open(path, O_WRONLY | O_CREAT, 0777);
    if (fd == -1) {
        android_LOGD("ERROR: failed to open file %s\n", path);
        return 0;
    }
    ssize_t written = write(fd, data, size);
    if (written < 0) android_LOGD("ERROR: failed write the data to %s errno=%d\n", path, (int)written);
    close(fd);
    return written >= 0;
}

int dir_exits(const char *path)
{
    if (!path) return -1;
    DIR *d = opendir(path);
    if (!d) return 0;
    closedir(d);
    return 1;
}

int createdir(const char *path)
{
    if (dir_exits(path)) return 0;
    return mkdir(path, 01411);
}

int CPL_media_init(void) { return createdir("/sdcard/tmp"); }

static void remove_temp(const MediaContext *player)
{
    const char *path = temp_path(player);
    int rc = unlink(path);
    if (rc) android_LOGD("ERROR: file remove failed %s, errno=%d\n", path, rc);
}

MediaContext *CPL_media_prepareDev(int type, int mode, const JbArray *data, int length)
{
    (void)mode;
    if (vm_current_notifier()->state != VM_DONE0) return prepared_player;
    MediaContext *player = malloc(sizeof(*player));
    if (!player) {
        android_LOGD("ERROR: fail to create media context\n");
        return NULL;
    }
    if (last_id > 10240) last_id = 0;
    player->id = ++last_id;
    player->type = type;
    player->empty = 0;
    player->notifier = NULL;
    player->flag = 0;
    player->position = -1;
    player->state = 0;

    if (type == URI_TYPE) {
        if (length > 256) {
            android_LOGD("ERROR: the url length is too long!\n");
            return NULL;
        }
        if (length) memcpy(media_path, data->data, (size_t)length);
        media_path[length] = 0;
    } else if (is_capture(type)) {
        temp_path(player);
        memmove(media_path + 15, media_path, strlen(media_path) + 1);
        memcpy(media_path, type == CAPTURE_AMR ? "capture://audio" : "capture://video", 15);
    } else if (!write_temp(temp_path(player), data ? data->data : NULL, (size_t)length)) {
        android_LOGD("ERROR: fail to store data to temp file\n");
        return NULL;
    }
    if (!length && !is_capture(type)) {
        android_LOGD("WARNING: the bufer is empty!!\n");
        player->empty = 1;
        return player;
    }

    player->notifier = vm_current_notifier();
    switch (android_media_createPlayer(player, media_path)) {
    case 0:
        player->notifier = NULL;
        return player;
    case 1:
        vm_current_notifier()->state = VM_BUSY;
        return NULL;
    default:
        android_LOGD("ERROR: fail to create android player\n");
        if (player->type != URI_TYPE) remove_temp(player);
        free(player);
        return NULL;
    }
}

static int get_metadata(MediaContext *player, int type, JbArray *out)
{
    if (is_capture(type)) return -2;
    char *s = NULL;
    int pairs;
    if (android_media_getMetaData(player, &pairs, &s) < 0) return -2;
    if (!pairs) return 0;
    void **roots = Jbed_nativeCallStateAdr;
    *Jbed_nativeCallStateAdr++ = &out;
    JbArray *entries = Jbni_newObjectArray(2 * pairs);
    out->data[0] = jb_ref(entries);
    for (int i = 0; i < pairs; ++i) {
        entries->data[2 * i] = jb_ref(Jbni_intern_newString(s));
        s += strlen(s) + 1;
        entries->data[2 * i + 1] = jb_ref(Jbni_intern_newString(s));
        s += strlen(s) + 1;
    }
    Jbed_nativeCallStateAdr = roots;
    return pairs;
}

int CPL_media_operation(MediaContext *player, int type, unsigned op, int p1, int p2, int p3, JbArray *out)
{
    switch (op) {
    case 18: return get_metadata(player, type, out);
    case 2: remove_temp(player); break;
    case 1: case 3: case 4: case 5: case 6: case 7: case 8: case 9: case 10: case 15:
        break;
    default: return -2;
    }
    int rc = player->empty == 1 ? 0 : android_media_operation(player, type, op, p1, p2, p3);
    if (op == 2) free(player);
    return rc;
}

int Jbed_mediaSendSimpleCustomizedEvent(int event, int value)
{
    return media_queue ? Jbed_upcall_sendSimple(media_queue, -1, event, value) : 0;
}

int Jbed_mediaSendProprietaryStringEvent(int player, const uint16_t *name, int name_length,
                                         const uint16_t *value, int value_length)
{
    return media_queue ? Jbed_upcall_sendComplex(media_queue, -1, 400, player, "ss",
                                                 name, name_length, value, value_length) : 0;
}

int Jbed_mediaSendEvent(int player, int event, int value)
{
    int pair[] = {event, value};
    return media_queue ? Jbed_upcall_sendComplex(media_queue, -1, 400, player, "I", pair, 2) : 0;
}

int JbniS_com_jbed_tina_media_player_NativeCoreStreamPlayer_nWrite(
    void *player, int type, int handle, const JbArray *data, int offset, int count, unsigned chunk)
{
    android_LOGD("jbed_mmapi: NativeCoreStreamPlayer_nWrite(%ld, %ld, %ld, %ld, %ld, %ld)\n",
                 (long)(intptr_t)player, (long)type, (long)handle, (long)(intptr_t)data, (long)offset, (long)count);
    const void *start = (const void *)((uintptr_t)data + offsetof(JbArray, data) + (unsigned)offset);
    int rc = CPL_media_streamWrite(type, handle, start, count, chunk);
    android_LOGD("jbed_mmapi: NativeCoreStreamPlayer_nWrite(%ld, %ld, %ld %ld, %ld) -> %ld\n",
                 (long)(intptr_t)player, (long)type, (long)(intptr_t)data, (long)offset, (long)count, (long)rc);
    return rc;
}

int JbniS_com_jbed_tina_media_player_NativeCoreStreamPlayer_nOpen(
    void *player, int type, int mode, int handle, const JbArray *data, int length)
{
    android_LOGD("jbed_mmapi: NativeCoreStreamPlayer_nOpen(%p, %ld, %ld, %ld, %ld, %ld)\n",
                 player, (long)type, (long)mode, (long)handle, (long)(intptr_t)data, (long)length);
    int rc = CPL_media_openStreamDev(type, mode, handle, data, length);
    android_LOGD("jbed_mmapi: NativeCoreStreamPlayer_nOpen(%ld, %ld, %ld) -> %ld\n",
                 (long)(intptr_t)player, (long)type, (long)mode, (long)rc);
    return rc;
}

MediaContext *JbniS_com_jbed_tina_media_player_NativeCoreStreamPlayer_nPrepare(
    void *player, int type, int mode, const JbArray *data, int length)
{
    android_LOGD("jbed_mmapi: NativeCoreStreamPlayer_nPrepare(%p, %ld, %ld, %ld)\n",
                 player, (long)type, (long)mode, (long)length);
    MediaContext *ctx = CPL_media_prepareDev(type, mode, data, length);
    android_LOGD("jbed_mmapi: NativeCoreStreamPlayer_nPrepare(%ld, %ld, %ld) -> %ld\n",
                 (long)(intptr_t)player, (long)type, (long)mode, (long)(intptr_t)ctx);
    return ctx;
}

int JbniS_com_jbed_tina_media_player_NativePlayer_nGetMediaConstant(int type, int key)
{
    android_LOGD("jbed_mmapi: NativePlayer_nGetMediaConstant(%ld, %ld)\n", (long)type, (long)key);
    int result = CPL_media_getConst(type, key);
    android_LOGD("jbed_mmapi: NativePlayer_nGetMediaConstant(%ld, %ld) -> %ld\n",
                 (long)type, (long)key, (long)result);
    return result;
}

int JbniS_com_jbed_tina_media_player_NativePlayer_nMediaOperation(
    MediaContext *player, int type, unsigned op, int p1, int p2, int p3, JbArray *out)
{
    android_LOGD("jbed_mmapi: NativePlayer_nMediaOperation(%ld, %ld, %ld, %ld, %ld, %ld, %p)\n",
                 (long)(intptr_t)player, (long)type, (long)op, (long)p1, (long)p2, (long)p3, (void *)out);
    int rc = CPL_media_operation(player, type, op, p1, p2, p3, out);
    android_LOGD("jbed_mmapi: NativePlayer_nMediaOperation(%ld, %ld, %ld, %ld, %ld, %p) -> %ld\n",
                 (long)(intptr_t)player, (long)op, (long)p1, (long)p2, (long)p3, (void *)out, (long)rc);
    return rc;
}

int JbniS_com_jbed_tina_media_NativeMediaSystem_nInitializeMedia(void)
{
    android_LOGD("jbed_mmapi: NativeMediaSystem_nInitializeMedia(), mediaInitCalls=%d\n", init_calls);
    if (!init_calls++) {
        android_LOGD("jbed_mmapi: NativeMediaSystem_nInitializeMedia(), calling CPL_init()\n");
        if (!media_queue) media_queue = Jbed_upcall_createQueue(49, 10);
        CPL_media_init();
    }
    android_LOGD("jbed_mmapi: NativeMediaSystem_nInitializeMedia() -> _\n");
    return 0;
}

int JbniS_com_jbed_tina_media_NativeMediaSystem_nFinalizeMedia(void)
{
    android_LOGD("jbed_mmapi: NativeMediaSystem_nFinalizeMedia(), mediaInitCalls=%d\n", init_calls);
    if (!--init_calls) {
        android_LOGD("jbed_mmapi: NativeMediaSystem_nFinalizeMedia(), calling CPL_media_term()\n");
        CPL_media_term();
        if (media_queue) {
            Jbed_upcall_deleteQueue(media_queue);
            media_queue = NULL;
        }
    }
    android_LOGD("jbed_mmapi: NativeMediaSystem_nFinalizeMedia() -> _\n");
    return 0;
}
