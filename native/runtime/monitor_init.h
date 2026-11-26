#ifndef JBED_RUNTIME_MONITOR_INIT_H
#define JBED_RUNTIME_MONITOR_INIT_H

#include "runtime.h"

bool jbed_vm_monitor_bootstrap(JbedVm *, uint32_t sync_slots, char *error, size_t error_size);
bool jbed_vm_monitor_configure(JbedVm *, uint32_t sync_slots, char *error, size_t error_size);
bool jbed_vm_base_bootstrap(JbedVm *, uint32_t sync_slots, char *error, size_t error_size);

#endif
