#ifndef JBED_VM_MARK_H
#define JBED_VM_MARK_H

#include "../runtime.h"
#include "vm_memory.h"
#include "vm_stackmap.h"

typedef struct JbedVmMarker {
    JbedVmHeap *heap;
    JbedRuntime *runtime;
    bool marking_vm_globals;
} JbedVmMarker;

typedef struct JbedVmMarkStacks {
    JbedVmStackMaps *maps;
    const JbedVmNativeFrames *native_frames;
    JbedAddress current_statics, vm_dummy;
    void *provider_context;
    void (*stack_provider)(void *, const JbedVmRootVisitor *, const JbedVmRootVisitor *);
} JbedVmMarkStacks;

/* Marking and compaction visit the same saved stacks and isolate static ranges.
 * The VM dummy runs under the global-root marking rules. */
void jbed_vm_visit_isolate_ranges(JbedBuffer, JbedAddress isolates, uint32_t default_offset,
                                  uint32_t default_size, void *context,
                                  void (*range)(void *, JbedAddress, JbedAddress));
void jbed_vm_visit_isolate_stacks(const JbedVmHeap *, JbedAddress isolates,
                                  const JbedVmMarkStacks *, const JbedVmRootVisitor *,
                                  const JbedVmRootVisitor *dummy_visitor);

/* Stop-the-world operations. Object addresses, class tags, roots and isolate
 * statics are in heap->memory. A failed collector invariant halts the VM. */
void jbed_vm_mark_descendants(JbedVmMarker *, JbedAddress object);
void jbed_vm_mark_pointer(JbedVmMarker *, JbedAddress object);
void jbed_vm_mark_stack_reference(JbedVmMarker *, JbedAddress slot);
void jbed_vm_mark_internal_pointer(JbedVmMarker *, JbedAddress slot);
void jbed_vm_mark_range(JbedVmMarker *, JbedAddress start, JbedAddress end);
void jbed_vm_mark_globals(JbedVmMarker *, JbedAddress start, JbedAddress end, JbedAddress isolates,
                          uint32_t default_offset, uint32_t default_size);
/* The active thread's Scheduled.context must contain the suspended guest registers. */
void jbed_vm_mark_isolates(JbedVmMarker *, JbedAddress isolates, const JbedVmMarkStacks *);

void jbed_vm_hide_special_references(JbedVmMarker *, JbedAddress isolate_statics);
void jbed_vm_process_references(JbedVmMarker *, JbedAddress isolate_statics, bool clear_soft);
void jbed_vm_hide_isolate_references(JbedVmMarker *, JbedAddress isolates);
void jbed_vm_process_isolate_references(JbedVmMarker *, JbedAddress isolates, bool clear_soft);

#endif
