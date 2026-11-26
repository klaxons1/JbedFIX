#include "object_classes.hpp"

int compositingmode_create(void **result)
{
    return create_object(CompositingModeObject, result);
}

void compositingmode_getAlphaThreshold(void *handle, float *result)
{
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetAlphaThreshold();
}

int compositingmode_setAlphaThreshold(void *handle, float value)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    value = g_ValidateFloat(value);
    if (value < 0 || value > 1)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetAlphaThreshold(value);
    CssTrapHandler::UnTrap();
    return 1;
}

void compositingmode_getBlending(void *handle, int *result)
{
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetBlending();
}

int compositingmode_setBlending(void *handle, int value)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    if (value < CssCompositingMode::Alpha || value > CssCompositingMode::Replace)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetBlending(static_cast<CssCompositingMode::EssBlending>(value));
    CssTrapHandler::UnTrap();
    return 1;
}

void compositingmode_isColorWriteEnabled(void *handle, int *result)
{
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetColorWrite();
}

void compositingmode_setColorWriteEnable(void *handle, int value)
{
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    object->SetColorWrite(value != 0);
}

void compositingmode_isAlphaWriteEnabled(void *handle, int *result)
{
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetAlphaWrite();
}

void compositingmode_setAlphaWriteEnable(void *handle, int value)
{
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    object->SetAlphaWrite(value != 0);
}

void compositingmode_isDepthWriteEnabled(void *handle, int *result)
{
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetDepthWrite();
}

void compositingmode_setDepthWriteEnable(void *handle, int value)
{
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    object->SetDepthWrite(value != 0);
}

void compositingmode_isDepthTestEnabled(void *handle, int *result)
{
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetDepthTest();
}

void compositingmode_setDepthTestEnable(void *handle, int value)
{
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    object->SetDepthTest(value != 0);
}

void compositingmode_getDepthOffsetFactor(void *handle, float *result)
{
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetDepthOffsetFactor();
}

void compositingmode_getDepthOffsetUnits(void *handle, float *result)
{
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetDepthOffsetUnits();
}

int compositingmode_setDepthOffset(void *handle, float factor, float units)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssCompositingMode *>(static_cast<CssRefCount *>(handle));
    factor = g_ValidateFloat(factor);
    units = g_ValidateFloat(units);
    object->SetDepthOffset(factor, units);
    CssTrapHandler::UnTrap();
    return 1;
}
