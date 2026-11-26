#include "legacy_math.hpp"
#include "cssmatrix.hpp"
#include <cfloat>
#include <cmath>
#include <cstring>

static float square(float x)
{
    return x * x;
}

static float quaternion_norm(const float q[4])
{
    return square(q[3]) + square(q[0]) + square(q[1]) + square(q[2]);
}

static float norm3(const float v[3])
{
    return square(v[0]) + square(v[1]) + square(v[2]);
}

CssQuaternion &CssQuaternion::operator*=(float scale)
{
    q[3] *= scale;
    for (int i = 0; i < 3; ++i)
        q[i] *= scale;
    return *this;
}

void CssQuaternion::Normalize()
{
    float norm = quaternion_norm(q);
    if (norm <= FLT_MIN || norm == 1)
        return;
    *this *= g_float_reciprocal_sqrt(norm);
}

CssQuaternion::CssQuaternion(float radians, const CssVector3D &axis)
{
    float half = radians * 0.5f;
    float sine = legacy_math::sin(half);
    CssVector3D v = axis;
    v.Unit();
    q[3] = legacy_math::cos(half);
    for (int i = 0; i < 3; ++i)
        q[i] = v[i] * sine;
}

void CssQuaternion::GetAxisAndAngle(CssVector3D *axis, float *radians) const
{
    float length = std::sqrt(norm3(q));
    int32_t angle = g_fixed_atan2(toFixed16(length), toFixed16(q[3]));
    *radians = (float)angle / 32768.0f;
    if (nearZero(length)) {
        (*axis)[0] = (*axis)[1] = 0;
        (*axis)[2] = 1;
    } else {
        float inv = 1 / length;
        for (int i = 0; i < 3; ++i)
            (*axis)[i] = q[i] * inv;
    }
}

void CssQuaternion::Matrix(CssMatrix *m) const
{
    m->Identity();
    float w = q[3];
    if (w == 1 || w == -1)
        return;
    float n = quaternion_norm(q);
    float f = n > 0 ? (2 - n) * 2.0f : n;
    float x = q[0], y = q[1], z = q[2];
    float sx = x * f, sy = y * f, sz = z * f;
    float xx = x * sx, yy = y * sy, zz = z * sz;
    float xy = x * sy, xz = x * sz, yz = y * sz;
    float wx = w * sx, wy = w * sy, wz = w * sz;
    m->m[0] = 1 - (yy + zz);
    m->m[1] = xy + wz;
    m->m[2] = xz - wy;
    m->m[4] = xy - wz;
    m->m[5] = 1 - (xx + zz);
    m->m[6] = yz + wx;
    m->m[8] = xz + wy;
    m->m[9] = yz - wx;
    m->m[10] = 1 - (xx + yy);
    m->flags = MatrixLinear;
}

static void multiply(CssQuaternion &out, const CssQuaternion &left, const CssQuaternion &right)
{
    float w = left.q[3] * right.q[3];
    for (int i = 0; i < 3; ++i)
        w -= left.q[i] * right.q[i];
    out.q[3] = w;
    for (int i = 0; i < 3; ++i) {
        int j = (i + 1) % 3, k = (i + 2) % 3;
        float v = left.q[3] * right.q[i] + left.q[i] * right.q[3];
        out.q[i] = v + left.q[j] * right.q[k] - left.q[k] * right.q[j];
    }
}

CssQuaternion &CssQuaternion::operator*=(const CssQuaternion &right)
{
    const CssQuaternion left(*this);
    multiply(*this, left, right);
    return *this;
}

void CssQuaternion::PreMultiply(const CssQuaternion &left)
{
    const CssQuaternion right(*this);
    multiply(*this, left, right);
}

bool CssQuaternion::operator==(const CssQuaternion &other) const
{
    return q[0] == other.q[0] && q[1] == other.q[1] && q[2] == other.q[2] && q[3] == other.q[3];
}

CssQuaternion::CssQuaternion(const CssMatrix &matrix)
{
    const float *m = matrix.m;
    float trace = m[0] + 1 + m[5] + m[10];
    if (trace > realEpsilon) {
        float half_inv = g_float_reciprocal_sqrt(trace) * 0.5f;
        q[3] = 0.25f / half_inv;
        q[0] = (m[6] - m[9]) * half_inv;
        q[1] = (m[8] - m[2]) * half_inv;
        q[2] = (m[1] - m[4]) * half_inv;
        return;
    }
    int axis = m[0] > m[5] && m[0] > m[10] ? 0 : m[5] > m[10] ? 1 : 2;
    int first = axis == 0 ? 1 : 0;
    int second = axis == 2 ? 1 : 2;
    float root =
        std::sqrt(m[5 * axis] + 1 - m[5 * first] - m[5 * second]);
    float twice = root * 2.0f, inv = 1 / twice;
    q[axis] = twice * 0.25f;
    q[first] = (m[4 * axis + first] + m[4 * first + axis]) * inv;
    q[second] = (m[4 * axis + second] + m[4 * second + axis]) * inv;
    q[3] = (m[4 * second + first] - m[4 * first + second]) * inv;
}

void CssQuaternion::Slerp(float *out, const float *a, const float *b, float t)
{
    if (t == 0 || t == 1) {
        const float *src = t == 0 ? a : b;
        for (int i = 0; i < 4; ++i)
            out[i] = src[i];
        return;
    }
    float cosine = a[3] * b[3];
    for (int i = 0; i < 3; ++i)
        cosine += a[i] * b[i];
    float left = 1 - t, right = t;
    if (cosine < 0.9999f) {
        float sine = std::sqrt(1 - cosine * cosine);
        if (sine > 0.00003f) {
            float angle =
                (float)g_fixed_atan2(toFixed16(sine), toFixed16(cosine)) / 65536.0f;
            left = legacy_math::sin(left * angle) / sine;
            right = legacy_math::sin(right * angle) / sine;
        }
    }
    for (int i = 0; i < 4; ++i)
        out[i] = a[i] * left + b[i] * right;
    float correction = (3 - quaternion_norm(out)) * 0.5f;
    for (int i = 0; i < 4; ++i)
        out[i] *= correction;
}

void CssQuaternion::Slerp(const CssQuaternion &a, const CssQuaternion &b, float t)
{
    Slerp(q, a.q, b.q, t);
}

void CssQuaternion::Squad(float *out, const float *a, const float *tangent_a,
                          const float *tangent_b, const float *b, float t)
{
    float points[4], tangents[4];
    Slerp(points, a, b, t);
    Slerp(tangents, tangent_a, tangent_b, t);
    Slerp(out, points, tangents, (1 - t) * t * 2.0f);
}

void CssQuaternion::Squad(const CssQuaternion &a, const CssQuaternion &tangent_a,
                          const CssQuaternion &tangent_b, const CssQuaternion &b, float t)
{
    Squad(q, a.q, tangent_a.q, tangent_b.q, b.q, t);
}

void CssQuaternion::Log()
{
    float length = std::sqrt(norm3(q));
    if (length > realEpsilon) {
        int32_t angle = g_fixed_atan2(toFixed16(length), toFixed16(q[3]));
        float ratio = (float)angle / 65536.0f / length;
        for (int i = 0; i < 3; ++i)
            q[i] *= ratio;
    }
    q[3] = 0;
}

void CssQuaternion::Exp()
{
    float length = std::sqrt(norm3(q));
    if (length > realEpsilon) {
        float ratio = legacy_math::sin(length) / length;
        for (int i = 0; i < 3; ++i)
            q[i] *= ratio;
    }
    q[3] = legacy_math::cos(length);
}

void CssQuaternion::SquadLogDiff(const CssQuaternion &a, const CssQuaternion &b)
{
    *this = a.Inverse();
    *this *= b;
    Normalize();
    Log();
}

static CssQuaternion from_components(const float v[4])
{
    return CssQuaternion(v[3], v[0], v[1], v[2]);
}

void CssQuaternion::SquadLogDiff(float *out, const float *a, const float *b)
{
    const CssQuaternion start = from_components(a), end = from_components(b);
    CssQuaternion result;
    result.SquadLogDiff(start, out == b ? result : end);
    memcpy(out, result.q, sizeof result.q);
}
