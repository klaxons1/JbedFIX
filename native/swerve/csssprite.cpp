#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"
#include "image_class.hpp"
#include "cssfixed1616.hpp"
#include <algorithm>
#include <utility>

static int sprite_crop_size(float value)
{
    if (value < -SWV_MAX_SPRITE_CROP_DIMENSION) return -SWV_MAX_SPRITE_CROP_DIMENSION;
    if (value > float(SWV_MAX_SPRITE_CROP_DIMENSION)) return SWV_MAX_SPRITE_CROP_DIMENSION;
    return value < 0 ? -(int)(0.5f - value) : (int)(value + 0.5f);
}

void CssSprite::Construct(bool scale, CssImage2D *source, CssAppearance *style)
{
    scaled = scale;
    SetpImage(source);
    SetpAppearance(style);
}

void CssSprite::SetpImage(CssImage2D *value)
{
    image = static_cast<CssImage2D *>(CssRefCount::Assign(image, value));
    const int width = std::min<int>(image->GetWidth(), SWV_MAX_SPRITE_CROP_DIMENSION);
    const int height = std::min<int>(image->GetHeight(), SWV_MAX_SPRITE_CROP_DIMENSION);
    SetCrop(0, 0, width, height);
}

void CssSprite::SetpAppearance(CssAppearance *value)
{
    appearance = static_cast<CssAppearance *>(CssRefCount::Assign(appearance, value));
}

void CssSprite::CalcCropRectangle(SwvFixedWord &s0, SwvFixedWord &t0, SwvFixedWord &s1, SwvFixedWord &t1) const
{
    auto endpoints = [](float origin, float size, int extent, SwvFixedWord &start, SwvFixedWord &end) {
        int p = toFixed16(origin);
        int span = toFixed16(size);
        int reciprocal = g_divide_int64_int64(65536, extent);
        start = (int64_t(reciprocal) * p) >> 16;
        int opposite = span < 0 ? p - span : p + span;
        end = (int64_t(reciprocal) * opposite) >> 16;
        if (span <= 0)
            std::swap(start, end);
    };
    endpoints(x, width, image->GetWidth(), s0, s1);
    endpoints(y, height, image->GetHeight(), t0, t1);
}

void CssSprite::SerializeIn(CssSerializeBufferObjectsIn &r)
{
    CssNode::SerializeIn(r);
    image = assign_ref(image, r.ReadObjectRefImage2D(false));
    if (!image) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    appearance = assign_ref(appearance, r.ReadObjectRefTypeChecked(AppearanceObject));
    if (!appearance) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    scaled = r.ReadBool();
    x = static_cast<float>(r.ReadInt());
    y = static_cast<float>(r.ReadInt());
    int width = r.ReadInt();
    int height = r.ReadInt();
    if ((width != INT32_MIN && (width < -SWV_MAX_SPRITE_CROP_DIMENSION || width > SWV_MAX_SPRITE_CROP_DIMENSION)) ||
        (height != INT32_MIN && (height < -SWV_MAX_SPRITE_CROP_DIMENSION || height > SWV_MAX_SPRITE_CROP_DIMENSION))) g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    this->width = (float)width;
    this->height = (float)height;
}

IssSerializable *CssSprite::FactoryCreate()
{
    return new CssSprite;
}

void CssSprite::CloneHelper(const CssSprite &source)
{
    CssNode::CloneHelper(source);
    height = source.height;
    width = source.width;
    x = source.x;
    y = source.y;
    image = assign_ref(image, source.image);
    appearance = assign_ref(appearance, source.appearance);
    scaled = source.scaled;
}

CssObject3D *CssSprite::Clone() const
{
    CssHeapPtr<CssSprite> copy(static_cast<CssSprite *>(FactoryCreate()));
    copy->CloneHelper(*this);
    copy->FixupAlignmentReferences(this, this, copy.get());
    return copy.release();
}

void *CssSprite::GetpRef(int index)
{
    void *refs[] = {image, appearance};
    return index < 2 ? refs[index] : CssObject3D::GetpRef(index - 2);
}

int CssSprite::AnimateRefs(int time, int validity, int stamp)
{
    return limit_validity(validity, appearance, time, stamp);
}

void CssSprite::SetProperty(int p, int components, float *v)
{
    if (p == CssAnimationTrack::Crop) {
        x = v[0]; y = v[1];
        width = (float)sprite_crop_size(v[2]);
        height = (float)sprite_crop_size(v[3]);
    } else {
        CssNode::SetProperty(p, components, v);
    }
}

CssSprite::~CssSprite()
{
    if (image) image->Release();
    if (appearance) appearance->Release();
}

void CssSprite::SetCrop(int x, int y, int width, int height)
{
    this->x = (float)x;
    this->y = (float)y;
    this->width = (float)width;
    this->height = (float)height;
}
