#ifndef JBED_RUNTIME_ARCH_H
#define JBED_RUNTIME_ARCH_H

#include "runtime.h"

void ArchBase_move(JbedAddress source, JbedAddress destination, uint32_t bytes);
void ArchBase_moveRev(JbedAddress source, JbedAddress destination, uint32_t bytes);
void ArchBase_zero(JbedAddress destination, uint32_t bytes);
void ArchBase_fill(JbedAddress destination, uint32_t pattern, uint32_t bytes);
bool Base_compare(JbedAddress left, JbedAddress right, int32_t bytes);
int32_t Base_arrayLength(JbedAddress array);
bool Base_isArray(JbedAddress object);
int32_t Base_objectSize(JbedAddress object);
bool Base_InstanceOf(JbedAddress object, JbedAddress klass);
void Base_arraystore(JbedAddress array, int32_t index, JbedAddress value);
int32_t Base_getHashCode(JbedAddress object);
bool Base_exceptionInstanceOf(JbedAddress tag, JbedAddress klass);
JbedAddress Base_baseOfJavaStack(void);
void Base_fillTrace(JbedAddress throwable);
void Base_fillTraceAt(JbedAddress throwable, JbedAddress pc, JbedAddress fp);
JbedAddress Base_getSynchronizer(JbedAddress object, bool allocate);
JbedAddress Base_allocSynchronizer(JbedAddress object);
bool Base_lockedByCurrent(JbedAddress object);
JbedAddress Base_tryExit(JbedAddress throwable, JbedAddress monitor);
void *Base_hashSeedField(void *runtime);
void *Base_staticsBaseField(void *runtime);
void *Base_paramPtrField(void *runtime);
void *Base_noCatchField(void *runtime);
void *Base_noCatchTagField(void *runtime);
void *Base_stackOVField(void *runtime);
void *Base_stackLimitField(void *runtime);
void *Base_reservedStackLimitField(void *runtime);
void *Base_nativeCallStateBaseField(void *runtime);
void *Base_nativeCallStateLimitField(void *runtime);
void *Base_nativeCallStateAdrField(void *runtime);
void *Base_nativeCallStateFrameField(void *runtime);

/* These entries use the managed register convention, including r7/r9/r10. */
JbedAddress ArchBase_stackPointer(void);
void ArchBase_call(JbedAddress entry, uint32_t argument);

#endif
