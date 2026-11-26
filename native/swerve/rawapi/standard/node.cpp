#include "object_classes.hpp"
#include "kni_targets.h"
#include "engine.h"

void node_getParent(void *handle, void **parent)
{
    auto *node = static_cast<CssNode *>(static_cast<CssRefCount *>(handle));
    *parent = reference_handle(node->GetParent());
}

void node_getAlphaFactor(void *handle, float *alpha)
{
    auto *node = static_cast<CssNode *>(static_cast<CssRefCount *>(handle));
    *alpha = node->GetAlphaFactor();
}

int node_setAlphaFactor(void *handle, float alpha)
{
    SWV_BEGIN_API(frame);
    auto *node = static_cast<CssNode *>(static_cast<CssRefCount *>(handle));
    alpha = g_ValidateFloat(alpha);
    if (alpha < 0 || alpha > 1)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    node->SetAlphaFactor(alpha);
    CssTrapHandler::UnTrap();
    return 1;
}

void node_isRenderingEnabled(void *handle, int *result)
{
    auto *node = static_cast<CssNode *>(static_cast<CssRefCount *>(handle));
    *result = node->GetRenderingEnabled();
}

void node_setRenderingEnable(void *handle, int enabled)
{
    static_cast<CssNode *>(static_cast<CssRefCount *>(handle))->SetRenderingEnabled(enabled != 0);
}

void node_isPickingEnabled(void *handle, int *result)
{
    auto *node = static_cast<CssNode *>(static_cast<CssRefCount *>(handle));
    *result = node->GetPickingEnabled();
}

void node_setPickingEnable(void *handle, int enabled)
{
    static_cast<CssNode *>(static_cast<CssRefCount *>(handle))->SetPickingEnabled(enabled != 0);
}

void node_getScope(void *handle, int *scope)
{
    auto *node = static_cast<CssNode *>(static_cast<CssRefCount *>(handle));
    *scope = node->GetScope();
}

void node_setScope(void *handle, int scope)
{
    static_cast<CssNode *>(static_cast<CssRefCount *>(handle))->SetScope(scope);
}

int node_setAlignment(void *handle, void *z, int z_target, void *y, int y_target)
{
    SWV_BEGIN_API(frame);
    if (z_target < CssNode::None || z_target > CssNode::ZAxis || y_target < CssNode::None || y_target > CssNode::ZAxis)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    static_cast<CssNode *>(static_cast<CssRefCount *>(handle))->SetAlignment(
        static_cast<CssNode *>(static_cast<CssRefCount *>(z)), static_cast<CssNode::EssOrientationReference>(z_target),
        static_cast<CssNode *>(static_cast<CssRefCount *>(y)), static_cast<CssNode::EssOrientationReference>(y_target));
    CssTrapHandler::UnTrap();
    return 1;
}

int node_getAlignmentReference(void *handle, int axis, void **result)
{
    SWV_BEGIN_API(frame);
    auto *node = static_cast<CssNode *>(static_cast<CssRefCount *>(handle));
    CssNode *ref = node->GetAlignmentReference(static_cast<CssNode::EssOrientationReference>(axis));
    if (ref == reinterpret_cast<CssNode *>(-1)) ref = nullptr;
    *result = swv_retain_handle(static_cast<CssRefCount *>(ref));
    CssTrapHandler::UnTrap();
    return 1;
}

int node_getAlignmentTarget(void *handle, int axis, int *result)
{
    SWV_BEGIN_API(frame);
    auto *node = static_cast<CssNode *>(static_cast<CssRefCount *>(handle));
    *result = node->GetAlignmentTarget(static_cast<CssNode::EssOrientationReference>(axis));
    CssTrapHandler::UnTrap();
    return 1;
}

int node_align(void *handle, void *reference)
{
    SWV_BEGIN_API(frame);
    static_cast<CssNode *>(static_cast<CssRefCount *>(handle))->Align(
        static_cast<CssNode *>(static_cast<CssRefCount *>(reference)));
    CssTrapHandler::UnTrap();
    return 1;
}

int node_getTransformTo(void *self, void *target, void *transform, int *result)
{
    SWV_BEGIN_API(frame);
    if (!target || !transform)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *node = static_cast<CssNode *>(static_cast<CssRefCount *>(self));
    *result = node->GetTransformTo(static_cast<CssNode *>(static_cast<CssRefCount *>(target)),
                                   static_cast<CssTransform *>(static_cast<CssRefCount *>(transform)));
    CssTrapHandler::UnTrap();
    return 1;
}
