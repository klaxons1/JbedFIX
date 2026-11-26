#ifndef JBED_SWERVE_PLATFORM_H
#define JBED_SWERVE_PLATFORM_H
#include "engine.h"
#include <stddef.h>
#include <stdint.h>

SWV_EXTERN_C_BEGIN

enum { SWV_ZLIB = 0x5a4c4942 }; /* "ZLIB" */

typedef struct SwvInflater SwvInflater;
void swvExit(void);
void *swvMemCpy(void *destination, const void *source, size_t length);
void *swvMemSet(void *destination, int value, size_t length);
void *swvAllocate(size_t size);
void swvFree(void *pointer);
int swvGetVM_ID(void);
void *swvGetGlobalDataPointer(void);
void swvSetGlobalDataPointer(void *data);
uint32_t swvAdler32(uint32_t sum, const uint8_t *data, unsigned count);
int swvDecompressOnDataStart(uint32_t type, void *loader, SwvInflater **out);
int swvDecompressOnData(const uint8_t *input, unsigned count, SwvInflater **state);
int swvDecompressOnDataEnd(SwvInflater **state);
int swvDecompressError(SwvInflater **state);
unsigned swvwcstombs(char *out, const uint16_t *source, unsigned limit);
unsigned swvmbstowcs(uint16_t *out, const char *source, unsigned limit);
uint16_t *swvItoW(int value, uint16_t *out);
uint16_t *swvFtoW(double value, uint16_t *out, int digits);
uint16_t *swvStrCpy(uint16_t *out, const uint16_t *source);
uint16_t *swvStrCat(uint16_t *out, const uint16_t *source);
unsigned swvStrLen(const uint16_t *source);
SWV_EXTERN_C_END
#endif
