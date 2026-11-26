#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(AnimationController_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(AnimationController_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(animationcontroller_create);
}

uint32_t M3G_ENTRY(AnimationController_getWeight)(void)
{
    return (uint32_t)SWV_Getter_Float(animationcontroller_getWeight, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(AnimationController_getActiveIntervalStart)(void)
{
    return (uint32_t)SWV_Getter_Integer(animationcontroller_getActiveIntervalStart, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(AnimationController_getActiveIntervalEnd)(void)
{
    return (uint32_t)SWV_Getter_Integer(animationcontroller_getActiveIntervalEnd, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(AnimationController_getSpeed)(void)
{
    return (uint32_t)SWV_Getter_Float(animationcontroller_getSpeed, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(AnimationController_setWeight)(void)
{
    SWV_UnSafeSetter_Float(animationcontroller_setWeight, swvBaseClassFIDs_Object3D);
}

/* 0x301be4  (II)V */
void M3G_ENTRY(AnimationController_setActiveInterval)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!animationcontroller_setActiveInterval(self, (int)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x301b74  (I)F */
uint32_t M3G_ENTRY(AnimationController_getPosition)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    float result = 0;
    animationcontroller_getPosition(self, (int)Jbed_ParamPtr[1], &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return kni_float_result(result);
}

/* 0x301af8  (FI)V */
void M3G_ENTRY(AnimationController_setPosition)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!animationcontroller_setPosition(self, kni_float(1), (int)Jbed_ParamPtr[2]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x301a7c  (FI)V */
void M3G_ENTRY(AnimationController_setSpeed)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!animationcontroller_setSpeed(self, kni_float(1), (int)Jbed_ParamPtr[2]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

uint32_t M3G_ENTRY(AnimationController_getRefWorldTime)(void)
{
    return (uint32_t)SWV_Getter_Integer(animationcontroller_getRefWorldTime, swvBaseClassFIDs_Object3D);
}
