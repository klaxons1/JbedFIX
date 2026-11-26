#include "kni.h"
#include "kni_targets.h"
#include "platform.h"

void M3G_ENTRY(MorphingMesh_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

/* 0x3055a4  (Ljavax/microedition/m3g/VertexBuffer;[I[I[I)I */
uint32_t M3G_ENTRY(MorphingMesh_createMultiSubmesh)(void)
{
    KNI_ROOTS(4);
    void *result = NULL;
    void *vertexBuffer = kni_peer(&roots[0], 1, swvBaseClassFIDs_Object3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[2], 'o');
    KniArray targets = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, UINT32_MAX, &targets.data, &targets.count);
    roots[2] = JbedKNI_VerifyObject(Jbed_ParamPtr[3], 'o');
    KniArray indices = {0};
    ready = ready && SWV_GetArrayBytes(&roots[2], 4, UINT32_MAX, &indices.data, &indices.count);
    roots[3] = JbedKNI_VerifyObject(Jbed_ParamPtr[4], 'o');
    KniArray appearances = {0};
    ready = ready && SWV_GetArrayBytes(&roots[3], 4, UINT32_MAX, &appearances.data, &appearances.count);
    if (ready && !morphingmesh_createMultiSubmesh(vertexBuffer, targets.count, targets.data, indices.count, indices.data, appearances.count, appearances.data, &result))
        ThrowSwerveAPIException();
    swvFree(targets.data);
    swvFree(indices.data);
    swvFree(appearances.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x305484  (Ljavax/microedition/m3g/VertexBuffer;[ILjavax/microedition/m3g/IndexBuffer;Ljavax/microedition/m3g/Appearance;)I */
uint32_t M3G_ENTRY(MorphingMesh_createSingleSubmesh)(void)
{
    KNI_ROOTS(4);
    void *result = NULL;
    void *vertexBuffer = kni_peer(&roots[0], 1, swvBaseClassFIDs_Object3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[2], 'o');
    KniArray targets = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, UINT32_MAX, &targets.data, &targets.count);
    void *indexBuffer = kni_peer(&roots[2], 3, swvBaseClassFIDs_Object3D);
    void *appearance = kni_peer(&roots[3], 4, swvBaseClassFIDs_Object3D);
    if (ready && !morphingmesh_createSingleSubmesh(vertexBuffer, targets.count, targets.data, indexBuffer, appearance, &result))
        ThrowSwerveAPIException();
    swvFree(targets.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

uint32_t M3G_ENTRY(MorphingMesh_getMorphTargetCount)(void)
{
    return (uint32_t)SWV_Getter_Integer(morphingmesh_getMorphTargetCount, swvBaseClassFIDs_Object3D);
}

/* 0x3053e4  (I)I */
uint32_t M3G_ENTRY(MorphingMesh_getMorphTargetImpl)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!morphingmesh_getMorphTarget(self, (int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x3052fc  ([F)V */
void M3G_ENTRY(MorphingMesh_getWeights)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray weights = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, UINT32_MAX, &weights.data, &weights.count);
    if (ready) {
        if (morphingmesh_getWeights(self, weights.count, weights.data)) {
            copy_back(&roots[1], 4, &weights);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[1], weights.data);
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x30522c  ([F)V */
void M3G_ENTRY(MorphingMesh_setWeights)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray weights = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, UINT32_MAX, &weights.data, &weights.count);
    if (ready && !morphingmesh_setWeights(self, weights.count, weights.data))
        ThrowSwerveAPIException();
    SWV_FreeArrayBytes(&roots[1], weights.data);
    Jbed_nativeCallStateAdr = saved_roots;
}
