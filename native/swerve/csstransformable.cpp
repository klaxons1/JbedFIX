#include "cssserializebufferobjectsin.hpp"
#include "object_class.hpp"
#include "engine.h"
#include "object_classes.hpp"
#include "cssquaternion.hpp"
#include <new>

bool CssTransformable::HasAnimatableProperty(int property) const
{
    return property == CssAnimationTrack::Orientation || property == CssAnimationTrack::Scale ||
           property == CssAnimationTrack::Translation;
}

void CssTransformable::SetMatrixCacheDirty() const
{
    if (!(transform_flags & SharedComponents)) transform_flags |= CompositeDirty | SkinningDirty;
}

CssTransformable::~CssTransformable()
{
    if (!(transform_flags & SharedGeneralMatrix))
        swvFree(state->general);
    if (!(transform_flags & SharedComponents))
        swvFree(state);
}

void CssTransformable::CloneHelper(const CssTransformable &source)
{
    CssObject3D::CloneHelper(source);
    if (!(transform_flags & SharedGeneralMatrix))
        swvFree(state->general);
    if (source.transform_flags & SharedComponents) {
        if (!(transform_flags & SharedComponents))
            swvFree(state);
        state = source.state;
    } else {
        if (transform_flags & SharedComponents) {
            state = new (ELeave) SssTransformComponents;
            transform_flags = SharedGeneralMatrix;
        }
        *state = *source.state;
        if (!(source.transform_flags & SharedGeneralMatrix)) {
            state->general = new (ELeave) CssMatrix(*source.state->general);
        }
    }
    transform_flags = source.transform_flags;
}

void CssTransformable::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    CssObject3D::SerializeIn(reader);
    if (reader.ReadBool()) {
        CssVector3D vector;
        reader.ReadVector3D(vector);
        SetTranslation(vector);
        reader.ReadVector3D(vector);
        SetScale(vector);
        float radians = reader.ReadReal() * radiansPerDegree;
        reader.ReadVector3D(vector);
        if (radians != 0 && vector.x == 0 && vector.y == 0 && vector.z == 0)
            g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
        SetOrientation(CssQuaternion(radians, vector));
    }
    if (reader.ReadBool()) {
        CssMatrix matrix;
        reader.ReadMatrix(matrix);
        SetGeneralMatrix(matrix);
    }
    SetMatrixCacheDirty();
}

void CssTransformable::SetProperty(int property, int, float *value)
{
    if (property == CssAnimationTrack::Orientation) {
        CssQuaternion rotation(value[3], value[0], value[1], value[2]);
        rotation.Normalize();
        SetOrientation(rotation);
    } else if (property == CssAnimationTrack::Scale) {
        SetScale({value[0], value[1], value[2]});
    } else if (property == CssAnimationTrack::Translation) {
        SetTranslation({value[0], value[1], value[2]});
    }
}

void CssTransformable::AllocateTransformComponents()
{
    if (!(transform_flags & SharedComponents))
        return;
    CssMatrix *general = state->general;
    state = new (ELeave) SssTransformComponents{};
    state->scale = {1, 1, 1};
    state->general = general;
    state->composite.Identity();
    transform_flags = SharedGeneralMatrix;
}

static bool near_vector(const CssVector3D &v, const CssVector3D &other)
{
    return nearZero(v.x - other[0]) &&
           nearZero(v.y - other[1]) &&
           nearZero(v.z - other[2]);
}

void CssTransformable::SetTranslation(const CssVector3D &v)
{
    if (near_vector(v, state->translation))
        return;
    AllocateTransformComponents();
    state->translation = v;
    SetMatrixCacheDirty();
}

void CssTransformable::SetScale(const CssVector3D &v)
{
    if (near_vector(v, state->scale))
        return;
    AllocateTransformComponents();
    state->scale = v;
    SetMatrixCacheDirty();
}

void CssTransformable::Translate(const CssVector3D &v)
{
    if (near_vector(v, {0, 0, 0}))
        return;
    AllocateTransformComponents();
    state->translation += v;
    SetMatrixCacheDirty();
}

void CssTransformable::Scale(const CssVector3D &v)
{
    if (near_vector(v, {1, 1, 1}))
        return;
    AllocateTransformComponents();
    for (int i = 0; i < 3; ++i)
        state->scale[i] = state->scale[i] * v[i];
    SetMatrixCacheDirty();
}

void CssTransformable::SetOrientation(const CssQuaternion &rotation)
{
    if (state->orientation == rotation)
        return;
    AllocateTransformComponents();
    state->orientation = rotation;
    SetMatrixCacheDirty();
}

void CssTransformable::PreRotate(const CssQuaternion &rotation)
{
    AllocateTransformComponents();
    state->orientation.PreMultiply(rotation);
    state->orientation.Normalize();
    SetMatrixCacheDirty();
}

void CssTransformable::PostRotate(const CssQuaternion &rotation)
{
    AllocateTransformComponents();
    state->orientation *= rotation;
    state->orientation.Normalize();
    SetMatrixCacheDirty();
}

void CssTransformable::GetTransform(CssTransform *out) const { out->matrix = *state->general; }

void CssTransformable::SetTransform(const CssTransform *transform)
{
    const CssMatrix &matrix = transform ? transform->matrix : *swv_identity_matrix();
    if (transform && Type() != Texture2DObject && !(matrix.flags & MatrixAffineFlag))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    SetGeneralMatrix(matrix);
}

void CssTransformable::SetGeneralMatrix(const CssMatrix &general)
{
    if ((transform_flags & SharedComponents) && (general.flags & MatrixIdentityFlag))
        return;
    AllocateTransformComponents();
    if (transform_flags & SharedGeneralMatrix) {
        state->general = new (ELeave) CssMatrix;
        transform_flags &= ~SharedGeneralMatrix;
    }
    *state->general = general;
    SetMatrixCacheDirty();
}

static void composite_transform(const SssTransformComponents &state, CssMatrix &out)
{
    out = CssMatrix(state.translation);
    CssMatrix rotation;
    state.orientation.Matrix(&rotation);
    out *= rotation;
    out *= CssMatrix(state.scale.x, state.scale.y, state.scale.z);
    out *= *state.general;
}

void CssTransformable::GetCompositeTransform(CssTransform *out) const
{
    composite_transform(*state, out->matrix);
}

void CssTransformable::ReCache() const
{
    if (!(transform_flags & CompositeDirty))
        return;
    CssMatrix &m = state->composite;
    m = *state->general;
    m.Scale(state->scale[0], state->scale[1], state->scale[2]);
    if (state->orientation.q[3] != 1 && state->orientation.q[3] != -1) {
        CssMatrix rotation;
        state->orientation.Matrix(&rotation);
        m.PreMultiply(rotation);
    }
    m.Translate(state->translation[0], state->translation[1], state->translation[2]);
    transform_flags &= ~CompositeDirty;
}
