#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"
#include "image_class.hpp"
#include <climits>
#include <cstdlib>

CssTexture2D::~CssTexture2D()
{
    if (image) image->Release();
}

bool CssTexture2D::IsPowerOfTwo(int value)
{
    if (value == 0 || value == INT_MIN)
        return false;
    int magnitude = std::abs(value);
    while ((magnitude & 1) == 0)
        magnitude /= 2;
    return magnitude == 1;
}

static bool validTextureSize(const CssImage2D &image)
{
    return CssTexture2D::IsPowerOfTwo(image.GetWidth()) && image.GetWidth() <= SWV_MAX_TEXTURE_DIMENSION &&
           CssTexture2D::IsPowerOfTwo(image.GetHeight()) && image.GetHeight() <= SWV_MAX_TEXTURE_DIMENSION;
}

void CssTexture2D::SetImage(CssImage2D *value)
{
    image = static_cast<CssImage2D *>(CssRefCount::Assign(image, value));
    if (!validTextureSize(*image))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
}

void CssTexture2D::Construct(CssImage2D *value)
{
    SetImage(value);
}

void CssTexture2D::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssTransformable::SerializeIn(r);
    image = static_cast<CssImage2D *>(CssRefCount::Assign(image, r.ReadObjectRefImage2D(false)));
    if (!image || !validTextureSize(*image))
        g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    r.ReadColorRGBA(blend_color, false);
    blending = static_cast<EssBlending>(r.ReadEnum(Add - 1, Replace + 1));
    wrap_s = static_cast<EssWrap>(r.ReadEnum(Clamp - 1, Repeat + 1));
    wrap_t = static_cast<EssWrap>(r.ReadEnum(Clamp - 1, Repeat + 1));
    level_filter = static_cast<EssFilter>(r.ReadEnum(BaseLevel - 1, Nearest + 1));
    image_filter = static_cast<EssFilter>(r.ReadEnum(Linear - 1, Nearest + 1));
}

IssSerializable *CssTexture2D::FactoryCreate()
{
    return new CssTexture2D;
}

void CssTexture2D::CloneHelper(const CssTexture2D &source)
{
    CssTransformable::CloneHelper(source);
    image = static_cast<CssImage2D *>(CssRefCount::Assign(image, source.image));
    wrap_s = source.wrap_s;
    wrap_t = source.wrap_t;
    blend_color = source.blend_color;
    blending = source.blending;
}

CssObject3D *CssTexture2D::Clone() const
{
    CssHeapPtr<CssTexture2D> copy(static_cast<CssTexture2D *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}

void *CssTexture2D::GetpRef(int index)
{
    return index == 0 ? image : CssObject3D::GetpRef(index - 1);
}

void CssTexture2D::SetProperty(int p, int components, float *v)
{
    if (p == CssAnimationTrack::Color) blend_color.SetReals(v[0], v[1], v[2]);
    else CssTransformable::SetProperty(p, components, v);
}

SwvImageFormat CssTexture2D::GetDataFormat() const
{
    return static_cast<SwvImageFormat>(image->GetDataFormat());
}

void CssTexture2D::SetWrapping(EssWrap s, EssWrap t)
{
    wrap_s = s;
    wrap_t = t;
}

void CssTexture2D::SetFiltering(EssFilter level, EssFilter image)
{
    level_filter = level;
    image_filter = image;
}
