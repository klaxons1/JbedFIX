#ifndef JBED_RUNTIME_COLLECTOR_INIT_H
#define JBED_RUNTIME_COLLECTOR_INIT_H

#include "runtime.h"

/* Initializes VM-wide collection before the first application isolate exists. */
bool jbed_vm_collector_bootstrap(JbedVm *, char *error, size_t error_size);
void jbed_vm_run_collector(JbedVm *, bool clear_soft_references);
void jbed_vm_run_compactor(JbedVm *, bool oldest_hole);
void jbed_vm_shutdown_collector(JbedVm *);

#endif
