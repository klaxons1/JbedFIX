#include "legacy_math.hpp"

#include <bit>
#include <climits>
#include <cmath>
#include <cstdint>

namespace legacy_math {
namespace {

// The bundled RVCT routines use their own argument reduction and CORDIC
// approximation. Their arithmetic also flushes subnormals before rounding.
uint32_t floatBits(float value)
{
    return std::bit_cast<uint32_t>(value);
}

float fromBits(uint32_t value)
{
    return std::bit_cast<float>(value);
}

enum {
    FP_FRACTION_BITS = 23,
    FP_EXPONENT_BIAS = 127,
    FP_SPECIAL_EXPONENT = 255,
    FP_HIDDEN = 0x800000,
    FP_INF = 0x7f800000,
    FP_QUIET_NAN = 0x7fc00000
};
constexpr uint32_t signBit = UINT32_C(0x80000000);

uint32_t mantissa(uint32_t magnitude)
{
    return (magnitude & (FP_HIDDEN - 1)) | FP_HIDDEN;
}

float normalizeResult(float x)
{
    uint32_t bits = floatBits(x), magnitude = bits & ~signBit;
    if (magnitude < FP_HIDDEN)
        return fromBits(bits & signBit);
    return magnitude > FP_INF ? fromBits(FP_QUIET_NAN) : x;
}

/* The ARM library flushes on the normalized exponent before rounding, even
 * when rounding the largest subnormal would have produced a normal number. */
float pack(uint32_t sign, int exponent, uint32_t mantissa)
{
    if (exponent <= 0)
        return fromBits(sign);
    uint32_t magnitude = ((uint32_t)(exponent - 1) << FP_FRACTION_BITS) + mantissa;
    return fromBits(sign | (magnitude >= FP_INF ? FP_INF : magnitude));
}

uint32_t shiftWithSticky(uint32_t value, unsigned distance)
{
    if (!distance)
        return value;
    if (distance >= 32)
        return value != 0;
    return (value >> distance) | ((value << (32 - distance)) != 0);
}

float sum(uint32_t a, uint32_t b)
{
    uint32_t ma = a & ~signBit, mb = b & ~signBit;
    uint32_t sign = a & signBit;
    int subtract = (a ^ b) >> 31;
    if (ma < mb) {
        uint32_t tmp = ma;
        ma = mb;
        mb = tmp;
        sign = b & signBit;
    }
    if (ma >= FP_INF)
        return fromBits(ma > FP_INF || (subtract && mb == FP_INF) ? FP_QUIET_NAN : sign | FP_INF);
    if (mb < FP_HIDDEN)
        return fromBits(ma < FP_HIDDEN ? (subtract ? 0 : sign) : sign | ma);

    int exponent = ma >> FP_FRACTION_BITS;
    uint32_t large = mantissa(ma) << 7;
    uint32_t small = shiftWithSticky(mantissa(mb) << 7, exponent - (mb >> FP_FRACTION_BITS));
    uint32_t sum;
    if (subtract) {
        sum = large - small;
        if (!sum)
            return 0;
        while (sum < (1u << 30)) {
            sum <<= 1;
            --exponent;
        }
    } else {
        sum = large + small;
        if (sum & signBit) {
            sum = shiftWithSticky(sum, 1);
            ++exponent;
        }
    }
    uint32_t mantissa = sum >> 7;
    unsigned tail = sum & 127;
    return pack(sign, exponent, mantissa + (tail > 64 || (tail == 64 && (mantissa & 1))));
}

float add(float x, float y)
{
    return sum(floatBits(x), floatBits(y));
}

float subtract(float x, float y)
{
    return sum(floatBits(x), floatBits(y) ^ signBit);
}

float multiply(float x, float y)
{
    uint32_t a = floatBits(x), b = floatBits(y), sign = (a ^ b) & signBit;
    a &= ~signBit;
    b &= ~signBit;
    if (a >= FP_INF || b >= FP_INF)
        return fromBits(a > FP_INF || b > FP_INF || a < FP_HIDDEN || b < FP_HIDDEN ? FP_QUIET_NAN : sign | FP_INF);
    if (a < FP_HIDDEN || b < FP_HIDDEN)
        return fromBits(sign);

    uint64_t product = (uint64_t)mantissa(a) * mantissa(b);
    unsigned high = product >> (2 * FP_FRACTION_BITS + 1);
    int exponent = (int)(a >> FP_FRACTION_BITS) + (int)(b >> FP_FRACTION_BITS) - FP_EXPONENT_BIAS + (int)high;
    uint32_t half = 1u << (FP_FRACTION_BITS - 1 + high);
    uint32_t tail = (uint32_t)product & (2 * half - 1);
    uint32_t mantissa = product >> (FP_FRACTION_BITS + high);
    return pack(sign, exponent, mantissa + (tail > half || (tail == half && (mantissa & 1))));
}

float divide(float x, float y)
{
    uint32_t a = floatBits(x), b = floatBits(y), sign = (a ^ b) & signBit;
    a &= ~signBit;
    b &= ~signBit;
    if (a > FP_INF || b > FP_INF || (a == FP_INF && b == FP_INF) || (a < FP_HIDDEN && b < FP_HIDDEN))
        return fromBits(FP_QUIET_NAN);
    if (a == FP_INF || b < FP_HIDDEN)
        return fromBits(sign | FP_INF);
    if (a < FP_HIDDEN || b == FP_INF)
        return fromBits(sign);

    /* 0x2cd9bc refines a 7-bit reciprocal seed, then obtains the high
     * and low quotient digits from two multiply-and-subtract steps. */
    static constexpr uint8_t seed[] = {
        254,250,247,243,240,236,233,230,226,223,220,217,215,212,209,206,
        204,201,199,197,194,192,190,188,185,183,181,179,178,176,174,172,
        170,168,167,165,163,162,160,159,157,156,154,153,151,150,149,147,
        146,145,143,142,141,140,139,137,136,135,134,133,132,131,130,129
    };
    int exponent = (int)(a >> FP_FRACTION_BITS) - (int)(b >> FP_FRACTION_BITS) + FP_EXPONENT_BIAS;
    uint32_t numerator = mantissa(a), denominator = mantissa(b);
    if (numerator < denominator) {
        numerator <<= 1;
        --exponent;
    }
    uint32_t estimate = 2u * seed[(denominator >> 17) - 64];
    int32_t error = (int32_t)(0u - denominator * estimate) >> 4;
    uint32_t reciprocal = (estimate << 7) + ((int32_t)((uint32_t)error * estimate) >> 21);
    uint32_t high = (reciprocal * (numerator >> 8)) >> 20;
    uint32_t remainder = (numerator << 11) - denominator * high;
    uint32_t low = (reciprocal * (remainder >> 8)) >> 19;
    remainder = (remainder << 12) - denominator * low;
    uint32_t mantissa = (high << 12) + low;
    if (remainder >= denominator) {
        remainder -= denominator;
        ++mantissa;
    }
    remainder *= 2;
    return pack(sign, exponent, mantissa +
                   (remainder > denominator || (remainder == denominator && (mantissa & 1))));
}

float remainder(float x, float y)
{
    uint32_t a = floatBits(x), b = floatBits(y) & ~signBit;
    uint32_t sign = a & signBit;
    a &= ~signBit;
    if (a >= FP_INF || b > FP_INF || b < FP_HIDDEN)
        return fromBits(FP_QUIET_NAN);
    if (a < FP_HIDDEN || b == FP_INF)
        return fromBits(sign | (a < FP_HIDDEN ? 0 : a));

    int exponent = a >> FP_FRACTION_BITS, divisor_exponent = b >> FP_FRACTION_BITS;
    uint32_t residue = mantissa(a) << 8, divisor = mantissa(b) << 8;
    int negative = 0, odd = 0;
    while (exponent >= divisor_exponent) {
        odd = (residue & signBit) != 0;
        if (odd) {
            if (residue < divisor) {
                residue = divisor - residue;
                negative ^= 1;
            } else {
                residue -= divisor;
            }
        }
        residue <<= 1;
        --exponent;
    }
    if (exponent == divisor_exponent - 1 && (residue > divisor || (residue == divisor && odd))) {
        residue = 2 * divisor - residue;
        negative ^= 1;
    }
    if (!residue)
        return fromBits(sign);
    while (!(residue & signBit)) {
        residue <<= 1;
        --exponent;
    }
    return pack(sign ^ (negative ? signBit : 0), exponent, residue >> 8);
}

float scale(float x, int exponent)
{
    uint32_t bits = floatBits(x);
    int e = (bits >> FP_FRACTION_BITS) & FP_SPECIAL_EXPONENT;
    if (e == 0 || e == FP_SPECIAL_EXPONENT)
        return normalizeResult(x);
    if (exponent <= -e)
        return fromBits(bits & signBit);
    if (exponent >= FP_SPECIAL_EXPONENT - e)
        return fromBits((bits & signBit) | (uint32_t)FP_INF);
    return fromBits(bits + ((uint32_t)exponent << FP_FRACTION_BITS));
}

int32_t truncate(float x)
{
    if (std::isnan(x))
        return 0;
    if (x >= 0x1p31f)
        return INT32_MAX;
    if (x <= -0x1p31f)
        return INT32_MIN;
    return (int32_t)x;
}

int32_t roundToEven(float x)
{
    uint32_t bits = floatBits(x);
    uint32_t mag = bits & ~signBit;
    constexpr uint32_t unitSpacingBits = std::bit_cast<uint32_t>(0x1p23f);
    if (mag >= unitSpacingBits)
        return truncate(x);
    float value = fromBits(mag);
    int32_t integer = (int32_t)value;
    float remainder = value - (float)integer;
    if (remainder > 0.5f || (remainder == 0.5f && (integer & 1)))
        ++integer;
    return bits >> 31 ? -integer : integer;
}

/* Split constants preserve the residual near an integer multiple of pi/2. */
unsigned reduceAngle(float *value)
{
    float x = *value;
    uint32_t magnitude = floatBits(x) & ~signBit;
    const float half_pi_high = 0x1.92p+0f;
    const float half_pi_mid = 0x1.fb4p-12f;
    const float half_pi_low = 0x1.4442d2p-24f;
    constexpr int32_t quarterPiBits = 0x3f490fdb;
    constexpr int32_t halfPiBits = 0x3fc90fdb;
    constexpr int32_t threeQuarterPiBits = 0x4016cbe4;
    constexpr int halfPiCancellationWindow = 2048;
    constexpr float twoOverPi = 0x1.45f306p-1f;
    constexpr int splitBits = 12;
    constexpr int splitMask = (1 << splitBits) - 1;
    unsigned quadrant = 0;
    if (magnitude >= threeQuarterPiBits) {
        int32_t n = roundToEven(multiply(x, twoOverPi));
        int32_t abs_n = n < 0 ? (int32_t)(0u - (uint32_t)n) : n;
        quadrant = (unsigned)n;
        if (abs_n < (1 << splitBits)) {
            x = subtract(x, multiply((float)n, half_pi_high));
            x = subtract(x, multiply((float)n, half_pi_mid));
            x = subtract(x, multiply((float)n, half_pi_low));
        } else if (abs_n < (1 << (FP_FRACTION_BITS + 1))) {
            int sign = n < 0 ? -1 : 1;
            float hi = (float)((abs_n & (splitMask << splitBits)) * sign);
            float lo = (float)((abs_n & splitMask) * sign);
            x = subtract(x, multiply(hi, half_pi_high));
            x = subtract(x, multiply(hi, half_pi_mid));
            x = subtract(x, multiply(lo, half_pi_high));
            x = subtract(x, multiply(hi, 0x1.444p-24f));
            x = subtract(x, multiply(lo, half_pi_mid));
            x = subtract(x, multiply(hi, 0x1.68c234p-39f));
            x = subtract(x, multiply(lo, half_pi_low));
        }
        magnitude = floatBits(x) & ~signBit;
    }
    if (magnitude >= threeQuarterPiBits) {
        float hi = fromBits(floatBits(x) & ~(uint32_t)splitMask);
        float lo = subtract(x, hi);
        float scale_hi = 0x1.a52p-2f, scale_lo = 0x1.a4p-16f;
        float coarse = multiply(hi, scale_hi);
        float cross = add(multiply(hi, scale_lo), multiply(lo, scale_hi));
        float sum = add(coarse, cross);
        float tail = add(subtract(cross, subtract(sum, coarse)), multiply(lo, scale_lo));
        float period = 0x1.4ac55cp+1f;
        float q = scale(divide(remainder(sum, period), period), 3);
        quadrant += (unsigned)(truncate(add(q, 9.0f)) >> 1);
        period = 0x1.4ac55cp-1f;
        x = divide(remainder(add(remainder(sum, period), tail), period),
                     0x1.a5269p-2f);
    } else if (magnitude > quarterPiBits) {
        int sign = x < 0 ? -1 : 1;
        quadrant += (unsigned)sign;
        x = subtract(x, sign * half_pi_high);
        if ((int32_t)magnitude - halfPiBits < halfPiCancellationWindow) {
            x = subtract(x, sign * half_pi_mid);
            x = subtract(x, sign * half_pi_low);
        } else {
            x = subtract(x, sign * 0x1.fb5444p-12f);
        }
    }
    *value = x;
    return quadrant;
}

uint32_t arithmeticShift(uint32_t value, unsigned shift)
{
    return (uint32_t)((int32_t)value >> (shift < 32 ? shift : 31));
}

void cordic(float angle, float *sine, float *cosine)
{
    uint32_t bits = floatBits(angle);
    constexpr uint32_t smallAngleBits = std::bit_cast<uint32_t>(0x1p-12f);
    if (bits <= smallAngleBits) {
        *sine = angle;
        *cosine = 1.0f;
        return;
    }
    static constexpr uint32_t angles[] = {0x3243f6a9, 0x3b58ce0b, 0x3eb6ebf2, 0x3fab7535, 0x3feab76e,
                                      0x3ffaab77, 0x3ffeaab7, 0x3fffaaab, 0x3fffeaab, 0x3ffffaab,
                                      0x3ffffeab, 0x3fffffab, 0x3fffffeb, 0x3ffffffb, 0x3fffffff};
    static constexpr struct {
        uint32_t phase;
        unsigned iterations;
    } start[] = {{0x3243f6a9, 1}, {0x292f1f46, 2},  {0x13a7529a, 3},  {0x274ea535, 3},
                 {0x0f31176d, 5}, {0x1e622ed9, 5},  {0x3cc45db3, 5},  {0x399b0da3, 8},
                 {0x3336309a, 9}, {0x266c668a, 10}, {0x0cd8ce6a, 11}, {0x19b19cd3, 11}};
    int exponent = (int)(bits >> FP_FRACTION_BITS) - FP_EXPONENT_BIAS;
    uint32_t phase = ((bits & (FP_HIDDEN - 1)) | FP_HIDDEN) << 5;
    uint32_t x = 0x20000000, y = 0;
    constexpr unsigned initialRotationDirections = 0xd1;
    unsigned initial = 0;
    if (exponent < 0) {
        initial = start[-exponent - 1].iterations;
        phase =
            arithmeticShift(2 * phase - start[-exponent - 1].phase, (unsigned)(-exponent) - (unsigned)initial);
        for (unsigned i = 0; i < initial; ++i) {
            uint32_t delta = arithmeticShift(y, 2 * i);
            if (initialRotationDirections & (1u << i)) {
                y = 2 * (y + x);
                x -= delta;
            } else {
                y = 2 * (y - x);
                x += delta;
            }
        }
    }
    for (unsigned i = 0; i < 32; ++i) {
        unsigned index = initial + i;
        uint32_t turn = index < sizeof angles / sizeof *angles ? angles[index] : 0x40000000;
        uint32_t dx = arithmeticShift(y, 2 * initial + i), dy = arithmeticShift(x, i);
        phase *= 2;
        if ((int32_t)phase < 0) {
            x += dx;
            y -= dy;
            phase += turn;
        } else {
            x -= dx;
            y += dy;
            phase -= turn;
        }
    }
    float gain = 0x1.36e9dcp-30f;
    *sine = fromBits(floatBits(multiply((float)(int32_t)y, gain)) - (initial << FP_FRACTION_BITS));
    *cosine = multiply((float)(int32_t)x, gain);
}

enum class TrigFunction { Sine, Cosine, Tangent };

float trig(float x, TrigFunction function)
{
    unsigned exponent = (floatBits(x) >> FP_FRACTION_BITS) & FP_SPECIAL_EXPONENT;
    if (exponent < FP_EXPONENT_BIAS - 12)
        return function == TrigFunction::Cosine ? 1.0f : x;
    if (exponent == FP_SPECIAL_EXPONENT)
        return fromBits(FP_QUIET_NAN);
    unsigned quadrant = reduceAngle(&x);
    float s, c;
    cordic(fromBits(floatBits(x) & ~signBit), &s, &c);
    if (x < 0)
        s = -s;
    if (function == TrigFunction::Tangent)
        return (quadrant & 1) ? -divide(c, s) : divide(s, c);
    if (function == TrigFunction::Cosine)
        ++quadrant;
    float value = (quadrant & 1) ? c : s;
    return (quadrant & 2) ? -value : value;
}

} // namespace

float sin(float radians)
{
    return trig(radians, TrigFunction::Sine);
}
float cos(float radians)
{
    return trig(radians, TrigFunction::Cosine);
}
float tan(float radians)
{
    return trig(radians, TrigFunction::Tangent);
}

} // namespace legacy_math
