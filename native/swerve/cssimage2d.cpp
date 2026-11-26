#include "image_class.hpp"
#include "cssserializebufferobjectsin.hpp"

namespace {
constexpr int PaletteEntries = 256;
constexpr int MinimumIndexedStorage = PaletteEntries * sizeof(uint16_t);
constexpr int ImageDimensionBits = 15;
}

int CssImage2D::GetcBytesPerFormat(EssFormat format)
{
    switch (format) {
    case LuminanceAlpha: return 2;
    case RGB: return 3;
    case RGBA: return 4;
    default: return 1;
    }
}

void CssImage2D::SetSize(int w, int h) const
{
    width = w;
    height = h;
    AllocateStorage(0);
}

void CssImage2D::AllocateStorage(int entries) const
{
    int n = width * height;
    int colors = entries > 0 ? entries : n;
    palette_offset = entries > 0 ? 0 : -1;
    pixels_offset = entries > 0 ? 2 * entries : 0;
    unsigned size = entries > 0 ? 2u * entries + n : 2u * n;
    int has_alpha =
        format == Alpha || format == LuminanceAlpha || format == RGBA;
    alpha_offset = has_alpha ? (int)size : -1;
    if (has_alpha)
        size += colors;
    if (entries > 0 && (int)size < MinimumIndexedStorage)
        size = MinimumIndexedStorage;
    storage.SetSize((int)size);
    if (is_mutable || format == Alpha)
        memset(storage.data, 255, 2u * colors);
    if (is_mutable && has_alpha)
        memset(GetpAlpha(), 255, n);
}

void CssImage2D::TranslatePixel(const uint8_t *data, EssFormat format, uint16_t *rgb, uint8_t *alpha)
{
    switch (format) {
    case Alpha:
        *alpha = data[0];
        break;
    case Luminance:
    case LuminanceAlpha:
        *rgb = static_cast<uint16_t>(((data[0] >> 3) << 11) | ((data[0] >> 2) << 5) | (data[0] >> 3));
        if (format == LuminanceAlpha) *alpha = data[1];
        break;
    case RGB:
    case RGBA:
        *rgb = static_cast<uint16_t>(((data[0] >> 3) << 11) | ((data[1] >> 2) << 5) | (data[2] >> 3));
        if (format == RGBA) *alpha = data[3];
        break;
    }
}

void CssImage2D::ReadPixel(CssSerializeBufferObjectsIn &reader, EssFormat format, uint16_t *rgb, uint8_t *alpha)
{
    uint8_t data[4], *dest = data;
    switch (GetcBytesPerFormat(format)) {
    case 4: *dest++ = reader.ReadByte(); [[fallthrough]];
    case 3: *dest++ = reader.ReadByte(); [[fallthrough]];
    case 2: *dest++ = reader.ReadByte(); [[fallthrough]];
    case 1: *dest = reader.ReadByte();
    }
    TranslatePixel(data, format, rgb, alpha);
}

void CssImage2D::unpackRow(uint16_t *rgb, uint8_t *alpha, int count, const uint8_t *data)
{
    int channels = GetcBytesPerFormat(format);
    for (int i = 0; i < count; ++i)
        TranslatePixel(data + (size_t)channels * i, format, rgb + i, alpha ? alpha + i : NULL);
}

void CssImage2D::Construct(EssFormat image_format, int w, int h, int size, const uint8_t *data)
{
    if (((unsigned)w | (unsigned)h) >> ImageDimensionBits) g_ssThrowLeave(SWV_LEAVE_NO_MEMORY);
    int n = w * h;
    if (size < n * GetcBytesPerFormat(image_format))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    width = w;
    height = h;
    format = image_format;
    is_mutable = false;
    AllocateStorage(0);
    unpackRow(GetpWritablePixels(), GetpAlpha(), n, data);
}

void CssImage2D::Construct(EssFormat image_format, int w, int h, int size, const uint8_t *data,
                           int palette_size, const uint8_t *palette)
{
    if (((unsigned)w | (unsigned)h) >> ImageDimensionBits) g_ssThrowLeave(SWV_LEAVE_NO_MEMORY);
    int channels = GetcBytesPerFormat(image_format);
    if (size < w * h || (palette_size < PaletteEntries * channels && palette_size % channels))
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    width = w;
    height = h;
    format = image_format;
    is_mutable = false;
    int entries = palette_size / channels;
    if (entries > PaletteEntries)
        entries = PaletteEntries;
    AllocateStorage(entries);
    memcpy(GetpPixels(), data, (size_t)(w * h));
    if (entries > 0)
        unpackRow(GetpPalette(), GetpAlpha(), entries, palette);
}

void CssImage2D::Construct(EssFormat image_format, int w, int h, bool immutable)
{
    if (((unsigned)w | (unsigned)h) >> ImageDimensionBits) g_ssThrowLeave(SWV_LEAVE_NO_MEMORY);
    width = w;
    height = h;
    format = image_format;
    is_mutable = !immutable;
    AllocateStorage(0);
}

void CssImage2D::Set(int x, int y, int w, int h, int size, const uint8_t *data)
{
    int channels = GetcBytesPerFormat(format);
    if (x < 0 || y < 0 || w <= 0 || h <= 0 || (int)((unsigned)x + w) > width ||
        (int)((unsigned)y + h) > height || (int)((unsigned)w * h * channels) > size)
        g_ssThrowLeave(SWV_LEAVE_INVALID_PARAMETER);
    if (!is_mutable)
        g_ssThrowLeave(SWV_LEAVE_INVALID_STATE);
    uint16_t *rgb = GetpWritablePixels();
    uint8_t *alpha = GetpAlpha();
    for (int i = 0; i < h; ++i) {
        int at = (y + i) * width + x;
        unpackRow(rgb + at, alpha ? alpha + at : NULL, w, data);
        data += (size_t)w * channels;
    }
}

void CssImage2D::SerializeIn(CssSerializeBufferObjectsIn &reader)
{
    CssObject3D::SerializeIn(reader);
    auto image_format = static_cast<EssFormat>(reader.ReadEnum(SWV_IMAGE_NONE, SWV_IMAGE_RGBA + 1));
    is_mutable = reader.ReadBool();
    unsigned w = reader.ReadUInt(), h = reader.ReadUInt();
    if (!w || !h)
        g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
    if ((w | h) >> ImageDimensionBits)
        g_ssThrowLeave(SWV_LEAVE_NO_MEMORY);
    height = h;
    width = w;
    format = image_format;
    if (is_mutable) {
        AllocateStorage(0);
        return;
    }

    unsigned pixels_left = w * h, channels = GetcBytesPerFormat(format);
    unsigned bytes = reader.ReadCount(1);
    // The ARM reader reuses one RGB word. TranslatePixel leaves it untouched for Alpha.
    uint16_t color = 0;
    uint8_t opacity = 0;
    if (bytes) {
        if (bytes < PaletteEntries * channels && bytes % channels)
            g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
        unsigned entries = bytes / channels;
        if (entries > PaletteEntries)
            entries = PaletteEntries;
        AllocateStorage(entries);
        auto *palette = GetpPalette();
        auto *alpha = GetpAlpha();
        do {
            ReadPixel(reader, format, &color, &opacity);
            if (entries) {
                --entries;
                *palette++ = color;
                if (alpha)
                    *alpha++ = opacity;
            }
            bytes -= channels;
        } while (bytes);
        bytes = reader.ReadCount(1);
        if (bytes < pixels_left)
            g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
        auto *indices = static_cast<uint8_t *>(storage.data) + pixels_offset;
        while (bytes--) {
            uint8_t index = reader.ReadByte();
            if (pixels_left) {
                --pixels_left;
                *indices++ = index;
            }
        }
    } else {
        bytes = reader.ReadCount(1);
        if (bytes < pixels_left * channels)
            g_ssThrowLeave(SWV_LEAVE_CORRUPT_FILE);
        AllocateStorage(0);
        auto *pixels = GetpWritablePixels();
        auto *alpha = GetpAlpha();
        while (bytes) {
            ReadPixel(reader, format, &color, &opacity);
            if (pixels_left) {
                --pixels_left;
                *pixels++ = color;
                if (alpha)
                    *alpha++ = opacity;
            }
            bytes -= channels;
        }
    }
}

void CssImage2D::CloneHelper(const CssImage2D &source)
{
    CssObject3D::CloneHelper(source);
    format = source.format;
    is_mutable = source.is_mutable;
    width = source.width;
    height = source.height;
    storage = source.storage;
    palette_offset = source.palette_offset;
    pixels_offset = source.pixels_offset;
    alpha_offset = source.alpha_offset;
}

CssObject3D *CssImage2D::Clone() const
{
    CssHeapPtr<CssImage2D> copy(static_cast<CssImage2D *>(FactoryCreate()));
    copy->CloneHelper(*this);
    return copy.release();
}
