#ifndef JBED_PLATFORM_GRAPHICS_H
#define JBED_PLATFORM_GRAPHICS_H

#include "image.h"

enum {
    LCDUI_HCENTER = 1, LCDUI_VCENTER = 2, LCDUI_LEFT = 4, LCDUI_RIGHT = 8,
    LCDUI_TOP = 16, LCDUI_BOTTOM = 32, LCDUI_BASELINE = 64,
    LCDUI_ANCHOR_MASK = LCDUI_HCENTER | LCDUI_VCENTER | LCDUI_LEFT | LCDUI_RIGHT |
                        LCDUI_TOP | LCDUI_BOTTOM | LCDUI_BASELINE
};
enum {
    TRANSFORM_FLIP_Y = 1, TRANSFORM_FLIP_X = 2, TRANSFORM_SWAP_AXES = 4,
    TRANSFORM_MASK = TRANSFORM_FLIP_Y | TRANSFORM_FLIP_X | TRANSFORM_SWAP_AXES
};

extern JbedBitmap *currentScreenBitmap, *screenBitmap;
JbedBitmap *getActiveScreenBitmap(void);
void RB_regionIsDirty(int x1, int y1, int x2, int y2);
void LCDUIrefresh(int x1, int y1, int x2, int y2);
void GUI_checkPostponedRefresh(void);
int LCDUIgetKeyCode(int action);
int LCDUIgetGameAction(int key);
const char *LCDUIgetKeyName(int key);

void LCDUIdrawLine(JbedGraphics *, int x1, int y1, int x2, int y2);
void LCDUIfillRect(JbedGraphics *, int x, int y, int w, int h);
void LCDUIdrawRect(JbedGraphics *, int x, int y, int w, int h);
void LCDUIfillTriangle(JbedGraphics *, int x1, int y1, int x2, int y2, int x3, int y3);
void LCDUIdrawRoundRect(JbedGraphics *, int x, int y, int w, int h, int aw, int ah);
void LCDUIfillRoundRect(JbedGraphics *, int x, int y, int w, int h, int aw, int ah);
void LCDUIdrawArc(JbedGraphics *, int x, int y, int w, int h, int start, int sweep);
void LCDUIfillArc(JbedGraphics *, int x, int y, int w, int h, int start, int sweep);

void LCDUIdrawRGB(JbedGraphics *, const JbArray *, int offset, int stride, int x, int y, int w,
                  int h, int process_alpha);
void LCDUIcopyArea(JbedGraphics *, int sx, int sy, int w, int h, int x, int y, int anchor);
void LCDUIdrawRegion(JbedGraphics *, const JbedBitmap *, int x, int y, int anchor, int sx, int sy,
                     int w, int h, unsigned transform, int process_alpha, int copy_alpha,
                     const uint8_t *src_alpha, uint8_t *dst_alpha);
void LCDUIdrawImage(JbedGraphics *, int x, int y, int anchor, const JbedBitmap *,
                    const uint8_t *alpha);

#endif
