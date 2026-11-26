#include "android_jni.h"
#include "android_methods.h"
#include "pim.h"

#include <stdlib.h>
#include <string.h>

void Java_android_jbed_jsr_JbedPimManager_nativeInitialization(JNIEnv *env, jclass clazz)
{
    gCachedFields.pim = (*env)->NewGlobalRef(env, clazz);
    gCachedFields.pim_supported = (*env)->GetStaticMethodID(env, clazz, "isSupported", "(I)Z");
    gCachedFields.pim_next = (*env)->GetStaticMethodID(env, clazz, "getNextItem", "(ILjava/lang/String;)[B");
    gCachedFields.pim_remove = (*env)->GetStaticMethodID(env, clazz, "remove", "(ILjava/lang/String;)I");
    gCachedFields.pim_store_contact = (*env)->GetStaticMethodID(env, clazz, "storeContact",
        "(Ljava/lang/String;Ljava/lang/String;[I[Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;"
        "Ljava/lang/String;[I[Ljava/lang/String;[I[Ljava/lang/String;[I[Ljava/lang/String;[I[Ljava/lang/String;[B)[B");
    gCachedFields.pim_store_todo = (*env)->GetStaticMethodID(env, clazz, "storeTodo",
        "(Ljava/lang/String;Ljava/lang/String;Z)[B");
    gCachedFields.pim_store_event = (*env)->GetStaticMethodID(env, clazz, "storeEvent",
        "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IJJ[IIIIJ)[B");
}

int android_pim_isSupported(int type)
{
    JNIEnv *env = jbed_android_get_env();
    return (*env)->CallStaticBooleanMethod(env, gCachedFields.pim, gCachedFields.pim_supported, type);
}

static jstring optional_string(JNIEnv *env, const uint16_t *chars, int length)
{
    return chars ? (*env)->NewString(env, chars, length) : NULL;
}

int android_pim_remove(int handle, const uint16_t *id, int length)
{
    JNIEnv *env = jbed_android_get_env();
    jstring uid = optional_string(env, id, length);
    int result = (*env)->CallStaticIntMethod(env, gCachedFields.pim, gCachedFields.pim_remove, handle, uid);
    (*env)->DeleteLocalRef(env, uid);
    return result;
}

static int copy_result(JNIEnv *env, jbyteArray a, void **out, size_t *size)
{
    *out = NULL;
    *size = 0;
    if (!a || (*env)->ExceptionCheck(env)) return -1;
    *size = (size_t)(*env)->GetArrayLength(env, a);
    if (!*size) return -1;
    *out = malloc(*size + 1);
    if (!*out) return -1;
    (*env)->GetByteArrayRegion(env, a, 0, (jsize)*size, *out);
    ((char *)*out)[*size] = 0;
    return 0;
}

int android_pim_getNextItem(int handle, const uint16_t *id, int length, void **out, size_t *size)
{
    JNIEnv *env = jbed_android_get_env();
    if ((*env)->PushLocalFrame(env, 4) < 0) return -1;
    jstring uid = optional_string(env, id, length);
    jbyteArray result = (*env)->CallStaticObjectMethod(env, gCachedFields.pim, gCachedFields.pim_next, handle, uid);
    int status = copy_result(env, result, out, size);
    (*env)->PopLocalFrame(env, NULL);
    return status;
}

int android_pim_storeTodo(const uint16_t *id, int id_length, const uint16_t *summary, int length,
                          uint8_t completed, void **out, size_t *size)
{
    JNIEnv *env = jbed_android_get_env();
    if ((*env)->PushLocalFrame(env, 4) < 0) return -1;
    jstring uid = optional_string(env, id, id_length);
    jstring title = optional_string(env, summary, length);
    jbyteArray result = (*env)->CallStaticObjectMethod(env, gCachedFields.pim, gCachedFields.pim_store_todo,
                                                       uid, title, completed);
    int status = copy_result(env, result, out, size);
    (*env)->PopLocalFrame(env, NULL);
    return status;
}

static jintArray int_array(JNIEnv *env, const int32_t *values, int count)
{
    jintArray a = (*env)->NewIntArray(env, count);
    if (a && count > 0) (*env)->SetIntArrayRegion(env, a, 0, count, values);
    return a;
}

int android_pim_storeEvent(const uint16_t *id, int id_length, const uint16_t *summary, int summary_length,
    const uint16_t *notes, int notes_length, const uint16_t *location, int location_length,
    int classification, int64_t start, int64_t end, const int32_t *alarms, int alarm_count,
    int frequency, int interval, int count, int64_t until, void **out, size_t *size)
{
    JNIEnv *env = jbed_android_get_env();
    if ((*env)->PushLocalFrame(env, 8) < 0) return -1;
    jstring uid = optional_string(env, id, id_length);
    jstring title = optional_string(env, summary, summary_length);
    jstring description = optional_string(env, notes, notes_length);
    jstring place = optional_string(env, location, location_length);
    jintArray reminders = int_array(env, alarms, alarm_count);
    jbyteArray result = (*env)->CallStaticObjectMethod(env, gCachedFields.pim, gCachedFields.pim_store_event,
        uid, title, description, place, classification, (jlong)start, (jlong)end, reminders,
        frequency, interval, count, (jlong)until);
    int status = copy_result(env, result, out, size);
    (*env)->PopLocalFrame(env, NULL);
    return status;
}

/* 0x9e81c maps missing and zero-length contact fields to null elements. */
static jobjectArray string_array(JNIEnv *env, const uint16_t *const *values, const int32_t *lengths, int count)
{
    jclass string = (*env)->FindClass(env, "java/lang/String");
    jobjectArray a = (*env)->NewObjectArray(env, count, string, NULL);
    (*env)->DeleteLocalRef(env, string);
    if (!a) return NULL;
    for (int i = 0; i < count; ++i) {
        jstring s = NULL;
        if (values[i] && lengths[i] > 0) s = (*env)->NewString(env, values[i], lengths[i]);
        (*env)->SetObjectArrayElement(env, a, i, s);
        (*env)->DeleteLocalRef(env, s);
    }
    return a;
}

typedef struct { jintArray attrs; jobjectArray strings; } ContactField;

static ContactField contact_field(JNIEnv *env, const int32_t *attrs, const uint16_t *const *values,
                                 const int32_t *lengths, int count)
{
    ContactField f;
    f.attrs = int_array(env, attrs, count);
    f.strings = string_array(env, values, lengths, count);
    return f;
}

int android_pim_storeContact(const uint16_t *id, int id_length, const uint16_t *formatted, int formatted_length,
    const int32_t *name_attrs, const uint16_t *const *names, const int32_t *name_lengths,
    const uint16_t *title, int title_length, const uint16_t *company, int company_length,
    const uint16_t *notes, int notes_length,
    const int32_t *phone_attrs, const uint16_t *const *phones, const int32_t *phone_lengths,
    const int32_t *email_attrs, const uint16_t *const *emails, const int32_t *email_lengths,
    const int32_t *addr_attrs, const uint16_t *const *addrs, const int32_t *addr_lengths,
    const int32_t *url_attrs, const uint16_t *const *urls, const int32_t *url_lengths,
    const void *photo_data, size_t photo_size, void **out, size_t *size, int count)
{
    JNIEnv *env = jbed_android_get_env();
    if ((*env)->PushLocalFrame(env, 24) < 0) return -1;
    jstring uid = optional_string(env, id, id_length);
    jstring display = optional_string(env, formatted, formatted_length);
    jstring job = optional_string(env, title, title_length);
    jstring employer = optional_string(env, company, company_length);
    jstring memo = optional_string(env, notes, notes_length);
    ContactField phone = contact_field(env, phone_attrs, phones, phone_lengths, count);
    ContactField email = contact_field(env, email_attrs, emails, email_lengths, count);
    ContactField addr = contact_field(env, addr_attrs, addrs, addr_lengths, count);
    ContactField name = contact_field(env, name_attrs, names, name_lengths, count);
    ContactField url = contact_field(env, url_attrs, urls, url_lengths, count);
    jbyteArray photo = (*env)->NewByteArray(env, (jsize)photo_size);
    if (photo && photo_size) (*env)->SetByteArrayRegion(env, photo, 0, (jsize)photo_size, photo_data);
    jbyteArray result = (*env)->CallStaticObjectMethod(env, gCachedFields.pim, gCachedFields.pim_store_contact,
        uid, display, name.attrs, name.strings, employer, job, memo, phone.attrs, phone.strings,
        email.attrs, email.strings, addr.attrs, addr.strings, url.attrs, url.strings, photo);
    int status = copy_result(env, result, out, size);
    (*env)->PopLocalFrame(env, NULL);
    return status;
}
