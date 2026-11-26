#include "cssstatics.hpp"
#include "object_classes.hpp"

CssRayIntersection *CssRayIntersection::Create()
{
    return new CssRayIntersection;
}

IssSerializable *CssRayIntersection::FactoryCreate()
{
    return new CssRayIntersection;
}

void CssRayIntersection::Initialize()
{
    g_Statics().ray_intersection = Create();
}

void CssRayIntersection::Uninitialize()
{
    CssStatics *statics = g_pStaticsNoLeave();
    if (!statics) return;
    delete statics->ray_intersection;
    statics->ray_intersection = nullptr;
}

CssRayIntersection *CssRayIntersection::GetInstance()
{
    if (!g_Statics().ray_intersection) Initialize();
    return g_Statics().ray_intersection;
}

CssRayIntersection &CssRayIntersection::operator=(const CssRayIntersection &source)
{
    SetIntersected(source.intersected);
    submesh = source.submesh;
    distance = source.distance;
    normal = source.normal;
    origin = source.origin;
    direction = source.direction;
    for (int unit = 0; unit < 2; ++unit) {
        s[unit] = source.s[unit];
        t[unit] = source.t[unit];
    }
    return *this;
}

float CssRayIntersection::GetTextureS(int unit) const
{
    if (unit < 0 || unit > 1) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    return s[unit];
}

float CssRayIntersection::GetTextureT(int unit) const
{
    if (unit < 0 || unit > 1) g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    return t[unit];
}

void CssRayIntersection::GetRay(int count, float *values) const
{
    if (count < 6) g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    for (int i = 0; i < 3; ++i) {
        values[i] = origin[i];
        values[i + 3] = direction[i];
    }
}
