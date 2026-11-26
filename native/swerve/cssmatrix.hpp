#ifndef SWERVE_CSSMATRIX_HPP
#define SWERVE_CSSMATRIX_HPP

#include "cssfixed1616.hpp"
#include "cssquaternion.hpp"
#include <cmath>

enum MatrixFlags : unsigned {
    MatrixGeneralFlag = 1, MatrixAffineFlag = 2, MatrixLinearFlag = 4,
    MatrixScaleFlag = 8, MatrixTranslationFlag = 16, MatrixIdentityFlag = 32
};

enum EssMatrixType : int {
    MatrixGeneral = MatrixGeneralFlag,
    MatrixAffine = MatrixGeneralFlag | MatrixAffineFlag,
    MatrixLinear = MatrixGeneralFlag | MatrixAffineFlag | MatrixLinearFlag,
    MatrixScale = MatrixGeneralFlag | MatrixAffineFlag | MatrixLinearFlag | MatrixScaleFlag,
    MatrixTranslation = MatrixGeneralFlag | MatrixAffineFlag | MatrixTranslationFlag,
    MatrixIdentity = MatrixGeneralFlag | MatrixAffineFlag | MatrixLinearFlag | MatrixScaleFlag |
                     MatrixTranslationFlag | MatrixIdentityFlag
};

struct CssVector3D;

struct CssFixedVector3D {
    SwvFixedWord x = 0, y = 0, z = 0;
    CssFixedVector3D() = default;
    CssFixedVector3D(SwvFixedWord x, SwvFixedWord y, SwvFixedWord z) : x(x), y(y), z(z) {}
    explicit CssFixedVector3D(CssVector3D &v);
    CssFixedVector3D operator-() const { return {-x, -y, -z}; }
    CssFixedVector3D operator-(const CssFixedVector3D &v) const { return {x - v.x, y - v.y, z - v.z}; }
    SwvFixedWord operator*(const CssFixedVector3D &v) const;
    CssFixedVector3D &operator*=(SwvFixedWord scale);
    SwvFixedWord Magnitude2() const { return *this * *this; }
    SwvFixedWord Magnitude() const { return g_fixed_sqrt(Magnitude2()); }
    void Unit();
    unsigned PreScale();
    void ReScale();
};

struct CssVector3D {
    float x = 0, y = 0, z = 0;
    void Unit();
    CssVector3D &operator+=(const CssVector3D &v) { x += v.x; y += v.y; z += v.z; return *this; }
    CssVector3D &operator-=(const CssVector3D &v) { x -= v.x; y -= v.y; z -= v.z; return *this; }
    CssVector3D operator+(const CssVector3D &v) const { return {x + v.x, y + v.y, z + v.z}; }
    CssVector3D operator-(const CssVector3D &v) const { return {x - v.x, y - v.y, z - v.z}; }
    float operator*(const CssVector3D &v) const { return x * v.x + y * v.y + z * v.z; }
    float Magnitude2() const { return *this * *this; }
    float Magnitude() const { return std::sqrt(Magnitude2()); }
    CssVector3D &operator*=(float scale);
    CssVector3D operator%(const CssVector3D &right) const;
    CssVector3D &operator%=(const CssVector3D &right);
    void Lerp(const CssVector3D &a, const CssVector3D &b, float t);
    float &operator[](int i) { return i == 0 ? x : i == 1 ? y : z; }
    const float &operator[](int i) const { return i == 0 ? x : i == 1 ? y : z; }
};

struct CssMatrix {
    float m[16];
    unsigned flags;
    void Identity();
    void ResetMatrixType();
    CssMatrix() : flags(MatrixIdentityFlag) {}
    explicit CssMatrix(EssMatrixType type);
    CssMatrix(float xx, float xy, float xz, float xw,
              float yx, float yy, float yz, float yw,
              float zx, float zy, float zz, float zw,
              float tx, float ty, float tz, float tw)
        : m{xx, xy, xz, xw, yx, yy, yz, yw, zx, zy, zz, zw, tx, ty, tz, tw}, flags(MatrixGeneral) {}
    CssMatrix(float x, float y, float z);
    explicit CssMatrix(const CssVector3D &translation);
    CssMatrix(float radians, const CssVector3D &axis);
    void MultiplyAffineAffine(float *out, const float *left, const float *right, bool linear);
    void MultiplyGeneralAffine(float *out, const float *left, const float *right);
    void MultiplyGeneralGeneral(float *out, const float *left, const float *right);
    void Scale(float uniform);
    void Scale(float x, float y, float z);
    void Translate(const CssVector3D &offset);
    void Translate(float x, float y, float z);
    void Rotate(float radians, const CssVector3D &axis);
    void PreMultiply(const CssMatrix &left);
    CssMatrix &operator*=(const CssMatrix &right);
    CssMatrix &operator+=(const CssMatrix &right);
    CssMatrix &operator-=(const CssMatrix &right);
    bool operator==(const CssMatrix &right) const;
    bool Invert();
    bool InverseTranspose();
    void Transpose();
    void Mult4(float x, float y, float z, float w, float out[4]) const;
    CssVector3D operator*(const CssVector3D &v) const;
    void TransformNormal(CssVector3D &out, const CssVector3D &in) const;
    CssVector3D Transform4Dto3D(const CssVector3D &v, float w) const;
    CssVector3D Transform3Dto4D(const CssVector3D &v, float *w) const;
    float GetMaxScale() const;
};

struct SssTransformComponents {
    CssVector3D translation{}, scale{};
    CssQuaternion orientation;
    CssMatrix *general;
    CssMatrix composite;
};

#endif
