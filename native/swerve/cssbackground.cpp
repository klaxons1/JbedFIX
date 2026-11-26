#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"
#include "image_class.hpp"

CssBackground::~CssBackground()
{
    if (image) image->Release();
}

void CssBackground::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssObject3D::SerializeIn(r);
    r.ReadColorRGBA(color, true);
    image = assign_ref(image, r.ReadObjectRefImage2D(true));
    mode_x = r.ReadEnum(Border - 1, Repeat + 1);
    mode_y = r.ReadEnum(Border - 1, Repeat + 1);
    x = static_cast<float>(r.ReadInt());
    y = static_cast<float>(r.ReadInt());
    width = static_cast<float>(r.ReadInt());
    height = static_cast<float>(r.ReadInt());
    if (width < 0 || height < 0) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    color_clear = r.ReadBool();
    depth_clear = r.ReadBool();
}

IssSerializable *CssBackground::FactoryCreate()
{
    return new CssBackground;
}

void CssBackground::CloneHelper(const CssBackground &source)
{
    CssObject3D::CloneHelper(source);
    color = source.color;
    image = assign_ref(image, source.image);
    mode_x = source.mode_x;
    mode_y = source.mode_y;
    x = source.x;
    y = source.y;
    width = source.width;
    height = source.height;
    color_clear = source.color_clear;
    depth_clear = source.depth_clear;
}

CssObject3D *CssBackground::Clone() const
{
    CssHeapPtr<CssBackground> copy(static_cast<CssBackground *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}

void *CssBackground::GetpRef(int index)
{
    return index == 0 ? image : CssObject3D::GetpRef(index - 1);
}

void CssBackground::SetProperty(int p, int components, float *v)
{
    switch (p) {
    case CssAnimationTrack::Alpha: color.SetAlpha(clamp(v[0], 1)); break;
    case CssAnimationTrack::Color: color.SetReals(v[0], v[1], v[2]); break;
    case CssAnimationTrack::Crop: x = v[0]; y = v[1]; width = v[2]; height = v[3]; break;
    default: CssObject3D::SetProperty(p, components, v); break;
    }
}

void CssBackground::SetImageCrop(int x, int y, int width, int height)
{
    this->x = (float)x;
    this->y = (float)y;
    this->width = (float)width;
    this->height = (float)height;
}
