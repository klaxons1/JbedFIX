#include "cssobjectfactory.hpp"
#include "engine.h"
#include "object_classes.hpp"
#include "cssquaternion.hpp"
#include "geometry_class.hpp"
#include "cssfixed1616.hpp"
#include "kni_targets.h"
#include <string.h>

static CssTransform *transform(void *handle)
{
    return static_cast<CssTransform *>(static_cast<CssRefCount *>(handle));
}

CssQuaternion readAxisAngle(const float *values)
{
    float radians = g_ValidateFloat(values[0]) * radiansPerDegree;
    CssVector3D axis{g_ValidateFloat(values[1]), g_ValidateFloat(values[2]), g_ValidateFloat(values[3])};
    if (radians != 0 && axis[0] == 0 && axis[1] == 0 && axis[2] == 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    return CssQuaternion(radians, axis);
}

int transform_create(void **result)
{
    SWV_BEGIN_API(frame);
    *result = swv_retain_handle(static_cast<CssRefCount *>(CssObjectFactory::CreateObject(TransformObject)));
    CssTrapHandler::UnTrap();
    return 1;
}

int transform_createCopy(void *source, void **result)
{
    SWV_BEGIN_API(frame);
    if (!source)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *copy = static_cast<CssTransform *>(CssObjectFactory::CreateObject(TransformObject));
    CssCleanupStackManager::Push(copy);
    copy->Construct(transform(source));
    CssCleanupStackManager::Pop(copy);
    *result = swv_retain_handle(static_cast<CssRefCount *>(copy));
    CssTrapHandler::UnTrap();
    return 1;
}

int transform_get(void *self, int count, float *out)
{
    SWV_BEGIN_API(frame);
    if (!out)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    transform(self)->Get(count, out);
    CssTrapHandler::UnTrap();
    return 1;
}

int transform_setMatrix(void *self, int count, const float *in)
{
    SWV_BEGIN_API(frame);
    if (!in)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    transform(self)->Set(count, in);
    CssTrapHandler::UnTrap();
    return 1;
}

int transform_setTransform(void *self, void *source)
{
    SWV_BEGIN_API(frame);
    if (!source)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    transform(self)->Set(transform(source));
    CssTrapHandler::UnTrap();
    return 1;
}

void transform_setIdentity(void *self)
{
    transform(self)->SetIdentity();
}

int transform_invert(void *self)
{
    SWV_BEGIN_API(frame);
    transform(self)->Invert();
    CssTrapHandler::UnTrap();
    return 1;
}

int transform_postMultiply(void *self, void *right)
{
    SWV_BEGIN_API(frame);
    if (!right)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    transform(self)->PostMultiply(transform(right));
    CssTrapHandler::UnTrap();
    return 1;
}

int transform_postRotate(void *self, const float *rotation)
{
    SWV_BEGIN_API(frame);
    transform(self)->PostRotate(readAxisAngle(rotation));
    CssTrapHandler::UnTrap();
    return 1;
}

int transform_postRotateQuat(void *self, const float *rotation)
{
    SWV_BEGIN_API(frame);
    float q[4];
    q[3] = g_ValidateFloat(rotation[3]);
    for (int i = 0; i < 3; ++i)
        q[i] = g_ValidateFloat(rotation[i]);
    if (q[3] == 0 && q[0] == 0 && q[1] == 0 && q[2] == 0)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    transform(self)->PostRotate(CssQuaternion(q[3], q[0], q[1], q[2]));
    CssTrapHandler::UnTrap();
    return 1;
}

int transform_postScale(void *self, const float *scale)
{
    SWV_BEGIN_API(frame);
    float v[3];
    for (int i = 0; i < 3; ++i)
        v[i] = g_ValidateFloat(scale[i]);
    transform(self)->PostScale({v[0], v[1], v[2]});
    CssTrapHandler::UnTrap();
    return 1;
}

int transform_postTranslate(void *self, const float *offset)
{
    SWV_BEGIN_API(frame);
    float v[3];
    for (int i = 0; i < 3; ++i)
        v[i] = g_ValidateFloat(offset[i]);
    transform(self)->PostTranslate({v[0], v[1], v[2]});
    CssTrapHandler::UnTrap();
    return 1;
}

int transform_transformPoints(void *self, int count, float *points)
{
    SWV_BEGIN_API(frame);
    if (!points)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    transform(self)->Transform(count, points);
    CssTrapHandler::UnTrap();
    return 1;
}

void transform_transpose(void *self)
{
    transform(self)->Transpose();
}

int transform_transform(void *self, void *vertex_handle, int length, float *out, int use_w)
{
    SWV_BEGIN_API(frame);
    if (!vertex_handle || !out)
        g_ssThrowLeave(SWV_LEAVE_NULL_POINTER);
    auto *vertices = static_cast<CssVertexArray *>(static_cast<CssRefCount *>(vertex_handle));
    transform(self)->Transform(vertices, length, out, use_w != 0);
    CssTrapHandler::UnTrap();
    return 1;
}
