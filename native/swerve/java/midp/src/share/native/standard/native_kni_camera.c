#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(Camera_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Camera_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(camera_create);
}

/* 0x302670  ([F)I */
uint32_t M3G_ENTRY(Camera_getProjectionParams)(void)
{
    KNI_ROOTS(2);
    int result = 0;
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray params = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, 4, &params.data, &params.count);
    if (ready) {
        if (camera_getProjectionParams(self, params.count, params.data, &result)) {
            copy_back(&roots[1], 4, &params);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[1], params.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x3025c4  (Ljavax/microedition/m3g/Transform;)I */
uint32_t M3G_ENTRY(Camera_getProjectionTransform)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *transform = kni_peer(&roots[1], 1, swvBaseClassFIDs_Transform);
    int result = 0;
    if (!camera_getProjectionTransform(self, transform, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

void M3G_ENTRY(Camera_setGeneric)(void)
{
    SWV_UnSafeMethod_Handle(camera_setGeneric, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Transform);
}

/* 0x302520  (FFFF)V */
void M3G_ENTRY(Camera_setParallel)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!camera_setParallel(self, kni_float(1), kni_float(2), kni_float(3), kni_float(4)))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x3024a0  (FFFF)V */
void M3G_ENTRY(Camera_setPerspective)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!camera_setPerspective(self, kni_float(1), kni_float(2), kni_float(3), kni_float(4)))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}
