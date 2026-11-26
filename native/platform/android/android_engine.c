#include "android_methods.h"
#include "android_jni.h"
#include "vm_os.h"
#include "vm_async.h"
#include "vm_lifecycle.h"
#include "display.h"
#include "io_files.h"
#include "io_socket.h"
#include "push.h"

#include <stdlib.h>
#include <string.h>

extern void Jbed_timerEntry(void);
extern void jbedPostRawEvent(int event);
extern int fullScreenDisplayWidth, fullScreenDisplayHeight, midletWidth, midletHeight;
extern float xScale, yScale;

enum {
    RAW_EVENT_TYPE_MASK = 0x0f, RAW_POINTER_RELEASED = 2,
    RAW_POINTER_METADATA_MASK = 0x3f, RAW_POINTER_COORDINATE_MASK = 0x1fff,
    RAW_POINTER_X_SHIFT = 19, RAW_POINTER_Y_SHIFT = 6
};

static jmethodID vm_state_change;
static int argc_for_vm, configured_slice;
static char **argv_for_vm, **command_line;
static int command_line_count;

void android_engine_sizeChangingDone(void)
{
    JNIEnv *env = jbed_android_get_env();
    jclass clazz = (*env)->GetObjectClass(env, jbed_android_engine);
    jmethodID method = (*env)->GetMethodID(env, clazz, "sizeChangingDone", "()V");
    (*env)->CallVoidMethod(env, jbed_android_engine, method);
    (*env)->DeleteLocalRef(env, clazz);
}

static int notify_state(int isolate, int commit, int from, int to, int status, void *arg)
{
    (void)isolate; (void)arg;
    android_LOGD("jbed_app (native): vmStateChange commit:%d oldstate:%d newstate:%d\n", commit, from, to);
    JNIEnv *env = jbed_android_get_env();
    return (*env)->CallBooleanMethod(env, jbed_android_engine, vm_state_change, commit, from, to, status);
}

static void free_arguments(char **arguments, int count)
{
    for (int i = 0; i < count; ++i) free(arguments[i]);
    free(arguments);
}

static char **get_arguments(jobjectArray args, int *count)
{
    JNIEnv *env = jbed_android_get_env();
    *count = 0;
    jsize n = (*env)->GetArrayLength(env, args);
    char **argv = calloc((size_t)n + 1, sizeof(*argv));
    if (!argv) {
        jbed_android_throw(env, "java/lang/OutOfMemoryError", "failed to getCommandLine");
        return NULL;
    }
    for (jsize i = 0; i < n; ++i) {
        jstring s = (*env)->GetObjectArrayElement(env, args, i);
        const char *text = (*env)->GetStringUTFChars(env, s, NULL);
        if (text) {
            argv[i] = malloc(strlen(text) + 1);
            if (argv[i]) strcpy(argv[i], text);
            (*env)->ReleaseStringUTFChars(env, s, text);
        }
        (*env)->DeleteLocalRef(env, s);
        if (!argv[i]) {
            free_arguments(argv, i);
            if (!(*env)->ExceptionCheck(env))
                jbed_android_throw(env, "java/lang/OutOfMemoryError", "failed to getCommandLine");
            return NULL;
        }
    }
    *count = n;
    return argv;
}

void Java_android_jbed_service_JbedEngine_nativeInitializeSubsystems(JNIEnv *env, jobject self,
                                                                    jobjectArray args, jint slice)
{
    jclass clazz = (*env)->GetObjectClass(env, self);
    configured_slice = slice;
    android_LOGD("jbed_app (native): nativeInitializeSubsystems \n\n");
    if (jbed_android_engine) (*env)->DeleteGlobalRef(env, jbed_android_engine);
    jbed_android_engine = (*env)->NewGlobalRef(env, self);
    if (!jbed_android_engine) { (*env)->DeleteLocalRef(env, clazz); return; }
    vm_state_change = (*env)->GetMethodID(env, clazz, "vmStateChange", "(ZIII)Z");
    (*env)->DeleteLocalRef(env, clazz);
    if (!vm_state_change) return;
    android_LOGD("jbed_app (native): parse command line\n");
    Jbed_props_startup();
    command_line = get_arguments(args, &command_line_count);
    if (!command_line) return;
    argv_for_vm = jbed_processCmdLine(command_line_count, command_line, &argc_for_vm, NULL);
    android_LOGD("jbed_app (native): initialize OS subsystem\n");
    jbed_os_initialize();
    if (CPL_file_startup())
        android_LOGD("ERROR CPL_file_startup() failed.\n");
    InitializeWindowSystem();
}

void Java_android_jbed_service_JbedEngine_nativeFinalizeSubsystems(JNIEnv *env, jobject self)
{
    (void)self;
    android_LOGD("jbed_app (native): nativeFinalizeSubsystems\n");
    Jbed_push_handle_shutdown();
    FinalizeWindowSystem();
    CPL_net_shutdown();
    CPL_file_shutdown();
    jbed_os_finalize();
    free(argv_for_vm);
    argv_for_vm = NULL;
    free_arguments(command_line, command_line_count);
    command_line = NULL;
    command_line_count = 0;
    Jbed_props_shutdown();
    (*env)->DeleteGlobalRef(env, jbed_android_engine);
    jbed_android_engine = NULL;
}

void Java_android_jbed_service_JbedEngine_nativeInitializePush(JNIEnv *env, jobject self)
{
    (void)env; (void)self;
    Jbed_push_handle_boot(1);
}

void Java_android_jbed_service_JbedEngine_nativeJbedInitVmLifeCycle(JNIEnv *env, jobject self)
{
    (void)env; (void)self;
    android_LOGD("jbed_app (native): nativeJbedInitVmLifeCycle \n\n");
    Jbed_initVmLifeCycle(argc_for_vm, argv_for_vm, notify_state);
    argc_for_vm = 0;
}

void Java_android_jbed_service_JbedEngine_nativeJbedRequestState(JNIEnv *env, jobject self, jint state)
{
    (void)env; (void)self;
    Jbed_requestState(state, NULL, NULL);
}

void Java_android_jbed_service_JbedEngine_nativeJbedDoRawEvent(JNIEnv *env, jobject self, jint event)
{
    (void)env; (void)self;
    uint32_t word = (uint32_t)event;
    if ((yScale != 1.0f || xScale != 1.0f) && (word & RAW_EVENT_TYPE_MASK) <= RAW_POINTER_RELEASED) {
        float x_ratio = (float)fullScreenDisplayWidth / (float)midletWidth;
        float y_ratio = (float)fullScreenDisplayHeight / (float)midletHeight;
        uint32_t x = (int32_t)((float)(word >> RAW_POINTER_X_SHIFT) / x_ratio);
        uint32_t y = (int32_t)((float)((word >> RAW_POINTER_Y_SHIFT) & RAW_POINTER_COORDINATE_MASK) / y_ratio);
        word = (x << RAW_POINTER_X_SHIFT) |
               ((y & RAW_POINTER_COORDINATE_MASK) << RAW_POINTER_Y_SHIFT) |
               (word & RAW_POINTER_METADATA_MASK);
    }
    jbedPostRawEvent((int32_t)word);
}

jint Java_android_jbed_service_JbedEngine_nativeJbedRun(JNIEnv *env, jobject self)
{
    (void)env; (void)self;
    return Jbed_run(50);
}

jint Java_android_jbed_service_JbedEngine_nativeAiocPoll(JNIEnv *env, jobject self)
{
    (void)env; (void)self;
    return aioc_poll(0);
}

void Java_android_jbed_service_JbedEngine_nativeOnEnterRestartVMLoop(JNIEnv *env, jobject self)
{
    (void)env; (void)self;
    CPL_wma_init();
    Jbed_push_handle_vm_start();
}

void Java_android_jbed_service_JbedEngine_nativeOnExitRestartVMLoop(JNIEnv *env, jobject self)
{
    (void)env; (void)self;
    Jbed_push_handle_vm_exit_or_reset();
    CPL_wma_shutdown();
}

void doTimer(void) { Jbed_timerEntry(); }

void Java_android_jbed_service_JbedEngine_nativeUpdateSystemTime(JNIEnv *env, jobject self)
{
    (void)env; (void)self;
    updateSystemTime();
}

void Java_android_jbed_service_JbedEngine_nativeScreenSizeChanged(JNIEnv *env, jobject self, jint width,
    jint height, jint bpp, jint full_width, jint full_height, jint max_square)
{
    (void)env; (void)self;
    int config[] = {width, height, full_width, full_height, (int32_t)((uint32_t)width * bpp), max_square};
    InitializeWindowConfig(config);
}
