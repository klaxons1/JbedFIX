#include "kni.h"
#include "kni_targets.h"

/* 0x303fd0  ()I */
uint32_t M3G_ENTRY(IndexBuffer_getIndexCountImpl)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int result = 0;
    indexbuffer_getIndexCount(self, &result);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

/* 0x303ee8  ([I)V */
void M3G_ENTRY(IndexBuffer_getIndicesImpl)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray indices = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, UINT32_MAX, &indices.data, &indices.count);
    if (ready) {
        if (indexbuffer_getIndices(self, indices.count, indices.data)) {
            copy_back(&roots[1], 4, &indices);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[1], indices.data);
    Jbed_nativeCallStateAdr = saved_roots;
}
