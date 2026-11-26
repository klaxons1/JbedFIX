#include "geometry_class.hpp"
#include "image_class.hpp"
#include "graphics3d_state.h"
#include "kni_targets.h"

int graphics3d_getCapability(int capability, int *out)
{
    SWV_BEGIN_API(f);
    if (capability < 0 || capability > CssGraphics3D::MaxViewportHeightCapability)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    *out = CssGraphics3D::GetCapability(static_cast<CssGraphics3D::EssCapabilities>(capability));
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_create(void **out)
{
    SWV_BEGIN_API(f);
    *out = swv_retain_handle(static_cast<CssRefCount *>(CssGraphics3D::Create()));
    CssTrapHandler::UnTrap();
    return 1;
}

static CssGraphics3D *object(void *h)
{
    return static_cast<CssGraphics3D *>(static_cast<CssRefCount *>(h));
}

void graphics3d_getWidth(void *h, int *o)
{
    *o = object(h)->Width();
}

void graphics3d_getHeight(void *h, int *o)
{
    *o = object(h)->Height();
}

void graphics3d_getPitch(void *h, int *o)
{
    *o = object(h)->Pitch();
}

void graphics3d_getPixels(void *h, void **o)
{
    *o = object(h)->pPixels();
}

void graphics3d_getDepthRangeNear(void *h, float *o)
{
    *o = object(h)->DepthRangeNear();
}

void graphics3d_getDepthRangeFar(void *h, float *o)
{
    *o = object(h)->DepthRangeFar();
}

void graphics3d_isDepthBufferEnabled(void *h, int *o)
{
    *o = object(h)->DepthBufferEnabled();
}

void graphics3d_getLightCount(void *h, int *o)
{
    *o = object(h)->GetLightCount();
}

void graphics3d_getHints(void *h, int *o)
{
    *o = object(h)->GetHints();
}

int graphics3d_setCroppedBackBufferData(void *h, int w, int height, int pitch, void *pixels, int x,
                                        int y, int cw, int ch)
{
    SWV_BEGIN_API(f);
    object(h)->SetBackBufferData(w, height, pitch, static_cast<uint16_t *>(pixels), x, y, cw, ch);
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_setBackBufferData(void *h, int w, int height, int pitch, void *pixels)
{
    SWV_BEGIN_API(f);
    object(h)->SetBackBufferData(w, height, pitch, static_cast<uint16_t *>(pixels));
    CssTrapHandler::UnTrap();
    return 1;
}

void graphics3d_updateBackBufferData(void *h, void *pixels)
{
    object(h)->UpdateBackBufferData(static_cast<uint16_t *>(pixels));
}

int graphics3d_setBackBufferImage2D(void *h, void *ih)
{
    SWV_BEGIN_API(f);
    object(h)->SetBackBufferImage2D(static_cast<CssImage2D *>(static_cast<CssRefCount *>(ih)));
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_setHints(void *h, int depth, int flags)
{
    SWV_BEGIN_API(f);
    object(h)->SetHints(depth, flags);
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_setViewport(void *h, int x, int y, int w, int height)
{
    SWV_BEGIN_API(f);
    object(h)->SetViewport(x, y, w, height);
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_setDepthRange(void *h, float near, float far)
{
    SWV_BEGIN_API(f);
    CssGraphics3D *g = object(h);
    near = g_ValidateFloat(near);
    if (near < 0 || near > 1)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    far = g_ValidateFloat(far);
    if (far < 0 || far > 1)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    g->SetDepthRange(near, far);
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_setCamera(void *h, void *camera, void *transform)
{
    SWV_BEGIN_API(f);
    object(h)->SetCamera(static_cast<CssCamera *>(static_cast<CssRefCount *>(camera)),
                         static_cast<CssTransform *>(static_cast<CssRefCount *>(transform)));
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_getCamera(void *h, void *transform, void **result)
{
    SWV_BEGIN_API(f);
    auto *camera = object(h)->GetCamera(static_cast<CssTransform *>(static_cast<CssRefCount *>(transform)));
    *result = swv_retain_handle(static_cast<CssRefCount *>(camera));
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_resetLights(void *h)
{
    SWV_BEGIN_API(f);
    object(h)->ResetLights();
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_getLight(void *h, int i, void *transform, void **result)
{
    SWV_BEGIN_API(f);
    auto *light = object(h)->GetLight(i, static_cast<CssTransform *>(static_cast<CssRefCount *>(transform)));
    *result = swv_retain_handle(static_cast<CssRefCount *>(light));
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_setLight(void *h, int i, void *light, void *transform)
{
    SWV_BEGIN_API(f);
    object(h)->SetLight(i, static_cast<CssLight *>(static_cast<CssRefCount *>(light)),
                        static_cast<CssTransform *>(static_cast<CssRefCount *>(transform)));
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_addLight(void *h, void *light, void *transform, int *index)
{
    SWV_BEGIN_API(f);
    if (!light)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    *index = object(h)->AddLight(static_cast<CssLight *>(static_cast<CssRefCount *>(light)),
                                static_cast<CssTransform *>(static_cast<CssRefCount *>(transform)));
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_clear(void *h, void *bg)
{
    SWV_BEGIN_API(f);
    object(h)->Clear(static_cast<CssBackground *>(static_cast<CssRefCount *>(bg)));
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_renderPrimitive(void *h, void *vertices, void *indices, void *appearance, void *transform,
                               int scope)
{
    SWV_BEGIN_API(f);
    if (!vertices || !indices || !appearance)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    object(h)->RenderPrimitive(static_cast<CssVertexBuffer *>(static_cast<CssRefCount *>(vertices)),
                               static_cast<CssIndexBuffer *>(static_cast<CssRefCount *>(indices)),
                               static_cast<CssAppearance *>(static_cast<CssRefCount *>(appearance)),
                               static_cast<CssTransform *>(static_cast<CssRefCount *>(transform)), scope);
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_renderNode(void *h, void *node, void *transform)
{
    SWV_BEGIN_API(f);
    if (!node)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    object(h)->RenderNode(static_cast<CssNode *>(static_cast<CssRefCount *>(node)),
                          static_cast<CssTransform *>(static_cast<CssRefCount *>(transform)));
    CssTrapHandler::UnTrap();
    return 1;
}

int graphics3d_renderWorld(void *h, void *world)
{
    SWV_BEGIN_API(f);
    if (!world)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    object(h)->RenderWorld(static_cast<CssWorld *>(static_cast<CssRefCount *>(world)));
    CssTrapHandler::UnTrap();
    return 1;
}
