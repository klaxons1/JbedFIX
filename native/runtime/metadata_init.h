#ifndef JBED_RUNTIME_METADATA_INIT_H
#define JBED_RUNTIME_METADATA_INIT_H

#include "runtime.h"

JbedAddress jbed_vm_static_field_slot(JbedVm *, const char *owner, const char *name);
/* character_root is a scanned writable word owned by the runtime compiler. */
bool jbed_vm_metadata_bootstrap(JbedVm *, JbedAddress intern_table, JbedAddress character_root,
                                 char *error, size_t error_size);

#endif
