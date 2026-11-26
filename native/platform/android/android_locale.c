#include "android_jni.h"
#include "android_methods.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>


void Java_android_jbed_jsr_JbedMiapiManager_nativeInitialization(JNIEnv *env, jclass clazz)
{
    gCachedFields.miapi = (*env)->NewGlobalRef(env, clazz);
}

static jmethodID method(const char *name, const char *signature)
{
    JNIEnv *env = jbed_android_get_env();
    return (*env)->GetStaticMethodID(env, gCachedFields.miapi, name, signature);
}

static jstring java_string(const jchar *characters, jsize length)
{
    JNIEnv *env = jbed_android_get_env();
    return characters ? (*env)->NewString(env, characters, length) : NULL;
}

static jint int0(const char *name)
{
    JNIEnv *env = jbed_android_get_env();
    jmethodID m = method(name, "()I");
    return (*env)->CallStaticIntMethod(env, gCachedFields.miapi, m);
}

static jint int1(const char *name, jint argument)
{
    JNIEnv *env = jbed_android_get_env();
    jmethodID m = method(name, "(I)I");
    return (*env)->CallStaticIntMethod(env, gCachedFields.miapi, m, argument);
}

jint android_miapi_closeCollator(jint handle) { return int1("closeCollator", handle); }
jint android_miapi_getCollatorLocalesNum(void) { return int0("getCollatorLocalesNum"); }
jint android_miapi_getFormatterLocalesNum(void) { return int0("getFormatterLocalesNum"); }
jint android_miapi_getCollatorLocaleLen(jint idx) { return int1("getCollatorLocaleLen", idx); }
jint android_miapi_getFormatterLocaleLen(jint idx) { return int1("getFormatterLocaleLen", idx); }

static jint locale_name(const char *name, jint (*length)(jint), char *buffer, jint limit, jint idx)
{
    JNIEnv *env = jbed_android_get_env();
    jmethodID m = method(name, "(I)Ljava/lang/String;");
    jstring s = (*env)->CallStaticObjectMethod(env, gCachedFields.miapi, m, idx);
    if (!s) return -1;
    const char *utf = (*env)->GetStringUTFChars(env, s, NULL);
    if (!utf) { (*env)->DeleteLocalRef(env, s); return -1; }
    jint count = length(idx);
    jint copied = count < limit ? count : limit;
    if (copied > 0) memcpy(buffer, utf, (size_t)copied);
    if (copied >= 0 && copied < limit) buffer[copied] = 0;
    (*env)->ReleaseStringUTFChars(env, s, utf);
    (*env)->DeleteLocalRef(env, s);
    return copied;
}

jint android_miapi_getCollatorLocaleName(char *dst, jint capacity, jint idx)
{
    return locale_name("getCollatorLocaleName", android_miapi_getCollatorLocaleLen, dst, capacity, idx);
}

jint android_miapi_getFormatterLocaleName(char *dst, jint capacity, jint idx)
{
    return locale_name("getFormatterLocaleName", android_miapi_getFormatterLocaleLen, dst, capacity, idx);
}

jint android_miapi_openCollator(const jchar *chars, jsize len)
{
    JNIEnv *env = jbed_android_get_env();
    jstring s = java_string(chars, len);
    jmethodID m = method("openCollator", "(Ljava/lang/String;)I");
    jint result = (*env)->CallStaticIntMethod(env, gCachedFields.miapi, m, s);
    (*env)->DeleteLocalRef(env, s);
    return result;
}

jint android_miapi_compare(jint handle, jint strength, const jchar *a, jsize na,
                           const jchar *b, jsize nb)
{
    JNIEnv *env = jbed_android_get_env();
    jstring first = java_string(a, na);
    jstring second = java_string(b, nb);
    jmethodID m = method("compare", "(IILjava/lang/String;Ljava/lang/String;)I");
    jint result = (*env)->CallStaticIntMethod(env, gCachedFields.miapi, m, handle, strength, first, second);
    (*env)->DeleteLocalRef(env, first);
    (*env)->DeleteLocalRef(env, second);
    return result;
}

char *android_miapi_getCharPtr(jstring s)
{
    JNIEnv *env = jbed_android_get_env();
    if (!s) return (char *)(intptr_t)-1;
    jsize n = (*env)->GetStringUTFLength(env, s);
    const char *chars = (*env)->GetStringUTFChars(env, s, NULL);
    if (!chars) return (char *)(intptr_t)-1;
    char *result = malloc((size_t)n + 1);
    if (result) memcpy(result, chars, (size_t)n + 1);
    (*env)->ReleaseStringUTFChars(env, s, chars);
    if (!result) {
        jbed_android_throw(env, "java/lang/OutOfMemoryError", "Failed to malloc buffer");
        return (char *)(intptr_t)-1;
    }
    return result;
}

char *android_miapi_formatDateTime(const jchar *chars, jsize length, const jint *style, const jlong *millis)
{
    JNIEnv *env = jbed_android_get_env();
    jstring locale = java_string(chars, length);
    jmethodID m = method("formatDateTime", "(Ljava/lang/String;IJ)Ljava/lang/String;");
    jstring result = (*env)->CallStaticObjectMethod(env, gCachedFields.miapi, m, locale, *style, *millis);
    char *text = android_miapi_getCharPtr(result);
    (*env)->DeleteLocalRef(env, result);
    (*env)->DeleteLocalRef(env, locale);
    return text;
}

char *android_miapi_formatCurrencyWithCode(const jchar *chars, jsize length, const jchar *currency, jsize currency_length, const jdouble *amount)
{
    JNIEnv *env = jbed_android_get_env();
    jstring locale = java_string(chars, length);
    jstring code = java_string(currency, currency_length);
    jmethodID m = method("formatCurrency", "(Ljava/lang/String;DLjava/lang/String;)Ljava/lang/String;");
    jstring result = (*env)->CallStaticObjectMethod(env, gCachedFields.miapi, m, locale, *amount, code);
    char *text = android_miapi_getCharPtr(result);
    (*env)->DeleteLocalRef(env, result);
    (*env)->DeleteLocalRef(env, locale);
    (*env)->DeleteLocalRef(env, code);
    return text;
}

char *android_miapi_formatCurrency(const jchar *chars, jsize length, const jdouble *amount)
{
    JNIEnv *env = jbed_android_get_env();
    jstring locale = java_string(chars, length);
    jmethodID m = method("formatCurrency", "(Ljava/lang/String;D)Ljava/lang/String;");
    jstring result = (*env)->CallStaticObjectMethod(env, gCachedFields.miapi, m, locale, *amount);
    char *text = android_miapi_getCharPtr(result);
    (*env)->DeleteLocalRef(env, result);
    (*env)->DeleteLocalRef(env, locale);
    return text;
}

char *android_miapi_formatDecimalPercent(const jchar *chars, jsize length, const jfloat *number, const jint *decimals)
{
    JNIEnv *env = jbed_android_get_env();
    jstring locale = java_string(chars, length);
    jmethodID m = method("formatPercent", "(Ljava/lang/String;FI)Ljava/lang/String;");
    jstring result = (*env)->CallStaticObjectMethod(env, gCachedFields.miapi, m, locale, *number, *decimals);
    char *text = android_miapi_getCharPtr(result);
    (*env)->DeleteLocalRef(env, result);
    (*env)->DeleteLocalRef(env, locale);
    return text;
}

char *android_miapi_formatLongPercent(const jchar *chars, jsize length, const jlong *number)
{
    JNIEnv *env = jbed_android_get_env();
    jstring locale = java_string(chars, length);
    jmethodID m = method("formatPercent", "(Ljava/lang/String;J)Ljava/lang/String;");
    jstring result = (*env)->CallStaticObjectMethod(env, gCachedFields.miapi, m, locale, *number);
    char *text = android_miapi_getCharPtr(result);
    (*env)->DeleteLocalRef(env, result);
    (*env)->DeleteLocalRef(env, locale);
    return text;
}

char *android_miapi_formatDecimalNumber(const jchar *chars, jsize length, const jdouble *number, const jint *decimals)
{
    JNIEnv *env = jbed_android_get_env();
    jstring locale = java_string(chars, length);
    jmethodID m = method("formatNumber", "(Ljava/lang/String;DI)Ljava/lang/String;");
    jstring result = (*env)->CallStaticObjectMethod(env, gCachedFields.miapi, m, locale, *number, *decimals);
    char *text = android_miapi_getCharPtr(result);
    (*env)->DeleteLocalRef(env, result);
    (*env)->DeleteLocalRef(env, locale);
    return text;
}

char *android_miapi_formatLongNumber(const jchar *chars, jsize length, const jlong *number)
{
    JNIEnv *env = jbed_android_get_env();
    jstring locale = java_string(chars, length);
    jmethodID m = method("formatNumber", "(Ljava/lang/String;J)Ljava/lang/String;");
    jstring result = (*env)->CallStaticObjectMethod(env, gCachedFields.miapi, m, locale, *number);
    char *text = android_miapi_getCharPtr(result);
    (*env)->DeleteLocalRef(env, result);
    (*env)->DeleteLocalRef(env, locale);
    return text;
}

char *android_miapi_formatDoubleNumber(const jchar *chars, jsize length, const jdouble *number)
{
    JNIEnv *env = jbed_android_get_env();
    jstring locale = java_string(chars, length);
    jmethodID m = method("formatNumber", "(Ljava/lang/String;D)Ljava/lang/String;");
    jstring result = (*env)->CallStaticObjectMethod(env, gCachedFields.miapi, m, locale, *number);
    char *text = android_miapi_getCharPtr(result);
    (*env)->DeleteLocalRef(env, result);
    (*env)->DeleteLocalRef(env, locale);
    return text;
}
