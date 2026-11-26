#ifndef JBED_SWERVE_RENDER_H
#define JBED_SWERVE_RENDER_H
#include <stdbool.h>
#include <stdint.h>

typedef enum {
    SWV_IMAGE_NONE = 95, SWV_IMAGE_ALPHA, SWV_IMAGE_LUMINANCE, SWV_IMAGE_LUMINANCE_ALPHA,
    SWV_IMAGE_RGB, SWV_IMAGE_RGBA
} SwvImageFormat;

typedef enum {
    SWV_BLEND_ALPHA = 64, SWV_BLEND_ALPHA_ADD, SWV_BLEND_MODULATE, SWV_BLEND_MODULATE_X2,
    SWV_BLEND_REPLACE
} SwvBlendMode;

enum { SWV_FOG_NONE = 79, SWV_FOG_EXPONENTIAL, SWV_FOG_LINEAR };
enum { SWV_LIGHT_AMBIENT = 128, SWV_LIGHT_DIRECTIONAL, SWV_LIGHT_OMNI, SWV_LIGHT_SPOT };

/* Limits exposed by the software renderer's Graphics3D capabilities. */
enum {
    SWV_MAX_LIGHTS = 256,
    SWV_TEXTURE_UNITS = 2,
    SWV_MAX_TRANSFORMS_PER_VERTEX = 2,
    SWV_MAX_VIEWPORT_DIMENSION = 1024,
    SWV_MAX_TEXTURE_DIMENSION = 1024,
    SWV_MAX_SPRITE_CROP_DIMENSION = 1024
};

typedef struct SssTLTexCoordsStd {
    int32_t s, t, r, q;
} SssTLTexCoordsStd;

/* CssRendererStandard submits 28.4 screen coordinates and a 16-bit depth
 * with twelve fractional bits. Texture coordinates and RGB are 16.16. */
typedef struct SssProjectedVertex {
    int32_t x, y, z, rgb[3];
    uint8_t alpha, fog;
    SssTLTexCoordsStd tex[2];
} SssProjectedVertex;


#endif
