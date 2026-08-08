/*
 * ART JNI lifetime compatibility hook for the 2011 Jbed VM.
 *
 * libjbedvm stores the JbedEngine jobject passed to
 * nativeInitializeSubsystems() in native global storage (0x31c864), but it
 * stores the incoming *local* reference. On ART that local reference expires
 * when nativeInitializeSubsystems returns; the first VM state callback then
 * aborts with "use of invalid jobject".
 *
 * The original VM calls GetMethodID("vmStateChange", "(ZIII)Z") only after
 * storing the local jobject. This hook temporarily replaces GetMethodID in
 * the current JNIEnv table. At that point it promotes the stored reference
 * with NewGlobalRef before the original native method returns.
 *
 * This is a narrow binary-compatibility workaround, not a general JNI hook.
 */
#include <jni.h>
#include <android/log.h>
#include <dlfcn.h>
#include <link.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define LOG_TAG "jbed-jni-compat"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

/* dword_31C864 in the original ELF; its first LOAD segment has vaddr zero. */
#define JBED_ENGINE_LOCAL_REF_OFFSET 0x31c864u

/* NDK's C jni.h names this structure JNINativeInterface (without the
 * trailing underscore used by some platform headers). */
static const struct JNINativeInterface *g_original_table;
static struct JNINativeInterface *g_hook_table;
static jmethodID (*g_original_get_method_id)(JNIEnv *, jclass, const char *, const char *);

static const struct JNINativeInterface *g_midp_original_table;
static struct JNINativeInterface *g_midp_hook_table;
static jclass (*g_original_find_class)(JNIEnv *, const char *);
static jclass g_promoted_midp_class;

static uintptr_t g_jbed_base;
static jobject g_promoted_engine;

static int locate_jbedvm(struct dl_phdr_info *info, size_t size, void *data) {
    (void) size;
    (void) data;
    if (info->dlpi_name && strstr(info->dlpi_name, "libjbedvm.so")) {
        g_jbed_base = (uintptr_t) info->dlpi_addr;
        return 1;
    }
    return 0;
}

static void promote_engine_reference(JNIEnv *env) {
    if (g_promoted_engine != NULL || g_jbed_base == 0) return;

    jobject *slot = (jobject *) (g_jbed_base + JBED_ENGINE_LOCAL_REF_OFFSET);
    jobject local_engine = *slot;
    if (local_engine == NULL) {
        LOGE("JbedEngine local jobject slot is null");
        return;
    }

    jobject global_engine = (*env)->NewGlobalRef(env, local_engine);
    if (global_engine == NULL) {
        LOGE("NewGlobalRef(JbedEngine) failed");
        return;
    }
    *slot = global_engine;
    g_promoted_engine = global_engine;
    LOGI("promoted legacy JbedEngine JNI reference to a global reference");
}

static jmethodID JNICALL hooked_get_method_id(JNIEnv *env, jclass clazz,
                                               const char *name, const char *signature) {
    jmethodID result = g_original_get_method_id(env, clazz, name, signature);
    if (name != NULL && signature != NULL &&
        strcmp(name, "vmStateChange") == 0 && strcmp(signature, "(ZIII)Z") == 0) {
        promote_engine_reference(env);
        /* The old native initializer has passed its only unsafe lookup. */
        *env = g_original_table;
    }
    return result;
}

static jclass JNICALL hooked_find_class(JNIEnv *env, const char *name) {
    jclass result = g_original_find_class(env, name);
    if (name != NULL && strcmp(name, "com/esmertec/android/jbed/jsr/JbedMidpManager") == 0) {
        if (result != NULL && g_promoted_midp_class == NULL) {
            g_promoted_midp_class = (jclass) (*env)->NewGlobalRef(env, result);
            LOGI("captured global JbedMidpManager class reference");
        }
        *env = g_midp_original_table;
    }
    return result;
}

JNIEXPORT void JNICALL
Java_com_esmertec_android_jbed_service_JbedService_nativePrepareMidpClassReferenceHook(JNIEnv *env, jclass clazz) {
    (void) clazz;
    if (g_midp_hook_table != NULL) return;
    dl_iterate_phdr(locate_jbedvm, NULL);
    if (g_jbed_base == 0) return;

    g_midp_original_table = *env;
    g_original_find_class = g_midp_original_table->FindClass;
    g_midp_hook_table = malloc(sizeof(*g_midp_hook_table));
    if (g_midp_hook_table == NULL) return;
    memcpy(g_midp_hook_table, g_midp_original_table, sizeof(*g_midp_hook_table));
    g_midp_hook_table->FindClass = hooked_find_class;
    *env = g_midp_hook_table;
    LOGI("installed JbedMidpManager class-reference hook");
}

JNIEXPORT void JNICALL
Java_com_esmertec_android_jbed_service_JbedService_nativePromoteMidpClassReference(JNIEnv *env, jclass clazz) {
    (void) env;
    (void) clazz;
    if (g_promoted_midp_class == NULL || g_jbed_base == 0) {
        LOGE("JbedMidpManager class reference was not captured");
        return;
    }
    *((jclass *) (g_jbed_base + 0x31c8a4u)) = g_promoted_midp_class;
    LOGI("promoted legacy JbedMidpManager JNI class reference");
}

JNIEXPORT void JNICALL
Java_com_esmertec_android_jbed_service_JbedEngine_nativeInstallJniLifetimeHook(JNIEnv *env, jclass clazz) {
    (void) clazz;
    if (g_hook_table != NULL) return;

    dl_iterate_phdr(locate_jbedvm, NULL);
    if (g_jbed_base == 0) {
        LOGE("libjbedvm.so is not loaded; cannot install JNI lifetime hook");
        return;
    }

    g_original_table = *env;
    g_original_get_method_id = g_original_table->GetMethodID;
    g_hook_table = malloc(sizeof(*g_hook_table));
    if (g_hook_table == NULL) {
        LOGE("unable to allocate JNI function-table clone");
        return;
    }
    memcpy(g_hook_table, g_original_table, sizeof(*g_hook_table));
    g_hook_table->GetMethodID = hooked_get_method_id;
    *env = g_hook_table;
    LOGI("installed one-shot JNI lifetime hook for libjbedvm at %p", (void *) g_jbed_base);
}

JNIEXPORT void JNICALL
Java_com_esmertec_android_jbed_service_JbedEngine_nativeReleaseJniLifetimeHook(JNIEnv *env, jclass clazz) {
    (void) clazz;
    if (g_promoted_engine != NULL) {
        (*env)->DeleteGlobalRef(env, g_promoted_engine);
        g_promoted_engine = NULL;
    }
    if (g_hook_table != NULL) {
        /* It is normally restored by hooked_get_method_id. Restore defensively. */
        if (*env == g_hook_table) {
            *env = g_original_table;
        }
        free(g_hook_table);
        g_hook_table = NULL;
    }
    g_original_table = NULL;
    g_original_get_method_id = NULL;
    if (g_promoted_midp_class != NULL) {
        (*env)->DeleteGlobalRef(env, g_promoted_midp_class);
        g_promoted_midp_class = NULL;
    }
    if (g_midp_hook_table != NULL) {
        if (*env == g_midp_hook_table) *env = g_midp_original_table;
        free(g_midp_hook_table);
        g_midp_hook_table = NULL;
    }
    g_midp_original_table = NULL;
    g_original_find_class = NULL;
    g_jbed_base = 0;
}

/* Explicit registration avoids relying on ART's cross-library native symbol
 * lookup order after libjbedvm.so has registered its own methods. */
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    (void) reserved;
    JNIEnv *env = NULL;
    if ((*vm)->GetEnv(vm, (void **) &env, JNI_VERSION_1_6) != JNI_OK) return JNI_ERR;

    jclass engine = (*env)->FindClass(env, "com/esmertec/android/jbed/service/JbedEngine");
    if (engine == NULL) return JNI_ERR;
    JNINativeMethod methods[] = {
        {"nativeInstallJniLifetimeHook", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedEngine_nativeInstallJniLifetimeHook},
        {"nativeReleaseJniLifetimeHook", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedEngine_nativeReleaseJniLifetimeHook},
    };
    if ((*env)->RegisterNatives(env, engine, methods, 2) != JNI_OK) return JNI_ERR;

    jclass service = (*env)->FindClass(env, "com/esmertec/android/jbed/service/JbedService");
    if (service == NULL) return JNI_ERR;
    JNINativeMethod service_methods[] = {
        {"nativePrepareMidpClassReferenceHook", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedService_nativePrepareMidpClassReferenceHook},
        {"nativePromoteMidpClassReference", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedService_nativePromoteMidpClassReference},
    };
    if ((*env)->RegisterNatives(env, service, service_methods, 2) != JNI_OK) return JNI_ERR;
    LOGI("registered ART JNI lifetime compatibility methods");
    return JNI_VERSION_1_6;
}
