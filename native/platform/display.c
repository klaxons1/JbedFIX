#include "display.h"
#include "graphics.h"

#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

extern void jbedPostRawEvent(int);
extern void android_engine_sizeChangingDone(void);
extern void android_soft_button_changed(const uint16_t *, int, const uint16_t *, int);
extern void android_lcdui_repaint(int, int, int, int, int, int);
extern int android_lcdui_getFontSize(void);

unsigned LCDUI_depth = 8;
uint32_t backgroundColor = 0xffffff;
int doubleBuffer = 1;
float xScale = 1, yScale = 1;
int fullScreenDisplayWidth, fullScreenDisplayHeight, midletWidth, midletHeight;
static int display_width, display_height;
static void *back_pixels, *shared_pixels;
static uint32_t buffer_bytes;
static JbedBitmap display_bitmap;

void JbniS_com_jbed_midp_lcdui_theme_ThemeRegistry_notifyNativeStartup(void) {}
void JbniS_com_jbed_midp_lcdui_theme_ThemeRegistry_notifyNativeCurrent(void) {}
void JbniS_com_jbed_midp_lcdui_theme_ThemeRegistry_notifyNativeAdded(void) {}
void JbniS_com_jbed_midp_lcdui_theme_ThemeRegistry_notifyNativeRemove(void) {}
void JbniS_com_jbed_midp_lcdui_theme_ThemeRegistry_notifyNativeUpdated(void) {}
int JbniS_com_jbed_midp_lcdui_theme_ThemeRegistry_queryNativeCurrent(void) { return 0; }

int LCDUIgetDisplayParams(int *w, int *h, int *fw, int *fh, int *colors, int *depth, int *caps)
{
    *w = display_width;
    *h = display_height;
    *fw = fullScreenDisplayWidth;
    *fh = fullScreenDisplayHeight;
    *colors = 0xffffff;
    *depth = (int)LCDUI_depth;
    *caps = LCDUI_CAP_POINTER | LCDUI_CAP_POINTER_MOTION | LCDUI_CAP_KEY_REPEAT |
            (LCDUI_depth > 7 ? LCDUI_CAP_COLOR : 0) |
            (doubleBuffer ? LCDUI_CAP_DOUBLE_BUFFER : 0);
    return doubleBuffer != 0;
}

void JbniV_com_jbed_midp_lcdui_RotationManager_init(uint32_t *self) { self[3] = 0; }

int JbniS_com_jbed_midp_lcdui_RotationManager_requestScreenRotation(void)
{
    jbedPostRawEvent(JBED_RAW_SCREEN_SIZE_CHANGED);
    return 1;
}

void JbniS_com_jbed_midp_lcdui_toolkit_ewt_NativeSoftBarComposite_nUpdateSoftButton(
    const JbString *left, const JbString *right)
{
    android_soft_button_changed(left ? jb_string_chars(left) : NULL, left ? left->length : 0,
                                right ? jb_string_chars(right) : NULL, right ? right->length : 0);
}

void LCDUIswitchScreenBuffer(int orientation) { (void)orientation; android_engine_sizeChangingDone(); }

void InitializeWindowConfig(const int config[6])
{
    LCDUI_depth = 16;
    display_width = config[0];
    display_height = config[1];
    fullScreenDisplayWidth = config[2];
    fullScreenDisplayHeight = config[3];
    uint32_t stride = (uint32_t)config[4];
    if (!back_pixels) {
        buffer_bytes = (stride / (uint32_t)display_width) * (uint32_t)config[5] * (uint32_t)config[5];
        int fd = open(JBED_FRAMEBUFFER_PATH, O_CREAT | O_TRUNC | O_RDWR, 0777);
        lseek(fd, (int32_t)(buffer_bytes - 1), SEEK_SET);
        write(fd, "", 1);
        shared_pixels = mmap(NULL, buffer_bytes, PROT_WRITE, MAP_SHARED, fd, 0);
        close(fd);
        back_pixels = malloc(buffer_bytes);
    }
    display_bitmap.width = fullScreenDisplayWidth;
    display_bitmap.height = fullScreenDisplayHeight;
    screenBitmap = &display_bitmap;
    GUI_createBitmap(screenBitmap);
    screenBitmap->stride_bytes = stride;
    screenBitmap->pixels_offset = (int32_t)((uintptr_t)back_pixels - (uintptr_t)screenBitmap);
    currentScreenBitmap = screenBitmap;
    jbedPostRawEvent(JBED_RAW_SCREEN_SIZE_CHANGED);
}

void *cleanScreenBuffer(void) { return memset(shared_pixels, 0, buffer_bytes); }

void refreshPaintWindow(uint16_t x, uint16_t y, uint16_t w, uint16_t h)
{
    memcpy(shared_pixels, back_pixels, buffer_bytes);
    android_lcdui_repaint(x, y, w, h, midletWidth, midletHeight);
}

typedef struct {
    JbedTargetFont *paint;
    int id, ascent, descent, leading, style, size, face;
} Font;
enum { FONT_CACHE_SIZE = 8 };
static Font *fonts, *current_font;
static int small = 14, medium = 18, large = 22;
static bool have_sizes;

int CPL_font_getFontId(int face, int style, int size) { return face | style | size; }
int CPL_font_getFontCharExtent(void) { return -1; }
int CPL_font_getFontCharBits(void) { return -1; }
int CPL_font_startup(void) { return 0; }
int CPL_font_shutdown(void) { return 0; }

int CPL_font_createFont(Font *font, int face, int style, int size)
{
    if (!have_sizes) {
        unsigned sizes = (unsigned)android_lcdui_getFontSize();
        if (sizes & 255) small = sizes & 255;
        if (sizes & 0xff00) medium = (sizes >> 8) & 255;
        if (sizes & 0xff0000) large = (sizes >> 16) & 255;
        have_sizes = true;
    }
    font->paint = JbedGFX_createTargFont(face, style, size == MIDP_FONT_SIZE_SMALL ? small :
                                          size == MIDP_FONT_SIZE_LARGE ? large : medium);
    JbedGFX_getFontInfo(font->paint, &font->ascent, &font->descent, &font->leading);
    return 0;
}

int CPL_font_releaseFont(Font *font)
{
    JbedGFX_releaseTargFont(font->paint);
    return 0;
}

int LCDUIinitText(void)
{
    fonts = malloc(FONT_CACHE_SIZE * sizeof(*fonts));
    memset(fonts, 0, FONT_CACHE_SIZE * sizeof(*fonts));
    current_font = NULL;
    return CPL_font_startup();
}

void LCDUIfinalizeText(void)
{
    CPL_font_shutdown();
    if (fonts) {
        for (int i = 0; i < FONT_CACHE_SIZE; ++i)
            if (fonts[i].paint) CPL_font_releaseFont(fonts + i);
    }
    free(fonts);
    fonts = current_font = NULL;
}

void InitializeWindowSystem(void) { LCDUIinitText(); }

void FinalizeWindowSystem(void)
{
    free(back_pixels);
    munmap(shared_pixels, buffer_bytes);
    back_pixels = shared_pixels = NULL;
    buffer_bytes = 0;
    LCDUIfinalizeText();
}

static Font *select_font(int face, int style, int size)
{
    if (current_font && current_font->face == face &&
        current_font->size == size && current_font->style == style)
        return current_font;
    int id = CPL_font_getFontId(face, style, size);
    current_font = NULL;
    for (int i = 0; i < FONT_CACHE_SIZE; ++i) {
        if (fonts[i].id == id && fonts[i].paint) { current_font = fonts + i; break; }
    }
    if (!current_font) {
        if (fonts[FONT_CACHE_SIZE - 1].paint) CPL_font_releaseFont(&fonts[FONT_CACHE_SIZE - 1]);
        memmove(fonts + 1, fonts, (FONT_CACHE_SIZE - 1) * sizeof(*fonts));
        current_font = fonts;
        fonts->id = id;
        CPL_font_createFont(fonts, face, style, size);
    }
    current_font->face = face;
    current_font->style = style;
    current_font->size = size;
    return current_font;
}

unsigned CPL_font_getStringWidth(const Font *font, const uint16_t *chars, int n, unsigned *out)
{
    unsigned width = n && chars ? JbedGFX_charsWidth(font->paint, chars, n) : 0;
    if (out) *out = width;
    return width;
}

unsigned LCDUIcharsWidth(int face, int style, int size, const uint16_t *chars, int n, unsigned *out)
{
    Font *font = select_font(face, style, size);
    return CPL_font_getStringWidth(font, chars, n, out);
}

void LCDUIgetFontInfo(int face, int style, int size, int *a, int *d, int *l)
{
    Font *f = select_font(face, style, size);
    *a = f->ascent;
    *d = f->descent;
    *l = f->leading;
}

void CPL_font_drawString(JbedGraphics *g, JbedTargetFont *paint, int id, int ascent, int descent,
                         int leading, int x, int y, int anchor, const uint16_t *s, int n)
{
    (void)id; (void)leading;
    JbedBitmap *b = g->bitmap ? g->bitmap : getActiveScreenBitmap();
    if (!anchor || (anchor & LCDUI_TOP)) y += ascent;
    if (anchor & LCDUI_BOTTOM) y -= descent;
    int width = -1;
    if (anchor & (LCDUI_HCENTER | LCDUI_RIGHT)) {
        width = (int)JbedGFX_charsWidth(paint, s, n);
        x -= (anchor & LCDUI_HCENTER) ? width >> 1 : width;
    }
    int clip[] = {g->clip_x, g->clip_y, g->clip_right, g->clip_bottom};
    JbedFontTarget target = {(int)b->width, (int)b->height, g->argb, (uint16_t)b->stride_bytes,
                             jbed_bitmap_row(b, 0), clip};
    JbedGFX_drawChars(&target, paint, s, n, x, y);
    if (!g->bitmap) {
        if (width == -1) width = (int)JbedGFX_charsWidth(paint, s, n);
        RB_regionIsDirty(x, y - ascent, x + width, y + descent);
    }
}

void LCDUIdrawChars(JbedGraphics *g, int face, int style, int size, int x, int y,
                    int anchor, const uint16_t *s, int n)
{
    Font *f = select_font(face, style, size);
    CPL_font_drawString(g, f->paint, f->id, f->ascent, f->descent, f->leading, x, y, anchor, s, n);
}
