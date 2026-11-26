#ifndef JBED_SWERVE_CSSQUATERNION_HPP
#define JBED_SWERVE_CSSQUATERNION_HPP

struct CssVector3D;
struct CssMatrix;

class CssQuaternion {
public:
    float q[4];

    CssQuaternion() : q{0, 0, 0, 1} {}
    CssQuaternion(float a, float b, float c, float d) : q{b, c, d, a} {}
    CssQuaternion(float radians, const CssVector3D &axis);
    explicit CssQuaternion(const CssMatrix &matrix);

    void Normalize();
    void Matrix(CssMatrix *matrix) const;
    void GetAxisAndAngle(CssVector3D *axis, float *radians) const;
    CssQuaternion &operator*=(float scale);
    CssQuaternion &operator*=(const CssQuaternion &right);
    bool operator==(const CssQuaternion &other) const;
    void PreMultiply(const CssQuaternion &left);
    CssQuaternion Inverse() const { return CssQuaternion(q[3], -q[0], -q[1], -q[2]); }
    void Log();
    void Exp();
    void SquadLogDiff(const CssQuaternion &a, const CssQuaternion &b);
    static void SquadLogDiff(float *out, const float *a, const float *b);
    static void Slerp(float *out, const float *a, const float *b, float t);
    void Slerp(const CssQuaternion &a, const CssQuaternion &b, float t);
    static void Squad(float *out, const float *a, const float *ta, const float *tb, const float *b, float t);
    void Squad(const CssQuaternion &a, const CssQuaternion &ta, const CssQuaternion &tb,
               const CssQuaternion &b, float t);
};
CssQuaternion readAxisAngle(const float *values);
#endif
