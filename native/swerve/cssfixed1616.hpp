#ifndef JBED_SWERVE_CSSFIXED1616_HPP
#define JBED_SWERVE_CSSFIXED1616_HPP
#include <climits>
#include <cmath>
#include <cstdint>
#include <numbers>

#if LONG_MAX == INT32_MAX
using SwvFixedWord = long;
#else
using SwvFixedWord = int32_t;
#endif

inline constexpr float radiansPerDegree = std::numbers::pi_v<float> / 180.0f;
inline constexpr float degreesPerRadian = 180.0f / std::numbers::pi_v<float>;
inline constexpr float realEpsilon = 0.000015f;

inline bool nearZero(float value) { return std::abs(value) <= realEpsilon; }

inline int32_t saturatingTruncate(float value)
{
    if (value >= 2147483648.0f) return INT32_MAX;
    if (value <= -2147483648.0f) return INT32_MIN;
    return std::isnan(value) ? 0 : static_cast<int32_t>(value);
}

inline int32_t toFixed16(float value)
{
    return saturatingTruncate(value * 65536.0f + 0.5f);
}

long long g_divide_int64_int64(long long a, long long b);
SwvFixedWord g_divide_int32_int32(SwvFixedWord a, SwvFixedWord b);
unsigned g_divide_uint32_uint32(unsigned a, unsigned b);
int g_quick_scaledreciprocal(int x, int precision);
SwvFixedWord g_fixed_reciprocal(SwvFixedWord x);
SwvFixedWord g_fixed_atan(SwvFixedWord x);
SwvFixedWord g_fixed_atan2(SwvFixedWord y, SwvFixedWord x);
SwvFixedWord g_fixed_reciprocal_sqrt(SwvFixedWord x);
SwvFixedWord g_fixed_sqrt(SwvFixedWord x);
SwvFixedWord g_fixed_fromIEEE(float x);
void g_FixedToBytes(SwvFixedWord value, unsigned char *out);
SwvFixedWord g_fixed_sin(SwvFixedWord angle);
SwvFixedWord g_fixed_cos(SwvFixedWord angle);
SwvFixedWord fixed_exp_int(SwvFixedWord x, int exponent);
SwvFixedWord fixed_pow(SwvFixedWord x, SwvFixedWord exponent);
float g_float_exp(float x);
float g_float_reciprocal_sqrt(float x);
float g_ValidateFloat(float x);
#endif
