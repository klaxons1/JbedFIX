#ifndef JBED_COMPILER_OPTLIST_H
#define JBED_COMPILER_OPTLIST_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "runtime.h"

/* JBedFastCoder.OptList tracks proven non-null expressions (width 1), or
 * array/index expressions and the registers holding them (width 2). Expression
 * identity uses a local number in the low 16 bits and a field in the high bits.
 * Register entries retain the original packed index/offset representation. */
typedef struct JbedOptList {
    JbedRuntime *runtime;
    uint32_t *expressions;
    size_t capacity, used;
    unsigned width;
    int32_t *registers;
    size_t register_count;
    int32_t found_register;
    uint32_t found_address;
    int32_t found_index;
    bool registers_enabled;
} JbedOptList;

void jbed_optlist_init(JbedOptList *, JbedRuntime *, unsigned width, size_t registers);
void jbed_optlist_reset(JbedOptList *);
void jbed_optlist_reset_lookup(JbedOptList *);
void jbed_optlist_add(JbedOptList *, uint32_t expression, uint32_t index);
void jbed_optlist_add_pointer(JbedOptList *, uint32_t expression);
bool jbed_optlist_search(JbedOptList *, uint32_t expression, uint32_t index);
bool jbed_optlist_search_pointer(JbedOptList *, uint32_t expression);
uint32_t jbed_optlist_get_registers(const JbedOptList *, bool include_addresses);
void jbed_optlist_remove(JbedOptList *, int32_t component, uint32_t value, uint32_t mask);
void jbed_optlist_remove_fields(JbedOptList *);
void jbed_optlist_remove_register_index(JbedOptList *, size_t index);
void jbed_optlist_remove_registers(JbedOptList *, uint32_t mask);
void jbed_optlist_remove_array_write(JbedOptList *, uint32_t array, uint32_t index);
void jbed_optlist_set_register(JbedOptList *, int32_t reg, int32_t offset);

#endif
