#ifndef JBED_SOURCE_BUNDLE_H
#define JBED_SOURCE_BUNDLE_H

#include "runtime.h"

void Isolate_initBundle(int32_t bundle);
void Isolate_runMain(JbedAddress isolate, JbedAddress arguments);

#endif
