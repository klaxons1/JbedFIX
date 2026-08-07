# Proguard rules for JbedFIX.
# Since this is a legacy app, if we use Proguard, we want to keep all JNI-accessed classes and methods.

-keep class com.esmertec.android.jbed.** { *; }
-keep class android.os.** { *; }
-keep class com.android.internal.telephony.** { *; }
