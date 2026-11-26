#include "kni.h"
#include "kni_targets.h"

void M3G_ENTRY(Transform_finalize)(void)
{
    SWV_Finalize(swvBaseClassFIDs_Transform);
}

uint32_t M3G_ENTRY(Transform_create)(void)
{
    return (uint32_t)(uintptr_t)SWV_Constructor_HandleReturn(transform_create);
}

/* 0x3079e4  (Ljavax/microedition/m3g/Transform;)I */
uint32_t M3G_ENTRY(Transform_createCopy)(void)
{
    KNI_ROOTS(1);
    void *transform = kni_peer(&roots[0], 1, swvBaseClassFIDs_Transform);
    void *result = NULL;
    if (!transform_createCopy(transform, &result))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
    return (uint32_t)(uintptr_t)result;
}

/* 0x3078fc  ([F)V */
void M3G_ENTRY(Transform_get)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Transform);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray matrix = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, 16, &matrix.data, &matrix.count);
    if (ready) {
        if (transform_get(self, matrix.count, matrix.data)) {
            copy_back(&roots[1], 4, &matrix);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[1], matrix.data);
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307830  ([F)V */
void M3G_ENTRY(Transform_setMatrix)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Transform);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray matrix = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, 16, &matrix.data, &matrix.count);
    if (ready && !transform_setMatrix(self, matrix.count, matrix.data))
        ThrowSwerveAPIException();
    SWV_FreeArrayBytes(&roots[1], matrix.data);
    Jbed_nativeCallStateAdr = saved_roots;
}

void M3G_ENTRY(Transform_setTransform)(void)
{
    SWV_UnSafeMethod_Handle(transform_setTransform, swvBaseClassFIDs_Transform, swvBaseClassFIDs_Transform);
}

/* 0x3077d4  ()V */
void M3G_ENTRY(Transform_setIdentity)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Transform);
    transform_setIdentity(self);
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307768  ()V */
void M3G_ENTRY(Transform_invert)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Transform);
    if (!transform_invert(self))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

void M3G_ENTRY(Transform_postMultiply)(void)
{
    SWV_UnSafeMethod_Handle(transform_postMultiply, swvBaseClassFIDs_Transform, swvBaseClassFIDs_Transform);
}

/* 0x307698  (FFFF)V */
void M3G_ENTRY(Transform_postRotate)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Transform);
    float vector[] = {kni_float(1), kni_float(2), kni_float(3), kni_float(4)};
    if (!transform_postRotate(self, vector))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307610  (FFFF)V */
void M3G_ENTRY(Transform_postRotateQuat)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Transform);
    float vector[] = {kni_float(1), kni_float(2), kni_float(3), kni_float(4)};
    if (!transform_postRotateQuat(self, vector))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x30758c  (FFF)V */
void M3G_ENTRY(Transform_postScale)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Transform);
    float vector[] = {kni_float(1), kni_float(2), kni_float(3)};
    if (!transform_postScale(self, vector))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307508  (FFF)V */
void M3G_ENTRY(Transform_postTranslate)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Transform);
    float vector[] = {kni_float(1), kni_float(2), kni_float(3)};
    if (!transform_postTranslate(self, vector))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x3073f0  (Ljavax/microedition/m3g/VertexArray;[FZ)V */
void M3G_ENTRY(Transform_transform)(void)
{
    KNI_ROOTS(3);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Transform);
    void *vertexArray = kni_peer(&roots[1], 1, swvBaseClassFIDs_Object3D);
    roots[2] = JbedKNI_VerifyObject(Jbed_ParamPtr[2], 'o');
    KniArray points = {0};
    int ready = SWV_GetArrayBytes(&roots[2], 4, UINT32_MAX, &points.data, &points.count);
    if (ready) {
        if (transform_transform(self, vertexArray, points.count, points.data, (uint8_t)Jbed_ParamPtr[3])) {
            copy_back(&roots[2], 4, &points);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[2], points.data);
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307308  ([F)V */
void M3G_ENTRY(Transform_transformPoints)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Transform);
    roots[1] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    KniArray points = {0};
    int ready = SWV_GetArrayBytes(&roots[1], 4, UINT32_MAX, &points.data, &points.count);
    if (ready) {
        if (transform_transformPoints(self, points.count, points.data)) {
            copy_back(&roots[1], 4, &points);
        } else {
            ThrowSwerveAPIException();
        }
    }
    SWV_FreeArrayBytes(&roots[1], points.data);
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x3072ac  ()V */
void M3G_ENTRY(Transform_transpose)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Transform);
    transform_transpose(self);
    Jbed_nativeCallStateAdr = saved_roots;
}
