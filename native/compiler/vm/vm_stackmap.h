#ifndef JBED_VM_STACKMAP_H
#define JBED_VM_STACKMAP_H

#include "../runtime.h"
#include "vm_exception.h"

typedef struct JbedVmStackMapBlock JbedVmStackMapBlock;
typedef struct JbedVmStackMaps {
    JbedRuntime *runtime;
    JbedVmMemoryReader memory;
    JbedVmStackMapBlock *blocks;
    uint32_t *bitmap;
    uint32_t capacity, last_word, next_id;
    JbedAddress cached_pc;
    bool cached;
} JbedVmStackMaps;

typedef struct JbedVmRootVisitor {
    void *context;
    void (*stack_reference)(void *, JbedAddress slot);
    void (*internal_pointer)(void *, JbedAddress slot);
} JbedVmRootVisitor;

typedef struct JbedVmStackRoots {
    JbedAddress sp, fp, pc;
    JbedAddress register_slots[3]; /* Writable saved r4, r5 and r6. */
} JbedVmStackRoots;

void jbed_vm_stack_maps_init(JbedVmStackMaps *, JbedRuntime *, JbedVmMemoryReader);
uint32_t jbed_vm_stack_map_id(JbedVmStackMaps *);
void jbed_vm_stack_map_add(JbedVmStackMaps *, JbedAddress header, uint32_t id);
void jbed_vm_stack_maps_add_resident(JbedVmStackMaps *, JbedAddress tables);
void jbed_vm_stack_maps_remove(JbedVmStackMaps *, uint32_t id);
uint32_t jbed_vm_stack_map_word(JbedVmStackMaps *, JbedAddress pc, uint32_t index);

struct JbedVmMarker;
JbedVmRootVisitor jbed_vm_mark_root_visitor(struct JbedVmMarker *);

/* Visit one managed activation, stopping at its native entry (FP zero). */
void jbed_vm_traverse_frames(JbedVmStackMaps *, JbedVmStackRoots,
                             const JbedVmRootVisitor *);

/* Scheduled.context contains the saved r4..r6, FP and PC. Native call state
 * is active only for current_scheduled. Visitors receive slot addresses, with
 * bit zero set for a saved native register (preserved by Compactor). */
void jbed_vm_traverse_stack(JbedVmStackMaps *, JbedAddress scheduled,
                            JbedAddress current_scheduled, const JbedVmNativeFrames *,
                            const JbedVmRootVisitor *);
void jbed_vm_traverse_scheduled(JbedVmStackMaps *, JbedAddress threads,
                                JbedAddress current_scheduled, const JbedVmNativeFrames *,
                                const JbedVmRootVisitor *);

#endif
