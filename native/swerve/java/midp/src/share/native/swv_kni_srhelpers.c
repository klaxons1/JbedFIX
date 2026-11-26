#include "kni_fields.h"
#include "swv_kni_srruntime.h"
#include "image2d.h"
#include <limits.h>

static int cached_graphics_fields;
static FieldId bound_target, is_graphics, preload;

extern void graphics3d_updateBackBufferData(void *handle, void *pixels);
extern int graphics3d_setCroppedBackBufferData(void *handle, int width, int height, int stride_bytes,
                                              void *pixels, int x, int y, int crop_w, int crop_h);

void SWV_Image2D_setRGB(void)
{
    JbRef roots[2] = {0};
    void **saved = kni_push_roots(roots, 2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    void *bytes = NULL;
    unsigned count = 0;
    if (SWV_GetArrayBytes(&roots[1], 4, UINT_MAX, &bytes, &count)) {
        unsigned x = Jbed_ParamPtr[2], y = Jbed_ParamPtr[3];
        unsigned w = Jbed_ParamPtr[4], h = Jbed_ParamPtr[5];
        int from_luminance = (uint8_t)Jbed_ParamPtr[6] != 0;
        int stride, format, height;
        uint16_t *pixels;
        uint8_t *alpha;
        image2d_getWidth(self, &stride);
        image2d_getFormat(self, &format);
        image2d_getPixels(self, &pixels);
        image2d_getAlpha(self, &alpha);
        image2d_getHeight(self, &height);
        if (bytes && w && w <= count && h <= count / w &&
            x <= (unsigned)stride && w <= (unsigned)stride - x &&
            y <= (unsigned)height && h <= (unsigned)height - y &&
            format >= SWV_IMAGE_ALPHA && format <= SWV_IMAGE_RGBA) {
            const uint32_t *argb = bytes;
            for (unsigned row = 0; row < h; ++row) {
                size_t index = (size_t)(row + y) * stride + x;
                for (unsigned col = 0; col < w; ++col, ++index) {
                    uint32_t c = *argb++;
                    unsigned r = (c >> 16) & 255, g = (c >> 8) & 255, b = c & 255;
                    unsigned gray = (19595 * r + 38470 * g + 7471 * b) >> 16;
                    if (format == SWV_IMAGE_ALPHA || format == SWV_IMAGE_LUMINANCE_ALPHA || format == SWV_IMAGE_RGBA)
                        alpha[index] = format == SWV_IMAGE_ALPHA && from_luminance ? gray : c >> 24;
                    if (format == SWV_IMAGE_ALPHA) continue;
                    if (format == SWV_IMAGE_LUMINANCE || format == SWV_IMAGE_LUMINANCE_ALPHA)
                        r = g = b = gray;
                    pixels[index] = (uint16_t)((r >> 3) << 11 | (g >> 2) << 5 | b >> 3);
                }
            }
        }
    }
    SWV_FreeArrayBytes(&roots[1], bytes);
    Jbed_nativeCallStateAdr = saved;
}

static JbRef get_class(JbRef root)
{
    const JbRef *object = (const JbRef *)(uintptr_t)JbedKNI_VerifyObject(root, 'O');
    const JbRef *header = (const JbRef *)(uintptr_t)*object;
    return JbedKNI_VerifyObject(*header, 'C');
}
int swvGetImage2DEncoding(JbRef *root)
{
    JbRef klass = 0;
    void **saved = kni_push_roots(&klass, 1);
    klass = get_class(*root);
    FieldId color_space = find_field(klass, "jpegColorSpace", "I", 0);
    FieldId components = find_field(klass, "jpegNumComponents", "I", 0);
    int color = *(int *)JbedKNI_VerifyField(*root, color_space, KNI_FIELD_INT, 0);
    int channels = *(int *)JbedKNI_VerifyField(*root, components, KNI_FIELD_INT, 0);
    Jbed_nativeCallStateAdr = saved;
    return color == 1 && channels == 1 ? SWV_IMAGE_LUMINANCE : SWV_IMAGE_RGBA;
}
int SWV_GetImage2DEncoding(void)
{
    JbRef root = 0;
    void **saved = kni_push_roots(&root, 1);
    root = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    int format = swvGetImage2DEncoding(&root);
    Jbed_nativeCallStateAdr = saved;
    return format;
}

void SWV_BindTargetCritical(JbRef *root, void *handle)
{
    if (!cached_graphics_fields) {
        JbRef klass = 0;
        void **saved = kni_push_roots(&klass, 1);
        klass = get_class(*root);
        bound_target = find_field(klass, "boundTarget", "Ljava/lang/Object;", 0);
        is_graphics = find_field(klass, "isGraphics", "Z", 0);
        preload = find_field(klass, "preload", "Z", 0);
        Jbed_nativeCallStateAdr = saved;
        cached_graphics_fields = 1;
    }
    if (*(uint8_t *)JbedKNI_VerifyField(*root, is_graphics, KNI_FIELD_BOOLEAN, 0)) {
        JbRef target = 0;
        void **saved = kni_push_roots(&target, 1);
        target = *(JbRef *)JbedKNI_VerifyField(*root, bound_target, KNI_FIELD_REFERENCE, 0);
        int load = *(uint8_t *)JbedKNI_VerifyField(*root, preload, KNI_FIELD_BOOLEAN, 0);
        void *pixels;
        swvKNIGraphicsUpdateBackBufferData(&target, load, &pixels);
        graphics3d_updateBackBufferData(handle, pixels);
        Jbed_nativeCallStateAdr = saved;
    }
}
void SWV_BindTargetGraphics(void)
{
    JbRef roots[2] = {0};
    void **saved = kni_push_roots(roots, 2);
    void *handle = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    SwvBackBuffer buffer;
    swvKNIGraphicsGetBackBufferData(&roots[1], &buffer);
    if (!graphics3d_setCroppedBackBufferData(handle, buffer.width, buffer.height, buffer.stride,
                                             buffer.pixels, Jbed_ParamPtr[2], Jbed_ParamPtr[3],
                                             Jbed_ParamPtr[4], Jbed_ParamPtr[5]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved;
}
void SWV_ReleaseTargetGraphics(void)
{
    JbRef roots[2] = {0};
    void **saved = kni_push_roots(roots, 2);
    void *handle = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    SWV_BindTargetCritical(&roots[0], handle);
    swvKNIGraphicsSetBackBufferData(&roots[1]);
    Jbed_nativeCallStateAdr = saved;
}
