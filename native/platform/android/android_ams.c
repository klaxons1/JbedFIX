#include "ams.h"
#include "android_jni.h"

#include <stdlib.h>
#include <string.h>

static const char connection_class[] = "com/esmertec/android/jbed/ams/AmsConnection";

void android_handle_ams_event(int event, int result, const void *data, int length)
{
    JNIEnv *env = jbed_android_get_env();
    jclass clazz = (*env)->FindClass(env, connection_class);
    jmethodID post = (*env)->GetStaticMethodID(env, clazz, "handleEventEx", "(II[B)V");
    jbyteArray payload = NULL;
    if (length > 0) {
        payload = (*env)->NewByteArray(env, length);
        if (payload) (*env)->SetByteArrayRegion(env, payload, 0, length, data);
    }
    if (!(*env)->ExceptionCheck(env))
        (*env)->CallStaticVoidMethod(env, clazz, post, event, result, payload);
    (*env)->DeleteLocalRef(env, payload);
    (*env)->DeleteLocalRef(env, clazz);
}

int jbed_ams_fetchAmsEvent(int *event, int *result, void **data, size_t *length)
{
    JNIEnv *env = jbed_android_get_env();
    if ((*env)->PushLocalFrame(env, 4) < 0) return -1;
    jclass connection = (*env)->FindClass(env, connection_class);
    jmethodID fetch = (*env)->GetStaticMethodID(env, connection, "fetchEvent",
                                                "()Lcom/esmertec/android/jbed/ams/AmsEvent;");
    jobject e = (*env)->CallStaticObjectMethod(env, connection, fetch);
    if (!e) {
        android_LOGD("WARNING: jbed_ams_fetchAmsEvent have nothing to fetch\n");
        (*env)->PopLocalFrame(env, NULL);
        return -1;
    }

    jclass clazz = (*env)->GetObjectClass(env, e);
    jfieldID id = (*env)->GetFieldID(env, clazz, "mId", "I");
    jfieldID status = (*env)->GetFieldID(env, clazz, "mResult", "I");
    jfieldID payload = (*env)->GetFieldID(env, clazz, "mData", "[B");
    *event = (*env)->GetIntField(env, e, id);
    *result = (*env)->GetIntField(env, e, status);
    jbyteArray a = (*env)->GetObjectField(env, e, payload);
    jsize size = a ? (*env)->GetArrayLength(env, a) : 0;
    *length = (size_t)size;
    *data = NULL;
    if (size > 0) {
        *data = malloc((size_t)size + 1);
        if (!*data) {
            jbed_android_throw(env, "java/lang/OutOfMemoryError", "failed to copy AMS event");
            (*env)->PopLocalFrame(env, NULL);
            return -1;
        }
        (*env)->GetByteArrayRegion(env, a, 0, size, *data);
        ((char *)*data)[*length] = 0;
    }
    (*env)->PopLocalFrame(env, NULL);
    return 0;
}
