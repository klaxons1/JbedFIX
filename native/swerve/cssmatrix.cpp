#include "cssmatrix.hpp"
#include "graphics3d_state.h"
#include <algorithm>
#include <bit>
#include <cfloat>
#include <cmath>
#include <cstring>

static int near_one(float x)
{
    return nearZero(x - 1);
}

void CssMatrix::Identity()
{
    static const float identity[16] = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    memcpy(m, identity, sizeof m);
    flags = MatrixIdentity;
}

CssMatrix::CssMatrix(EssMatrixType)
{
    Identity();
}

void CssMatrix::ResetMatrixType()
{
    unsigned classification = MatrixGeneral;
    if (nearZero(m[3]) && nearZero(m[7]) && nearZero(m[11]) && near_one(m[15])) {
        int origin = nearZero(m[12]) && nearZero(m[13]) && nearZero(m[14]);
        int diagonal = nearZero(m[1]) && nearZero(m[2]) && nearZero(m[4]) &&
                       nearZero(m[6]) && nearZero(m[8]) && nearZero(m[9]);
        int unit = near_one(m[0]) && near_one(m[5]) && near_one(m[10]);
        if (!origin)
            classification = diagonal && unit ? MatrixTranslation : MatrixAffine;
        else if (!diagonal)
            classification = MatrixLinear;
        else
            classification = unit ? MatrixIdentity : MatrixScale;
    }
    flags = classification;
}

CssMatrix::CssMatrix(float x, float y, float z)
{
    Identity();
    if (near_one(x) && near_one(y) && near_one(z))
        return;
    m[0] = x;
    m[5] = y;
    m[10] = z;
    flags = MatrixScale;
}

CssMatrix::CssMatrix(const CssVector3D &v)
{
    Identity();
    if (nearZero(v.x) && nearZero(v.y) && nearZero(v.z))
        return;
    m[12] = v.x;
    m[13] = v.y;
    m[14] = v.z;
    flags = MatrixTranslation;
}

static float dot3(const float *row, const float *col)
{
    return row[0] * col[0] + row[4] * col[1] + row[8] * col[2];
}

void CssMatrix::Mult4(float x, float y, float z, float w, float out[4]) const
{
    const float v[3] = {x, y, z};
    for (int r = 0; r < 4; ++r)
        out[r] = dot3(m + r, v) + m[12 + r] * w;
}

static void homogeneous(const CssMatrix &matrix, const float in[3], float out[3], float &w)
{
    out[0] = out[1] = out[2] = 0;
    for (int r = 0; r < 3; ++r)
        out[r] = dot3(matrix.m + r, in) + matrix.m[12 + r];
    w = dot3(matrix.m + 3, in) + matrix.m[15];
}

CssVector3D CssMatrix::Transform3Dto4D(const CssVector3D &v, float *w) const
{
    const float in[3] = {v.x, v.y, v.z};
    float out[3];
    homogeneous(*this, in, out, *w);
    return {out[0], out[1], out[2]};
}

bool CssMatrix::operator==(const CssMatrix &right) const
{
    return flags == right.flags && memcmp(m, right.m, sizeof m) == 0;
}

CssVector3D CssMatrix::operator*(const CssVector3D &v) const
{
    switch (flags) {
    case MatrixIdentityFlag:
    case MatrixIdentity:
        return v;
    case MatrixTranslation:
        return {v.x + m[12], v.y + m[13], v.z + m[14]};
    case MatrixScale:
        return {v.x * m[0], v.y * m[5], v.z * m[10]};
    default:
        const float xyz[3] = {v.x, v.y, v.z};
        CssVector3D out{dot3(m, xyz), dot3(m + 1, xyz), dot3(m + 2, xyz)};
        if (flags != MatrixLinear) {
            out.x += m[12];
            out.y += m[13];
            out.z += m[14];
        }
        return out;
    }
}

void CssMatrix::MultiplyGeneralGeneral(float *out, const float *left, const float *right)
{
    for (int c = 0; c < 4; ++c) {
        const float *col = right + 4 * c;
        for (int r = 0; r < 4; ++r)
            out[4 * c + r] = dot3(left + r, col) + left[12 + r] * col[3];
    }
}

void CssMatrix::MultiplyGeneralAffine(float *out, const float *left, const float *right)
{
    bool xy_perspective = left[3] != 0 || left[7] != 0;
    for (int c = 0; c < 4; ++c) {
        const float *col = right + 4 * c;
        for (int r = 0; r < 3; ++r) {
            float value = dot3(left + r, col);
            out[4 * c + r] = c == 3 ? value + left[12 + r] : value;
        }
        float w = col[2] * left[11];
        if (c == 3)
            w += left[15];
        float &result_w = out[4 * c + 3];
        result_w = w;
        if (xy_perspective) {
            float xy = col[0] * left[3] + col[1] * left[7];
            result_w = xy + w;
        }
    }
}

void CssMatrix::MultiplyAffineAffine(float *out, const float *left, const float *right, bool linear)
{
    for (int c = 0; c < 3; ++c)
        for (int r = 0; r < 3; ++r)
            out[4 * c + r] = dot3(left + r, right + 4 * c);
    if (!linear)
        for (int r = 0; r < 3; ++r)
            out[12 + r] = dot3(left + r, right + 12) + left[12 + r];
}

/* OpenGL column order. The classified shortcuts retain unmodified matrix
 * entries, including values within the engine's classification tolerance. */
CssMatrix &CssMatrix::operator*=(const CssMatrix &right)
{
    unsigned af = flags, bf = right.flags;
    if ((af | bf) & MatrixIdentityFlag) {
        if (!(bf & MatrixIdentityFlag))
            *this = right;
        return *this;
    }
    unsigned common = af & bf;
    flags = common;
    if ((common & ~MatrixGeneralFlag) && ((af | bf) & MatrixTranslationFlag)) {
        if (af & MatrixTranslationFlag) {
            for (int c = 0; c < 3; ++c)
                for (int r = 0; r < 3; ++r)
                    m[4 * c + r] = right.m[4 * c + r];
            for (int r = 0; r < 3; ++r)
                m[12 + r] += right.m[12 + r];
        } else {
            for (int r = 0; r < 3; ++r)
                m[12 + r] = dot3(m + r, right.m + 12) + m[12 + r];
        }
        return *this;
    }
    if ((common & ~MatrixGeneralFlag) && ((af | bf) & MatrixScaleFlag)) {
        if (common & MatrixScaleFlag) {
            for (int i = 0; i < 3; ++i)
                m[5 * i] *= right.m[5 * i];
        } else if (bf & MatrixScaleFlag) {
            for (int c = 0; c < 3; ++c)
                for (int r = 0; r < 3; ++r)
                    m[4 * c + r] *= right.m[5 * c];
        } else {
            float s[3] = {m[0], m[5], m[10]};
            for (int c = 0; c < 4; ++c)
                for (int r = 0; r < 3; ++r)
                    m[4 * c + r] = right.m[4 * c + r] * s[r];
        }
        return *this;
    }
    const CssMatrix left = *this;
    if (common & ~MatrixGeneralFlag)
        MultiplyAffineAffine(m, left.m, right.m, (common & MatrixLinearFlag) != 0);
    else if (right.flags & MatrixAffineFlag)
        MultiplyGeneralAffine(m, left.m, right.m);
    else
        MultiplyGeneralGeneral(m, left.m, right.m);
    return *this;
}

void CssMatrix::Transpose()
{
    if (flags == MatrixIdentityFlag || flags == MatrixIdentity)
        return;
    for (int i = 0; i < 4; ++i)
        for (int j = i + 1; j < 4; ++j) {
            float x = m[4 * i + j];
            m[4 * i + j] = m[4 * j + i];
            m[4 * j + i] = x;
        }
}

bool CssMatrix::Invert()
{
    if (flags == MatrixIdentityFlag || flags == MatrixIdentity)
        return true;
    CssMatrix left = *this, right;
    right.Identity();
    float largest = 0;
    for (int i = 0; i < 12; ++i) {
        float x = left.m[i];
        if (x > largest)
            largest = x;
        else if (-x > largest)
            largest = -x;
    }
    if (largest < 1) {
        if (largest == 0)
            return false;
        float factor = 1 / largest;
        for (int i = 0; i < 16; ++i) {
            left.m[i] *= factor;
            right.m[i] *= factor;
        }
    }
    for (int p = 0; p < 4; ++p) {
        int pivot = p;
        for (int j = p + 1; j < 4; ++j) {
            float candidate = std::abs(left.m[4 * j + p]);
            float current = std::abs(left.m[4 * pivot + p]);
            if (candidate > current)
                pivot = j;
        }
        if (pivot != p) {
            for (int i = 0; i < 4; ++i) {
                int x = 4 * p + i, y = 4 * pivot + i;
                std::swap(left.m[x], left.m[y]);
                std::swap(right.m[x], right.m[y]);
            }
        }
        if (std::abs(left.m[5 * p]) < FLT_MIN)
            return false;
        float reciprocal = 1 / left.m[5 * p];
        for (int i = 0; i < 4; ++i)
            right.m[4 * p + i] *= reciprocal;
        for (int i = p + 1; i < 4; ++i)
            left.m[4 * p + i] *= reciprocal;
        left.m[5 * p] = 1;
        for (int j = 0; j < 4; ++j) {
            if (j == p)
                continue;
            float factor = left.m[4 * j + p];
            for (int i = 0; i < 4; ++i)
                right.m[4 * j + i] -= factor * right.m[4 * p + i];
            for (int i = p + 1; i < 4; ++i)
                left.m[4 * j + i] -= factor * left.m[4 * p + i];
            left.m[4 * j + p] = 0;
        }
    }
    right.flags = flags;
    *this = right;
    return true;
}

void CssMatrix::PreMultiply(const CssMatrix &left)
{
    unsigned af = flags, bf = left.flags, common = af & bf;
    if ((af | bf) & MatrixIdentityFlag) {
        if (!(bf & MatrixIdentityFlag))
            *this = left;
        return;
    }
    flags = common;
    if ((common & ~MatrixGeneralFlag) && ((af | bf) & MatrixTranslationFlag)) {
        if (bf & MatrixTranslationFlag) {
            for (int i = 0; i < 3; ++i)
                m[12 + i] += left.m[12 + i];
        } else if (bf & MatrixScaleFlag) {
            for (int i = 0; i < 3; ++i) {
                m[12 + i] *= left.m[5 * i];
                m[5 * i] = left.m[5 * i];
            }
        } else {
            float offset[3] = {m[12], m[13], m[14]};
            *this = left;
            for (int r = 0; r < 3; ++r)
                m[12 + r] = dot3(m + r, offset) + m[12 + r];
            flags = common;
        }
    } else if ((common & ~MatrixGeneralFlag) && ((af | bf) & MatrixScaleFlag)) {
        if (common & MatrixScaleFlag) {
            for (int i = 0; i < 3; ++i)
                m[5 * i] *= left.m[5 * i];
        } else if (bf & MatrixScaleFlag) {
            float scale[3] = {left.m[0], left.m[5], left.m[10]};
            for (int c = 0; c < 4; ++c)
                for (int r = 0; r < 3; ++r)
                    m[4 * c + r] *= scale[r];
        } else {
            float scale[3] = {m[0], m[5], m[10]};
            for (int r = 0; r < 4; ++r) {
                for (int c = 0; c < 3; ++c)
                    m[4 * c + r] = left.m[4 * c + r] * scale[c];
                m[12 + r] = left.m[12 + r];
            }
        }
    } else {
        const CssMatrix right = *this;
        if (common & ~MatrixGeneralFlag)
            MultiplyAffineAffine(m, left.m, right.m, (common & MatrixLinearFlag) != 0);
        else if (af & MatrixAffineFlag)
            MultiplyGeneralAffine(m, left.m, right.m);
        else
            MultiplyGeneralGeneral(m, left.m, right.m);
    }
}

void CssMatrix::Scale(float uniform)
{
    if (!near_one(uniform))
        Scale(uniform, uniform, uniform);
}

void CssMatrix::Translate(const CssVector3D &offset)
{
    Translate(offset.x, offset.y, offset.z);
}

void CssMatrix::Scale(float x, float y, float z)
{
    if (near_one(x) && near_one(y) && near_one(z))
        return;
    if (flags & MatrixIdentityFlag)
        *this = CssMatrix(x, y, z);
    else {
        const float scale[3] = {x, y, z};
        int columns = (flags & MatrixTranslation) ? 4 : 3;
        for (int c = 0; c < columns; ++c)
            for (int r = 0; r < 3; ++r)
                m[4 * c + r] *= scale[r];
        flags &= MatrixScale;
    }
}

void CssMatrix::Translate(float x, float y, float z)
{
    if (nearZero(x) && nearZero(y) && nearZero(z))
        return;
    const float v[3] = {x, y, z};
    if (flags & MatrixIdentityFlag)
        *this = CssMatrix(CssVector3D{x, y, z});
    else {
        for (int i = 0; i < 3; ++i)
            m[12 + i] += v[i];
        flags &= MatrixTranslation;
    }
}

CssMatrix::CssMatrix(float radians, const CssVector3D &axis)
{
    CssQuaternion(radians, axis).Matrix(this);
}

void CssMatrix::Rotate(float radians, const CssVector3D &axis)
{
    if (!nearZero(radians))
        PreMultiply(CssMatrix(radians, axis));
}

CssVector3D CssMatrix::Transform4Dto3D(const CssVector3D &v, float w) const
{
    float projected[4];
    Mult4(v.x, v.y, v.z, w, projected);
    if (!near_one(projected[3]) && !nearZero(projected[3])) {
        float scale = 1 / projected[3];
        for (int i = 0; i < 3; ++i)
            projected[i] *= scale;
    }
    return {projected[0], projected[1], projected[2]};
}

float CssMatrix::GetMaxScale() const
{
    if (flags & (MatrixTranslationFlag | MatrixIdentityFlag))
        return 1;
    float largest = 0;
    for (int r = 0; r < 3; ++r) {
        float sum = 0;
        for (int c = 0; c < 3; ++c)
            sum += std::abs(m[c * 4 + r]);
        if (sum > largest)
            largest = sum;
    }
    return largest;
}

bool CssMatrix::InverseTranspose()
{
    if (flags == MatrixIdentity)
        return true;
    if (flags == MatrixLinear ||
        (nearZero(m[12]) && nearZero(m[13]) && nearZero(m[14]) &&
         nearZero(m[3]) && nearZero(m[7]) && nearZero(m[11]))) {
        int unit = 1;
        for (int c = 0; c < 3; ++c) {
            float *v = m + 4 * c;
            float xy = v[0] * v[0] + v[1] * v[1];
            unit &= near_one(xy + v[2] * v[2]);
        }
        if (unit) {
            flags = MatrixLinear;
            return true;
        }
    }
    if (!Invert())
        return false;
    Transpose();
    return true;
}

void CssMatrix::TransformNormal(CssVector3D &out, const CssVector3D &in) const
{
    for (int r = 0; r < 3; ++r) {
        if (flags == MatrixScale)
            out[r] = in[r] * m[5 * r];
        else if (flags == MatrixTranslation || flags == MatrixIdentityFlag || flags == MatrixIdentity)
            out[r] = in[r];
        else
            out[r] = m[r] * in.x + m[4 + r] * in.y + m[8 + r] * in.z;
    }
}

CssMatrix &CssMatrix::operator+=(const CssMatrix &right)
{
    for (int i = 0; i < 16; ++i)
        m[i] += right.m[i];
    flags &= right.flags;
    return *this;
}

CssMatrix &CssMatrix::operator-=(const CssMatrix &right)
{
    for (int i = 0; i < 16; ++i)
        m[i] -= right.m[i];
    flags &= right.flags;
    return *this;
}

static int int_shift(float a, float b)
{
    return a > b && b != 0 ? (std::bit_cast<uint32_t>(a) - std::bit_cast<uint32_t>(b)) >> 23 : 0;
}
/* 0x2da2d0. The scale for the W row is chosen independently
 * so that large translations do not consume its significant bits. */
bool CssIntMatrix::SetScaledMatrix(const CssMatrix &matrix, int magnitude, bool test_bounds, bool early_out)
{
    constexpr float CoefficientLimit = 0x1p30f;
    constexpr float TransformedCoordinateLimit = 0x1p25f;
    float sum[4], radius[4], center[4];
    const float *values = matrix.m;
    for (int i = 0; i < 4; ++i) {
        sum[i] =
            static_cast<float>(magnitude) * (fabsf(values[i]) + fabsf(values[4 + i]) + fabsf(values[8 + i]));
        radius[i] = sum[i] / 65536.0f;
        center[i] = values[12 + i];
    }
    float w_bound = center[3] + radius[3];
    bool visible = true;
    if (test_bounds) {
        for (int i = 0; i < 3; ++i)
            if (center[i] - radius[i] > w_bound || (center[i] + radius[i]) < -w_bound) {
                if (early_out)
                    return false;
                visible = false;
            }
    }
    float max_xyz = 0;
    for (int i = 0; i < 3; ++i) {
        center[i] = fabsf(center[i]);
        max_xyz = std::max(max_xyz, std::max(sum[i], radius[i] + center[i]));
    }
    float max_w = std::max(sum[3], w_bound);
    float maximum = std::max(max_xyz, max_w);
    w_shift = int_shift(maximum, max_w);
    float wscale = std::ldexp(1.0f, w_shift);
    int frac = int_shift(CoefficientLimit, maximum);
    float scale;
    if (frac == 0 || frac >= 30) {
        frac = 0;
        scale = CoefficientLimit / maximum;
    } else
        scale = std::ldexp(1.0f, frac);
    float bound = w_bound * wscale;
    for (int i = 0; i < 3; ++i)
        bound = std::max(bound, radius[i] + center[i]);
    int extra = int_shift(TransformedCoordinateLimit, bound * scale);
    if (extra > 16)
        extra = 16;
    float gain = std::ldexp(1.0f, extra);
    fraction = frac + extra;
    shift = 16 - extra;
    affine = (matrix.flags & MatrixAffineFlag) != 0;
    for (int i = 0; i < 16; ++i) {
        float factor = (i % 4 == 3) ? scale * wscale : scale;
        float v = values[i] * factor;
        if (i >= 12)
            v *= gain;
        m[i] = saturatingTruncate(v);
    }
    return visible;
}
template<class Component>
static int fixed_dot3(const CssIntMatrix &matrix, const Component *v, int row)
{
    uint32_t sum = uint32_t(matrix.m[row]) * v[0] + uint32_t(matrix.m[4 + row]) * v[1] +
                   uint32_t(matrix.m[8 + row]) * v[2];
    return static_cast<int>(sum) >> matrix.shift;
}

template<class Component>
static void transform3(const CssIntMatrix &matrix, const Component *v, SwvFixedWord *out)
{
    for (int row = 0; row < 3; ++row)
        out[row] = matrix.m[12 + row] + fixed_dot3(matrix, v, row);
}

template<class Component>
static void transform_normal(const CssIntMatrix &matrix, const Component *v, SwvFixedWord *out)
{
    for (int row = 0; row < 3; ++row)
        out[row] = fixed_dot3(matrix, v, row);
}

template<class Component>
static void transform3_with_w(const CssIntMatrix &matrix, const Component *v, SwvFixedWord *out,
                              SwvFixedWord *w, int count)
{
    for (int i = 0; i < count; ++i, v += 3, out += 3) {
        transform3(matrix, v, out);
        int value = matrix.m[15];
        if (!matrix.affine)
            value += fixed_dot3(matrix, v, 3);
        w[i] = value >> std::min(matrix.w_shift, 31);
    }
}

template<class Component>
static void transform2(const CssIntMatrix &matrix, const Component *v, SwvFixedWord *out, SwvFixedWord *w)
{
    auto dot = [&](int row) {
        uint32_t sum = uint32_t(matrix.m[row]) * v[0] + uint32_t(matrix.m[4 + row]) * v[1];
        return static_cast<int>(sum) >> matrix.shift;
    };
    out[0] = matrix.m[12] + dot(0);
    out[1] = matrix.m[13] + dot(1);
    int value = matrix.m[15];
    if (!matrix.affine)
        value += dot(3);
    *w = value >> std::min(matrix.w_shift, 31);
}

void CssIntMatrix::Transform3Fixed(const int8_t *v, SwvFixedWord *out) const
{
    transform3(*this, v, out);
}

void CssIntMatrix::Transform3NFixed(const int8_t *v, SwvFixedWord *out) const
{
    transform_normal(*this, v, out);
}

void CssIntMatrix::Transform3Fixed4(const int8_t *v, SwvFixedWord *out, SwvFixedWord *w, int count) const
{
    transform3_with_w(*this, v, out, w, count);
}

void CssIntMatrix::Transform2Fixed(const int8_t *v, SwvFixedWord *out, SwvFixedWord *w) const
{
    transform2(*this, v, out, w);
}

void CssIntMatrix::Transform3Fixed(const int16_t *v, SwvFixedWord *out) const
{
    transform3(*this, v, out);
}

void CssIntMatrix::Transform3NFixed(const int16_t *v, SwvFixedWord *out) const
{
    transform_normal(*this, v, out);
}

void CssIntMatrix::Transform3Fixed4(const int16_t *v, SwvFixedWord *out, SwvFixedWord *w, int count) const
{
    transform3_with_w(*this, v, out, w, count);
}

void CssIntMatrix::Transform2Fixed(const int16_t *v, SwvFixedWord *out, SwvFixedWord *w) const
{
    transform2(*this, v, out, w);
}
