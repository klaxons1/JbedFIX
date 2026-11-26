#ifndef JBED_VM_COLLECTOR_H
#define JBED_VM_COLLECTOR_H

#include "vm_mark.h"
#include "vm_stackmap.h"

typedef struct JbedVmCollector {
    JbedVmMarker marker;
    JbedVmMarkStacks stacks;
    JbedAddress isolates, global_start, global_end;
    uint32_t static_pointer_offset, static_pointer_size;
    uint32_t collections;
    int32_t finalizing_isolate, default_ttl;
    bool finalizing, checkpoint_requested;
    /* Executes Finalized.finalize() with the selected isolate's statics. */
    void *context;
    void (*invoke_finalizer)(void *, JbedAddress isolate, JbedAddress object);
    void (*visit_roots)(void *, const JbedVmRootVisitor *isolate_roots,
                       const JbedVmRootVisitor *global_roots);
} JbedVmCollector;

/* The scheduler supplies stopped thread contexts; isolates is the VM's
 * Isolate[] object. Attach this collector to heap->collector for allocation. */
void jbed_vm_collect(JbedVmCollector *, bool clear_soft_references);
void jbed_vm_collector_shutdown(JbedVmCollector *);

#endif
