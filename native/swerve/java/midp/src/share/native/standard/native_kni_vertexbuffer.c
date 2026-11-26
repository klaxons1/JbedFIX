#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(VertexBuffer_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(VertexBuffer_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(vertexbuffer_create);
}

uint32_t M3G_ENTRY(VertexBuffer_getNormalsImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(vertexbuffer_getNormals, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(VertexBuffer_getColorsImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(vertexbuffer_getColors, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(VertexBuffer_getDefaultColor)(void)
{
    return (uint32_t)SWV_Getter_Integer(vertexbuffer_getDefaultColor, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(VertexBuffer_getVertexCount)(void)
{
    return (uint32_t)SWV_Getter_Integer(vertexbuffer_getVertexCount, swvBaseClassFIDs_Object3D);
}

/* 0x308db8  (Ljavax/microedition/m3g/VertexArray;)V */
void M3G_ENTRY(VertexBuffer_setNormalsImpl)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[1], 0, swvBaseClassFIDs_Object3D);
    void *vertexArray = kni_peer(&roots[0], 1, swvBaseClassFIDs_Object3D);
    if (!vertexbuffer_setNormals(self, vertexArray))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x308d10  (Ljavax/microedition/m3g/VertexArray;)V */
void M3G_ENTRY(VertexBuffer_setColorsImpl)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[1], 0, swvBaseClassFIDs_Object3D);
    void *vertexArray = kni_peer(&roots[0], 1, swvBaseClassFIDs_Object3D);
    if (!vertexbuffer_setColors(self, vertexArray))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

void M3G_ENTRY(VertexBuffer_setDefaultColor)(void)
{
    SWV_Setter_Integer(vertexbuffer_setDefaultColor, swvBaseClassFIDs_Object3D);
}

/* 0x308c04  ([F)I */
uint32_t M3G_ENTRY(VertexBuffer_getPositionsImpl)(void)
{
    KNI_ROOTS(2);
    void *result = NULL;
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray scale_bias = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, 4, &scale_bias.data, &scale_bias.count);
    if (ready) {
        if (vertexbuffer_getPositions(self, scale_bias.count, scale_bias.data, &result)) {
            copy_back(&roots[1], 4, &scale_bias);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[1], scale_bias.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x308b0c  (Ljavax/microedition/m3g/VertexArray;F[F)V */
void M3G_ENTRY(VertexBuffer_setPositionsImpl)(void)
{
    KNI_ROOTS(3);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *vertexArray = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    float scale = kni_float(2);
    roots[2] = JbedKNI_VerifyObject(Jbed_ParamPtr[3], 'o');
    KniArray bias = {0};
    int ready = SWV_GetArrayBytes(&roots[2], 4, 3, &bias.data, &bias.count);
    if (ready && !vertexbuffer_setPositions(self, vertexArray, scale, bias.count, bias.data))
        ThrowSwerveAPIException();
    SWV_FreeArrayBytes(&roots[2], bias.data);
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x308a14  (I[F)I */
uint32_t M3G_ENTRY(VertexBuffer_getTexCoordsImpl)(void)
{
    KNI_ROOTS(2);
    void *result = NULL;
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int index = (int)Jbed_ParamPtr[1];
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[2], 'o');
    KniArray scale_bias = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, 4, &scale_bias.data, &scale_bias.count);
    if (ready) {
        if (vertexbuffer_getTexCoords(self, index, scale_bias.count, scale_bias.data, &result)) {
            copy_back(&roots[1], 4, &scale_bias);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[1], scale_bias.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x308914  (ILjavax/microedition/m3g/VertexArray;F[F)V */
void M3G_ENTRY(VertexBuffer_setTexCoordsImpl)(void)
{
    KNI_ROOTS(3);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int index = (int)Jbed_ParamPtr[1];
    void *vertexArray = kni_peer(&roots[1], 2, swvBaseClassFIDs_Object3D);
    float scale = kni_float(3);
    roots[2] = JbedKNI_VerifyObject(Jbed_ParamPtr[4], 'o');
    KniArray bias = {0};
    int ready = SWV_GetArrayBytes(&roots[2], 4, 3, &bias.data, &bias.count);
    if (ready && !vertexbuffer_setTexCoords(self, index, vertexArray, scale, bias.count, bias.data))
        ThrowSwerveAPIException();
    SWV_FreeArrayBytes(&roots[2], bias.data);
    Jbed_nativeCallStateAdr = saved_roots;
}
