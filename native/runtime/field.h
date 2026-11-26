#ifndef JBED_RUNTIME_FIELD_H
#define JBED_RUNTIME_FIELD_H

#include "runtime.h"

JbRef Field_getField(JbRef owner, int32_t name, int32_t type);
int32_t Field_getFieldAddress(JbRef owner, int32_t name, int32_t type, int32_t is_static);
int32_t Field_getFieldTypeIdByOffset(JbRef owner, int32_t offset);
int32_t Field_getFieldTypeIdByAddress(JbedAddress address);

#endif
