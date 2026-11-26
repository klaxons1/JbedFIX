#include "verifier.h"
#include "bytecode.h"
#include "vm_types.h"
#include "class_access.h"

#include <limits.h>
#include <string.h>

enum {
    MAP_CHECK = 1,
    MAP_LOAD = 2,
    MAP_REQUIRED = 4,
    MAP_BACKWARD = 8
};

enum {
    VE_STACK_OVERFLOW = 1,
    VE_STACK_UNDERFLOW = 2,
    VE_STACK_EXPECT_CAT1 = 3,
    VE_STACK_BAD_TYPE = 4,
    VE_LOCALS_OVERFLOW = 5,
    VE_LOCALS_BAD_TYPE = 6,
    VE_LOCALS_UNDERFLOW = 7,
    VE_TARGET_BAD_TYPE = 8,
    VE_BACK_BRANCH_UNINIT = 9,
    VE_SEQ_BAD_TYPE = 10,
    VE_EXPECT_CLASS = 11,
    VE_EXPECT_THROWABLE = 12,
    VE_BAD_LOOKUPSWITCH = 13,
    VE_BAD_LDC = 14,
    VE_BALOAD_BAD_TYPE = 15,
    VE_AALOAD_BAD_TYPE = 16,
    VE_BASTORE_BAD_TYPE = 17,
    VE_AASTORE_BAD_TYPE = 18,
    VE_EXPECT_METHODREF = 20,
    VE_EXPECT_INVOKESPECIAL = 23,
    VE_EXPECT_NEW = 24,
    VE_EXPECT_UNINIT = 25,
    VE_BAD_INSTR = 26,
    VE_EXPECT_ARRAY = 27,
    VE_MULTIANEWARRAY = 28,
    VE_EXPECT_NO_RETVAL = 29,
    VE_RETVAL_BAD_TYPE = 30,
    VE_EXPECT_RETVAL = 31,
    VE_RETURN_UNINIT_THIS = 32,
    VE_BAD_STACKMAP = 33,
    VE_FALL_THROUGH = 34,
    VE_EXPECT_ZERO = 35,
    VE_NARGS_MISMATCH = 36,
    VE_INVOKESPECIAL = 37,
    VE_BAD_INIT_CALL = 38,
    VE_EXPECT_FIELDREF = 39,
    VE_MIDDLE_OF_BYTE_CODE = 41,
    VE_BAD_NEW_OFFSET = 42,
    VE_BAD_EXCEPTION_HANDLER_RANGE = 43,
    VE_EXPECTING_OBJ_OR_ARR_ON_STK = 44
};

/* Vfy_toVerifierType, 0x180f68. */
static JbedVerifyType reference(JbedTypeId id)
{
    return id ? id : JBED_V_NULL;
}

static bool has_class_key(JbedVerifyType value)
{
    return (value >> 4) != 0;
}

static bool is_new(JbedVerifyType value)
{
    return (value >> 16) == 0xfffd;
}

static _Noreturn void fail(JbedVerifier *v, JbedErrorKind kind, uint32_t detail,
                           const char *message)
{
    JbedError error = {0};
    error.kind = kind;
    error.is_java_error = kind != JBED_ERROR_RUNTIME_EXCEPTION && kind != JBED_ERROR_NULL_POINTER &&
                          kind != JBED_ERROR_ARRAY_INDEX;
    error.class_id = v->method && v->method->owner ? v->method->owner->id : 0;
    error.member_id = v->method ? v->method->name_id : 0;
    error.bytecode_offset = v->pc;
    error.detail_code = detail;
    error.message = message;
    jbed_raise(v->runtime, &error);
}

static _Noreturn void verify_error(JbedVerifier *v, unsigned reason)
{
    /* The named throwVerifyError(int) at 0x148938 actually constructs a
     * NoClassDefFoundError. Its integer is a verifier reason, not a PC. */
    jbed_emitter_verify_at(v->services->emitter, (int32_t)reason);
}

static _Noreturn void index_error(JbedVerifier *v)
{
    fail(v, JBED_ERROR_ARRAY_INDEX, 0, NULL);
}

static void *allocate_array(JbedVerifier *v, size_t count, size_t element_size)
{
    if (count > SIZE_MAX / element_size)
        fail(v, JBED_ERROR_OUT_OF_MEMORY, 0, "Verifier array is too large");
    return jbed_alloc(v->runtime, count * element_size);
}

/* Java int arithmetic is defined modulo 2^32, including profiling weights. */
static int32_t signed_word(uint32_t value)
{
    return value <= INT32_MAX ? (int32_t)value : -1 - (int32_t)(UINT32_MAX - value);
}

static int32_t add_int(int32_t a, int32_t b)
{
    return signed_word((uint32_t)a + (uint32_t)b);
}

static int32_t shift_right_three(int32_t value)
{
    return value >= 0 ? value / 8 : -1 - (int32_t)((uint32_t)(-1 - value) / 8);
}

/* Vfy_createVerifierTypeForNewAt/isVerifierTypeForNew/retrieveIpForNew,
 * 0x180efa/0x180f28/0x180f3c. The original packed NEW marker is 0xfffd0000|PC. */
static JbedVerifyType new_type(JbedVerifier *v, uint32_t pc)
{
    if (pc > UINT16_MAX)
        jbed_halt(v->runtime, 0, "IP > 16 bits in Vfy_createVerifierTypeForNewAt");
    return UINT32_C(0xfffd0000) | pc;
}

static JbedClassAccess *class_access(JbedVerifier *v)
{
    if (!v->pool || !v->pool->services->class_access)
        jbed_raise_internal(v->runtime, "Missing verifier class access");
    return v->pool->services->class_access;
}

static JbedClass *class_object(JbedVerifier *v, JbedTypeId id)
{
    if (v->services->class_object)
        return v->services->class_object(v->services->context, id);
    return jbed_class_object(class_access(v), id);
}

/* typeIdToVerifierType, 0x180d00. */
static JbedVerifyType signature_type(JbedVerifier *v, JbedTypeId id)
{
    switch (id) {
    case UINT32_C(0xffff8000):
        return JBED_V_NULL;
    case 4:
    case 5:
    case 8:
    case 9:
    case 10:
        return JBED_V_INT;
    case 6:
        return JBED_V_FLOAT;
    case 7:
        return JBED_V_DOUBLE;
    case 11:
        return JBED_V_LONG;
    default: {
        JbedClass *klass = class_object(v, id);
        return klass && klass->instance_size < 0 ? JBED_V_NULL : reference(id);
    }
    }
}

/* Vfy_isAssignable, 0x180fe4. Interfaces deliberately accept every initialized
 * class reference; the original leaves their runtime check to dispatch. */
bool jbed_verifier_assignable(JbedVerifier *v, JbedVerifyType source, JbedVerifyType destination)
{
    if (source == destination || destination == JBED_V_TOP)
        return true;
    if (destination == JBED_V_ANY_REFERENCE)
        return source == JBED_V_NULL || source == JBED_V_UNINITIALIZED_THIS ||
               has_class_key(source);
    if (!has_class_key(destination) || is_new(destination))
        return false;
    if (source == JBED_V_NULL)
        return true;
    if (!has_class_key(source) || is_new(source))
        return false;
    if (destination == JBED_ROM_CLASS_OBJECT)
        return true;
    JbedClass *to = class_object(v, destination);
    if (!to)
        return false;
    if (to->flags & JBED_ACC_INTERFACE)
        return true;
    JbedClass *from = class_object(v, source);
    return from && (v->services->class_assignable
                        ? v->services->class_assignable(v->services->context, to, from)
                        : jbed_vm_assignable(to, from));
}

/* Vfy_toClassKey, 0x180f76. */
static JbedTypeId class_key(JbedVerifier *v, JbedVerifyType value)
{
    if (has_class_key(value))
        return value;
    fail(v, JBED_ERROR_RUNTIME_EXCEPTION, 0, NULL);
}

/* Vfy_isArrayClassKey, 0x180eba. */
static bool array_dimensions(JbedVerifier *v, JbedTypeId id, unsigned count)
{
    JbedClass *klass = class_object(v, id);
    while (count--) {
        if (!klass || !(klass->flags & JBED_CLASS_ARRAY))
            return false;
        klass = klass->superclass;
    }
    return true;
}

/* Vfy_isArray, 0x180fa4. */
static bool is_array(JbedVerifier *v, JbedVerifyType value)
{
    if (!has_class_key(value))
        return false;
    JbedTypeId id = class_key(v, value);
    return v->services->array_level ? v->services->array_level(v->services->context, id) > 0
                                    : jbed_class_params(class_access(v), id).dimensions > 0;
}

/* Vfy_getReferenceArrayElementType, 0x180e6a. */
static JbedVerifyType array_element(JbedVerifier *v, JbedVerifyType value)
{
    if (value == JBED_V_NULL)
        return value;
    JbedClass *klass = class_object(v, class_key(v, value));
    if (!klass || !klass->superclass)
        fail(v, JBED_ERROR_NULL_POINTER, 0, NULL);
    return reference(klass->superclass->id);
}

/* Pol_getTag/checkTagIs/checkTag2Is/checkTagIsClass,
 * 0x181da8/0x181de8/0x181e36/0x181e8a. */
static unsigned pool_tag(JbedVerifier *v, uint16_t index)
{
    const JbedVerifierServices *s = v->services;
    size_t count = s->pool_size ? s->pool_size(s->context, v->pool) : v->pool->count;
    if (index >= count)
        verify_error(v, 120);
    return (s->pool_tag ? s->pool_tag(s->context, v->pool, index) : v->pool->tags[index]) & 15;
}

static void require_tag(JbedVerifier *v, uint16_t index, unsigned tag, unsigned reason)
{
    if (pool_tag(v, index) != tag)
        verify_error(v, reason);
}

/* Pol_getClassKey, 0x181eb0. */
static JbedTypeId pool_class_id(JbedVerifier *v, uint16_t index)
{
    if (v->services->pool_class_id)
        return v->services->pool_class_id(v->services->context, v->pool, index);
    JbedTypeId id;
    JbedError error;
    if (!jbed_pool_class_id(v->pool, index, &id, &error))
        jbed_raise(v->runtime, &error);
    return id;
}

static JbedVerifierMemberReference member_reference(JbedVerifier *v, uint16_t index)
{
    if (v->services->pool_member_reference)
        return v->services->pool_member_reference(v->services->context, v->pool, index);
    if (index >= v->pool->count)
        index_error(v);
    uint32_t word = v->pool->values[index];
    return (JbedVerifierMemberReference){(uint16_t)(word >> 16), (uint16_t)word};
}

static JbedField *pool_field(JbedVerifier *v, uint16_t index)
{
    if (v->services->pool_field)
        return v->services->pool_field(v->services->context, v->pool, index, 0);
    JbedField *field;
    JbedError error;
    if (!jbed_pool_field(v->pool, index, 0, &field, &error))
        jbed_raise(v->runtime, &error);
    return field;
}

static bool same_package(JbedVerifier *v, JbedClass *owner)
{
    if (v->services->same_package)
        return v->services->same_package(v->services->context, owner, v->method->owner);
    bool same;
    JbedError error;
    if (!jbed_pool_same_package(v->pool, owner, v->method->owner, &same, &error))
        jbed_raise(v->runtime, &error);
    return same;
}

/* Vfy_isProtectedField/Method, 0x1810b4/0x1810f4; Pol_getField, 0x181ed2. */
static bool protected_field(JbedVerifier *v, uint16_t index)
{
    JbedField *field = pool_field(v, index);
    return (field->flags & JBED_ACC_PROTECTED) && !same_package(v, field->owner) &&
        !jbed_pool_trusted_access(v->pool, v->method->owner, field->owner);
}

static bool protected_method(JbedVerifier *v, uint16_t index)
{
    JbedMethod *method;
    JbedError error;
    if (v->services->pool_method)
        method = v->services->pool_method(v->services->context, v->pool, index, 0);
    else if (!jbed_pool_method(v->pool, index, 0, &method, &error))
        jbed_raise(v->runtime, &error);
    return (method->flags & JBED_ACC_PROTECTED) && !same_package(v, method->owner) &&
        !jbed_pool_trusted_access(v->pool, v->method->owner, method->owner);
}

/* Vfy_getUByte/getShort/getUShort/getCell, 0x180dda/0x180de6/0x180dfe/0x180e14.
 * These are unchecked native loads in the ROM. The caller must provide
 * readable storage for each fetched operand. The code-length check remains
 * at the end of verify_bytecode, in its original position. */
static uint8_t byte_at(JbedVerifier *v, int32_t pc)
{
    return v->method->code[pc];
}

static uint16_t ushort_at(JbedVerifier *v, int32_t pc)
{
    uint16_t high = byte_at(v, pc);
    return (uint16_t)((high << 8) | byte_at(v, add_int(pc, 1)));
}

static int32_t short_at(JbedVerifier *v, int32_t pc)
{
    uint16_t word = ushort_at(v, pc);
    return word < 0x8000 ? word : (int32_t)word - 0x10000;
}

static int32_t cell_at(JbedVerifier *v, int32_t pc)
{
    uint32_t high = ushort_at(v, pc);
    return signed_word((high << 16) | ushort_at(v, add_int(pc, 2)));
}

static uint32_t map_word(JbedVerifier *v, size_t index)
{
    if (index >= v->method->stack_maps.word_count)
        index_error(v);
    return v->method->stack_maps.words[index];
}

/* match, 0x181134. Maps count logical values; local/operand arrays count words. */
static size_t match_vector(JbedVerifier *v, JbedVerifyType *slots, size_t capacity, uint32_t offset,
                           unsigned mode, unsigned reason)
{
    if (!offset)
        return 0;
    unsigned remaining = map_word(v, offset);
    size_t cursor = (size_t)offset + 1, words = 0;
    JbedVerifyType value = JBED_V_TOP;
    for (;;) {
        if (value == JBED_V_LONG)
            value = JBED_V_LONG_HIGH;
        else if (value == JBED_V_DOUBLE)
            value = JBED_V_DOUBLE_HIGH;
        else {
            if (!remaining)
                return words;
            --remaining;
            uint16_t token = map_word(v, cursor++);
            if (token >= 0x8000)
                value = new_type(v, token & 0x7fff);
            else if (token < 7) {
                value = token;
                if (value == JBED_V_UNINITIALIZED_THIS)
                    v->map_uninitialized_this = true;
            } else {
                uint16_t index = (uint16_t)(token - 7);
                require_tag(v, index, JBED_POOL_CLASS, VE_EXPECT_CLASS);
                value = reference(pool_class_id(v, index));
            }
        }
        if (words >= capacity)
            index_error(v);
        if ((mode & MAP_CHECK) && !jbed_verifier_assignable(v, slots[words], value))
            verify_error(v, reason);
        if (mode & MAP_LOAD)
            slots[words] = value;
        ++words;
    }
}

/* Vfy_matchStackMap, 0x18127c. Loading a map does not mark it seen; matching a
 * branch does. This distinction drives the original loop-weight heuristic. */
static void match_map(JbedVerifier *v, int32_t pc, unsigned mode, unsigned reason)
{
    if (!v->method->stack_maps.words) {
        if (mode & MAP_REQUIRED)
            verify_error(v, reason);
        return;
    }
    int count = map_word(v, 0), lo = 0, hi = count - 1;
    while (lo < hi) {
        int mid = (lo + hi) / 2;
        if (pc <= (int32_t)map_word(v, mid + 1))
            hi = mid;
        else
            lo = mid + 1;
    }
    if (lo == count || pc != (int32_t)map_word(v, lo + 1)) {
        if (mode & MAP_REQUIRED)
            verify_error(v, reason);
        return;
    }
    v->map_uninitialized_this = false;
    size_t locals = match_vector(v, v->locals, v->local_capacity, map_word(v, count + 1 + 2 * lo),
                                 mode, reason);
    size_t stack =
        match_vector(v, v->stack, v->stack_capacity, map_word(v, count + 2 + 2 * lo), mode, reason);
    if ((mode & MAP_CHECK) &&
        (stack != v->stack_depth || (v->uninitialized_this && !v->map_uninitialized_this)))
        verify_error(v, reason);
    if (mode & MAP_LOAD) {
        v->stack_depth = stack;
        v->uninitialized_this = v->map_uninitialized_this;
        for (size_t i = locals; i < v->method->max_locals; ++i)
            v->locals[i] = JBED_V_TOP;
        if (!v->map_seen[lo])
            v->weight = signed_word(8u * (uint32_t)v->weight + 1u);
    } else {
        if ((mode & MAP_BACKWARD) && !v->map_seen[lo])
            v->weight = shift_right_three(v->weight);
        v->map_seen[lo] = true;
    }
}

/* Vfy_checkJumpTarget, 0x181454. Only NEW values are forbidden on backward
 * edges; uninitialized-this is governed by constructor/map checks instead. */
static void jump_target(JbedVerifier *v, int32_t from, int32_t to)
{
    bool backward = to < from;
    match_map(v, to, MAP_CHECK | MAP_REQUIRED | (backward ? MAP_BACKWARD : 0), VE_TARGET_BAD_TYPE);
    if (backward) {
        for (size_t i = 0; i < v->method->max_locals; ++i)
            if (is_new(v->locals[i]))
                verify_error(v, VE_BACK_BRANCH_UNINIT);
        for (size_t i = 0; i < v->stack_depth; ++i)
            if (is_new(v->stack[i]))
                verify_error(v, VE_BACK_BRANCH_UNINIT);
    }
}

/* Vfy_getLocal/Vfy_setLocal, 0x181524/0x18159e. Overwriting either half of a
 * two-word local invalidates its partner before writing the new value. */
static JbedVerifyType get_local(JbedVerifier *v, uint32_t index, JbedVerifyType expected)
{
    if (index >= v->method->max_locals)
        verify_error(v, VE_LOCALS_OVERFLOW);
    JbedVerifyType value = v->locals[index];
    if (!jbed_verifier_assignable(v, value, expected))
        verify_error(v, VE_LOCALS_BAD_TYPE);
    if (index < 32)
        v->local_weights[index] = add_int(v->local_weights[index], v->weight);
    return value;
}

static void set_local(JbedVerifier *v, uint32_t index, JbedVerifyType value)
{
    if (!index)
        v->local_zero_written = true;
    if (index >= v->method->max_locals)
        verify_error(v, VE_LOCALS_OVERFLOW);
    switch (v->locals[index]) {
    case JBED_V_LONG:
    case JBED_V_DOUBLE:
        if (index + 1 >= v->method->max_locals)
            verify_error(v, VE_LOCALS_OVERFLOW);
        v->locals[index + 1] = JBED_V_TOP;
        break;
    case JBED_V_LONG_HIGH:
    case JBED_V_DOUBLE_HIGH:
        if (!index)
            verify_error(v, VE_LOCALS_UNDERFLOW);
        v->locals[index - 1] = JBED_V_TOP;
        break;
    default:
        break;
    }
    v->locals[index] = value;
    if (index < 32)
        v->local_weights[index] = add_int(v->local_weights[index], v->weight);
}

/* setLocalCount, 0x18166c: three base-32 local indices, followed by a stop bit. */
static void set_local_hint(JbedVerifier *v)
{
    unsigned candidates = v->method->max_locals < 32 ? v->method->max_locals : 32;
    unsigned selected = v->method->max_locals < 3 ? v->method->max_locals : 3;
    uint32_t encoded = 0, scale = 1;
    while (selected--) {
        int32_t best_weight = -1;
        unsigned best = 0;
        for (unsigned i = 0; i < candidates; ++i) {
            if (v->local_weights[i] > best_weight) {
                best_weight = v->local_weights[i];
                best = i;
            }
        }
        encoded += best * scale;
        scale *= 32;
        v->local_weights[best] = -1;
    }
    v->method->local_hint = (uint16_t)(encoded + scale);
}

/* Vfy_push/pop/popCategory1, 0x181718/0x181760/0x1817b4. */
static void push(JbedVerifier *v, JbedVerifyType value)
{
    if (v->stack_depth >= v->method->max_stack)
        verify_error(v, VE_STACK_OVERFLOW);
    v->stack[v->stack_depth++] = value;
}

static JbedVerifyType pop(JbedVerifier *v, JbedVerifyType expected)
{
    if (!v->stack_depth)
        verify_error(v, VE_STACK_UNDERFLOW);
    JbedVerifyType value = v->stack[--v->stack_depth];
    if (!jbed_verifier_assignable(v, value, expected))
        verify_error(v, VE_STACK_BAD_TYPE);
    return value;
}

static JbedVerifyType pop_category_one(JbedVerifier *v)
{
    if (!v->stack_depth)
        verify_error(v, VE_STACK_UNDERFLOW);
    JbedVerifyType value = v->stack[--v->stack_depth];
    if (value != JBED_V_INT && value != JBED_V_NULL && value != JBED_V_FLOAT &&
        value != JBED_V_UNINITIALIZED_THIS && !has_class_key(value))
        verify_error(v, VE_STACK_EXPECT_CAT1);
    return value;
}

/* Vfy_popCategory2_secondWord/firstWord, 0x181848/0x18180a.
 * These operate on two words, accepting either one category-2 or two
 * category-1 values. The ROM tests only that the lower word is not a high half. */
static JbedVerifyType pop_pair_high(JbedVerifier *v)
{
    if (v->stack_depth <= 1)
        verify_error(v, VE_STACK_UNDERFLOW);
    return v->stack[--v->stack_depth];
}

static JbedVerifyType pop_pair_low(JbedVerifier *v)
{
    if (!v->stack_depth)
        index_error(v);
    JbedVerifyType value = v->stack[--v->stack_depth];
    if (value == JBED_V_LONG_HIGH || value == JBED_V_DOUBLE_HIGH)
        verify_error(v, VE_STACK_EXPECT_CAT1);
    return value;
}

static void push_value(JbedVerifier *v, JbedVerifyType value)
{
    push(v, value);
    if (value == JBED_V_LONG)
        push(v, JBED_V_LONG_HIGH);
    if (value == JBED_V_DOUBLE)
        push(v, JBED_V_DOUBLE_HIGH);
}

static JbedVerifyType pop_value(JbedVerifier *v, JbedVerifyType value)
{
    if (value == JBED_V_LONG)
        pop(v, JBED_V_LONG_HIGH);
    if (value == JBED_V_DOUBLE)
        pop(v, JBED_V_DOUBLE_HIGH);
    return pop(v, value);
}

/* VerifierUtil.Vfy_pushClassKey and Vfy_popClassKey, 0x1818fc/0x18193c. */
static void Vfy_pushClassKey(JbedVerifier *v, JbedTypeId id)
{
    v->act_type = signature_type(v, id);
    push_value(v, v->act_type);
}

static void Vfy_popClassKey(JbedVerifier *v, JbedTypeId id)
{
    v->act_type = signature_type(v, id);
    pop_value(v, v->act_type);
}

/* Vfy_popReturn/returnVoid, 0x1818c4/0x181882. */
static void Vfy_popReturn(JbedVerifier *v, JbedVerifyType expected)
{
    JbedVerifyType value = pop(v, expected);
    if (v->result_type == JBED_V_TOP)
        verify_error(v, VE_EXPECT_NO_RETVAL);
    if (!jbed_verifier_assignable(v, value, v->result_type))
        verify_error(v, VE_RETVAL_BAD_TYPE);
}

static void Vfy_returnVoid(JbedVerifier *v)
{
    if (v->result_type != JBED_V_TOP)
        verify_error(v, VE_EXPECT_RETVAL);
    if (v->method->name_id == JBED_NAME_INIT && v->uninitialized_this)
        verify_error(v, VE_RETURN_UNINIT_THIS);
}

/* Vfy_MethodNameIsInit/StartsWithLeftAngleBracket, 0x181a9c/0x181a54. */
static bool constructor_name(JbedVerifier *v, JbedNameId name)
{
    if (name == JBED_NAME_INIT)
        return true;
    int first;
    if (v->services->name_first_byte)
        first = v->services->name_first_byte(v->services->context, name);
    else {
        if (!v->pool || !v->pool->services->method_names)
            jbed_raise_internal(v->runtime, "Missing verifier method name table");
        first = jbed_reflection_first_byte(v->pool->services->method_names, name);
    }
    if (first == '<')
        jbed_halt(v->runtime, 0, "Found method name starting with < which is NOT <init>");
    return false;
}

/* These three VerifierUtil methods each close sigEnc in a Throwable handler.
 * It remains busy during class resolution and operand validation. */
static void with_signature(JbedVerifier *v, JbedSignatureId id,
                           void (*body)(void *), void *state)
{
    if (!v->sig_enc)
        fail(v, JBED_ERROR_NULL_POINTER, 0, NULL);
    jbed_signature_open(v->sig_enc, id);
    JbedError caught;
    bool ok = v->runtime->protected_call(v->runtime->context, body, state, &caught);
    jbed_signature_close(v->sig_enc, id);
    if (!ok)
        jbed_raise(v->runtime, &caught);
}

/* VerifierUtil.getParams, 0x180d70. A terminal E marks the preceding type
 * as the result. A D sets actType to void and leaves every caller an argument. */
static bool getParams(JbedVerifier *v)
{
    JbedTypeId id = jbed_signature_next(v->sig_enc);
    if (!id) {
        v->act_type = JBED_V_TOP;
        return false;
    }
    if (id == JBED_SIGNATURE_END)
        return true;
    JbedVerifyType type = signature_type(v, id);
    if (getParams(v))
        v->act_type = type;
    else
        pop_value(v, type);
    return false;
}

static void read_invoke_arguments(void *state)
{
    getParams(state);
}

static void Vfy_setupCalleeContext(JbedVerifier *v, JbedSignatureId id)
{
    v->callee_signature = id;
    v->method->flags |= JBED_METHOD_NOT_LEAF;
}

/* 0x18199a, with its cleanup handler at 0x1819e8. */
static size_t Vfy_popInvokeArguments(JbedVerifier *v)
{
    size_t before = v->stack_depth;
    with_signature(v, v->callee_signature, read_invoke_arguments, v);
    v->callee_result = v->act_type;
    return before - v->stack_depth;
}

static void Vfy_pushInvokeResult(JbedVerifier *v)
{
    if (v->callee_result != JBED_V_TOP)
        push_value(v, v->callee_result);
}

/* Vfy_ReplaceTypeWithType, 0x181aac. */
static void replace_type(JbedVerifier *v, JbedVerifyType old, JbedVerifyType replacement)
{
    for (size_t i = 0; i < v->stack_depth; ++i)
        if (v->stack[i] == old)
            v->stack[i] = replacement;
    for (size_t i = 0; i < v->method->max_locals; ++i)
        if (v->locals[i] == old)
            v->locals[i] = replacement;
}

typedef struct InitializeLocals {
    JbedVerifier *v;
    size_t count;
} InitializeLocals;

static void read_local_signature(void *state)
{
    InitializeLocals *locals = state;
    JbedVerifier *v = locals->v;
    size_t count = locals->count;
    JbedVerifyType pending = JBED_V_TOP;
    for (;;) {
        JbedTypeId id = jbed_signature_next(v->sig_enc);
        if (id == JBED_SIGNATURE_END) {
            v->result_type = pending;
            break;
        }
        if (pending != JBED_V_TOP) {
            if (count < v->method->max_locals)
                v->locals[count] = pending;
            ++count;
            if (pending == JBED_V_LONG || pending == JBED_V_DOUBLE) {
                if (count < v->method->max_locals)
                    v->locals[count] = pending == JBED_V_LONG ? JBED_V_LONG_HIGH : JBED_V_DOUBLE_HIGH;
                ++count;
            }
        }
        if (!id) {
            v->result_type = JBED_V_TOP;
            break;
        }
        pending = signature_type(v, id);
    }
    locals->count = count;
}

/* VerifierUtil.Vfy_initializeLocals, 0x181b1a. */
static void Vfy_initializeLocals(JbedVerifier *v)
{
    InitializeLocals locals = {v, (v->method->flags & JBED_ACC_STATIC) ? 0 : 1};
    v->uninitialized_this = false;
    if (locals.count && v->method->max_locals) {
        v->uninitialized_this = v->method->name_id == JBED_NAME_INIT &&
                                v->method->owner->id != JBED_ROM_CLASS_OBJECT;
        v->locals[0] =
            v->uninitialized_this ? JBED_V_UNINITIALIZED_THIS : reference(v->method->owner->id);
    }
    with_signature(v, v->method->signature_id, read_local_signature, &locals);
    if (locals.count > 255 || locals.count > v->method->max_locals)
        jbed_emitter_class_format(v->services->emitter);
    while (locals.count < v->method->max_locals)
        v->locals[locals.count++] = JBED_V_TOP;
}

static void resolve_signature_types(void *state)
{
    JbedVerifier *v = state;
    JbedTypeId id;
    while ((id = jbed_signature_next(v->sig_enc)) != JBED_SIGNATURE_END && id)
        (void)signature_type(v, id);
}

/* VerifierUtil.Vfy_resolveSignature, 0x181d14. */
static void Vfy_resolveSignature(JbedVerifier *v, JbedMethod *method)
{
    with_signature(v, method->signature_id, resolve_signature_types, v);
}

/* initVerify, 0x181fee. Arrays retain their Java-object lifetime and capacity
 * across methods; map checks therefore use allocated capacities, as in ROM. */
static void initialize_method(JbedVerifier *v, JbedMethod *method)
{
    v->method = method;
    v->pool = method->owner->pool;
    v->local_zero_written = false;
    v->stack_depth = 0;
    v->pc = 0;
    if (v->stack_capacity < method->max_stack) {
        v->stack = allocate_array(v, method->max_stack, sizeof(*v->stack));
        v->stack_capacity = method->max_stack;
    }
    if (v->local_capacity < method->max_locals) {
        v->locals = allocate_array(v, method->max_locals, sizeof(*v->locals));
        v->local_capacity = method->max_locals;
    }
    size_t new_words = method->code_length / 32 + (method->code_length % 32 != 0);
    if (v->new_capacity < new_words) {
        v->new_instructions = allocate_array(v, new_words, sizeof(*v->new_instructions));
        v->new_capacity = new_words;
    }
    if (new_words)
        memset(v->new_instructions, 0, new_words * sizeof(*v->new_instructions));
    memset(v->local_weights, 0, sizeof(v->local_weights));
    if (method->stack_maps.words) {
        size_t count = map_word(v, 0);
        if (v->map_capacity < count) {
            v->map_seen = allocate_array(v, count, sizeof(*v->map_seen));
            v->map_capacity = count;
        }
        if (count)
            memset(v->map_seen, 0, count * sizeof(*v->map_seen));
    }
    v->weight = 1;
}

/* Vfy_markNewInstruction/checkNew, 0x1814ee/0x18214c. A map's NEW token must
 * name a NEW opcode actually visited by the instruction walk, not an operand. */
static void check_new_maps(JbedVerifier *v)
{
    if (!v->method->stack_maps.words)
        return;
    size_t count = map_word(v, 0);
    for (size_t i = count + 1; i <= 3 * count; ++i) {
        size_t offset = map_word(v, i);
        if (!offset)
            continue;
        unsigned entries = map_word(v, offset++);
        while (entries--) {
            uint16_t token = map_word(v, offset++);
            if (token < 0x8000)
                continue;
            uint32_t pc = token & 0x7fff;
            if (pc >= v->method->code_length ||
                !(v->new_instructions[pc >> 5] & (UINT32_C(1) << (pc & 31))))
                verify_error(v, VE_BAD_NEW_OFFSET);
        }
    }
}

/* Mth_getStackMapEntryIP/Mth_checkStackMapOffset, 0x181f5c/0x181f9c. */
static int32_t map_pc(JbedVerifier *v, size_t index)
{
    if (!v->method->stack_maps.words || index >= map_word(v, 0))
        return INT32_MAX;
    return map_word(v, index + 1);
}

static bool map_walk_complete(JbedVerifier *v, size_t index)
{
    return !v->method->stack_maps.words || index >= map_word(v, 0);
}

/* The following helpers structure the single opcode interpreter at 0x159532.
 * They are source-level groupings, not additional methods in the ROM. */
static void load_local(JbedVerifier *v, uint32_t index, JbedVerifyType expected)
{
    JbedVerifyType actual = get_local(v, index, expected);
    if (expected == JBED_V_LONG)
        get_local(v, index + 1, JBED_V_LONG_HIGH);
    if (expected == JBED_V_DOUBLE)
        get_local(v, index + 1, JBED_V_DOUBLE_HIGH);
    push_value(v, expected == JBED_V_ANY_REFERENCE ? actual : expected);
}

static void store_local(JbedVerifier *v, uint32_t index, JbedVerifyType expected)
{
    JbedVerifyType actual = pop_value(v, expected);
    /* Write the high half first, so replacing an overlapping old pair clears
     * it before either of the new pair's words is finalized. */
    if (expected == JBED_V_LONG)
        set_local(v, index + 1, JBED_V_LONG_HIGH);
    if (expected == JBED_V_DOUBLE)
        set_local(v, index + 1, JBED_V_DOUBLE_HIGH);
    set_local(v, index, expected == JBED_V_ANY_REFERENCE ? actual : expected);
}

static void stack_operation(JbedVerifier *v, unsigned opcode)
{
    JbedVerifyType a, b, c, d;
    switch (opcode) {
    case JBED_BC_POP:
        (void)pop_category_one(v);
        break;
    case JBED_BC_POP2:
        (void)pop_pair_high(v);
        (void)pop_pair_low(v);
        break;
    case JBED_BC_DUP:
        a = pop_category_one(v);
        push(v, a);
        push(v, a);
        break;
    case JBED_BC_DUP_X1:
        a = pop_category_one(v);
        b = pop_category_one(v);
        push(v, a);
        push(v, b);
        push(v, a);
        break;
    case JBED_BC_DUP_X2:
        a = pop_category_one(v);
        b = pop_pair_high(v);
        c = pop_pair_low(v);
        push(v, a);
        push(v, c);
        push(v, b);
        push(v, a);
        break;
    case JBED_BC_DUP2:
        a = pop_pair_high(v);
        b = pop_pair_low(v);
        push(v, b);
        push(v, a);
        push(v, b);
        push(v, a);
        break;
    case JBED_BC_DUP2_X1:
        a = pop_pair_high(v);
        b = pop_pair_low(v);
        c = pop_category_one(v);
        push(v, b);
        push(v, a);
        push(v, c);
        push(v, b);
        push(v, a);
        break;
    case JBED_BC_DUP2_X2:
        a = pop_pair_high(v);
        b = pop_pair_low(v);
        c = pop_pair_high(v);
        d = pop_pair_low(v);
        push(v, b);
        push(v, a);
        push(v, d);
        push(v, c);
        push(v, b);
        push(v, a);
        break;
    case JBED_BC_SWAP:
        a = pop_category_one(v);
        b = pop_category_one(v);
        push(v, a);
        push(v, b);
        break;
    default:
        jbed_raise_internal(v->runtime, "Invalid stack-operation dispatch");
    }
}

/* Array loads/stores, 0x159b7a..0x159cc8 and 0x159e32..0x159fba. */
static void array_operation(JbedVerifier *v, unsigned opcode, bool store)
{
    unsigned element = opcode - (store ? JBED_BC_IASTORE : JBED_BC_IALOAD);
    static const JbedVerifyType kinds[] = {JBED_V_INT,   JBED_V_LONG, JBED_V_FLOAT, JBED_V_DOUBLE,
                                           JBED_ROM_CLASS_OBJECT, JBED_V_INT,  JBED_V_INT,   JBED_V_INT};
    static const JbedTypeId arrays[] = {JBED_ROM_CLASS_INT_ARRAY,    JBED_ROM_CLASS_LONG_ARRAY,   JBED_ROM_CLASS_FLOAT_ARRAY, JBED_ROM_CLASS_DOUBLE_ARRAY,
                                        JBED_ROM_CLASS_OBJECT_ARRAY, JBED_ROM_CLASS_OBJECT, JBED_ROM_CLASS_CHAR_ARRAY,  JBED_ROM_CLASS_SHORT_ARRAY};
    JbedVerifyType value = kinds[element];
    if (store)
        value = pop_value(v, value);
    pop(v, JBED_V_INT);
    JbedVerifyType array = pop(v, element == 4 && !store ? JBED_ROM_CLASS_OBJECT : arrays[element]);
    if (element == 5) {
        if (array != JBED_ROM_CLASS_BYTE_ARRAY && array != JBED_ROM_CLASS_BOOLEAN_ARRAY && array != JBED_V_NULL)
            verify_error(v, store ? VE_BASTORE_BAD_TYPE : VE_BALOAD_BAD_TYPE);
    } else if (element == 4) {
        if (!jbed_verifier_assignable(v, array, JBED_ROM_CLASS_OBJECT_ARRAY))
            verify_error(v, store ? VE_AASTORE_BAD_TYPE : VE_AALOAD_BAD_TYPE);
        JbedVerifyType component = array_element(v, array);
        if (store) {
            if (!jbed_verifier_assignable(v, value, JBED_ROM_CLASS_OBJECT) ||
                ((is_array(v, component) || is_array(v, value)) &&
                 !jbed_verifier_assignable(v, value, component)))
                verify_error(v, VE_AASTORE_BAD_TYPE);
        } else
            value = component;
    }
    if (!store)
        push_value(v, value);
}

/* Field references, 0x15a7d2..0x15a8e2. */
static void field_operation(JbedVerifier *v, unsigned opcode, uint16_t index)
{
    require_tag(v, index, JBED_POOL_FIELDREF, VE_EXPECT_FIELDREF);
    JbedVerifierMemberReference member = member_reference(v, index);
    /* Pol_getFieldTypeKey, 0x181f18. */
    JbedTypeId field_type;
    JbedError error;
    if (v->services->pool_field_type)
        field_type = v->services->pool_field_type(v->services->context, v->pool,
                                                  member.name_and_type_index);
    else if (!jbed_pool_type_id(v->pool, member.name_and_type_index, &field_type, &error))
        jbed_raise(v->runtime, &error);
    if (opcode == JBED_BC_GETSTATIC) {
        Vfy_pushClassKey(v, field_type);
        return;
    }
    if (opcode == JBED_BC_PUTSTATIC) {
        Vfy_popClassKey(v, field_type);
        return;
    }
    JbedVerifyType receiver = protected_field(v, index)
                                  ? reference(v->method->owner->id)
                                  : reference(pool_class_id(v, member.class_index));
    if (opcode == JBED_BC_GETFIELD) {
        pop(v, receiver);
        Vfy_pushClassKey(v, field_type);
    } else {
        Vfy_popClassKey(v, field_type);
        JbedVerifyType actual = pop_category_one(v);
        if (actual == JBED_V_UNINITIALIZED_THIS) {
            JbedClass *declaring;
            if (v->services->pool_class_object)
                (void)v->services->pool_class_object(v->services->context, v->pool,
                                                     member.class_index, true);
            else if (!jbed_pool_class(v->pool, member.class_index, true, &declaring, &error))
                jbed_raise(v->runtime, &error);
            JbedField *field = pool_field(v, index);
            if (field->owner != v->method->owner)
                verify_error(v, VE_EXPECTING_OBJ_OR_ARR_ON_STK);
        } else {
            /* Preserve the ROM's push/pop receiver check and overflow ordering. */
            push(v, actual);
            pop(v, receiver);
        }
    }
}

/* Invoke/constructor rules, 0x15a8e4..0x15ab5a. */
static void invoke_operation(JbedVerifier *v, unsigned opcode, uint16_t index)
{
    unsigned tag = pool_tag(v, index);
    if (tag != JBED_POOL_METHODREF && tag != JBED_POOL_INTERFACE_METHODREF)
        verify_error(v, VE_EXPECT_METHODREF);
    JbedVerifierMemberReference member = member_reference(v, index);
    /* Pol_getTypeKey/Pol_getDescriptorKey, 0x181ef6/0x181f3a. */
    JbedSignatureId signature;
    JbedNameId name;
    JbedError error;
    uint16_t nt = member.name_and_type_index;
    if (v->services->pool_signature)
        signature = v->services->pool_signature(v->services->context, v->pool, nt);
    else if (!jbed_pool_signature_id(v->pool, nt, &signature, &error))
        jbed_raise(v->runtime, &error);
    if (v->services->pool_name)
        name = v->services->pool_name(v->services->context, v->pool, nt);
    else if (!jbed_pool_name_id(v->pool, nt, &name, &error))
        jbed_raise(v->runtime, &error);
    Vfy_setupCalleeContext(v, signature);
    size_t argument_words = Vfy_popInvokeArguments(v);
    bool is_constructor = constructor_name(v, name);
    if (is_constructor && opcode != JBED_BC_INVOKESPECIAL)
        verify_error(v, VE_EXPECT_INVOKESPECIAL);
    if (opcode != JBED_BC_INVOKESTATIC) {
        JbedTypeId target = pool_class_id(v, member.class_index);
        if (is_constructor) {
            JbedVerifyType actual = pop_category_one(v);
            JbedTypeId initialized;
            if (is_new(actual)) {
                uint32_t allocation = (uint16_t)actual;
                if (v->method->code_length < 3 || allocation > v->method->code_length - 3 ||
                    byte_at(v, (int32_t)allocation) != JBED_BC_NEW)
                    verify_error(v, VE_EXPECT_NEW);
                uint16_t allocated_class = ushort_at(v, (int32_t)allocation + 1);
                require_tag(v, allocated_class, JBED_POOL_CLASS, VE_EXPECT_CLASS);
                initialized = pool_class_id(v, allocated_class);
                if (initialized != target)
                    verify_error(v, VE_BAD_INIT_CALL);
            } else {
                if (actual != JBED_V_UNINITIALIZED_THIS)
                    verify_error(v, VE_EXPECT_UNINIT);
                JbedClass *owner = v->method->owner;
                if (target != owner->id) {
                    if (!owner->superclass)
                        fail(v, JBED_ERROR_NULL_POINTER, 0, NULL);
                    if (target != owner->superclass->id)
                        verify_error(v, VE_BAD_INIT_CALL);
                }
                if (!v->uninitialized_this)
                    verify_error(v, VE_BAD_INIT_CALL);
                for (size_t i = 0; i < v->method->handler_count; ++i) {
                    const JbedExceptionHandler *h = &v->method->handlers[i];
                    if ((uint32_t)v->pc >= h->start_pc && (uint32_t)v->pc < h->end_pc)
                        verify_error(v, VE_BAD_INIT_CALL);
                }
                v->uninitialized_this = false;
                initialized = owner->id;
            }
            replace_type(v, actual, reference(initialized));
        } else {
            if (opcode == JBED_BC_INVOKESPECIAL && target != v->method->owner->id) {
                JbedClass *ancestor = v->method->owner->superclass;
                while (ancestor && ancestor->id != target)
                    ancestor = ancestor->superclass;
                if (!ancestor)
                    verify_error(v, VE_INVOKESPECIAL);
            }
            JbedVerifyType receiver = reference(target);
            if ((opcode == JBED_BC_INVOKESPECIAL || opcode == JBED_BC_INVOKEVIRTUAL) &&
                protected_method(v, index))
                receiver = reference(v->method->owner->id);
            pop(v, receiver);
        }
    }
    Vfy_pushInvokeResult(v);
    if (opcode == JBED_BC_INVOKEINTERFACE) {
        if (byte_at(v, v->pc + 3) != argument_words + 1)
            verify_error(v, VE_NARGS_MISMATCH);
        if (byte_at(v, v->pc + 4))
            verify_error(v, VE_EXPECT_ZERO);
    }
}

/* tableswitch/lookupswitch, 0x15a662..0x15a758. Both require at least one byte
 * after the table; the original deliberately uses >= against code_length. */
static int32_t switch_operation(JbedVerifier *v, unsigned opcode)
{
    int32_t table = (v->pc + 4) & ~3;
    pop(v, JBED_V_INT);
    int32_t count, stride;
    if (opcode == JBED_BC_TABLESWITCH) {
        int32_t low = cell_at(v, table + 4), high = cell_at(v, table + 8);
        int32_t difference = signed_word((uint32_t)high - (uint32_t)low);
        if (low > high || difference < 0 || difference > 65535)
            verify_error(v, VE_BAD_INSTR);
        count = difference + 1;
        stride = 4;
        if ((uint64_t)(uint32_t)table + 12u + 4u * (uint32_t)count >= v->method->code_length)
            verify_error(v, VE_BAD_INSTR);
    } else {
        count = cell_at(v, table + 4);
        stride = 8;
        if (count < 0 || count > 65535 ||
            (uint64_t)(uint32_t)table + 8u + 8u * (uint32_t)count >= v->method->code_length)
            verify_error(v, VE_BAD_INSTR);
        for (int32_t i = 1; i < count; ++i)
            if (cell_at(v, table + 8 + 8 * (i - 1)) >= cell_at(v, table + 8 + 8 * i))
                verify_error(v, VE_BAD_LOOKUPSWITCH);
    }
    jump_target(v, v->pc, add_int(v->pc, cell_at(v, table)));
    int32_t cursor = table + 12;
    for (int32_t i = 0; i < count; ++i, cursor += stride)
        jump_target(v, v->pc, add_int(v->pc, cell_at(v, cursor)));
    return cursor - stride + 4;
}

/* Verifier.Vfy_verifyMethodOrAbort, 0x159532..0x15b0b8. */
static void verify_bytecode(JbedVerifier *v)
{
    JbedMethod *method = v->method;
    for (size_t i = 0; i < method->handler_count; ++i) {
        uint32_t catch_index = method->handlers[i].catch_index;
        if (catch_index) {
            if (catch_index > UINT16_MAX)
                verify_error(v, 120);
            require_tag(v, (uint16_t)catch_index, JBED_POOL_CLASS, VE_EXPECT_CLASS);
            if (!jbed_verifier_assignable(v, reference(pool_class_id(v, (uint16_t)catch_index)),
                                          JBED_ROM_CLASS_THROWABLE))
                verify_error(v, VE_EXPECT_THROWABLE);
        }
    }
    Vfy_initializeLocals(v);
    size_t next_map = 0;
    bool no_fallthrough = false;
    while ((size_t)v->pc < method->code_length) {
        int32_t next_map_pc = map_pc(v, next_map);
        if (next_map_pc < v->pc)
            verify_error(v, VE_BAD_STACKMAP);
        if (next_map_pc == v->pc)
            ++next_map;
        match_map(v, v->pc, no_fallthrough ? MAP_LOAD | MAP_REQUIRED : MAP_CHECK | MAP_LOAD,
                  VE_SEQ_BAD_TYPE);
        /* Exception edges use the pre-instruction locals and a single catch
         * object, preserving the current operand stack while matching maps. */
        for (size_t i = 0; i < method->handler_count; ++i) {
            const JbedExceptionHandler *h = &method->handlers[i];
            if ((uint32_t)v->pc < h->start_pc || (uint32_t)v->pc >= h->end_pc)
                continue;
            JbedVerifyType caught = h->catch_index
                                        ? reference(pool_class_id(v, (uint16_t)h->catch_index))
                                        : JBED_ROM_CLASS_THROWABLE;
            if (!v->stack_capacity)
                index_error(v);
            size_t depth = v->stack_depth;
            JbedVerifyType first = v->stack[0];
            v->stack_depth = 0;
            push(v, caught);
            match_map(v, (int32_t)h->handler_pc, MAP_CHECK | MAP_REQUIRED, VE_TARGET_BAD_TYPE);
            v->stack[0] = first;
            v->stack_depth = depth;
        }
        unsigned opcode = byte_at(v, v->pc);
        int32_t next = v->pc + 1;
        no_fallthrough = false;
        static const JbedVerifyType local_kinds[] = {JBED_V_INT, JBED_V_LONG, JBED_V_FLOAT,
                                                     JBED_V_DOUBLE, JBED_V_ANY_REFERENCE};
        static const JbedVerifyType number_kinds[] = {JBED_V_INT, JBED_V_LONG, JBED_V_FLOAT,
                                                      JBED_V_DOUBLE};
        if (opcode >= JBED_BC_ILOAD && opcode <= JBED_BC_ALOAD_3) {
            unsigned group, index;
            if (opcode <= JBED_BC_ALOAD) {
                group = opcode - JBED_BC_ILOAD;
                index = byte_at(v, v->pc + 1);
                next += 1;
            } else {
                group = (opcode - JBED_BC_ILOAD_0) / 4;
                index = (opcode - JBED_BC_ILOAD_0) % 4;
            }
            load_local(v, index, local_kinds[group]);
        } else if (opcode >= JBED_BC_ISTORE && opcode <= JBED_BC_ASTORE_3) {
            unsigned group, index;
            if (opcode <= JBED_BC_ASTORE) {
                group = opcode - JBED_BC_ISTORE;
                index = byte_at(v, v->pc + 1);
                next += 1;
            } else {
                group = (opcode - JBED_BC_ISTORE_0) / 4;
                index = (opcode - JBED_BC_ISTORE_0) % 4;
            }
            store_local(v, index, local_kinds[group]);
        } else if (opcode >= JBED_BC_IALOAD && opcode <= JBED_BC_SALOAD) {
            array_operation(v, opcode, false);
        } else if (opcode >= JBED_BC_IASTORE && opcode <= JBED_BC_SASTORE) {
            array_operation(v, opcode, true);
        } else if (opcode >= JBED_BC_POP && opcode <= JBED_BC_SWAP) {
            stack_operation(v, opcode);
        } else if (opcode >= JBED_BC_IADD && opcode <= JBED_BC_DREM) {
            JbedVerifyType number = number_kinds[(opcode - JBED_BC_IADD) % 4];
            pop_value(v, number);
            pop_value(v, number);
            push_value(v, number);
        } else if (opcode >= JBED_BC_INEG && opcode <= JBED_BC_DNEG) {
            JbedVerifyType number = number_kinds[opcode - JBED_BC_INEG];
            pop_value(v, number);
            push_value(v, number);
        } else if (opcode >= JBED_BC_ISHL && opcode <= JBED_BC_LXOR) {
            JbedVerifyType number = (opcode & 1) ? JBED_V_LONG : JBED_V_INT;
            pop_value(v, opcode <= JBED_BC_LUSHR ? JBED_V_INT : number);
            pop_value(v, number);
            push_value(v, number);
        } else if (opcode >= JBED_BC_I2L && opcode <= JBED_BC_D2F) {
            static const JbedVerifyType from[] = {JBED_V_INT,    JBED_V_INT,    JBED_V_INT,
                                                  JBED_V_LONG,   JBED_V_LONG,   JBED_V_LONG,
                                                  JBED_V_FLOAT,  JBED_V_FLOAT,  JBED_V_FLOAT,
                                                  JBED_V_DOUBLE, JBED_V_DOUBLE, JBED_V_DOUBLE};
            static const JbedVerifyType to[] = {
                JBED_V_LONG, JBED_V_FLOAT, JBED_V_DOUBLE, JBED_V_INT, JBED_V_FLOAT, JBED_V_DOUBLE,
                JBED_V_INT,  JBED_V_LONG,  JBED_V_DOUBLE, JBED_V_INT, JBED_V_LONG,  JBED_V_FLOAT};
            pop_value(v, from[opcode - JBED_BC_I2L]);
            push_value(v, to[opcode - JBED_BC_I2L]);
        } else if (opcode >= JBED_BC_IFEQ && opcode <= JBED_BC_IF_ACMPNE) {
            JbedVerifyType compared = opcode >= JBED_BC_IF_ACMPEQ ? JBED_V_ANY_REFERENCE : JBED_V_INT;
            pop(v, compared);
            if (opcode >= JBED_BC_IF_ICMPEQ)
                pop(v, compared);
            jump_target(v, v->pc, add_int(v->pc, short_at(v, v->pc + 1)));
            next += 2;
        } else
            switch (opcode) {
            case JBED_BC_NOP:
                break;
            case JBED_BC_ACONST_NULL:
                push(v, JBED_V_NULL);
                break;
            case JBED_BC_ICONST_M1:
            case JBED_BC_ICONST_0:
            case JBED_BC_ICONST_1:
            case JBED_BC_ICONST_2:
            case JBED_BC_ICONST_3:
            case JBED_BC_ICONST_4:
            case JBED_BC_ICONST_5:
                push(v, JBED_V_INT);
                break;
            case JBED_BC_LCONST_0:
            case JBED_BC_LCONST_1:
                push_value(v, JBED_V_LONG);
                break;
            case JBED_BC_FCONST_0:
            case JBED_BC_FCONST_1:
            case JBED_BC_FCONST_2:
                push(v, JBED_V_FLOAT);
                break;
            case JBED_BC_DCONST_0:
            case JBED_BC_DCONST_1:
                push_value(v, JBED_V_DOUBLE);
                break;
            case JBED_BC_BIPUSH:
                push(v, JBED_V_INT);
                next += 1;
                break;
            case JBED_BC_SIPUSH:
                push(v, JBED_V_INT);
                next += 2;
                break;
            case JBED_BC_LDC:
            case JBED_BC_LDC_W:
            case JBED_BC_LDC2_W: {
                uint16_t index = opcode == JBED_BC_LDC ? byte_at(v, v->pc + 1) : ushort_at(v, v->pc + 1);
                unsigned tag = pool_tag(v, index);
                if (opcode == JBED_BC_LDC2_W) {
                    if (tag != JBED_POOL_LONG && tag != JBED_POOL_DOUBLE)
                        verify_error(v, VE_BAD_LDC);
                    push_value(v, tag == JBED_POOL_LONG ? JBED_V_LONG : JBED_V_DOUBLE);
                } else {
                    if (tag == JBED_POOL_STRING)
                        push(v, JBED_ROM_CLASS_STRING);
                    else if (tag == JBED_POOL_CLASS && v->pool->services->boot_image)
                        push(v, JBED_ROM_CLASS_CLASS);
                    else if (tag == JBED_POOL_INTEGER)
                        push(v, JBED_V_INT);
                    else if (tag == JBED_POOL_FLOAT)
                        push(v, JBED_V_FLOAT);
                    else
                        verify_error(v, VE_BAD_LDC);
                }
                next += opcode == JBED_BC_LDC ? 1 : 2;
                break;
            }
            case JBED_BC_IINC: {
                unsigned index = byte_at(v, v->pc + 1);
                get_local(v, index, JBED_V_INT);
                set_local(v, index, JBED_V_INT);
                next += 2;
                break;
            }
            case JBED_BC_I2B:
            case JBED_BC_I2C:
            case JBED_BC_I2S:
                pop(v, JBED_V_INT);
                push(v, JBED_V_INT);
                break;
            case JBED_BC_LCMP:
            case JBED_BC_FCMPL:
            case JBED_BC_FCMPG:
            case JBED_BC_DCMPL:
            case JBED_BC_DCMPG: {
                JbedVerifyType compared = opcode == JBED_BC_LCMP ? JBED_V_LONG
                                         : opcode <= JBED_BC_FCMPG ? JBED_V_FLOAT
                                                                  : JBED_V_DOUBLE;
                pop_value(v, compared);
                pop_value(v, compared);
                push(v, JBED_V_INT);
                break;
            }
            case JBED_BC_GOTO:
            case JBED_BC_GOTO_W:
                jump_target(v, v->pc,
                            add_int(v->pc, opcode == JBED_BC_GOTO ? short_at(v, v->pc + 1)
                                                          : cell_at(v, v->pc + 1)));
                next += opcode == JBED_BC_GOTO ? 2 : 4;
                no_fallthrough = true;
                break;
            case JBED_BC_TABLESWITCH:
            case JBED_BC_LOOKUPSWITCH:
                next = switch_operation(v, opcode);
                no_fallthrough = true;
                break;
            case JBED_BC_IRETURN:
                Vfy_popReturn(v, JBED_V_INT);
                no_fallthrough = true;
                break;
            case JBED_BC_LRETURN:
                pop(v, JBED_V_LONG_HIGH);
                Vfy_popReturn(v, JBED_V_LONG);
                no_fallthrough = true;
                break;
            case JBED_BC_FRETURN:
                Vfy_popReturn(v, JBED_V_FLOAT);
                no_fallthrough = true;
                break;
            case JBED_BC_DRETURN:
                pop(v, JBED_V_DOUBLE_HIGH);
                Vfy_popReturn(v, JBED_V_DOUBLE);
                no_fallthrough = true;
                break;
            case JBED_BC_ARETURN:
                Vfy_popReturn(v, JBED_ROM_CLASS_OBJECT);
                no_fallthrough = true;
                break;
            case JBED_BC_RETURN:
                Vfy_returnVoid(v);
                no_fallthrough = true;
                break;
            case JBED_BC_GETSTATIC:
            case JBED_BC_PUTSTATIC:
            case JBED_BC_GETFIELD:
            case JBED_BC_PUTFIELD:
                field_operation(v, opcode, ushort_at(v, v->pc + 1));
                next += 2;
                break;
            case JBED_BC_INVOKEVIRTUAL:
            case JBED_BC_INVOKESPECIAL:
            case JBED_BC_INVOKESTATIC:
            case JBED_BC_INVOKEINTERFACE:
                invoke_operation(v, opcode, ushort_at(v, v->pc + 1));
                next += opcode == JBED_BC_INVOKEINTERFACE ? 4 : 2;
                break;
            case JBED_BC_NEW: {
                uint16_t index = ushort_at(v, v->pc + 1);
                require_tag(v, index, JBED_POOL_CLASS, VE_EXPECT_CLASS);
                if (array_dimensions(v, pool_class_id(v, index), 1))
                    verify_error(v, VE_EXPECT_CLASS);
                push(v, new_type(v, (uint32_t)v->pc));
                v->new_instructions[(uint32_t)v->pc >> 5] |= UINT32_C(1) << ((uint32_t)v->pc & 31);
                next += 2;
                break;
            }
            case JBED_BC_NEWARRAY: {
                static const JbedTypeId primitive_arrays[] = {
                    JBED_ROM_CLASS_BOOLEAN_ARRAY, JBED_ROM_CLASS_CHAR_ARRAY,  JBED_ROM_CLASS_FLOAT_ARRAY, JBED_ROM_CLASS_DOUBLE_ARRAY,
                    JBED_ROM_CLASS_BYTE_ARRAY,    JBED_ROM_CLASS_SHORT_ARRAY, JBED_ROM_CLASS_INT_ARRAY,   JBED_ROM_CLASS_LONG_ARRAY};
                unsigned element = byte_at(v, v->pc + 1);
                if (element < 4 || element > 11)
                    verify_error(v, VE_BAD_INSTR);
                pop(v, JBED_V_INT);
                push(v, reference(primitive_arrays[element - 4]));
                next += 1;
                break;
            }
            case JBED_BC_ANEWARRAY: {
                uint16_t index = ushort_at(v, v->pc + 1);
                require_tag(v, index, JBED_POOL_CLASS, VE_EXPECT_CLASS);
                /* Vfy_getClassArrayVerifierType, 0x180e40. */
                JbedTypeId component = pool_class_id(v, index);
                JbedTypeId array = v->services->array_of_class
                                       ? v->services->array_of_class(v->services->context, component)
                                       : jbed_class_array_of(class_access(v), component);
                pop(v, JBED_V_INT);
                push(v, reference(array));
                next += 2;
                break;
            }
            case JBED_BC_ARRAYLENGTH: {
                JbedVerifyType array = pop(v, JBED_ROM_CLASS_OBJECT);
                if (array != JBED_V_NULL && !is_array(v, array))
                    verify_error(v, VE_EXPECT_ARRAY);
                push(v, JBED_V_INT);
                break;
            }
            case JBED_BC_ATHROW:
                pop(v, JBED_ROM_CLASS_THROWABLE);
                no_fallthrough = true;
                break;
            case JBED_BC_CHECKCAST:
            case JBED_BC_INSTANCEOF: {
                uint16_t index = ushort_at(v, v->pc + 1);
                require_tag(v, index, JBED_POOL_CLASS, VE_EXPECT_CLASS);
                JbedTypeId target = opcode == JBED_BC_CHECKCAST ? pool_class_id(v, index) : 0;
                pop(v, JBED_ROM_CLASS_OBJECT);
                push(v, opcode == JBED_BC_CHECKCAST ? reference(target) : JBED_V_INT);
                next += 2;
                break;
            }
            case JBED_BC_MONITORENTER:
            case JBED_BC_MONITOREXIT:
                pop(v, JBED_ROM_CLASS_OBJECT);
                break;
            case JBED_BC_WIDE: {
                unsigned modified = byte_at(v, v->pc + 1);
                if (!((modified >= JBED_BC_ILOAD && modified <= JBED_BC_ALOAD) ||
                      (modified >= JBED_BC_ISTORE && modified <= JBED_BC_ASTORE) ||
                      modified == JBED_BC_IINC))
                    verify_error(v, VE_BAD_INSTR);
                unsigned index = ushort_at(v, v->pc + 2);
                if (modified == JBED_BC_IINC) {
                    get_local(v, index, JBED_V_INT);
                    set_local(v, index, JBED_V_INT);
                    next += 5;
                } else {
                    if (modified <= JBED_BC_ALOAD)
                        load_local(v, index, local_kinds[modified - JBED_BC_ILOAD]);
                    else
                        store_local(v, index, local_kinds[modified - JBED_BC_ISTORE]);
                    next += 3;
                }
                break;
            }
            case JBED_BC_MULTIANEWARRAY: {
                uint16_t index = ushort_at(v, v->pc + 1);
                require_tag(v, index, JBED_POOL_CLASS, VE_EXPECT_CLASS);
                JbedTypeId array = pool_class_id(v, index);
                unsigned dimensions = byte_at(v, v->pc + 3);
                if (!dimensions || !array_dimensions(v, array, dimensions))
                    verify_error(v, VE_MULTIANEWARRAY);
                for (unsigned i = 0; i < dimensions; ++i)
                    pop(v, JBED_V_INT);
                push(v, reference(array));
                next += 3;
                break;
            }
            case JBED_BC_IFNULL:
            case JBED_BC_IFNONNULL:
                pop(v, JBED_V_ANY_REFERENCE);
                jump_target(v, v->pc, add_int(v->pc, short_at(v, v->pc + 1)));
                next += 2;
                break;
            default:
                verify_error(v, VE_BAD_INSTR); /* Includes jsr, ret and all opcodes > 200. */
            }
        if (next > v->pc + 1) {
            for (size_t i = 0; i < method->handler_count; ++i) {
                const JbedExceptionHandler *h = &method->handlers[i];
                if ((h->start_pc > (uint32_t)v->pc && h->start_pc < (uint32_t)next) ||
                    (h->end_pc > (uint32_t)v->pc && h->end_pc < (uint32_t)next))
                    verify_error(v, VE_BAD_EXCEPTION_HANDLER_RANGE);
            }
        }
        v->pc = next;
    }
    if (!map_walk_complete(v, next_map))
        verify_error(v, VE_BAD_STACKMAP);
    if ((size_t)v->pc > method->code_length)
        verify_error(v, VE_MIDDLE_OF_BYTE_CODE);
    if (!no_fallthrough)
        verify_error(v, VE_FALL_THROUGH);
    /* resetProfilingStats/evaluateProfilingStats/storeProfilingInfo,
     * 0x181fe8/0x181fea/0x181fec, are empty in this ROM. */
}

/* VerifierUtil.<init>/Verifier.<init>, 0x180cd4/0x15951c. */
void jbed_verifier_init(JbedVerifier *v, JbedRuntime *runtime, const JbedVerifierServices *services)
{
    memset(v, 0, sizeof(*v));
    v->runtime = runtime;
    v->services = services;
    v->sig_enc = services->signature_encoder;
}

void jbed_verifier_verify_method(JbedVerifier *v, JbedMethod *method)
{
    initialize_method(v, method);
    verify_bytecode(v);
    check_new_maps(v);
    set_local_hint(v);
    if (!(method->flags & JBED_ACC_STATIC) && !v->local_zero_written)
        method->flags |= JBED_METHOD_SLOT0_ALWAYS_THIS;
}

/* VerifierUtil.verify, 0x182236; Mth_getExceptionTableLength, 0x181fca,
 * corresponds to JbedMethod.handler_count in the semantic model. */
void jbed_verifier_verify_class(JbedVerifier *v, JbedClass *klass)
{
    for (JbedMethod *method = klass->methods; method; method = method->next) {
        jbed_emitter_set_import(v->services->emitter, klass->id, method->name_id,
                                method->signature_id);
        v->method = method;
        v->pool = klass->pool;
        v->pc = 0;
        if (method->code)
            jbed_verifier_verify_method(v, method);
        else
            Vfy_resolveSignature(v, method);
    }
    jbed_emitter_set_import(v->services->emitter, 0, 0, 0);
}
