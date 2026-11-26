#ifndef JBED_COMPILER_SIGNATURES_H
#define JBED_COMPILER_SIGNATURES_H

#include "reflection_table.h"

/* Nibble tags 4..11 use the VM primitive type IDs directly. */
enum {
    JBED_SIGNATURE_OBJECT = 0,
    JBED_SIGNATURE_STRING = 1,
    JBED_SIGNATURE_INT_ARRAY = 2,
    JBED_SIGNATURE_BYTE_ARRAY = 3,
    JBED_SIGNATURE_CHAR_ARRAY = 12,
    JBED_SIGNATURE_VOID = 13,
    JBED_SIGNATURE_END = 14,
    JBED_SIGNATURE_CLASS_ID = 15
};

typedef struct JbedSignatureTypes {
    JbedTypeId object, string, int_array, byte_array, char_array;
} JbedSignatureTypes;

/* ReflectionTable and ClassAccess are VM-owned. Their IDs and byte encoding
 * are preserved; the signature encoder itself owns nibble packing. */
typedef struct JbedSignatureServices {
    JbedRuntime *runtime;
    void *context;
    JbedReflectionTable *reflection_table;
    JbedSignatureTypes types;
    JbedSignatureId (*intern)(void *, const uint8_t *, size_t);
    int32_t (*fetch)(void *, JbedSignatureId, uint8_t *, size_t);
    JbedTypeId (*class_id)(void *, const uint8_t *, uint32_t, uint32_t, uint32_t, uint32_t);
    JbedTypeId (*primitive_array_id)(void *, JbedTypeId, uint32_t);
    /* Returns NULL for an unresolved ID. Arrays return their descriptor name;
     * other classes return the same name as java.lang.Class.getName(). */
    const char *(*class_name)(void *, JbedTypeId, bool *is_array);
    JbedClassAccess *class_access;
} JbedSignatureServices;

typedef struct JbedSignatureEncoder {
    const JbedSignatureServices *services;
    uint8_t *bytes;
    int32_t byte_count;
    bool high_nibble, added_void;
    int32_t current_id;
    uint32_t nibble_index;
} JbedSignatureEncoder;

typedef struct JbedSignatureArguments {
    JbedTypeId *parameters;
    size_t count, capacity;
    JbedTypeId result;
} JbedSignatureArguments;

void jbed_signature_unpack(JbedSignatureEncoder *, JbedSignatureId, JbedSignatureArguments *);
JbedSignatureTypes jbed_signature_rom_types(void);
JbedReflectionTable *jbed_signature_table(const JbedSignatureEncoder *);
void jbed_signature_init(JbedSignatureEncoder *, const JbedSignatureServices *);
JbedSignatureEncoder *jbed_signature_copy_if_busy(JbedSignatureEncoder *);
uint8_t *jbed_signature_buffer(JbedSignatureEncoder *);
void jbed_signature_start(JbedSignatureEncoder *);
void jbed_signature_add_short(JbedSignatureEncoder *, int32_t);
void jbed_signature_add_class_id(JbedSignatureEncoder *, JbedTypeId);
void jbed_signature_add_long_class_id(JbedSignatureEncoder *, JbedTypeId);
void jbed_signature_add_void(JbedSignatureEncoder *);
void jbed_signature_add_primitive(JbedSignatureEncoder *, JbedTypeId);
void jbed_signature_add_primitive_array(JbedSignatureEncoder *, uint32_t dimensions, JbedTypeId);
void jbed_signature_add_class_type(JbedSignatureEncoder *, const uint8_t *, uint32_t, uint32_t,
                                   uint32_t, uint32_t);
JbedSignatureId jbed_signature_finish(JbedSignatureEncoder *);
bool jbed_signature_returns_void(const JbedSignatureEncoder *);
void jbed_signature_discard(JbedSignatureEncoder *);
void jbed_signature_open(JbedSignatureEncoder *, JbedSignatureId);
JbedTypeId jbed_signature_next(JbedSignatureEncoder *);
void jbed_signature_close(JbedSignatureEncoder *, JbedSignatureId);
char *jbed_signature_descriptor(JbedSignatureEncoder *, JbedSignatureId);

/* Typed adapter for Pool.signature_id. Arguments precede the return type in
 * the original encoding; decoded void is zero, and end-of-signature is 14. */
JbedSignatureId jbed_signature_build_types(JbedSignatureEncoder *, const JbedTypeId *,
                                           size_t argument_count, JbedTypeId return_type,
                                           bool returns_void);

#endif
