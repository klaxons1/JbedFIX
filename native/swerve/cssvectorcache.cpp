#include "graphics3d_state.h"
#include "geometry_class.hpp"
#include "platform.h"

void CssFixedVectorCache::Clear()
{
    xyz.SetSize(0);
    w.SetSize(0);
    normalized_w.SetSize(0);
    normalized_xyz.SetSize(0);
    valid.SetSize(0);
    source = nullptr;
    skin = nullptr;
    prepared = false;
}

static bool same_bias(const CssVector3D &a, const CssVector3D &b)
{
    return nearZero(a.x - b.x) && nearZero(a.y - b.y) &&
           nearZero(a.z - b.z);
}

void CssFixedVectorCache::Initialize(const CssVertexArray *vertices, const CssMatrix &transform,
                                     float gain, const CssVector3D &offset, bool *visible)
{
    if (!visible && source && source == vertices && !vertices->dirty && scale == gain &&
        same_bias(bias, offset) && matrix == transform)
        return;
    source = vertices;
    matrix = transform;
    bias = offset;
    scale = gain;
    bool in_bounds = DoInitialize(transform, visible != nullptr);
    if (visible)
        *visible = in_bounds;
}

void CssFixedVectorCache::InitializeLazy(const CssVertexArray *vertices, const CssMatrix &transform,
                                         float gain, const CssVector3D &offset)
{
    if (source && source == vertices && !vertices->dirty && scale == gain &&
        same_bias(bias, offset) && matrix == transform)
        return;
    source = vertices;
    matrix = transform;
    bias = offset;
    scale = gain;
    prepared = false;
}

bool CssFixedVectorCache::DoInitialize(const CssMatrix &transform, bool test_bounds)
{
    xyz.SetSize(source->count);
    w.SetSize(source->count);
    normalized_w.SetSize(0);
    normalized_xyz.SetSize(0);
    valid.SetSize(source->count);
    if (source->count)
        std::memset(valid.data, 0, source->count);
    CssMatrix local;
    local.Scale(scale * 65536.0f);
    local.Translate(bias);
    const int magnitude = source->GetMaxNumber() + 1;
    bool visible = false;
    if (skin) {
        skin->Prepare();
        transforms.SetSize(skin->blends.size);
        for (int i = 0; i < transforms.size; ++i) {
            CssMatrix combined = local;
            combined.PreMultiply(skin->GetPaletteMatrix(i));
            combined.PreMultiply(transform);
            visible |= transforms[i].SetScaledMatrix(combined, magnitude, test_bounds, false);
        }
    } else {
        local.PreMultiply(transform);
        transforms.SetSize(1);
        if (local.flags == MatrixIdentityFlag)
            local.Identity();
        visible = transforms[0].SetScaledMatrix(local, magnitude, test_bounds, true);
    }
    prepared = true;
    return visible;
}

void CssFixedVectorCache::TransformAll4D()
{
    auto *positions = static_cast<CssFixedVector3D *>(xyz.data);
    auto *divisors = static_cast<SwvFixedWord *>(w.data);
    if (skin)
        skin->Prepare();
    if (skin && skin->blends.size > 1) {
        for (int i = 0; i < source->count; ++i)
            source->TransformVectorsRange(i, i + 1, transforms[skin->vertex_blends[i]], positions, divisors);
    } else
        source->TransformVectorsRange(0, source->count, transforms[0], positions, divisors);
    for (int i = 0; i < source->count; ++i)
        valid[i] = Transformed;
}

const CssFixedVector3D *CssFixedVectorCache::DivideByW(int index, SwvFixedWord *reciprocal)
{
    if (!normalized_xyz.size)
        normalized_xyz.SetSize(xyz.size);
    if (!normalized_w.size)
        normalized_w.SetSize(xyz.size);
    auto &out = normalized_xyz[index];
    if (valid[index] & DividedByW) {
        *reciprocal = normalized_w[index];
        return &out;
    }
    valid[index] |= DividedByW;
    out = xyz[index];
    SwvFixedWord divisor = w[index];
    if (divisor != 65536) {
        if (divisor != previous_w) {
            previous_w = divisor;
            reciprocal_shift = 0;
            while (divisor > 65536) {
                divisor >>= 1;
                ++reciprocal_shift;
            }
            reciprocal_w = g_fixed_reciprocal(divisor);
        }
        out.x = (int64_t(out.x >> reciprocal_shift) * reciprocal_w) >> 16;
        out.y = (int64_t(out.y >> reciprocal_shift) * reciprocal_w) >> 16;
        out.z = (int64_t(out.z >> reciprocal_shift) * reciprocal_w) >> 16;
        divisor = reciprocal_w >> reciprocal_shift;
        normalized_w[index] = divisor;
    }
    *reciprocal = divisor;
    return &out;
}

void CssFixedVectorCache::GetVector4D(int index, const CssFixedVector3D **position, SwvFixedWord *out_w)
{
    if (!(valid[index] & Transformed)) {
        if (skin)
            skin->Prepare();
        const auto &transform = transforms[skin ? skin->vertex_blends[index] : 0];
        source->TransformVector(index, transform, &xyz[index], &w[index]);
        valid[index] = Transformed;
    }
    *position = &xyz[index];
    if (out_w)
        *out_w = w[index];
}

void CssFixedVectorCache::GetShiftedVector4D(int index, const CssFixedVector3D **position,
                                            SwvFixedWord *out_w, int *shift)
{
    if (!prepared)
        DoInitialize(matrix, false);
    if (skin)
        skin->Prepare();
    auto &transform = transforms[skin ? skin->vertex_blends[index] : 0];
    int w_shift = transform.w_shift;
    if (!(valid[index] & Transformed)) {
        transform.w_shift = 0;
        source->TransformVector(index, transform, &xyz[index], &w[index]);
        transform.w_shift = w_shift;
        valid[index] = Transformed;
    }
    *position = &xyz[index];
    *out_w = w[index];
    *shift = w_shift;
}

const CssFixedVector3D *CssFixedVectorCache::GetNormalisedVector3D(int index)
{
    if (!(valid[index] & Transformed)) {
        if (skin)
            skin->Prepare();
        const auto &transform = transforms[skin ? skin->vertex_blends[index] : 0];
        source->TransformNormal(index, transform, &xyz[index]);
        xyz[index].Unit();
        valid[index] = Transformed;
    }
    return &xyz[index];
}

const CssFixedVector3D *CssFixedVectorCache::GetProjectedVector2D(int index)
{
    if (!(valid[index] & Transformed)) {
        if (skin)
            skin->Prepare();
        const auto &transform = transforms[skin ? skin->vertex_blends[index] : 0];
        auto &out = xyz[index];
        source->TransformVector(index, transform, &out, &w[index]);
        SwvFixedWord divisor = w[index];
        out.z = divisor;
        if (divisor != 65536 && divisor != 0) {
            int shift = 16 - transform.fraction;
            if (shift >= 0 && shift < 32 && (uint32_t(divisor) << shift) == 65536) {
                out.x = uint32_t(out.x) << shift;
                out.y = uint32_t(out.y) << shift;
            } else if (shift < 0 && shift > -32 && (divisor >> -shift) == 65536) {
                out.x >>= -shift;
                out.y >>= -shift;
            } else {
                if (previous_w != divisor) {
                    previous_w = divisor;
                    reciprocal_w = g_fixed_reciprocal(divisor);
                }
                out.x = (int64_t(out.x) * reciprocal_w) >> 16;
                out.y = (int64_t(out.y) * reciprocal_w) >> 16;
            }
        }
        valid[index] = Transformed;
    }
    return &xyz[index];
}
