#ifndef JBED_PLATFORM_IMAGE_H
#define JBED_PLATFORM_IMAGE_H

#include "jbni_objects.h"
#include <stdbool.h>
#include <stddef.h>

typedef struct {
    uint32_t reserved;
    int32_t pixels_offset, stride_bytes;
    uint32_t width, height;
    uint16_t flags, transparent_pixel;
} JbedBitmap;

enum {
    BITMAP_MUTABLE = 1, BITMAP_ALPHA = 2, BITMAP_FRACTIONAL_ALPHA = 4, BITMAP_COLOR_KEY = 8
};

static inline uint16_t *jbed_bitmap_row(const JbedBitmap *bitmap, unsigned y)
{
    /* The screen buffer can be a separate allocation preceding its header. */
    uintptr_t base = (uintptr_t)bitmap + (intptr_t)bitmap->pixels_offset;
    return (uint16_t *)(base + (uintptr_t)y * (intptr_t)bitmap->stride_bytes);
}

typedef struct JbedGraphics {
    uint32_t object_header[3];
    uint8_t hardClipModifiable;
    int32_t translate_x, translate_y, clip_x, clip_y, clip_right, clip_bottom;
    int32_t previous_clip[4], hard_clip[4];
    uint32_t argb, gray_rgb, gray, pixel, stroke;
    JbRef font;
    int32_t max_width, max_height;
    JbedBitmap *bitmap;
    JbRef target, context_stack, saved_context;
    uint8_t screen_graphics_behavior;
} JbedGraphics;

typedef struct JbedImageDestination JbedImageDestination;
typedef JbedImageDestination DstImage;
typedef JbArray *(*JbedImageAlloc)(void *image, int32_t size, int alpha);

struct JbedImageDestination {
    uint32_t packed_depth;
    DstImage *state;
    JbedBitmap *bitmap;
    uint8_t *alpha;
    void **image;
    uint32_t color_space, components;
    void (*palette)(DstImage *, const uint32_t *, unsigned);
    uint32_t (*storage_size)(DstImage *, uint32_t, uint32_t);
    int (*dimensions)(DstImage *, uint32_t, uint32_t);
    void (*reserved)(void);
    void (*row)(DstImage *, unsigned, const uint8_t *, const uint8_t *, int);
    void (*packed_row)(DstImage *, unsigned, const uint8_t *);
    void (*copy)(DstImage *, const JbedBitmap *);
    void (*release_alpha)(DstImage *);
    void (*region)(DstImage *, const JbedBitmap *, const uint8_t *, int, int, int, int, unsigned);
    void (*argb)(DstImage *, const JbArray *, int, int, int);
    void (*destroy)(DstImage *);
    void (*size)(DstImage *, uint32_t *, uint32_t *);
    JbedImageAlloc alloc;
    void (*transparent)(DstImage *, uint32_t rgb, int index);
    void (*finish)(DstImage *);
    JbedBitmap *active;
    uint32_t *colors;
    int mutable_image;
};

_Static_assert(sizeof(JbedBitmap) == 24, "RGB565 store header");
#if UINTPTR_MAX == UINT32_MAX
_Static_assert(offsetof(JbedGraphics, argb) == 72 && offsetof(JbedGraphics, bitmap) == 104, "LCDUI graphics offsets");
_Static_assert(sizeof(DstImage) == 100 && offsetof(DstImage, finish) == 84, "ARM image destination");
#endif

typedef struct {
    uint32_t header[3], width, height, clip_width, clip_height;
    JbRef pixels, alpha;
    uint32_t color_space, components;
} JbedImage;

JbedBitmap *getImageData(const JbedImage *);
uint8_t *LCDUIgetImageAlphaValues(const JbedBitmap *, const JbedImage *);
uint32_t GUI_getBmpStoreSize(uint32_t, uint32_t);
void GUI_createBitmap(JbedBitmap *);
void GUI_releaseBitmap(JbedBitmap *);

extern unsigned LCDUI_depth;
extern uint32_t backgroundColor;
unsigned LCDUIgetPixel(uint32_t rgb, unsigned gray, int use_gray);
uint32_t LCDUIgetDisplayColor(uint32_t rgb);
bool jbed_image_plane(DstImage *, uint32_t size, bool alpha);
DstImage *LCDUIcreateImageDst(int mutable_image, JbedImageAlloc, void (*release_alpha)(DstImage *),
                              void **image);
int PNGdecodeImage(const uint8_t **cursor, int32_t size, DstImage *);
int GIFdecodeImage(const uint8_t **cursor, int32_t size, DstImage *);
int JPEGdecodeImage(const uint8_t **cursor, int32_t size, DstImage *);
int decodeImageFromData(DstImage *, const uint8_t **cursor, int32_t size);

#endif
