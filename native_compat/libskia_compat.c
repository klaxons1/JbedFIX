/*
 * Link/load compatibility layer for the small legacy Skia ABI surface imported
 * by libjbedvm.so. Android 11 does not provide an app-loadable libskia.so.
 *
 * This is intentionally a conservative first-stage adapter: it preserves the
 * old C++ symbol ABI and makes primitive operations safe no-ops. The Jbed VM
 * still renders most graphics through its locked Surface buffer. Text rendered
 * through this old Skia path is not implemented yet. A full renderer needs a
 * separate public-API bridge to Bitmap/Canvas or ANativeWindow.
 *
 * Functions use assembler symbol names because Jbed was built against the old
 * C++ ABI while this shim intentionally has no C++ runtime dependency.
 */

#include <stdint.h>

#define EXPORTED __attribute__((visibility("default")))

/* SkPaint */
void sk_paint_ctor(void *self) asm("_ZN7SkPaintC1Ev");
void sk_paint_ctor(void *self) { (void)self; }
void sk_paint_set_text_size(void *self, float size) asm("_ZN7SkPaint11setTextSizeEf");
void sk_paint_set_text_size(void *self, float size) { (void)self; (void)size; }
void *sk_paint_set_typeface(void *self, void *typeface) asm("_ZN7SkPaint11setTypefaceEP10SkTypeface");
void *sk_paint_set_typeface(void *self, void *typeface) { (void)self; (void)typeface; return 0; }
void sk_paint_set_antialias(void *self, int enabled) asm("_ZN7SkPaint12setAntiAliasEb");
void sk_paint_set_antialias(void *self, int enabled) { (void)self; (void)enabled; }
void sk_paint_set_skew(void *self, float skew) asm("_ZN7SkPaint12setTextSkewXEf");
void sk_paint_set_skew(void *self, float skew) { (void)self; (void)skew; }
void sk_paint_set_encoding(void *self, int encoding) asm("_ZN7SkPaint15setTextEncodingENS_12TextEncodingE");
void sk_paint_set_encoding(void *self, int encoding) { (void)self; (void)encoding; }
void sk_paint_set_underline(void *self, int enabled) asm("_ZN7SkPaint16setUnderlineTextEb");
void sk_paint_set_underline(void *self, int enabled) { (void)self; (void)enabled; }
void sk_paint_set_color(void *self, uint32_t color) asm("_ZN7SkPaint8setColorEj");
void sk_paint_set_color(void *self, uint32_t color) { (void)self; (void)color; }
float sk_paint_measure_text(const void *self, const void *text, uint32_t length, void *bounds) asm("_ZNK7SkPaint11measureTextEPKvjP6SkRect");
float sk_paint_measure_text(const void *self, const void *text, uint32_t length, void *bounds) { (void)self; (void)text; (void)length; (void)bounds; return 0.0f; }
float sk_paint_get_metrics(const void *self, void *metrics, float scale) asm("_ZNK7SkPaint14getFontMetricsEPNS_11FontMetricsEf");
float sk_paint_get_metrics(const void *self, void *metrics, float scale) { (void)self; (void)metrics; (void)scale; return 0.0f; }

/* SkTypeface */
void *sk_typeface_create(const char *name, int style) asm("_ZN10SkTypeface14CreateFromNameEPKcNS_5StyleE");
void *sk_typeface_create(const char *name, int style) { (void)name; (void)style; return 0; }

/* SkBitmap */
void sk_bitmap_ctor(void *self) asm("_ZN8SkBitmapC1Ev");
void sk_bitmap_ctor(void *self) { (void)self; }
void sk_bitmap_dtor(void *self) asm("_ZN8SkBitmapD1Ev");
void sk_bitmap_dtor(void *self) { (void)self; }
void sk_bitmap_set_config(void *self, int config, int width, int height, int row_bytes) asm("_ZN8SkBitmap9setConfigENS_6ConfigEiii");
void sk_bitmap_set_config(void *self, int config, int width, int height, int row_bytes) { (void)self; (void)config; (void)width; (void)height; (void)row_bytes; }
void sk_bitmap_set_pixels(void *self, void *pixels, void *color_table) asm("_ZN8SkBitmap9setPixelsEPvP12SkColorTable");
void sk_bitmap_set_pixels(void *self, void *pixels, void *color_table) { (void)self; (void)pixels; (void)color_table; }

/* SkCanvas */
void sk_canvas_ctor(void *self, void *device) asm("_ZN8SkCanvasC1EP8SkDevice");
void sk_canvas_ctor(void *self, void *device) { (void)self; (void)device; }
void sk_canvas_dtor(void *self) asm("_ZN8SkCanvasD1Ev");
void sk_canvas_dtor(void *self) { (void)self; }
void sk_canvas_set_bitmap_device(void *self, const void *bitmap) asm("_ZN8SkCanvas15setBitmapDeviceERK8SkBitmap");
void sk_canvas_set_bitmap_device(void *self, const void *bitmap) { (void)self; (void)bitmap; }
int sk_canvas_clip_rect(void *self, const void *rect, int op) asm("_ZN8SkCanvas8clipRectERK6SkRectN8SkRegion2OpE");
int sk_canvas_clip_rect(void *self, const void *rect, int op) { (void)self; (void)rect; (void)op; return 1; }
void sk_canvas_draw_text(void *self, const void *text, uint32_t length, float x, float y, const void *paint) asm("_ZN8SkCanvas8drawTextEPKvjffRK7SkPaint");
void sk_canvas_draw_text(void *self, const void *text, uint32_t length, float x, float y, const void *paint) { (void)self; (void)text; (void)length; (void)x; (void)y; (void)paint; }
