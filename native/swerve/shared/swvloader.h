#ifndef JBED_SWERVE_SWVLOADER_H
#define JBED_SWERVE_SWVLOADER_H
#include "engine.h"

SWV_EXTERN_C_BEGIN

typedef int (*SwvURIRead)(void **stream, const uint16_t *name, unsigned limit, void *buffer, unsigned *actual);
typedef int (*SwvURIIsRelative)(const uint16_t *name);
typedef unsigned (*SwvURIResolve)(const uint16_t *base, const uint16_t *name, uint16_t *out);
typedef struct SwvLoader SwvLoader;
int swvURIRead_stdio(void **stream, const uint16_t *name, unsigned limit, void *buffer, unsigned *actual);
int swvURIIsRelative_stdio(const uint16_t *name);
unsigned swvURIResolve_stdio(const uint16_t *base, const uint16_t *name, uint16_t *out);
int swvLoaderCreate(SwvURIRead, SwvURIIsRelative, SwvURIResolve, SwvLoader **);
void swvLoaderFree(SwvLoader *);
void *swvLoaderGetRoot(SwvLoader *, int index);
int swvLoaderGetRootCount(SwvLoader *);
int swvLoaderLoadBuffer(SwvLoader *, int size, const uint8_t *, int extensions, int *status);
int swvLoaderLoadNamed(SwvLoader *, const uint16_t *name, int extensions, int *status);
void *swvLoadBuffer(SwvURIRead, SwvURIIsRelative, SwvURIResolve, int size, const uint8_t *, int extensions, int world_only);
void *swvLoadNamed(SwvURIRead, SwvURIIsRelative, SwvURIResolve, const uint16_t *name, int extensions, int world_only);
int swvPNGLoadBuffer(int size, const uint8_t *buffer, void **image);
int swvPNGLoadNamed(SwvURIRead, const uint16_t *name, void **image);
SWV_EXTERN_C_END
#endif
