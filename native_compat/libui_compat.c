/* Minimal Android 2.x libui ABI required by libjbedvm.so. */
#include <stdint.h>

/* Jbed creates Regions on its own stack and only uses set() before passing
 * them to Surface::lock. No compositor-side region interpretation is required
 * by the software surface shim. */
void region_ctor(void *self) asm("_ZN7android6RegionC1Ev");
void region_ctor(void *self) { (void)self; }
void region_dtor(void *self) asm("_ZN7android6RegionD1Ev");
void region_dtor(void *self) { (void)self; }
int region_set(void *self, const void *rect) asm("_ZN7android6Region3setERKNS_4RectE");
int region_set(void *self, const void *rect) { (void)self; (void)rect; return 0; }

/* Android 2.x PixelFormat values used by this VM. */
int bytes_per_pixel(int format) asm("_ZN7android13bytesPerPixelEi");
int bytes_per_pixel(int format) {
    switch (format) {
        case 1:  /* RGBA_8888 */
        case 2:  /* RGBX_8888 */
        case 3:  /* RGB_888 */
            return 4;
        case 4:  /* RGB_565 */
        case 5:  /* RGBA_5551 */
        case 6:  /* RGBA_4444 */
            return 2;
        default:
            return 2;
    }
}
