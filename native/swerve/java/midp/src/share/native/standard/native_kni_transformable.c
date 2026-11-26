#include "kni.h"
#include "kni_targets.h"

static void get_transform_vector(void (*get)(void *, float *), int count)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[1], 0, swvBaseClassFIDs_Object3D);
    float vector[4];
    get(self, vector);
    roots[0] = JbedKNI_VerifyObject(Jbed_ParamPtr[1], 'o');
    if (roots[0]) {
        JbArray *array = (JbArray *)(uintptr_t)JbedKNI_VerifyObject(roots[0], 'A');
        if (array->length >= count)
            SWV_SetArrayBytes(&roots[0], count * sizeof(float), vector, 1);
        else if (JbedKNI_ThrowNew("java/lang/IllegalArgumentException", JbedKNI_NewUtfString("", 0)) == -1)
            JbedKNI_FatalError("Failed to throw illegal argument exception");
    } else if (JbedKNI_ThrowNew("java/lang/NullPointerException", JbedKNI_NewUtfString("", 0)) == -1) {
        JbedKNI_FatalError("Failed to throw null pointer exception");
    }
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x3081dc  ([F)V */
void M3G_ENTRY(Transformable_getTranslation)(void)
{
    get_transform_vector(transformable_getTranslation, 3);
}

/* 0x3080bc  ([F)V */
void M3G_ENTRY(Transformable_getScale)(void)
{
    get_transform_vector(transformable_getScale, 3);
}

/* 0x307fa0  ([F)V */
void M3G_ENTRY(Transformable_getOrientation)(void)
{
    get_transform_vector(transformable_getOrientation, 4);
}

/* 0x307f1c  (FFF)V */
void M3G_ENTRY(Transformable_setTranslation)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    float vector[] = {kni_float(1), kni_float(2), kni_float(3)};
    if (!transformable_setTranslation(self, vector))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307e98  (FFF)V */
void M3G_ENTRY(Transformable_setScale)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    float vector[] = {kni_float(1), kni_float(2), kni_float(3)};
    if (!transformable_setScale(self, vector))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307e10  (FFFF)V */
void M3G_ENTRY(Transformable_setOrientation)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    float vector[] = {kni_float(1), kni_float(2), kni_float(3), kni_float(4)};
    if (!transformable_setOrientation(self, vector))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307d8c  (FFF)V */
void M3G_ENTRY(Transformable_translate)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    float vector[] = {kni_float(1), kni_float(2), kni_float(3)};
    if (!transformable_translate(self, vector))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307d08  (FFF)V */
void M3G_ENTRY(Transformable_scale)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    float vector[] = {kni_float(1), kni_float(2), kni_float(3)};
    if (!transformable_scale(self, vector))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307c80  (FFFF)V */
void M3G_ENTRY(Transformable_preRotate)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    float vector[] = {kni_float(1), kni_float(2), kni_float(3), kni_float(4)};
    if (!transformable_preRotate(self, vector))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307bf8  (FFFF)V */
void M3G_ENTRY(Transformable_postRotate)(void)
{
    KNI_ROOTS(1);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    float vector[] = {kni_float(1), kni_float(2), kni_float(3), kni_float(4)};
    if (!transformable_postRotate(self, vector))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307b54  (Ljavax/microedition/m3g/Transform;)V */
void M3G_ENTRY(Transformable_getTransform)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *transform = kni_peer(&roots[1], 1, swvBaseClassFIDs_Transform);
    if (!transformable_getTransform(self, transform))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

/* 0x307ab0  (Ljavax/microedition/m3g/Transform;)V */
void M3G_ENTRY(Transformable_getCompositeTransform)(void)
{
    KNI_ROOTS(2);
    void *self = kni_peer(&roots[0], 0, swvBaseClassFIDs_Object3D);
    void *transform = kni_peer(&roots[1], 1, swvBaseClassFIDs_Transform);
    if (!transformable_getCompositeTransform(self, transform))
        ThrowSwerveAPIException();
    Jbed_nativeCallStateAdr = saved_roots;
}

void M3G_ENTRY(Transformable_setTransform)(void)
{
    SWV_UnSafeMethod_Handle(transformable_setTransform, swvBaseClassFIDs_Object3D, swvBaseClassFIDs_Transform);
}
