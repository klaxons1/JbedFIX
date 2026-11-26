#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"

void CssFog::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssObject3D::SerializeIn(r);
    r.ReadColorRGBA(color, false);
    mode = r.ReadEnum(Exponential - 1, Linear + 1);
    if (mode == Exponential) {
        density = r.ReadReal();
    } else {
        near_distance = r.ReadReal();
        far_distance = r.ReadReal();
        if (nearZero(near_distance - far_distance))
            g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    }
}

IssSerializable *CssFog::FactoryCreate()
{
    return new CssFog;
}

void CssFog::CloneHelper(const CssFog &source)
{
    CssObject3D::CloneHelper(source);
    color = source.color;
    density = source.density;
    near_distance = source.near_distance;
    far_distance = source.far_distance;
    mode = source.mode;
}

CssObject3D *CssFog::Clone() const
{
    CssHeapPtr<CssFog> copy(static_cast<CssFog *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}

void CssFog::SetProperty(int p, int components, float *v)
{
    switch (p) {
    case CssAnimationTrack::Color: color.SetReals(v[0], v[1], v[2]); break;
    case CssAnimationTrack::Density: density = v[0] < 0 ? 0 : v[0]; break;
    case CssAnimationTrack::FarDistance: far_distance = v[0]; break;
    case CssAnimationTrack::NearDistance: near_distance = v[0]; break;
    default: CssObject3D::SetProperty(p, components, v); break;
    }
}

void CssFog::SetLinear(float near_distance, float far_distance)
{
    this->near_distance = near_distance;
    this->far_distance = far_distance;
}
