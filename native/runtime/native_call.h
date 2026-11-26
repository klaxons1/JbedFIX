#ifndef JBED_RUNTIME_NATIVE_CALL_H
#define JBED_RUNTIME_NATIVE_CALL_H

#include "runtime.h"
#include "arm32.h"
#include "../compiler/boot_image.h"

bool jbed_vm_native_methods_init(JbedVm *, const JbedBootImage *, char *error, size_t error_size);
void jbed_vm_native_methods_dispose(JbedVm *);
bool jbed_vm_call_native(JbedVm *, uint32_t index, JbedArm32Frame *);

#endif
