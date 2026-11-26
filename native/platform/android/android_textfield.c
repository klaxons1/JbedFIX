#include "android_jni.h"
#include "android_methods.h"
#include "io_textfield.h"

#include <stddef.h>

static jclass text_field_class(JNIEnv *env)
{
    return (*env)->FindClass(env, "com/esmertec/android/jbed/nativeui/JbedTextFieldConnection");
}

int android_textfield_create(int inline_field)
{
    JNIEnv *env = jbed_android_get_env();
    jclass cls = text_field_class(env);
    jmethodID method = (*env)->GetStaticMethodID(env, cls, "create", "(I)I");
    int result = (*env)->CallStaticIntMethod(env, cls, method, inline_field ? 0 : JBED_TEXTBOX_MASK);
    (*env)->DeleteLocalRef(env, cls);
    return result;
}

void android_textfield_dispose(int id)
{
    JNIEnv *env = jbed_android_get_env();
    jclass cls = text_field_class(env);
    jmethodID method = (*env)->GetStaticMethodID(env, cls, "dispose", "(I)V");
    (*env)->CallStaticVoidMethod(env, cls, method, id);
    (*env)->DeleteLocalRef(env, cls);
}

void android_textfield_calculateSizeHints(int id, int width_hint, int height_hint,
                                         int *min_w, int *min_h, int *pref_w, int *pref_h)
{
    JNIEnv *env = jbed_android_get_env();
    jclass cls = text_field_class(env);
    jintArray result = (*env)->NewIntArray(env, 4);
    jmethodID method = (*env)->GetStaticMethodID(env, cls, "calculateSizeHints", "(III[I)V");
    (*env)->CallStaticVoidMethod(env, cls, method, id, width_hint, height_hint, result);
    jint values[4] = {0};
    if (!(*env)->ExceptionCheck(env)) (*env)->GetIntArrayRegion(env, result, 0, 4, values);
    *min_w = values[0];
    *min_h = values[1];
    *pref_w = values[2];
    *pref_h = values[3];
    (*env)->DeleteLocalRef(env, result);
    (*env)->DeleteLocalRef(env, cls);
}

void android_textfield_setPosition(int id, int x, int y, int width, int height)
{
    JNIEnv *env = jbed_android_get_env();
    jclass cls = text_field_class(env);
    jmethodID method = (*env)->GetStaticMethodID(env, cls, "setPosition", "(IIIIIZI)V");
    int box = (id & JBED_TEXTBOX_MASK) != 0;
    (*env)->CallStaticVoidMethod(env, cls, method, id, x, y, width, height, box, box ? 0 : 20);
    (*env)->DeleteLocalRef(env, cls);
}

void android_textfield_setClip(int id, int x, int y, int width, int height)
{
    JNIEnv *env = jbed_android_get_env();
    jclass cls = text_field_class(env);
    jmethodID method = (*env)->GetStaticMethodID(env, cls, "setClip", "(IIIII)V");
    (*env)->CallStaticVoidMethod(env, cls, method, id, x, y, width, height);
    (*env)->DeleteLocalRef(env, cls);
}

static void set_int(int id, const char *name, const char *signature, int value)
{
    JNIEnv *env = jbed_android_get_env();
    jclass cls = text_field_class(env);
    jmethodID method = (*env)->GetStaticMethodID(env, cls, name, signature);
    (*env)->CallStaticVoidMethod(env, cls, method, id, value);
    (*env)->DeleteLocalRef(env, cls);
}

void android_textfield_setFocus(int id, int focus) { set_int(id, "setFocus", "(IZ)V", focus); }
void android_textfield_setConstrains(int id, int constraints) { set_int(id, "setConstraints", "(II)V", constraints); }
void android_textfield_setMaxSize(int id, int size) { set_int(id, "setMaxSize", "(II)V", size); }

int android_textfield_getCaretPosition(int id)
{
    JNIEnv *env = jbed_android_get_env();
    jclass cls = text_field_class(env);
    jmethodID method = (*env)->GetStaticMethodID(env, cls, "getCaretPosition", "(I)I");
    int result = (*env)->CallStaticIntMethod(env, cls, method, id);
    (*env)->DeleteLocalRef(env, cls);
    return result;
}

void android_textfield_setText(int id, const uint16_t *text, int length)
{
    JNIEnv *env = jbed_android_get_env();
    jclass cls = text_field_class(env);
    jstring value = text ? (*env)->NewString(env, text, length) : NULL;
    jmethodID method = (*env)->GetStaticMethodID(env, cls, "setText", "(ILjava/lang/String;)V");
    (*env)->CallStaticVoidMethod(env, cls, method, id, value);
    (*env)->DeleteLocalRef(env, value);
    (*env)->DeleteLocalRef(env, cls);
}

void android_textfield_replaceText(int id, int offset, int count, const uint16_t *text, int length)
{
    JNIEnv *env = jbed_android_get_env();
    jclass cls = text_field_class(env);
    jstring value = text ? (*env)->NewString(env, text, length) : NULL;
    jmethodID method = (*env)->GetStaticMethodID(env, cls, "replaceText", "(IIILjava/lang/String;)V");
    (*env)->CallStaticVoidMethod(env, cls, method, id, offset, count, value);
    (*env)->DeleteLocalRef(env, value);
    (*env)->DeleteLocalRef(env, cls);
}

void Java_android_jbed_nativeui_JbedTextFieldConnection_notifyRefreshTextField(
    JNIEnv *env, jobject self, jint id)
{
    (void)env; (void)self;
    if (id & JBED_TEXTBOX_MASK) JPL_javaui_TextBox_refresh();
    else JPL_javaui_TextField_refresh(id);
}

void Java_android_jbed_nativeui_JbedTextFieldConnection_notifyTextFieldClientAttached(JNIEnv *env, jobject self)
{
    (void)env; (void)self;
    jbed_handle_nativeTextField_client_attached();
    jbed_handle_nativeTextBox_client_attached();
}

void Java_android_jbed_nativeui_JbedTextFieldConnection_notifyTextFieldTextChanged(
    JNIEnv *env, jobject self, jint id, jstring value)
{
    (void)self;
    if (value) {
        int length = (*env)->GetStringLength(env, value);
        const jchar *text = (*env)->GetStringChars(env, value, NULL);
        if (!text) return;
        if (id & JBED_TEXTBOX_MASK)
            JPL_javaui_TextBox_setText(text, length);
        else
            JPL_javaui_TextField_setText(id, text, length);
        (*env)->ReleaseStringChars(env, value, text);
    }
}
