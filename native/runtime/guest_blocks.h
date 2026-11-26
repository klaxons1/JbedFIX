#ifndef JBED_RUNTIME_GUEST_BLOCKS_H
#define JBED_RUNTIME_GUEST_BLOCKS_H
#include "runtime.h"
JbRef HeapCodeBlocks_getArrayForBlock(JbRef, JbedAddress);
bool HeapCodeBlocks_getCodeBlocks(JbRef, int32_t, JbRef, int32_t);
void HeapCodeBlocks_writeBlock(JbRef, JbedAddress, JbRef, int32_t, int32_t);
#endif
