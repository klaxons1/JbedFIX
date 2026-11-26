#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"

uint32_t CssMaterial::GetColor(EssColorTarget target) const
{
    switch (target) {
    case Ambient: return ambient.GetPackedRGBA8();
    case Diffuse: return diffuse.GetPackedRGBA8();
    case Emissive: return emissive.GetPackedRGBA8();
    case Specular: return specular.GetPackedRGBA8();
    }
    return 0;
}

void CssMaterial::SetColor(EssColorTarget targets, uint32_t color)
{
    if (!targets || (targets & ~(Ambient | Diffuse | Emissive | Specular)))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (targets & Ambient) ambient.SetPackedRGBA8(color & 0xffffff);
    if (targets & Emissive) emissive.SetPackedRGBA8(color & 0xffffff);
    if (targets & Specular) specular.SetPackedRGBA8(color & 0xffffff);
    if (targets & Diffuse) diffuse.SetPackedRGBA8(color);
}

void CssMaterial::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssObject3D::SerializeIn(r);
    r.ReadColorRGBA(ambient, false);
    r.ReadColorRGBA(diffuse, true);
    r.ReadColorRGBA(emissive, false);
    r.ReadColorRGBA(specular, false);
    shininess = r.ReadReal();
    if (shininess < 0 || shininess > 128) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    vertex_tracking = r.ReadBool();
}

IssSerializable *CssMaterial::FactoryCreate()
{
    return new CssMaterial;
}

void CssMaterial::CloneHelper(const CssMaterial &source)
{
    CssObject3D::CloneHelper(source);
    ambient = source.ambient;
    diffuse = source.diffuse;
    emissive = source.emissive;
    specular = source.specular;
    vertex_tracking = source.vertex_tracking;
    shininess = source.shininess;
}

CssObject3D *CssMaterial::Clone() const
{
    CssHeapPtr<CssMaterial> copy(static_cast<CssMaterial *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}

void CssMaterial::SetProperty(int p, int components, float *v)
{
    switch (p) {
    case CssAnimationTrack::Alpha: diffuse.SetAlpha(clamp(v[0], 1)); break;
    case CssAnimationTrack::AmbientColor: ambient.SetReals(v[0], v[1], v[2]); break;
    case CssAnimationTrack::DiffuseColor: diffuse.SetReals(v[0], v[1], v[2]); break;
    case CssAnimationTrack::EmissiveColor: emissive.SetReals(v[0], v[1], v[2]); break;
    case CssAnimationTrack::Shininess: shininess = clamp(v[0], 128); break;
    case CssAnimationTrack::SpecularColor: specular.SetReals(v[0], v[1], v[2]); break;
    default: CssObject3D::SetProperty(p, components, v); break;
    }
}

bool CssMaterial::HasAnimatableProperty(int p) const
{
    return p == CssAnimationTrack::Alpha || p == CssAnimationTrack::AmbientColor ||
           p == CssAnimationTrack::DiffuseColor || p == CssAnimationTrack::EmissiveColor ||
           p == CssAnimationTrack::Shininess || p == CssAnimationTrack::SpecularColor ||
           CssObject3D::HasAnimatableProperty(p);
}
