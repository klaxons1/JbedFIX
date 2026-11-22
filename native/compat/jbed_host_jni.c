/* ART requires Java upcalls to use the attached pthread's stack. Jbed's green
 * threads use separate heap stacks. This facade belongs only to Jbed; Android's
 * JNIEnv and its function table are never modified. */
#define _GNU_SOURCE
#include "jbed_host_jni.h"
#include <pthread.h>
#include <stdarg.h>
#include <stdlib.h>

typedef struct {
    const struct JNINativeInterface *functions;
    JNIEnv *actual;
    uintptr_t *common_stack;
    uintptr_t stack_low;
    uintptr_t stack_high;
    int switch_stacks;
} HostEnv;

static HostEnv engine_env;
static struct JNINativeInterface host_functions;
extern void jbed_call_host_stack(void (*callback)(void *), void *, uintptr_t);

static void invoke(HostEnv *env, void (*callback)(void *), void *argument) {
    uintptr_t sp = (uintptr_t) &sp;
    if (!env->switch_stacks || (sp >= env->stack_low && sp < env->stack_high)) {
        callback(argument);
        return;
    }
    uintptr_t native_sp = *env->common_stack;
    /* Never substitute an arbitrary stack or continue with an invalid anchor. */
    if (native_sp <= env->stack_low || native_sp >= env->stack_high) abort();
    jbed_call_host_stack(callback, argument, native_sp);
}

#define WRAP(R, NAME, PARAMS, FIELDS, SET, ARGS) \
    typedef struct { HostEnv *env; R result; FIELDS } Args_##NAME; \
    static void host_##NAME(void *opaque) { \
        Args_##NAME *d = opaque; JNIEnv *real = d->env->actual; \
        d->result = (*real)->NAME ARGS; \
    } \
    static R JNICALL wrap_##NAME PARAMS { \
        Args_##NAME d = {0}; d.env = (HostEnv *) env; SET \
        invoke(d.env, host_##NAME, &d); return d.result; \
    }

#define WRAP_VOID(NAME, PARAMS, FIELDS, SET, ARGS) \
    typedef struct { HostEnv *env; FIELDS } Args_##NAME; \
    static void host_##NAME(void *opaque) { \
        Args_##NAME *d = opaque; JNIEnv *real = d->env->actual; \
        (*real)->NAME ARGS; \
    } \
    static void JNICALL wrap_##NAME PARAMS { \
        Args_##NAME d = {0}; d.env = (HostEnv *) env; SET \
        invoke(d.env, host_##NAME, &d); \
    }

WRAP(jint, GetVersion, (JNIEnv *env), , , (real))
WRAP(jclass, FindClass, (JNIEnv *env, const char *name), const char *name;, d.name=name;, (real,d->name))
WRAP(jint, Throw, (JNIEnv *env, jthrowable ex), jthrowable ex;, d.ex=ex;, (real,d->ex))
WRAP(jint, ThrowNew, (JNIEnv *env, jclass cls, const char *message), jclass cls; const char *message;, d.cls=cls; d.message=message;, (real,d->cls,d->message))
WRAP(jthrowable, ExceptionOccurred, (JNIEnv *env), , , (real))
WRAP(jboolean, ExceptionCheck, (JNIEnv *env), , , (real))
WRAP_VOID(ExceptionDescribe, (JNIEnv *env), , , (real))
WRAP_VOID(ExceptionClear, (JNIEnv *env), , , (real))
WRAP(jint, PushLocalFrame, (JNIEnv *env, jint capacity), jint capacity;, d.capacity=capacity;, (real,d->capacity))
WRAP(jobject, PopLocalFrame, (JNIEnv *env, jobject value), jobject value;, d.value=value;, (real,d->value))
WRAP(jint, EnsureLocalCapacity, (JNIEnv *env, jint capacity), jint capacity;, d.capacity=capacity;, (real,d->capacity))
WRAP(jobject, NewGlobalRef, (JNIEnv *env, jobject value), jobject value;, d.value=value;, (real,d->value))
WRAP(jobject, NewLocalRef, (JNIEnv *env, jobject value), jobject value;, d.value=value;, (real,d->value))
WRAP_VOID(DeleteGlobalRef, (JNIEnv *env, jobject value), jobject value;, d.value=value;, (real,d->value))
WRAP_VOID(DeleteLocalRef, (JNIEnv *env, jobject value), jobject value;, d.value=value;, (real,d->value))
WRAP(jboolean, IsSameObject, (JNIEnv *env, jobject a, jobject b), jobject a; jobject b;, d.a=a; d.b=b;, (real,d->a,d->b))
WRAP(jclass, GetObjectClass, (JNIEnv *env, jobject value), jobject value;, d.value=value;, (real,d->value))
WRAP(jboolean, IsInstanceOf, (JNIEnv *env, jobject value, jclass cls), jobject value; jclass cls;, d.value=value; d.cls=cls;, (real,d->value,d->cls))

#define LOOKUP(R, NAME) WRAP(R, NAME, (JNIEnv *env,jclass cls,const char *name,const char *sig), jclass cls; const char *name; const char *sig;, d.cls=cls; d.name=name; d.sig=sig;, (real,d->cls,d->name,d->sig))
LOOKUP(jmethodID, GetMethodID)
LOOKUP(jmethodID, GetStaticMethodID)
LOOKUP(jfieldID, GetFieldID)
LOOKUP(jfieldID, GetStaticFieldID)

#define FIELD(R, NAME) WRAP(R, NAME, (JNIEnv *env,jobject obj,jfieldID id), jobject obj; jfieldID id;, d.obj=obj; d.id=id;, (real,d->obj,d->id))
FIELD(jobject, GetObjectField)
FIELD(jint, GetIntField)

/* Convert variadic calls before changing stacks: va_list still points to the
 * caller's untouched VM stack, and the real JNI V entry consumes it there. */
#define CALL(R, NAME, OBJECT) \
    typedef struct { HostEnv *env; R result; OBJECT obj; jmethodID id; va_list args; } Args_##NAME; \
    static void host_##NAME(void *opaque) { \
        Args_##NAME *d=opaque; JNIEnv *real=d->env->actual; \
        d->result=(*real)->NAME##V(real,d->obj,d->id,d->args); \
    } \
    static R JNICALL wrap_##NAME##V(JNIEnv *env,OBJECT obj,jmethodID id,va_list args) { \
        Args_##NAME d={0}; d.env=(HostEnv *)env; d.obj=obj; d.id=id; va_copy(d.args,args); \
        invoke(d.env,host_##NAME,&d); va_end(d.args); return d.result; \
    } \
    static R JNICALL wrap_##NAME(JNIEnv *env,OBJECT obj,jmethodID id,...) { \
        va_list args; va_start(args,id); R result=wrap_##NAME##V(env,obj,id,args); \
        va_end(args); return result; \
    } \
    WRAP(R, NAME##A, (JNIEnv *env,OBJECT obj,jmethodID id,const jvalue *args), OBJECT obj; jmethodID id; const jvalue *args;, d.obj=obj; d.id=id; d.args=args;, (real,d->obj,d->id,d->args))

#define CALL_VOID(NAME, OBJECT) \
    typedef struct { HostEnv *env; OBJECT obj; jmethodID id; va_list args; } Args_##NAME; \
    static void host_##NAME(void *opaque) { \
        Args_##NAME *d=opaque; JNIEnv *real=d->env->actual; \
        (*real)->NAME##V(real,d->obj,d->id,d->args); \
    } \
    static void JNICALL wrap_##NAME##V(JNIEnv *env,OBJECT obj,jmethodID id,va_list args) { \
        Args_##NAME d={0}; d.env=(HostEnv *)env; d.obj=obj; d.id=id; va_copy(d.args,args); \
        invoke(d.env,host_##NAME,&d); va_end(d.args); \
    } \
    static void JNICALL wrap_##NAME(JNIEnv *env,OBJECT obj,jmethodID id,...) { \
        va_list args; va_start(args,id); wrap_##NAME##V(env,obj,id,args); va_end(args); \
    } \
    WRAP_VOID(NAME##A, (JNIEnv *env,OBJECT obj,jmethodID id,const jvalue *args), OBJECT obj; jmethodID id; const jvalue *args;, d.obj=obj; d.id=id; d.args=args;, (real,d->obj,d->id,d->args))

CALL(jobject, CallObjectMethod, jobject)
CALL(jboolean, CallBooleanMethod, jobject)
CALL(jint, CallIntMethod, jobject)
CALL(jfloat, CallFloatMethod, jobject)
CALL_VOID(CallVoidMethod, jobject)
CALL(jobject, CallStaticObjectMethod, jclass)
CALL(jboolean, CallStaticBooleanMethod, jclass)
CALL(jint, CallStaticIntMethod, jclass)
CALL(jlong, CallStaticLongMethod, jclass)
CALL(jfloat, CallStaticFloatMethod, jclass)
CALL(jdouble, CallStaticDoubleMethod, jclass)
CALL_VOID(CallStaticVoidMethod, jclass)

WRAP(jstring, NewString, (JNIEnv *env,const jchar *chars,jsize len), const jchar *chars; jsize len;, d.chars=chars; d.len=len;, (real,d->chars,d->len))
WRAP(jstring, NewStringUTF, (JNIEnv *env,const char *chars), const char *chars;, d.chars=chars;, (real,d->chars))
WRAP(jsize, GetStringLength, (JNIEnv *env,jstring str), jstring str;, d.str=str;, (real,d->str))
WRAP(jsize, GetStringUTFLength, (JNIEnv *env,jstring str), jstring str;, d.str=str;, (real,d->str))
WRAP(const jchar *, GetStringChars, (JNIEnv *env,jstring str,jboolean *copy), jstring str; jboolean *copy;, d.str=str; d.copy=copy;, (real,d->str,d->copy))
WRAP(const char *, GetStringUTFChars, (JNIEnv *env,jstring str,jboolean *copy), jstring str; jboolean *copy;, d.str=str; d.copy=copy;, (real,d->str,d->copy))
WRAP_VOID(ReleaseStringChars, (JNIEnv *env,jstring str,const jchar *chars), jstring str; const jchar *chars;, d.str=str; d.chars=chars;, (real,d->str,d->chars))
WRAP_VOID(ReleaseStringUTFChars, (JNIEnv *env,jstring str,const char *chars), jstring str; const char *chars;, d.str=str; d.chars=chars;, (real,d->str,d->chars))
WRAP(jsize, GetArrayLength, (JNIEnv *env,jarray array), jarray array;, d.array=array;, (real,d->array))
WRAP(jobjectArray, NewObjectArray, (JNIEnv *env,jsize len,jclass cls,jobject initial), jsize len; jclass cls; jobject initial;, d.len=len; d.cls=cls; d.initial=initial;, (real,d->len,d->cls,d->initial))
WRAP(jobject, GetObjectArrayElement, (JNIEnv *env,jobjectArray array,jsize index), jobjectArray array; jsize index;, d.array=array; d.index=index;, (real,d->array,d->index))
WRAP_VOID(SetObjectArrayElement, (JNIEnv *env,jobjectArray array,jsize index,jobject value), jobjectArray array; jsize index; jobject value;, d.array=array; d.index=index; d.value=value;, (real,d->array,d->index,d->value))

#define ARRAY(TYPE, NAME) \
    WRAP(TYPE##Array, New##NAME##Array, (JNIEnv *env,jsize len), jsize len;, d.len=len;, (real,d->len)) \
    WRAP(TYPE *, Get##NAME##ArrayElements, (JNIEnv *env,TYPE##Array array,jboolean *copy), TYPE##Array array; jboolean *copy;, d.array=array; d.copy=copy;, (real,d->array,d->copy)) \
    WRAP_VOID(Release##NAME##ArrayElements, (JNIEnv *env,TYPE##Array array,TYPE *bytes,jint mode), TYPE##Array array; TYPE *bytes; jint mode;, d.array=array; d.bytes=bytes; d.mode=mode;, (real,d->array,d->bytes,d->mode)) \
    WRAP_VOID(Get##NAME##ArrayRegion, (JNIEnv *env,TYPE##Array array,jsize start,jsize len,TYPE *bytes), TYPE##Array array; jsize start; jsize len; TYPE *bytes;, d.array=array; d.start=start; d.len=len; d.bytes=bytes;, (real,d->array,d->start,d->len,d->bytes)) \
    WRAP_VOID(Set##NAME##ArrayRegion, (JNIEnv *env,TYPE##Array array,jsize start,jsize len,const TYPE *bytes), TYPE##Array array; jsize start; jsize len; const TYPE *bytes;, d.array=array; d.start=start; d.len=len; d.bytes=bytes;, (real,d->array,d->start,d->len,d->bytes))
ARRAY(jbyte, Byte)
ARRAY(jint, Int)
ARRAY(jfloat, Float)

int jbed_host_jni_initialize(JNIEnv *env, uintptr_t *common_stack) {
    pthread_attr_t attributes;
    void *stack;
    size_t size;
    if (pthread_getattr_np(pthread_self(), &attributes) != 0) return -1;
    int result = pthread_attr_getstack(&attributes, &stack, &size);
    pthread_attr_destroy(&attributes);
    if (result != 0) return -1;
    engine_env.actual=env;
    engine_env.common_stack=common_stack;
    engine_env.stack_low=(uintptr_t) stack;
    engine_env.stack_high=(uintptr_t) stack+size;
    /* Native-bridge translation can give ARM a guest stack while pthread
     * attributes describe its host stack. Its JNI trampoline already changes
     * stacks; only switch when the initial Java-to-JNI stack matches pthread. */
    uintptr_t initial_sp=(uintptr_t) &attributes;
    engine_env.switch_stacks=initial_sp >= engine_env.stack_low
            && initial_sp < engine_env.stack_high;
#define BIND(NAME) host_functions.NAME=wrap_##NAME
    BIND(GetVersion); BIND(FindClass); BIND(Throw); BIND(ThrowNew);
    BIND(ExceptionOccurred); BIND(ExceptionCheck); BIND(ExceptionDescribe); BIND(ExceptionClear);
    BIND(PushLocalFrame); BIND(PopLocalFrame); BIND(EnsureLocalCapacity);
    BIND(NewGlobalRef); BIND(NewLocalRef); BIND(DeleteGlobalRef); BIND(DeleteLocalRef);
    BIND(IsSameObject); BIND(GetObjectClass); BIND(IsInstanceOf);
    BIND(GetMethodID); BIND(GetStaticMethodID); BIND(GetFieldID); BIND(GetStaticFieldID);
    BIND(GetObjectField); BIND(GetIntField);
#define BIND_CALL(NAME) BIND(NAME); BIND(NAME##V); BIND(NAME##A)
    BIND_CALL(CallObjectMethod); BIND_CALL(CallBooleanMethod); BIND_CALL(CallIntMethod);
    BIND_CALL(CallFloatMethod);
    BIND_CALL(CallVoidMethod); BIND_CALL(CallStaticObjectMethod); BIND_CALL(CallStaticBooleanMethod);
    BIND_CALL(CallStaticIntMethod); BIND_CALL(CallStaticLongMethod); BIND_CALL(CallStaticFloatMethod);
    BIND_CALL(CallStaticDoubleMethod); BIND_CALL(CallStaticVoidMethod);
    BIND(NewString); BIND(NewStringUTF); BIND(GetStringLength); BIND(GetStringUTFLength);
    BIND(GetStringChars); BIND(GetStringUTFChars); BIND(ReleaseStringChars); BIND(ReleaseStringUTFChars);
    BIND(GetArrayLength); BIND(NewObjectArray); BIND(GetObjectArrayElement); BIND(SetObjectArrayElement);
#define BIND_ARRAY(NAME) BIND(New##NAME##Array); BIND(Get##NAME##ArrayElements); BIND(Release##NAME##ArrayElements); BIND(Get##NAME##ArrayRegion); BIND(Set##NAME##ArrayRegion)
    BIND_ARRAY(Byte); BIND_ARRAY(Int); BIND_ARRAY(Float);
    engine_env.functions=&host_functions;
    return 0;
}

JNIEXPORT JNIEnv *jbedcompat_current_env(JNIEnv *actual) {
    return actual == engine_env.actual ? (JNIEnv *) &engine_env : actual;
}

typedef struct {
    JNIEnv *actual;
    void (*callback)(JNIEnv *, void *);
    void *argument;
} HostCallback;

static void host_callback(void *opaque) {
    HostCallback *call=opaque;
    call->callback(call->actual, call->argument);
}

JNIEXPORT void jbedcompat_call_host(JNIEnv *actual, void (*callback)(JNIEnv *, void *),
                                   void *argument) {
    if (actual == (JNIEnv *) &engine_env) actual=engine_env.actual;
    if (actual != engine_env.actual) {
        callback(actual, argument);
        return;
    }
    HostCallback call={actual, callback, argument};
    invoke(&engine_env, host_callback, &call);
}

void jbed_host_jni_finalize(void) {
    engine_env.actual=NULL;
}
