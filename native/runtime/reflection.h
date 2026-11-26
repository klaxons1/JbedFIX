#ifndef JBED_RUNTIME_REFLECTION_H
#define JBED_RUNTIME_REFLECTION_H

#include "runtime.h"

JbedAddress jbed_vm_class_for_name(JbedVm *, JbedAddress name, JbedAddress caller, bool checked);
JbedAddress jbed_vm_class_new_instance(JbedVm *, JbedAddress klass, JbedAddress caller, bool checked);
JbedAddress Class_checkedNewInstance(JbedAddress klass, JbedAddress caller);

#endif
