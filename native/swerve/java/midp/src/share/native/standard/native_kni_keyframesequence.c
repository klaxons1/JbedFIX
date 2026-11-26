#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(KeyframeSequence_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Object3D);
}

/* 0x3043a8  (III)I */
uint32_t M3G_ENTRY(KeyframeSequence_create)(void)
{
    void *result = NULL;
    if (!keyframesequence_create((int)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2], (int)Jbed_ParamPtr[3], &result))
        ThrowSwerveAPIException();
    return (uint32_t)(uintptr_t)result;
}

uint32_t M3G_ENTRY(KeyframeSequence_getDuration)(void)
{
    return (uint32_t)SWV_Getter_Integer(keyframesequence_getDuration, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(KeyframeSequence_getRepeatMode)(void)
{
    return (uint32_t)SWV_Getter_Integer(keyframesequence_getRepeatMode, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(KeyframeSequence_setDuration)(void)
{
    SWV_UnSafeSetter_Integer(keyframesequence_setDuration, swvBaseClassFIDs_Object3D);
}

void M3G_ENTRY(KeyframeSequence_setRepeatMode)(void)
{
    SWV_UnSafeSetter_Integer(keyframesequence_setRepeatMode, swvBaseClassFIDs_Object3D);
}

/* 0x3040ac  (II[F)V */
void M3G_ENTRY(KeyframeSequence_setKeyframe)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int index = (int)Jbed_ParamPtr[1];
    int time = (int)Jbed_ParamPtr[2];
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[3], 'o');
    KniArray values = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, UINT32_MAX, &values.data, &values.count);
    if (ready && !keyframesequence_setKeyframe(self, index, time, values.count, values.data))
        ThrowSwerveAPIException();
    SWV_FreeArrayBytes(&roots[1], values.data);
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x304030  (II)V */
void M3G_ENTRY(KeyframeSequence_setValidRange)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    if (!keyframesequence_setValidRange(self, (int)Jbed_ParamPtr[1], (int)Jbed_ParamPtr[2]))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

uint32_t M3G_ENTRY(KeyframeSequence_getComponentCount)(void)
{
    return (uint32_t)SWV_Getter_Integer(keyframesequence_getComponentCount, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(KeyframeSequence_getInterpolationType)(void)
{
    return (uint32_t)SWV_Getter_Integer(keyframesequence_getInterpolationType, swvBaseClassFIDs_Object3D);
}

/* 0x30418c  (I[F)I */
uint32_t M3G_ENTRY(KeyframeSequence_getKeyframe)(void)
{
    KNI_ROOTS(2);
    int result = 0;
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    int index = (int)Jbed_ParamPtr[1];
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[2], 'o');
    KniArray values = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, UINT32_MAX, &values.data, &values.count);
    if (ready) {
        if (keyframesequence_getKeyframe(self, index, values.count, values.data, &result)) {
            copy_back(&roots[1], 4, &values);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[1], values.data);
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)result;
}

uint32_t M3G_ENTRY(KeyframeSequence_getKeyframeCount)(void)
{
    return (uint32_t)SWV_Getter_Integer(keyframesequence_getKeyframeCount, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(KeyframeSequence_getValidRangeFirst)(void)
{
    return (uint32_t)SWV_Getter_Integer(keyframesequence_getValidRangeFirst, swvBaseClassFIDs_Object3D);
}

uint32_t M3G_ENTRY(KeyframeSequence_getValidRangeLast)(void)
{
    return (uint32_t)SWV_Getter_Integer(keyframesequence_getValidRangeLast, swvBaseClassFIDs_Object3D);
}
