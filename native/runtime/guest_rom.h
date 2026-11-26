#ifndef JBED_RUNTIME_GUEST_ROM_H
#define JBED_RUNTIME_GUEST_ROM_H

#include "runtime.h"

JbedAddress RomObjects_getPrimStaticsBase(JbRef);
JbedAddress RomObjects_getPtrStaticsBase(JbRef);
JbedAddress RomObjects_getInitFlagsBase(JbRef);
JbRef Isolate_getContext(JbRef);

void Isolate_deliverEvent(JbRef, int32_t, int32_t);
int32_t Isolate_startTransition(JbRef, int32_t, int32_t);
void RomObjects_writeClassObj(JbRef, JbedAddress, JbRef);
void RomObjects_writeCodeAdr(JbRef, JbedAddress, JbedAddress);
void RomObjects_genObjectHeader(JbRef, JbedAddress, JbRef, bool, bool);
void RomObjects_prepareCommon(JbRef, JbRef);
#endif
