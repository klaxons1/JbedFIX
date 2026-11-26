#ifndef JBED_SOURCE_RUNTIME_H
#define JBED_SOURCE_RUNTIME_H

#include "../compiler/class_access.h"
#include "../compiler/vm/vm_collector.h"
#include "../compiler/vm/vm_compactor.h"
#include "../compiler/vm/vm_monitor.h"
#include "../compiler/vm/vm_strings.h"
#include "../platform/jbni_objects.h"
#include "signals.h"
#include "lifecycle.h"

typedef struct JbedArm32Context JbedArm32Context;
typedef struct JbedNativePlan JbedNativePlan;
typedef struct JbedVmCompiler JbedVmCompiler;
typedef struct JbedVmScheduler JbedVmScheduler;

typedef struct JbedVmStaticRoot {
    JbedAddress slot;
    bool global;
} JbedVmStaticRoot;

typedef struct JbedVm {
    JbedRuntime services;
    JbedVmHeap heap;
    JbedVmClassTable resident;
    JbedClassAccess classes;
    JbedReflectionTable packages, base_names, field_names, method_names, signatures;
    JbedAddress reflection_roots[5];
    JbedVmStrings strings;
    JbedVmExceptionState exceptions;
    JbedAddress exception_no_catch_slot, exception_no_catch_tag_slot;
    JbedVmNativeFrames native_frames;
    JbedVmMonitors monitors;
    JbedVmStackMaps stack_maps;
    JbedVmCollector collector;
    JbedVmCompactor compactor;
    JbedVmSignals signals;
    JbedVmLifecycle lifecycle;
    JbedVmCompiler *compiler;
    JbedVmScheduler *scheduler;
    JbedArm32Context *arm;
    JbedNativePlan *native_methods;
    size_t native_method_count;
    JbedVmStaticRoot *static_roots;
    size_t static_root_count;
    JbedAddress **native_static_roots;
    size_t native_static_root_count;
    bool isolate_roots_owned;
    void (*checkpoint)(struct JbedVm *);
    JbedAddress isolate_statics;
    uint32_t stack_space;
    JbedAddress class_class, string_class, object_array_class;
    JbedAddress primitive_array_classes[JBED_TYPE_LONG + 1];
    JbedAddress pending_exception, out_of_memory;
    JbedAddress deliver_native_event;
    JbedAddress bundle_initializers;
    uint32_t bundle_initializer_count;
    void **native_roots_base, **native_roots_limit, **native_roots_top;
    JbRef *parameters;
    int32_t isolate_id;
} JbedVm;

/* Binding changes occur on the engine thread at isolate/native-call boundaries. */
JbedVm *jbed_vm_current(void);
JbedVm *jbed_vm_bind(JbedVm *);
JbedAddress jbed_vm_switch_statics(JbedVm *, JbedAddress);
_Noreturn void jbed_vm_raise(JbedVm *, JbedErrorKind, const char *message);
_Noreturn void jbed_vm_fatal(JbedVm *, const char *message);

/* Native roots are included while allocation may run the moving collector. */
JbedAddress jbed_vm_allocate_object(JbedVm *, JbedAddress klass, bool kni);
JbedAddress jbed_vm_allocate_array(JbedVm *, JbedAddress klass, int32_t length, bool kni);
JbedAddress jbed_vm_find_class(JbedVm *, const char *name);
JbedAddress Object_getClass(JbedAddress object);
void System_arraycopy(JbedAddress source, int32_t source_index, JbedAddress destination,
                       int32_t destination_index, int32_t count);
JbedTypeId jbed_vm_lookup_type(JbedVm *, const char *name, size_t length,
                               bool include_hidden, bool create_arrays);

JbRef JbedKNI_LookupClass(const char *name);
JbRef JbedKNI_VerifyObject(JbRef, int kind);
void *JbedKNI_VerifyArray(JbRef, int index, int kind, JbRef value);
void JbedKNI_VerifyArraySetObj(JbRef, int index, int kind, JbRef value);
void JbedKNI_VerifyArrayCopy(JbRef, unsigned offset, unsigned size, void *native, int to_java);
uint32_t JbedKNI_GetFieldAddress(JbRef klass, const char *name, const char *descriptor, int flags);
void *JbedKNI_VerifyField(JbRef object, uint32_t field, int kind, JbRef value);
JbRef JbedKNI_NewUtfString(const char *, int replace_slashes);
JbRef jbed_vm_new_utf_string(JbedVm *, const char *, int32_t length, bool replace_slashes);
int JbedKNI_ThrowNew(const char *class_name, JbRef message);
_Noreturn void JbedKNI_FatalError(const char *message);

extern JbRef *Jbed_ParamPtr;
extern uint8_t *Jbed_relativeStaticsBase;
extern uint32_t Jbed_noAllocation;

#endif
