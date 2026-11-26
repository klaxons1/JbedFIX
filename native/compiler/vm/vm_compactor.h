#ifndef JBED_VM_COMPACTOR_H
#define JBED_VM_COMPACTOR_H

#include "vm_collector.h"

enum { JBED_COMPACTOR_HOLE_COUNT = 6 };

typedef struct JbedVmHole {
    uint32_t size;
    JbedAddress start;
    uint32_t order;
} JbedVmHole;

typedef struct JbedVmCompactor {
    JbedVmCollector *collector;
    JbedBuffer memory;
    JbedAddress finalized_slot; /* Target word holding the VM-wide finalizer head. */
    JbedVmHole holes[JBED_COMPACTOR_HOLE_COUNT];        /* Compactor.init allocates eighteen ints. */
    uint32_t largest_hole, next_order;
    uint32_t runs, moved, stack_locked;
    bool oldest_hole;
} JbedVmCompactor;

void jbed_vm_compactor_init(JbedVmCompactor *, JbedVmCollector *, JbedAddress finalized_slot);
void jbed_vm_compact(JbedVmCompactor *, bool oldest_hole);
void jbed_vm_thread_field(JbedVmCompactor *, JbedAddress slot);
void jbed_vm_thread_slot(JbedVmCompactor *, JbedAddress slot);
JbedVmRootVisitor jbed_vm_compact_root_visitor(JbedVmCompactor *);
void jbed_vm_compact_roots(JbedVmCompactor *);
void jbed_vm_compact_relocate_roots(JbedVmCompactor *, JbedAddress source, JbedAddress destination);
void jbed_vm_compact_fix_interior(JbedVmCompactor *);

#endif
