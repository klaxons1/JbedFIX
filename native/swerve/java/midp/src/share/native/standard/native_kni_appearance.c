#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(Appearance_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Appearance_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(appearance_create);
}

uint32_t M3G_ENTRY(Appearance_getLayer)(void)
{
    return (uint32_t)SWV_Getter_Integer(appearance_getLayer, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Appearance_getMaterialImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(appearance_getMaterial, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Appearance_getFogImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(appearance_getFog, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Appearance_getCompositingModeImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(appearance_getCompositingMode, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Appearance_getPolygonModeImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(appearance_getPolygonMode, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Appearance_setLayer)(void)
{
    SWV_UnSafeSetter_Integer(appearance_setLayer, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Appearance_setMaterialImpl)(void)
{
    SWV_Setter_Handle(appearance_setMaterial, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Appearance_setFogImpl)(void)
{
    SWV_Setter_Handle(appearance_setFog, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Appearance_setCompositingModeImpl)(void)
{
    SWV_Setter_Handle(appearance_setCompositingMode, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Appearance_setPolygonModeImpl)(void)
{
    SWV_Setter_Handle(appearance_setPolygonMode, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}

/* 0x301f1c  (I)I */
uint32_t M3G_ENTRY(Appearance_getTextureImpl)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!appearance_getTexture(self, (int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x301e74  (ILjavax/microedition/m3g/Texture2D;)V */
void M3G_ENTRY(Appearance_setTextureImpl)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int index = (int)Jbed_ParamPtr[1];
    void *texture2D = kni_peer(&roots[1], 2, swvBaseClassFIDs_Object3D);
    if (!appearance_setTexture(self, index, texture2D))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}
