#include "object_classes.hpp"

int rayintersection_create(void **result)
{
    return create_object(RayIntersectionObject, result);
}

void rayintersection_getDistance(void *handle, float *result)
{
    auto *object = static_cast<CssRayIntersection *>(static_cast<CssRefCount *>(handle));
    *result = object->GetDistance();
}

void rayintersection_getSubmeshIndex(void *handle, int *result)
{
    auto *object = static_cast<CssRayIntersection *>(static_cast<CssRefCount *>(handle));
    *result = object->GetSubmeshIndex();
}

void rayintersection_getIntersected(void *handle, void **result)
{
    auto *object = static_cast<CssRayIntersection *>(static_cast<CssRefCount *>(handle));
    *result = reference_handle(object->GetIntersected());
}

void rayintersection_getNormalX(void *handle, float *result)
{
    auto *object = static_cast<CssRayIntersection *>(static_cast<CssRefCount *>(handle));
    *result = object->GetNormalX();
}

void rayintersection_getNormalY(void *handle, float *result)
{
    auto *object = static_cast<CssRayIntersection *>(static_cast<CssRefCount *>(handle));
    *result = object->GetNormalY();
}

void rayintersection_getNormalZ(void *handle, float *result)
{
    auto *object = static_cast<CssRayIntersection *>(static_cast<CssRefCount *>(handle));
    *result = object->GetNormalZ();
}

int rayintersection_getTextureS(void *handle, int unit, float *result)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssRayIntersection *>(static_cast<CssRefCount *>(handle));
    *result = object->GetTextureS(unit);
    CssTrapHandler::UnTrap();
    return 1;
}

int rayintersection_getTextureT(void *handle, int unit, float *result)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssRayIntersection *>(static_cast<CssRefCount *>(handle));
    *result = object->GetTextureT(unit);
    CssTrapHandler::UnTrap();
    return 1;
}

int rayintersection_getRay(void *handle, int length, float *ray)
{
    SWV_BEGIN_API(frame);
    auto *object = static_cast<CssRayIntersection *>(static_cast<CssRefCount *>(handle));
    if (!ray)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    object->GetRay(length, ray);
    CssTrapHandler::UnTrap();
    return 1;
}
