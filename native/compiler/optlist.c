#include "optlist.h"
#include <string.h>

static void require(const JbedOptList *list, bool condition, JbedErrorKind kind)
{
    if (!condition) {
        JbedError error = {.kind = kind, .is_java_error = false};
        jbed_raise(list->runtime, &error);
    }
}

/* 0x19a786 Init; 0x19aa0e Reset. Buffers belong to the compiler runtime arena. */
void jbed_optlist_init(JbedOptList *list, JbedRuntime *runtime, unsigned width, size_t registers)
{
    *list = (JbedOptList){.runtime = runtime};
    require(list, width == 1 || width == 2, JBED_ERROR_RUNTIME_EXCEPTION);
    list->capacity = 16;
    list->expressions = jbed_alloc(runtime, 16 * sizeof(*list->expressions));
    if (registers)
        list->registers = jbed_alloc(runtime, registers * sizeof(*list->registers));
    list->register_count = registers;
    jbed_optlist_reset(list);
    list->width = width;
    list->found_index = -1;
}

void jbed_optlist_reset(JbedOptList *list)
{
    list->used = 0;
    for (size_t i = 0; i < list->register_count; ++i)
        list->registers[i] = -1;
}

/* 0x19aa3e ResetLookupResults. */
void jbed_optlist_reset_lookup(JbedOptList *list)
{
    list->found_index = -1;
    list->found_address = 0;
    list->found_register = -1;
}

/* 0x19a5ea Add. Reuse the last empty slot, preserving original lookup order.
 * A zero second component is a wildcard when checking an existing entry. */
void jbed_optlist_add(JbedOptList *list, uint32_t expression, uint32_t index)
{
    require(list, list->width == 2 || !index, JBED_ERROR_RUNTIME_EXCEPTION);
    size_t slot = list->used;
    for (size_t i = 0; i < list->used; i += list->width) {
        if (!list->expressions[i])
            slot = i;
        if (list->expressions[i] == expression && (!index || list->expressions[i + 1] == index)) {
            list->found_index = (int32_t)i;
            return;
        }
    }
    if (slot + list->width > list->capacity) {
        size_t capacity = list->capacity * 2;
        uint32_t *replacement = jbed_alloc(list->runtime, capacity * sizeof(*replacement));
        memcpy(replacement, list->expressions, slot * sizeof(*replacement));
        list->expressions = replacement;
        list->capacity = capacity;
    }
    list->expressions[slot] = expression;
    if (list->width == 2)
        list->expressions[slot + 1] = index;
    if (list->used < slot + list->width)
        list->used = slot + list->width;
    list->found_index = (int32_t)slot;
}

/* 0x19a708 AddPointer. */
void jbed_optlist_add_pointer(JbedOptList *list, uint32_t expression)
{
    require(list, list->width == 1, JBED_ERROR_RUNTIME_EXCEPTION);
    jbed_optlist_add(list, expression, 0);
}

/* 0x19aa4e Search; 0x19ab3c SearchPointer. */
bool jbed_optlist_search(JbedOptList *list, uint32_t expression, uint32_t index)
{
    jbed_optlist_reset_lookup(list);
    size_t slot;
    for (slot = 0; slot < list->used; slot += list->width) {
        if (list->expressions[slot] != expression)
            continue;
        if (index) {
            require(list, slot + 1 < list->capacity, JBED_ERROR_ARRAY_INDEX);
            if (list->expressions[slot + 1] != index)
                continue;
        }
        break;
    }
    if (slot == list->used)
        return false;
    list->found_index = (int32_t)slot;
    if (index) {
        require(list, list->width == 2 && list->registers, JBED_ERROR_RUNTIME_EXCEPTION);
        for (size_t reg = 0; reg < list->register_count && list->found_register < 0; ++reg) {
            if (list->registers[reg] == (int32_t)slot)
                list->found_register = (int32_t)reg;
        }
        for (size_t reg = 0; reg < list->register_count && !list->found_address; ++reg) {
            uint32_t encoded = (uint32_t)list->registers[reg];
            if ((encoded >> 16) && (encoded & 0xffffu) == slot)
                list->found_address = (uint32_t)reg + ((encoded - 0x10000u) & 0xffff0000u);
        }
    }
    return true;
}

bool jbed_optlist_search_pointer(JbedOptList *list, uint32_t expression)
{
    require(list, list->width == 1, JBED_ERROR_RUNTIME_EXCEPTION);
    return jbed_optlist_search(list, expression, 0);
}

/* 0x19a740 GetRegs. Register shifts follow Java's masked shift distance. */
uint32_t jbed_optlist_get_registers(const JbedOptList *list, bool addresses)
{
    require(list, list->registers != NULL, JBED_ERROR_NULL_POINTER);
    uint32_t mask = 0;
    for (size_t reg = 0; reg < list->register_count; ++reg) {
        int32_t value = list->registers[reg];
        if (value != -1 && (!(value >> 16) || addresses))
            mask |= UINT32_C(1) << (reg & 31);
    }
    return mask;
}

/* 0x19a8d4 RemoveRegByIndex. */
void jbed_optlist_remove_register_index(JbedOptList *list, size_t index)
{
    require(list, list->width == 1 || !(index & 1), JBED_ERROR_RUNTIME_EXCEPTION);
    require(list, list->registers != NULL, JBED_ERROR_NULL_POINTER);
    for (size_t reg = 0; reg < list->register_count; ++reg)
        if (((uint32_t)list->registers[reg] & 0xffffu) == index)
            list->registers[reg] = -1;
}

/* 0x19a7ec Remove. A match invalidates both halves of an array/index pair. */
void jbed_optlist_remove(JbedOptList *list, int32_t component, uint32_t value, uint32_t mask)
{
    require(list, !component || list->width == 2, JBED_ERROR_RUNTIME_EXCEPTION);
    require(list, component >= 0, JBED_ERROR_ARRAY_INDEX);
    for (size_t i = (size_t)component; i < list->used; i += list->width) {
        if ((list->expressions[i] & mask) != value)
            continue;
        list->expressions[i] = 0;
        if (list->width == 2) {
            list->expressions[i ^ 1] = 0;
            jbed_optlist_remove_register_index(list, i & ~(size_t)1);
        }
    }
}

/* 0x19a880 RemoveFields. The original invalidates all cached registers here,
 * including those attached to expressions whose high half is zero. */
void jbed_optlist_remove_fields(JbedOptList *list)
{
    for (size_t i = 0; i < list->used; i += list->width) {
        if (list->expressions[i] >> 16)
            list->expressions[i] = 0;
        if (list->registers)
            jbed_optlist_remove_register_index(list, i);
    }
}

/* 0x19a934 RemoveRegs. */
void jbed_optlist_remove_registers(JbedOptList *list, uint32_t mask)
{
    require(list, list->registers != NULL, JBED_ERROR_NULL_POINTER);
    for (size_t reg = 0; reg < list->register_count; ++reg)
        if (mask & (UINT32_C(1) << (reg & 31)))
            list->registers[reg] = -1;
}

/* 0x19a96c RemoveRegsOnArrayWrite. A distinct constant index on the same
 * identified array is the only value-cache entry that survives a store. */
void jbed_optlist_remove_array_write(JbedOptList *list, uint32_t array, uint32_t index)
{
    require(list, list->registers != NULL, JBED_ERROR_NULL_POINTER);
    for (size_t reg = 0; reg < list->register_count; ++reg) {
        uint32_t entry = (uint32_t)list->registers[reg];
        if (entry & 0xffff0000u)
            continue;
        require(list, entry + 1 < list->capacity, JBED_ERROR_ARRAY_INDEX);
        uint32_t known_index = list->expressions[entry + 1];
        if (!index || list->expressions[entry] != array ||
            (known_index & 0xffffu) != (index & 0xffffu) || (known_index >> 16) == (index >> 16))
            list->registers[reg] = -1;
    }
}

/* 0x19ab74 SetRegister. offset=-1 records a value; other offsets record an
 * address derived from the selected expression. Addition wraps as Java int. */
void jbed_optlist_set_register(JbedOptList *list, int32_t reg, int32_t offset)
{
    require(list, list->registers != NULL, JBED_ERROR_NULL_POINTER);
    require(list, reg < (int32_t)list->register_count && list->registers_enabled,
            JBED_ERROR_RUNTIME_EXCEPTION);
    require(list, reg >= 0, JBED_ERROR_ARRAY_INDEX);
    list->registers[reg] =
        list->found_index < 0
            ? -1
            : (int32_t)((uint32_t)list->found_index + (((uint32_t)offset + 1) << 16));
}
