#include <jni.h>
#include <android/log.h>
#include <inttypes.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "instance.h"
#include "model.h"

extern const JbedBootImage jbed_boot_image;
extern int jbed_android_initialize(JNIEnv *env);

enum { MANAGED_STACK_BYTES = 256 * 1024 };
static JbedInstance *instance;
static const JbedBootMethod *program;
static char program_status[512];

static int diagnostic_fd = -1;

/* Deliberately not a signal handler: preserve Android's native crash reporter.
 * Flush ordinary-code checkpoints before entering unverified startup paths. */
static void diagnostic_phase(void *context, const char *phase)
{
    (void)context;
    __android_log_print(ANDROID_LOG_INFO, "JbedSource", "%s", phase);
    if (diagnostic_fd < 0) return;
    char line[1024];
    int size = snprintf(line, sizeof line, "[pid %ld] %s\n", (long)getpid(), phase);
    size_t remaining = size < 0 ? 0 : (size_t)size < sizeof line ? (size_t)size : sizeof line - 1;
    const char *cursor = line;
    while (remaining) {
        ssize_t written = write(diagnostic_fd, cursor, remaining);
        if (written < 0 && errno == EINTR) continue;
        if (written <= 0) break;
        cursor += written;
        remaining -= (size_t)written;
    }
    (void)fsync(diagnostic_fd);
}

JNIEXPORT jboolean JNICALL Java_org_jbed_source_MainActivity_nativeConfigureDiagnostics(
    JNIEnv *env, jclass type, jstring path)
{
    (void)type;
    if (diagnostic_fd >= 0) return JNI_TRUE;
    const char *name = (*env)->GetStringUTFChars(env, path, NULL);
    if (!name) return JNI_FALSE;
    diagnostic_fd = open(name, O_WRONLY | O_CREAT | O_APPEND | O_CLOEXEC, 0600);
    (*env)->ReleaseStringUTFChars(env, path, name);
    return diagnostic_fd >= 0 ? JNI_TRUE : JNI_FALSE;
}

static void diagnostic_begin(const JbedBootMethod *method)
{
    struct stat info;
    if (diagnostic_fd >= 0 && !fstat(diagnostic_fd, &info) && info.st_size > 256 * 1024)
        (void)ftruncate(diagnostic_fd, 0);
    char phase[512];
    snprintf(phase, sizeof phase, "BEGIN %s.%s%s", method->owner, method->name, method->descriptor);
    diagnostic_phase(NULL, phase);
}

static void diagnostic_instance(void)
{
    jbed_instance_set_diagnostic(instance, diagnostic_phase, NULL);
    const JbedLoadedBoot *boot = jbed_instance_image(instance);
    char phase[256];
    snprintf(phase, sizeof phase, "image base=0x%08" PRIx32 " bytes=%zu; writable offset=0x%08" PRIx32,
        boot->memory.address, boot->image->size, boot->executable_size);
    diagnostic_phase(NULL, phase);
}

static const char *throwable_name(JbedAddress object)
{
    if (!object) return "no managed throwable";
    uint32_t tag, klass;
    memcpy(&tag, (const void *)(uintptr_t)object, sizeof tag);
    memcpy(&klass, (const void *)(uintptr_t)tag, sizeof klass);
    const JbedLoadedBoot *boot = jbed_instance_image(instance);
    for (size_t i = 0; i < boot->image->class_count; ++i)
        if (boot->memory.address + boot->image->classes[i].offset == klass)
            return boot->image->classes[i].name;
    return "dynamically loaded throwable";
}

static bool selectable(const JbedBootMethod *method)
{
    return (method->flags & JBED_ACC_STATIC) && !(method->flags & JBED_ACC_ABSTRACT) &&
           method->name[0] != '<';
}

static const JbedBootMethod *selected_method(jint selected)
{
    if (selected < 0)
        return NULL;
    for (size_t i = 0; i < jbed_boot_image.method_count; ++i) {
        const JbedBootMethod *method = &jbed_boot_image.methods[i];
        if (selectable(method) && selected-- == 0)
            return method;
    }
    return NULL;
}

static int argument_words(const char *descriptor)
{
    if (*descriptor++ != '(')
        return -1;
    int count = 0;
    while (*descriptor && *descriptor != ')') {
        bool array = false;
        while (*descriptor == '[') {
            array = true;
            ++descriptor;
        }
        char kind = *descriptor++;
        if (kind == 'L') {
            const char *end = strchr(descriptor, ';');
            if (!end)
                return -1;
            descriptor = end + 1;
        } else if (!strchr("ZBCSIFJD", kind)) {
            return -1;
        }
        count += !array && (kind == 'J' || kind == 'D') ? 2 : 1;
    }
    return *descriptor == ')' ? count : -1;
}

JNIEXPORT jstring JNICALL Java_org_jbed_source_MainActivity_nativeDescribe(JNIEnv *env, jclass type)
{
    (void)type;
    char text[256];
    snprintf(text, sizeof text, "Source-built ARM32 runtime\n%zu classes · %zu methods\n"
        "Boot image: %zu bytes\nManaged heap: %u bytes",
        jbed_boot_image.class_count, jbed_boot_image.method_count, jbed_boot_image.size,
        (unsigned)JBED_ANDROID_HEAP_BYTES);
    return (*env)->NewStringUTF(env, text);
}

JNIEXPORT jobjectArray JNICALL Java_org_jbed_source_MainActivity_nativeMethods(JNIEnv *env, jclass type)
{
    (void)type;
    jsize count = 0;
    for (size_t i = 0; i < jbed_boot_image.method_count; ++i)
        count += selectable(&jbed_boot_image.methods[i]);
    jclass strings = (*env)->FindClass(env, "java/lang/String");
    if (!strings)
        return NULL;
    jobjectArray entries = (*env)->NewObjectArray(env, count, strings, NULL);
    (*env)->DeleteLocalRef(env, strings);
    if (!entries)
        return NULL;
    jsize index = 0;
    for (size_t i = 0; i < jbed_boot_image.method_count; ++i) {
        const JbedBootMethod *method = &jbed_boot_image.methods[i];
        if (!selectable(method))
            continue;
        size_t size = strlen(method->owner) + strlen(method->name) + strlen(method->descriptor) + 2;
        char *label = malloc(size);
        if (!label) {
            jclass error = (*env)->FindClass(env, "java/lang/OutOfMemoryError");
            if (error) (*env)->ThrowNew(env, error, "Method list");
            return NULL;
        }
        snprintf(label, size, "%s.%s%s", method->owner, method->name, method->descriptor);
        jstring value = (*env)->NewStringUTF(env, label);
        free(label);
        if (!value)
            return NULL;
        (*env)->SetObjectArrayElement(env, entries, index++, value);
        (*env)->DeleteLocalRef(env, value);
    }
    return entries;
}

JNIEXPORT jint JNICALL Java_org_jbed_source_MainActivity_nativeArgumentWords(JNIEnv *env, jclass type,
                                                                            jint method_index)
{
    (void)env; (void)type;
    const JbedBootMethod *method = selected_method(method_index);
    return method ? argument_words(method->descriptor) : -1;
}

JNIEXPORT jstring JNICALL Java_org_jbed_source_MainActivity_nativeRun(JNIEnv *env, jclass type,
    jint method_index, jintArray arguments)
{
    (void)type;
    const JbedBootMethod *method = selected_method(method_index);
    if (!method)
        return (*env)->NewStringUTF(env, "No static method selected");
    jsize count = (*env)->GetArrayLength(env, arguments);
    if (count != argument_words(method->descriptor))
        return (*env)->NewStringUTF(env, "Argument count does not match the method descriptor");
    char message[512];
    diagnostic_begin(method);
    if (!instance) {
        diagnostic_phase(NULL, "direct call: create VM instance");
        instance = jbed_instance_create(&jbed_boot_image, JBED_ANDROID_HEAP_BYTES,
                                       MANAGED_STACK_BYTES, message, sizeof message);
        if (!instance)
            return (*env)->NewStringUTF(env, message);
        diagnostic_instance();
        diagnostic_phase(NULL, "direct call: initialize VM services");
        if (JBED_ANDROID_INITIALIZE && !jbed_instance_initialize(instance, message, sizeof message)) {
            jbed_instance_destroy(instance);
            instance = NULL;
            return (*env)->NewStringUTF(env, message);
        }
    }
    uint32_t *words = count ? malloc((size_t)count * sizeof(*words)) : NULL;
    if (count && !words)
        return (*env)->NewStringUTF(env, "Cannot allocate native argument buffer");
    if (count)
        (*env)->GetIntArrayRegion(env, arguments, 0, count, (jint *)words);
    if ((*env)->ExceptionCheck(env)) {
        free(words);
        return NULL;
    }
    uint64_t result = 0;
    JbedAddress throwable = 0;
    diagnostic_phase(NULL, "direct call: invoke managed method");
    bool success = jbed_instance_call(instance, method->owner, method->name, method->descriptor,
                                     words, (size_t)count, &result, &throwable);
    free(words);
    const char *return_type = strchr(method->descriptor, ')');
    if (!success) {
        snprintf(message, sizeof message, "%s.%s%s\nJava exception: %s (0x%08" PRIx32 ")",
                 method->owner, method->name, method->descriptor, throwable_name(throwable), throwable);
    } else if (return_type && return_type[1] == 'V') {
        snprintf(message, sizeof message, "%s.%s%s\nReturned normally (void)",
                 method->owner, method->name, method->descriptor);
    } else {
        char value[96];
        switch (return_type ? return_type[1] : 0) {
        case 'J': snprintf(value, sizeof value, "%" PRId64, (int64_t)result); break;
        case 'F': {
            uint32_t bits = (uint32_t)result;
            float number;
            memcpy(&number, &bits, sizeof number);
            snprintf(value, sizeof value, "%.9g", (double)number);
            break;
        }
        case 'D': {
            double number;
            memcpy(&number, &result, sizeof number);
            snprintf(value, sizeof value, "%.17g", number);
            break;
        }
        case 'Z': snprintf(value, sizeof value, "%s", (uint32_t)result ? "true" : "false"); break;
        case 'L': case '[':
            snprintf(value, sizeof value, "reference 0x%08" PRIx32, (uint32_t)result);
            break;
        default: snprintf(value, sizeof value, "%" PRId32, (int32_t)result); break;
        }
        snprintf(message, sizeof message, "%s.%s%s\nResult: %s",
            method->owner, method->name, method->descriptor, value);
    }
    diagnostic_phase(NULL, message);
    return (*env)->NewStringUTF(env, message);
}

JNIEXPORT jstring JNICALL Java_org_jbed_source_MainActivity_nativeStartMain(JNIEnv *env, jclass type,
    jint method_index, jobjectArray arguments)
{
    (void)type;
    const JbedBootMethod *method = selected_method(method_index);
    if (!method || strcmp(method->name, "main") ||
        strcmp(method->descriptor, "([Ljava/lang/String;)V"))
        return (*env)->NewStringUTF(env, "Select a main(String[]) entry");
    jsize count = (*env)->GetArrayLength(env, arguments);
    char **argv = calloc((size_t)count + 1, sizeof(*argv));
    if (!argv)
        return (*env)->NewStringUTF(env, "Cannot allocate program arguments");
    const char *problem = NULL;
    for (jsize i = 0; i < count; ++i) {
        jbyteArray bytes = (*env)->GetObjectArrayElement(env, arguments, i);
        if (!bytes) { problem = "Missing program argument"; break; }
        jsize size = (*env)->GetArrayLength(env, bytes);
        argv[i] = malloc((size_t)size + 1);
        if (argv[i]) {
            (*env)->GetByteArrayRegion(env, bytes, 0, size, (jbyte *)argv[i]);
            argv[i][size] = 0;
            if (memchr(argv[i], 0, (size_t)size)) problem = "Program arguments cannot contain NUL";
        } else {
            problem = "Cannot allocate program argument";
        }
        (*env)->DeleteLocalRef(env, bytes);
        if (problem || (*env)->ExceptionCheck(env)) break;
    }
    bool started = false;
    if (!problem && !(*env)->ExceptionCheck(env)) {
        diagnostic_begin(method);
        diagnostic_phase(NULL, "main: destroy previous VM instance");
        jbed_instance_destroy(instance);
        instance = NULL;
        program = NULL;
        diagnostic_phase(NULL, "main: create fresh VM instance");
        instance = jbed_instance_create(&jbed_boot_image, JBED_ANDROID_HEAP_BYTES,
                                       MANAGED_STACK_BYTES, program_status, sizeof program_status);
        if (instance) {
            diagnostic_instance();
            started = jbed_instance_start_main(instance, method->owner, count,
                (const char *const *)argv, NULL, program_status, sizeof program_status);
        }
        diagnostic_phase(NULL, started ? "main: startup returned successfully" : program_status);
        if (started) program = method;
        else {
            jbed_instance_destroy(instance);
            instance = NULL;
            problem = program_status;
        }
    }
    for (jsize i = 0; i < count; ++i) free(argv[i]);
    free(argv);
    if ((*env)->ExceptionCheck(env)) return NULL;
    return started ? NULL : (*env)->NewStringUTF(env, problem);
}

JNIEXPORT jint JNICALL Java_org_jbed_source_MainActivity_nativeIterate(JNIEnv *env, jclass type,
                                                                     jint slice_millis)
{
    (void)env; (void)type;
    if (!instance || !program) return INT32_MIN;
    int32_t delay, status;
    char error[256];
    if (!jbed_instance_iterate(instance, slice_millis, &delay, &status, error, sizeof error)) {
        snprintf(program_status, sizeof program_status, "%s.main(String[])\n%s", program->owner, error);
        delay = INT32_MIN;
    } else if (delay == -3) {
        snprintf(program_status, sizeof program_status, "%s.main(String[])\nExited with status %" PRId32,
                 program->owner, status);
    }
    if (delay == -3 || delay == INT32_MIN) {
        diagnostic_phase(NULL, program_status);
        diagnostic_phase(NULL, "main: destroy finished VM instance");
        jbed_instance_destroy(instance);
        instance = NULL;
        program = NULL;
    }
    return delay;
}

JNIEXPORT void JNICALL Java_org_jbed_source_MainActivity_nativeRequestStop(JNIEnv *env, jclass type)
{
    (void)env; (void)type;
    if (instance && program) jbed_instance_request_state(instance, JBED_INSTANCE_DOWN);
}

JNIEXPORT jstring JNICALL Java_org_jbed_source_MainActivity_nativeStatus(JNIEnv *env, jclass type)
{
    (void)type;
    return (*env)->NewStringUTF(env, program_status);
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved)
{
    (void)reserved;
    JNIEnv *env;
    if ((*vm)->GetEnv(vm, (void **)&env, JNI_VERSION_1_6) != JNI_OK ||
        !jbed_android_initialize(env))
        return JNI_ERR;
    return JNI_VERSION_1_6;
}
