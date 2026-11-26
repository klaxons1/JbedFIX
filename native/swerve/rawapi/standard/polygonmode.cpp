#include "object_classes.hpp"

int polygonmode_create(void **result)
{
    return create_object(PolygonModeObject, result);
}

void polygonmode_getCulling(void *handle, int *result)
{
    auto *object = static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetCulling();
}

int polygonmode_setCulling(void *handle, int mode)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(handle));
    if (mode < CssPolygonMode::CullBack || mode > CssPolygonMode::CullNone)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetCulling(static_cast<CssPolygonMode::EssCulling>(mode));
    CssTrapHandler::UnTrap();
    return 1;
}

void polygonmode_getShading(void *handle, int *result)
{
    auto *object = static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetShading();
}

int polygonmode_setShading(void *handle, int mode)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(handle));
    if (mode < CssPolygonMode::Flat || mode > CssPolygonMode::Smooth)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetShading(static_cast<CssPolygonMode::EssShading>(mode));
    CssTrapHandler::UnTrap();
    return 1;
}

void polygonmode_getWinding(void *handle, int *result)
{
    auto *object = static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetWinding();
}

int polygonmode_setWinding(void *handle, int mode)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(handle));
    if (mode < CssPolygonMode::CounterClockwise || mode > CssPolygonMode::Clockwise)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    object->SetWinding(static_cast<CssPolygonMode::EssWinding>(mode));
    CssTrapHandler::UnTrap();
    return 1;
}

void polygonmode_isLocalCameraLightingEnabled(void *handle, int *result)
{
    auto *object = static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetLocalCameraLighting();
}

void polygonmode_setLocalCameraLightingEnable(void *handle, int value)
{
    auto *object = static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(handle));
    object->EnableLocalCameraLighting(value != 0);
}

void polygonmode_isPerspectiveCorrectionEnabled(void *handle, int *result)
{
    auto *object = static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetPerspectiveCorrection();
}

void polygonmode_setPerspectiveCorrectionEnable(void *handle, int value)
{
    auto *object = static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(handle));
    object->EnablePerspectiveCorrection(value != 0);
}

void polygonmode_isTwoSidedLightingEnabled(void *handle, int *result)
{
    auto *object = static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(handle));
    *result = object->GetbTwoSidedLighting();
}

void polygonmode_setTwoSidedLightingEnable(void *handle, int value)
{
    auto *object = static_cast<CssPolygonMode *>(static_cast<CssRefCount *>(handle));
    object->SetbTwoSidedLighting(value != 0);
}
