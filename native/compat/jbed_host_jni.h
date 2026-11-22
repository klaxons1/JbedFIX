#ifndef JBED_HOST_JNI_H
#define JBED_HOST_JNI_H

#include <jni.h>
#include <stdint.h>

/* Jbed's common-stack pointer is the native stack parked by its scheduler. */
int jbed_host_jni_initialize(JNIEnv *env, uintptr_t *common_stack);
void jbed_host_jni_finalize(void);
JNIEXPORT JNIEnv *jbedcompat_current_env(JNIEnv *actual);
JNIEXPORT void jbedcompat_call_host(JNIEnv *actual, void (*callback)(JNIEnv *, void *),
                                   void *argument);

#endif
