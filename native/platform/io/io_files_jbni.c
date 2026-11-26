#include "io_files.h"
#include "jbni_objects.h"
#include "vm_helpers.h"

#include <stddef.h>
#include <stdlib.h>
#include <string.h>

extern int android_LOGD(const char *format, ...);
extern int android_fc_getRoots(int *count, char **names, char **paths);

typedef struct {
    uint32_t header[3];
    int32_t inCount;
    JbRef in, out;
    uint8_t opened;
    int32_t pos, rpos, wpos, length;
    JbRef encoding, mediaType;
    uint8_t isHandleValid;
    int32_t mode, openMode;
    JbRef name;
    int32_t handle;
} FileConnection;

_Static_assert(offsetof(FileConnection, isHandleValid) == 52 && offsetof(FileConnection, handle) == 68,
               "JbedFileConnection layout");

#define FILE_STATIC(name) JbniS_com_jbed_io_JbedFileConnection_##name
#define FILE_INSTANCE(name) JbniV_com_jbed_io_JbedFileConnection_##name
#define HANDLER(name) JbniS_com_jbed_io_FileSystemCallHandler_##name
#define PATH(s) jb_string_chars(s), (s)->length

#define PATH_METHOD(entry, operation) \
    int FILE_STATIC(entry)(const JbString *s) \
    { return operation(PATH(s), 1, vm_current_notifier()); }
PATH_METHOD(nativePermission, CPL_file_permission)
PATH_METHOD(nativeCanWrite, CPL_file_canWrite)
PATH_METHOD(nativeCanRead, CPL_file_canRead)
PATH_METHOD(nativeIsHidden, CPL_file_isHidden)
PATH_METHOD(nativeMkDir, CPL_file_mkdir)
PATH_METHOD(nativeDelete, CPL_file_delete)
PATH_METHOD(nativeExists, CPL_file_exists)
PATH_METHOD(nativeLength, CPL_file_getFileLength)

#define PATH_VALUE_METHOD(entry, operation, type) \
    int FILE_STATIC(entry)(const JbString *s, type value) \
    { return operation(PATH(s), value, 1, vm_current_notifier()); }
PATH_VALUE_METHOD(nativeSetLastModified, CPL_file_setLastModified, int64_t)
PATH_VALUE_METHOD(nativeValidFilename, CPL_file_validFilename, int)
PATH_VALUE_METHOD(nativeSetWritable, CPL_file_setWritable, int)
PATH_VALUE_METHOD(nativeSetReadable, CPL_file_setReadable, int)
PATH_VALUE_METHOD(nativeSetHidden, CPL_file_setHidden, int)

#define PATH_LONG_METHOD(entry, operation) \
    void FILE_STATIC(entry)(const JbString *s, JbArray *out) \
    { \
        int64_t value = operation(PATH(s), 1, vm_current_notifier()); \
        memcpy(out->data, &value, sizeof(value)); \
    }
PATH_LONG_METHOD(nativeLastModified, CPL_file_lastModified)
PATH_LONG_METHOD(nativeAvailableSize, CPL_file_availableSize64)
PATH_LONG_METHOD(nativeTotalSize, CPL_file_totalSize64)

void FILE_STATIC(nativeDirectorySize)(const JbString *s, int recursive, JbArray *out)
{
    int64_t size = CPL_file_directorySize64(PATH(s), recursive, 1, vm_current_notifier());
    memcpy(out->data, &size, sizeof(size));
}

int FILE_STATIC(nativeFlush)(int fd) { return CPL_file_flush(fd, vm_current_notifier()); }
int FILE_STATIC(nativeSetPosition)(int fd, int offset) { return CPL_file_setPosition(fd, offset, vm_current_notifier()); }
int FILE_STATIC(nativeTruncate)(int fd, int size) { return CPL_file_truncate(fd, size, vm_current_notifier()); }
int FILE_STATIC(nativeClose)(int fd) { return CPL_file_close(fd, vm_current_notifier()); }

void FILE_INSTANCE(finalize)(FileConnection *self)
{
    if (self->isHandleValid) {
        android_LOGD("WARNING: file handle %d not closed properly\n", self->handle);
        CPL_file_close(self->handle, NULL);
    }
}

int FILE_INSTANCE(nativeOpen)(FileConnection *self, int mode)
{
    void **saved = Jbed_nativeCallStateAdr;
    *Jbed_nativeCallStateAdr++ = &self;
    const JbString *s = (const JbString *)(uintptr_t)self->name;
    int rc = CPL_file_open(PATH(s), mode, 1, &self->handle, vm_current_notifier());
    if (!rc) self->isHandleValid = 1;
    Jbed_nativeCallStateAdr = saved;
    return rc;
}

int FILE_STATIC(nativeWrite)(int fd, const JbArray *array, int offset, int length)
{
    return CPL_file_write(fd, (const uint8_t *)array->data + offset, length, vm_current_notifier());
}

int FILE_STATIC(nativeRead)(int fd, JbArray *array, int offset, int length)
{
    return CPL_file_read(fd, (uint8_t *)array->data + offset, length, vm_current_notifier());
}

int FILE_STATIC(nativeRename)(const JbString *from, const JbString *to)
{
    return CPL_file_rename(PATH(from), PATH(to), 1, vm_current_notifier());
}

int FILE_STATIC(nativeListOpen)(const JbString *s, JbArray *state)
{
    DIR *dir;
    int rc = CPL_file_listOpen(PATH(s), 1, &dir, (int32_t *)&state->data[1], vm_current_notifier());
    if (!rc) state->data[0] = jb_ref(dir);
    return rc;
}

int FILE_STATIC(nativeListNextEntry)(const JbString *s, JbArray *state, JbArray *out)
{
    DIR *dir = (DIR *)(uintptr_t)state->data[0];
    return CPL_file_listNextEntry(PATH(s), (uint16_t *)out->data, 2 * out->length,
                                  &dir, (int32_t *)&state->data[1], vm_current_notifier());
}

int FILE_STATIC(nativeListClose)(JbArray *state)
{
    return CPL_file_listClose((DIR *)(uintptr_t)state->data[0], state->data[1], vm_current_notifier());
}

JbUpcallQueue *jbed_fc_upcallQueue;
static uint32_t queue_users;

void Jbed_file_events_assertCleanedUp(void) {}
void setUpExistingRoots(void) {}
void destoryExistingRoots(void) {}

int Jbed_file_events_notifyRootChanged(int inserted, const char *name, const char *path)
{
    int name_length = Jbni_convertUtf8ToUcs2(name, -1, NULL, 0);
    uint16_t *name16 = malloc((uint32_t)name_length * 2u);
    if (!name16) return -1;
    int path_length = Jbni_convertUtf8ToUcs2(path, -1, NULL, 0);
    uint16_t *path16 = malloc((uint32_t)path_length * 2u);
    if (!path16) {
        free(name16);
        return -1;
    }
    Jbni_convertUtf8ToUcs2(name, -1, name16, 2 * name_length);
    Jbni_convertUtf8ToUcs2(path, -1, path16, 2 * path_length);
    int rc = Jbed_upcall_sendComplex(jbed_fc_upcallQueue, -1, JBED_UPCALL_FILE_SYSTEM, !inserted, "ss",
                                     name16, name_length, path16, path_length);
    free(path16);
    free(name16);
    return rc;
}

int jbed_handle_rootChanged(const char *name, const char *path, int inserted)
{
    if (jbed_fc_upcallQueue) Jbed_file_events_notifyRootChanged(inserted, name, path);
    if (inserted) return android_LOGD("ALWAYS: jbed_handle_rootChanged(): card insert  path=%s\n", path);
    return android_LOGD("ALWAYS: jbed_handle_rootChanged(): card removed path=%s\n", path);
}

int Jbed_file_events_closeQueue(void)
{
    if (!--queue_users && jbed_fc_upcallQueue) {
        Jbed_upcall_deleteQueue(jbed_fc_upcallQueue);
        jbed_fc_upcallQueue = NULL;
    }
    return 0;
}

int Jbed_file_events_openQueue(int channel, int flags)
{
    if (!queue_users && !jbed_fc_upcallQueue)
        jbed_fc_upcallQueue = Jbed_upcall_createQueue(channel, flags);
    if (!jbed_fc_upcallQueue) return -1;
    ++queue_users;
    return 0;
}

static JbArray *root_strings(const char *const *strings, int count)
{
    JbArray *array = Jbni_newObjectArray(count);
    void **saved = Jbed_nativeCallStateAdr;
    *Jbed_nativeCallStateAdr++ = &array;
    if (array) {
        for (int i = 0; i < count; ++i) {
            JbString *string = Jbni_intern_newString(strings[i]);
            if (!string) {
                array = NULL;
                break;
            }
            array->data[i] = jb_ref(string);
        }
    }
    Jbed_nativeCallStateAdr = saved;
    return array;
}

int Jbed_file_events_initialRootsUtf8(JbArray *out, const char *const *names,
                                     const char *const *paths, int count)
{
    if (count == -1) {
        count = 0;
        while (names[count]) ++count;
    }
    void **saved = Jbed_nativeCallStateAdr;
    *Jbed_nativeCallStateAdr++ = &out;
    JbArray *root_names = root_strings(names, count);
    JbArray *root_paths = NULL;
    *Jbed_nativeCallStateAdr++ = &root_names;
    *Jbed_nativeCallStateAdr++ = &root_paths;
    int rc = -1;
    if (root_names && (!paths || (root_paths = root_strings(paths, count)))) {
        out->data[0] = jb_ref(root_names);
        out->data[1] = jb_ref(root_paths);
        rc = 0;
    }
    Jbed_nativeCallStateAdr = saved;
    return rc;
}

int HANDLER(nativeFsListenerDown)(void) { return Jbed_file_events_closeQueue(); }

int HANDLER(nativeFsListenerUp)(JbArray *out, int isolate)
{
    (void)isolate;
    int rc = Jbed_file_events_openQueue(1031, 0);
    if (rc) return rc;
    int count;
    char *name_block = NULL, *path_block = NULL;
    rc = android_fc_getRoots(&count, &name_block, &path_block);
    if (!count) return 0;
    if (rc < 0) return -1;
    const char **names = malloc((size_t)count * sizeof(*names));
    if (!names) return -1;
    const char **paths = malloc((size_t)count * sizeof(*paths));
    if (!paths) {
        free(names);
        return -1;
    }
    char *name = name_block, *path = path_block;
    for (int i = 0; i < count; ++i) {
        names[i] = name;
        paths[i] = path;
        name += strlen(name) + 1;
        path += strlen(path) + 1;
    }
    rc = Jbed_file_events_initialRootsUtf8(out, names, paths, count);
    free(names);
    free(paths);
    free(name_block);
    free(path_block);
    return rc;
}
