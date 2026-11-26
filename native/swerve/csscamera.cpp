#include "legacy_math.hpp"
#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"
#include "engine.h"
#include <cmath>
#include <cfloat>

int CssCamera::GetProjection(int count, float *params) const
{
    if (params && count < 4)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (projection_type != Generic && params) {
        params[0] = projection_type == Perspective ? field_of_view : height;
        params[1] = aspect;
        params[2] = near_plane;
        params[3] = far_plane;
    }
    return projection_type;
}

int CssCamera::GetProjection(CssTransform *transform) const
{
    if (nearZero(far_plane - near_plane))
        g_ssThrowLeave(SWV_LEAVE_FLOAT_INVALID_OPERATION);
    if (transform)
        transform->SetMatrix(GetMatrix());
    return projection_type;
}

const CssMatrix &CssCamera::GetMatrix() const
{
    RecacheProjectionMatrix();
    return projection;
}

const CssMatrix &CssCamera::GetMatrixSafe() const
{
    if (nearZero(far_plane - near_plane))
        g_ssThrowLeave(SWV_LEAVE_FLOAT_INVALID_OPERATION);
    return GetMatrix();
}

void CssCamera::SetGeneric(const CssTransform *transform)
{
    if (!transform->bInvertible())
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    projection_type = Generic;
    projection = transform->GetMatrix();
    projection_dirty = 0;
    view_dirty = 1;
}

void CssCamera::SetParallel(float new_height, float new_aspect, float near_value, float far_value)
{
    projection_type = Parallel;
    height = new_height;
    aspect = new_aspect;
    near_plane = near_value;
    far_plane = far_value;
    projection_dirty = view_dirty = 1;
}

void CssCamera::SetPerspective(float fovy, float new_aspect, float near_value, float far_value)
{
    projection_type = Perspective;
    field_of_view = fovy;
    aspect = new_aspect;
    near_plane = near_value;
    far_plane = far_value;
    projection_dirty = view_dirty = 1;
}

void CssCamera::RecacheProjectionMatrix() const
{
    if (projection_type == Generic || !projection_dirty) return;
    float n = near_plane, f = far_plane;
    float span = f - n;
    float depth = -(n + f) / span;
    if (projection_type == Parallel) {
        float y = 1 / height * 2.0f;
        projection = CssMatrix(y / aspect, 0, 0, 0, 0, y, 0, 0,
                               0, 0, -2 / span, 0, 0, 0, depth, 1);
        projection.flags = MatrixAffine;
    } else {
        float radians = field_of_view * radiansPerDegree;
        float half = radians * 0.5f;
        float y = 1 / legacy_math::tan(half);
        projection = CssMatrix(y / aspect, 0, 0, 0, 0, y, 0, 0,
                               0, 0, depth, -1, 0, 0, n * f * -2 / span, 0);
    }
    projection_dirty = 0;
}

void CssCamera::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    CssNode::SerializeIn(reader);
    projection_type = reader.ReadEnum(Generic - 1, Perspective + 1);
    if (projection_type == Generic) {
        reader.ReadMatrix(projection);
        return;
    }
    float v = reader.ReadReal();
    if (projection_type == Parallel) {
        height = v;
        if (v <= 0) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    } else {
        field_of_view = v;
        if (v <= 0 || v >= 180) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    }
    aspect = reader.ReadReal();
    if (aspect <= 0) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    near_plane = reader.ReadReal();
    far_plane = reader.ReadReal();
    if (nearZero(near_plane - far_plane)) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    if (projection_type == Perspective && (near_plane <= 0 || far_plane <= 0)) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
}

IssSerializable *CssCamera::FactoryCreate()
{
    return new CssCamera;
}

void CssCamera::CloneHelper(const CssCamera &source)
{
    CssNode::CloneHelper(source);
    projection_type = source.projection_type;
    projection_dirty = source.projection_dirty;
    projection = source.projection;
    field_of_view = source.field_of_view;
    height = source.height;
    aspect = source.aspect;
    near_plane = source.near_plane;
    far_plane = source.far_plane;
}

CssObject3D *CssCamera::Clone() const
{
    CssHeapPtr<CssCamera> copy(static_cast<CssCamera *>(FactoryCreate()));
    copy->CloneHelper(*this);
    copy->FixupAlignmentReferences(this, this, copy.get());
    return copy.release();
}

bool CssCamera::HasAnimatableProperty(int prop) const
{
    return prop == CssAnimationTrack::FarDistance || prop == CssAnimationTrack::FieldOfView ||
           prop == CssAnimationTrack::NearDistance || CssNode::HasAnimatableProperty(prop);
}

void CssCamera::SetProperty(int prop, int count, float *v)
{
    float value = *v;
    switch (prop) {
    case CssAnimationTrack::FarDistance: case CssAnimationTrack::NearDistance:
        if (projection_type == Perspective && value <= 0) value = FLT_MIN;
        if (prop == CssAnimationTrack::FarDistance) far_plane = value; else near_plane = value;
        break;
    case CssAnimationTrack::FieldOfView:
        if (value <= 0) value = realEpsilon;
        if (projection_type == Parallel) height = value;
        else field_of_view = value >= 180 ? 179.99998f : value;
        break;
    default:
        CssNode::SetProperty(prop, count, v);
        return;
    }
    view_dirty = projection_dirty = 1;
}
