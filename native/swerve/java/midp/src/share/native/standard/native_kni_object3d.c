#include "kni.h"
#include "kni_targets.h"

uint32_t M3G_ENTRY(Object3D_getUserID)(void)
{
    return (uint32_t)SWV_Getter_Integer(object3d_getUserID, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Object3D_getAnimationTrackCount)(void)
{
    return (uint32_t)SWV_Getter_Integer(object3d_getAnimationTrackCount, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Object3D_setUserID)(void)
{
    SWV_Setter_Integer(object3d_setUserID, swvBaseClassFIDs_Object3D);
}

/* 0x305fac  (I)I */
uint32_t M3G_ENTRY(Object3D_getAnimationTrackImpl)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!object3d_getAnimationTrack(self, (int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

void M3G_ENTRY(Object3D_addAnimationTrackImpl)(void)
{
    SWV_UnSafeMethod_Handle(object3d_addAnimationTrack, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}

/* 0x305ef4  (Ljavax/microedition/m3g/AnimationTrack;)V */
void M3G_ENTRY(Object3D_removeAnimationTrack)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *animationTrack = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    object3d_removeAnimationTrack(self, animationTrack);
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x305e74  (I)I */
uint32_t M3G_ENTRY(Object3D_animate)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    if (!object3d_animate(self, (int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x305e04  (I)I */
uint32_t M3G_ENTRY(Object3D_findImpl)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    object3d_find(self, (int)Jbed_ParamPtr[1], &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x305d24  ([I)I */
uint32_t M3G_ENTRY(Object3D_getReferencesImpl)(void)
{
    KNI_ROOTS(2);
    int result = 0;
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray refs = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, UINT32_MAX, &refs.data, &refs.count);
    if (ready) {
        object3d_getReferences(self, refs.count, refs.data, &result);
        copy_back(&roots[1], 4, &refs);
    }
    SWV_FreeArrayBytes(&roots[1], refs.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x305cc8  ()V */
void M3G_ENTRY(Object3D_removeUserParameters)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    object3d_removeUserParameters(self);
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x305c58  (I)I */
uint32_t M3G_ENTRY(Object3D_getUserParameterID)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    object3d_getUserParameterID(self, (int)Jbed_ParamPtr[1], &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x305b6c  (I[B)I */
uint32_t M3G_ENTRY(Object3D_getUserParameterValue)(void)
{
    KNI_ROOTS(2);
    int result = 0;
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int index = (int)Jbed_ParamPtr[1];
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[2], 'o');
    KniArray value = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 1, UINT32_MAX, &value.data, &value.count);
    if (ready) {
        object3d_getUserParameterValue(self, index, value.count, value.data, &result);
        copy_back(&roots[1], 1, &value);
    }
    SWV_FreeArrayBytes(&roots[1], value.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x305afc  ()I */
uint32_t M3G_ENTRY(Object3D_duplicateImpl)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!object3d_duplicate(self, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}
