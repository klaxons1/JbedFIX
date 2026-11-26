#ifndef JBED_COMPILER_METHOD_RANGES_H
#define JBED_COMPILER_METHOD_RANGES_H

#include "runtime.h"

int32_t jbed_method_add_range(JbedRuntime *, uint32_t first, uint32_t last);
void jbed_method_discard_ranges(JbedRuntime *);
void jbed_method_pack_ranges(JbedRuntime *, JbedMethod *, uint32_t **words, size_t *used,
                             size_t *capacity);
int32_t jbed_method_pc_offset(JbedRuntime *, const JbedMethod *, uint32_t pc);
JbedMethod *jbed_search_dynamic_method_by_pc(JbedRuntime *, const JbedClass *, uint32_t pc);

/* Returns the matching 16-byte record within a loaded little-endian class object. */
const uint8_t *jbed_search_rom_method_by_pc(JbedRuntime *, const uint8_t *object, size_t bytes,
                                            uint32_t pc);

typedef enum JbedMethodSearch {
    JBED_METHOD_ALL_BUNDLES,
    JBED_METHOD_LOADED_BUNDLE,
    JBED_METHOD_DYNAMIC_BUNDLE
} JbedMethodSearch;

JbedMethod *jbed_method_by_pc(const JbedClassAccess *, uint32_t pc, JbedMethodSearch);

#endif
