#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(RayIntersection_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_RayIntersection);
}

uint32_t M3G_ENTRY(RayIntersection_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(rayintersection_create);
}

uint32_t M3G_ENTRY(RayIntersection_getDistance)(void)
{
    return (uint32_t)SWV_Getter_Float(rayintersection_getDistance, swvBaseClassFIDs_RayIntersection);
}

uint32_t M3G_ENTRY(RayIntersection_getIntersectedImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(rayintersection_getIntersected, swvBaseClassFIDs_RayIntersection);
}

uint32_t M3G_ENTRY(RayIntersection_getSubmeshIndex)(void)
{
    return (uint32_t)SWV_Getter_Integer(rayintersection_getSubmeshIndex, swvBaseClassFIDs_RayIntersection);
}

uint32_t M3G_ENTRY(RayIntersection_getNormalX)(void)
{
    return (uint32_t)SWV_Getter_Float(rayintersection_getNormalX, swvBaseClassFIDs_RayIntersection);
}

uint32_t M3G_ENTRY(RayIntersection_getNormalY)(void)
{
    return (uint32_t)SWV_Getter_Float(rayintersection_getNormalY, swvBaseClassFIDs_RayIntersection);
}

uint32_t M3G_ENTRY(RayIntersection_getNormalZ)(void)
{
    return (uint32_t)SWV_Getter_Float(rayintersection_getNormalZ, swvBaseClassFIDs_RayIntersection);
}

/* 0x306574  (I)F */
uint32_t M3G_ENTRY(RayIntersection_getTextureS)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_RayIntersection);
    float result = 0;
    if (!rayintersection_getTextureS(self, (int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return kni_float_result(result);
}

/* 0x3064f4  (I)F */
uint32_t M3G_ENTRY(RayIntersection_getTextureT)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_RayIntersection);
    float result = 0;
    if (!rayintersection_getTextureT(self, (int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return kni_float_result(result);
}

/* 0x30640c  ([F)V */
void M3G_ENTRY(RayIntersection_getRay)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_RayIntersection);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray ray = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, 6, &ray.data, &ray.count);
    if (ready) {
        if (rayintersection_getRay(self, ray.count, ray.data)) {
            copy_back(&roots[1], 4, &ray);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[1], ray.data);
    Jbed_nativeCallStateAdr = saved_roots;
}
