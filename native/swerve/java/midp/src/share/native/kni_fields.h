#ifndef JBED_SWERVE_KNI_FIELDS_H
#define JBED_SWERVE_KNI_FIELDS_H
#include "kni.h"

typedef uint32_t FieldId;

enum KniFieldKind {
    KNI_FIELD_REFERENCE = 2,
    KNI_FIELD_BOOLEAN = 4,
    KNI_FIELD_INT = 10
};

extern FieldId JbedKNI_GetFieldAddress(JbRef klass, const char *name, const char *descriptor, int flags);
extern void *JbedKNI_VerifyField(JbRef object, FieldId field, int kind, JbRef value);

static inline FieldId find_field(JbRef klass, const char *name, const char *signature, int flags)
{
    return JbedKNI_GetFieldAddress(JbedKNI_VerifyObject(klass, 'c'), name, signature, flags);
}
#endif
