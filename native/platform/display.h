#ifndef JBED_PLATFORM_DISPLAY_H
#define JBED_PLATFORM_DISPLAY_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct JbedTargetFont JbedTargetFont;

enum {
    MIDP_FONT_STYLE_BOLD = 1, MIDP_FONT_STYLE_ITALIC = 2, MIDP_FONT_STYLE_UNDERLINED = 4,
    MIDP_FONT_SIZE_SMALL = 8, MIDP_FONT_SIZE_LARGE = 16,
    MIDP_FONT_FACE_MONOSPACE = 32, MIDP_FONT_FACE_PROPORTIONAL = 64
};
enum {
    LCDUI_CAP_COLOR = 1, LCDUI_CAP_POINTER = 2, LCDUI_CAP_POINTER_MOTION = 4,
    LCDUI_CAP_KEY_REPEAT = 8, LCDUI_CAP_DOUBLE_BUFFER = 16
};
enum { JBED_RAW_SCREEN_SIZE_CHANGED = 105 };

struct JbedGraphics;
typedef struct {
    int width, height;
    uint32_t argb;
    uint16_t stride;
    uint16_t *pixels;
    const int *clip;
} JbedFontTarget;

JbedTargetFont *JbedGFX_createTargFont(int face, int style, int pixels);
void JbedGFX_releaseTargFont(JbedTargetFont *paint);
int JbedGFX_getFontInfo(const JbedTargetFont *paint, int *ascent, int *descent, int *leading);
unsigned JbedGFX_charsWidth(const JbedTargetFont *paint, const uint16_t *, int count);
void JbedGFX_drawChars(const JbedFontTarget *, JbedTargetFont *paint, const uint16_t *, int count,
                       int x, int baseline);

unsigned LCDUIcharsWidth(int face, int style, int size, const uint16_t *, int n, unsigned *out);
void LCDUIgetFontInfo(int face, int style, int size, int *ascent, int *descent, int *leading);
void LCDUIdrawChars(struct JbedGraphics *, int face, int style, int size, int x, int y,
                    int anchor, const uint16_t *, int n);
int LCDUIgetDisplayParams(int *w, int *h, int *fullw, int *fullh, int *colors, int *depth, int *caps);
void LCDUIswitchScreenBuffer(int orientation);
void refreshPaintWindow(uint16_t left, uint16_t top, uint16_t right, uint16_t bottom);
void InitializeWindowConfig(const int config[6]);
void InitializeWindowSystem(void);
void FinalizeWindowSystem(void);
#define JBED_FRAMEBUFFER_PATH "/data/data/com.esmertec.android.jbed/tmp/jbed_gfx_shm"

#ifdef __cplusplus
}
#endif
#endif
