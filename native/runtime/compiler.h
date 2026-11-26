#ifndef JBED_RUNTIME_COMPILER_H
#define JBED_RUNTIME_COMPILER_H

#include "runtime.h"
#include "../compiler/compiler.h"
#include "../compiler/signatures.h"

JbedCompiler *jbed_vm_compiler_driver(JbedVm *);
JbedClassAccess *jbed_vm_compiler_classes(JbedVm *);
JbedSignatureEncoder *jbed_vm_compiler_signatures(JbedVm *);
void jbed_vm_compiler_configure(JbedVm *, JbedWriter *, const JbedReaderLayout *);
void jbed_vm_compiler_rebase_statics(JbedVm *, JbedAddress old_base, JbedAddress new_base);
void jbed_vm_compiler_dispose(JbedVm *);

void Compiler_initialize(void);
void Compiler_startCompile(int32_t options, bool long_jumps, JbRef progress,
                           int32_t classes, int32_t read_weight);
void Compiler_define(int32_t id, JbRef bytes, int32_t offset, int32_t length);
void Compiler_compile(void);
void Compiler_compileDone(bool register_classes);
void Compiler_reset(void);
void Compiler_enableSwapping(JbRef output, JbRef input);
void Compiler_disableSwapping(void);
bool Compiler_isSwapping(void);
bool Compiler_isCanceled(void);
bool Compiler_fullDebugInfo(void);
void Compiler_flushFixups(int32_t boundary);

#endif
