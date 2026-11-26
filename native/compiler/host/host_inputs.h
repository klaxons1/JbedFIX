#ifndef JBED_HOST_INPUTS_H
#define JBED_HOST_INPUTS_H

#include "writer.h"

/* The caller owns out->data. Addresses in the image include the ELF load base. */
bool jbed_host_read_rom(const char *path, JbedAddress base, JbedBuffer *out,
                        char *error, size_t error_size);

/* The binary class name uses '/' separators. Name and bytes last for one call. */
typedef bool (*JbedHostClassFn)(void *context, const char *name, const uint8_t *bytes, size_t length);
bool jbed_host_read_jar(const char *path, JbedHostClassFn define, void *context,
                        char *error, size_t error_size);

#endif
