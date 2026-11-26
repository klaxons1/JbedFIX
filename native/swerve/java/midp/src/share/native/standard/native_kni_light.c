#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(Light_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Light_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(light_create);
}

/* 0x3046ac  ()I */
uint32_t M3G_ENTRY(Light_getMode)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    light_getMode(self, &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

uint32_t M3G_ENTRY(Light_getColor)(void)
{
    return (uint32_t)SWV_Getter_Integer(light_getColor, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Light_getIntensity)(void)
{
    return (uint32_t)SWV_Getter_Float(light_getIntensity, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Light_getSpotAngle)(void)
{
    return (uint32_t)SWV_Getter_Float(light_getSpotAngle, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Light_getSpotExponent)(void)
{
    return (uint32_t)SWV_Getter_Float(light_getSpotExponent, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Light_getConstantAttenuation)(void)
{
    return (uint32_t)SWV_Getter_Float(light_getConstantAttenuation, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Light_getLinearAttenuation)(void)
{
    return (uint32_t)SWV_Getter_Float(light_getLinearAttenuation, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Light_getQuadraticAttenuation)(void)
{
    return (uint32_t)SWV_Getter_Float(light_getQuadraticAttenuation, swvBaseClassFIDs_Object3D);
}

/* 0x304554  (I)V */
void M3G_ENTRY(Light_setMode)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!light_setMode(self, (int)Jbed_ParamPtr[1]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

void M3G_ENTRY(Light_setColor)(void)
{
    SWV_Setter_Integer(light_setColor, swvBaseClassFIDs_Object3D);
}

/* 0x3044bc  (F)V */
void M3G_ENTRY(Light_setIntensity)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!light_setIntensity(self, kni_float(1)))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

void M3G_ENTRY(Light_setSpotAngle)(void)
{
    SWV_UnSafeSetter_Float(light_setSpotAngle, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Light_setSpotExponent)(void)
{
    SWV_UnSafeSetter_Float(light_setSpotExponent, swvBaseClassFIDs_Object3D);
}

/* 0x304400  (FFF)V */
void M3G_ENTRY(Light_setAttenuation)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!light_setAttenuation(self, kni_float(1), kni_float(2), kni_float(3)))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}
