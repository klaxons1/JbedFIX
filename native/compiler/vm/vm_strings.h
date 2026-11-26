#ifndef JBED_VM_STRINGS_H
#define JBED_VM_STRINGS_H

#include "pool.h"
#include "vm_memory.h"

typedef struct JbedVmStringImage {
    JbedAddress string_class, char_array_class, string_array_class;
    JbedAddress intern_table;
    JbedAddress static_table_slot, dynamic_table_slot;
} JbedVmStringImage;

typedef struct JbedVmStrings {
    JbedVmHeap *heap;
    JbedVmStringImage image;
    /* A scanned target word for the current Pool.characters reference. */
    JbedAddress character_root;
} JbedVmStrings;

bool jbed_vm_strings_init_image(JbedVmStrings *, JbedVmHeap *, JbedVmStringImage,
                                JbedAddress character_root);
bool jbed_vm_strings_init(JbedVmStrings *, JbedVmHeap *, JbedAddress rom_base,
                          JbedAddress isolate_statics, JbedAddress character_root);
bool jbed_vm_strings_reset(JbedVmStrings *);
uint32_t jbed_vm_string_table_size(const JbedVmStrings *);
JbedAddress jbed_vm_string_intern(JbedVmStrings *, JbedAddress string, bool create);

bool jbed_vm_pool_character_buffer(JbedVmStrings *, size_t used, size_t capacity, JbedError *);
void jbed_vm_pool_finish_characters(JbedVmStrings *, uint32_t length);
bool jbed_vm_pool_intern(JbedPool *, size_t start, JbedPoolString **, bool *retained, JbedError *);
JbedPoolString *jbed_vm_pool_string_at(const JbedPoolServices *, JbedAddress);

#endif
