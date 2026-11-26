#include "object_classes.hpp"

int fog_create(void **result)
{
    return create_object(FogObject, result);
}

void fog_getColor(void *handle, int *result)
{
    auto *object = static_cast<CssFog *>(static_cast<CssRefCount *>(handle));
    *result = object->GetColor();
}

void fog_setColor(void *handle, int value)
{
    auto *object = static_cast<CssFog *>(static_cast<CssRefCount *>(handle));
    object->SetColor(value);
}

void fog_getDensity(void *handle, float *result)
{
    auto *object = static_cast<CssFog *>(static_cast<CssRefCount *>(handle));
    *result = object->GetDensity();
}

int fog_setDensity(void *handle, float value)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssFog *>(static_cast<CssRefCount *>(handle));
    value = g_ValidateFloat(value);
    if (value < 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetDensity(value);
    CssTrapHandler::UnTrap();
    return 1;
}

void fog_getMode(void *handle, int *result)
{
    auto *object = static_cast<CssFog *>(static_cast<CssRefCount *>(handle));
    *result = object->GetMode();
}

int fog_setMode(void *handle, int value)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssFog *>(static_cast<CssRefCount *>(handle));
    if (value < CssFog::Exponential || value > CssFog::Linear)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetMode(static_cast<CssFog::EssMode>(value));
    CssTrapHandler::UnTrap();
    return 1;
}

void fog_getNearDistance(void *handle, float *result)
{
    auto *object = static_cast<CssFog *>(static_cast<CssRefCount *>(handle));
    *result = object->GetNearDistance();
}

void fog_getFarDistance(void *handle, float *result)
{
    auto *object = static_cast<CssFog *>(static_cast<CssRefCount *>(handle));
    *result = object->GetFarDistance();
}

int fog_setLinear(void *handle, float near_distance, float far_distance)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssFog *>(static_cast<CssRefCount *>(handle));
    near_distance = g_ValidateFloat(near_distance);
    far_distance = g_ValidateFloat(far_distance);
    object->SetLinear(near_distance, far_distance);
    CssTrapHandler::UnTrap();
    return 1;
}
