#include "kni.h"
#include "kni_targets.h"
#include "platform.h"

void M3G_ENTRY(Image2D_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

/* 0x303e14  (III[B)I */
uint32_t M3G_ENTRY(Image2D_create)(void)
{
    KNI_ROOTS(1);
    void *result = NULL;
    int format = (int)Jbed_ParamPtr[1];
    int width = (int)Jbed_ParamPtr[2];
    int height = (int)Jbed_ParamPtr[3];
    roots[0] = JbedKNI_VerifyObject(Jbed_ParamPtr[4], 'o');
    KniArray pixels = {0};
    int ready = SWV_GetArrayBytes(&roots[0], 1, UINT32_MAX, &pixels.data, &pixels.count);
    if (ready && !image2d_create(format, width, height, pixels.count, pixels.data, &result))
        ThrowSwerveAPIException();
    swvFree(pixels.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x303d10  (III[B[B)I */
uint32_t M3G_ENTRY(Image2D_createPalettized)(void)
{
    KNI_ROOTS(2);
    void *result = NULL;
    int format = (int)Jbed_ParamPtr[1];
    int width = (int)Jbed_ParamPtr[2];
    int height = (int)Jbed_ParamPtr[3];
    roots[0] = JbedKNI_VerifyObject(Jbed_ParamPtr[4], 'o');
    KniArray pixels = {0};
    int ready = SWV_GetArrayBytes(&roots[0], 1, UINT32_MAX, &pixels.data, &pixels.count);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[5], 'o');
    KniArray palette = {0};
    ready = ready && SWV_GetArrayBytes(&roots[1], 1, UINT32_MAX, &palette.data, &palette.count);
    if (ready && !image2d_createPalettized(format, width, height, pixels.count, pixels.data, palette.count, palette.data, &result))
        ThrowSwerveAPIException();
    swvFree(pixels.data);
    swvFree(palette.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x303cd0  (III)I */
uint32_t M3G_ENTRY(Image2D_createMutable)(void)
{
    void *result = NULL;
    if (!image2d_createMutable((int)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2], (int)Jbed_ParamPtr[3], &result))
        ThrowSwerveAPIException();
    return (uint32_t)(uintptr_t)result;
}

/* 0x303c8c  (IIIZ)I */
uint32_t M3G_ENTRY(Image2D_createUninitialized)(void)
{
    void *result = NULL;
    if (!image2d_createUninitialized((int)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2], (int)Jbed_ParamPtr[3], (uint8_t)Jbed_ParamPtr[4], &result))
        ThrowSwerveAPIException();
    return (uint32_t)(uintptr_t)result;
}

uint32_t M3G_ENTRY(Image2D_getFormat)(void)
{
    return (uint32_t)SWV_Getter_Integer(image2d_getFormat, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Image2D_getWidth)(void)
{
    return (uint32_t)SWV_Getter_Integer(image2d_getWidth, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Image2D_getHeight)(void)
{
    return (uint32_t)SWV_Getter_Integer(image2d_getHeight, swvBaseClassFIDs_Object3D);
}

/* 0x303bc8  ()Z */
uint32_t M3G_ENTRY(Image2D_isMutable)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    image2d_isMutable(self, &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint8_t)result;
}

/* 0x303ad8  (IIII[B)V */
void M3G_ENTRY(Image2D_set)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int x = (int)Jbed_ParamPtr[1];
    int y = (int)Jbed_ParamPtr[2];
    int width = (int)Jbed_ParamPtr[3];
    int height = (int)Jbed_ParamPtr[4];
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[5], 'o');
    KniArray pixels = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 1, UINT32_MAX, &pixels.data, &pixels.count);
    if (ready && !image2d_set(self, x, y, width, height, pixels.count, pixels.data))
        ThrowSwerveAPIException();
    SWV_FreeArrayBytes(&roots[1], pixels.data);
    Jbed_nativeCallStateAdr = saved_roots;
}

void M3G_ENTRY(Image2D_setRGB)(void)
{
    SWV_Image2D_setRGB();
}

uint32_t M3G_ENTRY(Image2D_createImageImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Image2D_createPNG();
}
