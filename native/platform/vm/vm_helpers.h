#ifndef JBED_VM_HELPERS_H
#define JBED_VM_HELPERS_H

#include <stdint.h>

int Jbni_convertUcs2ToAscii(const uint16_t *source, int units, char *dest, int bytes);
int Jbni_convertAsciiToUcs2(const char *source, int length, uint16_t *dest, int bytes);
int Jbni_convertUcs2ToUtf8(const uint16_t *source, int units, char *dest, int bytes);
int Jbni_convertUtf8ToUcs2(const char *source, int length, uint16_t *dest, int bytes);
uint32_t Jbed_crc32_byte(uint32_t crc, uint8_t byte);
uint32_t Jbed_crc32(uint32_t crc, const uint8_t *data, int length);
int64_t jbed_mkgmtime(uint32_t year, uint32_t month, int day,
                       int hour, int minute, int second);

#endif
