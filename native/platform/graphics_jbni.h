#ifndef JBED_PLATFORM_GRAPHICS_JBNI_H
#define JBED_PLATFORM_GRAPHICS_JBNI_H

#include "graphics.h"

typedef struct {
    uint32_t header[3];
    int face, style, size, baseline, height;
} JbedFont;

typedef struct {
    uint32_t header[3];
    int width, height, fullscreen_width, fullscreen_height, alpha_levels, erase_color, depth;
    uint8_t color, pointer, motion, repeat, double_buffered;
} JbedDeviceCaps;

void JbniV_com_sun_midp_lcdui_DeviceCaps_init(JbedDeviceCaps *);
void JbniV_com_sun_midp_lcdui_DeviceCaps_switchScreenBuffer(JbedDeviceCaps *, int orientation);
void JbniV_com_jbed_midp_lcdui_lookandfeel_peer_PeerLookAndFeel_nRefresh(void *, int, int, int, int);
void JbniV_javax_microedition_lcdui_Display_00024DisplayAccessor_bufferRefresh(void *);
void JbniV_javax_microedition_lcdui_Font_init(JbedFont *, int face, int style, int size);
unsigned JbniV_javax_microedition_lcdui_Font_charWidth(JbedFont *, uint16_t);
unsigned JbniV_javax_microedition_lcdui_Font_charsWidth(JbedFont *, const JbArray *, int, int);
unsigned JbniV_javax_microedition_lcdui_Font_stringWidth(JbedFont *, const JbString *);
unsigned JbniV_javax_microedition_lcdui_Font_substringWidth(JbedFont *, const JbString *, int, int);
uint32_t JbniV_javax_microedition_lcdui_Graphics_getDisplayColor(JbedGraphics *, uint32_t);
uint32_t JbniS_javax_microedition_lcdui_Graphics_getPixel(uint32_t, unsigned, int);
void JbniV_javax_microedition_lcdui_Graphics_copyArea(JbedGraphics *, int, int, int, int, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_drawRGB(JbedGraphics *, const JbArray *, int, int, int, int, int, int, uint8_t);
void JbniV_javax_microedition_lcdui_Graphics_drawChars(JbedGraphics *, const JbArray *, int, int, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_drawChar(JbedGraphics *, uint16_t, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_drawString(JbedGraphics *, const JbString *, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_drawSubstring(JbedGraphics *, const JbString *, int, int, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_drawImage(JbedGraphics *, const JbedImage *, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_drawRegion(JbedGraphics *, const JbedImage *, int, int, int, int,
                                                       unsigned, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_drawLine(JbedGraphics *, int, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_fillTriangle(JbedGraphics *, int, int, int, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_drawRect(JbedGraphics *, int, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_fillRect(JbedGraphics *, int, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_drawArc(JbedGraphics *, int, int, int, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_fillArc(JbedGraphics *, int, int, int, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_drawRoundRect(JbedGraphics *, int, int, int, int, int, int);
void JbniV_javax_microedition_lcdui_Graphics_fillRoundRect(JbedGraphics *, int, int, int, int, int, int);
JbString *JbniV_com_jbed_midp_MIDPToolkit_getKeyName(void *, int key);
int JbniV_com_jbed_midp_MIDPToolkit_getGameAction(void *, int key);
int JbniV_com_jbed_midp_MIDPToolkit_getKeyCode(void *, int action);
void JbniS_javax_microedition_lcdui_Display_nativeAttach(int display);
void JbniS_javax_microedition_lcdui_Display_nativeDetach(int display);
#endif
