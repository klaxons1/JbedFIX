#ifndef SWERVE_CSSCOLOR_HPP
#define SWERVE_CSSCOLOR_HPP

#include "cssfixed1616.hpp"

class CssPackedColor {
public:
    CssPackedColor() = default;
    explicit CssPackedColor(uint32_t value) : argb(value) {}
    uint32_t GetPackedRGBA8() const { return argb; }
    void SetPackedRGBA8(uint32_t value) { argb = value; }
    void SetBlue8(uint8_t value)  { argb = (argb & 0xffffff00) | value; }
    void SetGreen8(uint8_t value) { argb = (argb & 0xffff00ff) | (uint32_t(value) << 8); }
    void SetRed8(uint8_t value)   { argb = (argb & 0xff00ffff) | (uint32_t(value) << 16); }
    void SetAlpha8(uint8_t value) { argb = (argb & 0x00ffffff) | (uint32_t(value) << 24); }
    void SetRed(float value)   { SetRed8(toByte(value)); }
    void SetGreen(float value) { SetGreen8(toByte(value)); }
    void SetBlue(float value)  { SetBlue8(toByte(value)); }
    void SetAlpha(float value) { SetAlpha8(toByte(value)); }
    void SetReals(float red, float green, float blue);

private:
    uint32_t argb = 0xff000000;
    static uint8_t toByte(float value)
    {
        return static_cast<uint8_t>(saturatingTruncate(value * 255.0f + 0.5f));
    }
};

class CssColor {
public:
    int32_t channels[3] = {};

    CssColor() = default;
    explicit CssColor(unsigned packed) { SetPackedRGBA8(packed); }
    CssColor(float red, float green, float blue);
    unsigned GetPackedRGBA8() const;
    void SetPackedRGBA8(unsigned packed);
    void SetRGB8(uint8_t red, uint8_t green, uint8_t blue);
    uint16_t GetPixel() const;
    void SetPixel(uint16_t pixel);

    CssColor &operator+=(const CssColor &other);
    CssColor &operator-=(const CssColor &other);
    CssColor &operator*=(const CssColor &other);
    CssColor &operator*=(float scale);
    CssColor &FixedScale(SwvFixedWord scale);
    bool IsWhite() const;
    bool IsBlack() const;
    void Clamp();

    int RedInt() const { return static_cast<int32_t>(static_cast<uint32_t>(channels[0]) << 8); }
    int GreenInt() const { return static_cast<int32_t>(static_cast<uint32_t>(channels[1]) << 8); }
    int BlueInt() const { return static_cast<int32_t>(static_cast<uint32_t>(channels[2]) << 8); }
};

#endif
