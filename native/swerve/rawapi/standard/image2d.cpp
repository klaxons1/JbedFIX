#include "cssobjectfactory.hpp"
#include "image_class.hpp"
#include "kni_targets.h"
#include "objects.h"

static CssImage2D *image(void *handle)
{
    return static_cast<CssImage2D *>(static_cast<CssRefCount *>(handle));
}

static void dimensions(int format, int width, int height)
{
    if ((unsigned)format - SWV_IMAGE_ALPHA > SWV_IMAGE_RGBA - SWV_IMAGE_ALPHA || width <= 0 ||
        height <= 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
}

static void publish(CssImage2D *base, void **out)
{
    CssCleanupStackManager::Pop(base);
    *out = swv_retain_handle(static_cast<CssRefCount *>(base));
    CssTrapHandler::UnTrap();
}

int image2d_create(int format, int w, int h, int size, const uint8_t *data, void **out)
{
    SWV_BEGIN_API(frame);
    dimensions(format, w, h);
    if (!data)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *im = static_cast<CssImage2D *>(CssObjectFactory::CreateObject(Image2DObject));
    CssCleanupStackManager::Push(im);
    im->Construct(static_cast<CssImage2D::EssFormat>(format), w, h, size, data);
    publish(im, out);
    return 1;
}

int image2d_createPalettized(int format, int w, int h, int size, const uint8_t *data, int palette_size,
                             const uint8_t *palette, void **out)
{
    SWV_BEGIN_API(frame);
    dimensions(format, w, h);
    if (!data || !palette)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *im = static_cast<CssImage2D *>(CssObjectFactory::CreateObject(Image2DObject));
    CssCleanupStackManager::Push(im);
    im->Construct(static_cast<CssImage2D::EssFormat>(format), w, h, size, data, palette_size, palette);
    publish(im, out);
    return 1;
}

int image2d_createUninitialized(int format, int w, int h, int immutable, void **out)
{
    SWV_BEGIN_API(frame);
    dimensions(format, w, h);
    auto *im = static_cast<CssImage2D *>(CssObjectFactory::CreateObject(Image2DObject));
    CssCleanupStackManager::Push(im);
    im->Construct(static_cast<CssImage2D::EssFormat>(format), w, h, immutable != 0);
    publish(im, out);
    return 1;
}

int image2d_createMutable(int format, int w, int h, void **out)
{
    return image2d_createUninitialized(format, w, h, 0, out);
}

void image2d_getFormat(void *h, int *v)
{
    *v = image(h)->GetFormat();
}

void image2d_isMutable(void *h, int *v)
{
    *v = image(h)->GetbMutable();
}

void image2d_getWidth(void *h, int *v)
{
    *v = image(h)->GetWidth();
}

void image2d_getHeight(void *h, int *v)
{
    *v = image(h)->GetHeight();
}

void image2d_getPixels(void *h, uint16_t **v)
{
    *v = static_cast<uint16_t *>(image(h)->GetpPixels());
}

void image2d_getAlpha(void *h, uint8_t **v)
{
    *v = image(h)->GetpAlpha();
}

void image2d_getPalette(void *h, uint16_t **v)
{
    *v = image(h)->GetpPalette();
}

int image2d_set(void *h, int x, int y, int w, int height, int size, const uint8_t *data)
{
    SWV_BEGIN_API(frame);
    if (x < 0 || y < 0 || w <= 0 || height <= 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (!data)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    image(h)->Set(x, y, w, height, size, data);
    CssTrapHandler::UnTrap();
    return 1;
}
