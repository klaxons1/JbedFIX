#ifndef JBED_RUNTIME_EXECUTION_H
#define JBED_RUNTIME_EXECUTION_H

#include "runtime.h"
#include "arm32.h"

bool jbed_vm_invoke(JbedVm *, JbedAddress entry, const uint32_t *arguments,
                    size_t word_count, uint64_t *result);
JbedAddress jbed_vm_new_throwable(JbedVm *, const char *class_name);
JbedAddress jbed_vm_error_throwable(JbedVm *, const JbedError *);
bool jbed_vm_exceptions_bootstrap(JbedVm *, char *error, size_t error_size);
void jbed_vm_dispatch(JbedArm32Context *, JbedArm32Operation, JbedArm32Frame *);

#endif
