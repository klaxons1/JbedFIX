#include "android_jni.h"
#include "android_methods.h"
#include "media.h"

#include <stdlib.h>
#include <string.h>

void Java_android_jbed_jsr_JbedMediaManager_nativeInitialization(JNIEnv *env, jclass clazz)
{
    gCachedFields.media = (*env)->NewGlobalRef(env, clazz);
    gCachedFields.create_player = (*env)->GetStaticMethodID(env, clazz, "createPlayer", "(ILjava/lang/String;)I");
    gCachedFields.open_stream = (*env)->GetStaticMethodID(env, clazz, "openStreamDev", "(II)I");
    gCachedFields.media_operation = (*env)->GetStaticMethodID(env, clazz, "operation", "(IIIIII)I");
}

int android_media_createPlayer(MediaContext *player, const char *source)
{
    JNIEnv *env = jbed_android_get_env();
    jstring locator = (*env)->NewStringUTF(env, source);
    int result = (*env)->CallStaticIntMethod(env, gCachedFields.media, gCachedFields.create_player,
                                            (jint)(uintptr_t)player, locator);
    (*env)->DeleteLocalRef(env, locator);
    return result;
}

int android_media_openStreamDev(int handle, int type)
{
    JNIEnv *env = jbed_android_get_env();
    return (*env)->CallStaticIntMethod(env, gCachedFields.media, gCachedFields.open_stream, handle, type);
}

int android_media_operation(MediaContext *player, int type, unsigned op, int a, int b, int c)
{
    JNIEnv *env = jbed_android_get_env();
    return (*env)->CallStaticIntMethod(env, gCachedFields.media, gCachedFields.media_operation,
                                       (jint)(uintptr_t)player, type, (jint)op, a, b, c);
}

int android_media_getSnapshot(MediaContext *player, const char *format)
{
    JNIEnv *env = jbed_android_get_env();
    jstring arg = (*env)->NewStringUTF(env, format);
    jmethodID snapshot = (*env)->GetStaticMethodID(env, gCachedFields.media, "getSnapshot", "(ILjava/lang/String;)I");
    int result = (*env)->CallStaticIntMethod(env, gCachedFields.media, snapshot, (jint)(uintptr_t)player, arg);
    (*env)->DeleteLocalRef(env, arg);
    return result;
}

int android_media_getMetaData(MediaContext *player, int *pairs, char **strings)
{
    JNIEnv *env = jbed_android_get_env();
    jmethodID get = (*env)->GetStaticMethodID(env, gCachedFields.media, "getMetaData", "(I)[B");
    jbyteArray a = (*env)->CallStaticObjectMethod(env, gCachedFields.media, get, (jint)(uintptr_t)player);
    *pairs = 0;
    *strings = NULL;
    if (!a || (*env)->ExceptionCheck(env)) return -1;
    int length = (*env)->GetArrayLength(env, a);
    if (length < 1) { (*env)->DeleteLocalRef(env, a); return -1; }
    jbyte count;
    (*env)->GetByteArrayRegion(env, a, 0, 1, &count);
    *pairs = (uint8_t)count;
    *strings = malloc((size_t)length);
    if (*strings) {
        (*env)->GetByteArrayRegion(env, a, 1, length - 1, (jbyte *)*strings);
        (*strings)[length - 1] = 0;
    }
    (*env)->DeleteLocalRef(env, a);
    if (!*strings) {
        jbed_android_throw(env, "java/lang/OutOfMemoryError", "failed to android_media_getMetaData()");
        return -1;
    }
    return 0;
}

void Java_android_jbed_jsr_JbedMediaManager_nativeNotifyMediaCreatePlayer(JNIEnv *env, jclass clazz, jint handle)
{
    (void)env; (void)clazz;
    jbed_handle_media_createPlayer((MediaContext *)(uintptr_t)(uint32_t)handle);
}

void Java_android_jbed_jsr_JbedMediaManager_nativeNotifyMediaFinishPlay(JNIEnv *env, jclass clazz, jint player)
{
    (void)env; (void)clazz;
    jbed_handle_media_finishPlay(player);
}
