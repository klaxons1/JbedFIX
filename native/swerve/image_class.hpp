#ifndef JBED_SWERVE_IMAGE_CLASS_HPP
#define JBED_SWERVE_IMAGE_CLASS_HPP
#include "object_class.hpp"
#include "image2d.h"

class CssCamera;

class CssImage2D : public CssObject3D
{
public:
    enum EssFormat { Alpha = SWV_IMAGE_ALPHA, Luminance = SWV_IMAGE_LUMINANCE,
                     LuminanceAlpha = SWV_IMAGE_LUMINANCE_ALPHA, RGB = SWV_IMAGE_RGB, RGBA = SWV_IMAGE_RGBA };
    mutable CssArray<uint8_t> storage;
    mutable int palette_offset = -1, pixels_offset = -1;
    mutable int width = 0, height = 0, alpha_offset = -1;
    EssFormat format = RGB;
    uint8_t is_mutable = 0;

    virtual int GetWidth() const { return width; }
    virtual int GetHeight() const { return height; }
    int Type() const override { return Image2DObject; }
    virtual void *GetpPixels() const { return plane(pixels_offset); }
    void SerializeIn(CssSerializeBufferObjectsIn &) override;
    static IssSerializable *FactoryCreate() { return new CssImage2D; }
    CssObject3D *Clone() const override;

    static int GetcBytesPerFormat(EssFormat format);
    static void TranslatePixel(const uint8_t *data, EssFormat format, uint16_t *rgb, uint8_t *alpha);
    static void ReadPixel(CssSerializeBufferObjectsIn &reader, EssFormat format, uint16_t *rgb, uint8_t *alpha);
    EssFormat GetFormat() const { return format; }
    bool GetbMutable() const { return is_mutable; }
    uint8_t *GetpAlpha() const { return plane(alpha_offset); }
    uint16_t *GetpPalette() const { return reinterpret_cast<uint16_t *>(plane(palette_offset)); }
    uint16_t *GetpWritablePixels() const { return reinterpret_cast<uint16_t *>(plane(pixels_offset)); }
    int GetPitch() const { return width * sizeof(uint16_t); }
    int GetAlphaPitch() const { return format == Alpha || format == LuminanceAlpha || format == RGBA ? width : 0; }
    EssFormat GetDataFormat() const { return format == Luminance ? RGB : format == LuminanceAlpha ? RGBA : format; }
    void AllocateStorage(int entries) const;
    void Construct(EssFormat format, int w, int h, bool immutable);
    void Construct(EssFormat format, int w, int h, int size, const uint8_t *data);
    void Construct(EssFormat format, int w, int h, int size, const uint8_t *data,
                   int palette_size, const uint8_t *palette);
    void SetSize(int width, int height) const;
    void Set(int x, int y, int w, int h, int size, const uint8_t *data);
    void CloneHelper(const CssImage2D &source);
    uint8_t *plane(int offset) const
    {
        return offset == -1 ? nullptr : static_cast<uint8_t *>(storage.data) + offset;
    }
    void unpackRow(uint16_t *rgb, uint8_t *alpha, int count, const uint8_t *data);
};

class CssStageset : public CssImage2D
{
public:
    CssArray<uint16_t> depth;
    float scale = 1, bias = 0;
    uint8_t dirty = 1;

    int Type() const override { return StagesetObject; }
    uint16_t *GetZData() { return depth.Pointer(); }
    void Rescale(const CssCamera *camera);
    static IssSerializable *FactoryCreate() { return new CssStageset; }
    void CloneHelper(const CssStageset &source);
    CssObject3D *Clone() const override;
    void SerializeIn(CssSerializeBufferObjectsIn &) override;
    void Construct(int w, int h);
    void Construct(int w, int h, int size, const uint8_t *data);
    virtual void Set(int x, int y, int w, int h, int size, const uint8_t *data);
};

#endif
