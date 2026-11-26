#include "kni.h"
#include "kni_targets.h"
#include "platform.h"

void M3G_ENTRY(TriangleStripArray_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

/* 0x3083e8  (I[I)I */
uint32_t M3G_ENTRY(TriangleStripArray_createImplicit)(void)
{
    KNI_ROOTS(1);
    void *result = NULL;
    int firstIndex = (int)Jbed_ParamPtr[1];
    roots[0] = JbedKNI_VerifyObject(Jbed_ParamPtr[2], 'o');
    KniArray strips = {0};
    int ready = SWV_GetArrayBytes(&roots[0], 4, UINT32_MAX, &strips.data, &strips.count);
    if (ready && !trianglestriparray_createImplicit(firstIndex, strips.count, strips.data, &result))
        ThrowSwerveAPIException();
    swvFree(strips.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x3082fc  ([I[I)I */
uint32_t M3G_ENTRY(TriangleStripArray_createExplicit)(void)
{
    KNI_ROOTS(2);
    void *result = NULL;
    roots[0] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray indices = {0};
    int ready = SWV_GetArrayBytes(&roots[0], 4, UINT32_MAX, &indices.data, &indices.count);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[2], 'o');
    KniArray strips = {0};
    ready = ready && SWV_GetArrayBytes(&roots[1], 4, UINT32_MAX, &strips.data, &strips.count);
    if (ready && !trianglestriparray_createExplicit(indices.count, indices.data, strips.count, strips.data, &result))
        ThrowSwerveAPIException();
    swvFree(indices.data);
    swvFree(strips.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}
