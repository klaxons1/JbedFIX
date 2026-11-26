#ifndef JBED_COMPILER_EMITTER_H
#define JBED_COMPILER_EMITTER_H

#include "runtime.h"

typedef struct JbedEmitterNames {
    void *context;
    const char *(*class_name)(void *, JbedTypeId);
    const char *(*method_name)(void *, JbedNameId);
    const char *(*field_name)(void *, JbedNameId);
    /* Returned text stays valid across subsequent formatting calls, matching
     * SignatureEncoder.copyIfInUse in Emitter.getSigEnc, 0x1484fc. */
    const char *(*signature)(void *, JbedSignatureId);
} JbedEmitterNames;

/* Emitter's three r9-relative import fields, +2076/+2080/+2084. */
typedef struct JbedEmitter {
    JbedRuntime *runtime;
    const JbedEmitterNames *names;
    JbedTypeId import_class;
    JbedNameId import_method;
    JbedSignatureId import_signature;
} JbedEmitter;

typedef enum JbedEmitterDiagnostic {
    JBED_EMITTER_CLASS_FORMAT,
    JBED_EMITTER_NO_CLASS,
    JBED_EMITTER_NO_METHOD,
    JBED_EMITTER_NO_FIELD,
    JBED_EMITTER_INCOMPATIBLE_CLASS,
    JBED_EMITTER_CLASS_CIRCULARITY,
    JBED_EMITTER_ABSTRACT_METHOD,
    JBED_EMITTER_VERIFY,
    JBED_EMITTER_VERIFY_AT
} JbedEmitterDiagnostic;

/* Shared construction for throwing and explicit-result compiler entry points.
 * The message has runtime-managed lifetime; allocation can still throw OOM. */
JbedError jbed_emitter_error(JbedEmitter *, JbedEmitterDiagnostic, JbedTypeId, JbedNameId,
                             JbedSignatureId, int32_t reason_code);

void jbed_emitter_set_import(JbedEmitter *, JbedTypeId, JbedNameId, JbedSignatureId);
const char *jbed_emitter_import_class_name(JbedEmitter *);
const char *jbed_emitter_usage(JbedEmitter *);
_Noreturn void jbed_emitter_class_format(JbedEmitter *);
_Noreturn void jbed_emitter_no_class(JbedEmitter *, JbedTypeId);
_Noreturn void jbed_emitter_no_method(JbedEmitter *, JbedTypeId, JbedNameId, JbedSignatureId);
_Noreturn void jbed_emitter_no_field(JbedEmitter *, JbedTypeId, JbedNameId);
_Noreturn void jbed_emitter_incompatible_class(JbedEmitter *, JbedTypeId);
_Noreturn void jbed_emitter_class_circularity(JbedEmitter *, JbedTypeId);
_Noreturn void jbed_emitter_abstract_method(JbedEmitter *, JbedTypeId, JbedNameId, JbedSignatureId);
_Noreturn void jbed_emitter_verify(JbedEmitter *);
_Noreturn void jbed_emitter_verify_at(JbedEmitter *, int32_t reason_code);

#endif
