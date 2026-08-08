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
#include <errno.h>
#include <dlfcn.h>
#include <link.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

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
static jmethodID g_vm_state_change_method;
static jmethodID g_midp_get_string_method;
static jmethodID g_file_get_roots_method;

static uintptr_t g_jbed_base;
static jobject g_promoted_engine;

/*
 * The Java method nativeJbedRun() in libjbedvm is only a tiny wrapper around
 * Jbed_run(50). Quantum 20 is the lowest value accepted by libjbedvm during
 * NativeAms bootstrap; lower values trip an internal assertion before the AMS
 * foreground transition. After Java observes that foreground transition, the
 * Java side calls nativeEnableLowSchedulerQuantum() so event processing can use
 * a one-step quantum and avoid the deep zero-delay scheduler recursion seen on
 * ART/Android 11.
 */
#define JBED_NATIVE_JBED_RUN_MOV_IMM_OFFSET 0x0a0ac2u
#define JBED_NATIVE_JBED_RUN_LEGACY_QUANTUM 50u
#define JBED_NATIVE_JBED_RUN_STARTUP_QUANTUM 20u
#define JBED_NATIVE_JBED_RUN_LOW_QUANTUM 1u
#define JBED_NATIVE_JBED_RUN_MOV_R0_LEGACY ((uint16_t) (0x2000u | JBED_NATIVE_JBED_RUN_LEGACY_QUANTUM))
#define JBED_NATIVE_JBED_RUN_MOV_R0_STARTUP ((uint16_t) (0x2000u | JBED_NATIVE_JBED_RUN_STARTUP_QUANTUM))
#define JBED_NATIVE_JBED_RUN_MOV_R0_LOW ((uint16_t) (0x2000u | JBED_NATIVE_JBED_RUN_LOW_QUANTUM))

#define JBED_ITERATE_MIN_QUANTUM_CMP_OFFSET 0x0f1718u
#define JBED_ITERATE_CMP_R1_20 0x2914u
#define JBED_ITERATE_CMP_R1_LOW ((uint16_t) (0x2900u | JBED_NATIVE_JBED_RUN_LOW_QUANTUM))

static int g_patched_startup_jbed_run_quantum;
static int g_patched_low_jbed_run_quantum;

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

static int write_thumb16_instruction(uintptr_t offset, uint16_t replacement,
                                      const char *description) {
    uint16_t *instruction = (uint16_t *) (g_jbed_base + offset);
    long page_size_long;
    size_t page_size;
    uintptr_t page;

    page_size_long = sysconf(_SC_PAGESIZE);
    page_size = page_size_long > 0 ? (size_t) page_size_long : 4096u;
    page = ((uintptr_t) instruction) & ~(uintptr_t) (page_size - 1u);
    if (mprotect((void *) page, page_size, PROT_READ | PROT_WRITE | PROT_EXEC) != 0) {
        LOGE("mprotect RWX failed while patching %s: errno=%d", description, errno);
        return 0;
    }

    *instruction = replacement;
    __builtin___clear_cache((char *) instruction, (char *) instruction + sizeof(*instruction));

    if (mprotect((void *) page, page_size, PROT_READ | PROT_EXEC) != 0) {
        LOGE("mprotect RX restore failed after %s patch: errno=%d", description, errno);
    }
    return 1;
}

static int patch_thumb16_instruction(uintptr_t offset, uint16_t expected, uint16_t replacement,
                                      const char *description) {
    uint16_t *instruction = (uint16_t *) (g_jbed_base + offset);
    uint16_t current = *instruction;

    if (current == replacement) {
        LOGI("%s patch already active", description);
        return 1;
    }
    if (current != expected) {
        LOGE("unexpected %s instruction 0x%04x at %p; not patching",
             description, current, instruction);
        return 0;
    }
    return write_thumb16_instruction(offset, replacement, description);
}

static int patch_thumb16_instruction_from_either(uintptr_t offset, uint16_t expected_a,
                                                  uint16_t expected_b, uint16_t replacement,
                                                  const char *description) {
    uint16_t *instruction = (uint16_t *) (g_jbed_base + offset);
    uint16_t current = *instruction;

    if (current == replacement) {
        LOGI("%s patch already active", description);
        return 1;
    }
    if (current != expected_a && current != expected_b) {
        LOGE("unexpected %s instruction 0x%04x at %p; not patching",
             description, current, instruction);
        return 0;
    }
    return write_thumb16_instruction(offset, replacement, description);
}

static void patch_native_jbed_run_startup_quantum(void) {
    if (g_patched_startup_jbed_run_quantum) return;

    ensure_jbed_base();
    if (g_jbed_base == 0) {
        LOGE("libjbedvm.so is not loaded; cannot patch nativeJbedRun startup quantum");
        return;
    }

    if (patch_thumb16_instruction(JBED_NATIVE_JBED_RUN_MOV_IMM_OFFSET,
                                  JBED_NATIVE_JBED_RUN_MOV_R0_LEGACY,
                                  JBED_NATIVE_JBED_RUN_MOV_R0_STARTUP,
                                  "nativeJbedRun startup quantum")) {
        g_patched_startup_jbed_run_quantum = 1;
        LOGI("patched libjbedvm startup scheduler quantum: Jbed_run(%u) -> Jbed_run(%u)",
             JBED_NATIVE_JBED_RUN_LEGACY_QUANTUM, JBED_NATIVE_JBED_RUN_STARTUP_QUANTUM);
    }
}

JNIEXPORT void JNICALL
Java_com_esmertec_android_jbed_service_JbedEngine_nativeEnableLowSchedulerQuantum(JNIEnv *env, jclass clazz) {
    (void) env;
    (void) clazz;
    int wrapper_ok;
    int guard_ok;

    if (g_patched_low_jbed_run_quantum) return;

    ensure_jbed_base();
    if (g_jbed_base == 0) {
        LOGE("libjbedvm.so is not loaded; cannot enable low scheduler quantum");
        return;
    }

    wrapper_ok = patch_thumb16_instruction_from_either(JBED_NATIVE_JBED_RUN_MOV_IMM_OFFSET,
                                                       JBED_NATIVE_JBED_RUN_MOV_R0_STARTUP,
                                                       JBED_NATIVE_JBED_RUN_MOV_R0_LEGACY,
                                                       JBED_NATIVE_JBED_RUN_MOV_R0_LOW,
                                                       "nativeJbedRun low quantum");
    guard_ok = patch_thumb16_instruction(JBED_ITERATE_MIN_QUANTUM_CMP_OFFSET,
                                         JBED_ITERATE_CMP_R1_20,
                                         JBED_ITERATE_CMP_R1_LOW,
                                         "Jbed_iterate low-quantum guard");
    if (wrapper_ok && guard_ok) {
        g_patched_low_jbed_run_quantum = 1;
        LOGI("lowered libjbedvm scheduler quantum after foreground: Jbed_run(%u) -> Jbed_run(%u), guard >=20 -> >=%u",
             JBED_NATIVE_JBED_RUN_STARTUP_QUANTUM, JBED_NATIVE_JBED_RUN_LOW_QUANTUM,
             JBED_NATIVE_JBED_RUN_LOW_QUANTUM);
    }
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
        g_vm_state_change_method = result;
        promote_engine_reference(env);
        /* Keep this cloned table active: the VM later performs unsafe static
         * JbedMidpManager string callbacks on the same JbedThread. */
    }
    return result;
}

static void maybe_enable_low_quantum_for_vm_state(JNIEnv *env, jmethodID method,
                                                   jboolean commit, jint old_state,
                                                   jint new_state, jint reason) {
    (void) old_state;
    (void) reason;
    if (g_vm_state_change_method != NULL && method == g_vm_state_change_method &&
        commit && new_state == 3 && !g_patched_low_jbed_run_quantum) {
        LOGI("vmStateChange foreground commit intercepted; lowering scheduler quantum before returning to VM");
        Java_com_esmertec_android_jbed_service_JbedEngine_nativeEnableLowSchedulerQuantum(env, NULL);
    }
}

static jboolean JNICALL hooked_call_boolean_method(JNIEnv *env, jobject obj, jmethodID method, ...) {
    va_list args;
    jboolean result;

    clear_pending_exception(env);
    va_start(args, method);
    if (g_vm_state_change_method != NULL && method == g_vm_state_change_method) {
        va_list inspect;
        jboolean commit;
        jint old_state;
        jint new_state;
        jint reason;

        va_copy(inspect, args);
        commit = (jboolean) va_arg(inspect, int);
        old_state = va_arg(inspect, jint);
        new_state = va_arg(inspect, jint);
        reason = va_arg(inspect, jint);
        va_end(inspect);
        maybe_enable_low_quantum_for_vm_state(env, method, commit, old_state, new_state, reason);
    }
    result = g_original_table->CallBooleanMethodV(env, obj, method, args);
    va_end(args);
    return result;
}

static jboolean JNICALL hooked_call_boolean_method_v(JNIEnv *env, jobject obj, jmethodID method, va_list args) {
    clear_pending_exception(env);
    if (g_vm_state_change_method != NULL && method == g_vm_state_change_method) {
        va_list inspect;
        jboolean commit;
        jint old_state;
        jint new_state;
        jint reason;

        va_copy(inspect, args);
        commit = (jboolean) va_arg(inspect, int);
        old_state = va_arg(inspect, jint);
        new_state = va_arg(inspect, jint);
        reason = va_arg(inspect, jint);
        va_end(inspect);
        maybe_enable_low_quantum_for_vm_state(env, method, commit, old_state, new_state, reason);
    }
    return g_original_table->CallBooleanMethodV(env, obj, method, args);
}

static jboolean JNICALL hooked_call_boolean_method_a(JNIEnv *env, jobject obj, jmethodID method, const jvalue *args) {
    clear_pending_exception(env);
    if (g_vm_state_change_method != NULL && method == g_vm_state_change_method && args != NULL) {
        maybe_enable_low_quantum_for_vm_state(env, method, args[0].z, args[1].i, args[2].i, args[3].i);
    }
    return g_original_table->CallBooleanMethodA(env, obj, method, args);
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

static int is_directory(const char *path) {
    struct stat st;
    return path != NULL && stat(path, &st) == 0 && S_ISDIR(st.st_mode);
}

static const char *choose_external_storage_root(void) {
    static const char *candidates[] = {
        "/storage/emulated/0",
        "/sdcard",
        "/mnt/sdcard",
    };
    size_t i;
    const char *env_root = getenv("EXTERNAL_STORAGE");
    if (is_directory(env_root)) return env_root;
    for (i = 0; i < sizeof(candidates) / sizeof(candidates[0]); ++i) {
        if (is_directory(candidates[i])) return candidates[i];
    }
    return "/sdcard";
}

static jobject make_legacy_roots(JNIEnv *env) {
    static const char root_name[] = "sdcard/";
    const char *root_path = choose_external_storage_root();
    char path_with_slash[256];
    size_t root_name_len = sizeof(root_name); /* includes NUL terminator */
    size_t root_path_len = strlen(root_path);
    size_t payload_len;
    jbyteArray roots;
    jbyte *payload;

    if (root_path_len + 2 > sizeof(path_with_slash)) {
        root_path = "/sdcard";
        root_path_len = strlen(root_path);
    }
    memcpy(path_with_slash, root_path, root_path_len);
    if (root_path_len == 0 || path_with_slash[root_path_len - 1] != '/') {
        path_with_slash[root_path_len++] = '/';
    }
    path_with_slash[root_path_len++] = '\0';

    payload_len = 1 + 2 + root_name_len + 2 + root_path_len;
    payload = (jbyte *) malloc(payload_len);
    if (payload == NULL) {
        LOGE("unable to allocate legacy root payload");
        return NULL;
    }

    payload[0] = 1; /* root count */
    payload[1] = (jbyte) ((root_name_len >> 8) & 0xff);
    payload[2] = (jbyte) (root_name_len & 0xff);
    memcpy(payload + 3, root_name, root_name_len);
    payload[3 + root_name_len] = (jbyte) ((root_path_len >> 8) & 0xff);
    payload[4 + root_name_len] = (jbyte) (root_path_len & 0xff);
    memcpy(payload + 5 + root_name_len, path_with_slash, root_path_len);

    LOGI("providing legacy JbedFileManager root: %s -> %s", root_name, path_with_slash);
    roots = (*env)->NewByteArray(env, (jsize) payload_len);
    if (roots != NULL) {
        (*env)->SetByteArrayRegion(env, roots, 0, (jsize) payload_len, payload);
    }
    free(payload);
    return roots;
}

static jobject JNICALL hooked_call_static_object_method(JNIEnv *env, jclass clazz, jmethodID method, ...) {
    clear_pending_exception(env);
    if (g_midp_get_string_method != NULL && method == g_midp_get_string_method) {
        return (*env)->NewStringUTF(env, "<unknown>");
    }
    if (g_file_get_roots_method != NULL && method == g_file_get_roots_method) {
        return make_legacy_roots(env);
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
        return make_legacy_roots(env);
    }
    return g_original_table->CallStaticObjectMethodV(env, clazz, method, args);
}

static jobject JNICALL hooked_call_static_object_method_a(JNIEnv *env, jclass clazz, jmethodID method, const jvalue *args) {
    clear_pending_exception(env);
    if (g_midp_get_string_method != NULL && method == g_midp_get_string_method) {
        return (*env)->NewStringUTF(env, "<unknown>");
    }
    if (g_file_get_roots_method != NULL && method == g_file_get_roots_method) {
        return make_legacy_roots(env);
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
    patch_native_jbed_run_startup_quantum();

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
    g_hook_table->CallBooleanMethod = hooked_call_boolean_method;
    g_hook_table->CallBooleanMethodV = hooked_call_boolean_method_v;
    g_hook_table->CallBooleanMethodA = hooked_call_boolean_method_a;
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
    g_vm_state_change_method = NULL;
    g_midp_get_string_method = NULL;
    g_file_get_roots_method = NULL;
    g_jbed_base = 0;
    g_patched_startup_jbed_run_quantum = 0;
    g_patched_low_jbed_run_quantum = 0;
}

/* Explicit registration avoids relying on ART's cross-library native symbol
 * lookup order after libjbedvm.so has registered its own methods. */
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    (void) reserved;
    JNIEnv *env = NULL;
    if ((*vm)->GetEnv(vm, (void **) &env, JNI_VERSION_1_6) != JNI_OK) return JNI_ERR;

    ensure_jbed_base();
    patch_native_jbed_run_startup_quantum();

    jclass engine = (*env)->FindClass(env, "com/esmertec/android/jbed/service/JbedEngine");
    if (engine == NULL) return JNI_ERR;
    JNINativeMethod methods[] = {
        {"nativeInstallJniLifetimeHook", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedEngine_nativeInstallJniLifetimeHook},
        {"nativeReleaseJniLifetimeHook", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedEngine_nativeReleaseJniLifetimeHook},
        {"nativeEnableLowSchedulerQuantum", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedEngine_nativeEnableLowSchedulerQuantum},
    };
    if ((*env)->RegisterNatives(env, engine, methods, 3) != JNI_OK) return JNI_ERR;

    /* The experimental JbedService MIDP-class hook was removed from Java.
     * Do not register methods that are no longer declared: ART treats that
     * as an error and rejects the entire compatibility library in JNI_OnLoad.
     * The active JbedEngine hook also handles the string callback fallback. */
    LOGI("registered ART JbedEngine JNI compatibility methods (lifetime + staged scheduler quantum patch)");
    return JNI_VERSION_1_6;
}
