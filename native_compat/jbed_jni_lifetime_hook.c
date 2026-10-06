#define _GNU_SOURCE

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
#include <fcntl.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/system_properties.h>
#include <ucontext.h>
#include <unistd.h>

#define LOG_TAG "jbed-jni-compat"
#define JBED_PUBLIC_LOG_DIR "/storage/emulated/0/jbedfix"
#define JBED_NATIVE_LOG_PATH JBED_PUBLIC_LOG_DIR "/native.log"
#define JBED_DISABLE_STARTUP_PATCH_MARKER JBED_PUBLIC_LOG_DIR "/disable-startup-quantum.patch"

/*
 * The Android log buffer is not available on every test device. Keep the
 * compatibility shim's decisions in the same user-visible directory as the
 * Java diagnostic log. Java creates this directory first; mkdir is repeated
 * here because the VM runs in the :remote process and must also work when the
 * directory was removed between launches.
 */
static void native_file_log(int priority, const char *format, ...) {
    char message[2048];
    char line[2200];
    va_list args;
    int length;
    int fd;
    struct stat file_stat;

    va_start(args, format);
    vsnprintf(message, sizeof(message), format, args);
    va_end(args);
    mkdir(JBED_PUBLIC_LOG_DIR, 0775);

    if (stat(JBED_NATIVE_LOG_PATH, &file_stat) == 0 && file_stat.st_size >= (4 * 1024 * 1024)) {
        unlink(JBED_PUBLIC_LOG_DIR "/native.log.previous");
        rename(JBED_NATIVE_LOG_PATH, JBED_PUBLIC_LOG_DIR "/native.log.previous");
    }
    length = snprintf(line, sizeof(line), "%s/%s %s\n",
                       priority == ANDROID_LOG_ERROR ? "E" : "I", LOG_TAG, message);
    if (length < 0) return;
    if (length > (int) sizeof(line)) length = (int) sizeof(line);
    fd = open(JBED_NATIVE_LOG_PATH, O_WRONLY | O_CREAT | O_APPEND, 0664);
    if (fd >= 0) {
        write(fd, line, (size_t) length);
        close(fd);
    }
    __android_log_print(priority, LOG_TAG, "%s", message);
}

#define LOGE(...) native_file_log(ANDROID_LOG_ERROR, __VA_ARGS__)
#define LOGI(...) native_file_log(ANDROID_LOG_INFO, __VA_ARGS__)

/* A native signal does not reach Java's uncaught-exception handler. Leave a
 * small async-signal-safe marker before re-raising it so Android still creates
 * its normal tombstone while devices without logcat retain the crash reason. */
static volatile sig_atomic_t g_crash_handler_active;
static uintptr_t g_jbed_base;

static size_t append_decimal(char *buffer, size_t offset, size_t capacity, unsigned long value) {
    char digits[24];
    size_t count = 0;
    if (value == 0) {
        if (offset < capacity) buffer[offset++] = '0';
        return offset;
    }
    while (value != 0 && count < sizeof(digits)) {
        digits[count++] = (char) ('0' + (value % 10));
        value /= 10;
    }
    while (count > 0 && offset < capacity) {
        buffer[offset++] = digits[--count];
    }
    return offset;
}

static size_t append_hex(char *buffer, size_t offset, size_t capacity, uintptr_t value) {
    static const char hex[] = "0123456789abcdef";
    char digits[2 * sizeof(uintptr_t)];
    size_t count = 0;
    if (value == 0) {
        if (offset < capacity) buffer[offset++] = '0';
        return offset;
    }
    while (value != 0 && count < sizeof(digits)) {
        digits[count++] = hex[value & 0xfu];
        value >>= 4;
    }
    while (count > 0 && offset < capacity) {
        buffer[offset++] = digits[--count];
    }
    return offset;
}

static uintptr_t crash_pc(void *context) {
    if (context == NULL) return 0;
#if defined(__arm__)
    return (uintptr_t) ((ucontext_t *) context)->uc_mcontext.arm_pc;
#elif defined(__aarch64__)
    return (uintptr_t) ((ucontext_t *) context)->uc_mcontext.pc;
#elif defined(__i386__)
    return (uintptr_t) ((ucontext_t *) context)->uc_mcontext.gregs[REG_EIP];
#elif defined(__x86_64__)
    return (uintptr_t) ((ucontext_t *) context)->uc_mcontext.gregs[REG_RIP];
#else
    return 0;
#endif
}

static uintptr_t crash_sp(void *context) {
    if (context == NULL) return 0;
#if defined(__arm__)
    return (uintptr_t) ((ucontext_t *) context)->uc_mcontext.arm_sp;
#elif defined(__aarch64__)
    return (uintptr_t) ((ucontext_t *) context)->uc_mcontext.sp;
#elif defined(__i386__)
    return (uintptr_t) ((ucontext_t *) context)->uc_mcontext.gregs[REG_ESP];
#elif defined(__x86_64__)
    return (uintptr_t) ((ucontext_t *) context)->uc_mcontext.gregs[REG_RSP];
#else
    return 0;
#endif
}

static size_t append_marker_hex(char *buffer, size_t offset, size_t capacity,
                                const char *marker, size_t marker_length,
                                uintptr_t value) {
    memcpy(buffer + offset, marker, marker_length);
    offset += marker_length;
    return append_hex(buffer, offset, capacity, value);
}

static void native_crash_signal_handler(int signal_number, siginfo_t *signal_info, void *context) {
    static const char prefix[] = "FATAL/jbed-jni-compat native signal=";
    static const char address_marker[] = " address=0x";
    static const char newline[] = "\n";
    char line[320];
    size_t length = 0;
    int fd;
    uintptr_t pc;
    uintptr_t vm_base;

    if (g_crash_handler_active) _exit(128 + signal_number);
    g_crash_handler_active = 1;
    pc = crash_pc(context);
    vm_base = g_jbed_base;
    memcpy(line + length, prefix, sizeof(prefix) - 1);
    length += sizeof(prefix) - 1;
    length = append_decimal(line, length, sizeof(line), (unsigned long) signal_number);
    memcpy(line + length, address_marker, sizeof(address_marker) - 1);
    length += sizeof(address_marker) - 1;
    length = append_hex(line, length, sizeof(line),
                        signal_info == NULL ? 0 : (uintptr_t) signal_info->si_addr);
    length = append_marker_hex(line, length, sizeof(line), " pc=0x", sizeof(" pc=0x") - 1,
                               crash_pc(context));
    length = append_marker_hex(line, length, sizeof(line), " sp=0x", sizeof(" sp=0x") - 1,
                               crash_sp(context));
    length = append_marker_hex(line, length, sizeof(line), " vmBase=0x", sizeof(" vmBase=0x") - 1,
                               vm_base);
    if (vm_base != 0 && pc >= vm_base) {
        length = append_marker_hex(line, length, sizeof(line), " vmPcOffset=0x",
                                   sizeof(" vmPcOffset=0x") - 1,
                                   (pc & ~(uintptr_t) 1u) - vm_base);
    }
    memcpy(line + length, newline, sizeof(newline) - 1);
    length += sizeof(newline) - 1;

    fd = open(JBED_PUBLIC_LOG_DIR "/native-crash.log", O_WRONLY | O_CREAT | O_APPEND, 0664);
    if (fd >= 0) {
        (void) write(fd, line, length);
        close(fd);
    }
    signal(signal_number, SIG_DFL);
    raise(signal_number);
    _exit(128 + signal_number);
}

static void install_native_crash_handlers(void) {
    static const int signals[] = {SIGSEGV, SIGABRT, SIGBUS, SIGILL, SIGFPE};
    struct sigaction action;
    size_t i;

    memset(&action, 0, sizeof(action));
    sigemptyset(&action.sa_mask);
    action.sa_sigaction = native_crash_signal_handler;
    action.sa_flags = SA_SIGINFO | SA_RESETHAND;
    for (i = 0; i < sizeof(signals) / sizeof(signals[0]); ++i) {
        sigaction(signals[i], &action, NULL);
    }
}

/* dword_31C864 in the original ELF; its first LOAD segment has vaddr zero. */
#define JBED_ENGINE_LOCAL_REF_OFFSET 0x31c864u

#define JBED_NATIVE_CALL_STATE_ADR_OFFSET 0x3200c8u
#define JBED_NATIVE_CALL_STATE_BASE_OFFSET 0x3200ccu
#define JBED_NATIVE_CALL_STATE_LIMIT_OFFSET 0x3200d0u
#define JBED_NATIVE_CALL_STATE_FRAME_OFFSET 0x3200d4u
#define JBED_STACK_OVERFLOW_DELTA_OFFSET 0x3200ecu
#define JBED_FATAL_ERROR_PC_OFFSET 0x3200f0u
#define JBED_FATAL_ERROR_SP_OFFSET 0x3200f4u
#define JBED_FATAL_ERROR_PENDING_OFFSET 0x3200f8u
#define JBED_VM_NATIVE_ACTIVE_OFFSET 0x320160u
#define JBED_AMS_UPCALL_QUEUE_OFFSET 0x31edc0u
#define JBED_EVENT_HANDLER_TABLE_OFFSET 0x320068u
#define JBED_EVENT_HANDLER_MASK_OFFSET 0x320170u
#define JBED_CURRENT_SCHEDULED_OFFSET 0x3200a8u
#define JBED_SCHEDULED_COUNT_OFFSET 0x320228u
#define JBED_WAITING_SCHEDULED_COUNT_OFFSET 0x32022cu
#define JBED_UPCALL_QUEUE_LIST_OFFSET 0x320320u

/* NDK's C jni.h names this structure JNINativeInterface (without the
 * trailing underscore used by some platform headers). */
static const struct JNINativeInterface *g_original_table;
static struct JNINativeInterface *g_hook_table;
static jmethodID (*g_original_get_method_id)(JNIEnv *, jclass, const char *, const char *);
static jmethodID g_vm_state_change_method;
static jmethodID g_midp_get_string_method;
static jmethodID g_file_get_roots_method;

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
#define JBED_ITERATE_RUN_BODY_QUANTUM_CMP_OFFSET 0x0f17a2u
#define JBED_ITERATE_CMP_R1_20 0x2914u
#define JBED_ITERATE_CMP_R0_20 0x2814u
#define JBED_ITERATE_CMP_R1_LOW ((uint16_t) (0x2900u | JBED_NATIVE_JBED_RUN_LOW_QUANTUM))
#define JBED_ITERATE_CMP_R0_LOW ((uint16_t) (0x2800u | JBED_NATIVE_JBED_RUN_LOW_QUANTUM))

static int g_patched_startup_jbed_run_quantum;
static int g_patched_low_jbed_run_quantum;

typedef const char *(*jbed_request_install_fn)(const char *url);
typedef void (*jbed_request_local_install_fn)(char *url, char *jad_url);
typedef int (*jbed_upcall_poll_fn)(void);
static jbed_request_install_fn g_jbed_request_install;
static jbed_request_local_install_fn g_jbed_request_local_install;
static jbed_upcall_poll_fn g_jbed_upcall_poll;

static void clear_pending_exception(JNIEnv *env);
static void dump_scheduler_state(const char *label);

static int get_android_api_level(void) {
    char sdk[PROP_VALUE_MAX];
    int len = __system_property_get("ro.build.version.sdk", sdk);
    if (len <= 0) return 0;
    return atoi(sdk);
}

static int use_modern_art_scheduler_workarounds(void) {
    int api_level = get_android_api_level();
    return api_level == 0 || api_level >= 21;
}

static void ensure_jbed_base(void) {
    FILE *maps;
    char line[512];
    uintptr_t best = UINTPTR_MAX;

    if (g_jbed_base != 0) return;

    /* dl_iterate_phdr is not available on Android 4.4/API 19, and dladdr is
     * not consistently exposed by old NDK levels. /proc/self/maps is stable
     * enough for this diagnostic compatibility shim and keeps the API-19 build
     * path usable. Pick the lowest mapped address for libjbedvm.so; this ELF's
     * first LOAD segment has p_vaddr == p_offset == 0, so it is the base used
     * by all offsets below. */
    maps = fopen("/proc/self/maps", "r");
    if (maps == NULL) {
        LOGE("unable to open /proc/self/maps while locating libjbedvm base: errno=%d", errno);
        return;
    }
    while (fgets(line, sizeof(line), maps) != NULL) {
        unsigned long start;
        if (strstr(line, "libjbedvm.so") == NULL) continue;
        if (sscanf(line, "%lx-", &start) == 1 && (uintptr_t) start < best) {
            best = (uintptr_t) start;
        }
    }
    fclose(maps);

    if (best != UINTPTR_MAX) {
        g_jbed_base = best;
    } else {
        LOGE("libjbedvm.so mapping not found in /proc/self/maps");
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

    if (access(JBED_DISABLE_STARTUP_PATCH_MARKER, F_OK) == 0) {
        g_patched_startup_jbed_run_quantum = 1;
        LOGI("startup scheduler patch disabled by marker %s; leaving Jbed_run(50) unchanged",
             JBED_DISABLE_STARTUP_PATCH_MARKER);
        return;
    }

    if (!use_modern_art_scheduler_workarounds()) {
        g_patched_startup_jbed_run_quantum = 1;
        LOGI("leaving legacy Jbed_run(50) scheduler quantum unchanged on Android API %d",
             get_android_api_level());
        return;
    }

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
    int body_ok;

    if (g_patched_low_jbed_run_quantum) return;

    if (!use_modern_art_scheduler_workarounds()) {
        g_patched_low_jbed_run_quantum = 1;
        LOGI("leaving low scheduler quantum patch disabled on Android API %d",
             get_android_api_level());
        return;
    }

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
    body_ok = patch_thumb16_instruction(JBED_ITERATE_RUN_BODY_QUANTUM_CMP_OFFSET,
                                        JBED_ITERATE_CMP_R0_20,
                                        JBED_ITERATE_CMP_R0_LOW,
                                        "Jbed_iterate run-body quantum gate");
    if (wrapper_ok && guard_ok && body_ok) {
        g_patched_low_jbed_run_quantum = 1;
        LOGI("lowered libjbedvm scheduler quantum after foreground: Jbed_run(%u) -> Jbed_run(%u), guard/body >=20 -> >=%u",
             JBED_NATIVE_JBED_RUN_STARTUP_QUANTUM, JBED_NATIVE_JBED_RUN_LOW_QUANTUM,
             JBED_NATIVE_JBED_RUN_LOW_QUANTUM);
    }
}

JNIEXPORT void JNICALL
Java_com_esmertec_android_jbed_service_JbedEngine_nativeRecoverAfterStackOverflow(JNIEnv *env, jclass clazz) {
    (void) env;
    (void) clazz;
    ensure_jbed_base();
    if (g_jbed_base == 0) {
        LOGE("libjbedvm.so is not loaded; cannot recover native scheduler state");
        return;
    }

    uint32_t call_state_base = *(uint32_t *) (g_jbed_base + JBED_NATIVE_CALL_STATE_BASE_OFFSET);
    *(uint8_t *) (g_jbed_base + JBED_VM_NATIVE_ACTIVE_OFFSET) = 0;
    *(uint32_t *) (g_jbed_base + JBED_STACK_OVERFLOW_DELTA_OFFSET) = 0;
    *(uint32_t *) (g_jbed_base + JBED_FATAL_ERROR_PC_OFFSET) = 0;
    *(uint32_t *) (g_jbed_base + JBED_FATAL_ERROR_SP_OFFSET) = 0;
    *(uint32_t *) (g_jbed_base + JBED_FATAL_ERROR_PENDING_OFFSET) = 0;
    if (call_state_base != 0) {
        *(uint32_t *) (g_jbed_base + JBED_NATIVE_CALL_STATE_FRAME_OFFSET) = call_state_base;
        *(uint32_t *) (g_jbed_base + JBED_NATIVE_CALL_STATE_ADR_OFFSET) = call_state_base + 24u;
    } else {
        *(uint32_t *) (g_jbed_base + JBED_NATIVE_CALL_STATE_FRAME_OFFSET) = 0;
        *(uint32_t *) (g_jbed_base + JBED_NATIVE_CALL_STATE_ADR_OFFSET) = 0;
        *(uint32_t *) (g_jbed_base + JBED_NATIVE_CALL_STATE_LIMIT_OFFSET) = 0;
    }
    LOGI("reset libjbedvm native scheduler flags after StackOverflow: callState=0x%08x",
         call_state_base);
    dump_scheduler_state("after-overflow-recover");
}

static uint32_t read_u32(uintptr_t offset) {
    return *(uint32_t *) (g_jbed_base + offset);
}

static uint8_t read_u8(uintptr_t offset) {
    return *(uint8_t *) (g_jbed_base + offset);
}

static void dump_upcall_queue(const char *label, const char *name, uint32_t queue_ptr) {
    int index = 0;
    while (queue_ptr != 0 && index < 4) {
        uint32_t *q = (uint32_t *) queue_ptr;
        LOGI("%s %s[%d]=%p next=%p prio=%u read=%u write=%u cap=%u tmpWrite=%d tmpRead=%d",
             label, name, index, (void *) queue_ptr, (void *) q[0], q[1], q[2], q[3], q[4],
             (int32_t) q[5], (int32_t) q[6]);
        if (q[3] != q[2]) {
            uint32_t pos = q[2];
            LOGI("%s %s[%d] head words: %08x %08x %08x %08x %08x %08x %08x %08x",
                 label, name, index, q[7 + pos], q[7 + ((pos + 1) % q[4])],
                 q[7 + ((pos + 2) % q[4])], q[7 + ((pos + 3) % q[4])],
                 q[7 + ((pos + 4) % q[4])], q[7 + ((pos + 5) % q[4])],
                 q[7 + ((pos + 6) % q[4])], q[7 + ((pos + 7) % q[4])]);
        }
        queue_ptr = q[0];
        ++index;
    }
    if (index == 0) {
        LOGI("%s %s=<null>", label, name);
    }
}

static void dump_event_handlers(const char *label, uint32_t event_id) {
    uint32_t table = read_u32(JBED_EVENT_HANDLER_TABLE_OFFSET);
    uint32_t mask = read_u32(JBED_EVENT_HANDLER_MASK_OFFSET);
    uint32_t bucket;
    uint32_t handler;
    int index = 0;

    if (table == 0) {
        LOGI("%s handlers event=%u table=<null> mask=0x%08x", label, event_id, mask);
        return;
    }
    bucket = event_id & mask;
    LOGI("%s handlers event=%u table=0x%08x len=%u mask=0x%08x bucket=%u",
         label, event_id, table, *(uint32_t *) (table + 12), mask, bucket);
    if (*(uint32_t *) (table + 12) <= bucket) {
        LOGI("%s handlers bucket out of range", label);
        return;
    }
    handler = *(uint32_t *) (table + 16 + 4 * bucket);
    while (handler != 0 && index < 12) {
        uint32_t *h = (uint32_t *) handler;
        LOGI("%s handler[%d]=0x%08x bucket=%u event=%u field6=0x%08x scheduled=0x%08x field8=0x%08x prev=0x%08x next=0x%08x",
             label, index, handler, h[4], h[5], h[6], h[7], h[8], h[9], h[10]);
        handler = h[10];
        ++index;
    }
    if (index == 0) {
        LOGI("%s handlers event=%u bucket empty", label, event_id);
    }
}

static void dump_current_scheduled(const char *label) {
    uint32_t current = read_u32(JBED_CURRENT_SCHEDULED_OFFSET);
    if (current == 0) {
        LOGI("%s currentScheduled=<null>", label);
        return;
    }
    uint32_t *s = (uint32_t *) current;
    LOGI("%s currentScheduled=0x%08x words: %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x",
         label, current, s[0], s[1], s[2], s[3], s[4], s[5], s[6], s[7],
         s[8], s[9], s[10], s[11], s[12], s[13]);
}

static void dump_scheduler_state(const char *label) {
    ensure_jbed_base();
    if (g_jbed_base == 0) return;

    uint32_t call_state_base = read_u32(JBED_NATIVE_CALL_STATE_BASE_OFFSET);
    uint32_t call_state_adr = read_u32(JBED_NATIVE_CALL_STATE_ADR_OFFSET);
    uint32_t call_state_frame = read_u32(JBED_NATIVE_CALL_STATE_FRAME_OFFSET);
    uint32_t ams_queue = read_u32(JBED_AMS_UPCALL_QUEUE_OFFSET);
    uint32_t queue_list = read_u32(JBED_UPCALL_QUEUE_LIST_OFFSET);
    LOGI("%s scheduler: active=%u callBase=0x%08x callAdr=0x%08x callFrame=0x%08x "
         "eventTable=0x%08x current=0x%08x scheduled=%u waiting=%u amsQueue=0x%08x queues=0x%08x",
         label, read_u8(JBED_VM_NATIVE_ACTIVE_OFFSET), call_state_base, call_state_adr,
         call_state_frame, read_u32(JBED_EVENT_HANDLER_TABLE_OFFSET),
         read_u32(JBED_CURRENT_SCHEDULED_OFFSET), read_u32(JBED_SCHEDULED_COUNT_OFFSET),
         read_u32(JBED_WAITING_SCHEDULED_COUNT_OFFSET), ams_queue, queue_list);
    dump_current_scheduled(label);
    dump_event_handlers(label, 210);
    dump_upcall_queue(label, "amsQueue", ams_queue);
    dump_upcall_queue(label, "queueList", queue_list);
}

static jbed_request_install_fn resolve_jbed_request_install(void) {
    if (g_jbed_request_install != NULL) return g_jbed_request_install;

    void *handle = dlopen("libjbedvm.so", RTLD_NOW);
    if (handle != NULL) {
        g_jbed_request_install =
                (jbed_request_install_fn) dlsym(handle, "Jbed_ams_event_requestInstall");
    }
    if (g_jbed_request_install == NULL) {
        LOGE("unable to resolve Jbed_ams_event_requestInstall");
    }
    return g_jbed_request_install;
}

static jbed_request_local_install_fn resolve_jbed_request_local_install(void) {
    if (g_jbed_request_local_install != NULL) return g_jbed_request_local_install;

    void *handle = dlopen("libjbedvm.so", RTLD_NOW);
    if (handle != NULL) {
        g_jbed_request_local_install =
                (jbed_request_local_install_fn) dlsym(handle, "Jbed_ams_event_requestLocalInstall");
    }
    if (g_jbed_request_local_install == NULL) {
        LOGE("unable to resolve Jbed_ams_event_requestLocalInstall");
    }
    return g_jbed_request_local_install;
}

static jbed_upcall_poll_fn resolve_jbed_upcall_poll(void) {
    if (g_jbed_upcall_poll != NULL) return g_jbed_upcall_poll;

    void *handle = dlopen("libjbedvm.so", RTLD_NOW);
    if (handle != NULL) {
        g_jbed_upcall_poll = (jbed_upcall_poll_fn) dlsym(handle, "Jbed_upcall_poll");
    }
    if (g_jbed_upcall_poll == NULL) {
        LOGE("unable to resolve Jbed_upcall_poll");
    }
    return g_jbed_upcall_poll;
}

JNIEXPORT jboolean JNICALL
Java_com_esmertec_android_jbed_ams_AmsConnection_nativeRequestLocalInstall(JNIEnv *env, jclass clazz,
                                                                            jstring url) {
    (void) clazz;
    const char *utf;
    jbed_request_install_fn request_install;
    jbed_request_local_install_fn request_local_install;

    if (url == NULL) return JNI_FALSE;
    if (!use_modern_art_scheduler_workarounds()) {
        LOGI("letting legacy Java AMS event path handle local install on Android API %d",
             get_android_api_level());
        return JNI_FALSE;
    }
    clear_pending_exception(env);
    request_install = resolve_jbed_request_install();
    request_local_install = resolve_jbed_request_local_install();
    if (request_install == NULL && request_local_install == NULL) return JNI_FALSE;

    utf = (*env)->GetStringUTFChars(env, url, NULL);
    if (utf == NULL) return JNI_FALSE;

    dump_scheduler_state("before-direct-install");
    if (request_install != NULL) {
        LOGI("direct native install upcall: %s", utf);
        request_install(utf);
        dump_scheduler_state("after-requestInstall");
    }
    if (!(*env)->ExceptionCheck(env) && request_local_install != NULL) {
        LOGI("direct native local-install upcall: %s", utf);
        request_local_install((char *) utf, "");
        dump_scheduler_state("after-requestLocalInstall");
    }
    if (!(*env)->ExceptionCheck(env)) {
        jbed_upcall_poll_fn upcall_poll = resolve_jbed_upcall_poll();
        if (upcall_poll != NULL) {
            int poll_result = upcall_poll();
            LOGI("direct native install upcall poll result=%d", poll_result);
            dump_scheduler_state("after-upcall-poll");
        }
    }
    if ((*env)->ExceptionCheck(env)) {
        LOGI("clearing pending JNI exception after direct install upcall");
        (*env)->ExceptionClear(env);
    }
    (*env)->ReleaseStringUTFChars(env, url, utf);
    return JNI_TRUE;
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
    (void) env;
    (void) old_state;
    (void) reason;
    if (g_vm_state_change_method != NULL && method == g_vm_state_change_method &&
        commit && new_state == 3 && !g_patched_low_jbed_run_quantum) {
        /* Java marks the request and applies it after nativeJbedRun returns.
         * Do not mprotect/patch libjbedvm while this callback is still inside
         * the VM: that timing caused SIGBUS on ARM ART. */
        LOGI("vmStateChange foreground commit intercepted; deferring scheduler patch until callback returns");
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
    g_jbed_request_install = NULL;
    g_jbed_request_local_install = NULL;
    g_jbed_upcall_poll = NULL;
}

/* Explicit registration avoids relying on ART's cross-library native symbol
 * lookup order after libjbedvm.so has registered its own methods. */
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved) {
    (void) reserved;
    JNIEnv *env = NULL;
    install_native_crash_handlers();
    LOGI("installed native crash marker handlers");
    if ((*vm)->GetEnv(vm, (void **) &env, JNI_VERSION_1_6) != JNI_OK) return JNI_ERR;

    ensure_jbed_base();
    patch_native_jbed_run_startup_quantum();

    jclass engine = (*env)->FindClass(env, "com/esmertec/android/jbed/service/JbedEngine");
    if (engine == NULL) return JNI_ERR;
    JNINativeMethod methods[] = {
        {"nativeInstallJniLifetimeHook", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedEngine_nativeInstallJniLifetimeHook},
        {"nativeReleaseJniLifetimeHook", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedEngine_nativeReleaseJniLifetimeHook},
        {"nativeEnableLowSchedulerQuantum", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedEngine_nativeEnableLowSchedulerQuantum},
        {"nativeRecoverAfterStackOverflow", "()V", (void *) Java_com_esmertec_android_jbed_service_JbedEngine_nativeRecoverAfterStackOverflow},
    };
    if ((*env)->RegisterNatives(env, engine, methods, 4) != JNI_OK) return JNI_ERR;

    jclass ams_connection = (*env)->FindClass(env, "com/esmertec/android/jbed/ams/AmsConnection");
    if (ams_connection == NULL) return JNI_ERR;
    JNINativeMethod ams_methods[] = {
        {"nativeRequestLocalInstall", "(Ljava/lang/String;)Z", (void *) Java_com_esmertec_android_jbed_ams_AmsConnection_nativeRequestLocalInstall},
    };
    if ((*env)->RegisterNatives(env, ams_connection, ams_methods, 1) != JNI_OK) return JNI_ERR;

    /* The experimental JbedService MIDP-class hook was removed from Java.
     * Do not register methods that are no longer declared: ART treats that
     * as an error and rejects the entire compatibility library in JNI_OnLoad.
     * The active JbedEngine hook also handles the string callback fallback. */
    LOGI("registered ART JbedEngine/AmsConnection JNI compatibility methods (lifetime + staged scheduler quantum patch)");
    return JNI_VERSION_1_6;
}
