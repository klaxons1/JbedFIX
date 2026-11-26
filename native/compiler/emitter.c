#include "emitter.h"
#include <stdio.h>
#include <string.h>

static const char *join(JbedEmitter *e, const char **pieces, size_t count)
{
    size_t length = 0;
    for (size_t i = 0; i < count; ++i) {
        if (!pieces[i])
            pieces[i] = "null"; /* StringBuffer.append(String), 0xb7b90. */
        length += strlen(pieces[i]);
    }
    char *result = jbed_alloc(e->runtime, length + 1);
    char *cursor = result;
    for (size_t i = 0; i < count; ++i) {
        size_t size = strlen(pieces[i]);
        memcpy(cursor, pieces[i], size);
        cursor += size;
    }
    *cursor = 0;
    return result;
}

/* 0x148390/0x1483ac setImport; the two-argument form sets signature to zero. */
void jbed_emitter_set_import(JbedEmitter *e, JbedTypeId type, JbedNameId method,
                             JbedSignatureId signature)
{
    e->import_class = type;
    e->import_method = method;
    e->import_signature = signature;
}
/* 0x1483c4 impClassName. */
const char *jbed_emitter_import_class_name(JbedEmitter *e)
{
    return e->names->class_name(e->names->context, e->import_class);
}
/* 0x1483f4 usage. Signature formatting is SignatureEncoder.idToSignature;
 * its copyIfInUse protocol (0x1484fc) is owned by the name-service adapter. */
const char *jbed_emitter_usage(JbedEmitter *e)
{
    if (!e->import_class)
        return "";
    const char *parts[6];
    size_t count = 0;
    parts[count++] = "(used in ";
    parts[count++] = jbed_emitter_import_class_name(e);
    if (e->import_method) {
        parts[count++] = ".";
        parts[count++] = e->names->method_name(e->names->context, e->import_method);
        if (e->import_signature)
            parts[count++] = e->names->signature(e->names->context, e->import_signature);
    }
    parts[count++] = ")";
    return join(e, parts, count);
}

/* Despite their helper names, these original methods allocate java/lang/Error
 * (ROM vtable 0x20ff60). Only noClass and verifyAt allocate NoClassDefFoundError
 * (0x2177b0). Construction is shared by throw and explicit-result boundaries. */
JbedError jbed_emitter_error(JbedEmitter *e, JbedEmitterDiagnostic diagnostic, JbedTypeId type,
                             JbedNameId member, JbedSignatureId signature, int32_t reason)
{
    JbedError error = {.kind = JBED_ERROR_ERROR,
                       .is_java_error = true,
                       .class_id = type,
                       .member_id = member,
                       .bytecode_offset = -1};
    const char *parts[6];
    size_t count = 0;
    char number[16];
    switch (diagnostic) {
    case JBED_EMITTER_CLASS_FORMAT: /* 0x148520 */
        parts[count++] = "class format error in ";
        parts[count++] = jbed_emitter_import_class_name(e);
        error.class_id = e->import_class;
        error.member_id = 0;
        break;
    case JBED_EMITTER_NO_CLASS: /* 0x148574 */
        error.kind = JBED_ERROR_NO_CLASS_DEF;
        parts[count++] = "class not found: ";
        parts[count++] = e->names->class_name(e->names->context, type);
        parts[count++] = jbed_emitter_usage(e);
        error.member_id = 0;
        break;
    case JBED_EMITTER_NO_METHOD:       /* 0x1485ec */
    case JBED_EMITTER_ABSTRACT_METHOD: /* 0x14882c */
        parts[count++] = diagnostic == JBED_EMITTER_NO_METHOD ? "method not found: "
                                                              : "abstract method called: ";
        parts[count++] = e->names->class_name(e->names->context, type);
        parts[count++] = ".";
        parts[count++] = e->names->method_name(e->names->context, member);
        parts[count++] = e->names->signature(e->names->context, signature);
        parts[count++] = jbed_emitter_usage(e);
        break;
    case JBED_EMITTER_NO_FIELD: /* 0x1486a4 */
        parts[count++] = "Field not found: ";
        parts[count++] = e->names->class_name(e->names->context, type);
        parts[count++] = ".";
        parts[count++] = e->names->field_name(e->names->context, member);
        parts[count++] = jbed_emitter_usage(e);
        break;
    case JBED_EMITTER_INCOMPATIBLE_CLASS: /* 0x148748 */
        parts[count++] = "incompatible class change in ";
        parts[count++] = e->names->class_name(e->names->context, type);
        parts[count++] = jbed_emitter_usage(e);
        error.member_id = 0;
        break;
    case JBED_EMITTER_CLASS_CIRCULARITY: /* 0x1487c0; deliberately no usage suffix */
        parts[count++] = "circular super class: ";
        parts[count++] = e->names->class_name(e->names->context, type);
        error.member_id = 0;
        break;
    case JBED_EMITTER_VERIFY:    /* 0x1488e4 */
    case JBED_EMITTER_VERIFY_AT: /* 0x148938 */
        parts[count++] = "verify error ";
        if (diagnostic == JBED_EMITTER_VERIFY_AT) {
            snprintf(number, sizeof(number), "%ld", (long)reason);
            parts[count++] = number;
            parts[count++] = " ";
            error.kind = JBED_ERROR_NO_CLASS_DEF;
            error.detail_code = (uint32_t)reason;
            error.bytecode_offset = 0;
        }
        parts[count++] = jbed_emitter_usage(e);
        error.class_id = e->import_class;
        error.member_id = e->import_method;
        break;
    }
    error.message = join(e, parts, count);
    return error;
}

static _Noreturn void raise_diagnostic(JbedEmitter *e, JbedEmitterDiagnostic diagnostic,
                                       JbedTypeId type, JbedNameId member,
                                       JbedSignatureId signature, int32_t reason)
{
    JbedError error = jbed_emitter_error(e, diagnostic, type, member, signature, reason);
    jbed_raise(e->runtime, &error);
}
_Noreturn void jbed_emitter_class_format(JbedEmitter *e)
{
    raise_diagnostic(e, JBED_EMITTER_CLASS_FORMAT, 0, 0, 0, 0);
}
_Noreturn void jbed_emitter_no_class(JbedEmitter *e, JbedTypeId type)
{
    raise_diagnostic(e, JBED_EMITTER_NO_CLASS, type, 0, 0, 0);
}
_Noreturn void jbed_emitter_no_method(JbedEmitter *e, JbedTypeId type, JbedNameId member,
                                      JbedSignatureId signature)
{
    raise_diagnostic(e, JBED_EMITTER_NO_METHOD, type, member, signature, 0);
}
_Noreturn void jbed_emitter_no_field(JbedEmitter *e, JbedTypeId type, JbedNameId member)
{
    raise_diagnostic(e, JBED_EMITTER_NO_FIELD, type, member, 0, 0);
}
_Noreturn void jbed_emitter_incompatible_class(JbedEmitter *e, JbedTypeId type)
{
    raise_diagnostic(e, JBED_EMITTER_INCOMPATIBLE_CLASS, type, 0, 0, 0);
}
_Noreturn void jbed_emitter_class_circularity(JbedEmitter *e, JbedTypeId type)
{
    raise_diagnostic(e, JBED_EMITTER_CLASS_CIRCULARITY, type, 0, 0, 0);
}
_Noreturn void jbed_emitter_abstract_method(JbedEmitter *e, JbedTypeId type, JbedNameId member,
                                            JbedSignatureId signature)
{
    raise_diagnostic(e, JBED_EMITTER_ABSTRACT_METHOD, type, member, signature, 0);
}
_Noreturn void jbed_emitter_verify(JbedEmitter *e)
{
    raise_diagnostic(e, JBED_EMITTER_VERIFY, 0, 0, 0, 0);
}
_Noreturn void jbed_emitter_verify_at(JbedEmitter *e, int32_t reason)
{
    raise_diagnostic(e, JBED_EMITTER_VERIFY_AT, 0, 0, 0, reason);
}
