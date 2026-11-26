#include "object_classes.hpp"

int appearance_create(void **result)
{
    return create_object(AppearanceObject, result);
}

void appearance_getLayer(void *handle, int *result)
{
    auto *object = static_cast<CssAppearance *>(static_cast<CssRefCount *>(handle));
    *result = object->GetLayer();
}

int appearance_setLayer(void *handle, int value)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssAppearance *>(static_cast<CssRefCount *>(handle));
    if (value < -CssAppearance::MaxLayer || value > CssAppearance::MaxLayer)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetLayer(value);
    CssTrapHandler::UnTrap();
    return 1;
}

void appearance_getMaterial(void *handle, void **result)
{
    auto *object = static_cast<CssAppearance *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->GetMaterial());
}

void appearance_setMaterial(void *handle, void *value)
{
    auto *object = static_cast<CssAppearance *>(static_cast<CssRefCount *>(handle));
    object->SetMaterial(static_cast<CssMaterial *>(static_cast<CssRefCount *>(value)));
}

void appearance_getFog(void *handle, void **result)
{
    auto *object = static_cast<CssAppearance *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->GetFog());
}

void appearance_setFog(void *handle, void *value)
{
    auto *object = static_cast<CssAppearance *>(static_cast<CssRefCount *>(handle));
    object->SetFog(static_cast<CssFog *>(static_cast<CssRefCount *>(value)));
}

void appearance_getCompositingMode(void *handle, void **result)
{
    auto *object = static_cast<CssAppearance *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->GetCompositingMode());
}

void appearance_setCompositingMode(void *handle, void *value)
{
    auto *object = static_cast<CssAppearance *>(static_cast<CssRefCount *>(handle));
    object->SetCompositingMode(static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(value)));
}

void appearance_getPolygonMode(void *handle, void **result)
{
    auto *object = static_cast<CssAppearance *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->GetPolygonMode());
}

void appearance_setPolygonMode(void *handle, void *value)
{
    auto *object = static_cast<CssAppearance *>(static_cast<CssRefCount *>(handle));
    object->SetPolygonMode(static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(value)));
}

int appearance_getTexture(void *handle, int unit, void **result)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssAppearance *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->GetTexture(unit));
    CssTrapHandler::UnTrap();
    return 1;
}

int appearance_setTexture(void *handle, int unit, void *texture)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssAppearance *>(static_cast<CssRefCount *>(handle));
    object->SetTexture(unit, static_cast<CssTexture2D *>(static_cast<CssRefCount *>(texture)));
    CssTrapHandler::UnTrap();
    return 1;
}
