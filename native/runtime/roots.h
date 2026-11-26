#ifndef JBED_RUNTIME_ROOTS_H
#define JBED_RUNTIME_ROOTS_H

#include "runtime.h"
#include "../compiler/boot_image.h"

typedef struct JbedVmNativeRoot {
    void **record;
    JbedAddress *slot;
    JbedAddress *interior;
} JbedVmNativeRoot;

bool jbed_vm_next_native_root(JbedVm *, void ***cursor, void **end, JbedVmNativeRoot *);
void jbed_vm_fix_native_pointers(JbedVm *, void **begin, void **end);

/* Used by both marking and compaction while execution is in a native service. */
void jbed_vm_visit_managed_roots(JbedVm *, const JbedVmRootVisitor *);
void jbed_vm_visit_arm_roots(JbedVm *, JbedArm32Context *, const JbedVmRootVisitor *);
void jbed_vm_visit_source_stacks(void *, const JbedVmRootVisitor *, const JbedVmRootVisitor *);
void jbed_vm_bind_static_roots(JbedVm *, const JbedBootImage *);
void jbed_vm_bind_global_roots(JbedVm *, const JbedBootImage *);
void jbed_vm_visit_runtime_roots(void *, const JbedVmRootVisitor *isolate_roots,
                               const JbedVmRootVisitor *global_roots);

#endif
