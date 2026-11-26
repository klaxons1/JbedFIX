#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(AnimationTrack_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

/* 0x301ddc  (Ljavax/microedition/m3g/KeyframeSequence;I)I */
uint32_t M3G_ENTRY(AnimationTrack_create)(void)
{
    KNI_ROOTS(1);
    void *keyframeSequence = kni_peer(&roots[0], 1, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!animationtrack_create(keyframeSequence, (int)Jbed_ParamPtr[2], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

uint32_t M3G_ENTRY(AnimationTrack_getControllerImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(animationtrack_getController, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(AnimationTrack_getKeyframeSequenceImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(animationtrack_getKeyframeSequence, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(AnimationTrack_getTargetProperty)(void)
{
    return (uint32_t)SWV_Getter_Integer(animationtrack_getTargetProperty, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(AnimationTrack_setControllerImpl)(void)
{
    SWV_Setter_Handle(animationtrack_setController, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}
