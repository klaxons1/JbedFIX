#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(PolygonMode_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(PolygonMode_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(polygonmode_create);
}

/* 0x306374  ()I */
uint32_t M3G_ENTRY(PolygonMode_getCulling)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    polygonmode_getCulling(self, &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x306314  ()I */
uint32_t M3G_ENTRY(PolygonMode_getShading)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    polygonmode_getShading(self, &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x3062b4  ()I */
uint32_t M3G_ENTRY(PolygonMode_getWinding)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    polygonmode_getWinding(self, &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

uint32_t M3G_ENTRY(PolygonMode_isTwoSidedLightingEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(polygonmode_isTwoSidedLightingEnabled, swvBaseClassFIDs_Object3D);
}

/* 0x3061dc  (I)V */
void M3G_ENTRY(PolygonMode_setCulling)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!polygonmode_setCulling(self, (int)Jbed_ParamPtr[1]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x306164  (I)V */
void M3G_ENTRY(PolygonMode_setShading)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!polygonmode_setShading(self, (int)Jbed_ParamPtr[1]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x3060ec  (I)V */
void M3G_ENTRY(PolygonMode_setWinding)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!polygonmode_setWinding(self, (int)Jbed_ParamPtr[1]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

void M3G_ENTRY(PolygonMode_setLocalCameraLightingEnable)(void)
{
    SWV_Setter_Boolean(polygonmode_setLocalCameraLightingEnable, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(PolygonMode_setPerspectiveCorrectionEnable)(void)
{
    SWV_Setter_Boolean(polygonmode_setPerspectiveCorrectionEnable, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(PolygonMode_setTwoSidedLightingEnable)(void)
{
    SWV_Setter_Boolean(polygonmode_setTwoSidedLightingEnable, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(PolygonMode_isLocalCameraLightingEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(polygonmode_isLocalCameraLightingEnabled, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(PolygonMode_isPerspectiveCorrectionEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(polygonmode_isPerspectiveCorrectionEnabled, swvBaseClassFIDs_Object3D);
}
