#ifndef JBED_RUNTIME_ARITHMETIC_H
#define JBED_RUNTIME_ARITHMETIC_H

#include <stdint.h>

float jbed_arm32_int_bits_to_float(int32_t);
int32_t jbed_arm32_float_to_raw_int_bits(float);
double jbed_arm32_long_bits_to_double(int64_t);
int64_t jbed_arm32_double_to_raw_long_bits(double);

int32_t jbed_arm32_integer_divide(int32_t, int32_t);
int32_t jbed_arm32_integer_remainder(int32_t, int32_t);
uint64_t jbed_arm32_ladd(uint64_t, uint64_t);
uint64_t jbed_arm32_lsub(uint64_t, uint64_t);
uint64_t jbed_arm32_lmul(uint64_t, uint64_t);
int64_t jbed_arm32_ldiv(int64_t, int64_t);
int64_t jbed_arm32_lrem(int64_t, int64_t);
uint64_t jbed_arm32_lneg(uint64_t);
uint64_t jbed_arm32_lshl(uint64_t, uint32_t);
int64_t jbed_arm32_lshr(int64_t, uint32_t);
uint64_t jbed_arm32_lushr(uint64_t, uint32_t);
uint64_t jbed_arm32_land(uint64_t, uint64_t);
uint64_t jbed_arm32_lor(uint64_t, uint64_t);
uint64_t jbed_arm32_lxor(uint64_t, uint64_t);
int32_t jbed_arm32_lcmp(int64_t, int64_t);

uint32_t jbed_arm32_fadd(uint32_t, uint32_t);
uint32_t jbed_arm32_fsub(uint32_t, uint32_t);
uint32_t jbed_arm32_fmul(uint32_t, uint32_t);
uint32_t jbed_arm32_fdiv(uint32_t, uint32_t);
uint32_t jbed_arm32_frem(uint32_t, uint32_t);
uint32_t jbed_arm32_fneg(uint32_t);
uint32_t jbed_arm32_i2f(int32_t);
uint32_t jbed_arm32_l2f(int64_t);
int32_t jbed_arm32_f2i(uint32_t);
int64_t jbed_arm32_f2l(uint32_t);
int32_t jbed_arm32_fcmpl(uint32_t, uint32_t);
int32_t jbed_arm32_fcmpg(uint32_t, uint32_t);

uint64_t jbed_arm32_dadd(uint64_t, uint64_t);
uint64_t jbed_arm32_dsub(uint64_t, uint64_t);
uint64_t jbed_arm32_dmul(uint64_t, uint64_t);
uint64_t jbed_arm32_ddiv(uint64_t, uint64_t);
uint64_t jbed_arm32_drem(uint64_t, uint64_t);
uint64_t jbed_arm32_dneg(uint64_t);
uint64_t jbed_arm32_i2d(int32_t);
uint64_t jbed_arm32_l2d(int64_t);
uint64_t jbed_arm32_f2d(uint32_t);
int32_t jbed_arm32_d2i(uint64_t);
int64_t jbed_arm32_d2l(uint64_t);
uint32_t jbed_arm32_d2f(uint64_t);
int32_t jbed_arm32_dcmpl(uint64_t, uint64_t);
int32_t jbed_arm32_dcmpg(uint64_t, uint64_t);

#endif
