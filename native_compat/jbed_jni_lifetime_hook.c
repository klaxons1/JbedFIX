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
#include <sys/prctl.h>
#include <sys/stat.h>
#include <sys/system_properties.h>
#include <ucontext.h>
#include <unistd.h>

#define LOG_TAG "jbed-jni-compat"
#ifndef JBED_PUBLIC_LOG_DIR
/* Overridable so the crash-record helpers can be exercised in a host test. */
#define JBED_PUBLIC_LOG_DIR "/storage/emulated/0/jbedfix"
#endif
#define JBED_NATIVE_LOG_PATH JBED_PUBLIC_LOG_DIR "/native.log"
#define JBED_DISABLE_STARTUP_PATCH_MARKER JBED_PUBLIC_LOG_DIR "/disable-startup-quantum.patch"
/* PT_LOAD image size from lib/armeabi/libjbedvm.so; used to validate pc offsets. */
#define JBED_LIBVM_IMAGE_SIZE 0x31abf8u

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
 * small async-signal-safe marker, then let the previously installed handler
 * (ART's own fault/signal handling) decide what happens, so this diagnostic
 * shim never changes ART semantics such as implicit null checks or
 * StackOverflowError detection. */
static volatile sig_atomic_t g_crash_handler_active;
static uintptr_t g_jbed_base;
static int g_native_crash_handler_installed;

#define JBED_MAX_SIGNALS 64
static struct sigaction g_previous_signal_actions[JBED_MAX_SIGNALS];
static int g_previous_signal_action_valid[JBED_MAX_SIGNALS];

/*
 * libcore's AsynchronousCloseMonitor interrupts a blocked syscall by sending
 * __SIGRTMIN+2 (bionic reserves 8 real-time signals, so this is signal 34) to
 * the blocked thread, and walks its blocked-thread list every time a Java
 * FileDescriptor is closed (IoBridge.closeAndSignalBlockedThreads). Counting
 * those signals in the crash record shows whether the platform was closing
 * descriptors right before the fault.
 */
#define JBED_BLOCKED_THREAD_SIGNAL 34
static volatile sig_atomic_t g_blocked_thread_signals_seen;

/* Crash diagnostics keep a copy of every named mapping, not only executable
 * ones, so a fault address (si_addr) can be attributed to the library that
 * owns it. A SIGBUS reported inside a platform library is only actionable
 * when the mapping of both pc and si_addr is known. */
#define JBED_MAX_MAPPINGS 1024
struct mapped_region {
    uintptr_t start;
    uintptr_t end;
    size_t name_length;
    char permissions[5];
    char name[96];
};
static struct mapped_region g_mappings[JBED_MAX_MAPPINGS];
static size_t g_mapping_count;
static size_t g_mapping_row_count;
static int g_mapping_table_truncated;

/*
 * Every VM -> Java call routed through the cloned JNIEnv table is recorded in
 * a small ring buffer together with the method name captured from the matching
 * GetMethodID/GetStaticMethodID lookup. The ring is dumped into
 * native-crash.log, so a native crash still reports which Java method the VM
 * was entering at that moment - essential when the fault happens inside
 * platform code (for example libcore's libandroidio.so) rather than in the VM.
 */
#define JBED_TRACE_RING_SIZE 128
#define JBED_TRACE_NAME_LENGTH 48
#define JBED_MAX_TRACE_METHODS 256
#define JBED_TRACE_UNKNOWN_METHOD "?"

enum {
    JBED_TRACE_CALL_VOID = 1,
    JBED_TRACE_CALL_BOOLEAN,
    JBED_TRACE_CALL_INT,
    JBED_TRACE_CALL_OBJECT,
    JBED_TRACE_CALL_STATIC_VOID,
    JBED_TRACE_CALL_STATIC_BOOLEAN,
    JBED_TRACE_CALL_STATIC_INT,
    JBED_TRACE_CALL_STATIC_OBJECT,
    JBED_TRACE_VM_STATE_CHANGE
};

struct jni_trace_entry {
    uint32_t kind;
    int32_t tid;
    int32_t arg0;
    int32_t arg1;
    uintptr_t method_id;
    char name[JBED_TRACE_NAME_LENGTH];
};
static struct jni_trace_entry g_jni_trace[JBED_TRACE_RING_SIZE];
static volatile uint32_t g_jni_trace_next;

struct jni_trace_method {
    uintptr_t method_id;
    uint8_t is_static;
    char name[JBED_TRACE_NAME_LENGTH];
};
static struct jni_trace_method g_jni_trace_methods[JBED_MAX_TRACE_METHODS];
static volatile uint32_t g_jni_trace_method_next;
static char g_last_find_class_name[JBED_TRACE_NAME_LENGTH];
static uintptr_t g_last_find_class;

/* Diagnostics can be turned off on-device without rebuilding the APK. */
#define JBED_DISABLE_CRASH_HANDLER_MARKER JBED_PUBLIC_LOG_DIR "/disable-crash-handler.patch"
#define JBED_DISABLE_JNI_TRACE_MARKER JBED_PUBLIC_LOG_DIR "/disable-jni-trace.patch"
#define JBED_DISABLE_BLOCKED_THREAD_OBSERVER_MARKER \
    JBED_PUBLIC_LOG_DIR "/disable-blocked-thread-observer.patch"
static int g_jni_trace_enabled = 1;

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

static size_t append_text(char *buffer, size_t offset, size_t capacity,
                          const char *text, size_t text_length) {
    while (text_length > 0 && offset < capacity) {
        buffer[offset++] = *text++;
        --text_length;
    }
    return offset;
}

static size_t bounded_length(const char *text, size_t maximum) {
    size_t length = 0;
    if (text == NULL) return 0;
    while (length < maximum && text[length] != '\0') ++length;
    return length;
}

static int32_t current_tid(void) {
#if defined(__arm__)
    /* gettid() is only declared from API 21; this library is built for API 19. */
    return (int32_t) syscall(224);
#else
    return (int32_t) getpid();
#endif
}

static const struct mapped_region *find_region(uintptr_t address, int require_executable) {
    size_t i;
    for (i = 0; i < g_mapping_count; ++i) {
        const struct mapped_region *region = &g_mappings[i];
        if (address >= region->start && address < region->end) {
            if (require_executable && strchr(region->permissions, 'x') == NULL) continue;
            return region;
        }
    }
    return NULL;
}

static void clear_pending_exception(JNIEnv *env);

/*
 * Java method names are captured when the VM resolves them. Both tables are
 * fixed-size and allocation-free: they are written from JNI callbacks and read
 * from the crash signal handler.
 */
static const char *trace_method_name(jmethodID method) {
    uint32_t i;
    if (method == NULL) return JBED_TRACE_UNKNOWN_METHOD;
    for (i = 0; i < JBED_MAX_TRACE_METHODS; ++i) {
        if (g_jni_trace_methods[i].method_id == (uintptr_t) method
                && g_jni_trace_methods[i].name[0] != '\0') {
            return g_jni_trace_methods[i].name;
        }
    }
    return JBED_TRACE_UNKNOWN_METHOD;
}

static void trace_remember_method(jmethodID method, int is_static, const char *name,
                                  const char *signature, int class_matches) {
    struct jni_trace_method *entry;
    uint32_t index;
    size_t offset = 0;

    if (method == NULL || name == NULL) return;
    index = g_jni_trace_method_next % JBED_MAX_TRACE_METHODS;
    entry = &g_jni_trace_methods[index];
    g_jni_trace_method_next = index + 1;
    entry->method_id = (uintptr_t) method;
    entry->is_static = (uint8_t) (is_static ? 1 : 0);
    if (class_matches && g_last_find_class_name[0] != '\0') {
        offset = append_text(entry->name, offset, sizeof(entry->name),
                             g_last_find_class_name, bounded_length(g_last_find_class_name,
                                                                    sizeof(entry->name)));
        if (offset + 1 < sizeof(entry->name)) entry->name[offset++] = '.';
    }
    offset = append_text(entry->name, offset, sizeof(entry->name), name,
                         bounded_length(name, sizeof(entry->name)));
    entry->name[offset < sizeof(entry->name) ? offset : sizeof(entry->name) - 1] = '\0';
    (void) signature;
}

static void trace_record(uint32_t kind, jmethodID method, int32_t arg0, int32_t arg1,
                         const char *call_name) {
    struct jni_trace_entry *entry;
    uint32_t index;
    size_t offset = 0;

    if (!g_jni_trace_enabled) return;
    index = g_jni_trace_next % JBED_TRACE_RING_SIZE;
    entry = &g_jni_trace[index];
    entry->kind = kind;
    entry->tid = current_tid();
    entry->arg0 = arg0;
    entry->arg1 = arg1;
    entry->method_id = (uintptr_t) method;
    offset = append_text(entry->name, offset, sizeof(entry->name), call_name,
                         bounded_length(call_name, sizeof(entry->name)));
    if (offset + 1 < sizeof(entry->name)) entry->name[offset++] = ' ';
    offset = append_text(entry->name, offset, sizeof(entry->name),
                         trace_method_name(method),
                         bounded_length(trace_method_name(method), sizeof(entry->name)));
    entry->name[offset < sizeof(entry->name) ? offset : sizeof(entry->name) - 1] = '\0';
    g_jni_trace_next = index + 1;
}

static void trace_and_clear_exception(JNIEnv *env, const char *call_name, uint32_t kind,
                                      jmethodID method) {
    clear_pending_exception(env);
    trace_record(kind, method, -1, -1, call_name);
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

static uintptr_t crash_lr(void *context) {
    if (context == NULL) return 0;
#if defined(__arm__)
    return (uintptr_t) ((ucontext_t *) context)->uc_mcontext.arm_lr;
#elif defined(__aarch64__)
    return (uintptr_t) ((ucontext_t *) context)->uc_mcontext.regs[30];
#else
    return 0;
#endif
}

static uintptr_t crash_arm_register(void *context, unsigned int index) {
    if (context == NULL) return 0;
#if defined(__arm__)
    ucontext_t *state = (ucontext_t *) context;
    switch (index) {
        case 0: return (uintptr_t) state->uc_mcontext.arm_r0;
        case 1: return (uintptr_t) state->uc_mcontext.arm_r1;
        case 2: return (uintptr_t) state->uc_mcontext.arm_r2;
        case 3: return (uintptr_t) state->uc_mcontext.arm_r3;
        case 4: return (uintptr_t) state->uc_mcontext.arm_r4;
        case 5: return (uintptr_t) state->uc_mcontext.arm_r5;
        case 6: return (uintptr_t) state->uc_mcontext.arm_r6;
        case 7: return (uintptr_t) state->uc_mcontext.arm_r7;
        case 8: return (uintptr_t) state->uc_mcontext.arm_r8;
        case 9: return (uintptr_t) state->uc_mcontext.arm_r9;
        case 10: return (uintptr_t) state->uc_mcontext.arm_r10;
        case 11: return (uintptr_t) state->uc_mcontext.arm_fp;
        case 12: return (uintptr_t) state->uc_mcontext.arm_ip;
        case 13: return (uintptr_t) state->uc_mcontext.arm_sp;
        case 14: return (uintptr_t) state->uc_mcontext.arm_lr;
        case 15: return (uintptr_t) state->uc_mcontext.arm_pc;
        case 16: return (uintptr_t) state->uc_mcontext.arm_cpsr;
        default: return 0;
    }
#elif defined(__aarch64__)
    if (index > 16) return 0;
    return (uintptr_t) ((ucontext_t *) context)->uc_mcontext.regs[index];
#else
    (void) context;
    (void) index;
    return 0;
#endif
}

/* bionic fills this in only for real faults; it stays zero when the signal was
 * sent (kill/tgkill) rather than raised by the hardware. */
static uintptr_t crash_fault_address(void *context) {
    if (context == NULL) return 0;
#if defined(__arm__) || defined(__aarch64__)
    /* bionic exposes the hardware fault address here; it stays zero when the
     * signal was sent rather than raised by the hardware. */
    return (uintptr_t) ((ucontext_t *) context)->uc_mcontext.fault_address;
#else
    return 0;
#endif
}

static int crash_signal_code(siginfo_t *signal_info) {
    return signal_info == NULL ? -1 : signal_info->si_code;
}

static size_t append_marker_hex(char *buffer, size_t offset, size_t capacity,
                                const char *marker, size_t marker_length,
                                uintptr_t value) {
    memcpy(buffer + offset, marker, marker_length);
    offset += marker_length;
    return append_hex(buffer, offset, capacity, value);
}

static uintptr_t module_lowest_base(const char *name, size_t name_length);
static int probe_read_memory(uintptr_t address, void *buffer, size_t length);
static void probe_real_time_site(const char *label, uintptr_t value);

#define JBED_CRASH_LINE_LENGTH 768

/* Every register that points into a named mapping is re-rendered with that
 * mapping's ELF base and its module offset, because /proc/self/maps only gives
 * mapping offsets: only "value - r--p base" is directly comparable with the
 * offset of a real instruction in the library file. */
static size_t append_register_region(char *line, size_t offset, size_t capacity,
                                     const char *register_name, uintptr_t value) {
    const struct mapped_region *region = find_region(value & ~(uintptr_t) 1u, 0);
    uintptr_t base;

    if (region == NULL) {
        /* Small values are not pointers at all; only annotate plausible ones. */
        if (value < 0x10000) return offset;
        offset = append_text(line, offset, capacity, " ", 1);
        offset = append_text(line, offset, capacity, register_name,
                             bounded_length(register_name, 32));
        offset = append_text(line, offset, capacity, "->unmapped", sizeof("->unmapped") - 1);
        return offset;
    }
    if (region->name[0] != '/') {
        offset = append_text(line, offset, capacity, " ", 1);
        offset = append_text(line, offset, capacity, register_name,
                             bounded_length(register_name, 32));
        offset = append_text(line, offset, capacity, "->anon[", sizeof("->anon[") - 1);
        offset = append_text(line, offset, capacity, region->permissions,
                             bounded_length(region->permissions, sizeof(region->permissions)));
        offset = append_text(line, offset, capacity, "]", 1);
        return offset;
    }
    if (region->name_length == 0) return offset;
    base = module_lowest_base(region->name, region->name_length);
    if (base == 0 || base > value) return offset;
    offset = append_text(line, offset, capacity, " ", 1);
    offset = append_text(line, offset, capacity, register_name,
                         bounded_length(register_name, 32));
    offset = append_text(line, offset, capacity, "->", 2);
    offset = append_text(line, offset, capacity, region->name, region->name_length);
    offset = append_text(line, offset, capacity, "+", 1);
    offset = append_marker_hex(line, offset, capacity, "0x", sizeof("0x") - 1, value - base);
    return offset;
}

static void write_crash_log(const char *buffer, size_t length) {
    int fd;
    if (length == 0) return;
    fd = open(JBED_PUBLIC_LOG_DIR "/native-crash.log", O_WRONLY | O_CREAT | O_APPEND, 0664);
    if (fd >= 0) {
        (void) write(fd, buffer, length);
        close(fd);
    }
}

static size_t begin_crash_line(char *line) {
    static const char prefix[] = "FATAL/jbed-jni-compat native ";
    memcpy(line, prefix, sizeof(prefix) - 1);
    return sizeof(prefix) - 1;
}

static void end_crash_line(char *line, size_t offset, size_t capacity) {
    if (offset + 1 < capacity) line[offset++] = '\n';
    write_crash_log(line, offset);
}

static size_t append_region(char *line, size_t offset, size_t capacity,
                            const char *name_marker, const char *base_marker,
                            const char *offset_marker, uintptr_t address,
                            int require_executable) {
    const struct mapped_region *region = find_region(address, require_executable);
    if (region == NULL) return offset;
    offset = append_text(line, offset, capacity, name_marker, bounded_length(name_marker, 32));
    offset = append_text(line, offset, capacity, region->name, region->name_length);
    if (base_marker != NULL && base_marker[0] != '\0') {
        offset = append_marker_hex(line, offset, capacity, base_marker,
                                   bounded_length(base_marker, 32), region->start);
    }
    if (address >= region->start) {
        offset = append_marker_hex(line, offset, capacity, offset_marker,
                                   bounded_length(offset_marker, 32),
                                   (address & ~(uintptr_t) 1u) - region->start);
    }
    return offset;
}

/*
 * ARM frames keep their caller chain in memory: fp points at {caller fp, lr}.
 * Walking it yields the native call chain even when the fault happens inside a
 * platform library such as libandroidio.so. Every read is bounds-checked
 * against the mapping table first, so a corrupted fp cannot fault again inside
 * the crash handler. The raw word scan below is the fallback for frames that
 * were built without frame pointers.
 */
static void dump_frame_chain(uintptr_t fp, uintptr_t sp) {
    char line[JBED_CRASH_LINE_LENGTH];
    size_t offset;
    int frame = 0;

    if (fp == 0 || fp < sp) return;
    while (frame < 32) {
        const struct mapped_region *region = find_region(fp, 0);
        const struct mapped_region *next_region;
        uintptr_t next_fp;
        uintptr_t return_address;

        if (region == NULL || strchr(region->permissions, 'r') == NULL) break;
        if (region->end - fp < 2 * sizeof(uintptr_t)) break;
        next_fp = ((const uintptr_t *) fp)[0];
        return_address = ((const uintptr_t *) fp)[1] & ~(uintptr_t) 1u;

        offset = begin_crash_line(line);
        offset = append_text(line, offset, sizeof(line), "frame=", sizeof("frame=") - 1);
        offset = append_decimal(line, offset, sizeof(line), (unsigned long) frame);
        offset = append_marker_hex(line, offset, sizeof(line), " fp=0x", sizeof(" fp=0x") - 1, fp);
        offset = append_region(line, offset, sizeof(line), " return=", NULL, " +0x",
                               return_address, 1);
        end_crash_line(line, offset, sizeof(line));

        if (next_fp <= fp) break;
        next_region = find_region(next_fp, 0);
        if (next_region == NULL || strchr(next_region->permissions, 'r') == NULL) break;
        fp = next_fp;
        ++frame;
    }
}

/* The mapping table has a fixed capacity; report it so a module missing from a
 * crash record can be told apart from a module that was never scanned. */
static void dump_mapping_summary(void) {
    char line[JBED_CRASH_LINE_LENGTH];
    size_t offset = begin_crash_line(line);

    offset = append_text(line, offset, sizeof(line), "maps=", sizeof("maps=") - 1);
    offset = append_decimal(line, offset, sizeof(line), (unsigned long) g_mapping_count);
    offset = append_text(line, offset, sizeof(line), " rows=", sizeof(" rows=") - 1);
    offset = append_decimal(line, offset, sizeof(line), (unsigned long) g_mapping_row_count);
    if (g_mapping_table_truncated) {
        offset = append_text(line, offset, sizeof(line), " truncated=1",
                             sizeof(" truncated=1") - 1);
    }
    end_crash_line(line, offset, sizeof(line));
}

static void dump_stack_scan(uintptr_t sp) {
    char line[JBED_CRASH_LINE_LENGTH];
    size_t offset;
    uintptr_t *words;
    int index;
    int word_limit = 0;
    int hits_on_line = 0;
    int hits = 0;

    if (sp == 0) return;
    {
        const struct mapped_region *stack_region = find_region(sp, 0);
        if (stack_region == NULL || strchr(stack_region->permissions, 'r') == NULL) return;
        word_limit = (int) ((stack_region->end - sp) / sizeof(uintptr_t));
        if (word_limit > 192) word_limit = 192;
    }
    if (word_limit <= 0) return;
    words = (uintptr_t *) sp;
    offset = begin_crash_line(line);
    offset = append_text(line, offset, sizeof(line), "stack-scan", sizeof("stack-scan") - 1);
    for (index = 0; index < word_limit && hits < 24; ++index) {
        uintptr_t value = words[index];
        uintptr_t address = value & ~(uintptr_t) 1u;
        if (find_region(address, 1) == NULL) continue;
        if (hits_on_line == 4) {
            end_crash_line(line, offset, sizeof(line));
            offset = begin_crash_line(line);
            offset = append_text(line, offset, sizeof(line), "stack-scan",
                                 sizeof("stack-scan") - 1);
            hits_on_line = 0;
        }
        offset = append_text(line, offset, sizeof(line), " ", 1);
        offset = append_region(line, offset, sizeof(line), "", NULL, " +0x", address, 1);
        ++hits_on_line;
        ++hits;
    }
    if (hits > 0) end_crash_line(line, offset, sizeof(line));
}

/*
 * Dump the last VM -> Java upcalls. This is the only place that shows which
 * Java method the VM was entering when the process died inside platform code,
 * because a SIGBUS in libcore's libandroidio.so has no Java stack trace.
 */
static void dump_jni_trace(void) {
    char line[JBED_CRASH_LINE_LENGTH];
    size_t offset;
    uint32_t count;
    uint32_t start;
    uint32_t produced = g_jni_trace_next;
    uint32_t i;

    if (produced == 0) return;
    count = produced < JBED_TRACE_RING_SIZE ? produced : JBED_TRACE_RING_SIZE;
    start = produced >= JBED_TRACE_RING_SIZE ? (produced % JBED_TRACE_RING_SIZE) : 0;
    offset = begin_crash_line(line);
    offset = append_text(line, offset, sizeof(line), "jni-trace entries=",
                         sizeof("jni-trace entries=") - 1);
    offset = append_decimal(line, offset, sizeof(line), (unsigned long) count);
    end_crash_line(line, offset, sizeof(line));

    for (i = 0; i < count; ++i) {
        const struct jni_trace_entry *entry =
                &g_jni_trace[(start + i) % JBED_TRACE_RING_SIZE];
        offset = begin_crash_line(line);
        offset = append_text(line, offset, sizeof(line), "jni-trace tid=",
                             sizeof("jni-trace tid=") - 1);
        offset = append_decimal(line, offset, sizeof(line), (unsigned long) entry->tid);
        offset = append_text(line, offset, sizeof(line), " ", 1);
        offset = append_text(line, offset, sizeof(line), entry->name,
                             bounded_length(entry->name, sizeof(entry->name)));
        if (entry->kind == JBED_TRACE_VM_STATE_CHANGE) {
            offset = append_text(line, offset, sizeof(line), " newState=",
                                 sizeof(" newState=") - 1);
            offset = append_decimal(line, offset, sizeof(line), (unsigned long) entry->arg0);
            offset = append_text(line, offset, sizeof(line), " reason=", sizeof(" reason=") - 1);
            offset = append_decimal(line, offset, sizeof(line), (unsigned long) entry->arg1);
        } else if (entry->method_id != 0) {
            offset = append_marker_hex(line, offset, sizeof(line), " method=0x",
                                       sizeof(" method=0x") - 1, entry->method_id);
        }
        end_crash_line(line, offset, sizeof(line));
    }
}

/*
 * The crash record itself must answer two questions without any further
 * processing on the device: which library offset belongs to which file offset,
 * and what the faulting instruction is. Both are printed as a few hex words,
 * which is small enough to be copied by hand from a phone.
 */
static void dump_fault_site(uintptr_t pc, uintptr_t fault, uint32_t cpsr) {
    /* In ARM state an instruction word is read most-significant byte first, in
     * Thumb state halfwords are little-endian; printing the value in the state's
     * own order keeps it identical to what a disassembler shows. */
    const int thumb = (cpsr & 0x20u) != 0;
    char line[JBED_CRASH_LINE_LENGTH];
    size_t offset = begin_crash_line(line);
    const struct mapped_region *region = find_region(pc, 1);
    const struct mapped_region *executable = region;
    uintptr_t base = 0;

    offset = append_text(line, offset, sizeof(line), "pc-offsets:", sizeof("pc-offsets:") - 1);
    if (region != NULL) {
        base = module_lowest_base(region->name, region->name_length);
        offset = append_text(line, offset, sizeof(line), " module=", sizeof(" module=") - 1);
        offset = append_text(line, offset, sizeof(line), region->name, region->name_length);
    }
    offset = append_marker_hex(line, offset, sizeof(line), " elfBase=0x",
                               sizeof(" elfBase=0x") - 1, base);
    if (base != 0 && pc >= base) {
        offset = append_marker_hex(line, offset, sizeof(line), " offsetFromElfBase=0x",
                                   sizeof(" offsetFromElfBase=0x") - 1, (pc & ~(uintptr_t) 1u) - base);
    }
    if (executable != NULL) {
        offset = append_marker_hex(line, offset, sizeof(line), " execRegionStart=0x",
                                   sizeof(" execRegionStart=0x") - 1, executable->start);
        if (pc >= executable->start) {
            offset = append_marker_hex(line, offset, sizeof(line), " offsetFromExecRegion=0x",
                                       sizeof(" offsetFromExecRegion=0x") - 1,
                                       (pc & ~(uintptr_t) 1u) - executable->start);
        }
        if (base != 0 && executable->start >= base) {
            offset = append_marker_hex(line, offset, sizeof(line), " execStartFromElfBase=0x",
                                       sizeof(" execStartFromElfBase=0x") - 1,
                                       executable->start - base);
        }
    }
    if (fault != 0) {
        /* The low bits of a faulting address decide whether a wider access can
         * even succeed: an odd address cannot satisfy a 2/4/8-byte access. */
        offset = append_marker_hex(line, offset, sizeof(line), " faultMod8=0x",
                                   sizeof(" faultMod8=0x") - 1, fault & 7u);
        offset = append_text(line, offset, sizeof(line),
                             (fault & 7u) != 0 ? " faultAlignment=misaligned"
                                               : " faultAlignment=aligned",
                             (fault & 7u) != 0 ? sizeof(" faultAlignment=misaligned") - 1
                                               : sizeof(" faultAlignment=aligned") - 1);
    }
    end_crash_line(line, offset, sizeof(line));

    /* The instruction words around pc: the faulting one is the last, and the
     * preceding ones show which register was loaded from where. */
    offset = begin_crash_line(line);
    offset = append_text(line, offset, sizeof(line), "pc-words:", sizeof("pc-words:") - 1);
    {
        /* One word past pc as well: a 32-bit Thumb-2 instruction starts at pc,
         * so its second halfword must be visible too. */
        static const int deltas[] = {-16, -12, -8, -4, 0, 4};
        size_t index;
        for (index = 0; index < sizeof(deltas) / sizeof(deltas[0]); ++index) {
            uintptr_t address = (pc & ~(uintptr_t) 1u) + (uintptr_t) deltas[index];
            unsigned char bytes[4];
            offset = append_text(line, offset, sizeof(line), " ", 1);
            if (deltas[index] < 0) {
                offset = append_text(line, offset, sizeof(line), "-", 1);
                offset = append_decimal(line, offset, sizeof(line),
                                        (unsigned long) (-deltas[index]));
            } else {
                offset = append_text(line, offset, sizeof(line), "+", 1);
                offset = append_decimal(line, offset, sizeof(line),
                                        (unsigned long) deltas[index]);
            }
            offset = append_text(line, offset, sizeof(line), "=", 1);
            if (probe_read_memory(address, bytes, sizeof(bytes))) {
                uintptr_t word = (uintptr_t) bytes[0] | ((uintptr_t) bytes[1] << 8)
                        | ((uintptr_t) bytes[2] << 16) | ((uintptr_t) bytes[3] << 24);
                if (!thumb) {
                    word = ((word & 0x000000ffu) << 24) | ((word & 0x0000ff00u) << 8)
                            | ((word & 0x00ff0000u) >> 8) | ((word & 0xff000000u) >> 24);
                }
                offset = append_marker_hex(line, offset, sizeof(line), "0x", sizeof("0x") - 1,
                                           word);
            } else {
                offset = append_text(line, offset, sizeof(line), "unreadable",
                                     sizeof("unreadable") - 1);
            }
        }
    }
    end_crash_line(line, offset, sizeof(line));

    /* Which mapping of the module holds which file offset: this decides how a
     * module+offset pair must be interpreted. */
    if (region != NULL) {
        size_t remaining = g_mapping_count;
        uintptr_t last_started = 0;
        int printed = 0;
        offset = begin_crash_line(line);
        offset = append_text(line, offset, sizeof(line), "pc-module-maps:",
                             sizeof("pc-module-maps:") - 1);
        while (remaining-- > 0) {
            size_t best_index = g_mapping_count;
            uintptr_t best_start = UINTPTR_MAX;
            size_t index;
            for (index = 0; index < g_mapping_count; ++index) {
                const struct mapped_region *candidate = &g_mappings[index];
                if (candidate->name_length != region->name_length) continue;
                if (strncmp(candidate->name, region->name, region->name_length) != 0) continue;
                if (candidate->start <= last_started) continue;
                if (candidate->start < best_start) {
                    best_start = candidate->start;
                    best_index = index;
                }
            }
            if (best_index == g_mapping_count) break;
            {
                const struct mapped_region *candidate = &g_mappings[best_index];
                offset = append_text(line, offset, sizeof(line), " ", 1);
                offset = append_text(line, offset, sizeof(line), candidate->permissions,
                                     bounded_length(candidate->permissions,
                                                    sizeof(candidate->permissions)));
                offset = append_text(line, offset, sizeof(line), "@0x", sizeof("@0x") - 1);
                offset = append_marker_hex(line, offset, sizeof(line), "", 0, candidate->start);
                offset = append_marker_hex(line, offset, sizeof(line), "-0x",
                                           sizeof("-0x") - 1, candidate->end);
                if (base != 0 && candidate->start >= base) {
                    offset = append_marker_hex(line, offset, sizeof(line), "+0x",
                                               sizeof("+0x") - 1, candidate->start - base);
                }
            }
            last_started = g_mappings[best_index].start;
            ++printed;
        }
        if (printed == 0) {
            offset = append_text(line, offset, sizeof(line), " none", sizeof(" none") - 1);
        }
        end_crash_line(line, offset, sizeof(line));
    }
}

/*
 * The monitor keeps its state in two module globals (the mutex and the head of
 * the blocked-thread list). They live in the module's writable segment, so the
 * first words of that segment are dumped too: a corrupted list head is visible
 * right here, without a second launch.
 */
static void dump_module_writable_words(uintptr_t pc, size_t length) {
    char line[JBED_CRASH_LINE_LENGTH];
    const struct mapped_region *region = find_region(pc, 1);
    const struct mapped_region *writable = NULL;
    size_t index;
    size_t i;
    size_t position = 0;
    int line_open = 0;

    if (region == NULL) return;
    for (i = 0; i < g_mapping_count; ++i) {
        const struct mapped_region *candidate = &g_mappings[i];
        if (candidate->name_length != region->name_length) continue;
        if (strncmp(candidate->name, region->name, region->name_length) != 0) continue;
        if (strchr(candidate->permissions, 'w') == NULL) continue;
        writable = candidate;
        break;
    }
    if (writable == NULL) return;
    if (length > writable->end - writable->start) length = writable->end - writable->start;
    if (length > 128) length = 128;

    for (index = 0; index + 4 <= length; index += 4) {
        unsigned char bytes[4];
        if ((index % 16) == 0) {
            if (line_open) end_crash_line(line, position, sizeof(line));
            line_open = 1;
            position = begin_crash_line(line);
            position = append_text(line, position, sizeof(line), "pc-module-rw+0x",
                                   sizeof("pc-module-rw+0x") - 1);
            position = append_marker_hex(line, position, sizeof(line), "", 0, index);
            position = append_text(line, position, sizeof(line), ":", 1);
        }
        if (!probe_read_memory(writable->start + index, bytes, sizeof(bytes))) break;
        position = append_text(line, position, sizeof(line), " ", 1);
        position = append_marker_hex(line, position, sizeof(line), "", 0,
                                     (uintptr_t) bytes[0] | ((uintptr_t) bytes[1] << 8)
                                             | ((uintptr_t) bytes[2] << 16)
                                             | ((uintptr_t) bytes[3] << 24));
    }
    if (line_open) end_crash_line(line, position, sizeof(line));
}

static void dump_crash_marker(int signal_number, siginfo_t *signal_info, void *context) {
    char line[JBED_CRASH_LINE_LENGTH];
    size_t offset;
    uintptr_t pc = crash_pc(context);
    uintptr_t lr = crash_lr(context);

    offset = begin_crash_line(line);
    offset = append_text(line, offset, sizeof(line), "signal=", sizeof("signal=") - 1);
    offset = append_decimal(line, offset, sizeof(line), (unsigned long) signal_number);
    offset = append_text(line, offset, sizeof(line), " code=", sizeof(" code=") - 1);
    offset = append_decimal(line, offset, sizeof(line),
                            (unsigned long) (unsigned int) crash_signal_code(signal_info));
    offset = append_text(line, offset, sizeof(line), " pid=", sizeof(" pid=") - 1);
    offset = append_decimal(line, offset, sizeof(line), (unsigned long) getpid());
    offset = append_text(line, offset, sizeof(line), " tid=", sizeof(" tid=") - 1);
    offset = append_decimal(line, offset, sizeof(line), (unsigned long) current_tid());
    offset = append_text(line, offset, sizeof(line), " blockedThreadSignals=",
                         sizeof(" blockedThreadSignals=") - 1);
    offset = append_decimal(line, offset, sizeof(line),
                            (unsigned long) g_blocked_thread_signals_seen);
    {
        /* The crashing thread's name separates a VM thread fault from an ART
         * runtime thread fault, which matters for a signal raised inside an
         * APEX library such as libandroidio.so. */
        char thread_name[32];
        thread_name[0] = '\0';
        (void) prctl(PR_GET_NAME, thread_name, 0, 0, 0);
        if (thread_name[0] != '\0') {
            offset = append_text(line, offset, sizeof(line), " thread=", sizeof(" thread=") - 1);
            offset = append_text(line, offset, sizeof(line), thread_name,
                                 bounded_length(thread_name, sizeof(thread_name)));
        }
    }
    offset = append_marker_hex(line, offset, sizeof(line), " address=0x",
                               sizeof(" address=0x") - 1,
                               signal_info == NULL ? 0 : (uintptr_t) signal_info->si_addr);
    offset = append_marker_hex(line, offset, sizeof(line), " faultAddress=0x",
                               sizeof(" faultAddress=0x") - 1, crash_fault_address(context));
    if (crash_signal_code(signal_info) <= 0) {
        /* si_code <= 0: the signal was sent by a process/thread (kill, tgkill,
         * raise), not raised by the hardware, so si_addr is not an address. */
        offset = append_text(line, offset, sizeof(line), " sent=1", sizeof(" sent=1") - 1);
    }
    end_crash_line(line, offset, sizeof(line));

    offset = begin_crash_line(line);
    offset = append_marker_hex(line, offset, sizeof(line), "pc=0x", sizeof("pc=0x") - 1, pc);
    if (find_region(pc, 1) == NULL) {
        offset = append_text(line, offset, sizeof(line), " pcModule=unknown-region",
                             sizeof(" pcModule=unknown-region") - 1);
    } else {
        offset = append_region(line, offset, sizeof(line), " pcModule=", " pcModuleBase=0x",
                               " pcModuleOffset=0x", pc, 1);
    }
    offset = append_marker_hex(line, offset, sizeof(line), " sp=0x", sizeof(" sp=0x") - 1,
                               crash_sp(context));
    offset = append_marker_hex(line, offset, sizeof(line), " lr=0x", sizeof(" lr=0x") - 1, lr);
    if (find_region(lr, 1) == NULL) {
        offset = append_text(line, offset, sizeof(line), " lrModule=unknown-region",
                             sizeof(" lrModule=unknown-region") - 1);
    } else {
        offset = append_region(line, offset, sizeof(line), " lrModule=", " lrModuleBase=0x",
                               " lrModuleOffset=0x", lr, 1);
    }
    offset = append_marker_hex(line, offset, sizeof(line), " vmBase=0x", sizeof(" vmBase=0x") - 1,
                               g_jbed_base);
    {
        uintptr_t fault = signal_info == NULL ? 0 : (uintptr_t) signal_info->si_addr;
        const struct mapped_region *region = find_region(fault, 0);
        if (region != NULL) {
            offset = append_text(line, offset, sizeof(line), " faultModule=",
                                 sizeof(" faultModule=") - 1);
            offset = append_text(line, offset, sizeof(line), region->name, region->name_length);
            offset = append_marker_hex(line, offset, sizeof(line), " faultModuleBase=0x",
                                       sizeof(" faultModuleBase=0x") - 1, region->start);
            if (fault >= region->start) {
                offset = append_marker_hex(line, offset, sizeof(line), " faultModuleOffset=0x",
                                           sizeof(" faultModuleOffset=0x") - 1,
                                           fault - region->start);
            }
            offset = append_text(line, offset, sizeof(line), " perms=", sizeof(" perms=") - 1);
            offset = append_text(line, offset, sizeof(line), region->permissions,
                                 bounded_length(region->permissions, sizeof(region->permissions)));
        } else {
            offset = append_text(line, offset, sizeof(line), " faultModule=unmapped",
                                 sizeof(" faultModule=unmapped") - 1);
        }
    }
    end_crash_line(line, offset, sizeof(line));

    offset = begin_crash_line(line);
    {
        unsigned int index;
        static const char *names[13] = {"r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7",
                                        "r8", "r9", "r10", "fp", "ip"};
        for (index = 0; index <= 12; ++index) {
            offset = append_text(line, offset, sizeof(line), " ", 1);
            offset = append_text(line, offset, sizeof(line), names[index],
                                 bounded_length(names[index], 4));
            offset = append_marker_hex(line, offset, sizeof(line), "=0x", sizeof("=0x") - 1,
                                       crash_arm_register(context, index));
        }
        offset = append_marker_hex(line, offset, sizeof(line), " cpsr=0x",
                                   sizeof(" cpsr=0x") - 1, crash_arm_register(context, 16));
        /* r4/r5/r9/r10 are what a corrupted monitor-list walk leaves pointing
         * at the bad node; r1/ip are the library's own data. */
        offset = append_register_region(line, offset, sizeof(line), "r1",
                                        crash_arm_register(context, 1));
        offset = append_register_region(line, offset, sizeof(line), "r4",
                                        crash_arm_register(context, 4));
        offset = append_register_region(line, offset, sizeof(line), "r5",
                                        crash_arm_register(context, 5));
        offset = append_register_region(line, offset, sizeof(line), "r9",
                                        crash_arm_register(context, 9));
        offset = append_register_region(line, offset, sizeof(line), "r10",
                                        crash_arm_register(context, 10));
        offset = append_register_region(line, offset, sizeof(line), "ip",
                                        crash_arm_register(context, 12));
        offset = append_marker_hex(line, offset, sizeof(line), " vmPcOffset=0x",
                                   sizeof(" vmPcOffset=0x") - 1,
                                   (g_jbed_base != 0 && pc >= g_jbed_base
                                    && (pc & ~(uintptr_t) 1u) - g_jbed_base
                                            < JBED_LIBVM_IMAGE_SIZE)
                                           ? ((pc & ~(uintptr_t) 1u) - g_jbed_base)
                                           : 0);
    }
    end_crash_line(line, offset, sizeof(line));

    dump_fault_site(pc, signal_info == NULL ? 0 : (uintptr_t) signal_info->si_addr,
                    (uint32_t) crash_arm_register(context, 16));
    dump_module_writable_words(pc, 96);
}

/*
 * Observing handler: it records the fault and then hands the signal back to
 * whatever ART (or the runtime) had installed. That keeps ART's implicit null
 * checks, StackOverflowError detection and tombstone generation intact - the
 * previous implementation replaced ART's handler and re-raised with SIG_DFL,
 * which turned signals ART handles internally into process death.
 */
static void native_crash_signal_handler(int signal_number, siginfo_t *signal_info, void *context) {
    if (g_crash_handler_active) {
        signal(signal_number, SIG_DFL);
        raise(signal_number);
        _exit(128 + signal_number);
    }
    g_crash_handler_active = 1;

    (void) mkdir(JBED_PUBLIC_LOG_DIR, 0775);
    dump_crash_marker(signal_number, signal_info, context);
    /* Ask for the faulting code page to be dumped at the start of the next
     * launch, when the process is healthy, and record the page address that the
     * address translation uses at crash time. */
    probe_real_time_site("pc", crash_pc(context));
    probe_real_time_site("lr", crash_lr(context));
    dump_mapping_summary();
    dump_frame_chain(crash_arm_register(context, 11), crash_sp(context));
    dump_stack_scan(crash_sp(context));
    dump_jni_trace();

    if (signal_number > 0 && signal_number < JBED_MAX_SIGNALS
            && g_previous_signal_action_valid[signal_number]) {
        struct sigaction *previous = &g_previous_signal_actions[signal_number];
        if ((previous->sa_flags & SA_SIGINFO) != 0) {
            if (previous->sa_sigaction != NULL) {
                previous->sa_sigaction(signal_number, signal_info, context);
                return;
            }
        } else if (previous->sa_handler == SIG_IGN) {
            return;
        } else if (previous->sa_handler != NULL && previous->sa_handler != SIG_DFL) {
            previous->sa_handler(signal_number);
            return;
        }
    }
    signal(signal_number, SIG_DFL);
    raise(signal_number);
    _exit(128 + signal_number);
}


/*
 * Crash addresses are only reproducible as module + offset, because the module
 * base is randomized on every launch. The probes below re-read that location in
 * a healthy process and write the raw bytes to native.log, so the faulting
 * instruction can be decoded later without adb and without triggering another
 * crash on the device.
 */
#define JBED_PROBE_BEFORE 64u
#define JBED_PROBE_LENGTH 192u
#define JBED_PAGE_SIZE 0x1000u

static const char *hex_nibbles = "0123456789abcdef";

/* All probe output goes to one focused file, so a device without logcat needs
 * to collect only probe.log instead of scrolling through native.log. */
static void probe_log(const char *format, ...) {
    char message[1024];
    char line[1104];
    va_list args;
    int length;
    int fd;
    struct stat file_stat;

    va_start(args, format);
    vsnprintf(message, sizeof(message), format, args);
    va_end(args);
    mkdir(JBED_PUBLIC_LOG_DIR, 0775);
    if (stat(JBED_PUBLIC_LOG_DIR "/probe.log", &file_stat) == 0
            && file_stat.st_size >= (1024 * 1024)) {
        unlink(JBED_PUBLIC_LOG_DIR "/probe.log.previous");
        rename(JBED_PUBLIC_LOG_DIR "/probe.log", JBED_PUBLIC_LOG_DIR "/probe.log.previous");
    }
    length = snprintf(line, sizeof(line), "probe %s\n", message);
    if (length < 0) return;
    if (length > (int) sizeof(line) - 1) length = (int) sizeof(line) - 1;
    fd = open(JBED_PUBLIC_LOG_DIR "/probe.log", O_WRONLY | O_CREAT | O_APPEND, 0664);
    if (fd >= 0) {
        (void) write(fd, line, (size_t) length);
        close(fd);
    }
    __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "probe %s", message);
}

static uint32_t probe_u32(const unsigned char *bytes) {
    return (uint32_t) bytes[0] | ((uint32_t) bytes[1] << 8)
            | ((uint32_t) bytes[2] << 16) | ((uint32_t) bytes[3] << 24);
}

static uint16_t probe_u16(const unsigned char *bytes) {
    return (uint16_t) ((uint16_t) bytes[0] | ((uint16_t) bytes[1] << 8));
}

/* The mapping table is the only bounds check available inside the crash
 * handler, so every read is validated against it before it happens. */
static int probe_read_memory(uintptr_t address, void *buffer, size_t length) {
    const struct mapped_region *region = find_region(address, 0);
    if (region == NULL || strchr(region->permissions, 'r') == NULL) return 0;
    if (region->end - address < length) return 0;
    memcpy(buffer, (const void *) address, length);
    return 1;
}

static void probe_dump_memory(const char *label, uintptr_t address, size_t length) {
    unsigned char row[16];
    char text[3 * 16 + 2];
    size_t index;
    size_t column;

    for (index = 0; index < length; index += 16) {
        size_t chunk = length - index < 16 ? length - index : 16;
        if (!probe_read_memory(address + index, row, chunk)) {
            probe_log("%s: unreadable at 0x%08x", label, (unsigned int) (address + index));
            return;
        }
        for (column = 0; column < chunk; ++column) {
            text[3 * column] = hex_nibbles[row[column] >> 4];
            text[3 * column + 1] = hex_nibbles[row[column] & 0xf];
            text[3 * column + 2] = ' ';
        }
        text[3 * chunk] = '\0';
        probe_log("%s+0x%x: %s", label, (unsigned int) index, text);
    }
}

/* First page of an ELF mapping: the kernel only accounts for the pages after
 * it, so a mapping's virtual start follows from its end address. */
static uintptr_t region_virtual_start(const struct mapped_region *region) {
    return region->end >= JBED_PAGE_SIZE ? region->end - JBED_PAGE_SIZE : 0;
}

/*
 * Dump the module's ELF header, program headers and dynamic table as raw bytes
 * plus decoded fields. DT_* values are absolute addresses of tables that do not
 * move if the loader maps the two copies of the first page identically, and do
 * move by exactly one page if it does not. Two consecutive launches of the APK
 * therefore decide how module + offset must be interpreted - without any shell
 * access to the device.
 */
static void probe_elf_layout(const char *module) {
    size_t name_length = strlen(module);
    uintptr_t base = module_lowest_base(module, name_length);
    unsigned char header[52];
    unsigned char program_header[32];
    uint32_t program_offset;
    uint32_t program_count;
    uint32_t program_size;
    unsigned int index;
    uint32_t dynamic_vaddr = 0;
    uint32_t dynamic_size = 0;
    uintptr_t last_started = 0;

    if (base == 0) {
        probe_log("%s layout: module is not mapped", module);
        return;
    }
    if (!probe_read_memory(base, header, sizeof(header))) {
        probe_log("%s layout: header at base=0x%08x is unreadable", module,
                  (unsigned int) base);
        return;
    }
    probe_log("%s layout: base=0x%08x e_ident=%02x %02x %02x %02x class=%u data=%u "
              "e_type=%u e_machine=%u e_phoff=0x%x e_phnum=%u e_phentsize=%u entry=0x%x",
              module, (unsigned int) base, header[0], header[1], header[2], header[3],
              (unsigned int) header[4], (unsigned int) header[5],
              (unsigned int) probe_u16(header + 16), (unsigned int) probe_u16(header + 18),
              (unsigned int) probe_u32(header + 28), (unsigned int) probe_u16(header + 44),
              (unsigned int) probe_u16(header + 42), (unsigned int) probe_u32(header + 24));
    probe_dump_memory("elf-header", base, 32);

    program_offset = probe_u32(header + 28);
    program_count = probe_u16(header + 44);
    program_size = probe_u16(header + 42);
    if (program_size == 0 || program_size > sizeof(program_header)) program_size = 32;
    if (program_count > 16) program_count = 16;
    for (index = 0; index < program_count; ++index) {
        uintptr_t address = base + program_offset + (uintptr_t) index * program_size;
        uint32_t type;
        uint32_t file_offset;
        uint32_t vaddr;
        uint32_t filesz;
        uint32_t memsz;
        uint32_t flags;
        if (!probe_read_memory(address, program_header, program_size)) {
            probe_log("%s phdr[%u]: unreadable at 0x%08x", module, index,
                      (unsigned int) address);
            break;
        }
        type = probe_u32(program_header);
        file_offset = probe_u32(program_header + 4);
        vaddr = probe_u32(program_header + 8);
        filesz = probe_u32(program_header + 16);
        memsz = probe_u32(program_header + 20);
        flags = probe_u32(program_header + 24);
        probe_log("%s phdr[%u]: type=0x%08x offset=0x%x vaddr=0x%x filesz=0x%x memsz=0x%x "
                  "flags=0x%x", module, index, type, file_offset, vaddr, filesz, memsz, flags);
        if (type == 2 && dynamic_size == 0) {
            dynamic_vaddr = vaddr;
            dynamic_size = memsz;
        }
    }

    if (dynamic_size != 0) {
        probe_log("%s dynamic: vaddr=0x%x size=0x%x (base+0x%x)",
                  module, dynamic_vaddr, dynamic_size, dynamic_vaddr);
        for (index = 0; index < 32; ++index) {
            unsigned char entry[8];
            uintptr_t address = base + dynamic_vaddr + (uintptr_t) index * 8;
            if (!probe_read_memory(address, entry, sizeof(entry))) break;
            if (probe_u32(entry) == 0) break; /* DT_NULL */
            probe_log("%s dyn[%u]: tag=%u value=0x%08x", module, index,
                      probe_u32(entry), probe_u32(entry + 4));
        }
        probe_dump_memory("dynamic-table", base + dynamic_vaddr, dynamic_size < 64 ? dynamic_size : 64);
    }
    /*
     * Every mapping of the module, in address order. This is what decides how
     * "module + offset" must be interpreted: when the executable mapping starts
     * at elfBase + 0x1000, an offset taken from the mapping start is not the
     * file offset of the instruction.
     */
    {
        size_t remaining = g_mapping_count;
        size_t i;
        size_t printed = 0;
        while (remaining-- > 0) {
            size_t best_index = g_mapping_count;
            uintptr_t best_start = UINTPTR_MAX;
            for (i = 0; i < g_mapping_count; ++i) {
                const struct mapped_region *region = &g_mappings[i];
                if (region->name_length < name_length) continue;
                if (strncmp(region->name, module, name_length) != 0) continue;
                if (region->start <= last_started) continue;
                if (region->start < best_start) {
                    best_start = region->start;
                    best_index = i;
                }
            }
            if (best_index == g_mapping_count) break;
            {
                const struct mapped_region *region = &g_mappings[best_index];
                probe_log("%s layout: mapping[%u] 0x%08x-0x%08x perms=%s virtualStart=0x%08x "
                          "fromElfBase=0x%x",
                          module, (unsigned int) printed, (unsigned int) region->start,
                          (unsigned int) region->end, region->permissions,
                          (unsigned int) region_virtual_start(region),
                          (unsigned int) (region->start >= base ? region->start - base : 0));
                last_started = region->start;
            }
            ++printed;
        }
    }
}

static void probe_dump_bytes(const char *label, const struct mapped_region *region,
                             uintptr_t offset, size_t length) {
    const unsigned char *bytes;
    size_t start = offset > JBED_PROBE_BEFORE ? (size_t) offset - JBED_PROBE_BEFORE : 0;
    size_t available;
    size_t index;

    if (strchr(region->permissions, 'r') == NULL) {
        probe_log("%s %s+0x%x: region is not readable (%s)", label, region->name,
                  (unsigned int) offset, region->permissions);
        return;
    }
    if (region->start + start >= region->end) {
        probe_log("%s %s+0x%x: offset is outside the mapping", label, region->name,
                  (unsigned int) offset);
        return;
    }
    available = region->end - (region->start + start);
    if (length > available) length = available;
    bytes = (const unsigned char *) (region->start + start);
    probe_log("%s: %s mappingStart=0x%08x virtualStart=0x%08x perms=%s offset=0x%x "
              "length=0x%x", label, region->name, (unsigned int) region->start,
              (unsigned int) region_virtual_start(region), region->permissions,
              (unsigned int) start, (unsigned int) length);
    for (index = 0; index < length; index += 16) {
        size_t column;
        size_t position = 0;
        char line[3 * 16 + 2];
        char leader[192];
        for (column = 0; column < 16 && index + column < length; ++column) {
            unsigned int value = bytes[index + column];
            line[position++] = hex_nibbles[(value >> 4) & 0xf];
            line[position++] = hex_nibbles[value & 0xf];
            line[position++] = ' ';
        }
        line[position] = '\0';
        snprintf(leader, sizeof(leader), "  %s %s+0x%x", label, region->name,
                 (unsigned int) (start + index));
        probe_log("%s: %s", leader, line);
    }
}

/*
 * The same file offset can be read through two different addresses: the one
 * derived from the mapping that starts later ("regionStart + offset", which is
 * what the crash marker's pcModuleOffset uses) and the one derived from the
 * module's own ELF base ("elfBase + offset", which is what a disassembler
 * expects). Dumping both decides which one holds the instruction.
 */
static void probe_dump_file_offset(const char *label, const char *module,
                                   uintptr_t offset, size_t length) {
    uintptr_t base = module_lowest_base(module, strlen(module));
    const struct mapped_region *region;
    if (base == 0) {
        probe_log("%s %s: module is not mapped", label, module);
        return;
    }
    region = find_region(base + offset, 0);
    if (region == NULL || strchr(region->permissions, 'r') == NULL) {
        probe_log("%s %s+0x%x (from elf base 0x%08x): unreadable", label, module,
                  (unsigned int) offset, (unsigned int) base);
        return;
    }
    probe_log("%s %s elfBase=0x%08x address=0x%08x offset=0x%x pageRelative=0x%x",
              label, module, (unsigned int) base, (unsigned int) (base + offset),
              (unsigned int) offset, (unsigned int) (offset & (JBED_PAGE_SIZE - 1)));
    probe_dump_memory(label, base + offset, length);
}

static const struct mapped_region *find_module_region(const char *module_name,
                                                      size_t module_name_length,
                                                      int require_executable,
                                                      const char *required_permissions) {
    const struct mapped_region *fallback = NULL;
    size_t i;
    for (i = 0; i < g_mapping_count; ++i) {
        const struct mapped_region *region = &g_mappings[i];
        if (region->name_length < module_name_length) continue;
        if (strncmp(region->name, module_name, module_name_length) != 0) continue;
        if (require_executable && strchr(region->permissions, 'x') == NULL) continue;
        if (required_permissions != NULL && required_permissions[0] != '\0'
                && strcmp(region->permissions, required_permissions) != 0) {
            if (fallback == NULL) fallback = region;
            continue;
        }
        return region;
    }
    return fallback;
}

static int parse_hex_uint(const char *text, uintptr_t *value) {
    uintptr_t result = 0;
    int digits = 0;
    if (text == NULL) return 0;
    for (;;) {
        int digit;
        char c = *text;
        if (c >= '0' && c <= '9') digit = c - '0';
        else if (c >= 'a' && c <= 'f') digit = c - 'a' + 10;
        else if (c >= 'A' && c <= 'F') digit = c - 'A' + 10;
        else break;
        result = (result << 4) | (uintptr_t) digit;
        ++digits;
        ++text;
    }
    if (digits == 0) return 0;
    *value = result;
    return 1;
}

/* One request: <module name> <offset hex> [<length hex>] [key=value ...].
 * The only key understood here is virt=0x..., the page address observed when
 * the request was written by the crash handler. */
static void probe_handle_request(const char *module_name, const char *offset_text,
                                 const char *length_text, const char *key_text) {
    const struct mapped_region *region;
    uintptr_t offset = 0;
    uintptr_t length = JBED_PROBE_LENGTH;

    if (module_name == NULL || module_name[0] == '\0') return;
    if (!parse_hex_uint(offset_text, &offset)) return;
    if (length_text != NULL && length_text[0] != '\0'
            && !parse_hex_uint(length_text, &length)) return;
    if (length == 0 || length > 1024) length = JBED_PROBE_LENGTH;

    region = find_module_region(module_name, strlen(module_name), 0, NULL);
    if (region == NULL) {
        probe_log("%s+0x%x: module is not mapped in this process", module_name,
                  (unsigned int) offset);
        return;
    }
    if (key_text != NULL && key_text[0] != '\0') {
        const char *virt_text = strstr(key_text, "virt=0x");
        if (virt_text != NULL) {
            uintptr_t virt = 0;
            uintptr_t base = module_lowest_base(module_name, strlen(module_name));
            const struct mapped_region *direct = find_region(base + offset, 0);
            const struct mapped_region *executable = find_region(base + offset, 1);
            if (parse_hex_uint(virt_text + sizeof("virt=0x") - 1, &virt) && virt != 0) {
                /* Decisive comparison: the page address recorded at crash time
                 * against every way of deriving it now. */
                probe_log("%s+0x%x: recordedPageAddress=0x%08x elfBasePlusOffset=0x%08x "
                          "mappingEndMinusPagePlusOffset=0x%08x regionStartPlusOffset=0x%08x",
                          module_name, (unsigned int) offset, (unsigned int) virt,
                          (unsigned int) (base + offset),
                          (unsigned int) (region_virtual_start(region) + offset),
                          (unsigned int) (region->start + offset));
                if (direct != NULL) {
                    probe_log("%s+0x%x: elfBasePlusOffset is in mapping 0x%08x-0x%08x perms=%s "
                              "virtualStart=0x%08x",
                              module_name, (unsigned int) offset, (unsigned int) direct->start,
                              (unsigned int) direct->end, direct->permissions,
                              (unsigned int) region_virtual_start(direct));
                }
                if (executable != NULL) {
                    probe_log("%s+0x%x: executable mapping 0x%08x-0x%08x virtualStart=0x%08x "
                              "pageForOffset=0x%08x",
                              module_name, (unsigned int) offset,
                              (unsigned int) executable->start, (unsigned int) executable->end,
                              (unsigned int) region_virtual_start(executable),
                              (unsigned int) (region_virtual_start(executable)
                                              + (offset & (JBED_PAGE_SIZE - 1))));
                }
            }
        }
    }
    probe_dump_bytes("requested", region, offset, (size_t) length);
    probe_dump_file_offset("requested-fileoffset", module_name, offset, (size_t) length);
}

/* Requests queued by hand on the device, or by the crash handler for the next
 * launch. */
static void run_byte_probes(void) {
    FILE *probes = fopen(JBED_PUBLIC_LOG_DIR "/probe.txt", "r");
    char line[256];
    int header_written = 0;

    if (probes == NULL) return;
    while (fgets(line, sizeof(line), probes) != NULL) {
        char module_name[160];
        char offset_text[40];
        char length_text[40];
        char key_text[120];

        module_name[0] = '\0';
        offset_text[0] = '\0';
        length_text[0] = '\0';
        key_text[0] = '\0';
        if (sscanf(line, "%159s %39s %39s %119s", module_name, offset_text, length_text,
                   key_text) < 2) {
            continue;
        }
        if (module_name[0] == '#') continue;
        if (!header_written) {
            probe_log("---- probe.txt requests (this launch) ----");
            header_written = 1;
        }
        probe_handle_request(module_name, offset_text, length_text, key_text);
    }
    fclose(probes);
}

/*
 * The last crash record is re-read on the next launch: pc/lr/fault are stored
 * as module + offset, so the same code and data can be dumped while the process
 * is healthy, and the page address recorded at crash time can be compared with
 * the one computed now.
 */
static void probe_crash_record_value(const char *line, const char *name_field,
                                     const char *offset_field, const char *virt_field,
                                     const char *label, int require_executable) {
    const char *name = strstr(line, name_field);
    const char *offset_text;
    const char *permissions_text;
    char permissions[8];
    uintptr_t offset = 0;
    const char *end;
    const struct mapped_region *region;

    if (name == NULL) return;
    name += strlen(name_field);
    end = strchr(name, ' ');
    if (end == NULL || name[0] != '/') return;
    offset_text = strstr(line, offset_field);
    if (offset_text == NULL) return;
    offset_text += strlen(offset_field);
    if (!parse_hex_uint(offset_text, &offset)) return;

    permissions[0] = '\0';
    permissions_text = strstr(line, " perms=");
    if (permissions_text != NULL) {
        size_t length = 0;
        permissions_text += sizeof(" perms=") - 1;
        while (length + 1 < sizeof(permissions) && permissions_text[length] != '\0'
                && permissions_text[length] != ' ') {
            ++length;
        }
        memcpy(permissions, permissions_text, length);
        permissions[length] = '\0';
    }

    region = find_module_region(name, (size_t) (end - name), require_executable,
                                permissions[0] != '\0' ? permissions : NULL);
    if (region == NULL) {
        probe_log("%s: %.*s is not mapped in this process", label, (int) (end - name), name);
        return;
    }
    {
        /* The crash-time page address, if the record has one. */
        const char *virt_text = strstr(line, virt_field);
        if (virt_text != NULL) {
            uintptr_t virt = 0;
            uintptr_t base = module_lowest_base(name, (size_t) (end - name));
            const struct mapped_region *executable =
                    find_module_region(name, (size_t) (end - name), 1, NULL);
            virt_text += strlen(virt_field);
            if (parse_hex_uint(virt_text, &virt) && virt != 0) {
                probe_log("%s: %.*s+0x%x recordedPageAddress=0x%08x "
                          "elfBasePlusOffset=0x%08x mappingEndMinusPagePlusOffset=0x%08x "
                          "regionStartPlusOffset=0x%08x executableStartFromElfBase=0x%x",
                          label, (int) (end - name), name, (unsigned int) offset,
                          (unsigned int) virt, (unsigned int) (base + offset),
                          (unsigned int) (region_virtual_start(region) + offset),
                          (unsigned int) (region->start + offset),
                          (unsigned int) (executable != NULL && executable->start >= base
                                          ? executable->start - base : 0));
            }
        }
    }
    probe_dump_bytes(label, region, offset, JBED_PROBE_LENGTH);
    probe_dump_file_offset(label, name, offset, JBED_PROBE_LENGTH);
}

/* Two records are enough: the newest crash and the one before it. */
#define JBED_PROBE_RECORDS 2

static int probe_key_seen(char seen[][160], size_t seen_count, const char *line,
                          const char *field) {
    const char *key = strstr(line, field);
    size_t length;
    size_t i;

    if (key == NULL) return 0;
    length = bounded_length(key, sizeof(seen[0]) - 1);
    for (i = 0; i < seen_count; ++i) {
        if (strcmp(seen[i], key) == 0) return 1;
    }
    return 0;
}

static void probe_key_add(char seen[][160], size_t *seen_count, const char *line,
                          const char *field) {
    const char *key = strstr(line, field);
    size_t length;

    if (key == NULL || *seen_count >= 16) return;
    length = bounded_length(key, sizeof(seen[0]) - 1);
    memcpy(seen[*seen_count], key, length);
    seen[*seen_count][length] = '\0';
    ++*seen_count;
}

static void probe_last_crash_site(void) {
    FILE *log = fopen(JBED_PUBLIC_LOG_DIR "/native-crash.log", "r");
    char pc_lines[JBED_PROBE_RECORDS][512];
    char fault_lines[JBED_PROBE_RECORDS][512];
    size_t pc_count = 0;
    size_t fault_count = 0;
    size_t seen_count = 0;
    char seen[16][160];
    char line[1024];
    size_t i;

    if (log == NULL) {
        probe_log("---- no previous crash record ----");
        return;
    }
    while (fgets(line, sizeof(line), log) != NULL) {
        if (strstr(line, "pcModule=") != NULL) {
            memcpy(pc_lines[pc_count % JBED_PROBE_RECORDS], line, sizeof(pc_lines[0]));
            pc_lines[pc_count % JBED_PROBE_RECORDS][sizeof(pc_lines[0]) - 1] = '\0';
            ++pc_count;
        } else if (strstr(line, "faultModule=") != NULL) {
            memcpy(fault_lines[fault_count % JBED_PROBE_RECORDS], line, sizeof(fault_lines[0]));
            fault_lines[fault_count % JBED_PROBE_RECORDS][sizeof(fault_lines[0]) - 1] = '\0';
            ++fault_count;
        }
    }
    fclose(log);

    if (pc_count == 0) {
        probe_log("---- crash record present, but without a pc line ----");
        return;
    }
    probe_log("---- previous crash site (pc lines=%u fault lines=%u) ----",
              (unsigned int) pc_count, (unsigned int) fault_count);
    for (i = 0; i < JBED_PROBE_RECORDS && i < pc_count; ++i) {
        const char *pc_line = pc_lines[(pc_count - 1 - i) % JBED_PROBE_RECORDS];
        if (probe_key_seen(seen, seen_count, pc_line, "pcModule=")) continue;
        probe_key_add(seen, &seen_count, pc_line, "pcModule=");
        probe_log("-- crash %u: pc/lr line --", (unsigned int) (i + 1));
        probe_crash_record_value(pc_line, "pcModule=", " pcModuleOffset=0x", " pcRealtime=0x",
                                 "pc", 1);
        probe_crash_record_value(pc_line, "lrModule=", " lrModuleOffset=0x", " lrRealtime=0x",
                                 "lr", 1);
    }
    for (i = 0; i < JBED_PROBE_RECORDS && i < fault_count; ++i) {
        const char *fault_line = fault_lines[(fault_count - 1 - i) % JBED_PROBE_RECORDS];
        if (probe_key_seen(seen, seen_count, fault_line, "faultModule=")) continue;
        probe_key_add(seen, &seen_count, fault_line, "faultModule=");
        probe_crash_record_value(fault_line, "faultModule=", " faultModuleOffset=0x",
                                 " faultRealtime=0x", "fault", 0);
    }
}

/* Dump the ELF layout of every module that takes part in the last crash. */
static void probe_self_layout(void) {
    FILE *log = fopen(JBED_PUBLIC_LOG_DIR "/native-crash.log", "r");
    char line[1024];
    char modules[6][96];
    size_t module_count = 0;
    size_t i;

    if (log != NULL) {
        while (fgets(line, sizeof(line), log) != NULL) {
            static const char *fields[] = {"pcModule=", "lrModule=", "faultModule="};
            size_t field;
            for (field = 0; field < 3; ++field) {
                const char *name = strstr(line, fields[field]);
                const char *end;
                size_t length;
                size_t existing;
                if (name == NULL) continue;
                name += strlen(fields[field]);
                if (name[0] != '/') continue;
                end = strchr(name, ' ');
                if (end == NULL) continue;
                length = (size_t) (end - name);
                if (length >= sizeof(modules[0])) length = sizeof(modules[0]) - 1;
                for (existing = 0; existing < module_count; ++existing) {
                    if (strlen(modules[existing]) == length
                            && strncmp(modules[existing], name, length) == 0) {
                        break;
                    }
                }
                if (existing < module_count) continue;
                if (module_count >= sizeof(modules) / sizeof(modules[0])) break;
                memcpy(modules[module_count], name, length);
                modules[module_count][length] = '\0';
                ++module_count;
            }
        }
        fclose(log);
    }
    if (module_count == 0) {
        /* No crash record yet: still describe the platform's own libraries so
         * the first capture already contains the layout. */
        static const char *defaults[] = {
            "/apex/com.android.art/lib/libandroidio.so",
            "/apex/com.android.art/lib/libjavacore.so"
        };
        probe_log("---- elf layout of default platform modules ----");
        for (i = 0; i < sizeof(defaults) / sizeof(defaults[0]); ++i) {
            probe_elf_layout(defaults[i]);
        }
        return;
    }
    probe_log("---- elf layout of modules from the last crash ----");
    for (i = 0; i < module_count; ++i) {
        probe_log("module base: %s -> 0x%08x", modules[i],
                  (unsigned int) module_lowest_base(modules[i], strlen(modules[i])));
        probe_elf_layout(modules[i]);
    }
}

/*
 * Real-time probe from the signal handler: record where the offset of a faulting
 * address starts from (the mapping or the module's ELF base) and ask for that
 * region to be dumped at the start of the next launch, when the process is
 * healthy. Only pre-formatted lines and small reads are used, so the handler
 * stays async-signal-safe.
 */
static void probe_real_time_site(const char *label, uintptr_t value) {
    const struct mapped_region *region;
    uintptr_t address = value & ~(uintptr_t) 1u;
    uintptr_t base;
    uintptr_t from_mapping;
    uintptr_t from_base;
    uintptr_t virt;
    char request[512];
    char record[320];
    int length;
    int fd;

    if (address == 0) return;
    region = find_region(address, 0);
    if (region == NULL || region->name[0] != '/' || region->name_length == 0) return;
    base = module_lowest_base(region->name, region->name_length);
    if (base == 0 || address < base) return;
    from_mapping = address - region->start;
    from_base = address - base;
    virt = region_virtual_start(region) + (from_mapping & (JBED_PAGE_SIZE - 1));

    length = snprintf(record, sizeof(record),
                      "%s: module=%s value=0x%08x elfBase=0x%08x offsetFromElfBase=0x%x "
                      "offsetFromMapping=0x%x mappingStart=0x%08x virtualStart=0x%08x "
                      "pageForOffset=0x%08x\n",
                      label, region->name, (unsigned int) address, (unsigned int) base,
                      (unsigned int) from_base, (unsigned int) from_mapping,
                      (unsigned int) region->start, (unsigned int) region_virtual_start(region),
                      (unsigned int) virt);
    if (length > 0) {
        if (length > (int) sizeof(record) - 1) length = (int) sizeof(record) - 1;
        fd = open(JBED_PUBLIC_LOG_DIR "/probe.log", O_WRONLY | O_CREAT | O_APPEND, 0664);
        if (fd >= 0) {
            (void) write(fd, record, (size_t) length);
            close(fd);
        }
    }

    {
        struct stat probes_stat;
        if (stat(JBED_PUBLIC_LOG_DIR "/probe.txt", &probes_stat) == 0
                && probes_stat.st_size >= 8192) {
            unlink(JBED_PUBLIC_LOG_DIR "/probe.txt.previous");
            rename(JBED_PUBLIC_LOG_DIR "/probe.txt", JBED_PUBLIC_LOG_DIR "/probe.txt.previous");
        }
    }
    fd = open(JBED_PUBLIC_LOG_DIR "/probe.txt", O_WRONLY | O_CREAT | O_APPEND, 0664);
    if (fd < 0) return;
    /* Both interpretations of the offset are requested; the dumped pages and the
     * recorded page address together show which one is the instruction. */
    length = snprintf(request, sizeof(request), "%.*s %x 300 virt=0x%x\n",
                      (int) region->name_length, region->name, (unsigned int) from_mapping,
                      (unsigned int) virt);
    if (length > 0) {
        (void) write(fd, request, (size_t) (length > (int) sizeof(request) - 1
                                            ? (int) sizeof(request) - 1 : length));
    }
    length = snprintf(request, sizeof(request), "%.*s %x 300 virt=0x%x\n",
                      (int) region->name_length, region->name, (unsigned int) from_base,
                      (unsigned int) virt);
    if (length > 0) {
        (void) write(fd, request, (size_t) (length > (int) sizeof(request) - 1
                                            ? (int) sizeof(request) - 1 : length));
    }
    close(fd);
}

/*
 * libcore sends this signal to a thread that is blocked in a syscall when the
 * Java FileDescriptor it uses is closed. Observing it (and chaining to the
 * handler libcore installed) shows whether the platform was closing descriptors
 * around the fault without changing what the signal does: its only job is to
 * interrupt the syscall, so the flags must stay exactly as libcore set them
 * (no SA_RESTART, no SA_SIGINFO) and the handler must return normally.
 */
static struct sigaction g_blocked_thread_signal_action;
static int g_blocked_thread_signal_action_valid;

static void blocked_thread_signal_handler(int signal_number) {
    static const char notice[] = "I/jbed-jni-compat observed libcore blocked-thread signal\n";
    int fd;

    ++g_blocked_thread_signals_seen;
    fd = open(JBED_NATIVE_LOG_PATH, O_WRONLY | O_CREAT | O_APPEND, 0664);
    if (fd >= 0) {
        (void) write(fd, notice, sizeof(notice) - 1);
        close(fd);
    }
    if (g_blocked_thread_signal_action_valid) {
        struct sigaction *previous = &g_blocked_thread_signal_action;
        if (previous->sa_handler != NULL && previous->sa_handler != SIG_DFL
                && previous->sa_handler != SIG_IGN) {
            previous->sa_handler(signal_number);
        }
    }
}

static void install_blocked_thread_observer(void) {
    struct sigaction current;
    struct sigaction action;

    if (access(JBED_DISABLE_BLOCKED_THREAD_OBSERVER_MARKER, F_OK) == 0) {
        LOGI("blocked-thread signal observer disabled by %s",
             JBED_DISABLE_BLOCKED_THREAD_OBSERVER_MARKER);
        return;
    }
    if (sigaction(JBED_BLOCKED_THREAD_SIGNAL, NULL, &current) != 0) {
        LOGI("unable to query signal %d: errno=%d", JBED_BLOCKED_THREAD_SIGNAL, errno);
        return;
    }
    if (current.sa_handler == SIG_DFL || current.sa_handler == SIG_IGN) {
        /* Nothing installed the handler yet; swallowing the signal here would
         * change its meaning, so leave it alone. */
        LOGI("signal %d has no libcore handler yet; observer not installed",
             JBED_BLOCKED_THREAD_SIGNAL);
        return;
    }
    memset(&action, 0, sizeof(action));
    sigemptyset(&action.sa_mask);
    action.sa_handler = blocked_thread_signal_handler;
    action.sa_flags = 0;
    if (sigaction(JBED_BLOCKED_THREAD_SIGNAL, &action, &g_blocked_thread_signal_action) == 0) {
        g_blocked_thread_signal_action_valid = 1;
        LOGI("observing libcore blocked-thread signal %d (chained to the existing handler)",
             JBED_BLOCKED_THREAD_SIGNAL);
    } else {
        LOGI("unable to observe signal %d: errno=%d", JBED_BLOCKED_THREAD_SIGNAL, errno);
    }
}

static char g_crash_alt_stack[128 * 1024];

static void install_native_crash_handlers(void) {
    static const int signals[] = {SIGSEGV, SIGABRT, SIGBUS, SIGILL, SIGFPE};
    struct sigaction action;
    stack_t alt_stack;
    size_t i;

    if (access(JBED_DISABLE_CRASH_HANDLER_MARKER, F_OK) == 0) {
        LOGI("native crash marker disabled by %s", JBED_DISABLE_CRASH_HANDLER_MARKER);
        return;
    }

    /* SA_ONSTACK only works when the process has an alternate stack; without
     * one a stack-overflow fault re-faults inside this handler and the marker
     * is lost. 128 KiB is larger than the runtime's own alternate stack. */
    memset(&alt_stack, 0, sizeof(alt_stack));
    alt_stack.ss_sp = g_crash_alt_stack;
    alt_stack.ss_size = sizeof(g_crash_alt_stack);
    alt_stack.ss_flags = 0;
    if (sigaltstack(&alt_stack, NULL) != 0) {
        LOGI("unable to install the crash alternate stack: errno=%d", errno);
    }

    memset(&action, 0, sizeof(action));
    sigemptyset(&action.sa_mask);
    action.sa_sigaction = native_crash_signal_handler;
    action.sa_flags = SA_SIGINFO | SA_ONSTACK;
    for (i = 0; i < sizeof(signals) / sizeof(signals[0]); ++i) {
        int signal_number = signals[i];
        if (signal_number >= JBED_MAX_SIGNALS) continue;
        if (sigaction(signal_number, &action, &g_previous_signal_actions[signal_number]) == 0) {
            g_previous_signal_action_valid[signal_number] = 1;
        }
    }
    g_native_crash_handler_installed = 1;
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

/*
 * dl_iterate_phdr is not available on Android 4.4/API 19, and dladdr is not
 * consistently exposed by old NDK levels. /proc/self/maps is stable enough for
 * this diagnostic compatibility shim and keeps the API-19 build path usable.
 * Pick the lowest mapped address for libjbedvm.so; this ELF's first LOAD
 * segment has p_vaddr == p_offset == 0, so it is the base used by all offsets.
 */
static void scan_process_mappings(uintptr_t *best_base) {
    FILE *maps;
    char line[512];
    uintptr_t best = UINTPTR_MAX;

    maps = fopen("/proc/self/maps", "r");
    if (maps == NULL) {
        LOGE("unable to open /proc/self/maps while locating libjbedvm base: errno=%d", errno);
        return;
    }
    g_mapping_count = 0;
    g_mapping_row_count = 0;
    g_mapping_table_truncated = 0;
    while (fgets(line, sizeof(line), maps) != NULL) {
        unsigned long start;
        unsigned long end;
        char permissions[5];
        char pathname[256];
        int fields;

        permissions[0] = '\0';
        pathname[0] = '\0';
        fields = sscanf(line, "%lx-%lx %4s %*lx %*s %*s %255[^\n]",
                        &start, &end, permissions, pathname);
        if (fields >= 3) ++g_mapping_row_count;
        if (fields >= 3 && g_mapping_count < JBED_MAX_MAPPINGS) {
            struct mapped_region *region = &g_mappings[g_mapping_count++];
            region->start = (uintptr_t) start;
            region->end = (uintptr_t) end;
            memcpy(region->permissions, permissions, sizeof(region->permissions));
            region->permissions[sizeof(region->permissions) - 1] = '\0';
            if (fields >= 4 && pathname[0] != '\0') {
                size_t name_length = bounded_length(pathname, sizeof(region->name) - 1);
                memcpy(region->name, pathname, name_length);
                region->name[name_length] = '\0';
                region->name_length = name_length;
            } else {
                static const char anonymous_name[] = "[anon]";
                memcpy(region->name, anonymous_name, sizeof(anonymous_name));
                region->name_length = sizeof(anonymous_name) - 1;
            }
        }
        if (fields >= 4 && strstr(pathname, "libjbedvm.so") != NULL
                && (uintptr_t) start < best) {
            best = (uintptr_t) start;
        }
    }
    fclose(maps);
    /* Rows beyond the table capacity mean a module reported as "not mapped"
     * may simply not have been recorded; say so instead of implying absence. */
    if (g_mapping_row_count > g_mapping_count) g_mapping_table_truncated = 1;
    *best_base = best;
}

/* The file-backed mapping of a module: the lowest r--p region of that file.
 * Column 3 of /proc/self/maps is the *mapping* offset (0 for the ELF header
 * page), not a section offset such as 0x748, which is why this base is only
 * used to name the region a register points into. */
static uintptr_t module_lowest_base(const char *name, size_t name_length) {
    uintptr_t lowest = UINTPTR_MAX;
    size_t i;

    if (name == NULL || name_length == 0) return 0;
    for (i = 0; i < g_mapping_count; ++i) {
        const struct mapped_region *region = &g_mappings[i];
        if (region->name_length < name_length) continue;
        if (strncmp(region->name, name, name_length) != 0) continue;
        if (strchr(region->permissions, 'r') == NULL) continue;
        if (region->start < lowest) lowest = region->start;
    }
    return lowest == UINTPTR_MAX ? 0 : lowest;
}

static void ensure_jbed_base(void) {
    uintptr_t best = UINTPTR_MAX;

    if (g_jbed_base != 0) return;
    scan_process_mappings(&best);
    if (best != UINTPTR_MAX) {
        g_jbed_base = best;
    } else {
        LOGE("libjbedvm.so mapping not found in /proc/self/maps");
    }
}

/* Libraries and JIT regions created after startup must also be attributable in
 * a crash report, so the map table is refreshed while the process is healthy. */
static void refresh_process_mappings(void) {
    uintptr_t best = UINTPTR_MAX;
    scan_process_mappings(&best);
    if (best != UINTPTR_MAX) {
        g_jbed_base = best;
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
    /* The last VM -> Java upcalls are the most useful evidence when the Java
     * side answered a VM callback with a StackOverflowError. */
    refresh_process_mappings();
    dump_jni_trace();
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
    jclass result;
    clear_pending_exception(env);
    result = g_original_table->FindClass(env, name);
    if (name != NULL && result != NULL) {
        /* Remember the class so the following GetMethodID/GetStaticMethodID
         * calls can be labelled with "Class.method" in the JNI trace. */
        size_t name_length = bounded_length(name, sizeof(g_last_find_class_name) - 1);
        memcpy(g_last_find_class_name, name, name_length);
        g_last_find_class_name[name_length] = '\0';
        g_last_find_class = (uintptr_t) result;
    }
    return result;
}

static jmethodID JNICALL hooked_get_method_id(JNIEnv *env, jclass clazz,
                                               const char *name, const char *signature) {
    jmethodID result;
    clear_pending_exception(env);
    result = g_original_get_method_id(env, clazz, name, signature);
    if (result != NULL) {
        trace_remember_method(result, 0, name, signature,
                              clazz != NULL && (uintptr_t) clazz == g_last_find_class);
    }
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
    if (g_vm_state_change_method != NULL && method == g_vm_state_change_method) {
        trace_record(JBED_TRACE_VM_STATE_CHANGE, method, new_state, reason, "vmStateChange");
    }
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

    trace_and_clear_exception(env, "CallBooleanMethod", JBED_TRACE_CALL_BOOLEAN, method);
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
    trace_and_clear_exception(env, "CallBooleanMethodV", JBED_TRACE_CALL_BOOLEAN, method);
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
    trace_and_clear_exception(env, "CallBooleanMethodA", JBED_TRACE_CALL_BOOLEAN, method);
    if (g_vm_state_change_method != NULL && method == g_vm_state_change_method && args != NULL) {
        maybe_enable_low_quantum_for_vm_state(env, method, args[0].z, args[1].i, args[2].i, args[3].i);
    }
    return g_original_table->CallBooleanMethodA(env, obj, method, args);
}

/*
 * Generic pass-through call hooks. They only add the upcall to the JNI trace
 * ring and otherwise delegate to the original JNIEnv entry, so the VM sees the
 * unmodified JNI behaviour. The boolean and static-object variants keep their
 * dedicated hooks because those also carry the scheduler workarounds.
 */
#define JBED_VOID_CALL_HOOKS(TABLE_FIELD, CALL_PREFIX, TRACE_KIND, FIRST_ARGUMENT_TYPE)                \
static void JNICALL hook_##TABLE_FIELD##_v(JNIEnv *env, FIRST_ARGUMENT_TYPE first, jmethodID method,   \
                                           va_list args) {                                             \
    trace_and_clear_exception(env, CALL_PREFIX "V", TRACE_KIND, method);                               \
    g_original_table->TABLE_FIELD##V(env, first, method, args);                                        \
}                                                                                                      \
static void JNICALL hook_##TABLE_FIELD##_a(JNIEnv *env, FIRST_ARGUMENT_TYPE first, jmethodID method,   \
                                           const jvalue *args) {                                       \
    trace_and_clear_exception(env, CALL_PREFIX "A", TRACE_KIND, method);                               \
    g_original_table->TABLE_FIELD##A(env, first, method, args);                                        \
}                                                                                                      \
static void JNICALL hook_##TABLE_FIELD(JNIEnv *env, FIRST_ARGUMENT_TYPE first, jmethodID method, ...) {\
    va_list args;                                                                                      \
    trace_and_clear_exception(env, CALL_PREFIX, TRACE_KIND, method);                                   \
    va_start(args, method);                                                                            \
    g_original_table->TABLE_FIELD##V(env, first, method, args);                                        \
    va_end(args);                                                                                      \
}

#define JBED_VALUE_CALL_HOOKS(RETURN_TYPE, TABLE_FIELD, CALL_PREFIX, TRACE_KIND, FIRST_ARGUMENT_TYPE)  \
static RETURN_TYPE JNICALL hook_##TABLE_FIELD##_v(JNIEnv *env, FIRST_ARGUMENT_TYPE first,              \
                                                  jmethodID method, va_list args) {                    \
    trace_and_clear_exception(env, CALL_PREFIX "V", TRACE_KIND, method);                               \
    return g_original_table->TABLE_FIELD##V(env, first, method, args);                                 \
}                                                                                                      \
static RETURN_TYPE JNICALL hook_##TABLE_FIELD##_a(JNIEnv *env, FIRST_ARGUMENT_TYPE first,              \
                                                  jmethodID method, const jvalue *args) {              \
    trace_and_clear_exception(env, CALL_PREFIX "A", TRACE_KIND, method);                               \
    return g_original_table->TABLE_FIELD##A(env, first, method, args);                                 \
}                                                                                                      \
static RETURN_TYPE JNICALL hook_##TABLE_FIELD(JNIEnv *env, FIRST_ARGUMENT_TYPE first,                  \
                                              jmethodID method, ...) {                                 \
    va_list args;                                                                                      \
    RETURN_TYPE result;                                                                                \
    trace_and_clear_exception(env, CALL_PREFIX, TRACE_KIND, method);                                   \
    va_start(args, method);                                                                            \
    result = g_original_table->TABLE_FIELD##V(env, first, method, args);                               \
    va_end(args);                                                                                      \
    return result;                                                                                     \
}

JBED_VOID_CALL_HOOKS(CallVoidMethod, "CallVoidMethod", JBED_TRACE_CALL_VOID, jobject)
JBED_VOID_CALL_HOOKS(CallStaticVoidMethod, "CallStaticVoidMethod", JBED_TRACE_CALL_STATIC_VOID, jclass)
JBED_VALUE_CALL_HOOKS(jint, CallIntMethod, "CallIntMethod", JBED_TRACE_CALL_INT, jobject)
JBED_VALUE_CALL_HOOKS(jobject, CallObjectMethod, "CallObjectMethod", JBED_TRACE_CALL_OBJECT, jobject)
JBED_VALUE_CALL_HOOKS(jint, CallStaticIntMethod, "CallStaticIntMethod", JBED_TRACE_CALL_STATIC_INT,
                      jclass)
JBED_VALUE_CALL_HOOKS(jboolean, CallStaticBooleanMethod, "CallStaticBooleanMethod",
                      JBED_TRACE_CALL_STATIC_BOOLEAN, jclass)

#define JBED_INSTALL_CALL_HOOKS(TABLE_FIELD)                                                           \
    g_hook_table->TABLE_FIELD = hook_##TABLE_FIELD;                                                    \
    g_hook_table->TABLE_FIELD##V = hook_##TABLE_FIELD##_v;                                             \
    g_hook_table->TABLE_FIELD##A = hook_##TABLE_FIELD##_a

static jmethodID JNICALL hooked_get_static_method_id(JNIEnv *env, jclass clazz,
                                                      const char *name, const char *signature) {
    jmethodID result;
    clear_pending_exception(env);
    result = g_original_table->GetStaticMethodID(env, clazz, name, signature);
    if (result != NULL) {
        trace_remember_method(result, 1, name, signature,
                              clazz != NULL && (uintptr_t) clazz == g_last_find_class);
    }
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
    trace_and_clear_exception(env, "CallStaticObjectMethod", JBED_TRACE_CALL_STATIC_OBJECT, method);
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
    trace_and_clear_exception(env, "CallStaticObjectMethodV", JBED_TRACE_CALL_STATIC_OBJECT, method);
    if (g_midp_get_string_method != NULL && method == g_midp_get_string_method) {
        return (*env)->NewStringUTF(env, "<unknown>");
    }
    if (g_file_get_roots_method != NULL && method == g_file_get_roots_method) {
        return make_legacy_roots(env);
    }
    return g_original_table->CallStaticObjectMethodV(env, clazz, method, args);
}

static jobject JNICALL hooked_call_static_object_method_a(JNIEnv *env, jclass clazz, jmethodID method, const jvalue *args) {
    trace_and_clear_exception(env, "CallStaticObjectMethodA", JBED_TRACE_CALL_STATIC_OBJECT, method);
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
    refresh_process_mappings();
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
    JBED_INSTALL_CALL_HOOKS(CallVoidMethod);
    JBED_INSTALL_CALL_HOOKS(CallStaticVoidMethod);
    JBED_INSTALL_CALL_HOOKS(CallIntMethod);
    JBED_INSTALL_CALL_HOOKS(CallObjectMethod);
    JBED_INSTALL_CALL_HOOKS(CallStaticIntMethod);
    JBED_INSTALL_CALL_HOOKS(CallStaticBooleanMethod);
    *env = g_hook_table;
    LOGI("installed JNI lifetime hook and upcall trace for libjbedvm at %p (trace=%s)",
         (void *) g_jbed_base, g_jni_trace_enabled ? "enabled" : "disabled");
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
    if (access(JBED_DISABLE_JNI_TRACE_MARKER, F_OK) == 0) {
        g_jni_trace_enabled = 0;
    }
    install_native_crash_handlers();
    install_blocked_thread_observer();
    LOGI("native crash marker handlers installed=%d (chained to the previous handlers); "
         "jniTrace=%d blockedThreadObserver=%d",
         g_native_crash_handler_installed, g_jni_trace_enabled,
         g_blocked_thread_signal_action_valid);
    if ((*vm)->GetEnv(vm, (void **) &env, JNI_VERSION_1_6) != JNI_OK) return JNI_ERR;

    ensure_jbed_base();
    refresh_process_mappings();
    probe_self_layout();
    probe_last_crash_site();
    run_byte_probes();
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
