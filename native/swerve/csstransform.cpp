#include "object_classes.hpp"
#include "geometry_class.hpp"
#include "cssquaternion.hpp"
#include "cssfixed1616.hpp"

IssSerializable *CssTransform::FactoryCreate() { return new CssTransform; }

void CssTransform::Construct(const CssTransform *from) { Set(from); }

void CssTransform::Get(int size, float *values) const
{
    if (size < 16)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    for (int row = 0; row < 4; ++row)
        for (int col = 0; col < 4; ++col)
            *values++ = matrix.m[4 * col + row];
}

void CssTransform::Set(int size, const float *values)
{
    if (size < 16)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    matrix.flags = MatrixGeneral;
    for (int row = 0; row < 4; ++row)
        for (int col = 0; col < 4; ++col)
            matrix.m[4 * col + row] = g_ValidateFloat(*values++);
    matrix.ResetMatrixType();
}

void CssTransform::Set(const CssTransform *from)
{
    matrix = from->matrix;
    matrix.ResetMatrixType();
}

void CssTransform::Transpose()
{
    matrix.Transpose();
    matrix.ResetMatrixType();
}

void CssTransform::SetIdentity() { matrix.Identity(); }

void CssTransform::Invert()
{
    if (!matrix.Invert())
        g_ssThrowLeave(SWV_LEAVE_DIVIDE_BY_ZERO);
    matrix.ResetMatrixType();
}

bool CssTransform::bInvertible() const
{
    CssMatrix copy(matrix);
    return copy.Invert();
}

void CssTransform::PostMultiply(CssTransform *right) { matrix *= right->matrix; }

void CssTransform::PostScale(const CssVector3D &scale)
{
    matrix *= CssMatrix(scale.x, scale.y, scale.z);
}

void CssTransform::PostTranslate(const CssVector3D &translation)
{
    matrix *= CssMatrix(translation);
}

void CssTransform::PostRotate(const CssQuaternion &rotation)
{
    CssMatrix right;
    CssQuaternion q = rotation;
    q.Normalize();
    q.Matrix(&right);
    matrix *= right;
}

void CssTransform::Transform(int count, float *points) const
{
    if (count & 3)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    for (int i = 0; i < count / 4; ++i, points += 4) {
        float w = g_ValidateFloat(points[3]);
        float z = g_ValidateFloat(points[2]);
        float y = g_ValidateFloat(points[1]);
        float x = g_ValidateFloat(points[0]);
        matrix.Mult4(x, y, z, w, points);
    }
}

void CssTransform::Transform(const CssVertexArray *vertices, int length, float *out, bool use_w) const
{
    if (length < 4 * vertices->count || (unsigned)(vertices->components - 2) > 1)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    for (int i = 0; i < vertices->count; ++i) {
        float z = vertices->components == 3 ? (float)vertices->Element(i, 2) : 0.0f;
        float y = (float)vertices->Element(i, 1);
        float x = (float)vertices->Element(i, 0);
        matrix.Mult4(x, y, z, use_w ? 1.0f : 0.0f, out + 4 * i);
    }
}
