#ifndef JBED_RUNTIME_MEMORY_H
#define JBED_RUNTIME_MEMORY_H

#include "runtime.h"

void *Memory_allocatedField(void *runtime);
void *Memory_firstChunkField(void *runtime);
void *Memory_heapTraceEnabledField(void *runtime);
void *Memory_maxTotalHeapUsageField(void *runtime);
void *Memory_totalHeapUsageField(void *runtime);
void *Memory_noAllocationField(void *runtime);
void *Memory_outOfMemoryField(void *runtime);
void *Memory_stackSpaceField(void *runtime);
void MemSupport_getHeapBlock(JbedAddress address_slot, JbedAddress size_slot);
void MemSupport_freeHeapBlock(JbedAddress address);
int32_t MemSupport_getStackSpace(void);

JbedAddress Memory_newObject(JbedAddress klass);
JbedAddress Memory_newArray(int32_t length, JbedAddress klass);
JbedAddress Memory_newArrayN(int32_t length, JbedAddress prototype, JbedAddress klass);
JbedAddress Memory_xKniNewObject(JbedAddress klass);
JbedAddress Memory_xKniNewArray(int32_t length, JbedAddress klass);
JbedAddress Memory_structCopy(JbedAddress object);
JbedAddress Memory_resize(JbedAddress array, int32_t length);
void Memory_lock(JbedAddress object);
void Memory_unlock(JbedAddress object);
void Memory_nextAllocateLocked(void);
bool Memory_isLocked(JbedAddress object);
bool Memory_isReadOnlyObject(JbedAddress object);
bool Memory_isStaticReadOnlyObject(JbedAddress object);
bool Memory_allocateFromHeapEnd(bool from_end);
void Memory_disableAccounting(bool disabled);
int32_t Memory_nextFinalizedOffset(JbedAddress object);
JbedAddress Memory_nextFinalized(JbedAddress object);
int32_t Memory_getFinalizingIsolateId(void);
void Memory_runGC(void);
void Memory_runCompactor(void);
void Memory_runCompactorOldest(bool oldest_hole);
void Memory_runCompactorPercent(int32_t percent);
int32_t Memory_heapAvail(void);
int32_t Memory_heapSize(void);
int32_t Memory_totalAllocated(void);
int32_t Memory_quotaAvail(void);
void Memory_incrementTotalHeapSize(int32_t delta);
int32_t Memory_largestFreeBlock(void);
JbedAddress Memory_findBlockTable(JbedAddress address);
JbedAddress Memory_tryAlloc(int32_t bytes);
JbedAddress Memory_getFreeList(void);
void Memory_setFreeList(JbedAddress first);
void Memory_freeListChanged(void);
int32_t Memory_getBlockAlign(void);
bool Memory_initHeapBlock(JbedAddress address, int32_t bytes, bool lockable);
bool Memory_addHeapBlock(int32_t bytes);
void Memory_runtimeCollectorTest(void);
void Memory_initCollectorTest(void);
void Memory_setCollectorTestProbabilities(int32_t allocations, int32_t runtime);
void Memory_enableHeapTracing(void);
void Memory_sampleHeapUsage(void);
void Memory_resetHeapUsageMaximums(void);
void Memory_setGCRunning(bool running);
bool Memory_setYGAllocation(bool enabled);
void Memory_shrinkHeap(void);
void Memory_shutdownGC(void);
void Memory_shutdownMemory(void);

#endif
