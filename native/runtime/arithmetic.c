#include "arithmetic.h"

#include <limits.h>
#include <math.h>
#include <string.h>

#define FLOAT_SIGN UINT32_C(0x80000000)
#define FLOAT_INFINITY UINT32_C(0x7f800000)
#define FLOAT_NAN UINT32_C(0x7fc00000)
#define DOUBLE_SIGN UINT64_C(0x8000000000000000)
#define DOUBLE_INFINITY UINT64_C(0x7ff0000000000000)
#define DOUBLE_NAN UINT64_C(0x7ff8000000000000)

static int float_nan(uint32_t word) { return (word & ~FLOAT_SIGN) > FLOAT_INFINITY; }
static int double_nan(uint64_t word) { return (word & ~DOUBLE_SIGN) > DOUBLE_INFINITY; }

static float as_float(uint32_t word)
{
    float value;
    memcpy(&value, &word, sizeof value);
    return value;
}
static uint32_t float_word(float value)
{
    uint32_t word;
    memcpy(&word, &value, sizeof word);
    return word;
}
static uint32_t float_result(float value)
{
    return isnan(value) ? FLOAT_NAN : float_word(value);
}
static double as_double(uint64_t word)
{
    double value;
    memcpy(&value, &word, sizeof value);
    return value;
}
static uint64_t double_word(double value)
{
    uint64_t word;
    memcpy(&word, &value, sizeof word);
    return word;
}
static uint64_t double_result(double value)
{
    return isnan(value) ? DOUBLE_NAN : double_word(value);
}

float jbed_arm32_int_bits_to_float(int32_t bits) { return as_float((uint32_t)bits); }
int32_t jbed_arm32_float_to_raw_int_bits(float value) { return (int32_t)float_word(value); }
double jbed_arm32_long_bits_to_double(int64_t bits) { return as_double((uint64_t)bits); }
int64_t jbed_arm32_double_to_raw_long_bits(double value) { return (int64_t)double_word(value); }

/* The assembler entry checks zero before a C frame can obscure the Java throw
 * site. Java's signed division overflow wraps instead of invoking C UB. */
int32_t jbed_arm32_idiv(int32_t a, int32_t b)
{
    return a == INT32_MIN && b == -1 ? INT32_MIN : a / b;
}
int32_t jbed_arm32_irem(int32_t a, int32_t b)
{
    return a == INT32_MIN && b == -1 ? 0 : a % b;
}
int64_t jbed_arm32_ldiv_nonzero(int64_t a, int64_t b)
{
    return a == INT64_MIN && b == -1 ? INT64_MIN : a / b;
}
int64_t jbed_arm32_lrem_nonzero(int64_t a, int64_t b)
{
    return a == INT64_MIN && b == -1 ? 0 : a % b;
}

uint64_t jbed_arm32_ladd(uint64_t a, uint64_t b) { return a + b; }
uint64_t jbed_arm32_lsub(uint64_t a, uint64_t b) { return a - b; }
uint64_t jbed_arm32_lmul(uint64_t a, uint64_t b) { return a * b; }
uint64_t jbed_arm32_lneg(uint64_t a) { return -a; }
uint64_t jbed_arm32_lshl(uint64_t a, uint32_t n) { return a << (n & 63); }
int64_t jbed_arm32_lshr(int64_t a, uint32_t n) { return a >> (n & 63); }
uint64_t jbed_arm32_lushr(uint64_t a, uint32_t n) { return a >> (n & 63); }
uint64_t jbed_arm32_land(uint64_t a, uint64_t b) { return a & b; }
uint64_t jbed_arm32_lor(uint64_t a, uint64_t b) { return a | b; }
uint64_t jbed_arm32_lxor(uint64_t a, uint64_t b) { return a ^ b; }
int32_t jbed_arm32_lcmp(int64_t a, int64_t b) { return (a > b) - (a < b); }

/* Jbed addition propagates a NaN operand unchanged; subtraction negates its
 * second operand first. Multiplication/division/remainder canonicalize NaNs. */
uint32_t jbed_arm32_fadd(uint32_t a, uint32_t b)
{
    if (float_nan(a)) return a;
    if (float_nan(b)) return b;
    return float_result(as_float(a) + as_float(b));
}
uint32_t jbed_arm32_fsub(uint32_t a, uint32_t b) { return jbed_arm32_fadd(a, b ^ FLOAT_SIGN); }
uint32_t jbed_arm32_fmul(uint32_t a, uint32_t b) { return float_result(as_float(a) * as_float(b)); }
uint32_t jbed_arm32_fdiv(uint32_t a, uint32_t b) { return float_result(as_float(a) / as_float(b)); }
uint32_t jbed_arm32_frem(uint32_t a, uint32_t b) { return float_result(fmodf(as_float(a), as_float(b))); }
uint32_t jbed_arm32_fneg(uint32_t a) { return a ^ FLOAT_SIGN; }
uint32_t jbed_arm32_i2f(int32_t a) { return float_word((float)a); }
uint32_t jbed_arm32_l2f(int64_t a) { return float_word((float)a); }

static int32_t to_int(double value)
{
    if (isnan(value)) return 0;
    if (value >= 0x1p31) return INT32_MAX;
    if (value <= -0x1p31) return INT32_MIN;
    return (int32_t)value;
}
static int64_t to_long(double value)
{
    if (isnan(value)) return 0;
    if (value >= 0x1p63) return INT64_MAX;
    if (value <= -0x1p63) return INT64_MIN;
    return (int64_t)value;
}
int32_t jbed_arm32_f2i(uint32_t a) { return to_int(as_float(a)); }
int64_t jbed_arm32_f2l(uint32_t a) { return to_long(as_float(a)); }
int32_t jbed_arm32_fcmpl(uint32_t a, uint32_t b)
{
    float x = as_float(a), y = as_float(b);
    return x > y ? 1 : x == y ? 0 : -1;
}
int32_t jbed_arm32_fcmpg(uint32_t a, uint32_t b)
{
    float x = as_float(a), y = as_float(b);
    return x < y ? -1 : x == y ? 0 : 1;
}

uint64_t jbed_arm32_dadd(uint64_t a, uint64_t b)
{
    /* Unlike float addition, two non-finite double operands are handled
     * together before either operand's NaN payload can be propagated. */
    if ((a & ~DOUBLE_SIGN) >= DOUBLE_INFINITY && (b & ~DOUBLE_SIGN) >= DOUBLE_INFINITY)
        return a == b && !double_nan(a) ? a : DOUBLE_NAN;
    if (double_nan(a)) return a;
    if (double_nan(b)) return b;
    return double_result(as_double(a) + as_double(b));
}
uint64_t jbed_arm32_dsub(uint64_t a, uint64_t b) { return jbed_arm32_dadd(a, b ^ DOUBLE_SIGN); }
uint64_t jbed_arm32_dmul(uint64_t a, uint64_t b) { return double_result(as_double(a) * as_double(b)); }
uint64_t jbed_arm32_ddiv(uint64_t a, uint64_t b) { return double_result(as_double(a) / as_double(b)); }
uint64_t jbed_arm32_drem(uint64_t a, uint64_t b) { return double_result(fmod(as_double(a), as_double(b))); }
uint64_t jbed_arm32_dneg(uint64_t a) { return a ^ DOUBLE_SIGN; }
uint64_t jbed_arm32_i2d(int32_t a) { return double_word((double)a); }
uint64_t jbed_arm32_l2d(int64_t a) { return double_word((double)a); }
uint64_t jbed_arm32_f2d(uint32_t a)
{
    return float_nan(a) ? DOUBLE_NAN | ((uint64_t)(a & FLOAT_SIGN) << 32) : double_word(as_float(a));
}
int32_t jbed_arm32_d2i(uint64_t a) { return to_int(as_double(a)); }
int64_t jbed_arm32_d2l(uint64_t a) { return to_long(as_double(a)); }
uint32_t jbed_arm32_d2f(uint64_t a)
{
    return double_nan(a) ? FLOAT_NAN | (uint32_t)((a & DOUBLE_SIGN) >> 32) : float_word((float)as_double(a));
}
int32_t jbed_arm32_dcmpl(uint64_t a, uint64_t b)
{
    double x = as_double(a), y = as_double(b);
    return x > y ? 1 : x == y ? 0 : -1;
}
int32_t jbed_arm32_dcmpg(uint64_t a, uint64_t b)
{
    double x = as_double(a), y = as_double(b);
    return x < y ? -1 : x == y ? 0 : 1;
}
