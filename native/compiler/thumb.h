#ifndef JBED_COMPILER_THUMB_H
#define JBED_COMPILER_THUMB_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "runtime.h"

typedef struct JbedCoder JbedCoder;
typedef struct JbedWriter JbedWriter;

/* Addresses are addresses in the generated 32-bit VM image, never host pointers. */
typedef struct JbedThumbRuntimeAddresses {
    uint32_t compiler_code; /* target ROM address of FCoder.GenInstr */
    uint32_t throw_null, throw_index, throw_stack, throw_large_stack;
    uint32_t throw_abstract, throw_no_class, interface_stub, initialize;
    uint32_t monitor_enter, monitor_exit, checkpoint, save_frame;
    uint32_t integer_divide, integer_remainder;
} JbedThumbRuntimeAddresses;

typedef struct JbedThumbFixupInfo {
    int32_t kind;
    int32_t displacement;
} JbedThumbFixupInfo;

typedef struct JbedThumbConstant {
    int32_t value;
    uint32_t site;
    uint8_t kind;
} JbedThumbConstant;

enum {
    JBED_JUMP_ABSOLUTE = 1,
    JBED_JUMP_METHOD = 2,
    JBED_JUMP_LOCAL = 4,
    JBED_JUMP_CLOBBERS_R3 = 8,
    JBED_JUMP_LABEL_INDEX = 16,
    JBED_JUMP_TEMP_INDEX = 32
};

typedef struct JbedThumbLongJump {
    uint32_t target;
    uint32_t label;
    uint32_t writer_fixup;
    JbedMethod *method;
    uint32_t flags;
} JbedThumbLongJump;

/* FCoder adds static Java fields, not instance fields. This context replaces
 * those r9-relative statics so independent compilations do not share them. */
typedef struct JbedThumbCoder {
    JbedCoder *coder;   /* r9+1116 */
    JbedWriter *writer; /* r9+1140 */
    JbedRuntime *runtime;
    JbedThumbRuntimeAddresses helpers;
    JbedThumbConstant *constants; /* r9+1120,+1124,+1128 */
    size_t constant_count, constant_capacity;
    JbedThumbLongJump **long_jumps; /* r9+1136 */
    size_t long_jump_count, long_jump_capacity, emitted_long_jumps;
    int32_t local_locations[32];  /* r9+1144: negative = register */
    int32_t trap_cache[6];        /* r9+1148 */
    int32_t interruption_depth;   /* r9+2088 */
    int32_t control_word;         /* r9+2096 */
    int32_t large_frame_size;     /* r9+2100 */
    int32_t tree_entry_cost;      /* r9+2104 */
    uint32_t fixup_bit;           /* r9+2108 */
    uint32_t literal_limit;       /* r9+2112 */
    int32_t handler_word_size;    /* r9+2116 */
    uint32_t xip_region;          /* r9+2120 */
    uint32_t code_limit;          /* r9+2124 */
    int32_t long_jump_cost;       /* r9+2136 */
    int32_t stack_bytes;          /* r9+2140 */
    int32_t argument_spill_bytes; /* r9+2144 */
    int32_t saved_frame_bytes;    /* r9+2148 */
    int32_t frame_size;           /* r9+2152 */
    uint32_t method_flags;        /* r9+2156 */
    int32_t argument_count;       /* r9+2160 */
    uint32_t pc;                  /* r9+2164 */
    int32_t local_registers;      /* r9+2168 */
    int32_t argument_registers;   /* r9+2172 */
    int32_t stack_registers;      /* r9+2176 */
    int32_t monitor_registers;    /* r9+2180 */
    int32_t saved_registers;      /* r9+2184 */
    int32_t table_remaining;      /* r9+2188 */
    int32_t short_fixups;         /* r9+2192 */
    uint32_t code_start;          /* r9+2196 */
    uint32_t thumb_bit;           /* r9+2200 */
} JbedThumbCoder;

JbedThumbRuntimeAddresses jbed_thumb_rom_helpers(uint32_t image_base);
void jbed_thumb_init(JbedThumbCoder *, JbedCoder *, JbedRuntime *,
                     const JbedThumbRuntimeAddresses *, bool);
void jbed_thumb_destroy(JbedThumbCoder *);
void jbed_thumb_reset(JbedThumbCoder *);
uint32_t jbed_thumb_actual_pc(const JbedThumbCoder *);
uint32_t jbed_thumb_border(JbedThumbCoder *);
unsigned jbed_thumb_bit_num(uint32_t);
uint32_t jbed_thumb_call_instr(int32_t halfword_displacement);
void jbed_thumb_allow_code_interruption(JbedThumbCoder *, bool allow);
int32_t jbed_thumb_reserved_code_size(const JbedThumbCoder *, bool);
void jbed_thumb_check_boundaries(JbedThumbCoder *, int32_t);
void jbed_thumb_gen_hword(JbedThumbCoder *, uint16_t);
void jbed_thumb_gen_word(JbedThumbCoder *, uint32_t);
void jbed_thumb_gen_pointer(JbedThumbCoder *, uint32_t);
void jbed_thumb_gen_static(JbedThumbCoder *, uint32_t);
void jbed_thumb_gen_reloc(JbedThumbCoder *, uint32_t, bool);
void jbed_thumb_gen_call(JbedThumbCoder *, int32_t);
void jbed_thumb_gen_instr(JbedThumbCoder *, int32_t, int32_t, int32_t, int32_t);
void jbed_thumb_gen_instr_no_check(JbedThumbCoder *, int32_t, int32_t, int32_t, int32_t);
void jbed_thumb_gen_reg_move(JbedThumbCoder *, int32_t, int32_t);
void jbed_thumb_gen_con_load(JbedThumbCoder *, int32_t, int32_t);
void jbed_thumb_gen_con_add(JbedThumbCoder *, int32_t, int32_t, int32_t);
void jbed_thumb_load_const_val(JbedThumbCoder *, int32_t, int32_t, uint8_t);
void jbed_thumb_flush_const_val(JbedThumbCoder *);
void jbed_thumb_insert_const_val(JbedThumbCoder *);
JbedThumbFixupInfo jbed_thumb_read_fixup(JbedThumbCoder *, uint32_t);
void jbed_thumb_write_fixup(JbedThumbCoder *, uint32_t, int32_t, int32_t);
uint32_t jbed_thumb_gen_fixup(JbedThumbCoder *, int32_t, uint32_t);
void jbed_thumb_fixup(JbedThumbCoder *, uint32_t, uint32_t);
uint32_t jbed_thumb_set_label(JbedThumbCoder *, uint32_t, uint32_t);
uint32_t jbed_thumb_truncate_fixup(JbedThumbCoder *, uint32_t, uint32_t);
void jbed_thumb_flush_current_fixups(JbedThumbCoder *, uint32_t);
JbedThumbLongJump *jbed_thumb_add_long_jump(JbedThumbCoder *, JbedMethod *, uint32_t, uint32_t);
void jbed_thumb_reset_long_jumps(JbedThumbCoder *);
void jbed_thumb_flush_long_jumps(JbedThumbCoder *);
void jbed_thumb_check_long_jump_consistency(JbedThumbCoder *);
bool jbed_thumb_before_limit(JbedThumbCoder *, int32_t, int32_t);
uint32_t jbed_thumb_jump_cc(JbedThumbCoder *, int32_t, JbedMethod *, uint32_t, int32_t, uint32_t);
uint32_t jbed_thumb_jump(JbedThumbCoder *, uint32_t, int32_t);
uint32_t jbed_thumb_call_static(JbedThumbCoder *, JbedMethod *, uint32_t, int32_t, bool);
void jbed_thumb_call_virtual(JbedThumbCoder *, uint32_t, int32_t, int32_t);
void jbed_thumb_prepare_call(JbedThumbCoder *, int32_t, bool);
void jbed_thumb_trap(JbedThumbCoder *, int32_t, int32_t, uint32_t, bool);
void jbed_thumb_nil_test(JbedThumbCoder *, int32_t, bool);
void jbed_thumb_insert_checkpoint(JbedThumbCoder *, int32_t);
void jbed_thumb_prepare_back_jump(JbedThumbCoder *);
uint32_t jbed_thumb_entry_code(JbedThumbCoder *, int32_t, int32_t, int32_t, uint32_t);
void jbed_thumb_exit_code(JbedThumbCoder *, uint32_t);
void jbed_thumb_close_method(JbedThumbCoder *);
int32_t jbed_thumb_address(const JbedThumbCoder *, int32_t, int32_t);
int32_t jbed_thumb_register(const JbedThumbCoder *, int32_t, int32_t);
int32_t jbed_thumb_pointer_bit(const JbedThumbCoder *, int32_t, int32_t);
int32_t jbed_thumb_new_register(JbedThumbCoder *, int32_t, uint32_t, bool);
int32_t jbed_thumb_temp_register(JbedThumbCoder *, uint32_t);
int32_t jbed_thumb_work_register(JbedThumbCoder *, int32_t);
int32_t jbed_thumb_result_register(JbedThumbCoder *, int32_t, bool);
bool jbed_thumb_writable_reg(const JbedThumbCoder *, int32_t);
void jbed_thumb_set_register(JbedThumbCoder *, int32_t, int32_t);
int32_t jbed_thumb_load_reg(JbedThumbCoder *, int32_t);
void jbed_thumb_load_this_reg(JbedThumbCoder *, int32_t, int32_t, int32_t);
void jbed_thumb_make_perm(JbedThumbCoder *, int32_t);
void jbed_thumb_make_temp(JbedThumbCoder *, int32_t);
void jbed_thumb_reg_assign(JbedThumbCoder *, int32_t, int32_t, int32_t);
void jbed_thumb_normalize(JbedThumbCoder *, bool);
void jbed_thumb_prepare_stack_op(JbedThumbCoder *, int32_t);
void jbed_thumb_handler_entry(JbedThumbCoder *);
void jbed_thumb_return(JbedThumbCoder *);
void jbed_thumb_check_stack_map(JbedThumbCoder *);
void jbed_thumb_stack_load_store(JbedThumbCoder *, int32_t, int32_t, int32_t, int32_t);
int32_t jbed_thumb_base_offset(JbedThumbCoder *, int32_t, int32_t, int32_t, bool);
void jbed_thumb_load(JbedThumbCoder *, int32_t, int32_t, int32_t);
void jbed_thumb_store(JbedThumbCoder *, int32_t, int32_t, int32_t);
void jbed_thumb_load_long_const(JbedThumbCoder *, int32_t, int32_t, int32_t, int32_t);
void jbed_thumb_op1(JbedThumbCoder *, int32_t);
void jbed_thumb_op2(JbedThumbCoder *, int32_t);
uint32_t jbed_thumb_compare(JbedThumbCoder *, int32_t, uint32_t, int32_t);
uint32_t jbed_thumb_table_jump(JbedThumbCoder *, int32_t, int32_t, uint32_t, int32_t);
uint32_t jbed_thumb_table_entry(JbedThumbCoder *, uint32_t, int32_t);
uint32_t jbed_thumb_tree_jump(JbedThumbCoder *, int32_t, uint32_t, int32_t, int32_t, int32_t);
int32_t jbed_thumb_size_estimate(JbedThumbCoder *);
int32_t jbed_thumb_get_num_optimized_registers(void);
int32_t jbed_thumb_get_max_static_base_offset(void);
int32_t jbed_thumb_synchronizer_stackmap_bit(void);

#endif
