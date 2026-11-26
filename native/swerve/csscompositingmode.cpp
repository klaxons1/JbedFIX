#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"

void CssCompositingMode::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssObject3D::SerializeIn(r);
    depth_test = r.ReadBool();
    depth_write = r.ReadBool();
    color_write = r.ReadBool();
    alpha_write = r.ReadBool();
    blending = r.ReadEnum(Alpha - 1, Replace + 1);
    threshold = r.ReadByte() * (1.0f / 255.0f);
    depth_factor = r.ReadReal();
    depth_units = r.ReadReal();
}

IssSerializable *CssCompositingMode::FactoryCreate()
{
    return new CssCompositingMode;
}

void CssCompositingMode::CloneHelper(const CssCompositingMode &source)
{
    CssObject3D::CloneHelper(source);
    color_write = source.color_write;
    alpha_write = source.alpha_write;
    depth_test = source.depth_test;
    depth_write = source.depth_write;
    blending = source.blending;
    threshold = source.threshold;
    depth_factor = source.depth_factor;
    depth_units = source.depth_units;
}

CssObject3D *CssCompositingMode::Clone() const
{
    CssHeapPtr<CssCompositingMode> copy(static_cast<CssCompositingMode *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}

void CssCompositingMode::SetDepthOffset(float factor, float units)
{
    depth_factor = factor;
    depth_units = units;
}
