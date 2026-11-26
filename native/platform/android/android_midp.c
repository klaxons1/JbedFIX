#include "android_jni.h"
#include "android_methods.h"
#include "ams.h"
#include "vm_async.h"
#include "vm_os.h"

#include <stdlib.h>
#include <string.h>

extern float xScale, yScale;

void Java_android_jbed_jsr_JbedLcduiManager_nativeInitialization(JNIEnv *env, jclass clazz)
{
    gCachedFields.lcdui = (*env)->NewGlobalRef(env, clazz);
    gCachedFields.repaint = (*env)->GetStaticMethodID(env, clazz, "repaint", "(IIIIIIFF)V");
}

void android_lcdui_showInputDialog(const jchar *chars, int n, int a, int b, int c)
{
    JNIEnv *env = jbed_android_get_env();
    jmethodID method = (*env)->GetStaticMethodID(env, gCachedFields.lcdui, "showInputDialog", "(Ljava/lang/String;III)V");
    jstring text = (*env)->NewString(env, chars, n);
    (*env)->CallStaticVoidMethod(env, gCachedFields.lcdui, method, text, a, b, c);
    (*env)->DeleteLocalRef(env, text);
}

void android_lcdui_repaint(int x, int y, int width, int height, int a, int b)
{
    JNIEnv *env = jbed_android_get_env();
    (*env)->CallStaticVoidMethod(env, gCachedFields.lcdui, gCachedFields.repaint, x, y, width, height, a, b, (double)xScale, (double)yScale);
}

void android_soft_button_changed(const jchar *left, int left_len, const jchar *right, int right_len)
{
    JNIEnv *env = jbed_android_get_env();
    jstring l = left ? (*env)->NewString(env, left, left_len) : NULL;
    jstring r = right ? (*env)->NewString(env, right, right_len) : NULL;
    jmethodID id = (*env)->GetStaticMethodID(env, gCachedFields.lcdui, "onSoftButtonChanged", "(Ljava/lang/String;Ljava/lang/String;)V");
    (*env)->CallStaticVoidMethod(env, gCachedFields.lcdui, id, l, r);
    (*env)->DeleteLocalRef(env, l);
    (*env)->DeleteLocalRef(env, r);
}

void Java_android_jbed_jsr_JbedLcduiManager_nativeMvmSwitchMideltList(JNIEnv *env, jobject self)
{
    (void)env; (void)self;
    CPL_conc_setAppUserRequest(4);
}

void Java_android_jbed_jsr_JbedMidpManager_nativeInitialization(JNIEnv *env, jclass clazz)
{
    gCachedFields.midp = (*env)->NewGlobalRef(env, clazz);
}

void Java_android_jbed_jsr_JbedMidpManager_nativeSetJbedProperty(JNIEnv *env, jobject self, jstring key, jstring value)
{
    (void)self;
    const char *name = (*env)->GetStringUTFChars(env, key, NULL);
    if (!name) return;
    const char *text = (*env)->GetStringUTFChars(env, value, NULL);
    if (text) {
        Jbed_setProperty(name, text);
        (*env)->ReleaseStringUTFChars(env, value, text);
    }
    (*env)->ReleaseStringUTFChars(env, key, name);
}

int android_midp_setVibrate(int value)
{
    JNIEnv *env = jbed_android_get_env();
    jmethodID id = (*env)->GetStaticMethodID(env, gCachedFields.midp, "setVibrate", "(Z)V");
    (*env)->CallStaticVoidMethod(env, gCachedFields.midp, id, value);
    return 0;
}

int android_midp_platformRequest(const jchar *url, int length)
{
    JNIEnv *env = jbed_android_get_env();
    jmethodID id = (*env)->GetStaticMethodID(env, gCachedFields.midp, "platformRequest", "(Ljava/lang/String;)I");
    jstring text = url ? (*env)->NewString(env, url, length) : NULL;
    int result = (*env)->CallStaticIntMethod(env, gCachedFields.midp, id, text);
    (*env)->DeleteLocalRef(env, text);
    return result;
}

static int copy_string(JNIEnv *env, jstring s, char **out, const char *failure)
{
    *out = NULL;
    if (!s) return -1;
    const char *text = (*env)->GetStringUTFChars(env, s, NULL);
    if (text) {
        *out = malloc(strlen(text) + 1);
        if (*out) strcpy(*out, text);
        (*env)->ReleaseStringUTFChars(env, s, text);
    }
    (*env)->DeleteLocalRef(env, s);
    if (!*out) {
        if (!(*env)->ExceptionCheck(env))
            jbed_android_throw(env, "java/lang/OutOfMemoryError", failure);
        return -1;
    }
    return 0;
}

int android_midp_getCurrentLanguage(char **out)
{
    JNIEnv *env = jbed_android_get_env();
    jmethodID id = (*env)->GetStaticMethodID(env, gCachedFields.midp, "getLocaleString", "()Ljava/lang/String;");
    jstring s = (*env)->CallStaticObjectMethod(env, gCachedFields.midp, id);
    return copy_string(env, s, out, "failed to getCurrentLanguage");
}

int android_midp_getString(int lang, int key, char **out)
{
    JNIEnv *env = jbed_android_get_env();
    jmethodID id = (*env)->GetStaticMethodID(env, gCachedFields.midp, "getString", "(II)Ljava/lang/String;");
    jstring s = (*env)->CallStaticObjectMethod(env, gCachedFields.midp, id, lang, key);
    return copy_string(env, s, out, "failed to getString");
}

void Java_android_jbed_jsr_JbedLapiManager_nativeInitialization(JNIEnv *env, jclass clazz, jstring dir)
{
    const char *path = (*env)->GetStringUTFChars(env, dir, NULL);
    if (!path) return;
    Jbed_setProperty("LandmarkStore.dir", path);
    (*env)->ReleaseStringUTFChars(env, dir, path);
    gCachedFields.lapi = (*env)->NewGlobalRef(env, clazz);
}

void Java_android_jbed_jsr_JbedLapiManager_notifyNative(JNIEnv *env, jclass clazz, jint address, jint result)
{
    (void)env; (void)clazz;
    VmNotifier *notifier = (VmNotifier *)(uintptr_t)(uint32_t)address;
    *(int *)ASYNC_getStateFromNotifier(notifier) = result;
    ASYNC_notify(notifier);
}
