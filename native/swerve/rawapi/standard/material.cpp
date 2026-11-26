#include "object_classes.hpp"

int material_create(void **result)
{
    return create_object(MaterialObject, result);
}

void material_getShininess(void *handle, float *result)
{
    auto *object = static_cast<CssMaterial *>(static_cast<CssRefCount *>(handle));
    *result = object->GetShininess();
}

int material_setShininess(void *handle, float value)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssMaterial *>(static_cast<CssRefCount *>(handle));
    value = g_ValidateFloat(value);
    if (value < 0 || value > 128)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetShininess(value);
    CssTrapHandler::UnTrap();
    return 1;
}

void material_isVertexColorTrackingEnabled(void *handle, int *result)
{
    auto *object = static_cast<CssMaterial *>(static_cast<CssRefCount *>(handle));
    *result = object->GetbVertexColorTracking();
}

void material_setVertexColorTrackingEnable(void *handle, int value)
{
    auto *object = static_cast<CssMaterial *>(static_cast<CssRefCount *>(handle));
    object->SetbVertexColorTracking(value != 0);
}

int material_getColor(void *handle, int component, int *color)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssMaterial *>(static_cast<CssRefCount *>(handle));
    if (component != CssMaterial::Ambient && component != CssMaterial::Diffuse &&
        component != CssMaterial::Emissive && component != CssMaterial::Specular)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    *color = object->GetColor(static_cast<CssMaterial::EssColorTarget>(component));
    CssTrapHandler::UnTrap();
    return 1;
}

int material_setColor(void *handle, int components, int color)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssMaterial *>(static_cast<CssRefCount *>(handle));
    object->SetColor(static_cast<CssMaterial::EssColorTarget>(components), color);
    CssTrapHandler::UnTrap();
    return 1;
}
