#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"

void CssLight::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssNode::SerializeIn(r);
    constant = r.ReadReal();
    linear = r.ReadReal();
    quadratic = r.ReadReal();
    if (constant < 0 || linear < 0 || quadratic < 0 ||
        !(constant || linear || quadratic)) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    r.ReadColorRGBA(color, false);
    mode = r.ReadEnum(Ambient - 1, Spot + 1);
    intensity = r.ReadReal();
    spot_angle = r.ReadReal();
    if (spot_angle < 0 || spot_angle > 90) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    spot_exponent = r.ReadReal();
    if (spot_exponent < 0 || spot_exponent > 128) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
}

IssSerializable *CssLight::FactoryCreate()
{
    return new CssLight;
}

void CssLight::CloneHelper(const CssLight &source)
{
    CssNode::CloneHelper(source);
    constant = source.constant;
    linear = source.linear;
    color = source.color;
    intensity = source.intensity;
    spot_angle = source.spot_angle;
    spot_exponent = source.spot_exponent;
    mode = source.mode;
}

CssObject3D *CssLight::Clone() const
{
    CssHeapPtr<CssLight> copy(static_cast<CssLight *>(FactoryCreate()));
    copy->CloneHelper(*this);
    copy->FixupAlignmentReferences(this, this, copy.get());
    return copy.release();
}

void CssLight::SetProperty(int p, int components, float *v)
{
    switch (p) {
    case CssAnimationTrack::Color: color.SetReals(v[0], v[1], v[2]); break;
    case CssAnimationTrack::Intensity: intensity = v[0]; break;
    case CssAnimationTrack::SpotAngle: spot_angle = clamp(v[0], 90); break;
    case CssAnimationTrack::SpotExponent: spot_exponent = clamp(v[0], 128); break;
    default: CssNode::SetProperty(p, components, v); break;
    }
    dirty = 1;
}

bool CssLight::HasAnimatableProperty(int p) const
{
    return p == CssAnimationTrack::Color || p == CssAnimationTrack::Intensity ||
           p == CssAnimationTrack::SpotAngle || p == CssAnimationTrack::SpotExponent ||
           CssNode::HasAnimatableProperty(p);
}

void CssLight::SetMatrixCacheDirty() const
{
    CssNode::SetMatrixCacheDirty();
    dirty = 1;
}

void CssLight::SetScope(int new_scope)
{
    CssNode::SetScope(new_scope);
    dirty = 1;
}

void CssLight::SetRenderingEnabled(bool enabled)
{
    CssNode::SetRenderingEnabled(enabled);
    dirty = 1;
}

void CssLight::SetMode(EssMode value)
{
    mode = value;
    dirty = 1;
}

void CssLight::SetColor(unsigned int value)
{
    color.SetPackedRGBA8(value & 0xffffff);
    dirty = 1;
}

void CssLight::SetIntensity(float value)
{
    intensity = value;
    dirty = 1;
}

void CssLight::SetSpotAngle(float value)
{
    spot_angle = value;
    dirty = 1;
}

void CssLight::SetSpotExponent(float value)
{
    spot_exponent = value;
    dirty = 1;
}

void CssLight::SetAttenuation(float constant, float linear, float quadratic)
{
    this->constant = constant;
    this->linear = linear;
    this->quadratic = quadratic;
    dirty = 1;
}
