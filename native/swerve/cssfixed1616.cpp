#include "engine.h"
#include "cssfixed1616.hpp"
#include <algorithm>
#include <bit>
#include <cfloat>
#include <cmath>

static int32_t fixed_mul(int32_t a, int32_t b)
{
    return (int32_t)(((int64_t)a * b) >> 16);
}

static int32_t fixed_div(int32_t a, int32_t b)
{
    return static_cast<int32_t>(g_divide_int64_int64(static_cast<int64_t>(a) * 65536, b));
}

long long g_divide_int64_int64(long long a, long long b)
{
    if (b == 0) return INT64_MAX;
    if (a == INT64_MIN && b == -1) return INT64_MIN;
    return a / b;
}

SwvFixedWord g_divide_int32_int32(SwvFixedWord a, SwvFixedWord b)
{
    if (b == 0) return INT32_MAX;
    if (a == INT32_MIN && b == -1) return INT32_MIN;
    return a / b;
}

unsigned g_divide_uint32_uint32(unsigned a, unsigned b)
{
    return b ? a / b : UINT32_MAX;
}

static int32_t abs_word(int32_t x)
{
    return x < 0 ? (int32_t)(0u - (uint32_t)x) : x;
}

/* The 513-word 2.30 table at 0x2d3d60. Large arguments interpolate
 * between adjacent entries with the next eight bits of the argument. */
#define RECIPROCAL(i) (0x40000000 / (i))
#define RECIPROCALS_8(i) \
    RECIPROCAL(i), RECIPROCAL(i+1), RECIPROCAL(i+2), RECIPROCAL(i+3), \
    RECIPROCAL(i+4), RECIPROCAL(i+5), RECIPROCAL(i+6), RECIPROCAL(i+7)
#define RECIPROCALS_64(i) \
    RECIPROCALS_8(i), RECIPROCALS_8(i+8), RECIPROCALS_8(i+16), RECIPROCALS_8(i+24), \
    RECIPROCALS_8(i+32), RECIPROCALS_8(i+40), RECIPROCALS_8(i+48), RECIPROCALS_8(i+56)
static const int32_t reciprocal_table[] = {
    INT32_MAX, RECIPROCALS_64(1), RECIPROCALS_64(65), RECIPROCALS_64(129),
    RECIPROCALS_64(193), RECIPROCALS_64(257), RECIPROCALS_64(321),
    RECIPROCALS_64(385), RECIPROCALS_64(449)
};
#undef RECIPROCALS_64
#undef RECIPROCALS_8
#undef RECIPROCAL

int g_quick_scaledreciprocal(int x, int precision)
{
    int32_t n = abs_word(x), result;
    if (n > 512) {
        uint32_t fraction = (uint32_t)n << 8;
        while (n >= 4096) {
            n >>= 4;
            fraction >>= 4;
            precision -= 4;
        }
        while (n >= 512) {
            n >>= 1;
            fraction >>= 1;
            --precision;
        }
        int32_t first = reciprocal_table[n];
        result =
            first +
            ((int32_t)((uint32_t)(reciprocal_table[n + 1] - first) * (fraction & 255)) >>
             8);
    } else {
        result = reciprocal_table[(uint32_t)n & 0x3fffffffu];
    }
    int32_t shift = (int32_t)((unsigned)precision - 30u);
    if (shift > 0)
        result = (shift & 255) >= 32 ? 0 : (int32_t)((uint32_t)result << (shift & 255));
    if (shift < 0) {
        unsigned count = (0u - (unsigned)shift) & 255;
        result >>= (count >= 32 ? 31 : count);
    }
    return x < 0 ? (int32_t)(0u - (uint32_t)result) : result;
}

SwvFixedWord g_fixed_reciprocal(SwvFixedWord x)
{
    return g_quick_scaledreciprocal(x, 32);
}

SwvFixedWord g_fixed_atan(SwvFixedWord x)
{
    static const int32_t offsets[] = {0, 34315, 102944, 68629};
    int32_t v = abs_word(x);
    unsigned sector = 0;
    if (v > 65536) {
        v = g_fixed_reciprocal(v);
        sector = 2;
    }
    if (v > 17560) {
        v = fixed_div(fixed_mul(47976, v) + v - 65536, v + 113512);
        ++sector;
    }
    int32_t square = fixed_mul(v, v);
    int32_t denominator = fixed_mul(square + 984613, square) + 3904533;
    denominator = fixed_mul(denominator, square) + 5646408;
    denominator = fixed_mul(denominator, square) + 2691322;
    int32_t numerator = fixed_mul(-54891, square) - 556703;
    numerator = fixed_mul(numerator, square) - 1343871;
    numerator = fixed_mul(numerator, square) - 897106;
    numerator = fixed_mul(fixed_mul(numerator, square), v);
    int32_t angle = (int32_t)((uint32_t)v + (uint32_t)fixed_div(numerator, denominator));
    if (sector > 1)
        angle = (int32_t)(0u - (uint32_t)angle);
    angle = (int32_t)((uint32_t)angle + offsets[sector]);
    return x < 0 ? (int32_t)(0u - (uint32_t)angle) : angle;
}

SwvFixedWord g_fixed_atan2(SwvFixedWord y, SwvFixedWord x)
{
    if (!(x | y))
        return 0;
    int32_t ax = abs_word(x), ay = abs_word(y);
    if ((int64_t)ax * 32768 < ay)
        return y < 0 ? -102943 : 102943;
    int32_t angle = (int64_t)ay * 32768 >= ax ? g_fixed_atan(fixed_div(y, x)) : 0;
    if (x <= 0)
        angle += y < 0 ? -205887 : 205887;
    return angle;
}

SwvFixedWord g_fixed_reciprocal_sqrt(SwvFixedWord x)
{
    uint32_t n = (uint32_t)x;
    if (n <= 2)
        return n == 0 ? INT32_MAX : n == 1 ? 16777216 : 11863283;
    unsigned shift = 0;
    if (n < 0x8000) {
        n <<= 16;
        shift += 16;
    }
    if (n < 0x800000) {
        n <<= 8;
        shift += 8;
    }
    if (n < 0x8000000) {
        n <<= 4;
        shift += 4;
    }
    if (n < 0x20000000) {
        n <<= 2;
        shift += 2;
    }
    int32_t guess;
    if (n >= 0x40000000)
        guess = (int32_t)((0xa0000000u - (n >> 1)) >> (22 - shift / 2));
    else {
        uint32_t seed = (0xa0000000u - n) >> (22 - shift / 2);
        guess = (int32_t)(seed + (seed >> 1));
    }
    int large = guess >= 6554;
    for (int i = 0; i < 2; ++i) {
        int32_t sq =
            large ? fixed_mul(x, fixed_mul(guess, guess)) : fixed_mul(fixed_mul(x, guess), guess);
        guess = fixed_mul(guess, (int32_t)(196608u - (uint32_t)sq) >> 1);
    }
    return guess;
}

SwvFixedWord g_fixed_sqrt(SwvFixedWord x)
{
    return fixed_mul(x, g_fixed_reciprocal_sqrt(x));
}

SwvFixedWord g_fixed_fromIEEE(float x)
{
    uint32_t bits = std::bit_cast<uint32_t>(x);
    int shift = (int)((bits >> 23) & 255) - 134;
    uint32_t m = (bits & 0x7fffff) | 0x800000;
    int32_t value = shift < -24  ? 0
                    : shift < 0  ? (int32_t)(m >> -shift)
                    : shift >= 8 ? INT32_MAX
                                 : (int32_t)(m << shift);
    return bits >> 31 ? -value : value;
}

/* 0x2d38b0 discards the low bits before its final rounding step. A native
 * int-to-float cast rounds ties differently for some large magnitudes. */
void g_FixedToBytes(SwvFixedWord value, unsigned char *out)
{
    uint32_t sign = (uint32_t)value & 0x80000000u;
    uint32_t magnitude = sign ? 0u - (uint32_t)value : (uint32_t)value;
    unsigned exponent = 134;
    if (magnitude) {
        while (!(magnitude & 0x7f800000u)) {
            magnitude <<= 1;
            --exponent;
        }
        while (magnitude & 0x7e000000u) {
            magnitude >>= 1;
            ++exponent;
        }
        while (magnitude & 0x7f000000u) {
            magnitude = (magnitude + 1) >> 1;
            ++exponent;
        }
        magnitude = sign | (exponent << 23) | (magnitude & 0x7fffffu);
    }
    for (unsigned i = 0; i < 4; ++i)
        out[i] = static_cast<unsigned char>(magnitude >> (8 * i));
}

static void Cordic(SwvFixedWord phase, SwvFixedWord &sine, SwvFixedWord &cosine)
{
    static const int32_t angles[] = {51471, 30385, 16054, 8149, 4090, 2047, 1023};
    if (phase == 0 || phase >= 102943) {
        sine = phase == 0 ? 0 : 65536;
        cosine = phase == 0 ? 65536 : 0;
        return;
    }
    int32_t x = 39797, y = 0, direction = 0;
    for (int i = 0; i < 7; ++i) {
        int32_t delta = y >> i;
        if (phase <= direction) {
            y -= x >> i;
            x += delta;
            direction -= angles[i];
        } else {
            y += x >> i;
            x -= delta;
            direction += angles[i];
        }
    }
    int32_t tail = (int32_t)((16777557LL * ((int64_t)phase - direction)) >> 24);
    cosine = (int32_t)((uint32_t)x - fixed_mul(tail, y));
    sine = (int32_t)((uint32_t)y + fixed_mul(tail, x));
}

SwvFixedWord g_fixed_sin(SwvFixedWord angle)
{
    SwvFixedWord sine, cosine;
    int negative = angle < 0;
    int32_t phase = abs_word(angle);
    while (phase > 411774)
        phase -= 411774;
    if (phase >= 205887) {
        phase = 411774 - phase;
        negative = !negative;
    }
    if (phase >= 102943)
        phase = 205887 - phase;
    Cordic(phase, sine, cosine);
    return negative ? (int32_t)(0u - (uint32_t)sine) : sine;
}

SwvFixedWord g_fixed_cos(SwvFixedWord angle)
{
    SwvFixedWord sine, cosine;
    int32_t phase = abs_word(angle);
    while (phase > 411774)
        phase -= 411774;
    if (phase >= 205887)
        phase = 411774 - phase;
    int negative = phase >= 102943;
    if (negative)
        phase = 205887 - phase;
    Cordic(phase, sine, cosine);
    return negative ? (int32_t)(0u - (uint32_t)cosine) : cosine;
}

SwvFixedWord fixed_exp_int(SwvFixedWord x, int exponent)
{
    int32_t result = 65536;
    for (unsigned mask = 1; (int32_t)mask <= exponent; mask <<= 1) {
        if ((unsigned)exponent & mask)
            result = fixed_mul(result, x);
        x = fixed_mul(x, x);
    }
    return result;
}

SwvFixedWord fixed_pow(SwvFixedWord x, SwvFixedWord exponent)
{
    int32_t result = fixed_exp_int(x, exponent >> 16);
    int32_t frac = (uint32_t)exponent & 65535;
    if (frac) {
        int32_t delta = (int32_t)((uint32_t)x - 65536u);
        result = (int32_t)((uint32_t)result + fixed_mul(delta, fixed_mul(frac, result)));
    }
    return result;
}

float g_float_exp(float x)
{
    if (x == 0) return 1;
    if (std::isnan(x)) return std::signbit(x) ? 0 : FLT_MAX;
    if (x < -88.0f) return 0;
    if (x > 88.0f) return FLT_MAX;
    float scaled = x * 1.442695f;
    int exponent = static_cast<int>(scaled);
    float frac = scaled - (float)exponent - 0.5f;
    float sq = frac * frac;
    float p = sq * 60.614853f + 30286.973f;
    p = (p * sq + 2.0803844e+06f) * frac;
    float q = (sq + 1749.2877f) * sq + 327725.16f;
    q = q * sq + 6.0027205e+06f;
    float reduced = (q + p) * 1.4142135f / (q - p);
    float result = std::ldexp(reduced, exponent);
    return result < FLT_MIN ? 0.0f : std::min(result, FLT_MAX);
}

float g_float_reciprocal_sqrt(float x)
{
    float guess = std::bit_cast<float>(0x5f374800u - (std::bit_cast<int32_t>(x) >> 1));
    for (int i = 0; i < 2; ++i) {
        float square = x * guess * guess;
        guess = guess * 0.5f * (3 - square);
    }
    return guess;
}

float g_ValidateFloat(float x)
{
    if (!std::isfinite(x)) g_ssThrowLeave(SWV_LEAVE_FLOAT_INVALID_NUMBER);
    return std::isnormal(x) ? x : 0.0f;
}
