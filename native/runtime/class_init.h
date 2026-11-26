#ifndef JBED_RUNTIME_CLASS_INIT_H
#define JBED_RUNTIME_CLASS_INIT_H

#include "runtime.h"

/* On failure, pending_exception contains the throwable seen by the caller. */
bool jbed_vm_initialize_class(JbedVm *, JbedAddress klass);
bool jbed_vm_static_initialize_class(JbedVm *, JbedAddress klass);

#endif
