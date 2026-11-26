#ifndef JBED_ANDROID_JNI_H
#define JBED_ANDROID_JNI_H

#include <jni.h>

struct AndroidCachedFields {
    jclass media;
    jmethodID create_player, open_stream, media_operation;
    jclass pim;
    jmethodID pim_supported, pim_remove, pim_store_contact, pim_next, pim_store_todo, pim_store_event;
    jclass midp, lcdui;
    jmethodID repaint;
    jclass lapi, drm, miapi;
};

extern struct AndroidCachedFields gCachedFields;
extern jobject jbed_android_engine;
JNIEXPORT int jbed_android_initialize(JNIEnv *env);
JNIEnv *jbed_android_get_env(void);
int jbed_android_attach_thread(void);
void jbed_android_detach_thread(void);
int jbed_android_graphics_initialize(JNIEnv *env);
int android_LOGD(const char *format, ...);
jint jbed_android_throw(JNIEnv *env, const char *name, const char *message);

#endif
