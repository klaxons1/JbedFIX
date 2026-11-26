#include "android_jni.h"

#include <android/log.h>
#include <stdarg.h>
#include <stdio.h>

struct AndroidCachedFields gCachedFields;

static JavaVM *java_vm;
jobject jbed_android_engine;

jint jbed_android_throw(JNIEnv *env, const char *name, const char *message)
{
    jclass exception = (*env)->FindClass(env, name);
    if (!exception) return JNI_ERR;
    jint result = (*env)->ThrowNew(env, exception, message);
    (*env)->DeleteLocalRef(env, exception);
    return result;
}

int jbed_android_initialize(JNIEnv *env)
{
    return (*env)->GetJavaVM(env, &java_vm) == JNI_OK && jbed_android_graphics_initialize(env);
}

JNIEnv *jbed_android_get_env(void)
{
    JNIEnv *env = NULL;
    if (!java_vm || (*java_vm)->GetEnv(java_vm, (void **)&env, JNI_VERSION_1_6) != JNI_OK)
        __android_log_assert("attached JNI thread", "jbed.native",
                              "Android platform call requires an attached thread");
    return env;
}

int jbed_android_attach_thread(void)
{
    if (!java_vm) return 1;
    JNIEnv *env;
    return (*java_vm)->AttachCurrentThread(java_vm, &env, NULL) == JNI_OK;
}

void jbed_android_detach_thread(void)
{
    if (java_vm) (*java_vm)->DetachCurrentThread(java_vm);
}

int android_LOGD(const char *format, ...)
{
    char text[512];
    va_list ap;
    va_start(ap, format);
    vsnprintf(text, sizeof(text), format, ap);
    va_end(ap);
    return __android_log_print(ANDROID_LOG_DEBUG, "jbed.native", "%s", text);
}
