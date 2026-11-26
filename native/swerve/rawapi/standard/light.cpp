#include "object_classes.hpp"

int light_create(void **result)
{
    return create_object(LightObject, result);
}

void light_getMode(void *handle, int *result)
{
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    *result = object->GetMode();
}

int light_setMode(void *handle, int value)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    if (value < CssLight::Ambient || value > CssLight::Spot)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetMode(static_cast<CssLight::EssMode>(value));
    CssTrapHandler::UnTrap();
    return 1;
}

void light_getColor(void *handle, int *result)
{
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    *result = object->GetColor();
}

void light_setColor(void *handle, int value)
{
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    object->SetColor(value);
}

void light_getIntensity(void *handle, float *result)
{
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    *result = object->GetIntensity();
}

int light_setIntensity(void *handle, float value)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    value = g_ValidateFloat(value);
    object->SetIntensity(value);
    CssTrapHandler::UnTrap();
    return 1;
}

void light_getSpotAngle(void *handle, float *result)
{
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    *result = object->GetSpotAngle();
}

int light_setSpotAngle(void *handle, float value)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    value = g_ValidateFloat(value);
    if (value < 0 || value > 90)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetSpotAngle(value);
    CssTrapHandler::UnTrap();
    return 1;
}

void light_getSpotExponent(void *handle, float *result)
{
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    *result = object->GetSpotExponent();
}

int light_setSpotExponent(void *handle, float value)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    value = g_ValidateFloat(value);
    if (value < 0 || value > 128)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetSpotExponent(value);
    CssTrapHandler::UnTrap();
    return 1;
}

void light_getConstantAttenuation(void *handle, float *result)
{
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    *result = object->GetConstantAttenuation();
}

void light_getLinearAttenuation(void *handle, float *result)
{
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    *result = object->GetLinearAttenuation();
}

void light_getQuadraticAttenuation(void *handle, float *result)
{
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    *result = object->GetQuadraticAttenuation();
}

int light_setAttenuation(void *handle, float constant, float linear, float quadratic)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssLight *>(static_cast<CssRefCount *>(handle));
    constant = g_ValidateFloat(constant);
    if (constant < 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    linear = g_ValidateFloat(linear);
    if (linear < 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    quadratic = g_ValidateFloat(quadratic);
    if (quadratic < 0 || (constant == 0 && linear == 0 && quadratic == 0))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetAttenuation(constant, linear, quadratic);
    CssTrapHandler::UnTrap();
    return 1;
}
