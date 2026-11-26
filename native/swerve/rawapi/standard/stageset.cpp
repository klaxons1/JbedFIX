#include "cssobjectfactory.hpp"
#include "image_class.hpp"
#include "kni_targets.h"
#include "objects.h"

static void dimensions(int format, int width, int height)
{
    if ((unsigned)format - SWV_IMAGE_ALPHA > SWV_IMAGE_RGBA - SWV_IMAGE_ALPHA || width <= 0 ||
        height <= 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
}

static void publish(CssStageset *base, void **out)
{
    CssCleanupStackManager::Pop(base);
    *out = swv_retain_handle(static_cast<CssRefCount *>(base));
    CssTrapHandler::UnTrap();
}

int stageset_create(int w, int h, int size, const uint8_t *data, void **out)
{
    SWV_BEGIN_API(frame);
    dimensions(SWV_IMAGE_RGB, w, h);
    if (!data)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *s = static_cast<CssStageset *>(CssObjectFactory::CreateObject(StagesetObject));
    CssCleanupStackManager::Push(s);
    s->Construct(w, h, size, data);
    publish(s, out);
    return 1;
}

int stageset_createMutable(int w, int h, void **out)
{
    SWV_BEGIN_API(frame);
    dimensions(SWV_IMAGE_RGB, w, h);
    auto *s = static_cast<CssStageset *>(CssObjectFactory::CreateObject(StagesetObject));
    CssCleanupStackManager::Push(s);
    s->Construct(w, h);
    publish(s, out);
    return 1;
}

void stageset_getScale(void *h, float *out)
{
    auto *s = static_cast<CssStageset *>(static_cast<CssRefCount *>(h));
    *out = s->scale;
}

void stageset_getBias(void *h, float *out)
{
    auto *s = static_cast<CssStageset *>(static_cast<CssRefCount *>(h));
    *out = s->bias;
}

int stageset_setScale(void *h, float scale)
{
    SWV_BEGIN_API(frame);
    auto *s = static_cast<CssStageset *>(static_cast<CssRefCount *>(h));
    scale = g_ValidateFloat(scale);
    if (scale < 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    s->scale = scale;
    CssTrapHandler::UnTrap();
    return 1;
}

int stageset_setBias(void *h, float bias)
{
    SWV_BEGIN_API(frame);
    auto *s = static_cast<CssStageset *>(static_cast<CssRefCount *>(h));
    s->bias = g_ValidateFloat(bias);
    CssTrapHandler::UnTrap();
    return 1;
}
