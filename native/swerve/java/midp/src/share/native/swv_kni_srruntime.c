#include "swv_kni_srruntime.h"
#include "platform/graphics.h"

static JbedBitmap *graphics_bitmap(JbRef *root)
{
    const JbedGraphics *g = (const JbedGraphics *)(uintptr_t)*root;
    return g->target ? getImageData((const JbedImage *)(uintptr_t)g->target) : getActiveScreenBitmap();
}
void swvKNIGraphicsUpdateBackBufferData(JbRef *root, int load, void **pixels)
{
    (void)load;
    JbedBitmap *bitmap = graphics_bitmap(root);
    *pixels = (uint8_t *)bitmap + bitmap->pixels_offset;
}
void swvKNIGraphicsGetBackBufferData(JbRef *root, SwvBackBuffer *out)
{
    JbedBitmap *bitmap = graphics_bitmap(root);
    *out = (SwvBackBuffer){ bitmap->width, bitmap->height, bitmap->stride_bytes,
                           (uint8_t *)bitmap + bitmap->pixels_offset };
}
void swvKNIGraphicsSetBackBufferData(JbRef *root)
{
    const JbedGraphics *g = (const JbedGraphics *)(uintptr_t)*root;
    if (!g->target) {
        JbedBitmap *bitmap = getActiveScreenBitmap();
        RB_regionIsDirty(0, 0, (int)bitmap->width - 1, (int)bitmap->height - 1);
    }
}
