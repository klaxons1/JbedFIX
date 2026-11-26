#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(Graphics3D_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Graphics3D);
}

/* 0x3036e4  ()I */
uint32_t M3G_ENTRY(Graphics3D_createImpl)(void)
{
    void *result = NULL;
    if (!graphics3d_create(&result))
        ThrowSwerveAPIException();
    return (uint32_t)(uintptr_t)result;
}

/* 0x303640  (Ljavax/microedition/m3g/Image2D;)V */
void M3G_ENTRY(Graphics3D_setBackBufferImage2D)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    void *image2D = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    if (!graphics3d_setBackBufferImage2D(self, image2D))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x3035c4  (ZI)V */
void M3G_ENTRY(Graphics3D_setHints)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    if (!graphics3d_setHints(self, (uint8_t)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

void M3G_ENTRY(Graphics3D_bindTargetGraphics)(void)
{
    SWV_BindTargetGraphics();
}

void M3G_ENTRY(Graphics3D_releaseTargetGraphics)(void)
{
    SWV_ReleaseTargetGraphics();
}

/* 0x3034e4  (IIII)V */
void M3G_ENTRY(Graphics3D_setViewportImpl)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    int x = (int)Jbed_ParamPtr[1];
    int y = (int)Jbed_ParamPtr[2];
    int width = (int)Jbed_ParamPtr[3];
    int height = (int)Jbed_ParamPtr[4];
    SWV_BindTargetCritical(&roots[0], self);
    if (!graphics3d_setViewport(self, x, y, width, height))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x303468  (FF)V */
void M3G_ENTRY(Graphics3D_setDepthRange)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    if (!graphics3d_setDepthRange(self, kni_float(1), kni_float(2)))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x3033b0  (Ljavax/microedition/m3g/Background;)V */
void M3G_ENTRY(Graphics3D_clearImpl)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    void *background = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    SWV_BindTargetCritical(&roots[0], self);
    if (!graphics3d_clear(self, background))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x303294  (Ljavax/microedition/m3g/VertexBuffer;Ljavax/microedition/m3g/IndexBuffer;Ljavax/microedition/m3g/Appearance;Ljavax/microedition/m3g/Transform;I)V */
void M3G_ENTRY(Graphics3D_renderPrimitive)(void)
{
    KNI_ROOTS(5);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    void *vertexBuffer = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    void *indexBuffer = kni_peer(&roots[2], 2, swvBaseClassFIDs_Object3D);
    void *appearance = kni_peer(&roots[3], 3, swvBaseClassFIDs_Object3D);
    void *transform = kni_peer(&roots[4], 4, swvBaseClassFIDs_Transform);
    int scope = (int)Jbed_ParamPtr[5];
    SWV_BindTargetCritical(&roots[0], self);
    if (!graphics3d_renderPrimitive(self, vertexBuffer, indexBuffer, appearance, transform, scope))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x3031c0  (Ljavax/microedition/m3g/Node;Ljavax/microedition/m3g/Transform;)V */
void M3G_ENTRY(Graphics3D_renderNode)(void)
{
    KNI_ROOTS(3);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    void *node = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    void *transform = kni_peer(&roots[2], 2, swvBaseClassFIDs_Transform);
    SWV_BindTargetCritical(&roots[0], self);
    if (!graphics3d_renderNode(self, node, transform))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x303108  (Ljavax/microedition/m3g/World;)V */
void M3G_ENTRY(Graphics3D_renderWorld)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    void *world = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    SWV_BindTargetCritical(&roots[0], self);
    if (!graphics3d_renderWorld(self, world))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x302ce8  ()V */
void M3G_ENTRY(Graphics3D_resetLights)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    if (!graphics3d_resetLights(self))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x302cac  (I)I */
uint32_t M3G_ENTRY(Graphics3D_getCapability)(void)
{
    int result = 0;
    if (!graphics3d_getCapability((int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    return (uint32_t)result;
}

/* 0x302d54  (Ljavax/microedition/m3g/Light;Ljavax/microedition/m3g/Transform;)I */
uint32_t M3G_ENTRY(Graphics3D_addLightImpl)(void)
{
    KNI_ROOTS(3);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    void *light = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    void *transform = kni_peer(&roots[2], 2, swvBaseClassFIDs_Transform);
    int result = 0;
    if (!graphics3d_addLight(self, light, transform, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x30305c  (Ljavax/microedition/m3g/Transform;)I */
uint32_t M3G_ENTRY(Graphics3D_getCameraImpl)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    void *transform = kni_peer(&roots[1], 1, swvBaseClassFIDs_Transform);
    void *result = NULL;
    if (!graphics3d_getCamera(self, transform, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

uint32_t M3G_ENTRY(Graphics3D_getDepthRangeFar)(void)
{
    return (uint32_t)SWV_Getter_Float(graphics3d_getDepthRangeFar, swvBaseClassFIDs_Graphics3D);
}

uint32_t M3G_ENTRY(Graphics3D_getDepthRangeNear)(void)
{
    return (uint32_t)SWV_Getter_Float(graphics3d_getDepthRangeNear, swvBaseClassFIDs_Graphics3D);
}

uint32_t M3G_ENTRY(Graphics3D_getHints)(void)
{
    return (uint32_t)SWV_Getter_Integer(graphics3d_getHints, swvBaseClassFIDs_Graphics3D);
}

uint32_t M3G_ENTRY(Graphics3D_getLightCount)(void)
{
    return (uint32_t)SWV_Getter_Integer(graphics3d_getLightCount, swvBaseClassFIDs_Graphics3D);
}

/* 0x302e1c  (ILjavax/microedition/m3g/Transform;)I */
uint32_t M3G_ENTRY(Graphics3D_getLightImpl)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    int index = (int)Jbed_ParamPtr[1];
    void *transform = kni_peer(&roots[1], 2, swvBaseClassFIDs_Transform);
    void *result = NULL;
    if (!graphics3d_getLight(self, index, transform, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

uint32_t M3G_ENTRY(Graphics3D_isDepthBufferEnabled)(void)
{
    return (uint32_t)SWV_Getter_Boolean(graphics3d_isDepthBufferEnabled, swvBaseClassFIDs_Graphics3D);
}

/* 0x302f98  (Ljavax/microedition/m3g/Camera;Ljavax/microedition/m3g/Transform;)V */
void M3G_ENTRY(Graphics3D_setCameraImpl)(void)
{
    KNI_ROOTS(3);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    void *camera = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    void *transform = kni_peer(&roots[2], 2, swvBaseClassFIDs_Transform);
    if (!graphics3d_setCamera(self, camera, transform))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x302ecc  (ILjavax/microedition/m3g/Light;Ljavax/microedition/m3g/Transform;)V */
void M3G_ENTRY(Graphics3D_setLightImpl)(void)
{
    KNI_ROOTS(3);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Graphics3D);
    int index = (int)Jbed_ParamPtr[1];
    void *light = kni_peer(&roots[1], 2, swvBaseClassFIDs_Object3D);
    void *transform = kni_peer(&roots[2], 3, swvBaseClassFIDs_Transform);
    if (!graphics3d_setLight(self, index, light, transform))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}
