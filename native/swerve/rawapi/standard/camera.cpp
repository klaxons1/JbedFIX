#include "cssobjectfactory.hpp"
#include "object_classes.hpp"
#include "engine.h"
#include "kni_targets.h"

int camera_create(void **out)
{
    SWV_BEGIN_API(frame);
    *out = swv_retain_handle(static_cast<CssRefCount *>(CssObjectFactory::CreateObject(CameraObject)));
    CssTrapHandler::UnTrap();
    return 1;
}

int camera_getProjectionParams(void *h, int count, float *out, int *type)
{
    SWV_BEGIN_API(frame);
    auto *c = static_cast<CssCamera *>(static_cast<CssRefCount *>(h));
    *type = c->GetProjection(count, out);
    CssTrapHandler::UnTrap();
    return 1;
}

int camera_getProjectionTransform(void *h, void *transform, int *type)
{
    SWV_BEGIN_API(frame);
    auto *c = static_cast<CssCamera *>(static_cast<CssRefCount *>(h));
    *type = c->GetProjection(static_cast<CssTransform *>(static_cast<CssRefCount *>(transform)));
    CssTrapHandler::UnTrap();
    return 1;
}

int camera_setGeneric(void *h, void *transform)
{
    SWV_BEGIN_API(frame);
    if (!transform) g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *c = static_cast<CssCamera *>(static_cast<CssRefCount *>(h));
    c->SetGeneric(static_cast<const CssTransform *>(static_cast<CssRefCount *>(transform)));
    CssTrapHandler::UnTrap();
    return 1;
}

static float positive(float value)
{
    value = g_ValidateFloat(value);
    if (value <= 0) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    return value;
}

int camera_setParallel(void *h, float height, float aspect, float near_plane, float far_plane)
{
    SWV_BEGIN_API(frame);
    auto *c = static_cast<CssCamera *>(static_cast<CssRefCount *>(h));
    height = positive(height);
    aspect = positive(aspect);
    near_plane = g_ValidateFloat(near_plane);
    far_plane = g_ValidateFloat(far_plane);
    c->SetParallel(height, aspect, near_plane, far_plane);
    CssTrapHandler::UnTrap();
    return 1;
}

int camera_setPerspective(void *h, float fovy, float aspect, float near_plane, float far_plane)
{
    SWV_BEGIN_API(frame);
    auto *c = static_cast<CssCamera *>(static_cast<CssRefCount *>(h));
    fovy = positive(fovy);
    if (fovy >= 180) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    aspect = positive(aspect);
    near_plane = positive(near_plane);
    far_plane = positive(far_plane);
    c->SetPerspective(fovy, aspect, near_plane, far_plane);
    CssTrapHandler::UnTrap();
    return 1;
}
