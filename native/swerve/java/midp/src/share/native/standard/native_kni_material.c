#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(Material_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Material_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(material_create);
}

uint32_t M3G_ENTRY(Material_getShininess)(void)
{
    return (uint32_t)SWV_Getter_Float(material_getShininess, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Material_isVertexColorTrackingEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(material_isVertexColorTrackingEnabled, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Material_setShininess)(void)
{
    SWV_UnSafeSetter_Float(material_setShininess, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Material_setVertexColorTrackingEnable)(void)
{
    SWV_Setter_Boolean(material_setVertexColorTrackingEnable, swvBaseClassFIDs_Object3D);
}

/* 0x304d14  (I)I */
uint32_t M3G_ENTRY(Material_getColor)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    if (!material_getColor(self, (int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x304c98  (II)V */
void M3G_ENTRY(Material_setColor)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!material_setColor(self, (int)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}
