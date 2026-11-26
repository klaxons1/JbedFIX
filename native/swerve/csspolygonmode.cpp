#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"

void CssPolygonMode::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssObject3D::SerializeIn(r);
    unsigned cull = r.ReadEnum(CullBack - 1, CullNone + 1);
    flags = (flags & ~CullMask) | (BackFaceCulling << (cull - CullBack));
    unsigned shade = r.ReadEnum(Flat - 1, Smooth + 1);
    flags = (flags & ~ShadingMask) | (FlatShading << (shade - Flat));
    unsigned winding = r.ReadEnum(CounterClockwise - 1, Clockwise + 1);
    flags = (flags & ~WindingMask) | (CounterClockwiseWinding << (winding - CounterClockwise));
    flags = (flags & ~LightingMask) | (r.ReadBool() ? TwoSidedLighting : OneSidedLighting);
    if (r.ReadBool()) flags |= LocalCameraLighting;
    if (r.ReadBool()) flags |= PerspectiveCorrection;
}

IssSerializable *CssPolygonMode::FactoryCreate()
{
    return new CssPolygonMode;
}

void CssPolygonMode::CloneHelper(const CssPolygonMode &source)
{
    CssObject3D::CloneHelper(source);
    flags = source.flags;
}

CssObject3D *CssPolygonMode::Clone() const
{
    CssHeapPtr<CssPolygonMode> copy(static_cast<CssPolygonMode *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}

void CssPolygonMode::SetCulling(EssCulling mode)
{
    unsigned flag = (BackFaceCulling << (mode - CullBack));
    flags = (flags & ~CullMask) | flag;
}

void CssPolygonMode::SetShading(EssShading mode)
{
    unsigned flag = FlatShading << (mode - Flat);
    flags = (flags & ~ShadingMask) | flag;
}

void CssPolygonMode::SetWinding(EssWinding mode)
{
    unsigned flag = CounterClockwiseWinding << (mode - CounterClockwise);
    flags = (flags & ~WindingMask) | flag;
}
