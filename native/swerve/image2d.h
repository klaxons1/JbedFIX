#ifndef SWV_IMAGE2D_H
#define SWV_IMAGE2D_H
#include "engine.h"
#include "render.h"

#ifdef __cplusplus
extern "C" {
#endif
int image2d_create(int format, int width, int height, int size, const uint8_t *data, void **out);
int image2d_createPalettized(int format, int width, int height, int size, const uint8_t *data,
                            int palette_size, const uint8_t *palette, void **out);
int image2d_createMutable(int format, int width, int height, void **out);
int image2d_createUninitialized(int format, int width, int height, int immutable, void **out);
int image2d_set(void *handle, int x, int y, int width, int height, int size, const uint8_t *data);
void image2d_getFormat(void *handle, int *result);
void image2d_getWidth(void *handle, int *result);
void image2d_getHeight(void *handle, int *result);
void image2d_isMutable(void *handle, int *result);
void image2d_getPixels(void *handle, uint16_t **result);
void image2d_getPalette(void *handle, uint16_t **result);
void image2d_getAlpha(void *handle, uint8_t **result);
int stageset_create(int width, int height, int size, const uint8_t *data, void **out);
int stageset_createMutable(int width, int height, void **out);
void stageset_getScale(void *, float *);
void stageset_getBias(void *, float *);
int stageset_setScale(void *, float);
int stageset_setBias(void *, float);

#ifdef __cplusplus
}
#endif
#endif
