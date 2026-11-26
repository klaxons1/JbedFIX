#ifndef JBED_RUNTIME_STRING_H
#define JBED_RUNTIME_STRING_H

#include "runtime.h"

JbedAddress NativeOps_getStringData(JbRef);
uint16_t String_charAt(JbRef, int32_t);
void String_getChars(JbRef, int32_t, int32_t, JbRef, int32_t);

#endif
