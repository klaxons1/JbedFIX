#include "android_jni.h"
#include "android_methods.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

extern int jbed_handle_rootChanged(const char *name, const char *path, int inserted);

void Java_android_jbed_jsr_JbedFileManager_nativeNotifyRootChanged(
    JNIEnv *env, jclass cls, jstring name, jstring path, jboolean inserted)
{
    (void)cls;
    const char *name8 = (*env)->GetStringUTFChars(env, name, NULL);
    const char *path8 = (*env)->GetStringUTFChars(env, path, NULL);
    jbed_handle_rootChanged(name8, path8, inserted);
    (*env)->ReleaseStringUTFChars(env, name, name8);
    (*env)->ReleaseStringUTFChars(env, path, path8);
}

static unsigned packed_length(const jbyte *p)
{
    return (unsigned)(uint8_t)p[0] << 8 | (uint8_t)p[1];
}

int android_fc_getRoots(int *count, char **names, char **paths)
{
    JNIEnv *env = jbed_android_get_env();
    *count = 0;
    *names = *paths = NULL;
    jclass cls = (*env)->FindClass(env, "com/esmertec/android/jbed/jsr/JbedFileManager");
    if (!cls) return -1;
    jmethodID get = (*env)->GetStaticMethodID(env, cls, "getRoots", "()[B");
    jbyteArray array = get ? (*env)->CallStaticObjectMethod(env, cls, get) : NULL;
    (*env)->DeleteLocalRef(env, cls);
    if (!array) return -1;
    int result = -1;
    jsize size = (*env)->GetArrayLength(env, array);
    jbyte *bytes = (*env)->GetByteArrayElements(env, array, NULL);
    if (!bytes) { (*env)->DeleteLocalRef(env, array); return -1; }
    if (size < 5) goto malformed;
    unsigned name_length = packed_length(bytes + 1);
    if (name_length > (unsigned)size - 5) goto malformed;
    const jbyte *path_header = bytes + 3 + name_length;
    unsigned path_length = packed_length(path_header);
    if (path_length > (unsigned)size - 5 - name_length) goto malformed;
    *names = malloc(name_length + 1);
    *paths = malloc(path_length + 1);
    if (!*names || !*paths) {
        free(*names);
        free(*paths);
        *names = *paths = NULL;
        jbed_android_throw(env, "java/lang/OutOfMemoryError", "failed to android_fc_getRoots()");
        goto done;
    }
    memcpy(*names, bytes + 3, name_length);
    memcpy(*paths, path_header + 2, path_length);
    (*names)[name_length] = (*paths)[path_length] = 0;
    *count = (uint8_t)bytes[0];
    result = 0;
    goto done;
malformed:
    jbed_android_throw(env, "java/lang/IllegalArgumentException", "invalid file roots");
done:
    (*env)->ReleaseByteArrayElements(env, array, bytes, JNI_ABORT);
    (*env)->DeleteLocalRef(env, array);
    return result;
}
