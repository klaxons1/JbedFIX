#include "kni.h"
#include "kni_targets.h"
#include "platform.h"

void M3G_ENTRY(SkinnedMesh_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

/* 0x306ad0  (Ljavax/microedition/m3g/VertexBuffer;[I[ILjavax/microedition/m3g/Group;)I */
uint32_t M3G_ENTRY(SkinnedMesh_createMultiSubmesh)(void)
{
    KNI_ROOTS(4);
    void *result = NULL;
    void *vertexBuffer = kni_peer(&roots[0], 1, swvBaseClassFIDs_Object3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[2], 'o');
    KniArray indices = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, UINT32_MAX, &indices.data, &indices.count);
    roots[2] = JbedKNI_VerifyObject(Jbed_ParamPtr[3], 'o');
    KniArray appearances = {0};
    ready = ready && SWV_GetArrayBytes(&roots[2], 4, UINT32_MAX, &appearances.data, &appearances.count);
    void *group = kni_peer(&roots[3], 4, swvBaseClassFIDs_Object3D);
    if (ready && !skinnedmesh_createMultiSubmesh(vertexBuffer, indices.count, indices.data, appearances.count, appearances.data, group, &result))
        ThrowSwerveAPIException();
    swvFree(indices.data);
    swvFree(appearances.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x3069e8  (Ljavax/microedition/m3g/VertexBuffer;Ljavax/microedition/m3g/IndexBuffer;Ljavax/microedition/m3g/Appearance;Ljavax/microedition/m3g/Group;)I */
uint32_t M3G_ENTRY(SkinnedMesh_createSingleSubmesh)(void)
{
    KNI_ROOTS(4);
    void *vertexBuffer = kni_peer(&roots[0], 1, swvBaseClassFIDs_Object3D);
    void *indexBuffer = kni_peer(&roots[1], 2, swvBaseClassFIDs_Object3D);
    void *appearance = kni_peer(&roots[2], 3, swvBaseClassFIDs_Object3D);
    void *group = kni_peer(&roots[3], 4, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!skinnedmesh_createSingleSubmesh(vertexBuffer, indexBuffer, appearance, group, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

uint32_t M3G_ENTRY(SkinnedMesh_getSkeletonImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(skinnedmesh_getSkeleton, swvBaseClassFIDs_Object3D);
}

/* 0x306918  (Ljavax/microedition/m3g/Node;III)V */
void M3G_ENTRY(SkinnedMesh_addTransformImpl)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *node = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    if (!skinnedmesh_addTransform(self, node, (int)Jbed_ParamPtr[2], (int)Jbed_ParamPtr[3], (int)Jbed_ParamPtr[4]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x3066ec  (Ljavax/microedition/m3g/Node;Ljavax/microedition/m3g/Transform;)V */
void M3G_ENTRY(SkinnedMesh_getBoneTransform)(void)
{
    KNI_ROOTS(3);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *node = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    void *transform = kni_peer(&roots[2], 2, swvBaseClassFIDs_Transform);
    if (!skinnedmesh_getBoneTransform(self, node, transform))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x3067b0  (Ljavax/microedition/m3g/Node;[I[F)I */
uint32_t M3G_ENTRY(SkinnedMesh_getBoneVertices)(void)
{
    KNI_ROOTS(4);
    int result = 0;
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *node = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    roots[2] = JbedKNI_VerifyObject(Jbed_ParamPtr[2], 'o');
    KniArray indices = {0};
    int ready = SWV_GetArrayBytes(&roots[2], 4, UINT32_MAX, &indices.data, &indices.count);
    roots[3] = JbedKNI_VerifyObject(Jbed_ParamPtr[3], 'o');
    KniArray weights = {0};
    ready = ready && SWV_GetArrayBytes(&roots[3], 4, UINT32_MAX, &weights.data, &weights.count);
    if (ready) {
        if (skinnedmesh_getBoneVertices(self, node, indices.count, indices.data, weights.count, weights.data, &result)) {
            copy_back(&roots[2], 4, &indices);
            copy_back(&roots[3], 4, &weights);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[2], indices.data);
    SWV_FreeArrayBytes(&roots[3], weights.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}
