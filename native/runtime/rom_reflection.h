#ifndef JBED_RUNTIME_ROM_REFLECTION_H
#define JBED_RUNTIME_ROM_REFLECTION_H

#include "runtime.h"

JbedClassAccess *jbed_vm_class_access_for_object(JbedVm *, JbRef);
JbRef jbed_vm_signature_encoder_new(JbedVm *, JbedClassAccess *);
void ClassAccess_initClassAccess(void);
void ClassAccess_resetTables(void);
void ClassAccess_loadBundle(int32_t);
void ClassAccess_loadDynamicBundle(int32_t, JbedAddress, JbedAddress, JbedAddress);

int32_t ClassAccess_getClassNameUtf8(int32_t package, int32_t base, int32_t dimensions,
                                   uint8_t *destination, int32_t capacity);
uint64_t ReflectionTable_getStaticAdr(JbRef table, const int8_t *chain, int32_t ordinal);
void ReflectionTable_init(JbRef table, const uint8_t *image);
int32_t ReflectionTable_getData(JbRef table, int32_t id, JbRef array, uint8_t *destination);
int32_t ReflectionTable_getFirstByte(JbRef table, int32_t id);
int32_t ReflectionTable_dataToId(JbRef table, JbRef array, int32_t offset,
                                  const uint8_t *address, int32_t length, bool create);
int32_t ReflectionTable_stringToId(JbRef table, JbRef string, bool create);
int32_t ReflectionTable_getStaticChainEntry(JbRef table, uint32_t hash, int32_t length,
                                            const uint8_t *bytes);
int32_t ReflectionTable_getStaticStringId(JbRef table, const uint8_t *string);
void ReflectionTable_clearDynamicHash(JbRef table);
void ReflectionTable_referenceDynamicTable(JbRef table, const uint8_t *image);
uint64_t ClassAccess_getClassParams(JbRef access, JbRef string, const uint8_t *address,
                                     int32_t length, bool create);
void Field_init(JbRef field, JbRef owner, const uint8_t *record);
void Method_init(JbRef method, JbRef owner, const uint8_t *record);
int32_t Method_getOffset(uint32_t address, uint32_t flags, uint32_t size,
                         uint32_t pc, const uint32_t *ranges);
JbedAddress Method_getCodeRangeBase(JbRef klass);
JbedAddress Method_searchMethodByPc(JbRef klass, uint32_t pc);
JbedAddress ClassRefTable_bucketAdr(JbRef table, int32_t bucket);
void ClassRefTable_init(JbRef table, const uint8_t *image);
uint64_t ClassRefTable_classParams(JbRef table, int32_t id);
JbRef ClassRefTable_classObject(JbRef table, int32_t id);
JbRef ClassRefTable_getNextClass(JbRef table, JbRef previous);
JbRef ClassRefTable_lookupClass(JbRef table, int32_t hash, int32_t package,
                               int32_t base, int32_t dimensions, bool include_hidden);

#endif
