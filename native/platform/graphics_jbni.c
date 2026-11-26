#include "graphics_jbni.h"
#include "display.h"

extern uint32_t Jbed_noAllocation;
extern void Jbni_intern_raiseCommonException(int);
extern void Jbni_intern_raiseException(const char *);


static int add(int a, int b) { return (int32_t)((uint32_t)a + (uint32_t)b); }
static int tx(const JbedGraphics *g, int x) { return add(g->translate_x, x); }
static int ty(const JbedGraphics *g, int y) { return add(g->translate_y, y); }

static void select_bitmap(JbedGraphics *g)
{
    g->bitmap = getImageData((JbedImage *)(uintptr_t)g->target);
}

static bool one_bit(unsigned value) { return value && !(value & (value - 1)); }

static bool valid_anchor(unsigned anchor, unsigned forbidden)
{
    if (!anchor) return true;
    return anchor <= LCDUI_ANCHOR_MASK && !(anchor & forbidden) && one_bit(anchor & (LCDUI_LEFT | LCDUI_RIGHT | LCDUI_HCENTER)) &&
           one_bit(anchor & (LCDUI_TOP | LCDUI_BOTTOM | LCDUI_BASELINE | LCDUI_VCENTER));
}

static bool char_range(const JbArray *array, int start, int n)
{
    if (!array) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_NULL_POINTER);
        return false;
    }
    if (start < 0 || n < 0 || start > array->length || n > array->length - start) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_ARRAY_BOUNDS);
        return false;
    }
    return true;
}

static bool string_range(const JbString *s, int start, int n)
{
    if (!s) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_NULL_POINTER);
        return false;
    }
    if (start < 0 || n < 0 || start > s->length || n > s->length || add(start, n) > s->length) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_STRING_BOUNDS);
        return false;
    }
    return true;
}

static unsigned measure(const JbedFont *f, const uint16_t *chars, int n)
{
    unsigned width;
    ++Jbed_noAllocation;
    LCDUIcharsWidth(f->face, f->style, f->size, chars, n, &width);
    --Jbed_noAllocation;
    return width;
}

unsigned JbniV_javax_microedition_lcdui_Font_charWidth(JbedFont *f, uint16_t ch)
{
    return measure(f, &ch, 1);
}

unsigned JbniV_javax_microedition_lcdui_Font_charsWidth(JbedFont *f, const JbArray *a, int start, int n)
{
    if (!char_range(a, start, n) || !n) return 0;
    return measure(f, (const uint16_t *)a->data + start, n);
}

unsigned JbniV_javax_microedition_lcdui_Font_stringWidth(JbedFont *f, const JbString *s)
{
    if (!s) { Jbni_intern_raiseCommonException(JBED_EXCEPTION_NULL_POINTER); return 0; }
    return measure(f, jb_string_chars(s), s->length);
}

unsigned JbniV_javax_microedition_lcdui_Font_substringWidth(JbedFont *f, const JbString *s, int start, int n)
{
    if (!string_range(s, start, n) || !s->length) return 0;
    return measure(f, jb_string_chars(s) + start, n);
}

void JbniV_javax_microedition_lcdui_Font_init(JbedFont *f, int face, int style, int size)
{
    int ascent, descent, leading;
    ++Jbed_noAllocation;
    LCDUIgetFontInfo(face, style, size, &ascent, &descent, &leading);
    f->baseline = ascent;
    f->height = add(add(ascent, descent), leading);
    --Jbed_noAllocation;
}

void JbniV_com_sun_midp_lcdui_DeviceCaps_init(JbedDeviceCaps *d)
{
    int flags;
    LCDUIgetDisplayParams(&d->width, &d->height, &d->fullscreen_width, &d->fullscreen_height,
                          &d->erase_color, &d->depth, &flags);
    d->alpha_levels = 256;
    d->color = !!(flags & LCDUI_CAP_COLOR);
    d->pointer = !!(flags & LCDUI_CAP_POINTER);
    d->motion = !!(flags & LCDUI_CAP_POINTER_MOTION);
    d->repeat = !!(flags & LCDUI_CAP_KEY_REPEAT);
    d->double_buffered = !!(flags & LCDUI_CAP_DOUBLE_BUFFER);
}

void JbniV_com_sun_midp_lcdui_DeviceCaps_switchScreenBuffer(JbedDeviceCaps *d, int orientation)
{
    (void)d;
    LCDUIswitchScreenBuffer(orientation);
}

void JbniV_com_jbed_midp_lcdui_lookandfeel_peer_PeerLookAndFeel_nRefresh(void *peer, int x1, int y1,
                                                                       int x2, int y2)
{
    (void)peer;
    LCDUIrefresh(x1, y1, x2, y2);
}

void JbniV_javax_microedition_lcdui_Display_00024DisplayAccessor_bufferRefresh(void *accessor)
{
    (void)accessor;
    RB_regionIsDirty(0, 0, 32767, 32767);
    LCDUIrefresh(0, 0, 32767, 32767);
}

uint32_t JbniV_javax_microedition_lcdui_Graphics_getDisplayColor(JbedGraphics *g, uint32_t rgb)
{
    (void)g;
    return LCDUIgetDisplayColor(rgb);
}

uint32_t JbniS_javax_microedition_lcdui_Graphics_getPixel(uint32_t rgb, unsigned gray, int use_gray)
{
    return LCDUIgetPixel(rgb, gray, use_gray);
}

void JbniV_javax_microedition_lcdui_Graphics_copyArea(JbedGraphics *g, int sx, int sy, int w, int h,
                                                      int x, int y, int anchor)
{
    if (!getImageData((JbedImage *)(uintptr_t)g->target) || g->screen_graphics_behavior) {
        Jbni_intern_raiseException("java/lang/IllegalStateException");
        return;
    }
    select_bitmap(g);
    LCDUIcopyArea(g, tx(g, sx), ty(g, sy), w, h, tx(g, x), ty(g, y), anchor);
}

void JbniV_javax_microedition_lcdui_Graphics_drawRGB(JbedGraphics *g, const JbArray *pixels, int offset,
                                                     int stride, int x, int y, int w, int h, uint8_t alpha)
{
    if (!pixels) { Jbni_intern_raiseCommonException(JBED_EXCEPTION_NULL_POINTER); return; }
    if (!w || !h) return;
    select_bitmap(g);
    LCDUIdrawRGB(g, pixels, offset, stride, tx(g, x), ty(g, y), w, h, alpha);
}

static void draw_text(JbedGraphics *g, const uint16_t *chars, int n, int x, int y, int anchor, bool clip_string)
{
    if (!valid_anchor((unsigned)anchor, LCDUI_VCENTER)) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT);
        return;
    }
    ++Jbed_noAllocation;
    const JbedFont *font = (const JbedFont *)(uintptr_t)g->font;
    y = ty(g, y);
    select_bitmap(g);
    if (!clip_string || (y >= (int32_t)(0u - (uint32_t)font->height) && y <= add(g->clip_bottom, font->height)))
        LCDUIdrawChars(g, font->face, font->style, font->size, tx(g, x), y, anchor, chars, n);
    --Jbed_noAllocation;
}

void JbniV_javax_microedition_lcdui_Graphics_drawChars(JbedGraphics *g, const JbArray *a, int start, int n,
                                                       int x, int y, int anchor)
{
    if (char_range(a, start, n)) draw_text(g, (const uint16_t *)a->data + start, n, x, y, anchor, false);
}

void JbniV_javax_microedition_lcdui_Graphics_drawChar(JbedGraphics *g, uint16_t ch, int x, int y, int anchor)
{
    draw_text(g, &ch, 1, x, y, anchor, false);
}

void JbniV_javax_microedition_lcdui_Graphics_drawString(JbedGraphics *g, const JbString *s, int x, int y, int anchor)
{
    if (!s) { Jbni_intern_raiseCommonException(JBED_EXCEPTION_NULL_POINTER); return; }
    draw_text(g, jb_string_chars(s), s->length, x, y, anchor, true);
}

void JbniV_javax_microedition_lcdui_Graphics_drawSubstring(JbedGraphics *g, const JbString *s, int start, int n,
                                                           int x, int y, int anchor)
{
    if (string_range(s, start, n)) draw_text(g, jb_string_chars(s) + start, n, x, y, anchor, true);
}

void JbniV_javax_microedition_lcdui_Graphics_drawImage(JbedGraphics *g, const JbedImage *image,
                                                       int x, int y, int anchor)
{
    JbedBitmap *bitmap = getImageData(image);
    if (!image) { Jbni_intern_raiseCommonException(JBED_EXCEPTION_NULL_POINTER); return; }
    if (!valid_anchor((unsigned)anchor, LCDUI_BASELINE)) { Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT); return; }
    ++Jbed_noAllocation;
    select_bitmap(g);
    LCDUIdrawImage(g, tx(g, x), ty(g, y), anchor, bitmap, LCDUIgetImageAlphaValues(bitmap, image));
    --Jbed_noAllocation;
}

void JbniV_javax_microedition_lcdui_Graphics_drawRegion(JbedGraphics *g, const JbedImage *src, int sx, int sy,
                                                        int w, int h, unsigned transform, int x, int y, int anchor)
{
    if (!src) { Jbni_intern_raiseCommonException(JBED_EXCEPTION_NULL_POINTER); return; }
    JbedBitmap *source = getImageData(src);
    if (source == getImageData((JbedImage *)(uintptr_t)g->target) || h < 0 || w < 0 || sx < 0 || sy < 0 ||
        transform > TRANSFORM_MASK || !valid_anchor((unsigned)anchor, LCDUI_BASELINE) ||
        add(sx, w) > (int32_t)src->width || add(sy, h) > (int32_t)src->height) {
        Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT);
        return;
    }
    select_bitmap(g);
    const uint8_t *alpha = LCDUIgetImageAlphaValues(source, src);
    LCDUIdrawRegion(g, source, tx(g, x), ty(g, y), anchor, sx, sy, w, h, transform, 1, 0, alpha, NULL);
}

void JbniV_javax_microedition_lcdui_Graphics_drawLine(JbedGraphics *g, int x1, int y1, int x2, int y2)
{
    ++Jbed_noAllocation;
    select_bitmap(g);
    LCDUIdrawLine(g, tx(g, x1), ty(g, y1), tx(g, x2), ty(g, y2));
    --Jbed_noAllocation;
}

void JbniV_javax_microedition_lcdui_Graphics_fillTriangle(JbedGraphics *g, int x1, int y1, int x2, int y2,
                                                          int x3, int y3)
{
    uint32_t stroke = g->stroke;
    select_bitmap(g);
    g->stroke = 0;
    LCDUIfillTriangle(g, tx(g, x1), ty(g, y1), tx(g, x2), ty(g, y2), tx(g, x3), ty(g, y3));
    g->stroke = stroke;
}

void JbniV_javax_microedition_lcdui_Graphics_drawRect(JbedGraphics *g, int x, int y, int w, int h)
{
    ++Jbed_noAllocation;
    select_bitmap(g);
    LCDUIdrawRect(g, tx(g, x), ty(g, y), w, h);
    --Jbed_noAllocation;
}

void JbniV_javax_microedition_lcdui_Graphics_fillRect(JbedGraphics *g, int x, int y, int w, int h)
{
    ++Jbed_noAllocation;
    uint32_t stroke = g->stroke;
    select_bitmap(g);
    g->stroke = 0;
    LCDUIfillRect(g, tx(g, x), ty(g, y), w, h);
    g->stroke = stroke;
    --Jbed_noAllocation;
}

static void normalize_arc(int *start, int *sweep)
{
    if (*sweep < 0) {
        *start = add(*start, *sweep);
        *sweep = (int32_t)(0u - (uint32_t)*sweep);
    }
    *start = add(*start, 360) % 360;
}

void JbniV_javax_microedition_lcdui_Graphics_drawArc(JbedGraphics *g, int x, int y, int w, int h,
                                                     int start, int sweep)
{
    ++Jbed_noAllocation;
    select_bitmap(g);
    normalize_arc(&start, &sweep);
    LCDUIdrawArc(g, tx(g, x), ty(g, y), w, h, start, sweep);
    --Jbed_noAllocation;
}

void JbniV_javax_microedition_lcdui_Graphics_fillArc(JbedGraphics *g, int x, int y, int w, int h,
                                                     int start, int sweep)
{
    ++Jbed_noAllocation;
    uint32_t stroke = g->stroke;
    select_bitmap(g);
    normalize_arc(&start, &sweep);
    g->stroke = 0;
    LCDUIfillArc(g, tx(g, x), ty(g, y), w, h, start, sweep);
    g->stroke = stroke;
    --Jbed_noAllocation;
}

void JbniV_javax_microedition_lcdui_Graphics_drawRoundRect(JbedGraphics *g, int x, int y, int w, int h,
                                                           int aw, int ah)
{
    ++Jbed_noAllocation;
    select_bitmap(g);
    if (h <= 1 || w <= 1) LCDUIdrawRect(g, tx(g, x), ty(g, y), w, h);
    else LCDUIdrawRoundRect(g, tx(g, x), ty(g, y), w, h, aw, ah);
    --Jbed_noAllocation;
}

void JbniV_javax_microedition_lcdui_Graphics_fillRoundRect(JbedGraphics *g, int x, int y, int w, int h,
                                                           int aw, int ah)
{
    ++Jbed_noAllocation;
    uint32_t stroke = g->stroke;
    select_bitmap(g);
    g->stroke = 0;
    if (h <= 2 || w <= 2) LCDUIfillRect(g, tx(g, x), ty(g, y), w, h);
    else LCDUIfillRoundRect(g, tx(g, x), ty(g, y), w, h, aw, ah);
    g->stroke = stroke;
    --Jbed_noAllocation;
}

JbString *JbniV_com_jbed_midp_MIDPToolkit_getKeyName(void *toolkit, int key)
{
    (void)toolkit;
    const char *name = LCDUIgetKeyName(key);
    if (!name) { Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT); return NULL; }
    return Jbni_intern_newString(name);
}

int JbniV_com_jbed_midp_MIDPToolkit_getGameAction(void *toolkit, int key)
{
    (void)toolkit;
    int action = LCDUIgetGameAction(key);
    if (action == -1) Jbni_intern_raiseCommonException(JBED_EXCEPTION_ILLEGAL_ARGUMENT);
    return action;
}

int JbniV_com_jbed_midp_MIDPToolkit_getKeyCode(void *toolkit, int action)
{
    (void)toolkit;
    return LCDUIgetKeyCode(action);
}

void JbniS_javax_microedition_lcdui_Display_nativeAttach(int display) { (void)display; }
void JbniS_javax_microedition_lcdui_Display_nativeDetach(int display) { (void)display; }
