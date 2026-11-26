#include "coder.h"
#include "bytecode.h"
#include "class_access.h"
#include "vm_types.h"
#include "method_ranges.h"
#include "thumb.h"
#include "pool.h"
#include <string.h>

/* Coder.Byte/UByte/Short/UShort/Word/UVar, 0x169cd0, 0x16d500,
 * 0x16dc04..0x16dc7a. Bytecode verification precedes this cursor. */
static uint8_t read_u8(JbedCoder *c)
{
    return c->code[c->bc_pos++];
}
static int8_t read_i8(JbedCoder *c)
{
    return (int8_t)read_u8(c);
}
static uint16_t read_u16(JbedCoder *c)
{
    uint16_t high = read_u8(c);
    return (uint16_t)((high << 8) | read_u8(c));
}
static int16_t read_i16(JbedCoder *c)
{
    return (int16_t)read_u16(c);
}
static int32_t read_i32(JbedCoder *c)
{
    uint32_t high = read_u16(c);
    return (int32_t)((high << 16) | read_u16(c));
}
static unsigned read_local(JbedCoder *c, unsigned width)
{
    return width == 2 ? read_u16(c) : read_u8(c);
}

/* 0x16cea6 Push, 0x16cf08 PushWord, 0x16ce88 Pop, 0x16ce9e PopWord. */
void jbed_coder_push_word(JbedCoder *c, int32_t type)
{
    c->stack[c->stack_depth].type = -type;
    c->stack[c->stack_depth].expression = 0;
    ++c->stack_depth;
}
void jbed_coder_push(JbedCoder *c, int32_t type)
{
    switch (type) {
    case JBED_TYPE_REFERENCE:
    case JBED_TYPE_FLOAT:
        jbed_coder_push_word(c, type);
        break;
    case JBED_TYPE_LONG:
        jbed_coder_push_word(c, JBED_TYPE_LONG);
        jbed_coder_push_word(c, JBED_TYPE_LONG_HIGH);
        break;
    case JBED_TYPE_DOUBLE:
        jbed_coder_push_word(c, JBED_TYPE_DOUBLE);
        jbed_coder_push_word(c, JBED_TYPE_DOUBLE_HIGH);
        break;
    default:
        jbed_coder_push_word(c, JBED_TYPE_INT);
        break;
    }
}
void jbed_coder_pop_word(JbedCoder *c)
{
    --c->stack_depth;
}
void jbed_coder_pop(JbedCoder *c, int32_t type)
{
    c->stack_depth -= type == JBED_TYPE_LONG || type == JBED_TYPE_DOUBLE ? 2 : 1;
}
/* 0x16d59e StackPush; 0x16d65c StackSwap. Distances are from the current top. */
void jbed_coder_stack_push(JbedCoder *c, int32_t distance)
{
    c->stack[c->stack_depth] = c->stack[c->stack_depth - distance];
    ++c->stack_depth;
}
void jbed_coder_stack_swap(JbedCoder *c, int32_t first, int32_t second)
{
    JbedCoderSlot value = c->stack[c->stack_depth - first];
    c->stack[c->stack_depth - first] = c->stack[c->stack_depth - second];
    c->stack[c->stack_depth - second] = value;
}
/* 0x16cc46 LoadConst. A nonzero object constant is already known non-null. */
void jbed_coder_load_const(JbedCoder *c, int32_t type, int32_t value)
{
    JbedCoderSlot *slot = &c->stack[c->stack_depth];
    slot->value = value;
    slot->location =
        type == JBED_TYPE_REFERENCE && value ? JBED_LOCATION_POINTER : JBED_LOCATION_CONSTANT;
    jbed_coder_push_word(c, type);
    if (type == JBED_TYPE_REFERENCE && value)
        slot->type = 0;
}

/* 0x16c1f8, 0x16d4b0, 0x16d390, 0x16c6a2. */
uint32_t jbed_coder_get_array_index_registers(JbedCoder *c, bool addresses)
{
    return jbed_optlist_get_registers(&c->safe_indices, addresses);
}
void jbed_coder_set_array_register(JbedCoder *c, int32_t reg, int32_t offset)
{
    jbed_optlist_set_register(&c->safe_indices, reg, offset);
}
void jbed_coder_remove_array_registers(JbedCoder *c, uint32_t mask)
{
    jbed_optlist_remove_registers(&c->safe_indices, mask);
}
void jbed_coder_invalidate_regs_at_call_site(JbedCoder *c)
{
    jbed_coder_remove_array_registers(c, UINT32_MAX);
}
/* 0x16d3b4 RemoveStackExp; 0x16c61a InvalidateExternallyChangeables. */
void jbed_coder_remove_stack_expression(JbedCoder *c, uint32_t value, uint32_t mask)
{
    for (int32_t i = 0; i < c->stack_depth; ++i)
        if ((c->stack[i].expression & mask) == value)
            c->stack[i].expression = 0;
}
void jbed_coder_invalidate_externally_changeables(JbedCoder *c, bool registers)
{
    for (int32_t i = 0; i < c->stack_depth; ++i)
        if (c->stack[i].type >= -2)
            c->stack[i].expression = 0;
    jbed_optlist_remove_fields(&c->safe_pointers);
    jbed_optlist_remove_fields(&c->safe_indices);
    if (registers)
        jbed_coder_invalidate_regs_at_call_site(c);
}

static void map_bit(JbedCoder *c, int32_t bit, uint32_t *first, unsigned *last, bool *extended)
{
    if (bit < 31) {
        *first |= UINT32_C(1) << ((uint32_t)bit & 31);
        return;
    }
    if (!*extended) {
        memset(c->map_words, 0, c->map_capacity * sizeof(*c->map_words));
        *extended = true;
    }
    unsigned word = (unsigned)bit / 31;
    if (word > *last)
        *last = word;
    c->map_words[word] |= UINT32_C(1) << (bit % 31);
}

/* 0x16a2e4 CreateMap. Negative depth encodes a single return-value register.
 * Short maps contain at most ten bits; long maps use 31 bits per word. */
void jbed_coder_create_map(JbedCoder *c, int32_t depth)
{
    uint32_t first = 0;
    unsigned last = 0;
    bool extended = false;
    if (depth >= 0) {
        for (unsigned i = 0; i < c->method->max_locals; ++i)
            if (c->local_pointers[i])
                map_bit(c, jbed_thumb_pointer_bit(c->thumb, JBED_LOCATION_LOCAL, (int32_t)i),
                        &first, &last, &extended);
        for (int32_t i = 0; i < depth; ++i) {
            JbedCoderSlot *slot = &c->stack[i];
            if (slot->type >= -2 && slot->location > JBED_LOCATION_POINTER)
                map_bit(c, jbed_thumb_pointer_bit(c->thumb, slot->location, slot->value), &first,
                        &last, &extended);
        }
    } else if (c->return_type == JBED_TYPE_REFERENCE) {
        first = UINT32_C(1) << ((uint32_t)(-1 - depth) & 31);
    }
    if (c->method->flags & JBED_ACC_SYNCHRONIZED)
        first |= UINT32_C(1) << ((unsigned)jbed_thumb_synchronizer_stackmap_bit() & 31);
    c->map_words[0] = first;
    c->map_word_count = (int32_t)last;
    if (last || first >> 10)
        ++c->map_word_count;
}

/* 0x16a208, 0x16d470, 0x16c5f4, 0x16d2d4. */
void jbed_coder_clear_last_map(JbedCoder *c)
{
    c->map_word_count = -1;
}
bool jbed_coder_same_map(const JbedCoder *c, uint32_t count, uint32_t bits)
{
    return (uint32_t)c->map_word_count == count && count <= 1 && c->map_words[0] == bits;
}
void jbed_coder_reinsert_last_map(JbedCoder *c, uint32_t address)
{
    if (c->map_word_count < 0)
        return;
    if (c->map_word_count)
        jbed_writer_add_long_map(c->writer, address, c->map_words, (uint32_t)c->map_word_count);
    else
        jbed_writer_add_short_map(c->writer, address, c->map_words[0]);
}
void jbed_coder_insert_map(JbedCoder *c, uint32_t address, int32_t depth)
{
    jbed_coder_create_map(c, depth);
    jbed_coder_reinsert_last_map(c, address);
}

/* 0x16dcf0 getLocalMap and 0x16ddf2 getStackMap expand verification types
 * into machine words. A long/double occupies two nonpointer words. */
void jbed_coder_get_local_map(JbedCoder *c, const JbedStackMaps *maps, uint32_t offset,
                              size_t locals)
{
    size_t word = 0;
    if (offset) {
        unsigned count = maps->words[offset++];
        for (unsigned i = 0; i < count; ++i) {
            unsigned type = maps->words[offset++];
            c->local_pointers[word++] = type >= 6;
            if (type == 3 || type == 4)
                c->local_pointers[word++] = 0;
        }
    }
    while (word < locals)
        c->local_pointers[word++] = 0;
}
void jbed_coder_get_stack_map(JbedCoder *c, const JbedStackMaps *maps, uint32_t offset)
{
    c->stack_depth = 0;
    if (!offset)
        return;
    unsigned count = maps->words[offset++];
    for (unsigned i = 0; i < count; ++i) {
        unsigned token = maps->words[offset++];
        int32_t type = token == 1   ? JBED_TYPE_INT
                       : token == 2 ? JBED_TYPE_FLOAT
                       : token == 3 ? JBED_TYPE_DOUBLE
                       : token == 4 ? JBED_TYPE_LONG
                                    : JBED_TYPE_REFERENCE;
        jbed_coder_push(c, type);
    }
}

/* 0x16c488 GetLabel; 0x16cbe6 LabelIdx returns the lower-bound PC index. */
uint32_t jbed_coder_get_label(JbedCoder *c, unsigned index)
{
    c->current_label_index = (int32_t)index;
    c->current_label_is_temp = false;
    return c->labels[index];
}
unsigned jbed_coder_label_index(const JbedCoder *c, uint32_t pc)
{
    const uint16_t *words = c->method->stack_maps.words;
    unsigned low = 0, high = words[0] - 1;
    do {
        unsigned middle = (low + high) >> 1;
        if (pc <= words[middle + 1])
            high = middle;
        else
            low = middle + 1;
    } while (low < high);
    return low;
}

/* 0x16decc getTempLabel, 0x16df58 setTempLabel, 0x16dc7a defineTempLabel. */
uint32_t jbed_coder_get_temp_label(JbedCoder *c, uint32_t fixup)
{
    if ((size_t)c->temp_label_count >= c->temp_label_capacity) {
        size_t capacity = c->temp_label_capacity ? c->temp_label_capacity * 2 : 32;
        uint32_t *next = jbed_alloc(c->runtime, capacity * sizeof(*next));
        if (c->temp_label_count)
            memcpy(next, c->temp_labels, (size_t)c->temp_label_count * sizeof(*next));
        c->temp_labels = next;
        c->temp_label_capacity = capacity;
    }
    uint32_t index = (uint32_t)c->temp_label_count;
    c->temp_labels[index] = 0;
    c->temp_labels[index + 1] = fixup;
    c->temp_label_count += 2;
    return index + 1;
}
void jbed_coder_set_temp_label(JbedCoder *c, unsigned index, uint32_t value)
{
    c->temp_labels[index] = value;
}
void jbed_coder_define_temp_label(JbedCoder *c, unsigned index)
{
    if (!c->long_jumps) {
        if (index != (uint32_t)c->temp_label_count - 1)
            jbed_halt(c->runtime, 0, "TempLabels not defined in reverse order.");
        c->temp_label_count -= 2;
    }
    c->temp_labels[index] =
        jbed_thumb_set_label(c->thumb, c->temp_labels[index], c->temp_labels[index - 1]);
}

/* 0x16d754 StartHandlerRange, 0x169e78 CheckHandlers, 0x16d520 SplitHandlers.
 * Each range is [source handler word index, native start, native end]. */
void jbed_coder_start_handler_range(JbedCoder *c, unsigned handler, unsigned info, uint32_t start)
{
    size_t used = (size_t)c->handler_range_position;
    if (used == c->handler_ranges_capacity) {
        size_t capacity = used * 2;
        int32_t *next = jbed_alloc(c->runtime, capacity * sizeof(*next));
        memcpy(next, c->handler_ranges, used * sizeof(*next));
        c->handler_ranges = next;
        c->handler_ranges_capacity = capacity;
    }
    c->handler_ranges[used] = (int32_t)handler;
    c->handler_ranges[used + 1] = (int32_t)start;
    c->handler_info[info] = (int32_t)used + 2;
    c->handler_range_position += 3;
}
void jbed_coder_check_handlers(JbedCoder *c)
{
    for (size_t i = 0; i < c->method->handler_count; ++i) {
        JbedExceptionHandler *handler = &c->method->handlers[i];
        if (handler->start_pc == (uint32_t)c->bc_pos)
            jbed_coder_start_handler_range(c, (unsigned)i * 4, (unsigned)i * 2,
                                           jbed_thumb_border(c->thumb));
        if (handler->end_pc == (uint32_t)c->bc_pos) {
            c->handler_ranges[c->handler_info[2 * i]] = (int32_t)jbed_thumb_border(c->thumb);
            c->handler_info[2 * i] = 0;
        }
        if (handler->handler_pc == (uint32_t)c->bc_pos) {
            c->handler_info[2 * i + 1] = (int32_t)jbed_thumb_actual_pc(c->thumb);
            jbed_thumb_handler_entry(c->thumb);
        }
    }
}
void jbed_coder_split_handlers(JbedCoder *c, uint32_t old_end, uint32_t new_start)
{
    if (!c->handler_range_position)
        return;
    for (size_t i = 0; i < c->handler_info_capacity; i += 2) {
        unsigned index = (unsigned)c->handler_info[i];
        if (!index)
            continue;
        c->handler_ranges[index] = (int32_t)(old_end - 1);
        jbed_coder_start_handler_range(c, (unsigned)c->handler_ranges[index - 2], (unsigned)i,
                                       new_start);
    }
}

/* 0x169be6 AddCodeRange; 0x169c1e AllocMethodCodeSpace; 0x16a8e8 FlushAlloc. */
void jbed_coder_add_code_range(JbedCoder *c, uint32_t start, uint32_t end)
{
    int32_t index = c->services && c->services->add_code_range
                        ? c->services->add_code_range(c->services->context, start, end)
                        : jbed_method_add_range(c->runtime, start, end);
    if (c->method_code_range_index == -1)
        c->method_code_range_index = index;
    c->method_code_length = (int32_t)((uint32_t)c->method_code_length + end - start);
}
static JbedCodeOwner *method_code_owner(const JbedCoder *c)
{
    return c->services->method_code_owner
               ? c->services->method_code_owner(c->services->context, c->method)
               : (JbedCodeOwner *)c->method;
}

uint32_t jbed_coder_alloc_method_code_space(JbedCoder *c, bool first, uint32_t reserve)
{
    if (!first && (c->debug_mode & 4))
        jbed_coder_add_code_range(c, c->allocation_start, jbed_thumb_actual_pc(c->thumb) - 1);
    uint32_t estimate = (uint32_t)jbed_thumb_size_estimate(c->thumb);
    uint32_t start = jbed_writer_allocate_code(c->writer, method_code_owner(c), estimate, reserve);
    c->allocation_open = true;
    uint32_t limit = jbed_writer_allocation_limit(c->writer);
    if (!limit)
        limit = start + estimate;
    c->allocation_limited = (int32_t)limit < (int32_t)(start + estimate);
    c->code_limit = limit;
    c->allocation_start = start;
    if (!first)
        jbed_coder_split_handlers(c, jbed_thumb_actual_pc(c->thumb), start);
    c->allocation_split = !first;
    return start;
}
void jbed_coder_flush_alloc(JbedCoder *c, uint32_t end)
{
    jbed_writer_flush_code(c->writer, method_code_owner(c), end);
    c->allocation_open = false;
}

/* 0x16a964 FlushCurrentFixups. Each chain carries a writer label for chunks
 * already flushed, retained separately from its still-writable chain head. */
void jbed_coder_flush_current_fixups(JbedCoder *c, uint32_t end)
{
    if (c->current_fixups) {
        c->truncate_label = c->method->label;
        c->current_fixups = jbed_thumb_truncate_fixup(c->thumb, c->current_fixups, end);
        c->method->label = c->truncate_label;
    }
    if (c->control_word_ref) {
        c->control_word_label = jbed_writer_write_label(c->writer, c->control_word_ref, 0);
        c->control_word_ref = 0;
    }
    for (int32_t i = 0; i < c->label_count; ++i) {
        if (!c->labels[i])
            continue;
        c->truncate_label = c->label_ids[i];
        c->labels[i] = jbed_thumb_truncate_fixup(c->thumb, c->labels[i], end);
        c->label_ids[i] = c->truncate_label;
    }
    for (int32_t i = 1; i < c->temp_label_count; i += 2) {
        if (!c->temp_labels[i])
            continue;
        c->truncate_label = c->temp_labels[i - 1];
        c->temp_labels[i] = jbed_thumb_truncate_fixup(c->thumb, c->temp_labels[i], end);
        c->temp_labels[i - 1] = c->truncate_label;
    }
}

/* 0x16d3f8 is intentionally empty in the original. */
void jbed_coder_report_return_address(JbedCoder *c, uint32_t address)
{
    (void)c;
    (void)address;
}
/* 0x16d4e0, 0x16d4da, 0x16d350, 0x16cd78, 0x16c572, 0x16dce8/0x16dcec. */
void jbed_coder_set_init_adr(JbedCoder *c, uint32_t address)
{
    c->method->owner->initializer_address = address;
}
void jbed_coder_set_control_word_ref(JbedCoder *c, uint32_t reference, uint32_t offset)
{
    c->control_word_ref = reference;
    c->control_word_offset = offset;
}
int32_t jbed_coder_remaining(JbedCoder *c)
{
    int32_t remaining = (int32_t)c->code_length - c->bc_pos;
    if (c->method->flags & JBED_METHOD_CLASS_INITIALIZER)
        remaining -= 8 * c->method->dispatch_slot;
    return remaining;
}
int32_t jbed_coder_max_stack(const JbedCoder *c)
{
    return c->method->max_stack;
}
int32_t jbed_coder_get_original_bytecode_size(JbedCoder *c, int32_t estimate)
{
    (void)c;
    return estimate;
}
int32_t jbed_coder_get_bc_pos(const JbedCoder *c)
{
    return c->bc_pos;
}
int32_t jbed_coder_get_bc_start(const JbedCoder *c)
{
    return c->bc_start;
}

/* 0x16a0c0 CheckLocal, 0x169de0 CheckDest. */
static void check_local(JbedCoder *c, int32_t local)
{
    for (int32_t i = 0; i < c->stack_depth; ++i) {
        JbedCoderSlot *s = &c->stack[i];
        if ((s->location == JBED_LOCATION_LOCAL && s->value == local) ||
            (s->location == JBED_LOCATION_LOCAL_OFFSET && (int32_t)(uint16_t)s->value - 1 == local))
            jbed_thumb_make_temp(c->thumb, i);
    }
}
static void check_destination(JbedCoder *c)
{
    int32_t saved = c->bc_pos;
    unsigned opcode = read_u8(c);
    if (opcode >= JBED_BC_ISTORE && opcode <= JBED_BC_ASTORE_3) {
        int32_t local = opcode < JBED_BC_ISTORE_0 ? read_u8(c) : (opcode - JBED_BC_ISTORE_0) & 3;
        check_local(c, local);
        c->destination_local = local;
    } else if (opcode >= JBED_BC_IRETURN && opcode <= JBED_BC_ARETURN)
        c->destination_local = -2;
    c->bc_pos = saved;
}
/* 0x16c4b6 GetLocal, 0x16d1d4 PutLocal. */
static void get_local(JbedCoder *c, int32_t type, int32_t local)
{
    JbedCoderSlot *s = &c->stack[c->stack_depth];
    s->location = JBED_LOCATION_LOCAL;
    s->value = local;
    jbed_coder_push_word(c, type);
    s->expression = (uint32_t)local + 1;
    if ((local == 0 && (c->method->flags & JBED_METHOD_SLOT0_ALWAYS_THIS)) ||
        jbed_optlist_search_pointer(&c->safe_pointers, s->expression))
        s->type = 0;
}
static void put_local(JbedCoder *c, int32_t type, int32_t local)
{
    c->input_depth = c->stack_depth;
    jbed_coder_pop_word(c);
    check_local(c, local);
    c->local_pointers[local] = type == JBED_TYPE_REFERENCE;
    jbed_thumb_store(c->thumb, JBED_LOCATION_LOCAL, local,
                     type == JBED_TYPE_REFERENCE ? type : JBED_TYPE_INT);
    uint32_t expression = (uint32_t)local + 1;
    jbed_coder_remove_stack_expression(c, expression, 0xffff);
    if (type == JBED_TYPE_REFERENCE) {
        jbed_optlist_remove(&c->safe_pointers, 0, expression, 0xffff);
        jbed_optlist_remove(&c->safe_indices, 0, expression, 0xffff);
        if (c->stack[c->stack_depth].type >= 0)
            jbed_optlist_add_pointer(&c->safe_pointers, expression);
    } else
        jbed_optlist_remove(&c->safe_indices, 1, expression, 0xffff);
}
/* 0x16a14e CheckPointer, 0x169f9c CheckIndex. */
static uint32_t check_pointer(JbedCoder *c)
{
    JbedCoderSlot *s = &c->stack[c->stack_depth];
    uint32_t expression =
        s->location == JBED_LOCATION_LOCAL ? (uint32_t)s->value + 1 : s->expression;
    if (expression) {
        if (jbed_optlist_search_pointer(&c->safe_pointers, expression)) {
            if (s->type < 0)
                s->type = 0;
        } else
            jbed_optlist_add_pointer(&c->safe_pointers, expression);
    }
    return expression;
}
static void check_index(JbedCoder *c, bool write)
{
    jbed_optlist_reset_lookup(&c->safe_indices);
    uint32_t array = check_pointer(c), index = 0;
    if (array) {
        JbedCoderSlot *s = &c->stack[c->stack_depth + 1];
        if (s->location == JBED_LOCATION_LOCAL)
            index = (uint32_t)s->value + 1;
        else if (s->location == JBED_LOCATION_CONSTANT && (int16_t)s->value == s->value)
            index = ((uint32_t)s->value + 1) << 16;
        else
            index = s->expression;
        if (index) {
            if (jbed_optlist_search(&c->safe_indices, array, index))
                c->stack[c->stack_depth].type = INT32_MAX;
            else
                jbed_optlist_add(&c->safe_indices, array, index);
        }
    } else
        c->safe_indices.found_index = -1;
    if (write)
        jbed_optlist_remove_array_write(&c->safe_indices, array, index);
}
/* 0x169ce6 CallStaticChecked. A zero/sentinel runtime entry is an original
 * compiler halt, rather than an emitted call to unmapped memory. */
uint32_t jbed_coder_call_static_checked(JbedCoder *c, JbedMethod *method, uint32_t address,
                                        int32_t type, bool null_check)
{
    if ((!method || !(method->owner->flags & JBED_CLASS_DYNAMIC)) &&
        (address <= 4 || address >= UINT32_MAX - 3 || address == UINT32_C(0x80000000)))
        jbed_halt(c->runtime, 0, "CallStatic to ROM method with 0 address");
    return jbed_thumb_call_static(c->thumb, method, address, type, null_check);
}
/* 0x16c114 GetArray, 0x16cf52 PutArray. */
static void get_array(JbedCoder *c, int32_t type)
{
    c->stack_depth -= 2;
    check_destination(c);
    uint32_t address = 0;
    bool cached = false;
    if ((type & 3) != 3) {
        check_index(c, false);
        address = c->safe_indices.found_address;
        if ((int32_t)address < 0) {
            JbedError error = {.kind = JBED_ERROR_RUNTIME_EXCEPTION};
            jbed_raise(c->runtime, &error);
        }
        if (c->safe_indices.found_register >= 0) {
            c->stack[c->stack_depth].location = JBED_LOCATION_REGISTER;
            c->stack[c->stack_depth].value = c->safe_indices.found_register;
            cached = true;
        }
    }
    if (!cached) {
        c->safe_indices.registers_enabled = true;
        jbed_thumb_load(c->thumb, JBED_LOCATION_INDEX, (int32_t)address, type);
        c->safe_indices.registers_enabled = false;
    }
    jbed_coder_push(c, type);
}
static void put_array(JbedCoder *c, int32_t type)
{
    jbed_coder_pop(c, type);
    c->stack_depth -= 2;
    check_index(c, true);
    if (type == JBED_TYPE_REFERENCE)
        jbed_coder_call_static_checked(c, NULL, c->helpers.array_store, 0, false);
    else {
        c->safe_indices.registers_enabled = true;
        jbed_thumb_store(c->thumb, JBED_LOCATION_INDEX, (int32_t)c->safe_indices.found_address,
                         type);
        c->safe_indices.registers_enabled = false;
    }
}

static void checked(JbedCoder *c, bool success, const JbedError *error)
{
    if (!success)
        jbed_raise(c->runtime, error);
}
/* 0x16c2ec GetField, 0x16cfd4 PutField. Object identity combines a local
 * in the low halfword with the constant-pool field index in the high half. */
static int32_t field_receiver(JbedCoder *c)
{
    JbedCoderSlot *s = &c->stack[c->stack_depth];
    if (s->location == JBED_LOCATION_LOCAL)
        return s->value + 1;
    return s->expression && (int16_t)s->expression == (int32_t)s->expression
               ? (int32_t)s->expression
               : -1;
}
static void get_field(JbedCoder *c, JbedLocation mode, JbedField *field, unsigned index)
{
    int32_t type = (int32_t)jbed_pool_primitive_type(field->type_id);
    if (field->flags & JBED_FIELD_CONSTANT) {
        if (type == JBED_TYPE_LONG || type == JBED_TYPE_DOUBLE) {
            int32_t high_type = type == JBED_TYPE_LONG ? JBED_TYPE_LONG_HIGH : JBED_TYPE_DOUBLE_HIGH;
            jbed_thumb_load_long_const(c->thumb, type, high_type,
                                       (int32_t)(field->constant_value >> 32),
                                       (int32_t)field->constant_value);
        } else
            jbed_coder_load_const(c, (type & 3) >= 2 ? type : JBED_TYPE_INT,
                                  (int32_t)field->constant_value);
        return;
    }
    int32_t expression = 0;
    if (mode == JBED_LOCATION_FIELD) {
        jbed_coder_pop(c, JBED_TYPE_REFERENCE);
        expression = field_receiver(c);
        check_pointer(c);
    }
    check_destination(c);
    if (field->flags & JBED_FIELD_RELATIVE_STATIC)
        mode = JBED_LOCATION_RELATIVE_STATIC;
    jbed_thumb_load(c->thumb, mode, (int32_t)field->offset, type);
    jbed_coder_push(c, type);
    if (expression >= 0 && index && type == JBED_TYPE_REFERENCE) {
        JbedCoderSlot *s = &c->stack[c->stack_depth - 1];
        s->expression = (uint32_t)expression + (index << 16);
        if (jbed_optlist_search_pointer(&c->safe_pointers, s->expression))
            s->type = 0;
    }
}
static void put_field(JbedCoder *c, JbedLocation mode, JbedField *field, unsigned index)
{
    if ((field->flags & JBED_ACC_FINAL) && field->owner != c->method->owner)
        jbed_emitter_incompatible_class(c->emitter, field->owner->id);
    int32_t type = (int32_t)jbed_pool_primitive_type(field->type_id);
    jbed_coder_pop(c, type);
    int32_t expression = 0, stored_info;
    if (mode == JBED_LOCATION_FIELD) {
        jbed_coder_pop(c, JBED_TYPE_REFERENCE);
        expression = field_receiver(c);
        check_pointer(c);
        stored_info = c->stack[c->stack_depth + 1].type;
    } else
        stored_info = c->stack[c->stack_depth].type;
    if (field->flags & JBED_FIELD_CONSTANT) {
        JbedCoderSlot *s = &c->stack[c->input_depth - 1];
        if (s->location == JBED_LOCATION_CONSTANT) {
            if (type == JBED_TYPE_LONG || type == JBED_TYPE_DOUBLE)
                field->constant_value =
                    ((uint64_t)(uint32_t)s->value << 32) | (uint32_t)field->constant_value;
            else
                field->constant_value =
                    (field->constant_value & UINT64_C(0xffffffff00000000)) | (uint32_t)s->value;
        }
    } else {
        if (field->flags & JBED_FIELD_RELATIVE_STATIC)
            mode = JBED_LOCATION_RELATIVE_STATIC;
        jbed_thumb_store(c->thumb, mode, (int32_t)field->offset, type);
    }
    if (index && type == JBED_TYPE_REFERENCE) {
        uint32_t field_bits = index << 16;
        jbed_coder_remove_stack_expression(c, field_bits, 0xffff0000);
        jbed_optlist_remove(&c->safe_indices, 0, field_bits, 0xffff0000);
        if (stored_info >= 0 && expression >= 0)
            jbed_optlist_add_pointer(&c->safe_pointers, (uint32_t)expression + field_bits);
        else if (stored_info < 0)
            jbed_optlist_remove(&c->safe_pointers, 0, field_bits, 0xffff0000);
    }
}
/* 0x16c592 InitializeStatics. */
static void initialize_statics(JbedCoder *c, JbedClass *owner)
{
    for (JbedField *field = owner->fields; field; field = field->next) {
        if (!(field->flags & JBED_FIELD_INITIALIZE_STATIC))
            continue;
        field->flags |= JBED_FIELD_CONSTANT;
        get_field(c, JBED_LOCATION_STATIC, field, 0);
        field->flags &= ~JBED_FIELD_CONSTANT;
        c->input_depth = c->stack_depth;
        put_field(c, JBED_LOCATION_STATIC, field, 0);
    }
}
/* 0x169d40 CheckActiveUse and 0x169e32 CheckFieldAccess retain lazy initialization. */
static void check_active_use(JbedCoder *c, JbedClass *owner)
{
    uint32_t skip = JBED_CLASS_SKIP_INIT_CHECK;
    if (!jbed_writer_reusable(c->writer))
        skip |= JBED_CLASS_SKIP_INIT_IN_CURRENT_IMAGE;
    while (owner && !(owner->flags & skip)) {
        JbedMethod *initializer = NULL;
        JbedError error = {0};
        checked(c, jbed_vm_find_method(c->pool->services, owner, JBED_NAME_CLINIT,
                                       JBED_SIGNATURE_VOID_NO_ARGS, &initializer, &error), &error);
        if (initializer) {
            for (JbedClass *current = c->method->owner; current; current = current->superclass)
                if (current == owner)
                    return;
            initializer->code_address =
                jbed_coder_call_static_checked(c, initializer, initializer->code_address, 0, false);
            return;
        }
        owner = owner->superclass;
    }
}
static void check_field_access(JbedCoder *c, JbedField *field, bool active)
{
    if (field->flags & JBED_FIELD_UNRESOLVED)
        jbed_coder_call_static_checked(c, NULL, c->thumb->helpers.throw_no_class, 0, false);
    else if (active)
        check_active_use(c, field->owner);
}
/* 0x169aa0 NumPar. The VM supplies SignatureEncoder's decoded type sequence. */
static int32_t parameter_slots(JbedCoder *c, JbedSignatureId signature, bool is_static,
                               uint8_t *pointers)
{
    const JbedTypeId *types;
    size_t count;
    JbedTypeId result;
    if (c->services->signature_types) {
        JbedError error = {0};
        checked(c, c->services->signature_types(c->services->context, signature, &types, &count,
                                                &result, &error), &error);
    } else {
        if (!c->pool || !c->pool->services->signature_encoder)
            jbed_raise_internal(c->runtime, "Missing compiler signature encoder");
        jbed_signature_unpack(c->pool->services->signature_encoder, signature, &c->signature_args);
        types = c->signature_args.parameters;
        count = c->signature_args.count;
        result = c->signature_args.result;
    }
    int32_t slots = is_static ? 0 : 1;
    if (pointers && !is_static)
        pointers[0] = 1;
    for (size_t i = 0; i < count; ++i) {
        int32_t type = (int32_t)jbed_pool_primitive_type(types[i]);
        if (pointers)
            pointers[slots] = type == JBED_TYPE_REFERENCE;
        ++slots;
        if (type == JBED_TYPE_LONG || type == JBED_TYPE_DOUBLE) {
            if (pointers)
                pointers[slots] = 0;
            ++slots;
        }
    }
    c->active_type = result ? (int32_t)jbed_pool_primitive_type(result) : 0;
    if (pointers)
        memset(pointers + slots, 0, c->method->max_locals - (size_t)slots);
    return slots;
}
JbedAddress jbed_coder_class_address(JbedCoder *c, JbedClass *klass)
{
    if (!klass)
        return 0;
    if (c->services->class_object_address)
        return c->services->class_object_address(c->services->context, klass);
    if (!c->pool || !c->pool->services->class_access)
        jbed_raise_internal(c->runtime, "Missing class address provider");
    JbedAddress address = jbed_class_target_address(c->pool->services->class_access, klass);
    if (!address)
        jbed_raise_internal(c->runtime, "Class has no target address");
    return address;
}

/* 0x16c6bc Invoke. */
static void invoke(JbedCoder *c, unsigned opcode, JbedMethod *method)
{
    if ((method->owner->flags & JBED_CLASS_DYNAMIC) && (method->flags & JBED_METHOD_NOT_LEAF))
        ++c->nonleaf_calls;
    uint32_t original = method->code_address, address = original;
    bool instantiate = method == c->services->class_new_instance_method ||
                       (address >> 1) == (c->helpers.class_new_instance >> 1);
    if (instantiate || method == c->services->class_for_name_method ||
        (address >> 1) == (c->helpers.class_for_name >> 1)) {
        address =
            instantiate ? c->helpers.checked_class_new_instance : c->helpers.checked_class_for_name;
        if (instantiate)
            c->method->owner->flags |= JBED_CLASS_INSTANTIABLE;
        jbed_coder_load_const(c, JBED_TYPE_REFERENCE, (int32_t)jbed_coder_class_address(c, c->owner));
        c->input_depth = c->stack_depth;
        --c->stack_depth;
    }
    c->stack_depth -= parameter_slots(c, method->signature_id, opcode == JBED_BC_INVOKESTATIC, NULL);
    if (opcode != JBED_BC_INVOKESTATIC)
        check_pointer(c);
    int32_t result = c->active_type;
    if (method->flags & JBED_METHOD_NATIVE_CALL)
        c->native_call = true;
    if ((opcode == JBED_BC_INVOKEVIRTUAL || opcode == JBED_BC_INVOKEINTERFACE) &&
        method->dispatch_slot >= 0 &&
        !((method->flags | method->owner->flags) & JBED_ACC_FINAL) &&
        (!(method->owner->flags & JBED_CLASS_DYNAMIC) ||
         (method->flags & JBED_METHOD_VIRTUAL_DISPATCH)))
        jbed_thumb_call_virtual(
            c->thumb,
            method->owner->flags & JBED_ACC_INTERFACE ? jbed_coder_class_address(c, method->owner) : 0,
            4 * method->dispatch_slot + 8, result);
    else {
        uint32_t target =
            jbed_coder_call_static_checked(c, original == address ? method : NULL, address, result,
                                           opcode != JBED_BC_INVOKESTATIC &&
                                               !(method->flags & JBED_METHOD_CONSTRUCTOR));
        if (original == address)
            method->code_address = target;
    }
    c->native_call = false;
    jbed_coder_invalidate_externally_changeables(c, false);
    if (result) {
        jbed_coder_push(c, result);
        if (result == JBED_TYPE_REFERENCE && (method->flags & JBED_METHOD_RETURNS_NONNULL))
            c->stack[c->stack_depth - 1].type = 0;
    }
}
/* 0x16c21c GetClass catches all but OutOfMemoryError. */
static JbedClass *get_class(JbedCoder *c, unsigned opcode)
{
    JbedClass *result = NULL;
    JbedError error = {0};
    bool success;
    if (opcode == JBED_BC_NEWARRAY)
        success = jbed_pool_array_of_type(c->pool, read_u8(c), &result, &error);
    else if (opcode == JBED_BC_ANEWARRAY)
        success = jbed_pool_array_of_class(c->pool, read_u16(c), &result, &error);
    else
        success = jbed_pool_class(c->pool, read_u16(c), false, &result, &error);
    if (!success && (c->pool->services->boot_image || error.kind == JBED_ERROR_OUT_OF_MEMORY))
        jbed_raise(c->runtime, &error);
    return success ? result : NULL;
}
/* 0x16c894 InvokeTyped, 0x16ce48 MultiNew. */
static void invoke_typed(JbedCoder *c, unsigned opcode, JbedClass *owner)
{
    jbed_coder_load_const(c, JBED_TYPE_REFERENCE, (int32_t)jbed_coder_class_address(c, owner));
    c->input_depth = c->stack_depth;
    uint32_t address;
    int32_t result = JBED_TYPE_REFERENCE;
    switch (opcode) {
    case JBED_BC_NEW:
        address = c->helpers.new_object;
        --c->stack_depth;
        break;
    case JBED_BC_NEWARRAY:
    case JBED_BC_ANEWARRAY:
        address = c->helpers.new_array;
        c->stack_depth -= 2;
        break;
    case JBED_BC_CHECKCAST:
        address = c->helpers.check_cast;
        c->stack_depth -= 2;
        break;
    case JBED_BC_INSTANCEOF:
        address = c->helpers.instance_of;
        result = JBED_TYPE_BOOLEAN;
        c->stack_depth -= 2;
        break;
    default:
        address = c->helpers.new_array_n;
        c->stack_depth -= 3;
        break;
    }
    if (!owner)
        address = jbed_pool_error_address(c->pool, NULL);
    jbed_coder_call_static_checked(c, NULL, address, result, false);
    jbed_coder_invalidate_externally_changeables(c, false);
    jbed_coder_push(c, result);
}
static void multi_new(JbedCoder *c, JbedClass *owner, unsigned dimensions)
{
    if (dimensions <= 1)
        invoke_typed(c, JBED_BC_NEWARRAY, owner);
    else {
        multi_new(c, owner ? owner->superclass : NULL, dimensions - 1);
        invoke_typed(c, JBED_BC_MULTIANEWARRAY, owner);
    }
}

/* 0x16a212 CondJump, 0x16d3fa ReturnJump. */
static void conditional_jump(JbedCoder *c, int32_t condition, int32_t operands, int32_t type)
{
    int32_t distance = condition >= 0 ? read_i16(c) : read_i32(c);
    if (operands == 1) {
        jbed_coder_load_const(c, type, 0);
        ++c->input_depth;
    }
    if (operands > 0)
        c->stack_depth -= 2;
    if (distance <= 0)
        jbed_thumb_prepare_back_jump(c->thumb);
    jbed_thumb_normalize(c->thumb, true);
    unsigned index = jbed_coder_label_index(c, (uint32_t)c->bc_start + (uint32_t)distance);
    uint32_t label = jbed_coder_get_label(c, index);
    if (distance <= 0)
        jbed_coder_invalidate_externally_changeables(c, true);
    if (operands > 0)
        label = jbed_thumb_compare(c->thumb, condition, label, distance);
    else if (distance != 3)
        label = jbed_thumb_jump(c->thumb, label, distance);
    c->labels[index] = label;
}
static uint32_t return_jump(JbedCoder *c, unsigned opcode, uint32_t label, int32_t distance)
{
    static const JbedPrimitive types[] = {
        JBED_TYPE_INT, JBED_TYPE_LONG, JBED_TYPE_FLOAT,
        JBED_TYPE_DOUBLE, JBED_TYPE_REFERENCE, JBED_TYPE_VOID};
    int32_t type = types[opcode - JBED_BC_IRETURN];
    if (type) {
        jbed_coder_pop(c, type);
        jbed_thumb_return(c->thumb);
    }
    return (size_t)c->bc_pos != c->code_length ? jbed_thumb_jump(c->thumb, label, distance) : label;
}
/* 0x16d7f4 TableSwitch, 0x16ccea LookupSwitch, 0x16c940 JumpTree,
 * 0x16a586 DoJump. Dense subranges become tables, sparse ranges become trees. */
static int32_t case_distance(int32_t value, int32_t base)
{
    return (int32_t)((uint32_t)value - (uint32_t)base);
}

static void table_switch(JbedCoder *c, int32_t fallback, int32_t low, int32_t high)
{
    jbed_thumb_normalize(c->thumb, true);
    c->tree_size = 0;
    unsigned index = jbed_coder_label_index(c, (uint32_t)c->bc_start + (uint32_t)fallback);
    c->labels[index] =
        jbed_thumb_table_jump(c->thumb, low, high, jbed_coder_get_label(c, index), fallback);
    int32_t span = case_distance(high, low);
    for (int32_t i = 0; i <= span; ++i) {
        int32_t distance = read_i32(c);
        index = jbed_coder_label_index(c, (uint32_t)c->bc_start + (uint32_t)distance);
        c->labels[index] =
            jbed_thumb_table_entry(c->thumb, jbed_coder_get_label(c, index), distance);
    }
}
static int32_t do_jump(JbedCoder *c, int32_t previous, int32_t index, int32_t less_count)
{
    int32_t value = c->tree_constants[index], distance = c->tree_distances[index];
    --c->tree_size;
    unsigned target = jbed_coder_label_index(c, (uint32_t)c->bc_start + (uint32_t)distance);
    c->labels[target] =
        jbed_thumb_tree_jump(c->thumb, case_distance(value, previous),
                             jbed_coder_get_label(c, target), distance, c->tree_size, less_count);
    return value;
}
static void default_jump(JbedCoder *c)
{
    unsigned target =
        jbed_coder_label_index(c, (uint32_t)c->bc_start + (uint32_t)c->default_distance);
    c->labels[target] =
        jbed_thumb_jump(c->thumb, jbed_coder_get_label(c, target), c->default_distance);
}
static void jump_tree(JbedCoder *c, int32_t first, int32_t count, int32_t previous)
{
    if (count <= 0) {
        default_jump(c);
        return;
    }
    int32_t last = first + count - 1;
    int32_t minimum = c->tree_constants[first], maximum = c->tree_constants[last];
    int32_t spread = case_distance(maximum, minimum);
    if (count < 5 || spread < 0) {
        for (int32_t i = first; i <= last; ++i)
            previous = do_jump(c, previous, i, 0);
        default_jump(c);
    } else if (spread == count - 1) {
        c->tree_size -= count;
        unsigned target =
            jbed_coder_label_index(c, (uint32_t)c->bc_start + (uint32_t)c->default_distance);
        c->labels[target] =
            jbed_thumb_table_jump(c->thumb, case_distance(minimum, previous),
                                  case_distance(maximum, previous),
                                  jbed_coder_get_label(c, target), c->default_distance);
        for (int32_t i = first; i <= last; ++i) {
            int32_t distance = c->tree_distances[i];
            target = jbed_coder_label_index(c, (uint32_t)c->bc_start + (uint32_t)distance);
            c->labels[target] =
                jbed_thumb_table_entry(c->thumb, jbed_coder_get_label(c, target), distance);
        }
    } else {
        int32_t middle = (first + last) >> 1;
        int32_t right_span = case_distance(maximum, c->tree_constants[middle]);
        int32_t step = right_span == last - middle ? -1 : 1;
        int32_t split = middle + step;
        while (c->tree_constants[middle] == case_distance(c->tree_constants[split], step)) {
            middle = split;
            split = middle + step;
        }
        if (split == first) {
            previous = do_jump(c, previous, split, 0);
            jump_tree(c, first + 1, count - 1, previous);
        } else if (split == last) {
            previous = do_jump(c, previous, split, 0);
            jump_tree(c, first, count - 1, previous);
        } else {
            unsigned temporary = jbed_coder_get_temp_label(c, 0);
            c->destination_local = (int32_t)temporary;
            int32_t left_count = split - first;
            previous = do_jump(c, previous, split, left_count);
            if (c->destination_local)
                jbed_coder_set_temp_label(c, temporary, (uint32_t)c->destination_local);
            jump_tree(c, first, left_count, previous);
            jbed_coder_define_temp_label(c, temporary);
            jump_tree(c, split + 1, last - split, previous);
        }
    }
}
static void lookup_switch(JbedCoder *c, int32_t fallback, int32_t count)
{
    jbed_thumb_normalize(c->thumb, true);
    c->default_distance = fallback;
    c->tree_size = count;
    c->tree_constants = jbed_alloc(c->runtime, (size_t)count * sizeof(*c->tree_constants));
    c->tree_distances = jbed_alloc(c->runtime, (size_t)count * sizeof(*c->tree_distances));
    for (int32_t i = 0; i < count; ++i) {
        c->tree_constants[i] = read_i32(c);
        c->tree_distances[i] = read_i32(c);
    }
    jump_tree(c, 0, count, 0);
    c->tree_constants = c->tree_distances = NULL;
}
/* 0x16a7b6 FloatOp, 0x16a648 DoubleOp. */
static void float_operation(JbedCoder *c, unsigned opcode)
{
    int32_t first = JBED_TYPE_FLOAT, second = JBED_TYPE_FLOAT, result = JBED_TYPE_FLOAT;
    switch (opcode) {
    case JBED_BC_FNEG:
        second = 0;
        break;
    case JBED_BC_I2F:
        first = JBED_TYPE_INT;
        second = 0;
        break;
    case JBED_BC_L2F:
        first = JBED_TYPE_LONG;
        second = 0;
        break;
    case JBED_BC_F2I:
        result = JBED_TYPE_INT;
        second = 0;
        break;
    case JBED_BC_F2L:
        result = JBED_TYPE_LONG;
        second = 0;
        break;
    case JBED_BC_FCMPL:
    case JBED_BC_FCMPG:
        result = JBED_TYPE_INT;
        break;
    default:
        break;
    }
    jbed_coder_pop(c, first);
    if (second)
        jbed_coder_pop(c, second);
    jbed_coder_call_static_checked(c, NULL, c->helpers.arithmetic[opcode], result, false);
    jbed_coder_push(c, result);
}
static void double_operation(JbedCoder *c, unsigned opcode)
{
    int32_t first = JBED_TYPE_DOUBLE, second = JBED_TYPE_DOUBLE, result = JBED_TYPE_DOUBLE;
    switch (opcode) {
    case JBED_BC_DNEG:
        second = 0;
        break;
    case JBED_BC_I2D:
        first = JBED_TYPE_INT;
        second = 0;
        break;
    case JBED_BC_L2D:
        first = JBED_TYPE_LONG;
        second = 0;
        break;
    case JBED_BC_F2D:
        first = JBED_TYPE_FLOAT;
        second = 0;
        break;
    case JBED_BC_D2I:
        result = JBED_TYPE_INT;
        second = 0;
        break;
    case JBED_BC_D2L:
        result = JBED_TYPE_LONG;
        second = 0;
        break;
    case JBED_BC_D2F:
        result = JBED_TYPE_FLOAT;
        second = 0;
        break;
    case JBED_BC_DCMPL:
    case JBED_BC_DCMPG:
        result = JBED_TYPE_INT;
        break;
    default:
        break;
    }
    jbed_coder_pop(c, first);
    if (second)
        jbed_coder_pop(c, second);
    jbed_coder_call_static_checked(c, NULL, c->helpers.arithmetic[opcode], result, false);
    jbed_coder_push(c, result);
}
/* 0x16aaf2 GenHandlerTable. Runtime entries are [start,end,handler,class]
 * quadruples in source catch-order, followed by a zero start word. */
static void generate_handler_table(JbedCoder *c)
{
    if (!c->handler_range_position)
        return;
    uint32_t table = jbed_writer_allocate(c->writer, method_code_owner(c),
                                          (uint32_t)(c->handler_range_position / 3 * 16 + 4));
    if (c->control_word_ref) {
        jbed_writer_put_reloc(c->writer, c->control_word_ref, table + c->control_word_offset,
                              false);
        c->control_word_ref = 0;
    } else {
        if (!c->control_word_label)
            jbed_halt(c->runtime, 0, "No reference to generated handler table.");
        jbed_writer_set_label(c->writer, c->control_word_label, table + c->control_word_offset);
    }
    for (size_t i = 0; i < c->method->handler_count; ++i) {
        for (int32_t j = 0; j < c->handler_range_position; j += 3) {
            if (c->handler_ranges[j] != (int32_t)(4 * i))
                continue;
            jbed_writer_put_reloc(c->writer, table, (uint32_t)c->handler_ranges[j + 1], false);
            jbed_writer_put_reloc(c->writer, table + 4, (uint32_t)c->handler_ranges[j + 2], false);
            jbed_writer_put_reloc(c->writer, table + 8, (uint32_t)c->handler_info[2 * i + 1],
                                  false);
            uint32_t catch_index = c->method->handlers[i].catch_index;
            if (catch_index) {
                JbedClass *exception_class;
                JbedError error = {0};
                checked(c, jbed_pool_class(c->pool, catch_index, false, &exception_class, &error),
                        &error);
                jbed_writer_put_pointer(c->writer, table + 12,
                                        jbed_coder_class_address(c, exception_class));
            } else
                jbed_writer_put_word(c->writer, table + 12, 0);
            table += 16;
        }
    }
    jbed_writer_put_word(c->writer, table, 0);
}
/* 0x16cd8c MethodEntry. */
static uint32_t method_entry(JbedCoder *c)
{
    int32_t parameters = parameter_slots(
        c, c->method->signature_id, (c->method->flags & JBED_ACC_STATIC) != 0, c->local_pointers);
    c->return_type = c->active_type;
    c->handler_range_position = 0;
    if (c->method->handlers) {
        c->control_word_ref = c->control_word_label = 0;
        size_t info = 2 * c->method->handler_count, ranges = 3 * c->method->handler_count;
        if (c->handler_info_capacity < info) {
            c->handler_info = jbed_alloc(c->runtime, info * sizeof(*c->handler_info));
            c->handler_info_capacity = info;
        }
        if (c->handler_ranges_capacity < ranges) {
            c->handler_ranges = jbed_alloc(c->runtime, ranges * sizeof(*c->handler_ranges));
            c->handler_ranges_capacity = ranges;
        }
    }
    return jbed_thumb_entry_code(c->thumb, c->method->max_stack, c->method->max_locals, parameters,
                                 c->method->flags);
}

/* 0x16b642 integer Op2 lowering preserves the local-plus-small-offset
 * expression used to eliminate repeated array bounds checks. */
static void integer_operation(JbedCoder *c, unsigned opcode)
{
    c->stack_depth -= 2;
    check_destination(c);
    JbedCoderSlot *left = &c->stack[c->stack_depth], *right = left + 1;
    uint32_t expression = 0;
    if (opcode <= JBED_BC_ISUB && right->location == JBED_LOCATION_CONSTANT) {
        int32_t delta = opcode == JBED_BC_ISUB ? (int32_t)(0u - (uint32_t)right->value) : right->value;
        if ((int16_t)delta == delta) {
            if (left->location == JBED_LOCATION_LOCAL)
                expression = ((uint32_t)delta << 16) + (uint32_t)left->value + 1;
            else if (left->expression &&
                     (int32_t)(int16_t)left->expression == (int32_t)left->expression)
                expression = ((uint32_t)delta << 16) + left->expression;
        }
    }
    if (expression) {
        left->location = JBED_LOCATION_LOCAL_OFFSET;
        left->value = (int32_t)expression;
    } else
        jbed_thumb_op2(c->thumb, (int32_t)opcode);
    jbed_coder_push_word(c, JBED_TYPE_INT);
    if (expression)
        left->expression = expression;
}
static void load_local_value(JbedCoder *c, int32_t type, int32_t local)
{
    get_local(c, type, local);
    if (type == JBED_TYPE_LONG || type == JBED_TYPE_DOUBLE)
        get_local(c, type == JBED_TYPE_LONG ? JBED_TYPE_LONG_HIGH : JBED_TYPE_DOUBLE_HIGH,
                  local + 1);
}
static void store_local_value(JbedCoder *c, int32_t type, int32_t local)
{
    if (type == JBED_TYPE_LONG || type == JBED_TYPE_DOUBLE)
        put_local(c, type == JBED_TYPE_LONG ? JBED_TYPE_LONG_HIGH : JBED_TYPE_DOUBLE_HIGH,
                  local + 1);
    put_local(c, type, local);
}
static void stack_operation(JbedCoder *c, unsigned opcode)
{
    if (opcode == JBED_BC_POP || opcode == JBED_BC_POP2) {
        jbed_thumb_prepare_stack_op(c->thumb, opcode == JBED_BC_POP ? -1 : -2);
        c->stack_depth -= opcode == JBED_BC_POP ? 1 : 2;
        return;
    }
    static const int32_t prepared[] = {1, 2, 3, 2, 3, 4, 2};
    jbed_thumb_prepare_stack_op(c->thumb, prepared[opcode - JBED_BC_DUP]);
    switch (opcode) {
    case JBED_BC_DUP:
        jbed_coder_stack_push(c, 1);
        break;
    case JBED_BC_DUP_X1:
        jbed_coder_stack_push(c, 1);
        jbed_coder_stack_swap(c, 2, 3);
        break;
    case JBED_BC_DUP_X2:
        jbed_coder_stack_push(c, 1);
        jbed_coder_stack_swap(c, 2, 3);
        jbed_coder_stack_swap(c, 3, 4);
        break;
    case JBED_BC_DUP2:
        jbed_coder_stack_push(c, 2);
        jbed_coder_stack_push(c, 2);
        break;
    case JBED_BC_DUP2_X1:
        jbed_coder_stack_push(c, 2);
        jbed_coder_stack_push(c, 2);
        jbed_coder_stack_swap(c, 4, 5);
        jbed_coder_stack_swap(c, 3, 4);
        break;
    case JBED_BC_DUP2_X2:
        jbed_coder_stack_push(c, 2);
        jbed_coder_stack_push(c, 2);
        jbed_coder_stack_swap(c, 3, 5);
        jbed_coder_stack_swap(c, 4, 6);
        break;
    default:
        jbed_coder_stack_swap(c, 1, 2);
        break;
    }
}
/* Coder.Generate, 0x16ad08..0x16c036. The 201-entry Thumb jump table at
 * 0x16afc6 selects this dispatch. Verification rejects jsr/ret before entry. */
static void generate_body(void *argument)
{
    JbedCoder *c = argument;
    JbedMethod *method = c->method;
    JbedStackMaps *maps = &method->stack_maps;
    c->label_count = maps->words ? maps->words[0] : 0;
    c->nonleaf_calls = 0;
    c->method_code_range_index = -1;
    c->method_code_length = 0;
    if (c->label_capacity < (size_t)c->label_count) {
        c->label_capacity = (size_t)c->label_count;
        c->labels = jbed_alloc(c->runtime, c->label_capacity * sizeof(*c->labels));
        c->label_ids = jbed_alloc(c->runtime, c->label_capacity * sizeof(*c->label_ids));
    } else if (c->label_count) {
        memset(c->labels, 0, (size_t)c->label_count * sizeof(*c->labels));
        memset(c->label_ids, 0, (size_t)c->label_count * sizeof(*c->label_ids));
    }
    c->temp_label_count = 0;
    unsigned return_label = jbed_coder_get_temp_label(c, 0);
    c->bc_pos = c->bc_start = c->stack_depth = 0;
    jbed_optlist_reset(&c->safe_pointers);
    jbed_optlist_reset(&c->safe_indices);
    method->code_address = method_entry(c);
    if (method->flags & JBED_METHOD_CLASS_INITIALIZER)
        initialize_statics(c, method->owner);
    unsigned next_label = 0;
    bool fallthrough = true;
    while ((size_t)c->bc_pos < c->code_length) {
        if (next_label < (unsigned)c->label_count && maps->words[next_label + 1] == c->bc_pos) {
            unsigned vector = (unsigned)c->label_count + 2 * next_label + 1;
            jbed_coder_get_local_map(c, maps, maps->words[vector], method->max_locals);
            jbed_coder_get_stack_map(c, maps, maps->words[vector + 1]);
            jbed_optlist_reset(&c->safe_pointers);
            jbed_optlist_reset(&c->safe_indices);
            c->input_depth = c->stack_depth;
            jbed_thumb_normalize(c->thumb, fallthrough);
            c->labels[next_label] =
                jbed_thumb_set_label(c->thumb, c->labels[next_label], c->label_ids[next_label]);
            ++next_label;
        }
        c->destination_local = -1;
        jbed_coder_check_handlers(c);
        c->bc_start = c->bc_pos;
        c->input_depth = c->stack_depth;
        unsigned opcode = read_u8(c), width = 1;
        if (opcode == JBED_BC_WIDE) {
            opcode = read_u8(c);
            width = 2;
        }
        fallthrough = true;
        static const JbedPrimitive types[] = {
            JBED_TYPE_INT, JBED_TYPE_LONG, JBED_TYPE_FLOAT,
            JBED_TYPE_DOUBLE, JBED_TYPE_REFERENCE};
        static const JbedPrimitive array_types[] = {
            JBED_TYPE_INT, JBED_TYPE_LONG, JBED_TYPE_FLOAT, JBED_TYPE_DOUBLE,
            JBED_TYPE_REFERENCE, JBED_TYPE_BYTE, JBED_TYPE_CHAR, JBED_TYPE_SHORT};
        if (opcode >= JBED_BC_ILOAD && opcode <= JBED_BC_ALOAD) {
            load_local_value(c, types[opcode - JBED_BC_ILOAD], (int32_t)read_local(c, width));
        } else if (opcode >= JBED_BC_ILOAD_0 && opcode <= JBED_BC_ALOAD_3) {
            load_local_value(c, types[(opcode - JBED_BC_ILOAD_0) / 4],
                             (int32_t)((opcode - JBED_BC_ILOAD_0) & 3));
        } else if (opcode >= JBED_BC_IALOAD && opcode <= JBED_BC_SALOAD)
            get_array(c, array_types[opcode - JBED_BC_IALOAD]);
        else if (opcode >= JBED_BC_ISTORE && opcode <= JBED_BC_ASTORE)
            store_local_value(c, types[opcode - JBED_BC_ISTORE], (int32_t)read_local(c, width));
        else if (opcode >= JBED_BC_ISTORE_0 && opcode <= JBED_BC_ASTORE_3)
            store_local_value(c, types[(opcode - JBED_BC_ISTORE_0) / 4],
                              (int32_t)((opcode - JBED_BC_ISTORE_0) & 3));
        else if (opcode >= JBED_BC_IASTORE && opcode <= JBED_BC_SASTORE)
            put_array(c, array_types[opcode - JBED_BC_IASTORE]);
        else if (opcode >= JBED_BC_POP && opcode <= JBED_BC_SWAP)
            stack_operation(c, opcode);
        else
            switch (opcode) {
            case JBED_BC_ACONST_NULL:
                jbed_coder_load_const(c, JBED_TYPE_REFERENCE, 0);
                break;
            case JBED_BC_ICONST_M1:
            case JBED_BC_ICONST_0:
            case JBED_BC_ICONST_1:
            case JBED_BC_ICONST_2:
            case JBED_BC_ICONST_3:
            case JBED_BC_ICONST_4:
            case JBED_BC_ICONST_5:
                jbed_coder_load_const(c, JBED_TYPE_INT, (int32_t)opcode - JBED_BC_ICONST_0);
                break;
            case JBED_BC_LCONST_0:
            case JBED_BC_LCONST_1:
                jbed_thumb_load_long_const(c->thumb, JBED_TYPE_LONG, JBED_TYPE_LONG_HIGH, 0,
                                           (int32_t)opcode - JBED_BC_LCONST_0);
                break;
            case JBED_BC_FCONST_0:
            case JBED_BC_FCONST_1:
            case JBED_BC_FCONST_2:
                jbed_coder_load_const(c, JBED_TYPE_FLOAT,
                                      opcode == JBED_BC_FCONST_0 ? 0
                                      : opcode == JBED_BC_FCONST_1 ? 0x3f800000
                                                                 : 0x40000000);
                break;
            case JBED_BC_DCONST_0:
            case JBED_BC_DCONST_1:
                jbed_thumb_load_long_const(c->thumb, JBED_TYPE_DOUBLE, JBED_TYPE_DOUBLE_HIGH,
                                           opcode == JBED_BC_DCONST_0 ? 0 : 0x3ff00000, 0);
                break;
            case JBED_BC_BIPUSH:
                jbed_coder_load_const(c, JBED_TYPE_INT, read_i8(c));
                break;
            case JBED_BC_SIPUSH:
                jbed_coder_load_const(c, JBED_TYPE_INT, read_i16(c));
                break;
            case JBED_BC_LDC:
            case JBED_BC_LDC_W:
            case JBED_BC_LDC2_W: {
                unsigned index = opcode == JBED_BC_LDC ? read_u8(c) : read_u16(c);
                JbedError error = {0};
                JbedTypeId type;
                uint32_t high, low;
                checked(c, jbed_pool_constant_type(c->pool, index, &type, &error), &error);
                if (opcode != JBED_BC_LDC2_W) {
                    checked(c, jbed_pool_constant_word(c->pool, index, &low, &error), &error);
                    jbed_coder_load_const(c, (int32_t)type, (int32_t)low);
                } else if (type == JBED_TYPE_DOUBLE || type == JBED_TYPE_LONG) {
                    checked(c, jbed_pool_constant_word(c->pool, index, &high, &error), &error);
                    checked(c, jbed_pool_constant_word(c->pool, index + 1, &low, &error), &error);
                    int32_t high_type = type == JBED_TYPE_LONG ? JBED_TYPE_LONG_HIGH
                                                               : JBED_TYPE_DOUBLE_HIGH;
                    jbed_thumb_load_long_const(c->thumb, (int32_t)type, high_type,
                                               (int32_t)high, (int32_t)low);
                }
                break;
            }
            case JBED_BC_IADD:
            case JBED_BC_ISUB:
            case JBED_BC_IMUL:
            case JBED_BC_IDIV:
            case JBED_BC_IREM:
            case JBED_BC_ISHL:
            case JBED_BC_ISHR:
            case JBED_BC_IUSHR:
            case JBED_BC_IAND:
            case JBED_BC_IOR:
            case JBED_BC_IXOR:
                integer_operation(c, opcode);
                break;
            case JBED_BC_INEG:
            case JBED_BC_I2B:
            case JBED_BC_I2C:
            case JBED_BC_I2S:
                jbed_coder_pop_word(c);
                check_destination(c);
                jbed_thumb_op1(c->thumb, (int32_t)opcode);
                jbed_coder_push_word(c, JBED_TYPE_INT);
                break;
            case JBED_BC_LADD:
            case JBED_BC_LSUB:
            case JBED_BC_LMUL:
            case JBED_BC_LDIV:
            case JBED_BC_LREM:
            case JBED_BC_LAND:
            case JBED_BC_LOR:
            case JBED_BC_LXOR:
                c->stack_depth -= 4;
                jbed_coder_call_static_checked(c, NULL, c->helpers.arithmetic[opcode],
                                               JBED_TYPE_LONG, false);
                jbed_coder_push(c, JBED_TYPE_LONG);
                break;
            case JBED_BC_LNEG:
                jbed_coder_pop(c, JBED_TYPE_LONG);
                jbed_coder_call_static_checked(c, NULL, c->helpers.arithmetic[opcode],
                                               JBED_TYPE_LONG, false);
                jbed_coder_push(c, JBED_TYPE_LONG);
                break;
            case JBED_BC_LSHL:
            case JBED_BC_LSHR:
            case JBED_BC_LUSHR:
                c->stack_depth -= 3;
                jbed_coder_call_static_checked(c, NULL, c->helpers.arithmetic[opcode],
                                               JBED_TYPE_LONG, false);
                jbed_coder_push(c, JBED_TYPE_LONG);
                break;
            case JBED_BC_FADD:
            case JBED_BC_FSUB:
            case JBED_BC_FMUL:
            case JBED_BC_FDIV:
            case JBED_BC_FREM:
            case JBED_BC_FNEG:
            case JBED_BC_I2F:
            case JBED_BC_L2F:
            case JBED_BC_F2I:
            case JBED_BC_F2L:
            case JBED_BC_FCMPL:
            case JBED_BC_FCMPG:
                float_operation(c, opcode);
                break;
            case JBED_BC_DADD:
            case JBED_BC_DSUB:
            case JBED_BC_DMUL:
            case JBED_BC_DDIV:
            case JBED_BC_DREM:
            case JBED_BC_DNEG:
            case JBED_BC_I2D:
            case JBED_BC_L2D:
            case JBED_BC_F2D:
            case JBED_BC_D2I:
            case JBED_BC_D2L:
            case JBED_BC_D2F:
            case JBED_BC_DCMPL:
            case JBED_BC_DCMPG:
                double_operation(c, opcode);
                break;
            case JBED_BC_IINC: {
                int32_t local = (int32_t)read_local(c, width);
                check_local(c, local);
                get_local(c, JBED_TYPE_INT, local);
                jbed_coder_load_const(c, JBED_TYPE_INT, width == 2 ? read_i16(c) : read_i8(c));
                c->input_depth += 2;
                c->stack_depth -= 2;
                c->destination_local = local;
                jbed_thumb_op2(c->thumb, 96);
                jbed_coder_push_word(c, JBED_TYPE_INT);
                put_local(c, JBED_TYPE_INT, local);
                break;
            }
            case JBED_BC_I2L:
                jbed_coder_pop_word(c);
                jbed_thumb_op1(c->thumb, 133);
                jbed_coder_push(c, JBED_TYPE_LONG);
                break;
            case JBED_BC_L2I:
                jbed_coder_pop(c, JBED_TYPE_LONG);
                jbed_thumb_op1(c->thumb, 136);
                jbed_coder_push_word(c, JBED_TYPE_INT);
                break;
            case JBED_BC_LCMP:
                c->stack_depth -= 4;
                jbed_coder_call_static_checked(c, NULL, c->helpers.arithmetic[opcode],
                                               JBED_TYPE_INT, false);
                jbed_coder_push_word(c, JBED_TYPE_INT);
                break;
            case JBED_BC_IFEQ:
            case JBED_BC_IFNE:
            case JBED_BC_IFLT:
            case JBED_BC_IFGE:
            case JBED_BC_IFGT:
            case JBED_BC_IFLE:
                conditional_jump(c, (int32_t)opcode - JBED_BC_IFEQ, 1, JBED_TYPE_INT);
                break;
            case JBED_BC_IF_ICMPEQ:
            case JBED_BC_IF_ICMPNE:
            case JBED_BC_IF_ICMPLT:
            case JBED_BC_IF_ICMPGE:
            case JBED_BC_IF_ICMPGT:
            case JBED_BC_IF_ICMPLE:
                conditional_jump(c, (int32_t)opcode - JBED_BC_IF_ICMPEQ, 2, JBED_TYPE_INT);
                break;
            case JBED_BC_IF_ACMPEQ:
            case JBED_BC_IF_ACMPNE:
                conditional_jump(c, (int32_t)opcode - JBED_BC_IF_ACMPEQ, 2, JBED_TYPE_REFERENCE);
                break;
            case JBED_BC_GOTO:
            case JBED_BC_GOTO_W:
                conditional_jump(c, opcode == JBED_BC_GOTO ? 0 : -1, 0, 0);
                fallthrough = false;
                break;
            case JBED_BC_TABLESWITCH:
            case JBED_BC_LOOKUPSWITCH: {
                c->bc_pos = (c->bc_pos + 3) & ~3;
                jbed_coder_pop_word(c);
                int32_t fallback = read_i32(c), low_or_count = read_i32(c);
                if (opcode == JBED_BC_TABLESWITCH) {
                    int32_t high = read_i32(c);
                    table_switch(c, fallback, low_or_count, high);
                } else
                    lookup_switch(c, fallback, low_or_count);
                fallthrough = false;
                break;
            }
            case JBED_BC_IRETURN:
            case JBED_BC_LRETURN:
            case JBED_BC_FRETURN:
            case JBED_BC_DRETURN:
            case JBED_BC_ARETURN:
            case JBED_BC_RETURN:
                c->current_label_index = (int32_t)return_label;
                c->current_label_is_temp = true;
                c->temp_labels[return_label] = return_jump(c, opcode, c->temp_labels[return_label],
                                                           (int32_t)c->code_length - c->bc_start);
                fallthrough = false;
                break;
            case JBED_BC_GETSTATIC:
            case JBED_BC_PUTSTATIC:
            case JBED_BC_GETFIELD:
            case JBED_BC_PUTFIELD: {
                unsigned index = read_u16(c);
                bool is_static = opcode <= JBED_BC_PUTSTATIC;
                JbedField *field;
                JbedError error = {0};
                checked(c,
                        jbed_pool_field(c->pool, index, is_static ? JBED_ACC_STATIC : 0, &field,
                                        &error),
                        &error);
                check_field_access(c, field, is_static);
                JbedLocation mode = is_static ? JBED_LOCATION_STATIC : JBED_LOCATION_FIELD;
                if (opcode & 1)
                    put_field(c, mode, field, index);
                else
                    get_field(c, mode, field, index);
                break;
            }
            case JBED_BC_INVOKEVIRTUAL:
            case JBED_BC_INVOKESPECIAL:
            case JBED_BC_INVOKESTATIC:
            case JBED_BC_INVOKEINTERFACE: {
                unsigned index = read_u16(c);
                uint32_t flags =
                    opcode == JBED_BC_INVOKESTATIC ? JBED_ACC_STATIC
                    : opcode == JBED_BC_INVOKEINTERFACE ? JBED_ACC_INTERFACE
                    : opcode == JBED_BC_INVOKESPECIAL ? method->owner->flags & JBED_ACC_SUPER
                                                    : 0;
                JbedMethod *target;
                JbedError error = {0};
                checked(c, jbed_pool_method(c->pool, index, flags, &target, &error), &error);
                if (opcode == JBED_BC_INVOKESTATIC)
                    check_active_use(c, target->owner);
                if (opcode == JBED_BC_INVOKEINTERFACE) {
                    (void)read_u8(c);
                    (void)read_u8(c);
                }
                invoke(c, opcode, target);
                break;
            }
            case JBED_BC_NEW: {
                JbedClass *target = get_class(c, opcode);
                if (target) {
                    check_active_use(c, target);
                    if (target->flags & JBED_CLASS_DYNAMIC)
                        target->flags |= JBED_CLASS_INSTANTIABLE;
                }
                invoke_typed(c, opcode, target);
                c->stack[c->stack_depth - 1].type = 0;
                break;
            }
            case JBED_BC_NEWARRAY:
            case JBED_BC_ANEWARRAY: {
                JbedCoderSlot *size = &c->stack[c->stack_depth - 1];
                int32_t known_length = size->location == JBED_LOCATION_CONSTANT ? size->value : 0;
                JbedClass *target = get_class(c, opcode);
                invoke_typed(c, JBED_BC_NEWARRAY, target);
                c->stack[c->stack_depth - 1].type = known_length;
                break;
            }
            case JBED_BC_ARRAYLENGTH:
                jbed_coder_pop_word(c);
                check_destination(c);
                check_pointer(c);
                jbed_thumb_load(c->thumb, JBED_LOCATION_FIELD, 12, JBED_TYPE_INT);
                jbed_coder_push_word(c, JBED_TYPE_INT);
                break;
            case JBED_BC_ATHROW:
                jbed_coder_pop(c, JBED_TYPE_REFERENCE);
                jbed_coder_call_static_checked(c, NULL, c->helpers.throw_exception, 0, false);
                fallthrough = false;
                break;
            case JBED_BC_CHECKCAST:
            case JBED_BC_INSTANCEOF: {
                JbedClass *target = get_class(c, opcode);
                invoke_typed(c, opcode, target);
                break;
            }
            case JBED_BC_MONITORENTER:
            case JBED_BC_MONITOREXIT:
                jbed_coder_pop_word(c);
                jbed_coder_call_static_checked(
                    c, NULL,
                    opcode == JBED_BC_MONITORENTER ? c->helpers.monitor_enter : c->helpers.monitor_exit,
                    JBED_TYPE_VOID, false);
                break;
            case JBED_BC_MULTIANEWARRAY: {
                JbedClass *target = get_class(c, opcode);
                multi_new(c, target, read_u8(c));
                break;
            }
            case JBED_BC_IFNULL:
            case JBED_BC_IFNONNULL:
                conditional_jump(c, (int32_t)opcode - JBED_BC_IFNULL, 1, JBED_TYPE_REFERENCE);
                break;
            default:
                break; /* Original nop/default/jsr/ret entries. */
            }
        if (c->services->checkpoint)
            c->services->checkpoint(c->services->context);
    }
    jbed_coder_define_temp_label(c, return_label);
    jbed_coder_check_handlers(c);
    jbed_thumb_exit_code(c->thumb, c->nonleaf_calls < 2 ? method->flags & ~JBED_METHOD_NOT_LEAF
                                                        : method->flags);
    uint32_t size = jbed_thumb_actual_pc(c->thumb) - method->code_address;
    if ((c->debug_mode & 4) && (c->method_code_range_index >= 0 || size >= 0x10000)) {
        jbed_coder_add_code_range(c, c->allocation_start, jbed_thumb_actual_pc(c->thumb) - 1);
        jbed_coder_add_code_range(c, 0, 0);
        method->generated_size = (uint16_t)c->method_code_range_index;
        method->flags |= JBED_METHOD_CODE_RANGES;
    } else {
        c->method_code_length = (int32_t)(size < 0x10000 ? size : 0xffff);
        method->generated_size = (uint16_t)c->method_code_length;
    }
    c->total_code_length += (uint32_t)c->method_code_length;
    generate_handler_table(c);
    method->handlers = NULL;
    method->handler_count = 0;
    for (size_t i = 0; i < c->handler_info_capacity; i += 2)
        if (c->handler_info[i])
            jbed_halt(c->runtime, 0, "Found open Range!");
}

/* Generate's original catch region, 0x16c038..0x16c0dc. OOM escapes;
 * linkage/verification failures replace generated code with its VM error entry. */
void jbed_coder_generate(JbedCoder *c)
{
    JbedError caught = {0};
    if (c->runtime->protected_call(c->runtime->context, generate_body, c, &caught))
        return;
    if (caught.kind == JBED_ERROR_OUT_OF_MEMORY)
        jbed_raise(c->runtime, &caught);
    if (c->allocation_open)
        jbed_thumb_close_method(c->thumb);
    if (!(c->method->flags & JBED_METHOD_CLASS_INITIALIZER)) {
        c->method->generated_size = 0;
        c->method->code_address = jbed_pool_error_address(c->pool, &caught);
    } else {
        c->method->generated_size =
            (uint16_t)(c->method->owner->initializer_address - c->method->code_address);
        c->method->owner->initializer_address = jbed_pool_error_address(c->pool, &caught);
    }
    jbed_coder_set_control_word_ref(c, 0, 0);
    for (size_t i = 0; i < c->handler_info_capacity; i += 2)
        c->handler_info[i] = 0;
}
/* Relocated method literals in Generate, FloatOp, DoubleOp, Invoke,
 * InvokeTyped and PutArray. The low bit selects the ROM's Thumb entry. */
JbedCoderRuntimeAddresses jbed_coder_rom_helpers(uint32_t image_base)
{
    static const uint32_t arithmetic[] = {
        /* long arithmetic, shifts and compare */
        [JBED_BC_LADD] = 0xe66a9, [JBED_BC_LSUB] = 0xe6951,
        [JBED_BC_LMUL] = 0xe6885, [JBED_BC_LDIV] = 0xe66d1,
        [JBED_BC_LREM] = 0xe68af, [JBED_BC_LNEG] = 0xe689d,
        [JBED_BC_LSHL] = 0xe6911, [JBED_BC_LSHR] = 0xe6931,
        [JBED_BC_LUSHR] = 0xe6959, [JBED_BC_LAND] = 0xe66b1,
        [JBED_BC_LOR] = 0xe68a9, [JBED_BC_LXOR] = 0xe6979,
        [JBED_BC_LCMP] = 0xe66b9,
        /* float arithmetic, conversions and ordered/unordered compares */
        [JBED_BC_FADD] = 0xe50dd, [JBED_BC_FSUB] = 0xe508d,
        [JBED_BC_FMUL] = 0xe5065, [JBED_BC_FDIV] = 0xe5105,
        [JBED_BC_FREM] = 0xe50c9, [JBED_BC_FNEG] = 0xe50f1,
        [JBED_BC_I2F] = 0xe503d, [JBED_BC_L2F] = 0xe50a1,
        [JBED_BC_F2I] = 0xe5029, [JBED_BC_F2L] = 0xe50b5,
        [JBED_BC_FCMPL] = 0xe5079, [JBED_BC_FCMPG] = 0xe5051,
        /* double arithmetic, conversions and ordered/unordered compares */
        [JBED_BC_DADD] = 0xe8b49, [JBED_BC_DSUB] = 0xe8bfd,
        [JBED_BC_DMUL] = 0xe8b99, [JBED_BC_DDIV] = 0xe8b85,
        [JBED_BC_DREM] = 0xe8b5d, [JBED_BC_DNEG] = 0xe8c39,
        [JBED_BC_I2D] = 0xe8b71, [JBED_BC_L2D] = 0xe8be9,
        [JBED_BC_F2D] = 0xe8c4d, [JBED_BC_D2I] = 0xe8bad,
        [JBED_BC_D2L] = 0xe8c11, [JBED_BC_D2F] = 0xe8bc1,
        [JBED_BC_DCMPL] = 0xe8c25, [JBED_BC_DCMPG] = 0xe8bd5
    };
    JbedCoderRuntimeAddresses helpers = {
        .new_object = image_base + 0xdf949, .new_array = image_base + 0xdfa25,
        .new_array_n = image_base + 0xdfc01, .array_store = image_base + 0xe2e09,
        .check_cast = image_base + 0xe2ddd, .instance_of = image_base + 0xe2d5d,
        .throw_exception = image_base + 0xe077f,
        .monitor_enter = image_base + 0xe03b9, .monitor_exit = image_base + 0xe03f9,
        .class_for_name = image_base + 0xb5649, .checked_class_for_name = image_base + 0xb55c9,
        .class_new_instance = image_base + 0xb58c5,
        .checked_class_new_instance = image_base + 0xb5825
    };
    for (unsigned opcode = 0; opcode < sizeof(arithmetic) / sizeof(*arithmetic); ++opcode)
        if (arithmetic[opcode])
            helpers.arithmetic[opcode] = image_base + arithmetic[opcode];
    return helpers;
}

/* 0x169bd0 constructor plus Translate's original optimizer initialization. */
void jbed_coder_init(JbedCoder *c, JbedRuntime *runtime, const JbedCoderServices *services,
                     JbedEmitter *emitter, JbedWriter *writer,
                     const JbedCoderRuntimeAddresses *helpers)
{
    static const JbedCoderServices defaults = {0};
    memset(c, 0, sizeof(*c));
    c->runtime = runtime;
    c->services = services ? services : &defaults;
    c->emitter = emitter;
    c->writer = writer;
    c->helpers = helpers ? *helpers : jbed_coder_rom_helpers(0);
    jbed_optlist_init(&c->safe_pointers, runtime, 1, 0);
    jbed_optlist_init(&c->safe_indices, runtime, 2,
                      (size_t)jbed_thumb_get_num_optimized_registers());
}
/* 0x16d9a4 TranslateMethod moves bytecode ownership into Coder while compiling,
 * then resolves callers waiting on this method's old address chain. */
void jbed_coder_translate_method(JbedCoder *c, JbedMethod *method)
{
    if ((method->flags & JBED_ACC_NATIVE) && method->owner->pool &&
        method->owner->pool->services->boot_image) {
        if (!method->code_address)
            jbed_raise_internal(c->runtime, "Boot native method has no managed entry");
        return;
    }
    c->current_fixups = method->code_address;
    if (!method->code)
        method->code_address = c->thumb->helpers.throw_abstract;
    else {
        method->code_address = 0;
        jbed_emitter_set_import(c->emitter, method->owner->id, method->name_id, 0);
        c->method = method;
        c->code = method->code;
        c->code_length = method->code_length;
        method->code = NULL;
        c->owner = method->owner;
        if (!c->pool)
            c->pool = method->owner->pool;
        size_t stack = (size_t)method->max_stack + 3;
        if (c->stack_capacity < stack) {
            c->stack = jbed_alloc(c->runtime, stack * sizeof(*c->stack));
            c->stack_capacity = stack;
        }
        size_t maps = (2u * method->max_stack + method->max_locals) / 31u + 2;
        if (c->map_capacity < maps) {
            c->map_words = jbed_alloc(c->runtime, maps * sizeof(*c->map_words));
            c->map_capacity = maps;
        }
        if (c->local_pointer_capacity < method->max_locals) {
            c->local_pointers = jbed_alloc(c->runtime, method->max_locals);
            c->local_pointer_capacity = method->max_locals;
        }
        uint32_t old_count = jbed_writer_map_count(c->writer),
                 old_words = jbed_writer_long_map_words(c->writer);
        jbed_coder_generate(c);
        uint32_t new_count = jbed_writer_map_count(c->writer),
                 new_words = jbed_writer_long_map_words(c->writer);
        if ((new_count > old_count || new_words > old_words) && c->services->report_stack_maps)
            c->services->report_stack_maps(c->services->context, new_count - old_count,
                                           new_words - old_words);
        method->stack_maps = (JbedStackMaps){0};
        c->method = NULL;
        c->code = NULL;
        c->code_length = 0;
        jbed_emitter_set_import(c->emitter, 0, 0, 0);
    }
    jbed_thumb_fixup(c->thumb, c->current_fixups, method->code_address);
    if (method->label)
        jbed_writer_set_label(c->writer, method->label, method->code_address);
    c->current_fixups = 0;
}
/* 0x16d8b4 Translate. Optimizer/operand arrays have one class-compilation
 * lifetime. Handler/map storage is retained for the next class. */
void jbed_coder_translate(JbedCoder *c, JbedClass *owner)
{
    c->pool = owner->pool;
    if (!c->safe_pointers.expressions)
        jbed_optlist_init(&c->safe_pointers, c->runtime, 1, 0);
    if (!c->safe_indices.expressions)
        jbed_optlist_init(&c->safe_indices, c->runtime, 2,
                          (size_t)jbed_thumb_get_num_optimized_registers());
    for (JbedMethod *method = owner->methods; method; method = method->next) {
        jbed_coder_translate_method(c, method);
        if ((method->flags & JBED_METHOD_CONSTRUCTOR) &&
            method->signature_id == JBED_SIGNATURE_VOID_NO_ARGS) {
            owner->default_constructor_address = method->code_address;
            if (method->flags & JBED_ACC_PUBLIC)
                owner->flags |= JBED_CLASS_PUBLIC_DEFAULT_CTOR;
            if (method->flags & JBED_ACC_PRIVATE)
                owner->flags |= JBED_CLASS_PRIVATE_DEFAULT_CTOR;
        }
    }
    c->stack = NULL;
    c->stack_capacity = 0;
    memset(&c->safe_pointers, 0, sizeof(c->safe_pointers));
    memset(&c->safe_indices, 0, sizeof(c->safe_indices));
    c->pool = NULL;
    c->labels = NULL;
    c->label_capacity = 0;
    c->label_count = 0;
}
/* 0x16a914 FlushClassFixups. */
void jbed_coder_flush_class_fixups(JbedCoder *c, JbedClass *owner, uint32_t end)
{
    for (JbedMethod *method = owner->methods; method; method = method->next) {
        if (method == c->method || !method->code_address)
            continue;
        c->truncate_label = method->label;
        method->code_address = jbed_thumb_truncate_fixup(c->thumb, method->code_address, end);
        method->label = c->truncate_label;
    }
}
/* 0x169a86 LimitCheckFailed. */
_Noreturn void jbed_coder_limit_check_failed(JbedCoder *c)
{
    jbed_halt(c->runtime, 0, "Code size heuristic overflow");
}
