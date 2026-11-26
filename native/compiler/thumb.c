#include "thumb.h"
#include "bytecode.h"
#include "coder.h"
#include "writer.h"

#include <limits.h>
#include <stdio.h>
#include <string.h>

/* GenInstr takes the opcode high byte, then the fields at bits 6 and 3,
 * followed by the low field. Register/immediate bits are added by each caller. */
enum {
    THUMB_LSL_IMM = 0x00,
    THUMB_LSR_IMM = 0x08,
    THUMB_ASR_IMM = 0x10,
    THUMB_ADD_REG = 0x18,
    THUMB_SUB_REG = 0x1a,
    THUMB_ADD_IMM3 = 0x1c,
    THUMB_SUB_IMM3 = 0x1e,
    THUMB_MOV_IMM = 0x20,
    THUMB_CMP_IMM = 0x28,
    THUMB_ADD_IMM8 = 0x30,
    THUMB_SUB_IMM8 = 0x38,
    THUMB_ALU = 0x40,
    THUMB_ADD_HIGH = 0x44,
    THUMB_CMP_HIGH = 0x45,
    THUMB_MOV_HIGH = 0x46,
    THUMB_BRANCH_EXCHANGE = 0x47,
    THUMB_LDR_LITERAL = 0x48,
    THUMB_STR_REG = 0x50,
    THUMB_STRH_REG = 0x52,
    THUMB_STRB_REG = 0x54,
    THUMB_LDRSB_REG = 0x56,
    THUMB_LDR_REG = 0x58,
    THUMB_LDRH_REG = 0x5a,
    THUMB_LDRB_REG = 0x5c,
    THUMB_LDRSH_REG = 0x5e,
    THUMB_STR_IMM = 0x60,
    THUMB_LDR_IMM = 0x68,
    THUMB_STRB_IMM = 0x70,
    THUMB_LDRB_IMM = 0x78,
    THUMB_STRH_IMM = 0x80,
    THUMB_LDRH_IMM = 0x88,
    THUMB_STR_SP = 0x90,
    THUMB_LDR_SP = 0x98,
    THUMB_ADDRESS_SP = 0xa8,
    THUMB_ADJUST_SP = 0xb0,
    THUMB_PUSH = 0xb4,
    THUMB_POP = 0xbc,
    THUMB_POP_PC = 0xbd,
    THUMB_STMIA = 0xc0,
    THUMB_LDMIA = 0xc8,
    THUMB_BCOND = 0xd0,
    THUMB_B = 0xe0
};
enum {
    THUMB_ALU_AND = 0,
    THUMB_ALU_EOR = 1,
    THUMB_ALU_LSL = 2,
    THUMB_ALU_LSR = 3,
    THUMB_ALU_ASR = 4,
    THUMB_ALU_NEG = 9,
    THUMB_ALU_CMP = 10,
    THUMB_ALU_ORR = 12,
    THUMB_ALU_MUL = 13,
    THUMB_ALU_BIC = 14,
    THUMB_ALU_MVN = 15
};

static int32_t min_i(int32_t a, int32_t b)
{
    return a < b ? a : b;
}
static int32_t max_i(int32_t a, int32_t b)
{
    return a > b ? a : b;
}
static uint32_t bit(int32_t r)
{
    return UINT32_C(1) << ((uint32_t)r & 31);
}
static int32_t neg_i(int32_t n)
{
    return (int32_t)(0u - (uint32_t)n);
}
static int32_t displacement(uint32_t to, uint32_t from)
{
    return (int32_t)(to - from - 4) >> 1;
}
static bool resolved(const JbedThumbCoder *t, uint32_t label)
{
    return label && !(label & t->fixup_bit);
}
static void require(JbedThumbCoder *t, bool valid, const char *message)
{
    if (!valid)
        jbed_raise_internal(t->runtime, message);
}
static void halt_unless(JbedThumbCoder *t, bool valid, const char *message)
{
    if (!valid)
        jbed_halt(t->runtime, 0, message);
}
static void runtime_require(JbedThumbCoder *t, bool valid, const char *message)
{
    if (!valid) {
        const JbedError error = {
            .kind = JBED_ERROR_RUNTIME_EXCEPTION, .is_java_error = false, .message = message};
        jbed_raise(t->runtime, &error);
    }
}

/* FCoder's literal targets in EntryCode, ExitCode, PrepareCall, CallVirtual,
 * ResetLongJumps, BaseOffset, NilTest, InsertCheckPoint and Op2. */
JbedThumbRuntimeAddresses jbed_thumb_rom_helpers(uint32_t image_base)
{
    return (JbedThumbRuntimeAddresses){
        .compiler_code = image_base + 0x13f7cd,
        .throw_null = image_base + 0xe080d, .throw_index = image_base + 0xe0819,
        .throw_stack = image_base + 0xe0851, .throw_large_stack = image_base + 0xe0825,
        .throw_abstract = image_base + 0xe0879, .throw_no_class = image_base + 0xe0891,
        .interface_stub = image_base + 0xe08b5, .initialize = image_base + 0xe2af9,
        .monitor_enter = image_base + 0xe03b9, .monitor_exit = image_base + 0xe03f9,
        .checkpoint = image_base + 0xb8dd5, .save_frame = image_base + 0xe0c89,
        .integer_divide = image_base + 0xe6d25, .integer_remainder = image_base + 0xe6e45
    };
}

/* 0x13fb38 NewCoder; helper constructors 0x169a70,0x16e570 have zero state. */
void jbed_thumb_init(JbedThumbCoder *t, JbedCoder *coder, JbedRuntime *runtime,
                     const JbedThumbRuntimeAddresses *helpers, bool xip)
{
    memset(t, 0, sizeof(*t));
    t->coder = coder;
    coder->thumb = t;
    coder->long_jumps = xip;
    t->runtime = runtime;
    t->helpers = helpers ? *helpers : jbed_thumb_rom_helpers(0);
    t->constant_capacity = 32;
    t->constants = jbed_alloc(runtime, 32 * sizeof(*t->constants));
    t->thumb_bit = 1;
    t->tree_entry_cost = xip ? 7 : 3;
    t->long_jump_cost = xip ? 12 : 0;
    t->xip_region = xip ? JBED_CODE_BASE : 0;
    jbed_thumb_reset_long_jumps(t);
}

void jbed_thumb_destroy(JbedThumbCoder *t)
{
    /* Managed allocations belong to the supplied runtime's compilation arena. */
    memset(t, 0, sizeof(*t));
}

/* 0x1427d8 Reset */
void jbed_thumb_reset(JbedThumbCoder *t)
{
    t->writer = NULL;
    t->coder = NULL;
    jbed_thumb_reset_long_jumps(t);
}

/* 0x13fe92 ActualPc; 0x14039c Border */
uint32_t jbed_thumb_actual_pc(const JbedThumbCoder *t)
{
    return t->pc;
}
uint32_t jbed_thumb_border(JbedThumbCoder *t)
{
    t->trap_cache[0] = t->trap_cache[3] = 0;
    return t->pc;
}

/* 0x13edc4 BitNum. The original caller supplies a nonzero bit mask. */
unsigned jbed_thumb_bit_num(uint32_t value)
{
    unsigned result = 0;
    while (!(value & 1)) {
        value >>= 1;
        ++result;
    }
    return result;
}

/* 0x13edd4 CallInstr: classic Thumb BL, displacement measured in halfwords. */
uint32_t jbed_thumb_call_instr(int32_t value)
{
    uint32_t bits = (uint32_t)value;
    return ((UINT32_C(0xf800) + (bits & 0x7ff)) << 16) |
           (UINT32_C(0xf000) + ((bits >> 11) & 0x7ff));
}

/* 0x13ed80 AllowCodeInterruption */
void jbed_thumb_allow_code_interruption(JbedThumbCoder *t, bool allow)
{
    t->interruption_depth += allow ? -1 : 1;
    halt_unless(t, t->interruption_depth >= 0, "unbalanced code interruption guard");
}

static void emission_limit(JbedThumbCoder *t)
{
    halt_unless(t, t->pc < t->code_limit, "method code allocation limit exceeded");
}

/* 0x13f774 GenHWord */
void jbed_thumb_gen_hword(JbedThumbCoder *t, uint16_t word)
{
    emission_limit(t);
    jbed_writer_put_halfword(t->writer, t->pc, word);
    t->pc += 2;
}

/* 0x13f954 GenWord */
void jbed_thumb_gen_word(JbedThumbCoder *t, uint32_t word)
{
    emission_limit(t);
    jbed_writer_put_word(t->writer, t->pc, word);
    t->pc += 4;
}

/* 0x13f826 GenPointer */
void jbed_thumb_gen_pointer(JbedThumbCoder *t, uint32_t value)
{
    emission_limit(t);
    jbed_writer_put_pointer(t->writer, t->pc, value);
    t->pc += 4;
}

/* 0x13f8fc GenStatic */
void jbed_thumb_gen_static(JbedThumbCoder *t, uint32_t value)
{
    emission_limit(t);
    jbed_writer_put_static(t->writer, t->pc, value);
    t->pc += 4;
}

/* 0x13f89e GenReloc */
void jbed_thumb_gen_reloc(JbedThumbCoder *t, uint32_t value, bool resident)
{
    emission_limit(t);
    jbed_writer_put_reloc(t->writer, t->pc, value, resident);
    t->pc += 4;
}

/* 0x13f614 GenCall */
void jbed_thumb_gen_call(JbedThumbCoder *t, int32_t offset)
{
    emission_limit(t);
    jbed_writer_put_call(t->writer, t->pc, jbed_thumb_call_instr(offset), false);
    t->pc += 4;
}

/* 0x13f7fc GenInstrNoCheck; 0x13f7cc GenInstr */
void jbed_thumb_gen_instr_no_check(JbedThumbCoder *t, int32_t a, int32_t b, int32_t c, int32_t d)
{
    jbed_thumb_gen_hword(
        t, (uint16_t)(((uint32_t)a << 8) + ((uint32_t)b << 6) + ((uint32_t)c << 3) + (uint32_t)d));
}

void jbed_thumb_gen_instr(JbedThumbCoder *t, int32_t a, int32_t b, int32_t c, int32_t d)
{
    jbed_thumb_check_boundaries(t, 2);
    jbed_thumb_gen_instr_no_check(t, a, b, c, d);
}

/* 0x13f87c GenRegMove */
void jbed_thumb_gen_reg_move(JbedThumbCoder *t, int32_t to, int32_t from)
{
    if (to != from)
        jbed_thumb_gen_instr(t, THUMB_LSL_IMM, 0, from, to);
}

/* 0x13f678 GenConLoad */
void jbed_thumb_gen_con_load(JbedThumbCoder *t, int32_t reg, int32_t value)
{
    if ((value >> 8) == 0)
        jbed_thumb_gen_instr(t, reg + THUMB_MOV_IMM, 0, 0, value);
    else if ((value >> 8) == -1) {
        jbed_thumb_gen_instr(t, reg + THUMB_MOV_IMM, 0, 0, ~value);
        jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_MVN, reg, reg);
    } else
        jbed_thumb_load_const_val(t, reg, value, 0);
}

/* 0x1411c0 GenConAdd */
void jbed_thumb_gen_con_add(JbedThumbCoder *t, int32_t to, int32_t from, int32_t value)
{
    int32_t magnitude = neg_i(value);
    if ((value >> 3) == 0)
        jbed_thumb_gen_instr(t, THUMB_ADD_IMM3, value, from, to);
    else if ((magnitude >> 3) == 0)
        jbed_thumb_gen_instr(t, THUMB_SUB_IMM3, magnitude, from, to);
    else if ((value >> 8) == 0) {
        jbed_thumb_gen_reg_move(t, to, from);
        jbed_thumb_gen_instr(t, to + THUMB_ADD_IMM8, 0, 0, value);
    } else if ((magnitude >> 8) == 0) {
        jbed_thumb_gen_reg_move(t, to, from);
        jbed_thumb_gen_instr(t, to + THUMB_SUB_IMM8, 0, 0, magnitude);
    } else {
        int32_t work = to == from ? jbed_thumb_temp_register(t, bit(from)) : to;
        jbed_thumb_gen_con_load(t, work, value >= 0 ? value : magnitude);
        jbed_thumb_gen_instr(t, value >= 0 ? THUMB_ADD_REG : THUMB_SUB_REG, work, from, to);
    }
}

/* 0x13f9d8 LoadConstVal */
void jbed_thumb_load_const_val(JbedThumbCoder *t, int32_t reg, int32_t value, uint8_t kind)
{
    jbed_thumb_check_boundaries(t, 8);
    if (t->constant_count == t->constant_capacity) {
        size_t capacity = t->constant_capacity * 2;
        JbedThumbConstant *next = jbed_alloc(t->runtime, capacity * sizeof(*next));
        memcpy(next, t->constants, t->constant_count * sizeof(*next));
        t->constants = next;
        t->constant_capacity = capacity;
    }
    size_t index = t->constant_count;
    t->constants[index] = (JbedThumbConstant){value, t->pc, kind};
    uint32_t limit = t->pc + 1020 - (uint32_t)(4 * index) - 4;
    if (limit < t->literal_limit)
        t->literal_limit = limit;
    ++t->constant_count;
    jbed_thumb_gen_instr(t, reg + THUMB_LDR_LITERAL, 0, 0, 0);
}

/* 0x13f0b4 FlushConstVal: preserve first-occurrence order and type-sensitive
 * deduplication; each placeholder is patched using Thumb's aligned PC rule. */
void jbed_thumb_flush_const_val(JbedThumbCoder *t)
{
    if (t->constant_count) {
        jbed_thumb_allow_code_interruption(t, false);
        if (t->pc & 3)
            jbed_thumb_gen_hword(t, 0);
        for (size_t i = 0; i < t->constant_count; ++i) {
            JbedThumbConstant *entry = &t->constants[i];
            size_t first = 0;
            while (t->constants[first].value != entry->value ||
                   t->constants[first].kind != entry->kind)
                ++first;
            uint32_t site = entry->site;
            uint32_t literal;
            if (first == i) {
                literal = entry->site = t->pc;
                switch (entry->kind) {
                case 0:
                    jbed_thumb_gen_word(t, (uint32_t)entry->value);
                    break;
                case 1:
                    jbed_thumb_gen_pointer(t, (uint32_t)entry->value);
                    break;
                case 2:
                    jbed_thumb_gen_reloc(t, (uint32_t)entry->value, true);
                    break;
                case 3:
                    jbed_thumb_gen_static(t, (uint32_t)entry->value);
                    break;
                case 4:
                    jbed_coder_set_control_word_ref(t->coder, literal, t->control_word);
                    jbed_thumb_gen_word(t, 0);
                    break;
                }
            } else
                literal = t->constants[first].site;
            uint32_t distance = literal - site - 2;
            require(t, !(distance & 1) && distance < 1024, "literal pool outside Thumb LDR range");
            uint16_t instruction = (uint16_t)jbed_writer_get_halfword(t->writer, site);
            jbed_writer_put_halfword(t->writer, site, (uint16_t)(instruction + (distance >> 2)));
        }
        jbed_thumb_allow_code_interruption(t, true);
    }
    t->constant_count = 0;
    t->literal_limit = t->code_limit;
}

/* 0x13f9ac InsertConstVal */
void jbed_thumb_insert_const_val(JbedThumbCoder *t)
{
    if (t->pc > t->literal_limit - 510)
        jbed_thumb_flush_const_val(t);
}

/* 0x13fc18 ReadFixup */
JbedThumbFixupInfo jbed_thumb_read_fixup(JbedThumbCoder *t, uint32_t address)
{
    uint32_t first = (uint16_t)jbed_writer_get_halfword(t->writer, address);
    int32_t kind = (int32_t)(first >> 11);
    int32_t delta;
    if (kind > 15) {
        kind = 16;
        delta =
            (int32_t)((first & 0x7fff) +
                      ((uint32_t)(int32_t)jbed_writer_get_halfword(t->writer, address + 2) << 15));
    } else {
        delta = (int32_t)(first & 0x7ff);
        if (kind == 15)
            delta = (int32_t)((uint32_t)delta +
                              ((uint32_t)(int32_t)jbed_writer_get_halfword(t->writer, address + 2)
                               << 11));
    }
    return (JbedThumbFixupInfo){kind, delta};
}

/* 0x13fdd0 WriteFixup */
void jbed_thumb_write_fixup(JbedThumbCoder *t, uint32_t address, int32_t kind, int32_t delta)
{
    require(t, kind <= 16, "invalid Thumb fixup kind");
    uint16_t low = kind == 16 ? (uint16_t)(0x8000 | ((uint32_t)delta & 0x7fff))
                              : (uint16_t)((kind << 11) + ((uint32_t)delta & 0x7ff));
    uint16_t high = (uint16_t)(delta >> (kind == 16 ? 15 : 11));
    if (address) {
        jbed_writer_put_halfword(t->writer, address, low);
        if (kind >= 15)
            jbed_writer_put_halfword(t->writer, address + 2, high);
    } else {
        jbed_thumb_gen_hword(t, low);
        if (kind >= 15)
            jbed_thumb_gen_hword(t, high);
    }
}

/* 0x13f6d2 GenFixup */
uint32_t jbed_thumb_gen_fixup(JbedThumbCoder *t, int32_t kind, uint32_t chain)
{
    uint32_t site = chain & ~t->fixup_bit;
    int32_t delta = 0;
    if (chain && kind < 15) {
        JbedThumbFixupInfo info;
        do {
            info = jbed_thumb_read_fixup(t, site);
            site += (uint32_t)info.displacement * 2;
        } while (info.displacement);
        jbed_thumb_write_fixup(t, site, info.kind, (int32_t)(t->pc - site) >> 1);
    } else {
        if (chain)
            delta = (int32_t)(site - t->pc) >> 1;
        chain = t->pc | t->fixup_bit;
    }
    jbed_thumb_write_fixup(t, 0, kind, delta);
    if (kind < 15)
        ++t->short_fixups;
    return chain;
}

/* 0x140ef0 Fixup */
void jbed_thumb_fixup(JbedThumbCoder *t, uint32_t chain, uint32_t destination)
{
    if (destination == t->helpers.throw_abstract)
        destination = t->long_jumps[0]->label;
    else if (destination == t->helpers.throw_no_class)
        destination = t->long_jumps[1]->label;
    if (!(chain & t->fixup_bit))
        return;
    uint32_t site = chain & ~t->fixup_bit;
    JbedThumbFixupInfo info;
    do {
        int32_t delta = displacement(destination, site);
        info = jbed_thumb_read_fixup(t, site);
        switch (info.kind) {
        case 15:
            require(t, delta >= -2097152 && delta < 2097152, "Thumb BL fixup out of range");
            jbed_writer_put_call(t->writer, site, jbed_thumb_call_instr(delta), false);
            break;
        case 16:
            jbed_writer_put_reloc(t->writer, site, destination + t->thumb_bit, false);
            break;
        case 14:
            require(t, delta >= -2 && delta < 1024, "Thumb branch fixup out of range");
            --t->short_fixups;
            jbed_writer_put_halfword(t->writer, site,
                                     (uint16_t)(0xe000 + ((uint32_t)delta & 0x7ff)));
            break;
        default:
            require(t, delta >= -2 && delta < 128, "Thumb conditional fixup out of range");
            --t->short_fixups;
            jbed_writer_put_halfword(t->writer, site,
                                     (uint16_t)(((info.kind + 208) << 8) + (uint8_t)delta));
            break;
        }
        site += 2u * (uint32_t)info.displacement;
    } while (info.displacement);
}

/* 0x1428bc SetLabel */
uint32_t jbed_thumb_set_label(JbedThumbCoder *t, uint32_t chain, uint32_t writer_label)
{
    jbed_thumb_fixup(t, chain, t->pc);
    if (writer_label)
        jbed_writer_set_label(t->writer, writer_label, t->pc);
    return t->pc;
}

/* 0x13fe78,0x1412a0,0x142c24: architecture constants. */
int32_t jbed_thumb_get_max_static_base_offset(void)
{
    return 64;
}
int32_t jbed_thumb_get_num_optimized_registers(void)
{
    return 7;
}
int32_t jbed_thumb_synchronizer_stackmap_bit(void)
{
    return 0;
}

/* 0x13ecf4 Address */
int32_t jbed_thumb_address(const JbedThumbCoder *t, int32_t mode, int32_t value)
{
    if (mode == JBED_LOCATION_LOCAL) {
        if (value < 32)
            return t->local_locations[value];
        if (value < t->argument_count)
            return 4 * (value - 4) + t->frame_size;
        return 4 * (value - t->argument_count - t->local_registers) + t->stack_bytes;
    }
    if (mode == JBED_LOCATION_STACK)
        return t->stack_bytes - 4 - 4 * (value - t->stack_registers);
    return 0;
}

/* 0x13fca8 Register */
int32_t jbed_thumb_register(const JbedThumbCoder *t, int32_t mode, int32_t value)
{
    if (mode == JBED_LOCATION_LOCAL && value < 32) {
        int32_t location = t->local_locations[value];
        if (location < 0)
            return -location;
    } else if (mode == JBED_LOCATION_STACK && value < t->stack_registers)
        return t->monitor_registers + 4 + t->argument_registers + t->local_registers + value;
    else if (mode == JBED_LOCATION_REGISTER)
        return value;
    return -1;
}

/* 0x1422f4 PointerBit */
int32_t jbed_thumb_pointer_bit(const JbedThumbCoder *t, int32_t mode, int32_t value)
{
    int32_t reg = jbed_thumb_register(t, mode, value);
    return reg >= 0 ? reg - 4
                    : ((jbed_thumb_address(t, mode, value) - t->large_frame_size) >> 2) + 3;
}

/* 0x142908 SetRegister */
void jbed_thumb_set_register(JbedThumbCoder *t, int32_t index, int32_t reg)
{
    t->coder->stack[index].location = JBED_LOCATION_REGISTER;
    t->coder->stack[index].value = reg;
    jbed_coder_remove_array_registers(t->coder, bit(reg));
}

/* 0x1432ba WritableReg */
bool jbed_thumb_writable_reg(const JbedThumbCoder *t, int32_t index)
{
    const JbedCoder *c = t->coder;
    if (c->stack[index].location != JBED_LOCATION_REGISTER)
        return false;
    for (int32_t i = c->input_depth; i-- > 0;)
        if (i != index && c->stack[i].location == JBED_LOCATION_REGISTER &&
            c->stack[i].value == c->stack[index].value)
            return false;
    return true;
}

/* 0x141b00 NewRegister. Try cached-address/index masks in that order, then
 * spill the first unexcluded temporary into its permanent stack location. */
int32_t jbed_thumb_new_register(JbedThumbCoder *t, int32_t preferred, uint32_t excluded, bool spill)
{
    JbedCoder *c = t->coder;
    int32_t first = preferred & 3;
    uint32_t unavailable = excluded | jbed_coder_get_array_index_registers(c, true);
    bool include_addresses = true;
    size_t spill_index = 0;
    for (;;) {
        int32_t reg = first;
        do {
            bool used = (bit(reg) & unavailable) != 0;
            for (int32_t i = c->input_depth; !used && i-- > 0;)
                used = c->stack[i].location == JBED_LOCATION_REGISTER && c->stack[i].value == reg;
            if (!used)
                return reg;
            reg = (reg + 1) & 3;
        } while (reg != first);
        if (unavailable & ~excluded) {
            if (include_addresses) {
                unavailable = excluded | jbed_coder_get_array_index_registers(c, false);
                include_addresses = false;
            } else
                unavailable = excluded;
        } else {
            if (!spill)
                return -1;
            while (spill_index < c->stack_capacity &&
                   (c->stack[spill_index].location != JBED_LOCATION_REGISTER ||
                    (bit(c->stack[spill_index].value) & unavailable)))
                ++spill_index;
            runtime_require(t, spill_index < c->stack_capacity, "no spillable Thumb work register");
            first = c->stack[spill_index].value & 3;
            jbed_thumb_make_perm(t, (int32_t)spill_index++);
        }
    }
}

/* 0x142e60 TempRegister */
int32_t jbed_thumb_temp_register(JbedThumbCoder *t, uint32_t excluded)
{
    int32_t reg = jbed_thumb_new_register(t, t->coder->input_depth, excluded, true);
    jbed_coder_remove_array_registers(t->coder, bit(reg));
    return reg;
}

/* 0x143250 WorkRegister */
int32_t jbed_thumb_work_register(JbedThumbCoder *t, int32_t index)
{
    if (t->coder->stack[index].location == JBED_LOCATION_REGISTER)
        t->coder->stack[index].value = -1;
    int32_t reg = jbed_thumb_new_register(t, index, 0, true);
    jbed_thumb_set_register(t, index, reg);
    return reg;
}

/* 0x1427fc ResultRegister */
int32_t jbed_thumb_result_register(JbedThumbCoder *t, int32_t index, bool preserve_arrays)
{
    JbedCoder *c = t->coder;
    int32_t reg = -1;
    if (c->destination_local >= 0)
        reg = jbed_thumb_register(t, JBED_LOCATION_LOCAL,
                                  c->destination_local + index - c->stack_depth);
    if (reg < 0 && preserve_arrays)
        reg = jbed_thumb_new_register(t, index, 0, false);
    if (reg < 0)
        reg = jbed_thumb_work_register(t, index);
    else
        jbed_thumb_set_register(t, index, reg);
    runtime_require(t, !(bit(reg) & jbed_coder_get_array_index_registers(c, true)),
                    "result overwrites cached array register");
    return reg;
}

/* 0x1418a8 LoadReg */
int32_t jbed_thumb_load_reg(JbedThumbCoder *t, int32_t offset)
{
    int32_t index = t->coder->stack_depth + offset;
    JbedCoderSlot slot = t->coder->stack[index];
    int32_t reg = jbed_thumb_register(t, slot.location, slot.value);
    if (reg < 0) {
        jbed_thumb_make_temp(t, index);
        reg = t->coder->stack[index].value;
    }
    return reg;
}

/* 0x14191c LoadThisReg */
void jbed_thumb_load_this_reg(JbedThumbCoder *t, int32_t mode, int32_t value, int32_t to)
{
    int32_t from = jbed_thumb_register(t, mode, value);
    require(t, to < 8 || from >= 0, "high-register load requires a register source");
    if (from >= 8 || to >= 8)
        jbed_thumb_gen_instr(t, THUMB_MOV_HIGH, 2 * (to >> 3), from, to & 7);
    else if (from >= 0)
        jbed_thumb_gen_reg_move(t, to, from);
    else if (mode == JBED_LOCATION_CONSTANT)
        jbed_thumb_gen_con_load(t, to, value);
    else if (mode == JBED_LOCATION_POINTER)
        jbed_thumb_load_const_val(t, to, value, 1);
    else if (mode == JBED_LOCATION_LOCAL_OFFSET) {
        int32_t local = (int32_t)(uint16_t)value - 1;
        int32_t reg = jbed_thumb_register(t, JBED_LOCATION_LOCAL, local);
        if (reg < 0) {
            jbed_thumb_load_this_reg(t, JBED_LOCATION_LOCAL, local, to);
            reg = to;
        }
        jbed_thumb_gen_con_add(t, to, reg, value >> 16);
    } else
        jbed_thumb_stack_load_store(t, mode, value, to, 8);
}

/* 0x141aa2 MakeTemp */
void jbed_thumb_make_temp(JbedThumbCoder *t, int32_t index)
{
    JbedCoderSlot slot = t->coder->stack[index];
    int32_t reg = jbed_thumb_work_register(t, index);
    jbed_thumb_load_this_reg(t, slot.location, slot.value, reg);
}

/* 0x1419ec MakePerm */
void jbed_thumb_make_perm(JbedThumbCoder *t, int32_t index)
{
    JbedCoderSlot slot = t->coder->stack[index];
    if (slot.location == JBED_LOCATION_STACK)
        return;
    int32_t reg = jbed_thumb_register(t, JBED_LOCATION_STACK, index);
    if (reg >= 0)
        jbed_thumb_load_this_reg(t, slot.location, slot.value, reg);
    else {
        reg = jbed_thumb_load_reg(t, index - t->coder->stack_depth);
        jbed_thumb_stack_load_store(t, JBED_LOCATION_STACK, index, reg, 0);
    }
    t->coder->stack[index].location = JBED_LOCATION_STACK;
    t->coder->stack[index].value = index;
}

/* 0x142614 RegAssign: resolve parallel register moves, breaking cycles with LR. */
void jbed_thumb_reg_assign(JbedThumbCoder *t, int32_t first_reg, int32_t start, int32_t count)
{
    JbedCoder *c = t->coder;
    int32_t end = start + count;
    for (int32_t i = start; i < end; ++i) {
        if (c->stack[i].location == JBED_LOCATION_LOCAL_OFFSET) {
            int32_t value = c->stack[i].value;
            int32_t work = jbed_thumb_work_register(t, i);
            jbed_thumb_load_this_reg(t, JBED_LOCATION_LOCAL_OFFSET, value, work);
        }
    }
    bool break_cycle = false, pending;
    do {
        bool progress = false;
        pending = false;
        for (int32_t i = start; i < end; ++i) {
            int32_t destination = first_reg + i - start;
            JbedCoderSlot source = c->stack[i];
            if (source.location == JBED_LOCATION_REGISTER && source.value == destination)
                continue;
            int32_t j = start;
            while (j < end && !(c->stack[j].location == JBED_LOCATION_REGISTER &&
                                c->stack[j].value == destination))
                ++j;
            if (j == end || break_cycle) {
                if (j != end) {
                    jbed_thumb_check_boundaries(t, 10);
                    destination = 14;
                    pending = true;
                }
                jbed_thumb_load_this_reg(t, source.location, source.value, destination);
                jbed_thumb_set_register(t, i, destination);
                progress = true;
                break_cycle = false;
            } else
                pending = true;
        }
        if (!progress)
            break_cycle = true;
    } while (pending);
    for (int32_t i = start; i < end; ++i)
        halt_unless(t, c->stack[i].location == JBED_LOCATION_REGISTER,
                    "parallel register assignment incomplete");
}

/* 0x141c80 Normalize */
void jbed_thumb_normalize(JbedThumbCoder *t, bool emit)
{
    JbedCoder *c = t->coder;
    if (c->stack_depth <= 0)
        return;
    if (emit) {
        int32_t i = c->input_depth;
        while (i > c->stack_depth) {
            JbedCoderSlot slot = c->stack[i - 1];
            if (slot.location == JBED_LOCATION_REGISTER && slot.value < 2)
                break;
            --i;
        }
        while (i > 2)
            jbed_thumb_make_perm(t, --i);
        jbed_thumb_reg_assign(t, 0, 0, i);
    } else {
        for (int32_t i = 0; i < c->stack_depth; ++i) {
            c->stack[i].location = i >= 2 ? JBED_LOCATION_STACK : JBED_LOCATION_REGISTER;
            c->stack[i].value = i;
            if (i < 2)
                jbed_coder_remove_array_registers(c, bit(i));
        }
    }
}

/* 0x1425cc PrepareStackOp */
void jbed_thumb_prepare_stack_op(JbedThumbCoder *t, int32_t count)
{
    int32_t index = t->coder->stack_depth;
    while (count-- > 0) {
        --index;
        if (t->coder->stack[index].location == JBED_LOCATION_STACK)
            jbed_thumb_make_temp(t, index);
    }
}

/* 0x1412a4 HandlerEntry; 0x14288c Return */
void jbed_thumb_handler_entry(JbedThumbCoder *t)
{
    jbed_thumb_set_register(t, 0, 0);
}
void jbed_thumb_return(JbedThumbCoder *t)
{
    jbed_thumb_reg_assign(t, t->method_flags & JBED_ACC_SYNCHRONIZED ? 5 : 0, t->coder->stack_depth,
                          t->coder->input_depth - t->coder->stack_depth);
}

/* 0x14057c CheckStackMap */
void jbed_thumb_check_stack_map(JbedThumbCoder *t)
{
    for (int32_t i = 0; i < t->coder->input_depth; ++i)
        if (t->coder->stack[i].type >= -2 && t->coder->stack[i].location == JBED_LOCATION_REGISTER)
            jbed_thumb_make_perm(t, i);
    jbed_coder_insert_map(t->coder, t->pc + 4, t->coder->input_depth);
}

/* 0x1429a0 StackLoadStore */
void jbed_thumb_stack_load_store(JbedThumbCoder *t, int32_t mode, int32_t value, int32_t reg,
                                 int32_t load)
{
    int32_t address = jbed_thumb_address(t, mode, value);
    if (address < 1024)
        jbed_thumb_gen_instr(t, load + THUMB_STR_SP + reg, 0, 0, address >> 2);
    else {
        int32_t work = jbed_thumb_temp_register(t, 0);
        jbed_thumb_gen_con_load(t, work, address);
        jbed_thumb_gen_instr(t, THUMB_ADD_HIGH, 0, 13, work);
        jbed_thumb_gen_instr(t, load + THUMB_STR_IMM, 0, work, reg);
    }
}

/* 0x13fd24 ReservedCodeSize */
int32_t jbed_thumb_reserved_code_size(const JbedThumbCoder *t, bool crossing_pool)
{
    int32_t bytes =
        t->constant_count ? (int32_t)(4 * t->constant_count) + (crossing_pool ? 8 : 6) : 4;
    if (t->coder->long_jumps)
        bytes += (int32_t)(12 * (t->long_jump_count - t->emitted_long_jumps)) + 8;
    return bytes;
}

/* 0x13edf0 CheckBoundaries */
void jbed_thumb_check_boundaries(JbedThumbCoder *t, int32_t bytes)
{
    uint32_t old_pc = t->pc;
    uint32_t requested_end = old_pc + (uint32_t)bytes;
    bool crossing_pool = requested_end > t->literal_limit;
    if (t->coder->allocation_limited &&
        requested_end > t->code_limit - (uint32_t)jbed_thumb_reserved_code_size(t, crossing_pool)) {
        jbed_thumb_gen_word(t, 0);
        if (t->coder->long_jumps) {
            jbed_thumb_gen_word(t, 0);
            if (t->pc & 3)
                jbed_thumb_gen_hword(t, 0);
            jbed_thumb_gen_word(t, 0);
        }
        halt_unless(t, !t->short_fixups, "short branches cross an allocation boundary");
        halt_unless(t, !t->interruption_depth,
                    "allocation split inside guarded instruction sequence");
        jbed_thumb_flush_const_val(t);
        if (t->coder->long_jumps) {
            jbed_thumb_flush_long_jumps(t);
            jbed_thumb_reset_long_jumps(t);
        }
        jbed_coder_flush_alloc(t->coder, t->pc);
        t->code_start =
            jbed_coder_alloc_method_code_space(t->coder, false, (uint32_t)max_i(bytes + 4, 128));
        t->code_limit = t->literal_limit = t->coder->code_limit;
        t->pc = old_pc;
        if (t->coder->long_jumps) {
            jbed_thumb_gen_instr_no_check(t, THUMB_PUSH, 0, 0, 3);
            jbed_thumb_gen_instr_no_check(t, THUMB_LDR_LITERAL, 0, 0, 1);
            jbed_thumb_gen_instr_no_check(t, THUMB_STR_SP, 0, 0, 1);
            jbed_thumb_gen_instr_no_check(t, THUMB_POP_PC, 0, 0, 1);
            if (t->pc & 3)
                jbed_thumb_gen_hword(t, 0);
            jbed_thumb_gen_reloc(t, t->code_start + 1, false);
        } else
            jbed_thumb_gen_call(t, displacement(t->code_start, old_pc));
        t->pc = t->code_start;
        jbed_coder_reinsert_last_map(t->coder, t->pc);
    } else if (crossing_pool) {
        jbed_thumb_gen_hword(t, 0);
        jbed_thumb_flush_const_val(t);
        uint32_t pool_end = t->pc;
        t->pc = old_pc;
        jbed_thumb_gen_hword(t, (uint16_t)(0xe000 + displacement(pool_end, old_pc)));
        t->pc = pool_end;
    }
}

/* 0x140338 BeforeLimit */
bool jbed_thumb_before_limit(JbedThumbCoder *t, int32_t bytecodes, int32_t reserved)
{
    if (bytecodes > 0 && t->coder->allocation_limited) {
        int32_t available = (int32_t)(t->code_limit - (uint32_t)reserved - t->pc) -
                            jbed_thumb_reserved_code_size(t, true);
        return bytecodes < jbed_coder_get_original_bytecode_size(t->coder, available >> 3);
    }
    return true;
}

/* 0x13ea94 AddLongJump */
JbedThumbLongJump *jbed_thumb_add_long_jump(JbedThumbCoder *t, JbedMethod *method, uint32_t target,
                                            uint32_t flags)
{
    halt_unless(t, flags & (JBED_JUMP_ABSOLUTE | JBED_JUMP_METHOD | JBED_JUMP_LOCAL),
                "Long jump type not specified.");
    halt_unless(t, !(flags & JBED_JUMP_ABSOLUTE) || resolved(t, target),
                "Long jump inconsistency: No target for static call");
    halt_unless(t, !(flags & JBED_JUMP_METHOD) || method,
                "Long jump inconsistency: Dynamic method not specified");
    if (flags & JBED_JUMP_ABSOLUTE)
        target &= ~UINT32_C(1);
    for (size_t i = 0; i < t->long_jump_count; ++i) {
        JbedThumbLongJump *entry = t->long_jumps[i];
        if ((flags & entry->flags & JBED_JUMP_ABSOLUTE) && target == entry->target &&
            ((flags ^ entry->flags) & JBED_JUMP_CLOBBERS_R3))
            halt_unless(
                t,
                target == (t->helpers.throw_abstract & ~1u) ||
                    target == (t->helpers.throw_no_class & ~1u),
                "Long jump inconsistency: Call to same method but different number of arguments");
        if (flags == entry->flags &&
            (((flags & JBED_JUMP_ABSOLUTE) && target == entry->target) ||
             ((flags & JBED_JUMP_METHOD) && method == entry->method) ||
             ((flags & JBED_JUMP_LOCAL) && method == entry->method && target == entry->target)))
            return entry;
    }
    size_t slot = t->long_jump_count;
    if (slot == t->long_jump_capacity) {
        size_t capacity = slot * 2;
        JbedThumbLongJump **entries = jbed_alloc(t->runtime, capacity * sizeof(*entries));
        memcpy(entries, t->long_jumps, slot * sizeof(*entries));
        t->long_jumps = entries;
        t->long_jump_capacity = capacity;
    }
    JbedThumbLongJump *entry = t->long_jumps[slot];
    if (entry) {
        entry->label = 0;
        entry->writer_fixup = 0;
        entry->method = NULL;
    } else {
        entry = jbed_alloc(t->runtime, sizeof(*entry));
        t->long_jumps[slot] = entry;
    }
    ++t->long_jump_count;
    entry->flags = flags;
    entry->target = target;
    if (flags & (JBED_JUMP_METHOD | JBED_JUMP_LOCAL))
        entry->method = method;
    return entry;
}

/* 0x13fd7c ResetLongJumps */
void jbed_thumb_reset_long_jumps(JbedThumbCoder *t)
{
    t->emitted_long_jumps = t->long_jump_count = 0;
    t->long_jumps = jbed_alloc(t->runtime, 16 * sizeof(*t->long_jumps));
    t->long_jump_capacity = 16;
    jbed_thumb_add_long_jump(t, NULL, t->helpers.throw_abstract,
                             JBED_JUMP_ABSOLUTE | JBED_JUMP_CLOBBERS_R3);
    jbed_thumb_add_long_jump(t, NULL, t->helpers.throw_no_class,
                             JBED_JUMP_ABSOLUTE | JBED_JUMP_CLOBBERS_R3);
}

/* 0x13f000 CheckLongJumpConsistency */
void jbed_thumb_check_long_jump_consistency(JbedThumbCoder *t)
{
    size_t local_jumps = 0, temporary_jumps = 0;
    for (size_t i = t->emitted_long_jumps; i < t->long_jump_count; ++i) {
        uint32_t flags = t->long_jumps[i]->flags;
        if (flags & JBED_JUMP_LOCAL) {
            ++local_jumps;
            if (flags & JBED_JUMP_TEMP_INDEX)
                ++temporary_jumps;
        }
    }
    if (local_jumps) {
        printf("WARNING: Pending long jump stubs for local jumps after closing method: %zu\n",
               local_jumps);
        halt_unless(t, !temporary_jumps, "Pending long jumps to temporary labels");
    }
}

/* 0x13f2e0 FlushLongJumps */
void jbed_thumb_flush_long_jumps(JbedThumbCoder *t)
{
    if (t->emitted_long_jumps >= t->long_jump_count)
        return;
    bool long_mode = t->coder->long_jumps;
    if (long_mode)
        jbed_thumb_allow_code_interruption(t, false);
    if (t->pc & 3)
        jbed_thumb_gen_hword(t, 0);
    while (t->emitted_long_jumps < t->long_jump_count) {
        if (!long_mode) {
            jbed_thumb_check_boundaries(t, 12);
            jbed_thumb_allow_code_interruption(t, false);
        }
        JbedThumbLongJump *entry = t->long_jumps[t->emitted_long_jumps];
        entry->label = jbed_thumb_set_label(t, entry->label, entry->writer_fixup);
        if (entry->flags & JBED_JUMP_CLOBBERS_R3) {
            jbed_thumb_gen_instr_no_check(t, THUMB_LDR_LITERAL + 3, 0, 0, 0);
            jbed_thumb_gen_instr_no_check(t, THUMB_MOV_HIGH, 2, 3, 7);
        } else {
            jbed_thumb_gen_instr_no_check(t, THUMB_PUSH, 0, 0, 3);
            jbed_thumb_gen_instr_no_check(t, THUMB_LDR_LITERAL, 0, 0, 1);
            jbed_thumb_gen_instr_no_check(t, THUMB_STR_SP, 0, 0, 1);
            jbed_thumb_gen_instr_no_check(t, THUMB_POP_PC, 0, 0, 1);
        }
        if (!long_mode || (entry->flags & JBED_JUMP_ABSOLUTE))
            jbed_thumb_gen_reloc(t, entry->target + t->thumb_bit, true);
        else {
            uint32_t *target = NULL;
            bool clear = false;
            if (entry->flags & JBED_JUMP_METHOD)
                target = &entry->method->code_address;
            else {
                halt_unless(t, (entry->flags & JBED_JUMP_LOCAL) != 0, "unknown long-jump target");
                if (entry->flags & JBED_JUMP_LABEL_INDEX)
                    target = &t->coder->labels[entry->target];
                else if (entry->flags & JBED_JUMP_TEMP_INDEX) {
                    target = &t->coder->temp_labels[entry->target];
                    clear = true;
                }
            }
            if (!target)
                jbed_thumb_gen_reloc(t, entry->target + t->thumb_bit, false);
            else if (resolved(t, *target)) {
                jbed_thumb_gen_reloc(t, *target + t->thumb_bit, false);
                if (clear)
                    *target = 0;
            } else
                *target = jbed_thumb_gen_fixup(t, 16, *target);
        }
        if (!long_mode)
            jbed_thumb_allow_code_interruption(t, true);
        ++t->emitted_long_jumps;
    }
    if (long_mode)
        jbed_thumb_allow_code_interruption(t, true);
}

/* 0x14136a JumpCC */
uint32_t jbed_thumb_jump_cc(JbedThumbCoder *t, int32_t condition, JbedMethod *method,
                            uint32_t destination, int32_t distance, uint32_t flags)
{
    JbedCoder *c = t->coder;
    bool known = resolved(t, destination);
    bool clobbers_r3 = (flags & JBED_JUMP_CLOBBERS_R3) != 0;
    bool explicit_temp = (flags & 16) != 0;
    uint32_t target_index = (uint32_t)distance;
    bool temporary = explicit_temp;
    if (c->long_jumps) {
        if (!explicit_temp)
            target_index = method || known ? 0 : (uint32_t)c->current_label_index;
        temporary = c->current_label_is_temp || explicit_temp;
    } else
        target_index = 0;
    int32_t estimate = (flags >> 5) ? (int32_t)flags >> 5 : distance;
    jbed_thumb_check_boundaries(t, t->long_jump_cost + 6);
    uint32_t original = destination;
    if (c->long_jumps && !known) {
        destination = method      ? method->code_address
                      : temporary ? c->temp_labels[target_index]
                                  : c->labels[target_index];
        original = destination;
        known = resolved(t, destination);
    }
    bool long_branch = (known && c->allocation_split && destination < t->code_start) ||
                       !jbed_thumb_before_limit(t, estimate, 0);
    int32_t effective_condition = long_branch ? 15 : condition;
    int32_t delta = known ? displacement(destination, t->pc) : 1;
    uint32_t veneer_flags = 0;
    if (!known || (delta >= -2097152 && delta < 2097152)) {
        if (c->long_jumps && method) {
            veneer_flags = JBED_JUMP_METHOD | (clobbers_r3 ? JBED_JUMP_CLOBBERS_R3 : 0);
            runtime_require(t, effective_condition == 15, "method target requires call encoding");
            target_index = destination;
        } else if (c->long_jumps && long_branch) {
            if (known) {
                target_index = destination;
                veneer_flags = JBED_JUMP_LOCAL;
            } else {
                method = c->method;
                veneer_flags =
                    JBED_JUMP_LOCAL | (temporary ? JBED_JUMP_TEMP_INDEX : JBED_JUMP_LABEL_INDEX);
            }
        } else {
            target_index = destination;
        }
    } else {
        veneer_flags = JBED_JUMP_ABSOLUTE | (clobbers_r3 ? JBED_JUMP_CLOBBERS_R3 : 0);
        runtime_require(t, effective_condition == 15, "distant target requires call encoding");
        target_index = destination;
    }
    JbedThumbLongJump *entry = NULL;
    if (veneer_flags) {
        entry = jbed_thumb_add_long_jump(t, method, target_index, veneer_flags);
        target_index = entry->label;
        known = resolved(t, target_index);
        delta = known ? displacement(target_index, t->pc) : 1;
        method = NULL;
    }
    int32_t encoding = 15;
    if (effective_condition == 15)
        encoding = effective_condition;
    else if ((!known || delta >= -1023) && estimate < 249 - (int32_t)(t->constant_count >> 1)) {
        if (effective_condition >= 14 ||
            (delta >= -128 && estimate <= 36 - (int32_t)(t->constant_count >> 1)))
            encoding = effective_condition;
        else
            encoding = 14;
    }
    jbed_thumb_allow_code_interruption(t, false);
    if (condition < 14 && encoding >= 14) {
        jbed_thumb_gen_instr(t, (condition ^ 1) + THUMB_BCOND, 0, 0, encoding - 14);
        --delta;
    }
    if (method)
        target_index = method->code_address;
    if (known) {
        if (encoding == 15)
            jbed_thumb_gen_call(t, delta);
        else if (encoding == 14)
            jbed_thumb_gen_instr(t, THUMB_B, 0, 0, delta & 0x7ff);
        else
            jbed_thumb_gen_instr(t, encoding + THUMB_BCOND, 0, 0, (uint8_t)delta);
    } else
        target_index = jbed_thumb_gen_fixup(t, encoding, target_index);
    jbed_thumb_allow_code_interruption(t, true);
    if (!entry)
        return target_index;
    entry->label = target_index;
    if (!resolved(t, original) && resolved(t, entry->label))
        halt_unless(t,
                    (original & ~t->fixup_bit) ==
                        entry->label + (entry->flags & JBED_JUMP_CLOBBERS_R3 ? 4u : 8u),
                    "long-jump literal and target chain disagree");
    return original;
}

/* 0x141338 Jump */
uint32_t jbed_thumb_jump(JbedThumbCoder *t, uint32_t label, int32_t distance)
{
    uint32_t result = jbed_thumb_jump_cc(t, 14, NULL, label, distance, 0);
    jbed_thumb_insert_const_val(t);
    return result;
}

/* 0x1430b8 TruncateFixup */
uint32_t jbed_thumb_truncate_fixup(JbedThumbCoder *t, uint32_t chain, uint32_t boundary)
{
    if (!(chain & t->fixup_bit))
        return chain;
    uint32_t head = chain & ~t->fixup_bit;
    uint32_t site = head, previous = 0;
    JbedThumbFixupInfo info;
    while (site >= boundary) {
        info = jbed_thumb_read_fixup(t, site);
        if (info.kind < 15 || !info.displacement)
            return head | t->fixup_bit;
        previous = site;
        site += (uint32_t)info.displacement * 2;
    }
    uint32_t label = t->coder->truncate_label;
    do {
        info = jbed_thumb_read_fixup(t, site);
        require(t, info.kind >= 15, "short fixup escaped its code allocation");
        if (info.kind == 16)
            label = jbed_writer_write_long_jump_label(t->writer, site, label);
        else {
            halt_unless(t, !t->coder->long_jumps, "call-chain truncation in long-jump mode");
            label = jbed_writer_write_call_label(t->writer, site, 0, label);
        }
        site += (uint32_t)info.displacement * 2;
    } while (info.displacement && site < boundary);
    t->coder->truncate_label = label;
    if (site < boundary) {
        if (previous)
            jbed_thumb_write_fixup(t, previous, info.kind, 0);
    } else if (previous) {
        /* Original 0x14320e passes the byte difference here, without >>1. */
        jbed_thumb_write_fixup(t, previous, info.kind, (int32_t)(site - previous));
    } else
        head = site | t->fixup_bit;
    return (int32_t)head >= (int32_t)boundary ? head | t->fixup_bit : 0;
}

/* 0x1410f0 FlushCurrentFixups */
void jbed_thumb_flush_current_fixups(JbedThumbCoder *t, uint32_t boundary)
{
    for (size_t i = t->emitted_long_jumps; i < t->long_jump_count; ++i) {
        JbedThumbLongJump *entry = t->long_jumps[i];
        if (entry->label) {
            t->coder->truncate_label = entry->writer_fixup;
            entry->label = jbed_thumb_truncate_fixup(t, entry->label, boundary);
            entry->writer_fixup = t->coder->truncate_label;
        }
    }
    jbed_coder_flush_current_fixups(t->coder, boundary);
}

/* 0x142356 PrepareCall */
void jbed_thumb_prepare_call(JbedThumbCoder *t, int32_t return_type, bool receiver)
{
    JbedCoder *c = t->coder;
    for (int32_t i = 0; i < c->stack_depth; ++i)
        if (c->stack[i].location == JBED_LOCATION_REGISTER)
            jbed_thumb_make_perm(t, i);
    int32_t index = c->stack_depth + 4;
    int32_t spill = (t->stack_bytes >> 2) + t->stack_registers - 1;
    int32_t argument = 4;
    for (; index < c->input_depth; ++index, --spill, ++argument) {
        if (c->stack[index].location == JBED_LOCATION_REGISTER &&
            (spill >= c->input_depth || c->stack[spill].location != JBED_LOCATION_STACK)) {
            jbed_thumb_gen_instr(t, c->stack[index].value + THUMB_STR_SP, 0, 0, argument - 4);
            c->stack[index].location = 0;
        }
    }
    while (index > c->stack_depth + 4) {
        --index;
        ++spill;
        if (c->stack[index].location &&
            (spill != index || c->stack[spill].location != JBED_LOCATION_STACK)) {
            int32_t reg = jbed_thumb_load_reg(t, argument - 1);
            if (spill < index && c->stack[spill].location == JBED_LOCATION_STACK) {
                int32_t temp = jbed_thumb_temp_register(t, bit(reg));
                jbed_thumb_gen_instr(t, temp + THUMB_LDR_SP, 0, 0, argument - 5);
                jbed_thumb_gen_instr(t, temp + THUMB_STR_SP, 0, 0, spill - c->stack_depth - 4);
                c->stack[spill].location = 0;
            }
            jbed_thumb_gen_instr(t, reg + THUMB_STR_SP, 0, 0, argument - 5);
        }
        c->input_depth = index;
        --argument;
    }
    jbed_thumb_reg_assign(t, 0, c->stack_depth, c->input_depth - c->stack_depth);
    jbed_coder_insert_map(c, t->pc + 4, c->stack_depth);
    if (receiver && c->stack[c->stack_depth].type < 0)
        jbed_thumb_nil_test(t, 0, false);
    if (return_type) {
        jbed_thumb_set_register(t, c->stack_depth, 0);
        if ((return_type & 3) == 3)
            jbed_thumb_set_register(t, c->stack_depth + 1, 1);
    }
    if (c->native_call)
        jbed_thumb_jump_cc(t, 15, NULL, t->helpers.save_frame, 0, 0);
}

/* 0x1403d8 CallStatic */
uint32_t jbed_thumb_call_static(JbedThumbCoder *t, JbedMethod *method, uint32_t address,
                                int32_t return_type, bool receiver)
{
    jbed_coder_invalidate_regs_at_call_site(t->coder);
    uint32_t flags = t->coder->input_depth - t->coder->stack_depth >= 4 ? 0 : JBED_JUMP_CLOBBERS_R3;
    jbed_thumb_prepare_call(t, return_type, receiver);
    uint32_t result = jbed_thumb_jump_cc(t, 15, method, address, 0, flags);
    jbed_coder_report_return_address(t->coder, t->pc);
    return result;
}

/* 0x14043c CallVirtual */
void jbed_thumb_call_virtual(JbedThumbCoder *t, uint32_t interface_id, int32_t offset,
                             int32_t return_type)
{
    jbed_coder_invalidate_regs_at_call_site(t->coder);
    jbed_thumb_prepare_call(t, return_type, true);
    int32_t count = t->coder->input_depth - t->coder->stack_depth;
    int32_t saved = 0;
    if (count > 3) {
        saved = offset < 380 ? 8 : 12;
        jbed_thumb_gen_instr(t, THUMB_PUSH, 0, 0, saved);
    }
    if (interface_id) {
        jbed_thumb_load_const_val(t, 3, (int32_t)interface_id, 1);
        jbed_thumb_jump_cc(t, 15, NULL, t->helpers.interface_stub, 0, 0);
    } else
        jbed_thumb_gen_instr(t, THUMB_LDR_IMM, 0, 0, 3);
    if (offset < 380) {
        int32_t immediate = offset;
        if (offset >= 128) {
            immediate = 124;
            jbed_thumb_gen_con_add(t, 3, 3, offset - 124);
        }
        jbed_thumb_gen_instr(t, THUMB_LDR_IMM, immediate >> 2, 3, 3);
    } else {
        if (count == 3)
            jbed_thumb_gen_instr(t, THUMB_PUSH, 0, 0, 4);
        jbed_thumb_gen_con_load(t, 2, offset);
        jbed_thumb_gen_instr(t, THUMB_LDR_REG, 2, 3, 3);
        if (count == 3)
            jbed_thumb_gen_instr(t, THUMB_POP, 0, 0, 4);
    }
    if (count > 3) {
        jbed_thumb_check_boundaries(t, 6);
        jbed_thumb_gen_instr(t, THUMB_MOV_HIGH, 2, 3, 6);
        jbed_thumb_gen_instr(t, THUMB_POP, 0, 0, saved);
        jbed_thumb_gen_instr(t, THUMB_BRANCH_EXCHANGE, 2, 14, 0);
    } else
        jbed_thumb_gen_instr(t, THUMB_BRANCH_EXCHANGE, 2, 3, 0);
    jbed_coder_report_return_address(t->coder, t->pc);
}

/* 0x142e90 Trap */
void jbed_thumb_trap(JbedThumbCoder *t, int32_t condition, int32_t cache, uint32_t handler,
                     bool insert_map)
{
    JbedCoder *c = t->coder;
    jbed_thumb_check_boundaries(t, t->long_jump_cost + 8);
    jbed_thumb_allow_code_interruption(t, false);
    if (insert_map)
        jbed_coder_insert_map(c, t->pc + 4, 0);
    if (cache >= 0) {
        uint32_t previous = (uint32_t)t->trap_cache[cache];
        int32_t delta = displacement(previous, t->pc);
        if (previous >= c->allocation_start && delta >= -128 && delta <= 127 &&
            jbed_coder_same_map(c, (uint32_t)t->trap_cache[cache + 1],
                                (uint32_t)t->trap_cache[cache + 2])) {
            jbed_thumb_gen_instr(t, (condition ^ 1) + THUMB_BCOND, 0, 0, (uint8_t)delta);
            jbed_thumb_allow_code_interruption(t, true);
            return;
        }
        t->trap_cache[cache] = (int32_t)(t->pc + 2);
        t->trap_cache[cache + 1] = c->map_word_count;
        t->trap_cache[cache + 2] = (int32_t)c->map_words[0];
    }
    jbed_thumb_gen_instr(t, condition + THUMB_BCOND, 0, 0, 1);
    jbed_thumb_jump_cc(t, 15, NULL, handler, 0, 8);
    jbed_thumb_allow_code_interruption(t, true);
}

/* 0x141c48 NilTest */
void jbed_thumb_nil_test(JbedThumbCoder *t, int32_t reg, bool map)
{
    jbed_thumb_gen_instr(t, reg + THUMB_CMP_IMM, 0, 0, 0);
    jbed_thumb_trap(t, 1, 0, t->helpers.throw_null, map);
}

/* 0x1412be InsertCheckPoint */
void jbed_thumb_insert_checkpoint(JbedThumbCoder *t, int32_t reg)
{
    jbed_thumb_gen_instr(t, THUMB_MOV_HIGH, 0, 8, reg);
    jbed_thumb_gen_instr(t, reg + THUMB_SUB_IMM8, 0, 0, 1);
    jbed_thumb_gen_instr(t, THUMB_MOV_HIGH, 2, reg, 0);
    jbed_thumb_check_boundaries(t, t->long_jump_cost + 8);
    jbed_thumb_allow_code_interruption(t, false);
    jbed_thumb_gen_instr(t, THUMB_BCOND + 1, 0, 0, 1);
    jbed_thumb_jump_cc(t, 15, NULL, t->helpers.checkpoint, 0, 0);
    jbed_thumb_allow_code_interruption(t, true);
}

/* 0x142330 PrepareBackJump */
void jbed_thumb_prepare_back_jump(JbedThumbCoder *t)
{
    jbed_thumb_check_stack_map(t);
    int32_t temp = jbed_thumb_temp_register(t, 0);
    jbed_thumb_insert_checkpoint(t, temp);
}

/* 0x1405f4 CloseMethod */
void jbed_thumb_close_method(JbedThumbCoder *t)
{
    jbed_thumb_flush_const_val(t);
    jbed_thumb_flush_long_jumps(t);
    jbed_coder_flush_alloc(t->coder, t->pc);
}

/* 0x140704 EntryCode(maxStack, maxLocals, paramSlots, modifiers). */
uint32_t jbed_thumb_entry_code(JbedThumbCoder *t, int32_t max_stack, int32_t max_locals,
                               int32_t parameters, uint32_t modifiers)
{
    JbedCoder *c = t->coder;
    if (c->long_jumps)
        jbed_thumb_check_long_jump_consistency(t);
    t->trap_cache[0] = t->trap_cache[3] = 0;
    t->writer = c->writer;
    t->code_start = t->pc = jbed_coder_alloc_method_code_space(c, true, 128);
    t->code_limit = c->code_limit;
    if (c->long_jumps && t->xip_region != (t->code_start & ~(JBED_BLOCK_SIZE - 1))) {
        t->xip_region = t->code_start & ~(JBED_BLOCK_SIZE - 1);
        jbed_thumb_reset_long_jumps(t);
    }
    jbed_thumb_allow_code_interruption(t, false);
    t->short_fixups = 0;
    jbed_coder_clear_last_map(c);
    if (!t->fixup_bit) {
        uint32_t mask = UINT32_C(0x80000000);
        while (mask & (t->code_start | t->helpers.compiler_code))
            mask >>= 1;
        t->fixup_bit = mask;
    }
    t->method_flags = modifiers;
    t->constant_count = 0;
    t->literal_limit = t->code_limit;
    t->argument_count = parameters;
    t->argument_registers = t->monitor_registers = 0;
    t->stack_bytes = max_stack > 4 ? 4 * (max_stack - 4) : 0;
    for (int32_t i = min_i(max_locals, 32); i-- > 0;)
        t->local_locations[i] = -1;
    bool synchronized = (modifiers & JBED_ACC_SYNCHRONIZED) != 0;
    int32_t free_registers = synchronized ? 2 : 3;
    if (synchronized) {
        if (modifiers & JBED_METHOD_SLOT0_ALWAYS_THIS) {
            t->local_locations[0] = -4;
            t->argument_registers = 1;
        } else
            t->monitor_registers = 1;
    }
    t->local_registers = 0;
    for (uint32_t hints = c->method->local_hint; hints > 1 && free_registers > 0; hints >>= 5) {
        uint32_t index = hints & 31;
        if ((index >= (uint32_t)parameters || index < 4) && t->local_locations[index] == -1) {
            t->local_locations[index] = free_registers - 7;
            --free_registers;
            if (index >= (uint32_t)parameters)
                ++t->local_registers;
            else
                ++t->argument_registers;
        }
    }
    t->stack_registers = min_i(max_stack, free_registers);
    t->saved_registers =
        t->monitor_registers + t->argument_registers + t->local_registers + t->stack_registers;
    if (synchronized && c->return_type)
        t->saved_registers = max_i(t->saved_registers, (c->return_type & 3) == 3 ? 3 : 2);
    if ((modifiers & JBED_METHOD_NOT_LEAF) && c->return_type == JBED_TYPE_REFERENCE && !t->saved_registers)
        t->saved_registers = 1;
    if (t->saved_registers == 1)
        t->saved_registers = 2;
    t->stack_bytes = 4 * (max_stack - t->stack_registers);
    int32_t local_bytes = 4 * (max_locals - parameters - t->local_registers);
    t->argument_spill_bytes = max_i(4 * (min_i(parameters, 4) - t->argument_registers), 0);
    int32_t work_bytes = local_bytes + t->stack_bytes;
    if (work_bytes + t->argument_spill_bytes > 0)
        t->saved_registers = 3;
    t->saved_frame_bytes = 4 * t->saved_registers + 8;
    if (modifiers & JBED_METHOD_CLASS_INITIALIZER) {
        jbed_thumb_load_const_val(t, 0, (int32_t)jbed_coder_class_address(c, c->owner), 1);
        jbed_thumb_load_const_val(t, 1, (int32_t)t->helpers.initialize, 2);
        jbed_thumb_gen_instr(t, THUMB_MOV_HIGH, 2, 1, 7);
        jbed_thumb_flush_const_val(t);
        jbed_coder_set_init_adr(c, t->pc);
    }
    uint32_t push_mask =
        t->saved_registers > 0 ? (16 * (bit(t->saved_registers) - 1)) | 0x180 : 0x180;
    int32_t control = c->method->handlers != NULL ? 1 : 0;
    if (synchronized)
        control += 2;
    t->handler_word_size = 0;
    if (control) {
        t->saved_registers = 3;
        t->saved_frame_bytes = 24;
        int32_t reg;
        if (parameters >= 4) {
            jbed_thumb_gen_instr(t, THUMB_PUSH, 0, 0, (int32_t)(push_mask | 0x70));
            reg = 4;
            push_mask = 16;
        } else {
            push_mask |= 0x78;
            reg = 3;
        }
        if (control & 1) {
            t->control_word = control;
            jbed_thumb_load_const_val(t, reg, 0, 4);
        } else
            jbed_thumb_gen_con_load(t, reg, control);
        t->handler_word_size = 4;
    }
    int32_t saved_bytes = t->saved_frame_bytes + t->argument_spill_bytes;
    if ((saved_bytes + work_bytes) & 7)
        work_bytes += 4;
    t->frame_size = saved_bytes + work_bytes;
    int32_t offset = work_bytes;
    int32_t local = 0;
    for (; local < parameters && local < 4; ++local) {
        if (t->local_locations[local] == -1) {
            t->local_locations[local] = offset;
            offset += 4;
            push_mask |= bit(local);
        }
    }
    offset = t->frame_size;
    for (; local < parameters && local < 32; ++local, offset += 4)
        if (t->local_locations[local] == -1)
            t->local_locations[local] = offset;
    offset = t->stack_bytes;
    for (; local < max_locals && local < 32; ++local) {
        if (t->local_locations[local] == -1) {
            t->local_locations[local] = offset;
            offset += 4;
        }
    }
    int32_t padding = 0;
    int32_t allocation = work_bytes;
    if ((saved_bytes & 7) && work_bytes > 100) {
        if (push_mask & 1) {
            jbed_thumb_gen_instr(t, THUMB_PUSH, 0, 0, (int32_t)push_mask);
            jbed_thumb_gen_instr(t, THUMB_ADJUST_SP, 2, 0, 1);
        } else
            jbed_thumb_gen_instr(t, THUMB_PUSH, 0, 0, (int32_t)(push_mask | 1));
        allocation -= 4;
        padding = 4;
    } else
        jbed_thumb_gen_instr(t, THUMB_PUSH, 0, 0, (int32_t)push_mask);
    for (int32_t i = 0; i < parameters && i < 4; ++i)
        if (t->local_locations[i] < 0)
            jbed_thumb_gen_reg_move(t, -t->local_locations[i], i);
    if (synchronized) {
        if (modifiers & JBED_ACC_STATIC)
            jbed_thumb_load_const_val(t, 4, (int32_t)jbed_coder_class_address(c, c->owner), 1);
        else if (!(modifiers & JBED_METHOD_SLOT0_ALWAYS_THIS))
            jbed_thumb_gen_reg_move(t, 4, 0);
    }
    jbed_thumb_gen_instr(
        t, THUMB_ADDRESS_SP + 7, 0, 0,
        (t->saved_frame_bytes + t->argument_spill_bytes + t->handler_word_size + padding) >> 2);
    if (allocation + padding <= 100) {
        if (allocation > 0)
            jbed_thumb_gen_instr(t, THUMB_ADJUST_SP, 2, 0, allocation >> 2);
        jbed_thumb_gen_instr(t, THUMB_CMP_HIGH, 2, 13, 2);
        jbed_thumb_trap(t, 9, -1, t->helpers.throw_stack, true);
    } else {
        if (allocation < 256) {
            jbed_thumb_gen_instr(t, THUMB_MOV_HIGH, 0, 13, 0);
            jbed_thumb_gen_instr(t, THUMB_SUB_IMM8, 0, 0, allocation);
        } else {
            jbed_thumb_gen_con_load(t, 0, -allocation);
            jbed_thumb_gen_instr(t, THUMB_ADD_HIGH, 0, 13, 0);
        }
        jbed_thumb_gen_instr(t, THUMB_CMP_HIGH, 2, 0, 2);
        t->large_frame_size = allocation;
        jbed_thumb_trap(t, 9, -1, t->helpers.throw_large_stack, true);
        t->large_frame_size = 0;
        jbed_thumb_gen_instr(t, THUMB_MOV_HIGH, 2, 0, 5);
    }
    if (synchronized) {
        jbed_thumb_gen_reg_move(t, 0, 4);
        jbed_coder_insert_map(c, t->pc + 4, 0);
        jbed_thumb_jump_cc(t, 15, NULL, t->helpers.monitor_enter, 0, 8);
    }
    jbed_thumb_allow_code_interruption(t, true);
    return t->code_start;
}

/* 0x140dc4 ExitCode */
void jbed_thumb_exit_code(JbedThumbCoder *t, uint32_t modifiers)
{
    JbedCoder *c = t->coder;
    if (modifiers & JBED_ACC_SYNCHRONIZED) {
        jbed_thumb_gen_reg_move(t, 0, 4);
        jbed_coder_insert_map(c, t->pc + 4, -2);
        jbed_thumb_jump_cc(t, 15, NULL, t->helpers.monitor_exit, 0, 8);
        if (c->return_type) {
            jbed_thumb_gen_reg_move(t, 0, 5);
            if ((c->return_type & 3) == 3)
                jbed_thumb_gen_reg_move(t, 1, 6);
        }
    } else if (modifiers & JBED_METHOD_NOT_LEAF) {
        if (c->return_type == JBED_TYPE_REFERENCE)
            jbed_thumb_gen_reg_move(t, 4, 0);
        jbed_coder_insert_map(c, t->pc + 4, -1);
        jbed_thumb_insert_checkpoint(t, 3);
        if (c->return_type == JBED_TYPE_REFERENCE)
            jbed_thumb_gen_reg_move(t, 0, 4);
    }
    int32_t adjustment = t->frame_size - 20;
    uint32_t pop_mask = 128;
    if (t->frame_size == 24)
        pop_mask = 136;
    else if (adjustment < 512) {
        if (adjustment > 0)
            jbed_thumb_gen_instr(t, THUMB_ADJUST_SP, 0, 0, adjustment >> 2);
    } else {
        jbed_thumb_gen_con_add(t, 7, 7, -20 - t->handler_word_size);
        jbed_thumb_gen_instr(t, THUMB_MOV_HIGH, 2, 7, 5);
    }
    if (t->saved_registers > 0)
        pop_mask |= 16 * (bit(t->saved_registers) - 1);
    jbed_thumb_gen_instr(t, THUMB_POP_PC, 0, 0, (int32_t)pop_mask);
    jbed_thumb_close_method(t);
}

/* 0x13fea0 BaseOffset. Nonnegative result packs base + 8*scaled immediate;
 * negative result packs -(base + 8*offset-register). */
int32_t jbed_thumb_base_offset(JbedThumbCoder *t, int32_t mode, int32_t address, int32_t type,
                               bool load)
{
    JbedCoder *c = t->coder;
    int32_t width = type & 3;
    int32_t base, index_reg = -1, offset;
    bool signed_load = load && (type == JBED_TYPE_BYTE || type == JBED_TYPE_SHORT);
    if (mode == JBED_LOCATION_INDEX && address && !signed_load) {
        int32_t reg = (uint16_t)address;
        c->stack[c->stack_depth].location = JBED_LOCATION_REGISTER;
        c->stack[c->stack_depth].value = reg;
        return 8 * (address >> 16) + reg;
    }
    if (mode == JBED_LOCATION_INDEX) {
        base = jbed_thumb_load_reg(t, 0);
        int32_t bound = c->stack[c->stack_depth].type;
        if (bound < 0)
            jbed_thumb_nil_test(t, base, true);
        JbedCoderSlot index = c->stack[c->stack_depth + 1];
        int32_t constant = index.location == JBED_LOCATION_CONSTANT ? index.value : -1;
        if ((constant >> 8) && (constant < 0 || constant >= bound)) {
            int32_t value_reg = jbed_thumb_load_reg(t, 1);
            offset = 16;
            if (bound != INT32_MAX) {
                int32_t length_reg = jbed_thumb_temp_register(t, 0);
                jbed_thumb_gen_instr(t, THUMB_LDR_IMM, 3, base, length_reg);
                if (jbed_thumb_writable_reg(t, c->stack_depth)) {
                    jbed_thumb_gen_instr(t, base + THUMB_ADD_IMM8, 0, 0, 16);
                    jbed_coder_remove_array_registers(c, bit(base));
                    offset = 0;
                }
                jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_CMP, value_reg, length_reg);
                jbed_thumb_trap(t, 8, 3, t->helpers.throw_index, bound >= 0);
            }
            base = jbed_thumb_load_reg(t, 0);
            if (width) {
                index_reg = jbed_thumb_work_register(t, c->stack_depth + 1);
                jbed_thumb_gen_instr(t, THUMB_LSL_IMM, width, value_reg, index_reg);
            } else
                index_reg = value_reg;
        } else {
            offset = (int32_t)(((uint32_t)constant << width) + 16);
            if (constant >= bound) {
                int32_t length_reg = jbed_thumb_temp_register(t, 0);
                jbed_thumb_gen_instr(t, THUMB_LDR_IMM, 3, base, length_reg);
                jbed_thumb_gen_instr(t, length_reg + THUMB_CMP_IMM, 0, 0, constant);
                jbed_thumb_trap(t, 12, 3, t->helpers.throw_index, bound >= 0);
            }
        }
    } else if (mode == JBED_LOCATION_FIELD) {
        base = jbed_thumb_load_reg(t, 0);
        if (c->stack[c->stack_depth].type < 0)
            jbed_thumb_nil_test(t, base, true);
        offset = address;
    } else {
        base = jbed_thumb_work_register(t, c->input_depth++);
        int32_t high = width == 0   ? (int32_t)((uint32_t)address & ~15u)
                       : width == 1 ? (int32_t)((uint32_t)address & ~31u)
                       : width == 2 ? (int32_t)((uint32_t)address & ~63u)
                                    : address;
        if (mode == JBED_LOCATION_STATIC)
            jbed_thumb_load_const_val(t, base, high, 3);
        else {
            jbed_thumb_gen_con_load(t, base, high);
            jbed_thumb_gen_instr(t, THUMB_ADD_HIGH, 0, 9, base);
        }
        offset = address - high;
    }
    require(t, offset >= 0, "negative base offset");
    int32_t scaled = width == 0 ? offset : width == 1 ? offset >> 1 : offset >> 2;
    if (signed_load || (width < 3 && (scaled >= 31 || (index_reg != -1 && !offset)))) {
        int32_t reg;
        if (index_reg == -1) {
            int32_t slot = c->stack_depth + 1;
            if (!load && mode != JBED_LOCATION_INDEX) {
                slot = c->stack_depth + 2;
                c->input_depth = c->stack_depth + 3;
            }
            reg = jbed_thumb_work_register(t, slot);
            jbed_thumb_gen_con_load(t, reg, offset);
        } else if (offset) {
            if (jbed_thumb_writable_reg(t, c->stack_depth)) {
                jbed_thumb_gen_con_add(t, base, base, offset);
                jbed_coder_remove_array_registers(c, bit(base));
                reg = index_reg;
            } else {
                reg = jbed_thumb_work_register(t, c->stack_depth + 1);
                jbed_thumb_gen_con_add(t, reg, index_reg, offset);
            }
        } else
            reg = index_reg;
        return -(8 * reg + base);
    }
    int32_t combined = base, work = -1;
    if (index_reg != -1) {
        combined = work = jbed_thumb_work_register(t, c->stack_depth);
        jbed_thumb_gen_instr(t, THUMB_ADD_REG, index_reg, base, combined);
    }
    if (scaled >= 31 || (width == 3 && scaled > 0)) {
        if (work == -1)
            work = jbed_thumb_work_register(t, c->stack_depth);
        jbed_thumb_gen_con_add(t, work, combined, offset);
        combined = work;
        scaled = 0;
    }
    if (mode == JBED_LOCATION_INDEX && width != 3) {
        jbed_coder_set_array_register(c, combined, scaled);
        if (c->stack[c->stack_depth + 1].location == JBED_LOCATION_REGISTER)
            c->stack[c->stack_depth + 1].value = -1;
    }
    return 8 * scaled + combined;
}

/* 0x141730 Load */
void jbed_thumb_load(JbedThumbCoder *t, int32_t mode, int32_t address, int32_t type)
{
    JbedCoder *c = t->coder;
    int32_t operand = jbed_thumb_base_offset(t, mode, address, type, true);
    int32_t reg = jbed_thumb_result_register(t, c->stack_depth,
                                             operand >= 0 && mode == JBED_LOCATION_INDEX);
    if (operand < 0) {
        int32_t opcode = type == JBED_TYPE_BOOLEAN ? THUMB_LDRB_REG
                         : type == JBED_TYPE_CHAR ? THUMB_LDRH_REG
                         : type == JBED_TYPE_BYTE ? THUMB_LDRSB_REG
                         : type == JBED_TYPE_SHORT ? THUMB_LDRSH_REG : THUMB_LDR_REG;
        jbed_thumb_gen_instr(t, opcode, 0, -operand, reg);
    } else {
        if (type == JBED_TYPE_BOOLEAN)
            jbed_thumb_gen_instr(t, THUMB_LDRB_IMM, 0, operand, reg);
        else if (type == JBED_TYPE_CHAR)
            jbed_thumb_gen_instr(t, THUMB_LDRH_IMM, 0, operand, reg);
        else if ((type & 3) == 3) {
            int32_t high = jbed_thumb_result_register(t, c->stack_depth + 1, false);
            jbed_thumb_gen_instr(t, operand + THUMB_LDMIA, 0, 0, (int32_t)(bit(reg) | bit(high)));
            if (high < reg) {
                jbed_thumb_set_register(t, c->stack_depth, high);
                jbed_thumb_set_register(t, c->stack_depth + 1, reg);
            }
        } else
            jbed_thumb_gen_instr(t, THUMB_LDR_IMM, 0, operand, reg);
        if (mode == JBED_LOCATION_INDEX && (type & 3) != 3)
            jbed_coder_set_array_register(c, reg, -1);
    }
}

/* 0x142a0a Store */
void jbed_thumb_store(JbedThumbCoder *t, int32_t mode, int32_t address, int32_t type)
{
    JbedCoder *c = t->coder;
    int32_t index = c->input_depth - 1;
    JbedCoderSlot *value = &c->stack[index];
    int32_t location = value->location;
    if (location == JBED_LOCATION_CONSTANT && type == JBED_TYPE_BYTE)
        value->value = (uint8_t)value->value;
    int32_t offset = index - c->stack_depth;
    if (mode == JBED_LOCATION_LOCAL) {
        int32_t destination = jbed_thumb_register(t, JBED_LOCATION_LOCAL, address);
        if (destination >= 0)
            jbed_thumb_load_this_reg(t, location, value->value, destination);
        else {
            int32_t reg = jbed_thumb_load_reg(t, offset);
            jbed_thumb_stack_load_store(t, mode, address, reg, 0);
        }
        return;
    }
    int32_t operand = jbed_thumb_base_offset(t, mode, address, type, false);
    int32_t width = type & 3;
    int32_t reg = jbed_thumb_load_reg(t, offset);
    if (operand >= 0) {
        if (width == 0)
            jbed_thumb_gen_instr(t, THUMB_STRB_IMM, 0, operand, reg);
        else if (width == 1)
            jbed_thumb_gen_instr(t, THUMB_STRH_IMM, 0, operand, reg);
        else if (width == 2)
            jbed_thumb_gen_instr(t, THUMB_STR_IMM, 0, operand, reg);
        else {
            int32_t low = jbed_thumb_load_reg(t, offset - 1);
            if (low > reg) {
                jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_EOR, reg, low);
                jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_EOR, low, reg);
                jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_EOR, reg, low);
            }
            jbed_thumb_gen_instr(t, operand + THUMB_STMIA, 0, 0, (int32_t)(bit(low) | bit(reg)));
            if (low > reg) {
                jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_EOR, reg, low);
                jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_EOR, low, reg);
                jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_EOR, reg, low);
            }
        }
        if (mode == JBED_LOCATION_INDEX && width == 2)
            jbed_coder_set_array_register(c, reg, -1);
    } else {
        runtime_require(t, !address || mode != JBED_LOCATION_INDEX,
                        "cached array address used as register offset");
        jbed_thumb_gen_instr(t, width == 0 ? THUMB_STRB_REG : width == 1 ? THUMB_STRH_REG : THUMB_STR_REG, 0, -operand, reg);
    }
}

/* 0x14187c LoadLongConst: Java's argument order is explicitly high/low here. */
void jbed_thumb_load_long_const(JbedThumbCoder *t, int32_t low_type, int32_t high_type,
                                int32_t high_value, int32_t low_value)
{
    jbed_coder_load_const(t->coder, low_type, low_value);
    jbed_coder_load_const(t->coder, high_type, high_value);
}

/* 0x141d74 Op1 */
void jbed_thumb_op1(JbedThumbCoder *t, int32_t opcode)
{
    if (opcode == JBED_BC_L2I)
        return;
    int32_t source = jbed_thumb_load_reg(t, 0);
    if (opcode == JBED_BC_I2L) {
        int32_t high = jbed_thumb_work_register(t, t->coder->stack_depth + 1);
        jbed_thumb_gen_instr(t, THUMB_ASR_IMM, 31, source, high);
        return;
    }
    int32_t result = jbed_thumb_result_register(t, t->coder->stack_depth, false);
    if (opcode == JBED_BC_I2B) {
        jbed_thumb_gen_instr(t, THUMB_LSL_IMM, 24, source, result);
        jbed_thumb_gen_instr(t, THUMB_ASR_IMM, 24, result, result);
    } else if (opcode == JBED_BC_I2C || opcode == JBED_BC_I2S) {
        jbed_thumb_gen_instr(t, THUMB_LSL_IMM, 16, source, result);
        jbed_thumb_gen_instr(t, opcode == JBED_BC_I2C ? THUMB_LSR_IMM : THUMB_ASR_IMM, 16, result, result);
    } else
        jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_NEG, source, result);
}

/* Op2 uses the otherwise unused long-subtract opcode for reversed ISUB. */
enum { REVERSE_ISUB = JBED_BC_ISUB + 1 };

/* 0x141e28 Op2. */
void jbed_thumb_op2(JbedThumbCoder *t, int32_t opcode)
{
    JbedCoder *c = t->coder;
    if (c->stack[c->stack_depth].location == JBED_LOCATION_CONSTANT &&
        (opcode < JBED_BC_IDIV || opcode > JBED_BC_IUSHR)) {
        jbed_coder_stack_swap(c, 0, -1);
        if (opcode == JBED_BC_ISUB)
            opcode = REVERSE_ISUB;
    }
    int32_t left = jbed_thumb_load_reg(t, 0);
    int32_t value = c->stack[c->stack_depth + 1].value;
    bool immediate = c->stack[c->stack_depth + 1].location == JBED_LOCATION_CONSTANT;
    if (opcode >= JBED_BC_IDIV && opcode <= JBED_BC_IREM &&
        (((uint32_t)value & ((uint32_t)value - 1)) || value <= 1))
        immediate = false;
    int32_t right, result;
    if (immediate) {
        if (opcode == JBED_BC_IMUL) {
            if (!value) {
                jbed_coder_stack_swap(c, 0, -1);
                return;
            }
            if (!((uint32_t)value & ((uint32_t)value - 1))) {
                value = (int32_t)jbed_thumb_bit_num((uint32_t)value);
                opcode = JBED_BC_ISHL;
            }
        } else if (opcode == JBED_BC_ISUB) {
            value = neg_i(value);
            opcode = JBED_BC_IADD;
        }
        result = jbed_thumb_result_register(t, c->stack_depth, false);
        if (opcode == JBED_BC_IADD) {
            jbed_thumb_gen_con_add(t, result, left, value);
            return;
        }
        if (opcode == REVERSE_ISUB && (value == 0 || value == -1)) {
            jbed_thumb_gen_instr(t, THUMB_ALU, value ? THUMB_ALU_MVN : THUMB_ALU_NEG, left, result);
            return;
        }
        if (opcode == JBED_BC_IMUL && value >= 0 && !(((uint32_t)value - 1) & ((uint32_t)value - 2))) {
            int32_t work = result == left ? jbed_thumb_temp_register(t, bit(left)) : result;
            jbed_thumb_gen_instr(t, THUMB_LSL_IMM, (int32_t)jbed_thumb_bit_num((uint32_t)value - 1), left,
                                 work);
            jbed_thumb_gen_instr(t, THUMB_ADD_REG, left, work, result);
            return;
        }
        if (opcode == JBED_BC_IDIV || opcode == JBED_BC_IREM) {
            int32_t shift = (int32_t)jbed_thumb_bit_num((uint32_t)value);
            int32_t bias = jbed_thumb_temp_register(t, bit(left));
            if (shift <= 1)
                jbed_thumb_gen_instr(t, THUMB_LSR_IMM, 31, left, bias);
            else {
                jbed_thumb_gen_instr(t, THUMB_ASR_IMM, 31, left, bias);
                jbed_thumb_gen_instr(t, THUMB_LSR_IMM, 32 - shift, bias, bias);
            }
            jbed_thumb_gen_instr(t, THUMB_ADD_REG, bias, left, result);
            if (opcode == JBED_BC_IDIV)
                jbed_thumb_gen_instr(t, THUMB_ASR_IMM, shift, result, result);
            else {
                jbed_thumb_gen_instr(t, THUMB_LSL_IMM, 32 - shift, result, result);
                jbed_thumb_gen_instr(t, THUMB_LSR_IMM, 32 - shift, result, result);
                jbed_thumb_gen_instr(t, THUMB_SUB_REG, bias, result, result);
            }
            return;
        }
        if (opcode == JBED_BC_ISHL || opcode == JBED_BC_ISHR || opcode == JBED_BC_IUSHR) {
            int32_t shift = value & 31;
            if (!shift)
                jbed_thumb_set_register(t, c->stack_depth, left);
            else
                jbed_thumb_gen_instr(t,
                                     opcode == JBED_BC_ISHL ? THUMB_LSL_IMM
                                     : opcode == JBED_BC_ISHR ? THUMB_ASR_IMM
                                                              : THUMB_LSR_IMM,
                                     shift, left, result);
            return;
        }
        if (opcode == JBED_BC_IAND && value > 0 && !(((uint32_t)value + 1) & (uint32_t)value)) {
            int32_t shift = 32 - (int32_t)jbed_thumb_bit_num((uint32_t)value + 1);
            jbed_thumb_gen_instr(t, THUMB_LSL_IMM, shift, left, result);
            jbed_thumb_gen_instr(t, THUMB_LSR_IMM, shift, result, result);
            return;
        }
        if (opcode == JBED_BC_IAND && value < 0 && value >= -256) {
            int32_t temp = jbed_thumb_temp_register(t, bit(result));
            jbed_thumb_gen_reg_move(t, result, left);
            jbed_thumb_gen_con_load(t, temp, ~value);
            jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_BIC, temp, result);
            return;
        }
        if (opcode == JBED_BC_IXOR && value == -1) {
            jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_MVN, left, result);
            return;
        }
        if (result == left)
            right = jbed_thumb_load_reg(t, 1);
        else {
            jbed_thumb_gen_con_load(t, result, value);
            right = result;
        }
    } else {
        if (opcode == JBED_BC_IDIV || opcode == JBED_BC_IREM) {
            jbed_thumb_call_static(
                t, NULL,
                opcode == JBED_BC_IDIV ? t->helpers.integer_divide : t->helpers.integer_remainder,
                JBED_TYPE_INT, false);
            return;
        }
        right = jbed_thumb_load_reg(t, 1);
        if (opcode >= JBED_BC_ISHL && opcode <= JBED_BC_IUSHR) {
            int32_t shift = jbed_thumb_work_register(t, c->stack_depth + 1);
            jbed_thumb_gen_instr(t, THUMB_LSL_IMM, 27, right, shift);
            jbed_thumb_gen_instr(t, THUMB_LSR_IMM, 27, shift, shift);
            right = shift;
        }
        result = jbed_thumb_result_register(t, c->stack_depth, false);
    }
    int32_t source = right;
    if (opcode > REVERSE_ISUB) {
        source = left;
        if (right != result) {
            jbed_thumb_gen_reg_move(t, result, left);
            source = right;
        }
    }
    switch (opcode) {
    case JBED_BC_IADD:
        jbed_thumb_gen_instr(t, THUMB_ADD_REG, source, left, result);
        break;
    case JBED_BC_ISUB:
        jbed_thumb_gen_instr(t, THUMB_SUB_REG, source, left, result);
        break;
    case REVERSE_ISUB:
        jbed_thumb_gen_instr(t, THUMB_SUB_REG, left, source, result);
        break;
    case JBED_BC_IMUL:
        if (source == result) {
            int32_t temp = jbed_thumb_temp_register(t, bit(result));
            jbed_thumb_gen_reg_move(t, temp, result);
            source = temp;
        }
        jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_MUL, source, result);
        break;
    case JBED_BC_ISHL:
        jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_LSL, source, result);
        break;
    case JBED_BC_ISHR:
        jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_ASR, source, result);
        break;
    case JBED_BC_IUSHR:
        jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_LSR, source, result);
        break;
    case JBED_BC_IAND:
        jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_AND, source, result);
        break;
    case JBED_BC_IOR:
        jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_ORR, source, result);
        break;
    default:
        jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_EOR, source, result);
        break;
    }
}

/* 0x14061c Compare */
uint32_t jbed_thumb_compare(JbedThumbCoder *t, int32_t comparison, uint32_t label, int32_t distance)
{
    int32_t left = jbed_thumb_load_reg(t, 0);
    JbedCoderSlot right = t->coder->stack[t->coder->stack_depth + 1];
    int32_t value = right.location == JBED_LOCATION_CONSTANT ? right.value : 1000;
    if (!(value >> 8))
        jbed_thumb_gen_instr(t, left + THUMB_CMP_IMM, 0, 0, value);
    else if (!(neg_i(value) >> 8)) {
        int32_t temp = jbed_thumb_temp_register(t, 0);
        jbed_thumb_gen_con_add(t, temp, left, neg_i(value));
    } else {
        int32_t reg = jbed_thumb_load_reg(t, 1);
        jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_CMP, reg, left);
    }
    int32_t condition = comparison == 0   ? 0
                        : comparison == 1 ? 1
                        : comparison == 2 ? 11
                        : comparison == 3 ? 10
                        : comparison == 4 ? 12
                                          : 13;
    return jbed_thumb_jump_cc(t, condition, NULL, label, distance, 0);
}

/* 0x142c88 TableJump */
uint32_t jbed_thumb_table_jump(JbedThumbCoder *t, int32_t low, int32_t high, uint32_t default_label,
                               int32_t distance)
{
    int32_t index = jbed_thumb_load_reg(t, 0);
    if (low) {
        int32_t work = jbed_thumb_work_register(t, t->coder->stack_depth);
        jbed_thumb_gen_con_add(t, work, index, neg_i(low));
        index = work;
    }
    int32_t range = high - low;
    if (range < 256)
        jbed_thumb_gen_instr(t, index + THUMB_CMP_IMM, 0, 0, range);
    else {
        int32_t temp = jbed_thumb_temp_register(t, bit(index));
        jbed_thumb_gen_con_load(t, temp, range);
        jbed_thumb_gen_instr(t, THUMB_ALU, THUMB_ALU_CMP, temp, index);
    }
    int32_t estimate = distance - 3 * range;
    int32_t work = jbed_thumb_work_register(t, t->coder->stack_depth);
    t->table_remaining = range + 1;
    jbed_thumb_check_boundaries(t, (range + 1) * (t->long_jump_cost + 4) + 14 + t->long_jump_cost);
    jbed_thumb_allow_code_interruption(t, false);
    bool known = resolved(t, default_label);
    int32_t delta = known ? (int32_t)(default_label - t->pc - 12) >> 1 : 1;
    bool distant = (known && t->coder->allocation_split && default_label < t->code_start) ||
                   !jbed_thumb_before_limit(t, estimate, 8);
    int32_t encoding;
    uint32_t end;
    if (distant || delta < -1023 || estimate >= 249 - (int32_t)(t->constant_count >> 1)) {
        jbed_thumb_gen_instr(t, THUMB_BCOND + 8, 0, 0, 2);
        jbed_thumb_gen_instr(t, THUMB_LSL_IMM, 2, index, work);
        jbed_thumb_gen_instr(t, THUMB_ADD_IMM3, 2, work, work);
        end = t->pc + 6;
        encoding = 15;
    } else {
        jbed_thumb_gen_instr(t, THUMB_BCOND + 8, 0, 0, 1);
        jbed_thumb_gen_instr(t, THUMB_LSL_IMM, 2, index, work);
        end = t->pc + 4;
        encoding = 14;
    }
    jbed_thumb_gen_instr(t, THUMB_ADD_HIGH, 2, work, 7);
    uint32_t result =
        jbed_thumb_jump_cc(t, encoding, NULL, default_label, distance, (uint32_t)estimate << 5);
    halt_unless(t, t->pc == end, "unexpected table-jump instruction size");
    return result;
}

/* 0x142c28 TableEntry */
uint32_t jbed_thumb_table_entry(JbedThumbCoder *t, uint32_t label, int32_t distance)
{
    halt_unless(t, t->interruption_depth != 0, "table entry outside guarded table");
    uint32_t result = jbed_thumb_jump_cc(t, 15, NULL, label, distance, 0);
    if (!--t->table_remaining)
        jbed_thumb_allow_code_interruption(t, true);
    return result;
}

/* 0x143008 TreeJump */
uint32_t jbed_thumb_tree_jump(JbedThumbCoder *t, int32_t pivot, uint32_t label, int32_t distance,
                              int32_t unused, int32_t count)
{
    (void)unused;
    int32_t source = jbed_thumb_load_reg(t, 0);
    int32_t work = jbed_thumb_work_register(t, t->coder->stack_depth);
    jbed_thumb_gen_con_add(t, work, source, neg_i(pivot));
    if (count > 0)
        t->coder->destination_local =
            (int32_t)jbed_thumb_jump_cc(t, 12, NULL, 0, t->coder->destination_local,
                                        ((uint32_t)count * (uint32_t)t->tree_entry_cost << 5) + 16);
    int32_t position =
        jbed_coder_get_bc_pos(t->coder) - (4 * ((jbed_coder_get_bc_start(t->coder) + 4) >> 2) + 8);
    halt_unless(t, !(position & 7), "unaligned lookup-switch tree position");
    uint32_t estimate = (uint32_t)(distance - position + (position >> 3) * t->tree_entry_cost) << 5;
    return jbed_thumb_jump_cc(t, 0, NULL, label, distance, estimate);
}

/* 0x142962 SizeEstimate */
int32_t jbed_thumb_size_estimate(JbedThumbCoder *t)
{
    return 8 * (jbed_coder_remaining(t->coder) + jbed_coder_max_stack(t->coder)) + 64 +
           (int32_t)(12 * (t->long_jump_count - t->emitted_long_jumps));
}
