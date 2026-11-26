#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(Sprite3D_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

/* 0x306e1c  (ZLjavax/microedition/m3g/Image2D;Ljavax/microedition/m3g/Appearance;)I */
uint32_t M3G_ENTRY(Sprite3D_create)(void)
{
    KNI_ROOTS(2);
    int scaled = (uint8_t)Jbed_ParamPtr[1];
    void *image2D = kni_peer(&roots[0], 2, swvBaseClassFIDs_Object3D);
    void *appearance = kni_peer(&roots[1], 3, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!sprite3d_create(scaled, image2D, appearance, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

uint32_t M3G_ENTRY(Sprite3D_getAppearanceImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(sprite3d_getAppearance, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Sprite3D_getImageImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(sprite3d_getImage, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Sprite3D_getCropHeight)(void)
{
    return (uint32_t)SWV_Getter_Integer(sprite3d_getCropHeight, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Sprite3D_getCropWidth)(void)
{
    return (uint32_t)SWV_Getter_Integer(sprite3d_getCropWidth, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Sprite3D_getCropX)(void)
{
    return (uint32_t)SWV_Getter_Integer(sprite3d_getCropX, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Sprite3D_getCropY)(void)
{
    return (uint32_t)SWV_Getter_Integer(sprite3d_getCropY, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Sprite3D_setAppearanceImpl)(void)
{
    SWV_Setter_Handle(sprite3d_setAppearance, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Sprite3D_setImageImpl)(void)
{
    SWV_UnSafeSetter_Handle(sprite3d_setImage, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Object3D);
}

/* 0x306cb0  ()Z */
uint32_t M3G_ENTRY(Sprite3D_isScaled)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    sprite3d_isScaled(self, &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint8_t)result;
}

/* 0x306c30  (IIII)V */
void M3G_ENTRY(Sprite3D_setCrop)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!sprite3d_setCrop(self, (int)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2], (int)Jbed_ParamPtr[3], (int)Jbed_ParamPtr[4]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}
