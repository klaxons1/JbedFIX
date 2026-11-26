#include "kni.h"
#include "kni_targets.h"
#include "platform.h"

void M3G_ENTRY(Mesh_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

/* 0x3050fc  (Ljavax/microedition/m3g/VertexBuffer;[I[I)I */
uint32_t M3G_ENTRY(Mesh_createMultiSubmesh)(void)
{
    KNI_ROOTS(3);
    void *result = NULL;
    void *vertexBuffer = kni_peer(&roots[0], 1, swvBaseClassFIDs_Object3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[2], 'o');
    KniArray indices = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, UINT32_MAX, &indices.data, &indices.count);
    roots[2] = JbedKNI_VerifyObject(Jbed_ParamPtr[3], 'o');
    KniArray appearances = {0};
    ready = ready && SWV_GetArrayBytes(&roots[2], 4, UINT32_MAX, &appearances.data, &appearances.count);
    if (ready && !mesh_createMultiSubmesh(vertexBuffer, indices.count, indices.data, appearances.count, appearances.data, &result))
        ThrowSwerveAPIException();
    swvFree(indices.data);
    swvFree(appearances.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x305034  (Ljavax/microedition/m3g/VertexBuffer;Ljavax/microedition/m3g/IndexBuffer;Ljavax/microedition/m3g/Appearance;)I */
uint32_t M3G_ENTRY(Mesh_createSingleSubmesh)(void)
{
    KNI_ROOTS(3);
    void *vertexBuffer = kni_peer(&roots[0], 1, swvBaseClassFIDs_Object3D);
    void *indexBuffer = kni_peer(&roots[1], 2, swvBaseClassFIDs_Object3D);
    void *appearance = kni_peer(&roots[2], 3, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!mesh_createSingleSubmesh(vertexBuffer, indexBuffer, appearance, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

uint32_t M3G_ENTRY(Mesh_getSubmeshCount)(void)
{
    return (uint32_t)SWV_Getter_Integer(mesh_getSubmeshCount, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(Mesh_getVertexBufferImpl)(void)
{
    return (uint32_t)(uintptr_t)SWV_Getter_Handle(mesh_getVertexBuffer, swvBaseClassFIDs_Object3D);
}

/* 0x304f74  (I)I */
uint32_t M3G_ENTRY(Mesh_getIndexBufferImpl)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!mesh_getIndexBuffer(self, (int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x304ef4  (I)I */
uint32_t M3G_ENTRY(Mesh_getAppearanceImpl)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *result = NULL;
    if (!mesh_getAppearance(self, (int)Jbed_ParamPtr[1], &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x304e4c  (ILjavax/microedition/m3g/Appearance;)V */
void M3G_ENTRY(Mesh_setAppearanceImpl)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int index = (int)Jbed_ParamPtr[1];
    void *appearance = kni_peer(&roots[1], 2, swvBaseClassFIDs_Object3D);
    if (!mesh_setAppearance(self, index, appearance))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}
