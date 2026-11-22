/*
 * Adapt the original ARM32 runtime to its modern Android host.
 *
 * Keep retained JNI objects alive, route Java upcalls through the private host
 * bridge, and apply verified startup repairs for native stack bounds, array
 * ownership, generated-code publication, allocation failure and portable suites.
 * Android's shared JNI table and the original VM file remain unchanged.
 */
#include <dlfcn.h>
#include <jni.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include "jbed_host_jni.h"

#define ENGINE_CLASS "com/esmertec/android/jbed/service/JbedEngine"
#define LEGACY_INIT "Java_android_jbed_service_JbedEngine_nativeInitializeSubsystems"
#define LEGACY_FINI "Java_android_jbed_service_JbedEngine_nativeFinalizeSubsystems"

typedef void (*InitializeSubsystems)(JNIEnv *, jobject, jobjectArray, jint);
typedef void (*FinalizeSubsystems)(JNIEnv *, jobject);

static InitializeSubsystems original_initialize;
static FinalizeSubsystems original_finalize;
static jobject retained_engine;
static pthread_t engine_thread;
static JavaVM *android_vm;
static uintptr_t *legacy_common_stack;
__attribute__((visibility("hidden"))) uintptr_t jbed_rom_base;
__attribute__((visibility("hidden"))) uintptr_t jbed_store_rom_resume;
__attribute__((visibility("hidden"))) uintptr_t jbed_load_rom_resume;
__attribute__((visibility("hidden"))) uintptr_t jbed_write_class_resume;
__attribute__((visibility("hidden"))) uintptr_t jbed_write_pointer_resume;
__attribute__((visibility("hidden"))) uintptr_t jbed_write_code_resume;
__attribute__((visibility("hidden"))) uintptr_t jbed_write_header_resume;
__attribute__((visibility("hidden"))) uintptr_t jbed_header_null_return;
__attribute__((visibility("hidden"))) uintptr_t jbed_throw_null;
__attribute__((visibility("hidden"))) uintptr_t jbed_runtime_state;
__attribute__((visibility("hidden"))) uintptr_t jbed_end_reserved_resume;
extern void jbed_end_reserved_stack(void);
extern void jbed_store_rom_fixup(void);
extern void jbed_load_rom_fixup(void);
extern void jbed_write_rom_class(void);
extern void jbed_write_rom_pointer(void);
extern void jbed_write_rom_code(void);
extern void jbed_write_rom_header(void);

static void throw_exception(JNIEnv *env, const char *name, const char *message) {
    if ((*env)->ExceptionCheck(env)) return;
    jclass type = (*env)->FindClass(env, name);
    if (type != NULL) {
        (*env)->ThrowNew(env, type, message);
        (*env)->DeleteLocalRef(env, type);
    }
}

static void throw_state(JNIEnv *env, const char *message) {
    throw_exception(env, "java/lang/IllegalStateException", message);
}

static int replace_code(uintptr_t address, const void *expected, const void *replacement,
                        size_t size) {
    if (memcmp((void *) address, expected, size) != 0) return -1;
    long page_size = sysconf(_SC_PAGESIZE);
    if (page_size <= 0) return -1;
    uintptr_t first_page = address & ~((uintptr_t) page_size - 1);
    uintptr_t page_end = (address + size + page_size - 1) & ~((uintptr_t) page_size - 1);
    size_t length = page_end - first_page;
    if (mprotect((void *) first_page, length, PROT_READ | PROT_WRITE | PROT_EXEC)) return -1;
    memcpy((void *) address, replacement, size);
    __builtin___clear_cache((char *) address, (char *) address + size);
    return mprotect((void *) first_page, length, PROT_READ | PROT_EXEC);
}

static int redirect_thumb_address(uintptr_t address, const uint8_t expected[8],
                                  void *replacement) {
    if (address & 3) return -1;
    uint32_t branch[] = {0xf000f8df, (uint32_t) (uintptr_t) replacement};
    return replace_code(address, expected, branch, sizeof(branch));
}

/* The VM uses direct calls and its own GOT, so ELF interposition is insufficient.
 * Redirect verified Thumb entries once, before starting the VM. The entry must
 * be word-aligned for the PC-relative literal load. */
static int redirect_thumb(void *library, const char *name, const uint8_t expected[8],
                          void *replacement) {
    uintptr_t symbol = (uintptr_t) dlsym(library, name);
    uintptr_t address = symbol & ~(uintptr_t) 1;
    if (!(symbol & 1) || (address & 3)) return -1;
    /* ldr.w pc, [pc, #0]; .word replacement (including its instruction set bit). */
    return redirect_thumb_address(address, expected, replacement);
}

static int fix_native_stack_restore(uintptr_t base) {
    jbed_runtime_state = base + 0x3200cc;
    jbed_end_reserved_resume = base + 0xe2133;
    /* endUseRuntimeReservedStackSpace must restore zero as the native dummy's
     * regular limit, just as setCurrentScheduled does. A nonzero value left by
     * an external upcall makes the next entry reuse that upcall's stack bounds. */
    static const uint8_t restore_limit[] = {0x0e, 0x4d, 0x69, 0x62, 0x0f, 0x48, 0x40, 0x68,
                                           0x0c, 0x18, 0x28, 0x00, 0x84, 0x62};
    if (memcmp((void *) (base + 0xe2124), restore_limit, sizeof(restore_limit))) return -1;
    return redirect_thumb_address(base + 0xe2124, restore_limit, (void *) jbed_end_reserved_stack);
}

static int enable_portable_suites(uintptr_t base) {
    jbed_rom_base = base;
    jbed_store_rom_resume = base + 0x176109;
    jbed_load_rom_resume = base + 0x16146d;
    jbed_write_class_resume = base + 0x132cfd;
    jbed_write_pointer_resume = base + 0x176fdb;
    jbed_write_code_resume = base + 0x132d97;
    jbed_write_header_resume = base + 0x132dd7;
    jbed_header_null_return = base + 0x132dcf;
    jbed_throw_null = base + 0xe080d;
    static const uint8_t store_entry[] = {0xf0, 0xb5, 0x05, 0xaf, 0x85, 0xb0, 0x06, 0x00};
    static const uint8_t load_entry[] = {0xf0, 0xb5, 0x05, 0xaf, 0x87, 0xb0, 0x06, 0x90};
    if (redirect_thumb_address(base + 0x176100, store_entry, (void *) jbed_store_rom_fixup)
            || redirect_thumb_address(base + 0x161464, load_entry, (void *) jbed_load_rom_fixup)) return -1;

    /* ROM class/string pointers also bypass writeReloc in the original object
     * serializer. Retain virtual dispatch so direct and file writers both work. */
    static const uint8_t class_pointer[] = {0x03, 0x68, 0x5b, 0x6d, 0x29, 0x00, 0x98, 0x47};
    static const uint8_t object_pointer[] = {0x03, 0x68, 0x5b, 0x6d, 0x00, 0x9a, 0x21, 0x00};
    static const uint8_t code_pointer[] = {0x03, 0x68, 0x5b, 0x6d, 0x22, 0x00, 0x29, 0x00};
    static const uint8_t header_pointer[] = {0x32, 0x68, 0x00, 0x28, 0x01, 0xd1, 0xad, 0xf7,
                                           0x1f, 0xfd, 0x03, 0x68};
    if (memcmp((void *) (base + 0x132dc4), header_pointer, sizeof(header_pointer))) return -1;
    if (redirect_thumb_address(base + 0x132cf4, class_pointer, (void *) jbed_write_rom_class)
            || redirect_thumb_address(base + 0x176fd0, object_pointer, (void *) jbed_write_rom_pointer)
            || redirect_thumb_address(base + 0x132d8c, code_pointer, (void *) jbed_write_rom_code)
            || redirect_thumb_address(base + 0x132dc4, header_pointer, (void *) jbed_write_rom_header)) return -1;

    /* Static pointer literals must use the same recorded chains as static calls.
     * MOV r0,r4; MOV r2,r5; MOV r1,r6; MOV r3,#0; BL addStaticCodeFixup. */
    static const uint8_t raw_pointer[] = {0x20, 0x00, 0x03, 0x68, 0x5b, 0x6d,
                                        0x2a, 0x00, 0x31, 0x00, 0x98, 0x47};
    static const uint8_t pointer_fixup[] = {0x20, 0x00, 0x2a, 0x00, 0x31, 0x00,
                                          0x00, 0x23, 0xff, 0xf7, 0xcb, 0xfe};
    if (replace_code(base + 0x17635e, raw_pointer, pointer_fixup, sizeof(raw_pointer))) return -1;

    /* Header word 2 is zero for ROM-relative suites. Keep the existing magic,
     * VM fingerprint and version checks. Old absolute-address suites reject
     * cleanly and must be regenerated from their source JAR. */
    static const uint8_t writer_address[] = {0x89, 0xf7, 0x63, 0xfb};
    static const uint8_t reader_address[] = {0x8a, 0xf7, 0x7f, 0xfb};
    static const uint8_t portable_marker[] = {0x00, 0x20, 0xc0, 0x46};
    return replace_code(base + 0x161a82, writer_address, portable_marker, sizeof(portable_marker))
            || replace_code(base + 0x160a4a, reader_address, portable_marker, sizeof(portable_marker));
}

static void flush_generated_code(char *start, unsigned length) {
    /* Writer.finishBlock passes the newly generated code's start and byte count. */
    __builtin___clear_cache(start, start + length);
}

static int fix_heap_failure_check(void *library) {
    uintptr_t symbol = (uintptr_t) dlsym(library, "OPL_os_getHeapBlock");
    uintptr_t address = symbol & ~(uintptr_t) 1;
    static const uint8_t entry[] = {0xf0, 0xb5, 0x57, 0x46, 0x46, 0x46, 0xc0, 0xb4};
    if (!(symbol & 1) || memcmp((void *) address, entry, sizeof(entry)) != 0) return -1;
    /* At 0xa2ab0: CMP r0,#0 -> ADDS r7,r0,#1. The following BEQ now detects
     * MAP_FAILED (-1); r0 remains unchanged and r7 is overwritten on success. */
    static const uint8_t expected[] = {0x00, 0x28};
    static const uint8_t replacement[] = {0x47, 0x1c};
    return replace_code(address + 0x70, expected, replacement, sizeof(replacement));
}

static int fix_metadata_array_release(void *library) {
    uintptr_t symbol = (uintptr_t) dlsym(library, "android_media_getMetaData");
    uintptr_t address = symbol & ~(uintptr_t) 1;
    static const uint8_t entry[] = {0xf8, 0xb5, 0x5f, 0x46, 0x56, 0x46, 0x4d, 0x46};
    if (!(symbol & 1) || memcmp((void *) address, entry, sizeof(entry))) return -1;

    /* Java returns u8 count followed by UTF-8 key\0value\0 pairs. R9 advances
     * to the payload for memcpy, but JNI must release the original array base.
     * R11 is saved by this function and its earlier player-ID use has ended.
     * MOVS r3,#0; LDRSB r3,[r7,r3] -> MOV r11,r7; LDRB r3,[r7]. */
    static const uint8_t count_load[] = {0x00, 0x23, 0xfb, 0x56};
    static const uint8_t save_base[] = {0xbb, 0x46, 0x3b, 0x78};
    static const uint8_t payload_pointer[] = {0x4a, 0x46};
    static const uint8_t original_pointer[] = {0x5a, 0x46};
    return replace_code(address + 0x9e, count_load, save_base, sizeof(save_base))
            || replace_code(address + 0xd0, payload_pointer, original_pointer, sizeof(original_pointer))
            || replace_code(address + 0xe4, payload_pointer, original_pointer, sizeof(original_pointer));
}

static int contains_roots(const uint8_t *bytes, size_t length, unsigned count) {
    size_t offset = 0;
    for (unsigned i = 0; i < count; ++i) {
        if (offset == length) return 0;
        const uint8_t *end = memchr(bytes + offset, 0, length - offset);
        if (end == NULL || end == bytes + offset) return 0;
        offset = (size_t) (end - bytes) + 1;
    }
    return offset == length;
}

/* android_fc_getRoots (0xa045c) releases an interior array pointer and reads
 * signed length bytes. Consume the Java serialization without pinning an array:
 * u8 count, u16be names length, NUL-terminated names, u16be paths length, paths.
 * The VM caller owns and frees the two resulting malloc allocations. */
static int get_roots(int *count, void **names, void **paths) {
    JNIEnv *env = NULL;
    *count = 0;
    *names = NULL;
    *paths = NULL;
    if ((*android_vm)->GetEnv(android_vm, (void **) &env, JNI_VERSION_1_6) != JNI_OK) return -1;
    env = jbedcompat_current_env(env);
    if ((*env)->PushLocalFrame(env, 4) < 0) return -1;

    int result = -1;
    uint8_t *name_bytes = NULL;
    uint8_t *path_bytes = NULL;
    jclass manager = (*env)->FindClass(env, "com/esmertec/android/jbed/jsr/JbedFileManager");
    if (manager == NULL) goto done;
    jmethodID method = (*env)->GetStaticMethodID(env, manager, "getRoots", "()[B");
    if (method == NULL) goto done;
    jbyteArray encoded = (*env)->CallStaticObjectMethod(env, manager, method);
    if ((*env)->ExceptionCheck(env)) goto done;
    if (encoded == NULL) goto invalid;
    jsize total = (*env)->GetArrayLength(env, encoded);
    if (total < 5) goto invalid;

    uint8_t header[3];
    (*env)->GetByteArrayRegion(env, encoded, 0, 3, (jbyte *) header);
    if ((*env)->ExceptionCheck(env)) goto done;
    unsigned root_count = header[0];
    unsigned names_length = ((unsigned) header[1] << 8) | header[2];
    if (names_length > (unsigned) total - 5) goto invalid;
    uint8_t path_header[2];
    (*env)->GetByteArrayRegion(env, encoded, (jsize) names_length + 3, 2,
                              (jbyte *) path_header);
    if ((*env)->ExceptionCheck(env)) goto done;
    unsigned paths_length = ((unsigned) path_header[0] << 8) | path_header[1];
    if (names_length + paths_length + 5 != (unsigned) total) goto invalid;
    if (root_count == 0) {
        if (names_length != 0 || paths_length != 0) goto invalid;
        result = 0;
        goto done;
    }
    if (names_length < root_count || paths_length < root_count) goto invalid;
    name_bytes = malloc(names_length);
    path_bytes = malloc(paths_length);
    if (name_bytes == NULL || path_bytes == NULL) {
        throw_exception(env, "java/lang/OutOfMemoryError", "Cannot allocate Jbed file roots");
        goto done;
    }
    (*env)->GetByteArrayRegion(env, encoded, 3, (jsize) names_length, (jbyte *) name_bytes);
    if ((*env)->ExceptionCheck(env)) goto done;
    (*env)->GetByteArrayRegion(env, encoded, (jsize) names_length + 5,
                              (jsize) paths_length, (jbyte *) path_bytes);
    if ((*env)->ExceptionCheck(env)) goto done;
    if (!contains_roots(name_bytes, names_length, root_count)
            || !contains_roots(path_bytes, paths_length, root_count)) goto invalid;
    *count = (int) root_count;
    *names = name_bytes;
    *paths = path_bytes;
    name_bytes = NULL;
    path_bytes = NULL;
    result = 0;
    goto done;

invalid:
    throw_exception(env, "java/lang/IllegalArgumentException", "Invalid Jbed file-root serialization");
done:
    free(name_bytes);
    free(path_bytes);
    (*env)->PopLocalFrame(env, NULL);
    return result;
}

static void JNICALL initialize_subsystems(JNIEnv *env, jobject engine,
                                         jobjectArray arguments, jint quantum) {
    if (retained_engine != NULL) {
        throw_state(env, "The Jbed VM is already initialized");
        return;
    }
    if (jbed_host_jni_initialize(env, legacy_common_stack) != 0) {
        throw_state(env, "Cannot identify Jbed's native thread stack");
        return;
    }

    jobject global_engine = (*env)->NewGlobalRef(env, engine);
    if (global_engine == NULL) {
        jbed_host_jni_finalize();
        return;
    }
    retained_engine = global_engine;
    engine_thread = pthread_self();

    /* At 0xa0bf0 the VM saves this argument to its engine slot at 0x31c864.
     * Its command-line array is consumed during this call and is not retained. */
    original_initialize(jbedcompat_current_env(env), global_engine, arguments, quantum);
    if ((*env)->ExceptionCheck(env)) {
        (*env)->DeleteGlobalRef(env, global_engine);
        retained_engine = NULL;
        jbed_host_jni_finalize();
    }
}

static void JNICALL finalize_subsystems(JNIEnv *env, jobject engine) {
    if (retained_engine == NULL) return;
    if (!pthread_equal(pthread_self(), engine_thread)
            || !(*env)->IsSameObject(env, engine, retained_engine)) {
        throw_state(env, "Finalize the Jbed VM on its owning JbedThread");
        return;
    }

    /* Teardown can still make VM upcalls, so release the reference afterward. */
    original_finalize(env, retained_engine);
    (*env)->DeleteGlobalRef(env, retained_engine);
    retained_engine = NULL;
    jbed_host_jni_finalize();
}

/* Media callbacks run between native iterations on JbedThread. Java removes
 * the exact pending player before calling this, so a late callback cannot use
 * a context that OP_CLOSE has released. */
JNIEXPORT void JNICALL
Java_com_esmertec_android_jbed_jsr_JbedMediaManager_nativeNotifyMediaCreateFailed(
        JNIEnv *env, jclass type, jint native_context) {
    (void) env;
    (void) type;
    uint32_t *context = (uint32_t *) (uintptr_t) (uint32_t) native_context;
    if (context == NULL || context[3] == 0) return;
    uintptr_t notifier = context[3];
    context[3] = 0;

    /* CPL_media_prepareDev returns this result when its notifier resumes.
     * Match its immediate failure path: URL players (type 88) have no generated
     * file; other types use the original temp-file remover, then free the
     * malloc-owned 28-byte context before waking the waiting Jbed thread. */
    *(uint32_t *) (jbed_rom_base + 0x31edc4) = 0;
    if (context[1] != 88) {
        int (*remove_media_file)(void *) =
                (int (*)(void *)) (jbed_rom_base + 0xa7595);
        remove_media_file(context);
    }
    free(context);
    int (*notify)(uintptr_t) = (int (*)(uintptr_t)) (jbed_rom_base + 0x2bd74d);
    notify(notifier);
}

JNIEXPORT void JNICALL
Java_com_esmertec_android_jbed_jsr_JbedMediaManager_nativeNotifyMediaError(
        JNIEnv *env, jclass type, jint native_context, jint error_code) {
    (void) env;
    (void) type;
    /* Media event 0 becomes PlayerListener.ERROR in CoreBasicPlayer. The
     * prepared player retains its context until the ordinary OP_CLOSE path. */
    int (*send_event)(uint32_t, int, int) =
            (int (*)(uint32_t, int, int)) (jbed_rom_base + 0x2ca5b1);
    send_event((uint32_t) native_context, 0, error_code);
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    (void) reserved;
    JNIEnv *env = NULL;
    if ((*vm)->GetEnv(vm, (void **) &env, JNI_VERSION_1_6) != JNI_OK) return JNI_ERR;
    android_vm = vm;

    /* JbedService loads the original VM first. Keep this handle for the
     * process lifetime: its registered methods and callbacks remain in use. */
    void *library = dlopen("libjbedvm.so", RTLD_NOW | RTLD_LOCAL);
    if (library == NULL) return JNI_ERR;
    original_initialize = (InitializeSubsystems) dlsym(library, LEGACY_INIT);
    original_finalize = (FinalizeSubsystems) dlsym(library, LEGACY_FINI);
    if (original_initialize == NULL || original_finalize == NULL) {
        dlclose(library);
        return JNI_ERR;
    }
    uintptr_t vm_base = ((uintptr_t) original_initialize & ~(uintptr_t) 1) - 0xa0bf0;
    legacy_common_stack = (uintptr_t *) (vm_base + 0x3200e4);
    static const uint8_t roots_entry[] = {0xf0, 0xb5, 0x5f, 0x46, 0x56, 0x46, 0x4d, 0x46};
    static const uint8_t flush_entry[] = {0x10, 0xb5, 0x03, 0x4b, 0x03, 0x4a, 0x7b, 0x44};
    if (redirect_thumb(library, "android_fc_getRoots", roots_entry, (void *) get_roots) != 0
            || redirect_thumb(library, "OPL_os_intern_flushCache", flush_entry,
                              (void *) flush_generated_code) != 0
            || fix_heap_failure_check(library) != 0
            || fix_metadata_array_release(library) != 0
            || enable_portable_suites(vm_base) != 0
            || fix_native_stack_restore(vm_base) != 0) {
        dlclose(library);
        return JNI_ERR;
    }
    /* Scheduler.<clinit> caches its logging flag. Keep Config.amsDebug's other
     * policy users unchanged, and avoid constructing scheduler trace strings. */
    static const uint8_t debug_call[] = {0xf3, 0xf7, 0xca, 0xfb};
    static const uint8_t debug_off[] = {0x00, 0x20, 0xc0, 0x46};
    if (replace_code(vm_base + 0x102acc, debug_call, debug_off, sizeof(debug_off)) != 0) {
        dlclose(library);
        return JNI_ERR;
    }

    jclass engine = (*env)->FindClass(env, ENGINE_CLASS);
    if (engine == NULL) {
        dlclose(library);
        return JNI_ERR;
    }
    const JNINativeMethod methods[] = {
        {"nativeInitializeSubsystems", "([Ljava/lang/String;I)V", (void *) initialize_subsystems},
        {"nativeFinalizeSubsystems", "()V", (void *) finalize_subsystems},
    };
    jint result = (*env)->RegisterNatives(env, engine, methods,
                                        (jint) (sizeof(methods) / sizeof(methods[0])));
    (*env)->DeleteLocalRef(env, engine);
    if (result != JNI_OK) {
        dlclose(library);
        return JNI_ERR;
    }
    return JNI_VERSION_1_6;
}
