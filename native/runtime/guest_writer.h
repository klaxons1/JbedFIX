#ifndef JBED_RUNTIME_GUEST_WRITER_H
#define JBED_RUNTIME_GUEST_WRITER_H

#include "runtime.h"

/* Receivers are ARM Java objects, never host JbedWriter pointers. */
void Writer_writeByte(JbRef, JbedAddress, int32_t);
void Writer_writeShort(JbRef, JbedAddress, int32_t);
void Writer_writeInt(JbRef, JbedAddress, int32_t);
void CodeBlockWriter_writeByte(JbRef, JbedAddress, int32_t);
void CodeBlockWriter_writeShort(JbRef, JbedAddress, int32_t);
void CodeBlockWriter_writeInt(JbRef, JbedAddress, int32_t);
int32_t CodeBlockWriter_readShort(JbRef, JbedAddress);
int32_t CodeBlockWriter_readInt(JbRef, JbedAddress);
void CodeBlockWriter_writeBlock(JbRef, JbedAddress, int32_t, JbedAddress);

JbedAddress DirectCodeBlockWriter_relocateAdr(JbRef, JbedAddress);
void DirectCodeBlockWriter_writeByte(JbRef, JbedAddress, int32_t);
void DirectCodeBlockWriter_writeShort(JbRef, JbedAddress, int32_t);
void DirectCodeBlockWriter_writeInt(JbRef, JbedAddress, int32_t);
int32_t DirectCodeBlockWriter_readShort(JbRef, JbedAddress);
int32_t DirectCodeBlockWriter_readInt(JbRef, JbedAddress);
JbedAddress Writer_allocIntern(JbRef, JbRef, int32_t, bool);
void CodeBlock_readBlock(JbRef, JbedAddress, JbRef, int32_t, int32_t);

void Writer_finishBlock(JbRef);
#endif
