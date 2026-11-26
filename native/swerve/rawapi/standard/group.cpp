#include "cssobjectfactory.hpp"
#include "math_pick.h"
#include "object_classes.hpp"
#include "kni_targets.h"

int group_create(void **out)
{
    SWV_BEGIN_API(frame);
    *out = swv_retain_handle(static_cast<CssRefCount *>(CssObjectFactory::CreateObject(GroupObject)));
    CssTrapHandler::UnTrap();
    return 1;
}

void group_getChildCount(void *h, int *count)
{
    auto *group = static_cast<CssGroup *>(static_cast<CssRefCount *>(h));
    *count = group->GetChildCount();
}

int group_getChild(void *h, int index, void **out)
{
    SWV_BEGIN_API(frame);
    auto *group = static_cast<CssGroup *>(static_cast<CssRefCount *>(h));
    *out = reference_handle(group->GetChild(index));
    CssTrapHandler::UnTrap();
    return 1;
}

int group_addChild(void *h, void *child)
{
    SWV_BEGIN_API(frame);
    auto *group = static_cast<CssGroup *>(static_cast<CssRefCount *>(h));
    group->AddChild(static_cast<CssNode *>(static_cast<CssRefCount *>(child)));
    CssTrapHandler::UnTrap();
    return 1;
}

int group_removeChild(void *h, void *child)
{
    SWV_BEGIN_API(frame);
    auto *group = static_cast<CssGroup *>(static_cast<CssRefCount *>(h));
    group->RemoveChild(static_cast<CssNode *>(static_cast<CssRefCount *>(child)));
    CssTrapHandler::UnTrap();
    return 1;
}

extern "C" int group_pickNode(void *group, int scope, const float *origin, const float *direction,
                              void *out, int *found)
{
    SWV_BEGIN_API(frame);
    auto *node = static_cast<CssGroup *>(static_cast<CssRefCount *>(group));
    CssVector3D from{g_ValidateFloat(origin[0]), g_ValidateFloat(origin[1]), g_ValidateFloat(origin[2])};
    CssVector3D delta{g_ValidateFloat(direction[0]), g_ValidateFloat(direction[1]), g_ValidateFloat(direction[2])};
    auto *hit = static_cast<CssRayIntersection *>(static_cast<CssRefCount *>(out));
    *found = node ? node->Pick(scope, from, delta, hit)
                  : swv_pick_empty_group(scope, from, delta, hit);
    CssTrapHandler::UnTrap();
    return 1;
}

extern "C" int group_pickCamera(void *group, int scope, float x, float y, void *camera,
                                void *out, int *found)
{
    SWV_BEGIN_API(frame);
    auto *node = static_cast<CssGroup *>(static_cast<CssRefCount *>(group));
    x = g_ValidateFloat(x);
    y = g_ValidateFloat(y);
    auto *c = static_cast<CssCamera *>(static_cast<CssRefCount *>(camera));
    if (!c)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *hit = static_cast<CssRayIntersection *>(static_cast<CssRefCount *>(out));
    if (!node)
        g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    *found = node->Pick(scope, x, y, c, hit);
    CssTrapHandler::UnTrap();
    return 1;
}
