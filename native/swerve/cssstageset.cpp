#include "image_class.hpp"
#include "cssserializebufferobjectsin.hpp"
#include "object_classes.hpp"
#include "cssfixed1616.hpp"

CssObject3D *CssStageset::Clone() const
{
    CssHeapPtr<CssStageset> copy(static_cast<CssStageset *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}

void CssStageset::CloneHelper(const CssStageset &source)
{
    CssImage2D::CloneHelper(source);
    depth = source.depth;
    scale = source.scale;
    bias = source.bias;
    dirty = source.dirty;
}

void CssStageset::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    CssImage2D::SerializeIn(reader);
    bias = reader.ReadReal();
    scale = reader.ReadReal();
    int n = width * height;
    depth.SetSize(n);
    if (is_mutable) {
        memset(depth.data, 255, (size_t)n * 2);
    } else {
        auto *d = static_cast<uint16_t *>(depth.data);
        for (int i = 0; i < n; ++i)
            d[i] = reader.ReadUInt16();
    }
}

void CssStageset::Set(int x, int y, int w, int h, int size, const uint8_t *data)
{
    CssImage2D::Set(x, y, w, h, size, data);
    int n = w * h, channels = GetcBytesPerFormat(format);
    if (size < (int)((unsigned)n * (channels + 2)))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    auto *dst = static_cast<uint16_t *>(depth.data);
    data += (size_t)n * channels;
    for (int i = 0; i < h; ++i) {
        memcpy(dst + (y + i) * width + x, data, (size_t)w * 2);
        data += (size_t)w * 2;
    }
}

void CssStageset::Construct(int w, int h, int size, const uint8_t *data)
{
    CssImage2D::Construct(RGB, w, h, size, data);
    int n = w * h;
    if (size < (int)(5u * n))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    depth.SetSize(n);
    memcpy(depth.data, data + (size_t)n * 3, (size_t)n * 2);
}

void CssStageset::Construct(int w, int h)
{
    CssImage2D::Construct(RGB, w, h, false);
    depth.SetSize(w * h);
    memset(depth.data, 255, (size_t)w * h * 2);
}

/* StageSet stores eye-space distances until its first world background draw. */
void CssStageset::Rescale(const CssCamera *camera)
{
    if (!dirty)
        return;
    float near = camera->near_plane, far = camera->far_plane;
    if (camera->projection_type == CssCamera::Parallel || camera->projection_type == CssCamera::Perspective) {
        float scale = 4095.0f;
        bool perspective = camera->projection_type == CssCamera::Perspective;
        if (perspective)
            scale = far * scale;
        scale /= (far - near);
        auto *values = static_cast<uint16_t *>(depth.data);
        for (int i = 0; i < depth.size; ++i) {
            float z = values[i] ? (float)values[i] * this->scale + bias : far;
            z = z >= far ? far : z < near ? near : z;
            z = perspective ? 1 - near * (1 / z) : z - near;
            values[i] = (uint16_t)(saturatingTruncate(z * scale * 65536.0f) >> 12);
        }
    }
    dirty = 0;
}
