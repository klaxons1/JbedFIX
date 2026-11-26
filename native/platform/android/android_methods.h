#ifndef JBED_ANDROID_METHODS_H
#define JBED_ANDROID_METHODS_H

#include <jni.h>

void Java_android_jbed_app_JbedView_nativeInitializeAppView(JNIEnv *, jobject, jobject);
void Java_android_jbed_app_JbedView_nativeFinalizeAppView(JNIEnv *, jobject, jobject);
void Java_android_jbed_app_JbedView_nativeRepaint(JNIEnv *, jobject, jint, jint, jint, jint, jint, jint, jfloat, jfloat);
void Java_android_jbed_service_JbedEngine_nativeInitializeSubsystems(JNIEnv *, jobject, jobjectArray, jint);
void Java_android_jbed_service_JbedEngine_nativeFinalizeSubsystems(JNIEnv *, jobject);
void Java_android_jbed_service_JbedEngine_nativeInitializePush(JNIEnv *, jobject);
void Java_android_jbed_service_JbedEngine_nativeJbedInitVmLifeCycle(JNIEnv *, jobject);
void Java_android_jbed_service_JbedEngine_nativeJbedRequestState(JNIEnv *, jobject, jint);
void Java_android_jbed_service_JbedEngine_nativeJbedDoRawEvent(JNIEnv *, jobject, jint);
jint Java_android_jbed_service_JbedEngine_nativeJbedRun(JNIEnv *, jobject);
jint Java_android_jbed_service_JbedEngine_nativeAiocPoll(JNIEnv *, jobject);
void Java_android_jbed_service_JbedEngine_nativeOnEnterRestartVMLoop(JNIEnv *, jobject);
void Java_android_jbed_service_JbedEngine_nativeOnExitRestartVMLoop(JNIEnv *, jobject);
void Java_android_jbed_service_JbedEngine_nativeScreenSizeChanged(JNIEnv *, jobject, jint, jint, jint, jint, jint, jint);
void Java_android_jbed_service_JbedEngine_nativeUpdateSystemTime(JNIEnv *, jobject);
void Java_android_jbed_jsr_JbedLcduiManager_nativeInitialization(JNIEnv *, jclass);
void Java_android_jbed_jsr_JbedLcduiManager_nativeMvmSwitchMideltList(JNIEnv *, jobject);
void Java_android_jbed_jsr_JbedMidpManager_nativeInitialization(JNIEnv *, jclass);
void Java_android_jbed_jsr_JbedMidpManager_nativeSetJbedProperty(JNIEnv *, jobject, jstring, jstring);
void Java_android_jbed_jsr_JbedMediaManager_nativeInitialization(JNIEnv *, jclass);
void Java_android_jbed_jsr_JbedMediaManager_nativeNotifyMediaFinishPlay(JNIEnv *, jclass, jint);
void Java_android_jbed_jsr_JbedMediaManager_nativeNotifyMediaCreatePlayer(JNIEnv *, jclass, jint);
void Java_android_jbed_jsr_JbedSmsManager_nativeNotifyNewSms(JNIEnv *, jclass, jstring, jint, jint, jint, jlong, jbyteArray);
void Java_android_jbed_jsr_JbedSmsManager_nativeNotifySmsSendResult(JNIEnv *, jclass, jint, jboolean);
void Java_android_jbed_jsr_JbedMmsManager_nativeNotifyNewMms(JNIEnv *, jclass, jboolean);
void Java_android_jbed_jsr_JbedMmsManager_nativeNotifyMmsSendResult(JNIEnv *, jclass, jint, jboolean);
void Java_android_jbed_jsr_JbedFileManager_nativeNotifyRootChanged(JNIEnv *, jclass, jstring, jstring, jboolean);
void Java_android_jbed_jsr_JbedPimManager_nativeInitialization(JNIEnv *, jclass);
void Java_android_jbed_nativeui_JbedTextFieldConnection_notifyTextFieldTextChanged(JNIEnv *, jobject, jint, jstring);
void Java_android_jbed_nativeui_JbedTextFieldConnection_notifyTextFieldClientAttached(JNIEnv *, jobject);
void Java_android_jbed_nativeui_JbedTextFieldConnection_notifyRefreshTextField(JNIEnv *, jobject, jint);
void Java_android_jbed_jsr_JbedLapiManager_nativeInitialization(JNIEnv *, jclass, jstring);
void Java_android_jbed_jsr_JbedLapiManager_notifyNative(JNIEnv *, jclass, jint, jint);
void Java_android_jbed_jsr_JbedDrmManager_nativeInitialization(JNIEnv *, jclass, jstring);
void Java_android_jbed_jsr_JbedMiapiManager_nativeInitialization(JNIEnv *, jclass);

#endif
