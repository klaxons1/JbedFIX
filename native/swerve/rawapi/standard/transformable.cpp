#include "object_classes.hpp"
#include "cssquaternion.hpp"
#include "cssfixed1616.hpp"
#include "kni_targets.h"

static CssTransformable *transformable(void *handle)
{
    return static_cast<CssTransformable *>(static_cast<CssRefCount *>(handle));
}

void transformable_getTranslation(void *self, float *v)
{
    auto *object = transformable(self);
    memcpy(v, &object->state->translation, sizeof(CssVector3D));
}

void transformable_getScale(void *self, float *v)
{
    auto *object = transformable(self);
    memcpy(v, &object->state->scale, sizeof(CssVector3D));
}

void transformable_getOrientation(void *self, float *v)
{
    auto *object = transformable(self);
    float angle;
    CssVector3D axis;
    object->state->orientation.GetAxisAndAngle(&axis, &angle);
    memcpy(v + 1, &axis, sizeof axis);
    v[0] = angle * degreesPerRadian;
}

int transformable_setScale(void *self, const float *input)
{
    SWV_BEGIN_API(frame);
    CssVector3D v{g_ValidateFloat(input[0]), g_ValidateFloat(input[1]), g_ValidateFloat(input[2])};
    transformable(self)->SetScale(v);
    CssTrapHandler::UnTrap();
    return 1;
}

int transformable_scale(void *self, const float *input)
{
    SWV_BEGIN_API(frame);
    CssVector3D v{g_ValidateFloat(input[0]), g_ValidateFloat(input[1]), g_ValidateFloat(input[2])};
    transformable(self)->Scale(v);
    CssTrapHandler::UnTrap();
    return 1;
}

int transformable_setTranslation(void *self, const float *input)
{
    SWV_BEGIN_API(frame);
    CssVector3D v{g_ValidateFloat(input[0]), g_ValidateFloat(input[1]), g_ValidateFloat(input[2])};
    transformable(self)->SetTranslation(v);
    CssTrapHandler::UnTrap();
    return 1;
}

int transformable_translate(void *self, const float *input)
{
    SWV_BEGIN_API(frame);
    CssVector3D v{g_ValidateFloat(input[0]), g_ValidateFloat(input[1]), g_ValidateFloat(input[2])};
    transformable(self)->Translate(v);
    CssTrapHandler::UnTrap();
    return 1;
}

int transformable_setOrientation(void *self, const float *input)
{
    SWV_BEGIN_API(frame);
    transformable(self)->SetOrientation(readAxisAngle(input));
    CssTrapHandler::UnTrap();
    return 1;
}

int transformable_preRotate(void *self, const float *input)
{
    SWV_BEGIN_API(frame);
    transformable(self)->PreRotate(readAxisAngle(input));
    CssTrapHandler::UnTrap();
    return 1;
}

int transformable_postRotate(void *self, const float *input)
{
    SWV_BEGIN_API(frame);
    transformable(self)->PostRotate(readAxisAngle(input));
    CssTrapHandler::UnTrap();
    return 1;
}

int transformable_getTransform(void *self, void *handle)
{
    SWV_BEGIN_API(frame);
    if (!handle)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    transformable(self)->GetTransform(static_cast<CssTransform *>(static_cast<CssRefCount *>(handle)));
    CssTrapHandler::UnTrap();
    return 1;
}

int transformable_getCompositeTransform(void *self, void *handle)
{
    SWV_BEGIN_API(frame);
    if (!handle)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    transformable(self)->GetCompositeTransform(static_cast<CssTransform *>(static_cast<CssRefCount *>(handle)));
    CssTrapHandler::UnTrap();
    return 1;
}

int transformable_setTransform(void *self, void *handle)
{
    SWV_BEGIN_API(frame);
    transformable(self)->SetTransform(static_cast<CssTransform *>(static_cast<CssRefCount *>(handle)));
    CssTrapHandler::UnTrap();
    return 1;
}
