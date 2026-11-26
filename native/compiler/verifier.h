#ifndef JBED_COMPILER_VERIFIER_H
#define JBED_COMPILER_VERIFIER_H

#include "model.h"
#include "runtime.h"
#include "signatures.h"
#include "emitter.h"

/* A VerifierUtil frame is an int[]. Class keys and NEW instruction addresses
 * share these words with the small ITEM_* values from the classfile verifier. */
typedef uint32_t JbedVerifyType;
enum {
    JBED_V_TOP = 0,
    JBED_V_INT = 1,
    JBED_V_FLOAT = 2,
    JBED_V_DOUBLE = 3,
    JBED_V_LONG = 4,
    JBED_V_NULL = 5,
    JBED_V_UNINITIALIZED_THIS = 6,
    JBED_V_LONG_HIGH = 9,
    JBED_V_DOUBLE_HIGH = 10,
    JBED_V_ANY_REFERENCE = 14
};

typedef struct JbedVerifierMemberReference {
    /* Pool.values[index]: class index in the high half, name/type in the low. */
    uint16_t class_index;
    uint16_t name_and_type_index;
} JbedVerifierMemberReference;

/* Resolution retains Pool/ClassAccess behavior, including deferred-error
 * members. Callbacks raise through JbedRuntime on exceptions; returned records
 * and signatures remain owned by the host. No callback may silently substitute
 * an unresolved class/member with a successfully resolved one. */
typedef struct JbedVerifierServices {
    void *context;
    JbedEmitter *emitter;
    JbedClass *(*class_object)(void *, JbedTypeId);
    bool (*class_assignable)(void *, JbedClass *destination, JbedClass *source);
    JbedTypeId (*array_of_class)(void *, JbedTypeId);
    int32_t (*array_level)(void *, JbedTypeId);
    bool (*same_package)(void *, JbedClass *, JbedClass *);
    JbedSignatureEncoder *signature_encoder;
    uint8_t (*name_first_byte)(void *, JbedNameId);

    size_t (*pool_size)(void *, JbedPool *);
    uint8_t (*pool_tag)(void *, JbedPool *, uint16_t);
    JbedTypeId (*pool_class_id)(void *, JbedPool *, uint16_t);
    JbedClass *(*pool_class_object)(void *, JbedPool *, uint16_t, bool allow_missing);
    JbedVerifierMemberReference (*pool_member_reference)(void *, JbedPool *, uint16_t);
    JbedTypeId (*pool_field_type)(void *, JbedPool *, uint16_t name_and_type);
    JbedSignatureId (*pool_signature)(void *, JbedPool *, uint16_t name_and_type);
    JbedNameId (*pool_name)(void *, JbedPool *, uint16_t name_and_type);
    JbedField *(*pool_field)(void *, JbedPool *, uint16_t, uint32_t expected_flags);
    JbedMethod *(*pool_method)(void *, JbedPool *, uint16_t, uint32_t expected_flags);
} JbedVerifierServices;

typedef struct JbedVerifier {
    JbedRuntime *runtime;
    const JbedVerifierServices *services;
    JbedMethod *method;
    JbedPool *pool;
    JbedVerifyType result_type, act_type, callee_result;
    JbedSignatureId callee_signature;
    JbedVerifyType *stack, *locals;
    size_t stack_capacity, local_capacity, stack_depth;
    uint32_t *new_instructions;
    size_t new_capacity;
    bool *map_seen;
    size_t map_capacity;
    bool uninitialized_this, local_zero_written, map_uninitialized_this;
    int32_t local_weights[32], weight;
    int32_t pc;
    JbedSignatureEncoder *sig_enc;
} JbedVerifier;

void jbed_verifier_init(JbedVerifier *, JbedRuntime *, const JbedVerifierServices *);
/* Input records come from Reader/Pool. Code lengths fit a Java int. Operand
 * fetches retain the ROM's unchecked-load contract: code storage must contain
 * each operand that the walk reads, including when exercising malformed code.
 * The final length check uses code_length, independently of that storage. */
void jbed_verifier_verify_class(JbedVerifier *, JbedClass *);
void jbed_verifier_verify_method(JbedVerifier *, JbedMethod *);
bool jbed_verifier_assignable(JbedVerifier *, JbedVerifyType source, JbedVerifyType destination);

#endif
