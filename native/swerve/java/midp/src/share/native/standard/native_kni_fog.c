#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(Fog_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Fog_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(fog_create);
}

uint32_t M3G_ENTRY(Fog_getColor)(void)
{
    return (uint32_t)SWV_Getter_Integer(fog_getColor, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Fog_getDensity)(void)
{
    return (uint32_t)SWV_Getter_Float(fog_getDensity, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Fog_getMode)(void)
{
    return (uint32_t)SWV_Getter_Integer(fog_getMode, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Fog_getNearDistance)(void)
{
    return (uint32_t)SWV_Getter_Float(fog_getNearDistance, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Fog_getFarDistance)(void)
{
    return (uint32_t)SWV_Getter_Float(fog_getFarDistance, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Fog_setColor)(void)
{
    SWV_Setter_Integer(fog_setColor, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Fog_setDensity)(void)
{
    SWV_UnSafeSetter_Float(fog_setDensity, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Fog_setMode)(void)
{
    SWV_UnSafeSetter_Integer(fog_setMode, swvBaseClassFIDs_Object3D);
}

/* 0x302af8  (FF)V */
void M3G_ENTRY(Fog_setLinear)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!fog_setLinear(self, kni_float(1), kni_float(2)))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}
