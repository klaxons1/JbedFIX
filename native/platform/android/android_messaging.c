#include "android_jni.h"
#include "android_methods.h"
#include "push.h"
#include "vm_os.h"

#include <string.h>

void Java_android_jbed_jsr_JbedDrmManager_nativeInitialization(JNIEnv *env, jclass cls, jstring directory)
{
    const char *path = (*env)->GetStringUTFChars(env, directory, NULL);
    if (path) {
        Jbed_setProperty("Ams.pending-install-dir", path);
        (*env)->ReleaseStringUTFChars(env, directory, path);
    }
    gCachedFields.drm = (*env)->NewGlobalRef(env, cls);
}

void android_drm_getEnv(void) {}

static jint drm_int(const char *name, const char *signature, jint argument)
{
    JNIEnv *env = jbed_android_get_env();
    jmethodID method = (*env)->GetStaticMethodID(env, gCachedFields.drm, name, signature);
    return method ? (*env)->CallStaticIntMethod(env, gCachedFields.drm, method, argument) : -1;
}

static jint drm_int_pair(const char *name, jint first, jint second)
{
    JNIEnv *env = jbed_android_get_env();
    jmethodID method = (*env)->GetStaticMethodID(env, gCachedFields.drm, name, "(II)I");
    return method ? (*env)->CallStaticIntMethod(env, gCachedFields.drm, method, first, second) : -1;
}

jint android_drm_getContentLength(jint content) { return drm_int("getContentLength", "(I)I", content); }
jint android_drm_closeStream(jint stream) { return drm_int("closeStream", "(I)I", stream); }
jint android_drm_canRequestRights(jint content) { return drm_int("canRequestRights", "(I)I", content); }
jint android_drm_requestRights(jint content) { return drm_int("requestRights", "(I)I", content); }
jint android_drm_isForwardLocked(jint content) { return drm_int("isForwardLocked", "(I)I", content); }
jint android_drm_closeDrmContent(jint content) { return drm_int("closeDrmContent", "(I)I", content); }

jstring android_drm_getContentType(jint content)
{
    JNIEnv *env = jbed_android_get_env();
    jmethodID method = (*env)->GetStaticMethodID(env, gCachedFields.drm, "getContentType", "(I)Ljava/lang/String;");
    return method ? (*env)->CallStaticObjectMethod(env, gCachedFields.drm, method, content) : NULL;
}

jint android_drm_openStream(jint content) { return drm_int("openStream", "(I)I", content); }

jint android_drm_seekStream(jint stream, jint offset) { return drm_int_pair("seekStream", stream, offset); }
jint android_drm_hasRights(jint content, jint permission) { return drm_int_pair("hasRights", content, permission); }
jint android_drm_consumeRights(jint content, jint permission)
{
    return drm_int_pair("consumeRights", content, permission);
}

jint android_drm_getConstraint(jint content, jint permission, jlong *out, jint count)
{
    if (count <= 0 || !out) return -1;
    JNIEnv *env = jbed_android_get_env();
    jmethodID method = (*env)->GetStaticMethodID(env, gCachedFields.drm, "getConstraint", "(II)[J");
    if (!method) return -1;
    jlongArray array = (*env)->CallStaticObjectMethod(env, gCachedFields.drm, method, content, permission);
    if (!array) return -1;
    int result = -1;
    if (count == (*env)->GetArrayLength(env, array)) {
        (*env)->GetLongArrayRegion(env, array, 0, count, out);
        if (!(*env)->ExceptionCheck(env)) result = 0;
    }
    (*env)->DeleteLocalRef(env, array);
    return result;
}

jint android_drm_readStream(jint stream, void *out, jint capacity, jint *length)
{
    if (length) *length = 0;
    if (capacity <= 0 || !out) return -1;
    JNIEnv *env = jbed_android_get_env();
    jmethodID method = (*env)->GetStaticMethodID(env, gCachedFields.drm, "readStream", "(II)[B");
    if (!method) return -1;
    jbyteArray array = (*env)->CallStaticObjectMethod(env, gCachedFields.drm, method, stream, capacity);
    if (!array) return -1;
    jint n = (*env)->GetArrayLength(env, array);
    int result = -1;
    if (n <= capacity) {
        (*env)->GetByteArrayRegion(env, array, 0, n, out);
        if (!(*env)->ExceptionCheck(env)) {
            if (length) *length = n;
            result = 0;
        }
    }
    (*env)->DeleteLocalRef(env, array);
    return result;
}

static jstring drm_path(JNIEnv *env, const jchar *path, jsize length)
{
    return path ? (*env)->NewString(env, path, length) : NULL;
}

static jint drm_path_call(const char *name, const jchar *path, jsize length)
{
    JNIEnv *env = jbed_android_get_env();
    jstring s = drm_path(env, path, length);
    jmethodID method = (*env)->GetStaticMethodID(env, gCachedFields.drm, name, "(Ljava/lang/String;)I");
    int result = method ? (*env)->CallStaticIntMethod(env, gCachedFields.drm, method, s) : -1;
    (*env)->DeleteLocalRef(env, s);
    return result;
}

jint android_drm_isDrmContent(const jchar *path, jsize length)
{
    return drm_path_call("isDrmContent", path, length);
}

jint android_drm_getDrmMethodType(const jchar *path, jsize length)
{
    return drm_path_call("getDrmMethodType", path, length);
}

jint android_drm_openDrmContent(const jchar *path, jsize length)
{
    return drm_path_call("openDrmContent", path, length);
}

jint android_drm_deleteContent(const jchar *path, jsize length)
{
    return drm_path_call("deleteContent", path, length);
}

jint android_drm_installContent(const jchar *path, jsize length, jint type)
{
    JNIEnv *env = jbed_android_get_env();
    jstring s = drm_path(env, path, length);
    jmethodID method = (*env)->GetStaticMethodID(env, gCachedFields.drm, "installContent", "(Ljava/lang/String;I)I");
    int result = method ? (*env)->CallStaticIntMethod(env, gCachedFields.drm, method, s, type) : -1;
    (*env)->DeleteLocalRef(env, s);
    return result;
}

jint android_drm_renameDrmContent(const jchar *path, jsize length, const jchar *to, jsize to_length)
{
    JNIEnv *env = jbed_android_get_env();
    jstring from_path = drm_path(env, path, length);
    jstring to_path = drm_path(env, to, to_length);
    jmethodID method = (*env)->GetStaticMethodID(env, gCachedFields.drm, "renameContent",
                                                "(Ljava/lang/String;Ljava/lang/String;)I");
    int result = method ? (*env)->CallStaticIntMethod(env, gCachedFields.drm, method, from_path, to_path) : -1;
    (*env)->DeleteLocalRef(env, from_path);
    (*env)->DeleteLocalRef(env, to_path);
    return result;
}

static jint sms_port_call(const char *name, jint port)
{
    JNIEnv *env = jbed_android_get_env();
    jclass cls = (*env)->FindClass(env, "com/esmertec/android/jbed/jsr/JbedSmsManager");
    if (!cls) return -1;
    jmethodID method = (*env)->GetStaticMethodID(env, cls, name, "(I)I");
    int result = method ? (*env)->CallStaticIntMethod(env, cls, method, port) : -1;
    (*env)->DeleteLocalRef(env, cls);
    return result;
}

jint android_sms_register(jint port) { return sms_port_call("register", port); }
jint android_sms_deregister(jint port) { return sms_port_call("deregister", port); }

jint android_sms_send(struct VmNotifier *notifier, const jchar *address, jsize address_length,
                      jint port, const void *payload, jint length, jint encoding)
{
    JNIEnv *env = jbed_android_get_env();
    if ((*env)->PushLocalFrame(env, 3) < 0) return -1;
    int result = -1;
    jclass cls = (*env)->FindClass(env, "com/esmertec/android/jbed/jsr/JbedSmsManager");
    if (!cls) goto done;
    jmethodID method = (*env)->GetStaticMethodID(env, cls, "sendSms", "(ILjava/lang/String;I[BI)I");
    if (!method) goto done;
    jstring addr = (*env)->NewString(env, address, address_length);
    if (!addr) goto done;
    jbyteArray array = (*env)->NewByteArray(env, length);
    if (!array) goto done;
    (*env)->SetByteArrayRegion(env, array, 0, length, payload);
    if (!(*env)->ExceptionCheck(env))
        result = (*env)->CallStaticIntMethod(env, cls, method, (jint)(uintptr_t)notifier, addr, port, array, encoding);
done:
    (*env)->PopLocalFrame(env, NULL);
    return result;
}

void Java_android_jbed_jsr_JbedSmsManager_nativeNotifySmsSendResult(JNIEnv *env, jclass cls, jint token, jboolean ok)
{
    (void)env;
    (void)cls;
    jbed_handle_sms_sendresult((struct VmNotifier *)(uintptr_t)(uint32_t)token, ok);
}

void Java_android_jbed_jsr_JbedSmsManager_nativeNotifyNewSms(JNIEnv *env, jclass cls, jstring sender,
    jint from_port, jint to_port, jint encoding, jlong timestamp, jbyteArray payload)
{
    (void)cls;
    if (!payload || !sender) {
        android_LOGD("ERROR: data is invalid\n");
        return;
    }
    jsize address_length = (*env)->GetStringUTFLength(env, sender);
    const char *address = (*env)->GetStringUTFChars(env, sender, NULL);
    if (!address) return;
    uint16_t length = (uint16_t)(*env)->GetArrayLength(env, payload);
    jbyte *bytes = (*env)->GetByteArrayElements(env, payload, NULL);
    int status = -1;
    if (bytes) status = jbed_handle_newSms(address, (size_t)address_length, (uint16_t)from_port,
                                          to_port, (uint8_t)encoding, timestamp, bytes, length);
    (*env)->ReleaseStringUTFChars(env, sender, address);
    if (bytes) (*env)->ReleaseByteArrayElements(env, payload, bytes, 0);
    if (status < 0) {
        const char *message = "ERROR: failed to put the new message to jbed vm";
        jbed_android_throw(env, "java/lang/IllegalArgumentException", message);
        android_LOGD("%s", message);
    }
}

void Java_android_jbed_jsr_JbedMmsManager_nativeNotifyNewMms(JNIEnv *env, jclass cls, jboolean push)
{
    (void)env;
    (void)cls;
    (void)push;
}

void Java_android_jbed_jsr_JbedMmsManager_nativeNotifyMmsSendResult(JNIEnv *env, jclass cls, jint token, jboolean ok)
{
    (void)env;
    (void)cls;
    (void)token;
    (void)ok;
}
