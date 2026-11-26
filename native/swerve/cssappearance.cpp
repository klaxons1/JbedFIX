#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"

void CssAppearance::SetCompositingMode(CssCompositingMode *mode)
{
    compositing = static_cast<CssCompositingMode *>(CssRefCount::Assign(compositing, mode));
}

void CssAppearance::SetFog(CssFog *value)
{
    fog = static_cast<CssFog *>(CssRefCount::Assign(fog, value));
}

void CssAppearance::SetMaterial(CssMaterial *value)
{
    material = static_cast<CssMaterial *>(CssRefCount::Assign(material, value));
}

void CssAppearance::SetPolygonMode(CssPolygonMode *mode)
{
    polygon = static_cast<CssPolygonMode *>(CssRefCount::Assign(polygon, mode));
}

void CssAppearance::SetTexture(int unit, CssTexture2D *texture)
{
    if ((unsigned)unit >= 2)
        g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    textures[unit] = static_cast<CssTexture2D *>(CssRefCount::Assign(textures[unit], texture));
}

CssTexture2D *CssAppearance::GetTexture(int unit) const
{
    if ((unsigned)unit >= 2)
        g_ssThrowLeave(SWV_LEAVE_INVALID_DATA_RANGE);
    return textures[unit];
}

void CssAppearance::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssObject3D::SerializeIn(r);
    layer = r.ReadByte();
    if (layer > MaxLayer) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    compositing = assign_ref(compositing, r.ReadObjectRefTypeChecked(CompositingModeObject));
    fog = assign_ref(fog, r.ReadObjectRefTypeChecked(FogObject));
    polygon = assign_ref(polygon, r.ReadObjectRefTypeChecked(PolygonModeObject));
    material = assign_ref(material, r.ReadObjectRefTypeChecked(MaterialObject));
    int count = r.ReadCount(4);
    for (int i = 0; i < count; ++i) {
        IssSerializable *texture = r.ReadObjectRefTypeChecked(Texture2DObject);
        if (!texture) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
        if (i < 2) textures[i] = assign_ref(textures[i], texture);
    }
}

IssSerializable *CssAppearance::FactoryCreate()
{
    return new CssAppearance;
}

void CssAppearance::CloneHelper(const CssAppearance &source)
{
    CssObject3D::CloneHelper(source);
    layer = source.layer;
    compositing = assign_ref(compositing, source.compositing);
    fog = assign_ref(fog, source.fog);
    polygon = assign_ref(polygon, source.polygon);
    material = assign_ref(material, source.material);
    for (int unit = 0; unit < 2; ++unit)
        textures[unit] = assign_ref(textures[unit], source.textures[unit]);
}

CssObject3D *CssAppearance::Clone() const
{
    CssHeapPtr<CssAppearance> copy(static_cast<CssAppearance *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}

void *CssAppearance::GetpRef(int index)
{
    void *refs[] = {compositing, fog, polygon, material, textures[0], textures[1]};
    return index < 6 ? refs[index] : CssObject3D::GetpRef(index - 6);
}

int CssAppearance::AnimateRefs(int time, int validity, int stamp)
{
    CssObject3D *animated[] = {fog, material, textures[0], textures[1]};
    for (unsigned i = 0; i < 4; ++i)
        validity = limit_validity(validity, animated[i], time, stamp);
    return validity;
}

CssAppearance::~CssAppearance()
{
    if (compositing) compositing->Release();
    if (fog) fog->Release();
    if (polygon) polygon->Release();
    if (material) material->Release();
    for (CssTexture2D *texture : textures)
        if (texture) texture->Release();
}
