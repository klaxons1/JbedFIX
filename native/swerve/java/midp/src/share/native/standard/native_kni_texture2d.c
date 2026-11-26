#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(Texture2D_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

/* 0x307224  (Ljavax/microedition/m3g/Image2D;)I */
uint32_t M3G_ENTRY(Texture2D_create)(void)
{
    KNI_ROOTS(1);
    void *image2D = kni_peer(&roots[0], 1, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!texture2d_create(image2D, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

uint32_t M3G_ENTRY(Texture2D_getImageImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(texture2d_getImage, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Texture2D_getBlending)(void)
{
    return (uint32_t)SWV_Getter_Integer(texture2d_getBlending, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Texture2D_getBlendColor)(void)
{
    return (uint32_t)SWV_Getter_Integer(texture2d_getBlendColor, swvBaseClassFIDs_Object3D);
}

/* 0x3070dc  (Ljavax/microedition/m3g/Image2D;)V */
void M3G_ENTRY(Texture2D_setImageImpl)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[1], 0, swvBaseClassFIDs_Object3D);
    void *image2D = kni_peer(&roots[0], 1, swvBaseClassFIDs_Object3D);
    if (!texture2d_setImage(self, image2D))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

void M3G_ENTRY(Texture2D_setBlending)(void)
{
    SWV_UnSafeSetter_Integer(texture2d_setBlending, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(Texture2D_setBlendColor)(void)
{
    SWV_Setter_Integer(texture2d_setBlendColor, swvBaseClassFIDs_Object3D);
}

/* 0x30703c  ()I */
uint32_t M3G_ENTRY(Texture2D_getWrappingS)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    texture2d_getWrappingS(self, &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x306fdc  ()I */
uint32_t M3G_ENTRY(Texture2D_getWrappingT)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    texture2d_getWrappingT(self, &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x306f60  (II)V */
void M3G_ENTRY(Texture2D_setWrapping)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!texture2d_setWrapping(self, (int)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x306ee4  (II)V */
void M3G_ENTRY(Texture2D_setFiltering)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!texture2d_setFiltering(self, (int)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

uint32_t M3G_ENTRY(Texture2D_getImageFilter)(void)
{
    return (uint32_t)SWV_Getter_Integer(texture2d_getImageFilter, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Texture2D_getLevelFilter)(void)
{
    return (uint32_t)SWV_Getter_Integer(texture2d_getLevelFilter, swvBaseClassFIDs_Object3D);
}
