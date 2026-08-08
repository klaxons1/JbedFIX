/*
 * ART JNI/native compatibility hooks for the 2011 Jbed VM.
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
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#define LOG_TAG "jbed-jni-compat"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

#ifndef RTLD_NOLOAD
#define RTLD_NOLOAD 0
#endif

/* dword_31C864 in the original ELF; its first LOAD segment has vaddr zero. */
#define JBED_ENGINE_LOCAL_REF_OFFSET 0x31c864u

/* NDK's C jni.h names this structure JNINativeInterface (without the
 * trailing underscore used by some platform headers). */
static const struct JNINativeInterface *g_original_table;
static struct JNINativeInterface *g_hook_table;
static jmethodID (*g_original_get_method_id)(JNIEnv *, jclass, const char *, const char *);
static jmethodID g_midp_get_string_method;
static jmethodID g_file_get_roots_method;

static uintptr_t g_jbed_base;
static jobject g_promoted_engine;

/*
 * The Java method nativeJbedRun() in libjbedvm is only a tiny wrapper around
 * Jbed_run(50). On ART/Android 11 the VM currently consumes the whole host
 * thread stack during the first zero-delay NativeAms scheduler pass before the
 * Java loop gets a chance to wait. RegisterNatives below replaces that JNI
 * entry point with this compatibility wrapper, which still executes the
 * proprietary scheduler but with a one-step quantum. This is intentionally
 * conservative: it trades some startup throughput for native stack headroom
 * while we investigate the deeper scheduler recursion.
 */
#define JBED_RUN_THUMB_OFFSET 0x2bd331u
#define JBED_RUN_COMPAT_QUANTUM 1
#define JBED_RUN_STACK_FALLBACK_DELAY_MS 100

typedef int (*jbed_run_fn)(int quantum);
static jbed_run_fn g_jbed_run;
static jclass g_stack_overflow_error_class;
static int g_logged_jbed_run_hook;

static int locate_jbedvm(struct dl_phdr_info *info, size_t size, void *data) {
    (void) size;
    (void) data;
    if (info->dlpi_name && strstr(info->dlpi_name, "libjbedvm.so")) {
        g_jbed_base = (uintptr_t) info->dlpi_addr;
        return 1;
    }
    return 0;
}

static void ensure_jbed_base(void) {
    if (g_jbed_base == 0) {
        dl_iterate_phdr(locate_jbedvm, NULL);
    }
}

static jbed_run_fn resolve_jbed_run(void) {
    if (g_jbed_run != NULL) return g_jbed_run;

    void *handle = dlopen("libjbedvm.so", RTLD_NOW | RTLD_NOLOAD);
    if (handle == NULL) {
        /* The library is already loaded by JbedService before libjbedcompat,
         * but some Android linkers only match the exact soname/path with a
         * plain dlopen. This should still return the existing instance. */
        handle = dlopen("libjbedvm.so", RTLD_NOW);
    }
    if (handle != NULL) {
        g_jbed_run = (jbed_run_fn) dlsym(handle, "Jbed_run");
    }

    if (g_jbed_run == NULL) {
        ensure_jbed_base();
        if (g_jbed_base != 0) {
            /* readelf shows Jbed_run at st_value 0x2bd331; the low bit marks
             * the exported ARM Thumb function pointer. */
            g_jbed_run = (jbed_run_fn) (g_jbed_base + JBED_RUN_THUMB_OFFSET);
        }
    }
    return g_jbed_run;
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

static void clear_pending_exception(JNIEnv *env) {
    if ((*env)->ExceptionCheck(env)) {
        LOGI("clearing pending JNI exception before unsafe legacy callback");
        (*env)->ExceptionClear(env);
    }
}

static jclass JNICALL hooked_find_class(JNIEnv *env, const char *name) {
    clear_pending_exception(env);
    return g_original_table->FindClass(env, name);
}

static jmethodID JNICALL hooked_get_method_id(JNIEnv *env, jclass clazz,
                                               const char *name, const char *signature) {
    clear_pending_exception(env);
    jmethodID result = g_original_get_method_id(env, clazz, name, signature);
    if (name != NULL && signature != NULL &&
        strcmp(name, "vmStateChange") == 0 && strcmp(signature, "(ZIII)Z") == 0) {
        promote_engine_reference(env);
        /* Keep this cloned table active: the VM later performs unsafe static
         * JbedMidpManager string callbacks on the same JbedThread. */
    }
    return result;
}

static jmethodID JNICALL hooked_get_static_method_id(JNIEnv *env, jclass clazz,
                                                      const char *name, const char *signature) {
    clear_pending_exception(env);
    jmethodID result = g_original_table->GetStaticMethodID(env, clazz, name, signature);
    if (name != NULL && signature != NULL &&
        strcmp(name, "getString") == 0 && strcmp(signature, "(II)Ljava/lang/String;") == 0) {
        if (g_midp_get_string_method == NULL) {
            LOGI("intercepted JbedMidpManager.getString method lookup: %p", result);
        }
        g_midp_get_string_method = result;
    } else if (name != NULL && signature != NULL &&
               strcmp(name, "getRoots") == 0 && strcmp(signature, "()[B") == 0) {
        LOGI("intercepted JbedFileManager.getRoots method lookup: %p", result);
        g_file_get_roots_method = result;
    }
    return result;
}

static jobject make_empty_roots(JNIEnv *env) {
    jbyteArray empty_roots;
    jbyte zero_roots[5] = {0, 0, 0, 0, 0};
    LOGI("bypassing legacy JbedFileManager.getRoots with an empty root list");
    empty_roots = (*env)->NewByteArray(env, (jsize) sizeof(zero_roots));
    if (empty_roots != NULL) {
        (*env)->SetByteArrayRegion(env, empty_roots, 0,
                                    (jsize) sizeof(zero_roots), zero_roots);
    }
    return empty_roots;
}

static jobject JNICALL hooked_call_static_object_method(JNIEnv *env, jclass clazz, jmethodID method, ...) {
    clear_pending_exception(env);
    if (g_midp_get_string_method != NULL && method == g_midp_get_string_method) {
        return (*env)->NewStringUTF(env, "<unknown>");
    }
    if (g_file_get_roots_method != NULL && method == g_file_get_roots_method) {
        return make_empty_roots(env);
    }

    va_list args;
    va_start(args, method);
    jobject result = g_original_table->CallStaticObjectMethodV(env, clazz, method, args);
    va_end(args);
    return result;
}

static jobject JNICALL hooked_call_static_object_method_v(JNIEnv *env, jclass clazz, jmethodID method, va_list args) {
    clear_pending_exception(env);
    if (g_midp_get_string_method != NULL && method == g_midp_get_string_method) {
        return (*env)->NewStringUTF(env, "<unknown>");
    }
    if (g_file_get_roots_method != NULL && method == g_file_get_roots_method) {
        return make_empty_roots(env);
    }
    return g_original_table->CallStaticObjectMethodV(env, clazz, method, args);
}

static jobject JNICALL hooked_call_static_object_method_a(JNIEnv *env, jclass clazz, jmethodID method, const jvalue *args) {
    clear_pending_exception(env);
    if (g_midp_get_string_method != NULL && method == g_midp_get_string_method) {
        return (*env)->NewStringUTF(env, "<unknown>");
    }
    if (g_file_get_roots_method != NULL && method == g_file_get_roots_method) {
        return make_empty_roots(env);
    }
    return g_original_table->CallStaticObjectMethodA(env, clazz, method, args);
}

JNIEXPORT void JNICALL
Java_com_esmertec_android_jbed_service_JbedEngine_nativeInstallJniLifetimeHook(JNIEnv *env, jclass clazz) {
    (void) clazz;
    if (g_hook_table != NULL) return;

    ensure_jbed_base();
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
    g_hook_table->FindClass = hooked_find_class;
    g_hook_table->GetMethodID = hooked_get_method_id;
    g_hook_table->GetStaticMethodID = hooked_get_static_method_id;
    g_hook_table->CallStaticObjectMethod = hooked_call_static_object_method;
    g_hook_table->CallStaticObjectMethodV = hooked_call_static_object_method_v;
    g_hook_table->CallStaticObjectMethodA = hooked_call_static_object_method_a;
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
    g_midp_get_string_method = NULL;
    g_file_get_roots_method = NULL;
    g_jbed_base = 0;
}

static jint JNICALL hooked_native_jbed_run(JNIEnv *env, jobject thiz) {
    (void) thiz;

    jbed_run_fn jbed_run = resolve_jbed_run();
    if (jbed_run == NULL) {
        LOGE("unable to resolve libjbedvm Jbed_run; delaying VM loop");
        return JBED_RUN_STACK_FALLBACK_DELAY_MS;
    }

    if (!g_logged_jbed_run_hook) {
        g_logged_jbed_run_hook = 1;
        LOGI("hooked nativeJbedRun: calling Jbed_run(%d) instead of legacy Jbed_run(50)",
             JBED_RUN_COMPAT_QUANTUM);
    }

    jint delay = (jint) jbed_run(JBED_RUN_COMPAT_QUANTUM);
    if ((*env)->ExceptionCheck(env)) {
        jthrowable pending = (*env)->ExceptionOccurred(env);
        (*env)->ExceptionClear(env);
        if (pending != NULL && g_stack_overflow_error_class != NULL &&
            (*env)->IsInstanceOf(env, pending, g_stack_overflow_error_class)) {
            LOGE("Jbed_run(%d) still raised StackOverflowError; returning %dms fallback",
                 JBED_RUN_COMPAT_QUANTUM, JBED_RUN_STACK_FALLBACK_DELAY_MS);
            if (pending != NULL) (*env)->DeleteLocalRef(env, pending);
            return JBED_RUN_STACK_FALLBACK_DELAY_MS;
        }

        LOGE("Jbed_run(%d) raised a non-stack exception; rethrowing to Java",
             JBED_RUN_COMPAT_QUANTUM);
        if (pending != NULL) {
            (*env)->Throw(env, pending);
            (*env)->DeleteLocalRef(env, pending);
        }
        return JBED_RUN_STACK_FALLBACK_DELAY_MS;
    }
    return delay;
}

/* Explicit registration avoids relying on ART's cross-library native symbol
 * lookup order after libjbedvm.so has registered its own methods. */
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    (void) reserved;
    JNIEnv *env = NULL;
    if ((*vm)->GetEnv(vm, (void **) &env, JNI_VERSION_1_6) != JNI_OK) return JNI_ERR;

    jclass stack_overflow = (*env)->FindClass(env, "java/lang/StackOverflowError");
    if (stack_overflow != NULL) {
        g_stack_overflow_error_class = (*env)->NewGlobalRef(env, stack_overflow);
        (*env)->DeleteLocalRef(env, stack_overflow);
    } else if ((*env)->ExceptionCheck(env)) {
        (*env)->ExceptionClear(env);
    }

    ensure_jbed_base();
    resolve_jbed_run();

    jclass engine = (*env)->FindClass(env, "com/esmertec/android/jbed/service/JbedEngine");
    if (engine == NULL) return JNI_ERR;
    JNINativeMethod methods[] = {
        {"nativeInstallJniLifetimeHook", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedEngine_nativeInstallJniLifetimeHook},
        {"nativeReleaseJniLifetimeHook", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedEngine_nativeReleaseJniLifetimeHook},
        {"nativeJbedRun", "()I", (void *) hooked_native_jbed_run},
    };
    if ((*env)->RegisterNatives(env, engine, methods, 3) != JNI_OK) return JNI_ERR;

    /* The experimental JbedService MIDP-class hook was removed from Java.
     * Do not register methods that are no longer declared: ART treats that
     * as an error and rejects the entire compatibility library in JNI_OnLoad.
     * The active JbedEngine hook also handles the string callback fallback. */
    LOGI("registered ART JbedEngine JNI compatibility methods (lifetime + nativeJbedRun quantum hook)");
    return JNI_VERSION_1_6;
}
