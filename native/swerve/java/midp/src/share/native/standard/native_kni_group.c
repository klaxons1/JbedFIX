#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(Group_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Group_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(group_create);
}

uint32_t M3G_ENTRY(Group_getChildCount)(void)
{
    return (uint32_t)SWV_Getter_Integer(group_getChildCount, swvBaseClassFIDs_Object3D);
}

/* 0x3039d0  (I)I */
uint32_t M3G_ENTRY(Group_getChildImpl)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!group_getChild(self, (int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

void M3G_ENTRY(Group_addChildImpl)(void)
{
    SWV_UnSafeMethod_Handle(group_addChild, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Group_removeChild)(void)
{
    SWV_UnSafeMethod_Handle(group_removeChild, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}

/* 0x3038b0  (IFFFFFFLjavax/microedition/m3g/RayIntersection;)Z */
uint32_t M3G_ENTRY(Group_pickNode)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int scope = (int)Jbed_ParamPtr[1];
    float origin[] = {kni_float(2), kni_float(3), kni_float(4)};
    float direction[] = {kni_float(5), kni_float(6), kni_float(7)};
    void *rayIntersection = kni_peer(&roots[1], 8, swvBaseClassFIDs_RayIntersection);
    int result = 0;
    if (!group_pickNode(self, scope, origin, direction, rayIntersection, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint8_t)result;
}

/* 0x3037cc  (IFFLjavax/microedition/m3g/Camera;Ljavax/microedition/m3g/RayIntersection;)Z */
uint32_t M3G_ENTRY(Group_pickCamera)(void)
{
    KNI_ROOTS(3);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int scope = (int)Jbed_ParamPtr[1];
    float x = kni_float(2);
    float y = kni_float(3);
    void *camera = kni_peer(&roots[1], 4, swvBaseClassFIDs_Object3D);
    void *rayIntersection = kni_peer(&roots[2], 5, swvBaseClassFIDs_RayIntersection);
    int result = 0;
    if (!group_pickCamera(self, scope, x, y, camera, rayIntersection, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint8_t)result;
}
