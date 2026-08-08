/*
 * First-stage replacement for Android 2.x libsurfaceflinger_client.so.
 *
 * The legacy Jbed VM imports only Surface::lock/unlockAndPost from this DSO.
 * The original SurfaceInfo layout is visible in docs/libsurfaceflinger_client.so.c:
 * w, h, stride, usage, format, bits.  We provide a stable software framebuffer
 * so the VM can initialise and copy pixels without using Android 11 private
 * SurfaceFlinger APIs. Presenting that buffer through a modern Surface is the
 * next bridge stage; unlockAndPost is intentionally a successful no-op here.
 */
#include <stdint.h>

#define WIDTH 480
#define HEIGHT 800
#define RGB_565 4

typedef struct {
    int32_t w;
    int32_t h;
    int32_t stride;
    int32_t usage;
    int32_t format;
    void *bits;
} LegacySurfaceInfo;

static uint16_t framebuffer[WIDTH * HEIGHT];

int surface_lock_region(void *surface, LegacySurfaceInfo *info, void *region, int dirty)
    asm("_ZN7android7Surface4lockEPNS0_11SurfaceInfoEPNS_6RegionEb");
int surface_lock_region(void *surface, LegacySurfaceInfo *info, void *region, int dirty) {
    (void) surface; (void) region; (void) dirty;
    if (!info) return -1;
    info->w = WIDTH;
    info->h = HEIGHT;
    info->stride = WIDTH;
    info->usage = 0;
    info->format = RGB_565;
    info->bits = framebuffer;
    return 0;
}

int surface_lock(void *surface, LegacySurfaceInfo *info, int dirty)
    asm("_ZN7android7Surface4lockEPNS0_11SurfaceInfoEb");
int surface_lock(void *surface, LegacySurfaceInfo *info, int dirty) {
    return surface_lock_region(surface, info, 0, dirty);
}

int surface_unlock_and_post(void *surface)
    asm("_ZN7android7Surface13unlockAndPostEv");
int surface_unlock_and_post(void *surface) {
    (void) surface;
    return 0;
}
