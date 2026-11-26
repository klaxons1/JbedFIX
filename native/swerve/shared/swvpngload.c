#include "swvloader.h"
#include "image2d.h"
#include "platform.h"
#include <limits.h>
#include <setjmp.h>
#include <stddef.h>

#include <png.h>

typedef struct {
    const uint8_t *cursor, *end;
    uint8_t *pixels, *palette, **rows;
} PngSource;

static void PNG_bufcpy(png_structp png, uint8_t *out, size_t n)
{
    PngSource *s = png_get_io_ptr(png);
    if (!s || (size_t)(s->end - s->cursor) < n) {
        png_error(png, "Read Error");
        return;
    }
    swvMemCpy(out, s->cursor, n);
    s->cursor += n;
}

static int load_image(png_structp png, png_infop info, PngSource *s, void **image)
{
    static const uint8_t scale[] = {0,255,85,36,17,8,4,2,1};
    uint32_t width, height;
    int depth, color, alpha_count = 0, palette_count = 0;
    uint8_t *alpha = NULL;
    png_color_16 *key = NULL;
    if (setjmp(png_jmpbuf(png))) return 0;
    png_set_read_fn(png, s, PNG_bufcpy);
    png_read_info(png, info);
    if (!png_get_IHDR(png, info, &width, &height, &depth, &color, NULL, NULL, NULL)) return 0;
    if (png_get_valid(png, info, PNG_INFO_tRNS)) png_get_tRNS(png, info, &alpha, &alpha_count, &key);
    if (depth == 16) png_set_strip_16(png);
    if (depth < 8) png_set_packing(png);
    int keyed = (color == PNG_COLOR_TYPE_GRAY || color == PNG_COLOR_TYPE_RGB) && alpha_count > 0 && depth != 16 && key;
    unsigned channels;
    int format;
    switch (color) {
    case PNG_COLOR_TYPE_GRAY: format = keyed ? SWV_IMAGE_LUMINANCE_ALPHA : SWV_IMAGE_LUMINANCE; channels = keyed ? 2 : 1; break;
    case PNG_COLOR_TYPE_RGB: format = keyed ? SWV_IMAGE_RGBA : SWV_IMAGE_RGB; channels = keyed ? 4 : 3; break;
    case PNG_COLOR_TYPE_GRAY_ALPHA: format = SWV_IMAGE_LUMINANCE_ALPHA; channels = 2; break;
    case PNG_COLOR_TYPE_RGB_ALPHA: format = SWV_IMAGE_RGBA; channels = 4; break;
    case PNG_COLOR_TYPE_PALETTE: {
        png_color *palette = NULL;
        if (!png_get_PLTE(png, info, &palette, &palette_count) || palette_count <= 0 || palette_count > 256)
            return 0;
        unsigned components = alpha_count > 0 ? 4 : 3;
        format = alpha_count > 0 ? SWV_IMAGE_RGBA : SWV_IMAGE_RGB;
        channels = 1;
        s->palette = swvAllocate(palette_count * components);
        if (!s->palette) return 0;
        for (int i = 0; i < palette_count; ++i) {
            uint8_t *entry = s->palette + i * components;
            entry[0] = palette[i].red;
            entry[1] = palette[i].green;
            entry[2] = palette[i].blue;
            if (components == 4) entry[3] = i < alpha_count ? alpha[i] : 255;
        }
        break;
    }
    default: return 0;
    }
    if (!width || !height || width > INT_MAX / channels / height ||
        height > UINT_MAX / sizeof *s->rows) return 0;
    unsigned stride = width * channels, length = stride * height;
    s->pixels = swvAllocate(length);
    s->rows = swvAllocate(height * sizeof *s->rows);
    if (!s->pixels || !s->rows) return 0;
    for (unsigned y = 0; y < height; ++y) s->rows[y] = s->pixels + y * stride;
    png_read_image(png, s->rows);
    png_read_end(png, info);
    if (s->palette)
        return image2d_createPalettized(format, width, height, length, s->pixels,
                                        palette_count * (alpha_count > 0 ? 4 : 3), s->palette, image);
    for (unsigned y = 0; y < height; ++y) {
        uint8_t *row = s->rows[y];
        if (depth < 8)
            for (unsigned x = 0; x < width; ++x) row[x] *= scale[depth];
        if (!keyed) continue;
        /* Grow each row backwards. Its allocations already include space for alpha. */
        for (unsigned x = width; x-- > 0;) {
            uint8_t *dst = row + x * channels;
            if (color == PNG_COLOR_TYPE_GRAY) {
                uint8_t gray = row[x];
                dst[0] = gray;
                dst[1] = gray == (uint8_t)(key->gray * scale[depth]) ? 0 : 255;
            } else {
                uint8_t r = row[3*x], g = row[3*x+1], b = row[3*x+2];
                dst[0] = r;
                dst[1] = g;
                dst[2] = b;
                dst[3] = (r == (uint8_t)key->red && g == (uint8_t)key->green &&
                          b == (uint8_t)key->blue) ? 0 : 255;
            }
        }
    }
    return image2d_create(format, width, height, length, s->pixels, image);
}

int swvPNGLoadBuffer(int size, const uint8_t *buffer, void **image)
{
    *image = NULL;
    if (!buffer || size < 8 || png_sig_cmp(buffer, 0, 8)) return 0;
    png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!png) return 0;
    png_infop info = png_create_info_struct(png);
    PngSource source = {.cursor = buffer, .end = buffer + size};
    int ok = info && load_image(png, info, &source, image);
    swvFree(source.pixels);
    swvFree(source.rows);
    swvFree(source.palette);
    png_destroy_read_struct(&png, &info, NULL);
    return ok;
}

int swvPNGLoadNamed(SwvURIRead read, const uint16_t *name, void **image)
{
    uint8_t block[1024], *bytes = NULL;
    unsigned n = 0, total = 0;
    void *stream = NULL;
    int ok = 0;
    *image = NULL;
    if (!read) return 0;
    while (read(&stream, name, sizeof block, block, &n)) {
        if (!n) {
            ok = 1;
            break;
        }
        if (n > sizeof block || total > INT_MAX - n) break;
        uint8_t *larger = swvAllocate(total + n);
        if (!larger) break;
        if (total) swvMemCpy(larger, bytes, total);
        swvMemCpy(larger + total, block, n);
        swvFree(bytes);
        bytes = larger;
        total += n;
        name = NULL;
    }
    read(&stream, NULL, 0, NULL, &n);
    if (ok) ok = swvPNGLoadBuffer(total, bytes, image);
    swvFree(bytes);
    return ok;
}
