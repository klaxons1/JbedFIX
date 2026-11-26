#ifndef JBED_RUNTIME_CLASS_ACCESS_H
#define JBED_RUNTIME_CLASS_ACCESS_H

#include "runtime.h"

void jbed_vm_class_access_publish(JbedVm *, JbedClassAccess *);

bool ClassAccess_isDynamicId(JbRef, int32_t);
uint64_t ClassAccess_getClassParamsId(JbRef, int32_t);
int32_t ClassAccess_getArrayLevel(JbRef, int32_t);
int32_t ClassAccess_getPackageId(JbRef, int32_t);
int32_t ClassAccess_getClassIdParams(JbRef, int32_t, int32_t, int32_t, bool, bool);
int32_t ClassAccess_getClassIdString(JbRef, JbRef, bool, bool, bool);
int32_t ClassAccess_getClassIdUtf8(JbRef, const uint8_t *, int32_t, bool);
int32_t ClassAccess_getClassIdBytes(JbRef, JbRef, int32_t, int32_t, int32_t, int32_t);
int32_t ClassAccess_getArrayOfClass(JbRef, int32_t);
int32_t ClassAccess_getPrimitiveArrayId(JbRef, int32_t, int32_t);
JbRef ClassAccess_classObject(JbRef, int32_t);
JbRef ClassAccess_getClassObject(JbRef, int32_t);
JbRef ClassAccess_getOrCreateClassObject(JbRef, int32_t);
JbRef ClassAccess_getNextDynamicClass(JbRef, JbRef);
int32_t ClassAccess_getNextUnresolvedDynamicClassId(JbRef, int32_t);
JbRef ClassAccess_getDynamicClasses(JbRef);
void ClassAccess_registerWithRuntime(JbRef);
JbRef ClassAccess_getName(JbRef, int32_t);
JbRef Class_getName(JbRef);

#endif
