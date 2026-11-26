#include "image.h"
#include "graphics.h"

#include <stdlib.h>
#include <string.h>

extern void Jbni_intern_raiseCommonException(int);
extern uint32_t Jbed_noAllocation;

static uint16_t rgb565(uint32_t rgb)
{
    return ((rgb >> 8) & 0xf800) | ((rgb >> 5) & 0x07e0) | ((rgb >> 3) & 31);
}

unsigned LCDUIgetPixel(uint32_t rgb, unsigned gray, int use_gray)
{
    static const uint32_t shades4[] = {
        0, 0x3a403a, 0x4d544d, 0x5b645b, 0x667166, 0x707b70, 0x788578, 0x808d80,
        0x879587, 0x8d9c8d, 0x93a393, 0x99a999, 0x9faf9f, 0xa4b5a4, 0xa9baa9, 0xaec0ae
    };
    static const uint32_t shades2[] = { 0, 0x6f7b6f, 0x94a394, 0xaec0ae };
    if (LCDUI_depth >= 8) return rgb565(rgb);
    if (!use_gray)
        gray = (76 * ((rgb >> 16) & 255) + 150 * ((rgb >> 8) & 255) + 29 * (rgb & 255)) >> 8;
    if (LCDUI_depth == 4) return rgb565(shades4[gray >> 4]);
    if (LCDUI_depth == 2) return rgb565(shades2[gray >> 6]);
    return LCDUI_depth == 1 && gray > 127 ? 44565 : 0;
}

static uint32_t pixel_rgb(uint16_t pixel)
{
    return (uint32_t)(pixel & 0xf800) << 8 | (uint32_t)(pixel & 0x07e0) << 5 |
           (unsigned)(pixel & 31) << 3;
}

uint32_t LCDUIgetDisplayColor(uint32_t rgb)
{
    return pixel_rgb(rgb565(rgb));
}

uint32_t GUI_getBmpStoreSize(uint32_t w, uint32_t h)
{
    return 2 * w * h;
}

void GUI_createBitmap(JbedBitmap *bmp)
{
    bmp->pixels_offset = sizeof(*bmp);
    bmp->stride_bytes = 2 * bmp->width;
}

void GUI_releaseBitmap(JbedBitmap *bmp) { (void)bmp; }

void LCDUIdestroyNativeImage(JbedBitmap *bmp)
{
    GUI_releaseBitmap(bmp);
}

static uint32_t storage_size(DstImage *dst, uint32_t w, uint32_t h)
{
    (void)dst;
    return GUI_getBmpStoreSize(w, h) + sizeof(JbedBitmap);
}

static void pin_interior(void *slot, JbArray *base)
{
    *Jbed_nativeCallStateAdr++ = (void *)(intptr_t)-1;
    *Jbed_nativeCallStateAdr++ = slot;
    *Jbed_nativeCallStateAdr++ = base;
}

bool jbed_image_plane(DstImage *dst, uint32_t size, bool alpha)
{
    JbArray *a = dst->alloc(*dst->image, (int32_t)size, alpha);
    if (!a) return false;
    if (alpha) {
        dst->alpha = (uint8_t *)a->data;
        pin_interior(&dst->alpha, a);
    } else {
        dst->bitmap = (JbedBitmap *)a->data;
        pin_interior(&dst->bitmap, a);
    }
    return true;
}

static int dimensions(DstImage *dst, unsigned width, unsigned height)
{
    DstImage *s = dst->state;
    JbedBitmap *bmp = s->bitmap;
    if (!bmp) return 0;
    s->active = bmp;
    bmp->width = (uint16_t)width;
    bmp->height = (uint16_t)height;
    bmp->flags = s->mutable_image ? BITMAP_MUTABLE : 0;
    GUI_createBitmap(bmp);
    uint16_t color = rgb565(backgroundColor);
    if (s->mutable_image && color) {
        JbedGraphics g = {.clip_right = (int)width, .clip_bottom = (int)height, .bitmap = bmp,
                          .argb = backgroundColor | 0xff000000, .pixel = color};
        LCDUIfillRect(&g, 0, 0, width, height);
    }
    if (s->alpha) bmp->flags |= s->mutable_image ? BITMAP_ALPHA | BITMAP_FRACTIONAL_ALPHA : BITMAP_ALPHA;
    return 1;
}

static void palette(DstImage *dst, const uint32_t *rgb, unsigned count)
{
    DstImage *s = dst->state;
    free(s->colors);
    s->colors = malloc(count * sizeof(*rgb));
    if (s->colors) memcpy(s->colors, rgb, count * sizeof(*rgb));
}

static void transparent(DstImage *dst, uint32_t rgb, int index)
{
    DstImage *s = dst->state;
    s->active->flags |= BITMAP_ALPHA | BITMAP_COLOR_KEY;
    s->active->transparent_pixel = rgb565(rgb);
    if (index >= 0 && s->colors) s->colors[index] |= 0xff000000u;
}

static void write_row(DstImage *dst, unsigned y, const uint8_t *pixels,
                      const uint8_t *alpha, int rgb24)
{
    DstImage *s = dst->state;
    JbedBitmap *bmp = s->active = s->bitmap;
    if (!bmp) return;
    if (alpha && s->alpha) {
        bmp->flags |= BITMAP_ALPHA;
        memcpy(s->alpha + y * bmp->width, alpha, bmp->width);
    }
    uint16_t *out = jbed_bitmap_row(bmp, y);
    if (rgb24) {
        for (unsigned x = 0; x < bmp->width; ++x, pixels += 3)
            out[x] = rgb565((uint32_t)pixels[0] << 16 | (unsigned)pixels[1] << 8 | pixels[2]);
    } else if (s->colors) {
        for (unsigned x = 0; x < bmp->width; ++x) {
            uint32_t entry = s->colors[pixels[x]];
            out[x] = entry >> 24 ? bmp->transparent_pixel : rgb565(entry);
        }
    } else {
        for (unsigned x = 0; x < bmp->width; ++x) {
            unsigned index = pixels[x];
            out[x] = rgb565((index & 0xe0) << 16 | ((index << 3) & 0xe0) << 8 | ((index << 6) & 255));
        }
    }
}

static void packed_row(DstImage *dst, unsigned y, const uint8_t *indices)
{
    write_row(dst, y, indices, NULL, 0);
}

static void finish(DstImage *dst)
{
    DstImage *s = dst->state;
    if (s->mutable_image) return;
    JbedBitmap *bmp = s->active = s->bitmap;
    if ((bmp->flags & (BITMAP_ALPHA | BITMAP_COLOR_KEY)) != BITMAP_ALPHA) return;
    bool clear = false;
    for (uint32_t i = 0; i < bmp->width * bmp->height; ++i) {
        uint8_t opacity = s->alpha[i];
        if (opacity == 0) clear = true;
        else if (opacity != 255) {
            bmp->flags |= BITMAP_FRACTIONAL_ALPHA;
            return;
        }
    }
    if (!clear) {
        bmp->flags &= ~BITMAP_ALPHA;
        dst->release_alpha(dst);
        bmp = s->active;
    }
    bmp->flags &= ~BITMAP_FRACTIONAL_ALPHA;
}

static void copy(DstImage *dst, const JbedBitmap *src)
{
    DstImage *s = dst->state;
    JbedBitmap *d = s->active = s->bitmap;
    unsigned h = d->height < src->height ? d->height : src->height;
    if (d->stride_bytes > 0 && d->stride_bytes == src->stride_bytes) {
        memcpy(jbed_bitmap_row(d, 0), jbed_bitmap_row(src, 0), d->stride_bytes * h);
    } else {
        unsigned w = d->width < src->width ? d->width : src->width;
        for (unsigned y = 0; y < h; ++y)
            memcpy(jbed_bitmap_row(d, y), jbed_bitmap_row(src, y), 2 * w);
    }
    if (src->flags & BITMAP_ALPHA) {
        d->flags = (d->flags & ~BITMAP_FRACTIONAL_ALPHA) | BITMAP_ALPHA | (src->flags & BITMAP_FRACTIONAL_ALPHA);
        if (src->flags & BITMAP_COLOR_KEY) {
            d->flags |= BITMAP_COLOR_KEY;
            d->transparent_pixel = src->transparent_pixel;
        }
    }
}

static void copy_region(DstImage *dst, const JbedBitmap *src, const uint8_t *source_alpha,
                        int x, int y, int width, int height, unsigned transform)
{
    DstImage *s = dst->state;
    JbedBitmap *d = s->active = s->bitmap;
    JbedGraphics g = {.clip_right = (int)d->width, .clip_bottom = (int)d->height, .bitmap = d};
    LCDUIdrawRegion(&g, src, 0, 0, LCDUI_TOP | LCDUI_LEFT, x, y, width, height, transform, 0, 1,
                    source_alpha, dst->alpha);
    if (src->flags & BITMAP_ALPHA) {
        d->flags |= BITMAP_ALPHA;
        if (src->flags & BITMAP_COLOR_KEY) {
            d->flags |= BITMAP_COLOR_KEY;
            d->transparent_pixel = src->transparent_pixel;
        }
    }
}

static void write_argb(DstImage *dst, const JbArray *argb, int width, int height, int has_alpha)
{
    DstImage *s = dst->state;
    JbedBitmap *d = s->active = s->bitmap;
    const uint32_t *in = argb->data;
    uint8_t *alpha = s->alpha;
    bool partial = false, clear = false;
    for (int y = 0; y < height; ++y) {
        uint16_t *out = jbed_bitmap_row(d, (unsigned)y);
        for (int x = 0; x < width; ++x, ++in) {
            out[x] = rgb565(*in);
            if (has_alpha) {
                uint8_t a = *in >> 24;
                *alpha++ = a;
                if (!a) clear = true;
                else if (a != 255) partial = true;
            }
        }
    }
    if (!has_alpha) { d->flags &= ~BITMAP_ALPHA; return; }
    d->flags |= BITMAP_ALPHA;
    if (partial) { d->flags |= BITMAP_FRACTIONAL_ALPHA; return; }
    if (!clear) {
        d->flags &= ~BITMAP_ALPHA;
        dst->release_alpha(dst);
    }
    s->active->flags &= ~BITMAP_FRACTIONAL_ALPHA;
}

static void get_size(DstImage *dst, uint32_t *width, uint32_t *height)
{
    if (dst->state) {
        JbedBitmap *bmp = dst->state->active = dst->state->bitmap;
        *width = bmp->width;
        *height = bmp->height;
    }
}

static void destroy(DstImage *dst)
{
    DstImage *s = dst->state;
    if (s) { free(s->colors); s->colors = NULL; free(s); }
}

DstImage *LCDUIcreateImageDst(int mutable_image, JbedImageAlloc alloc, void (*release)(DstImage *),
                              void **image)
{
    DstImage *s = malloc(sizeof(*s));
    if (!s) return NULL;
    /* color_space and components are set by JPEG only. The original leaves
     * both words untouched for GIF and PNG. */
    s->packed_depth = 8;
    s->state = s;
    s->alpha = NULL;
    s->image = image;
    s->palette = palette;
    s->storage_size = storage_size;
    s->dimensions = dimensions;
    s->row = write_row;
    s->packed_row = packed_row;
    s->copy = copy;
    s->release_alpha = release;
    s->region = copy_region;
    s->argb = write_argb;
    s->destroy = destroy;
    s->size = get_size;
    s->alloc = alloc;
    s->transparent = transparent;
    s->finish = finish;
    s->active = NULL;
    s->colors = NULL;
    s->mutable_image = mutable_image;
    return s;
}

int decodeImageFromData(DstImage *dst, const uint8_t **cursor, int32_t size)
{
    const uint8_t *p = *cursor;
    if (size > 8 && !memcmp(p, "\211PNG\r\n\032\n", 8))
        return PNGdecodeImage(cursor, size, dst);
    if (size > 3 && !memcmp(p, "GIF", 3))
        return GIFdecodeImage(cursor, size, dst);
    if (size > 4 && p[0] == 255 && p[1] == 216 && p[2] == 255)
        return JPEGdecodeImage(cursor, size, dst);
    return 0;
}

static uint8_t *array_data(JbRef ref)
{
    return ref ? (uint8_t *)((JbArray *)(uintptr_t)ref)->data : NULL;
}

JbedBitmap *getImageData(const JbedImage *image)
{
    return image ? (JbedBitmap *)array_data(image->pixels) : NULL;
}

uint8_t *LCDUIgetImageAlphaValues(const JbedBitmap *bmp, const JbedImage *image)
{
    return (bmp->flags & (BITMAP_ALPHA | BITMAP_COLOR_KEY)) == BITMAP_ALPHA ? array_data(image->alpha) : NULL;
}

static JbArray *allocate_array(void *owner, int32_t size, int alpha)
{
    JbedImage *image = owner;
    if (size == -1) { image->pixels = 0; return NULL; }
    void **roots = Jbed_nativeCallStateAdr;
    *Jbed_nativeCallStateAdr++ = &image;
    JbArray *a = Jbni_newByteArray(size);
    *Jbed_nativeCallStateAdr++ = &a;
    if (!a) Jbni_intern_raiseCommonException(JBED_EXCEPTION_OUT_OF_MEMORY);
    if (alpha) image->alpha = jb_ref(a);
    else image->pixels = jb_ref(a);
    Jbed_nativeCallStateAdr = roots;
    return a;
}

static void drop_alpha(DstImage *d)
{
    ((JbedImage *)*d->image)->alpha = 0;
}

static DstImage *destination(JbedImage **image, int mutable_image)
{
    DstImage *d = LCDUIcreateImageDst(mutable_image, allocate_array, drop_alpha, (void **)image);
    if (!d) Jbni_intern_raiseCommonException(JBED_EXCEPTION_OUT_OF_MEMORY);
    return d;
}

static void decode_image(JbedImage *image, JbArray *bytes, int offset, int count, int mutable_image)
{
    if (!bytes) { Jbni_intern_raiseCommonException(JBED_EXCEPTION_NULL_POINTER); return; }
    if (offset < 0 || count < 0 || (int32_t)((uint32_t)offset + count) > bytes->length) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_ARRAY_BOUNDS); return;
    }
    void **roots = Jbed_nativeCallStateAdr;
    *Jbed_nativeCallStateAdr++ = &image;
    const uint8_t *cursor = (uint8_t *)bytes->data + offset;
    pin_interior(&cursor, bytes);
    DstImage *d = destination(&image, mutable_image);
    if (decodeImageFromData(d, &cursor, count)) {
        uint32_t w, h;
        d->size(d, &w, &h);
        image->width = w;
        image->height = h;
        memcpy(&image->color_space, &d->color_space, sizeof(uint32_t) * 2);
        d->destroy(d);
    } else {
        d->destroy(d);
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT);
    }
    Jbed_nativeCallStateAdr = roots;
}

void JbniV_javax_microedition_lcdui_MutableImage_decodeImage(JbedImage *i, JbArray *b, int off, int n)
{
    decode_image(i, b, off, n, 1);
}

void JbniV_javax_microedition_lcdui_ImmutableImage_decodeImage(JbedImage *i, JbArray *b, int off, int n)
{
    decode_image(i, b, off, n, 0);
}

void JbniV_javax_microedition_lcdui_ImmutableImage_loadIcon(void) {}

void JbniV_javax_microedition_lcdui_Image_finalize(JbedImage *i)
{
    JbedBitmap *b = getImageData(i);
    if (b) LCDUIdestroyNativeImage(b);
}

void JbniV_javax_microedition_lcdui_ImmutableImage_decodeRGBImage(
    JbedImage *i, JbArray *argb, int w, int h, uint8_t alpha)
{
    void **roots = Jbed_nativeCallStateAdr;
    *Jbed_nativeCallStateAdr++ = &i;
    *Jbed_nativeCallStateAdr++ = &argb;
    if (!argb) Jbni_intern_raiseCommonException(JBED_EXCEPTION_NULL_POINTER);
    else if (w < 0 || h < 0) Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT);
    else if ((int32_t)((uint32_t)w * h) > argb->length) Jbni_intern_raiseCommonException(JBED_EXCEPTION_ARRAY_BOUNDS);
    else {
        DstImage *d = destination(&i, 0);
        if (d) {
            if (jbed_image_plane(d, d->storage_size(d, w, h), false) &&
                (!alpha || jbed_image_plane(d, (uint32_t)w * h, true)) && d->dimensions(d, w, h))
                d->argb(d, argb, w, h, alpha);
            d->destroy(d);
        }
    }
    Jbed_nativeCallStateAdr = roots;
}

void JbniV_javax_microedition_lcdui_MutableImage_createMutableImageARGB(
    JbedImage *i, int w, int h, uint32_t color)
{
    uint32_t saved_color = backgroundColor;
    if (w < 0 || h < 0) Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT);
    void **roots = Jbed_nativeCallStateAdr;
    *Jbed_nativeCallStateAdr++ = &i;
    DstImage *d = destination(&i, 1);
    if (d) {
        if (jbed_image_plane(d, d->storage_size(d, w, h), false)) {
            unsigned opacity = color >> 24;
            uint32_t n = (uint32_t)w * h;
            if (opacity != 255 && n && jbed_image_plane(d, n, true) && opacity)
                memset(d->alpha, opacity, n);
            backgroundColor = color;
            d->dimensions(d, w, h);
            backgroundColor = saved_color;
        }
        d->destroy(d);
    }
    Jbed_nativeCallStateAdr = roots;
}

static void existing_alpha(uint8_t **slot, JbRef ref)
{
    JbArray *a = (JbArray *)(uintptr_t)ref;
    *slot = (uint8_t *)a->data;
    pin_interior(slot, a);
}

void JbniV_javax_microedition_lcdui_ImmutableImage_createImmutableCopy(
    JbedImage *i, unsigned w, unsigned h, JbedImage *source)
{
    void **roots = Jbed_nativeCallStateAdr;
    *Jbed_nativeCallStateAdr++ = &i;
    *Jbed_nativeCallStateAdr++ = &source;
    DstImage *d = destination(&i, 0);
    if (d) {
        if (jbed_image_plane(d, d->storage_size(d, w, h), false)) {
            if (i->alpha) existing_alpha(&d->alpha, i->alpha);
            if (d->dimensions(d, w, h)) d->copy(d, getImageData(source));
        }
        d->destroy(d);
    }
    Jbed_nativeCallStateAdr = roots;
}

void JbniV_javax_microedition_lcdui_ImmutableImage_createImmutableImageRegion(
    JbedImage *i, JbedImage *source, int x, int y, int w, int h, unsigned transform)
{
    void **roots = Jbed_nativeCallStateAdr;
    *Jbed_nativeCallStateAdr++ = &i;
    *Jbed_nativeCallStateAdr++ = &source;
    DstImage *d = destination(&i, 0);
    uint8_t *alpha = NULL;
    if (d) {
        if (jbed_image_plane(d, d->storage_size(d, i->width, i->height), false)) {
            if (i->alpha) {
                existing_alpha(&d->alpha, i->alpha);
                existing_alpha(&alpha, source->alpha);
            }
            if (d->dimensions(d, i->width, i->height))
                d->region(d, getImageData(source), alpha, x, y, w, h, transform);
        }
        d->destroy(d);
    }
    Jbed_nativeCallStateAdr = roots;
}

void LCDUIgetRGB(JbArray *out, int offset, int stride, int x, int y, int w, int h,
                 const JbedBitmap *bmp, const JbedImage *i)
{
    int32_t abs_stride = stride < 0 ? (int32_t)(0u - (uint32_t)stride) : stride;
    if ((x | y | w | h) < 0 || (unsigned)w > bmp->width - x || (unsigned)h > bmp->height - y ||
        abs_stride < w) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT); return;
    }
    uint32_t last = (uint32_t)offset + (uint32_t)stride * ((uint32_t)h - 1);
    if (offset < 0 || offset >= out->length || (int32_t)(last + w) > out->length ||
        (int32_t)((uint32_t)offset + w) > out->length || (int32_t)last < 0) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_ARRAY_BOUNDS); return;
    }
    const uint8_t *alpha = LCDUIgetImageAlphaValues(bmp, i);
    for (int row = 0; row < h; ++row) {
        const uint16_t *src = jbed_bitmap_row(bmp, (unsigned)(y + row)) + x;
        uint32_t *dest = out->data + offset + row * stride;
        for (int col = 0; col < w; ++col) {
            unsigned opacity = 255;
            if (bmp->flags & BITMAP_ALPHA)
                opacity = (bmp->flags & BITMAP_COLOR_KEY) ? (src[col] == bmp->transparent_pixel ? 0 : 255)
                          : alpha[(y + row) * bmp->width + x + col];
            dest[col] = pixel_rgb(src[col]) | (uint32_t)opacity << 24;
        }
    }
}

void JbniV_javax_microedition_lcdui_Image_getRGB(JbedImage *i, JbArray *out, int offset,
                                                  int stride, int x, int y, int w, int h)
{
    if (!out) Jbni_intern_raiseCommonException(JBED_EXCEPTION_NULL_POINTER);
    else if (w && h) LCDUIgetRGB(out, offset, stride, x, y, w, h, getImageData(i), i);
}
