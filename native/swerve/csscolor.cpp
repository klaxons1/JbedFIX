#include "csscolor.hpp"
#include <algorithm>
#include <cmath>

namespace {
constexpr float MaximumColorGain = 1024.0f;
constexpr int MaximumFixedColorGain = 1024 * 256;
}

void CssPackedColor::SetReals(float red, float green, float blue)
{
    SetRed(std::clamp(red, 0.0f, 1.0f));
    SetGreen(std::clamp(green, 0.0f, 1.0f));
    SetBlue(std::clamp(blue, 0.0f, 1.0f));
}

static int scaleToChannel(float value)
{
    int fixed = saturatingTruncate(value * 65536.0f);
    return (fixed + 127) >> 8;
}

CssColor::CssColor(float red, float green, float blue)
    : channels{scaleToChannel(red), scaleToChannel(green), scaleToChannel(blue)}
{
}

static int expandByte(uint8_t c)
{
    return c + ((c + 128) >> 8);
}

void CssColor::SetRGB8(uint8_t red, uint8_t green, uint8_t blue)
{
    channels[0] = expandByte(red);
    channels[1] = expandByte(green);
    channels[2] = expandByte(blue);
}

void CssColor::SetPackedRGBA8(unsigned packed)
{
    SetRGB8(static_cast<uint8_t>(packed >> 16), static_cast<uint8_t>(packed >> 8),
            static_cast<uint8_t>(packed));
}

static unsigned narrowChannel(int c)
{
    int rounded = (c + 128) >> 8;
    return static_cast<unsigned>(c - rounded);
}

static void getRGB8(const CssColor &color, unsigned &r, unsigned &g, unsigned &b)
{
    r = narrowChannel(color.channels[0]);
    g = narrowChannel(color.channels[1]);
    b = narrowChannel(color.channels[2]);
    if ((r | g | b) > 255) {
        r = std::min(r, 255u);
        g = std::min(g, 255u);
        b = std::min(b, 255u);
    }
}

unsigned CssColor::GetPackedRGBA8() const
{
    unsigned r, g, b;
    getRGB8(*this, r, g, b);
    return 0xff000000u | (r << 16) | (g << 8) | b;
}

uint16_t CssColor::GetPixel() const
{
    unsigned r, g, b;
    getRGB8(*this, r, g, b);
    return static_cast<uint16_t>(((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3));
}

void CssColor::SetPixel(uint16_t pixel)
{
    channels[0] = ((pixel >> 11) * 256) / 31;
    channels[1] = (((pixel >> 5) & 63) * 256) / 63;
    channels[2] = ((pixel & 31) * 256) / 31;
}

bool CssColor::IsWhite() const
{
    return channels[0] == 256 && channels[1] == 256 && channels[2] == 256;
}

bool CssColor::IsBlack() const
{
    return channels[0] == 0 && channels[1] == 0 && channels[2] == 0;
}

void CssColor::Clamp()
{
    for (auto &c : channels) c = std::clamp(c, 0, 256);
}

CssColor &CssColor::operator+=(const CssColor &other)
{
    for (int i = 0; i < 3; ++i)
        channels[i] += other.channels[i];
    return *this;
}

CssColor &CssColor::operator-=(const CssColor &other)
{
    for (int i = 0; i < 3; ++i)
        channels[i] -= other.channels[i];
    return *this;
}

static int multiplyChannel(int channel, int scale)
{
    return (channel * scale) >> 8;
}

CssColor &CssColor::operator*=(const CssColor &other)
{
    for (int i = 0; i < 3; ++i) channels[i] = multiplyChannel(channels[i], other.channels[i]);
    return *this;
}

CssColor &CssColor::operator*=(float scale)
{
    if (!(std::abs(scale) <= MaximumColorGain))
        scale = std::copysign(MaximumColorGain, scale);
    int gain = static_cast<int>(scale * 256.0f);
    for (auto &c : channels) c = multiplyChannel(c, gain);
    return *this;
}

CssColor &CssColor::FixedScale(SwvFixedWord scale)
{
    int gain = std::clamp(static_cast<int>(scale >> 8), -MaximumFixedColorGain, MaximumFixedColorGain);
    for (auto &c : channels) c = multiplyChannel(c, gain);
    return *this;
}
