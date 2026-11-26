#ifndef JBED_RUNTIME_TRACE_H
#define JBED_RUNTIME_TRACE_H

#include "runtime.h"

void jbed_vm_fill_throwable_trace(void *context, JbedAddress *throwable);
void jbed_vm_fill_trace_at(JbedVm *, JbedAddress *throwable, JbedAddress pc, JbedAddress fp);

#endif
