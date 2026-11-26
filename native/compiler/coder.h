#ifndef JBED_COMPILER_CODER_H
#define JBED_COMPILER_CODER_H

#include "model.h"
#include "runtime.h"
#include "signatures.h"
#include "writer.h"
#include "optlist.h"
#include "emitter.h"

typedef struct JbedThumbCoder JbedThumbCoder;
typedef struct JbedCoderServices JbedCoderServices;
typedef struct JbedPool JbedPool;

/* Reflection/code-ownership services supplied by the hosting VM. */
struct JbedCoderServices {
    void *context;
    JbedCodeOwner *(*method_code_owner)(void *, JbedMethod *);
    int32_t (*add_code_range)(void *, uint32_t start, uint32_t end);
    uint32_t (*class_object_address)(void *, JbedClass *);
    bool (*signature_types)(void *, JbedSignatureId, const JbedTypeId **arguments,
                            size_t *argument_count, JbedTypeId *return_type, JbedError *);
    void (*checkpoint)(void *);
    void (*report_stack_maps)(void *, uint32_t count, uint32_t long_words);
    JbedMethod *class_for_name_method, *class_new_instance_method;
};

/* Original runtime operations called by emitted Java code. arithmetic[opcode]
 * holds Long/Float/Double helpers for that JVM operation, not host functions. */
typedef struct JbedCoderRuntimeAddresses {
    uint32_t arithmetic[256];
    uint32_t new_object, new_array, new_array_n, array_store;
    uint32_t check_cast, instance_of, throw_exception, monitor_enter, monitor_exit;
    uint32_t class_for_name, checked_class_for_name;
    uint32_t class_new_instance, checked_class_new_instance;
} JbedCoderRuntimeAddresses;

typedef enum JbedLocation {
    JBED_LOCATION_INDEX = 1,
    JBED_LOCATION_FIELD = 2,
    JBED_LOCATION_STATIC = 3,
    JBED_LOCATION_RELATIVE_STATIC = 4,
    JBED_LOCATION_LOCAL = 5,
    JBED_LOCATION_CONSTANT = 6,
    JBED_LOCATION_POINTER = 7,
    JBED_LOCATION_STACK = 8,
    JBED_LOCATION_REGISTER = 9,
    JBED_LOCATION_LOCAL_OFFSET = 10
} JbedLocation;


typedef struct JbedCoderSlot {
    int32_t location;    /* stackMode[] */
    int32_t value;       /* stackValue[] */
    int32_t type;        /* stackInfo[]: negative type or proven bound */
    uint32_t expression; /* stackExp[]: local/field identity */
} JbedCoderSlot;

/* Coder instance fields 0x0c..0xc8. Host arrays have explicit capacities;
 * generated addresses and fixup-chain links remain 32-bit target values. */
typedef struct JbedCoder {
    JbedRuntime *runtime;
    const JbedCoderServices *services;
    JbedEmitter *emitter;
    JbedCoderRuntimeAddresses helpers;
    int32_t active_type;
    uint32_t total_code_length;
    JbedThumbCoder *thumb;
    JbedWriter *writer;
    JbedCoderSlot *stack;
    size_t stack_capacity;
    int32_t input_depth, stack_depth; /* topIdx0 +28, topIdx +32 */
    int32_t destination_local;        /* +36 */
    JbedMethod *method;               /* +40 */
    JbedClass *owner;                 /* +44 */
    uint32_t *labels, *label_ids;     /* +48,+52 */
    size_t label_capacity;
    int32_t label_count;      /* +56 */
    uint32_t current_fixups;  /* +60 */
    int32_t temp_label_count; /* +64; count of interleaved words */
    uint32_t *temp_labels;    /* +68: label-id/fixup pairs */
    size_t temp_label_capacity;
    uint32_t truncate_label;                /* +72 */
    bool long_jumps;                        /* +76 modeLongJumps */
    int32_t *handler_info, *handler_ranges; /* +80,+84 */
    size_t handler_info_capacity, handler_ranges_capacity;
    int32_t handler_range_position; /* +88 */
    uint32_t control_word_offset, control_word_ref, control_word_label;
    int32_t return_type; /* +104 */
    JbedPool *pool;      /* +108 */
    const uint8_t *code; /* +112 */
    size_t code_length;
    int32_t bc_pos, bc_start; /* +116,+120 */
    bool native_call;         /* +124 */
    uint32_t debug_mode;      /* +128 */
    bool allocation_open, allocation_limited, allocation_split;
    uint32_t allocation_start, code_limit;   /* +136,+140 */
    JbedOptList safe_pointers, safe_indices; /* +148,+152 */
    uint8_t *local_pointers;                 /* +156 */
    size_t local_pointer_capacity;
    uint32_t *map_words; /* +160; 31 pointer bits per word */
    size_t map_capacity;
    int32_t map_word_count; /* +164; -1 absent, 0 short encoding */
    int32_t *tree_constants, *tree_distances;
    int32_t default_distance, tree_size; /* +176,+180 */
    int32_t nonleaf_calls;               /* +184 */
    int32_t method_code_range_index, method_code_length;
    int32_t current_label_index; /* +196 */
    JbedSignatureArguments signature_args;
    bool current_label_is_temp;  /* +200 */
} JbedCoder;

void jbed_coder_push_word(JbedCoder *, int32_t type);
void jbed_coder_push(JbedCoder *, int32_t type);
void jbed_coder_pop_word(JbedCoder *);
void jbed_coder_pop(JbedCoder *, int32_t type);
void jbed_coder_stack_push(JbedCoder *, int32_t distance);
void jbed_coder_stack_swap(JbedCoder *, int32_t first, int32_t second);
uint32_t jbed_coder_get_array_index_registers(JbedCoder *, bool include_addresses);
void jbed_coder_set_array_register(JbedCoder *, int32_t reg, int32_t offset);
void jbed_coder_remove_array_registers(JbedCoder *, uint32_t mask);
void jbed_coder_remove_stack_expression(JbedCoder *, uint32_t value, uint32_t mask);
void jbed_coder_create_map(JbedCoder *, int32_t depth);
void jbed_coder_insert_map(JbedCoder *, uint32_t address, int32_t depth);
void jbed_coder_reinsert_last_map(JbedCoder *, uint32_t address);
void jbed_coder_clear_last_map(JbedCoder *);
bool jbed_coder_same_map(const JbedCoder *, uint32_t count, uint32_t bits);
uint32_t jbed_coder_alloc_method_code_space(JbedCoder *, bool first, uint32_t reserve);
void jbed_coder_flush_alloc(JbedCoder *, uint32_t end);
void jbed_coder_flush_current_fixups(JbedCoder *, uint32_t end);
void jbed_coder_report_return_address(JbedCoder *, uint32_t address);
void jbed_coder_set_init_adr(JbedCoder *, uint32_t address);
void jbed_coder_set_control_word_ref(JbedCoder *, uint32_t reference, uint32_t offset);
int32_t jbed_coder_remaining(JbedCoder *);
int32_t jbed_coder_max_stack(const JbedCoder *);
int32_t jbed_coder_get_original_bytecode_size(JbedCoder *, int32_t estimate);
int32_t jbed_coder_get_bc_pos(const JbedCoder *);
int32_t jbed_coder_get_bc_start(const JbedCoder *);
void jbed_coder_invalidate_regs_at_call_site(JbedCoder *);
void jbed_coder_load_const(JbedCoder *, int32_t type, int32_t value);
void jbed_coder_invalidate_externally_changeables(JbedCoder *, bool registers);
void jbed_coder_get_local_map(JbedCoder *, const JbedStackMaps *, uint32_t offset, size_t locals);
void jbed_coder_get_stack_map(JbedCoder *, const JbedStackMaps *, uint32_t offset);
uint32_t jbed_coder_get_label(JbedCoder *, unsigned index);
uint32_t jbed_coder_get_temp_label(JbedCoder *, uint32_t fixup);
void jbed_coder_set_temp_label(JbedCoder *, unsigned index, uint32_t value);
void jbed_coder_define_temp_label(JbedCoder *, unsigned index);
unsigned jbed_coder_label_index(const JbedCoder *, uint32_t bytecode_pc);
void jbed_coder_check_handlers(JbedCoder *);
void jbed_coder_split_handlers(JbedCoder *, uint32_t old_end, uint32_t new_start);
void jbed_coder_start_handler_range(JbedCoder *, unsigned handler_word_index, unsigned info_index,
                                    uint32_t start);
void jbed_coder_add_code_range(JbedCoder *, uint32_t start, uint32_t end);
JbedAddress jbed_coder_class_address(JbedCoder *, JbedClass *);
JbedCoderRuntimeAddresses jbed_coder_rom_helpers(uint32_t image_base);
void jbed_coder_init(JbedCoder *, JbedRuntime *, const JbedCoderServices *, JbedEmitter *,
                     JbedWriter *, const JbedCoderRuntimeAddresses *);
void jbed_coder_translate_method(JbedCoder *, JbedMethod *);
void jbed_coder_translate(JbedCoder *, JbedClass *);
void jbed_coder_generate(JbedCoder *);
void jbed_coder_flush_class_fixups(JbedCoder *, JbedClass *, uint32_t end);
_Noreturn void jbed_coder_limit_check_failed(JbedCoder *);
uint32_t jbed_coder_call_static_checked(JbedCoder *, JbedMethod *, uint32_t, int32_t result_type,
                                        bool null_check);

#endif
