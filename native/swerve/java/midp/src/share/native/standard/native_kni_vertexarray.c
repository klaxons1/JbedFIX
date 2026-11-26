#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(VertexArray_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

/* 0x3088bc  (III)I */
uint32_t M3G_ENTRY(VertexArray_create)(void)
{
    void *result = NULL;
    if (!vertexarray_create((int)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2], (int)Jbed_ParamPtr[3], &result))
        ThrowSwerveAPIException();
    return (uint32_t)(uintptr_t)result;
}

/* 0x308680  (II[S)V */
void M3G_ENTRY(VertexArray_set16)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int firstVertex = (int)Jbed_ParamPtr[1];
    int numVertices = (int)Jbed_ParamPtr[2];
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[3], 'o');
    KniArray values = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 2, UINT32_MAX, &values.data, &values.count);
    if (ready && !vertexarray_set16(self, firstVertex, numVertices, values.count, values.data))
        ThrowSwerveAPIException();
    SWV_FreeArrayBytes(&roots[1], values.data);
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x3084a4  (II[B)V */
void M3G_ENTRY(VertexArray_set8)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int firstVertex = (int)Jbed_ParamPtr[1];
    int numVertices = (int)Jbed_ParamPtr[2];
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[3], 'o');
    KniArray values = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 1, UINT32_MAX, &values.data, &values.count);
    if (ready && !vertexarray_set8(self, firstVertex, numVertices, values.count, values.data))
        ThrowSwerveAPIException();
    SWV_FreeArrayBytes(&roots[1], values.data);
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x308760  (II[S)V */
void M3G_ENTRY(VertexArray_get16)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int firstVertex = (int)Jbed_ParamPtr[1];
    int numVertices = (int)Jbed_ParamPtr[2];
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[3], 'o');
    KniArray values = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 2, UINT32_MAX, &values.data, &values.count);
    if (ready) {
        if (vertexarray_get16(self, firstVertex, numVertices, values.count, values.data)) {
            copy_back(&roots[1], 2, &values);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[1], values.data);
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x308584  (II[B)V */
void M3G_ENTRY(VertexArray_get8)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int firstVertex = (int)Jbed_ParamPtr[1];
    int numVertices = (int)Jbed_ParamPtr[2];
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[3], 'o');
    KniArray values = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 1, UINT32_MAX, &values.data, &values.count);
    if (ready) {
        if (vertexarray_get8(self, firstVertex, numVertices, values.count, values.data)) {
            copy_back(&roots[1], 1, &values);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[1], values.data);
    Jbed_nativeCallStateAdr = saved_roots;
}

uint32_t M3G_ENTRY(VertexArray_getComponentCount)(void)
{
    return (uint32_t)SWV_Getter_Integer(vertexarray_getComponentCount, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(VertexArray_getComponentType)(void)
{
    return (uint32_t)SWV_Getter_Integer(vertexarray_getComponentType, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(VertexArray_getVertexCount)(void)
{
    return (uint32_t)SWV_Getter_Integer(vertexarray_getVertexCount, swvBaseClassFIDs_Object3D);
}
