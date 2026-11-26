#include "cssmatrix.hpp"

CssVector3D &CssVector3D::operator*=(float scale)
{
    x *= scale;
    y *= scale;
    z *= scale;
    return *this;
}

CssVector3D CssVector3D::operator%(const CssVector3D &right) const
{
    return {y * right.z - z * right.y,
            z * right.x - x * right.z,
            x * right.y - y * right.x};
}

CssVector3D &CssVector3D::operator%=(const CssVector3D &right)
{
    const CssVector3D left = *this;
    x = left.y * right.z - left.z * right.y;
    y = left.z * right.x - left.x * right.z;
    z = left.x * right.y - left.y * right.x;
    return *this;
}

void CssVector3D::Lerp(const CssVector3D &a, const CssVector3D &b, float t)
{
    *this = b;
    *this -= a;
    *this *= t;
    *this += a;
}

void CssVector3D::Unit()
{
    float norm = Magnitude2();
    if (norm == 0) {
        x = y = z = 0;
    } else if (norm != 1) {
        *this *= g_float_reciprocal_sqrt(norm);
    }
}

static int32_t fixed_abs(int32_t x)
{
    return x < 0 ? (int32_t)(0u - (uint32_t)x) : x;
}

static int32_t fixed_product(int32_t a, int32_t b)
{
    return (int32_t)(((int64_t)a * b) >> 16);
}

CssFixedVector3D::CssFixedVector3D(CssVector3D &v)
    : x(toFixed16(v.x)),
      y(toFixed16(v.y)),
      z(toFixed16(v.z))
{
}

SwvFixedWord CssFixedVector3D::operator*(const CssFixedVector3D &v) const
{
    return static_cast<SwvFixedWord>((int64_t(x) * v.x + int64_t(y) * v.y + int64_t(z) * v.z) >> 16);
}

CssFixedVector3D &CssFixedVector3D::operator*=(SwvFixedWord scale)
{
    x = fixed_product(x, scale);
    y = fixed_product(y, scale);
    z = fixed_product(z, scale);
    return *this;
}

void CssFixedVector3D::ReScale()
{
    int32_t bits = fixed_abs(x) | fixed_abs(y) | fixed_abs(z);
    if (bits == 0)
        return;
    /* Squaring uses a fixed 16-bit shift. Bring the largest component into
     * [1,2] first to keep the products in range. */
    if (bits > 0x20000) {
        unsigned shift = 0;
        do {
            bits >>= 1;
            ++shift;
        } while (bits > 0x20000);
        x >>= shift;
        y >>= shift;
        z >>= shift;
    } else if (bits < 0x10000) {
        unsigned shift = 0;
        do {
            bits = (int32_t)((uint32_t)bits * 2);
            ++shift;
        } while (bits < 0x10000);
        x = (int32_t)((uint32_t)x << shift);
        y = (int32_t)((uint32_t)y << shift);
        z = (int32_t)((uint32_t)z << shift);
    }
}

void CssFixedVector3D::Unit()
{
    ReScale();
    *this *= g_fixed_reciprocal_sqrt(Magnitude2());
}

unsigned CssFixedVector3D::PreScale()
{
    int32_t bits = fixed_abs(x) | fixed_abs(y) | fixed_abs(z);
    unsigned shift = 0;
    while (bits > 0x400000) {
        bits >>= 2;
        shift += 2;
    }
    x >>= shift;
    y >>= shift;
    z >>= shift;
    return shift;
}
