#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(Background_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Background_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(background_create);
}

uint32_t M3G_ENTRY(Background_getColor)(void)
{
    return (uint32_t)SWV_Getter_Integer(background_getColor, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Background_getImageImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(background_getImage, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Background_getImageModeX)(void)
{
    return (uint32_t)SWV_Getter_Integer(background_getImageModeX, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Background_getImageModeY)(void)
{
    return (uint32_t)SWV_Getter_Integer(background_getImageModeY, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Background_getCropX)(void)
{
    return (uint32_t)SWV_Getter_Integer(background_getCropX, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Background_getCropY)(void)
{
    return (uint32_t)SWV_Getter_Integer(background_getCropY, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Background_getCropWidth)(void)
{
    return (uint32_t)SWV_Getter_Integer(background_getCropWidth, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Background_getCropHeight)(void)
{
    return (uint32_t)SWV_Getter_Integer(background_getCropHeight, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Background_isColorClearEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(background_isColorClearEnabled, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Background_isDepthClearEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(background_isDepthClearEnabled, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Background_setColor)(void)
{
    SWV_Setter_Integer(background_setColor, swvBaseClassFIDs_Object3D);
}

/* 0x302260  (Ljavax/microedition/m3g/Image2D;)V */
void M3G_ENTRY(Background_setImageImpl)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[1], 0, swvBaseClassFIDs_Object3D);
    void *image2D = kni_peer(&roots[0], 1, swvBaseClassFIDs_Object3D);
    if (!background_setImage(self, image2D))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

void M3G_ENTRY(Background_setColorClearEnable)(void)
{
    SWV_Setter_Boolean(background_setColorClearEnable, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Background_setDepthClearEnable)(void)
{
    SWV_Setter_Boolean(background_setDepthClearEnable, swvBaseClassFIDs_Object3D);
}

/* 0x3021a4  (II)V */
void M3G_ENTRY(Background_setImageMode)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!background_setImageMode(self, (int)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x302124  (IIII)V */
void M3G_ENTRY(Background_setCrop)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!background_setCrop(self, (int)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2], (int)Jbed_ParamPtr[3], (int)Jbed_ParamPtr[4]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}
