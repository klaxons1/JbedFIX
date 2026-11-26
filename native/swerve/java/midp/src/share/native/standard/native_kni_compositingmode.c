#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(CompositingMode_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(CompositingMode_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(compositingmode_create);
}

uint32_t M3G_ENTRY(CompositingMode_getAlphaThreshold)(void)
{
    return (uint32_t)SWV_Getter_Float(compositingmode_getAlphaThreshold, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(CompositingMode_getBlending)(void)
{
    return (uint32_t)SWV_Getter_Integer(compositingmode_getBlending, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(CompositingMode_isColorWriteEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(compositingmode_isColorWriteEnabled, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(CompositingMode_isAlphaWriteEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(compositingmode_isAlphaWriteEnabled, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(CompositingMode_isDepthWriteEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(compositingmode_isDepthWriteEnabled, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(CompositingMode_isDepthTestEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(compositingmode_isDepthTestEnabled, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(CompositingMode_getDepthOffsetFactor)(void)
{
    return (uint32_t)SWV_Getter_Float(compositingmode_getDepthOffsetFactor, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(CompositingMode_getDepthOffsetUnits)(void)
{
    return (uint32_t)SWV_Getter_Float(compositingmode_getDepthOffsetUnits, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(CompositingMode_setAlphaThreshold)(void)
{
    SWV_UnSafeSetter_Float(compositingmode_setAlphaThreshold, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(CompositingMode_setBlending)(void)
{
    SWV_UnSafeSetter_Integer(compositingmode_setBlending, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(CompositingMode_setColorWriteEnable)(void)
{
    SWV_Setter_Boolean(compositingmode_setColorWriteEnable, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(CompositingMode_setAlphaWriteEnable)(void)
{
    SWV_Setter_Boolean(compositingmode_setAlphaWriteEnable, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(CompositingMode_setDepthWriteEnable)(void)
{
    SWV_Setter_Boolean(compositingmode_setDepthWriteEnable, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(CompositingMode_setDepthTestEnable)(void)
{
    SWV_Setter_Boolean(compositingmode_setDepthTestEnable, swvBaseClassFIDs_Object3D);
}

/* 0x302794  (FF)V */
void M3G_ENTRY(CompositingMode_setDepthOffset)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!compositingmode_setDepthOffset(self, kni_float(1), kni_float(2)))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}
