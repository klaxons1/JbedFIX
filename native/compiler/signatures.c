#include "signatures.h"
#include "class_access.h"

#include <string.h>

enum {
    SIGNATURE_CAPACITY = 1286,
    SHORT_SIGNATURE = 0xf000,
    SHORT_CLASS_ID_LIMIT = 2048,
    LONG_CLASS_ID = 8
};

static void require(JbedSignatureEncoder *s, bool condition, const char *message)
{
    if (!condition)
        jbed_halt(s->services->runtime, 0, message);
}

static uint8_t *byte_at(JbedSignatureEncoder *s, size_t i)
{
    if (!s->bytes || i >= SIGNATURE_CAPACITY) {
        const JbedError error = {.kind =
                                     s->bytes ? JBED_ERROR_ARRAY_INDEX : JBED_ERROR_NULL_POINTER,
                                 .message = "signature buffer access"};
        jbed_raise(s->services->runtime, &error);
    }
    return &s->bytes[i];
}

/* SignatureEncoder.<clinit>, 0x147a6c. IDs belong to this ROM's ClassAccess. */
JbedSignatureTypes jbed_signature_rom_types(void)
{
    return (JbedSignatureTypes){JBED_ROM_CLASS_OBJECT, JBED_ROM_CLASS_STRING,
                                JBED_ROM_CLASS_INT_ARRAY, JBED_ROM_CLASS_BYTE_ARRAY,
                                JBED_ROM_CLASS_CHAR_ARRAY};
}

/* getReflTable, 0x147088: the host supplies ReflectionTable's lazy singleton. */
JbedReflectionTable *jbed_signature_table(const JbedSignatureEncoder *s)
{
    if (!s->services->reflection_table)
        jbed_halt(s->services->runtime, 0, "SignatureEncoder.getReflTable() before table initialized");
    return s->services->reflection_table;
}

/* <init>, 0x1470b8; copyIfInUse, 0x1470d2. A busy copy starts empty. */
void jbed_signature_init(JbedSignatureEncoder *s, const JbedSignatureServices *services)
{
    *s = (JbedSignatureEncoder){.services = services};
}

JbedSignatureEncoder *jbed_signature_copy_if_busy(JbedSignatureEncoder *s)
{
    if (!s->current_id)
        return s;
    JbedSignatureEncoder *copy = jbed_alloc(s->services->runtime, sizeof *copy);
    jbed_signature_init(copy, s->services);
    return copy;
}

/* getBuf, 0x147104. */
uint8_t *jbed_signature_buffer(JbedSignatureEncoder *s)
{
    if (!s->bytes)
        s->bytes = jbed_alloc(s->services->runtime, SIGNATURE_CAPACITY);
    return s->bytes;
}

/* startSignature, 0x147596. Only byte 1 needs clearing for inline signatures. */
void jbed_signature_start(JbedSignatureEncoder *s)
{
    require(s, !s->current_id, "signature encoder already in use");
    s->current_id = -1;
    jbed_signature_buffer(s)[1] = 0;
    s->byte_count = 0;
    s->added_void = false;
    s->high_nibble = false;
}

/* addShort, 0x147128: the low nibble is written first. */
void jbed_signature_add_short(JbedSignatureEncoder *s, int32_t value)
{
    require(s, value <= JBED_SIGNATURE_END, "invalid short signature type");
    uint8_t *b = byte_at(s, s->byte_count);
    if (s->high_nibble) {
        *b |= (uint8_t)((uint32_t)value << 4);
        ++s->byte_count;
        s->high_nibble = false;
    } else {
        *b = (uint8_t)value;
        s->high_nibble = true;
    }
}

/* addClassId, 0x1471a4. IDs below 2048 use exactly four nibbles. */
void jbed_signature_add_class_id(JbedSignatureEncoder *s, JbedTypeId id)
{
    if (id >= SHORT_CLASS_ID_LIMIT) {
        jbed_signature_add_long_class_id(s, id);
        return;
    }
    if (s->high_nibble) {
        *byte_at(s, s->byte_count) |= JBED_SIGNATURE_CLASS_ID << 4;
        *byte_at(s, s->byte_count + 1) = (uint8_t)((id & 0xf0) | ((id >> 8) & 0xf));
        *byte_at(s, s->byte_count + 2) = (uint8_t)(id & 0xf);
    } else {
        *byte_at(s, s->byte_count) = (uint8_t)(((id >> 4) & 0xf0) | JBED_SIGNATURE_CLASS_ID);
        *byte_at(s, s->byte_count + 1) = (uint8_t)id;
    }
    s->byte_count += 2;
}

/* addLongClassId, 0x14726e. Prefix F, (8 | digit_count-1), then the ID's
 * hexadecimal digits; byte pairs are big endian even though nibble order is low
 * first. A partial final digit occupies the low nibble of the next byte. */
void jbed_signature_add_long_class_id(JbedSignatureEncoder *s, JbedTypeId id)
{
    unsigned digits = 0;
    for (uint32_t n = id; n; n >>= 4)
        ++digits;
    int shift = 4 * ((int)digits - 2);
    uint32_t prefix = (digits - 1) | LONG_CLASS_ID;
    if (s->high_nibble) {
        *byte_at(s, s->byte_count) |= JBED_SIGNATURE_CLASS_ID << 4;
        *byte_at(s, s->byte_count + 1) =
            (uint8_t)(prefix | ((id >> ((unsigned)shift & 31)) & 0xf0));
        shift -= 4;
        s->byte_count += 2;
    } else {
        *byte_at(s, s->byte_count) = (uint8_t)((prefix << 4) | JBED_SIGNATURE_CLASS_ID);
        ++s->byte_count;
    }
    while (shift >= 0) {
        *byte_at(s, s->byte_count) = (uint8_t)(id >> ((unsigned)shift & 31));
        ++s->byte_count;
        shift -= 8;
    }
    s->high_nibble = shift == -4;
    if (s->high_nibble)
        *byte_at(s, s->byte_count) = (uint8_t)(id & 0xf);
}

/* addVoid, 0x14738a; addPrimitive, 0x1473a6. */
void jbed_signature_add_void(JbedSignatureEncoder *s)
{
    jbed_signature_add_short(s, JBED_SIGNATURE_VOID);
    s->added_void = true;
}
void jbed_signature_add_primitive(JbedSignatureEncoder *s, JbedTypeId id)
{
    require(s, id >= JBED_TYPE_BOOLEAN && id <= JBED_TYPE_LONG, "invalid primitive signature type");
    jbed_signature_add_short(s, (int32_t)id);
}

/* addPrimitiveArray, 0x1473d8; addClassType, 0x147436. */
void jbed_signature_add_primitive_array(JbedSignatureEncoder *s, uint32_t dimensions,
                                        JbedTypeId primitive)
{
    if (dimensions == 1) {
        if (primitive == JBED_TYPE_INT) {
            jbed_signature_add_short(s, JBED_SIGNATURE_INT_ARRAY);
            return;
        }
        if (primitive == JBED_TYPE_CHAR) {
            jbed_signature_add_short(s, JBED_SIGNATURE_CHAR_ARRAY);
            return;
        }
        if (primitive == JBED_TYPE_BYTE) {
            jbed_signature_add_short(s, JBED_SIGNATURE_BYTE_ARRAY);
            return;
        }
    }
    JbedTypeId id = s->services->primitive_array_id
                        ? s->services->primitive_array_id(s->services->context, primitive, dimensions)
                        : jbed_class_primitive_array(s->services->class_access, primitive, (int32_t)dimensions);
    jbed_signature_add_class_id(s, id);
}
void jbed_signature_add_class_type(JbedSignatureEncoder *s, const uint8_t *bytes, uint32_t start,
                                   uint32_t end, uint32_t slash, uint32_t dimensions)
{
    JbedTypeId id = s->services->class_id
                        ? s->services->class_id(s->services->context, bytes, start, end, slash, dimensions)
                        : jbed_class_name_id(s->services->class_access, bytes, start, end, slash,
                                             (int32_t)dimensions);
    if (id == s->services->types.object)
        jbed_signature_add_short(s, JBED_SIGNATURE_OBJECT);
    else if (id == s->services->types.string)
        jbed_signature_add_short(s, JBED_SIGNATURE_STRING);
    else
        jbed_signature_add_class_id(s, id);
}

/* getBuiltSignatureId, 0x1474a0. A three-nibble signature fits in Fxxx. Void
 * terminates without an E; non-void signatures receive E after the result. */
JbedSignatureId jbed_signature_finish(JbedSignatureEncoder *s)
{
    if (!s->added_void)
        jbed_signature_add_short(s, JBED_SIGNATURE_END);
    JbedSignatureId id;
    if (s->byte_count < 2 || (s->byte_count == 2 && !s->high_nibble && !s->added_void)) {
        id = (JbedSignatureId)(s->bytes[0] | ((s->bytes[1] & 15) << 8) | SHORT_SIGNATURE);
    } else {
        if (s->high_nibble)
            ++s->byte_count;
        if (s->services->intern)
            id = s->services->intern(s->services->context, s->bytes, s->byte_count);
        else
            id = jbed_reflection_id(s->services->reflection_table, s->bytes, s->byte_count, true);
        require(s, (id & SHORT_SIGNATURE) != SHORT_SIGNATURE,
                "reflection signature ID overlaps inline signature range");
    }
    s->current_id = 0;
    return id;
}
/* builtSignatureReturnsVoid, 0x14758c; discardBuiltSignature, 0x147590. */
bool jbed_signature_returns_void(const JbedSignatureEncoder *s)
{
    return s->added_void;
}
void jbed_signature_discard(JbedSignatureEncoder *s)
{
    s->current_id = 0;
}

/* openSignature, 0x1477b4. */
void jbed_signature_open(JbedSignatureEncoder *s, JbedSignatureId id)
{
    require(s, !s->current_id, "signature encoder already open");
    s->current_id = id;
    if ((id & SHORT_SIGNATURE) != SHORT_SIGNATURE) {
        uint8_t *bytes = jbed_signature_buffer(s);
        if (s->services->fetch)
            s->byte_count = s->services->fetch(s->services->context, id, bytes, SIGNATURE_CAPACITY);
        else
            s->byte_count = jbed_reflection_data(s->services->reflection_table, id, bytes,
                                                 SIGNATURE_CAPACITY);
    }
    s->nibble_index = 0;
}

/* getNextSignatureType, 0x147818, including dispatch table at 0x1479e2. */
JbedTypeId jbed_signature_next(JbedSignatureEncoder *s)
{
    require(s, s->current_id && s->current_id != -1, "signature encoder is not decoding");
    uint32_t type;
    if (((uint32_t)s->current_id & SHORT_SIGNATURE) == SHORT_SIGNATURE) {
        if (s->nibble_index == 3)
            return JBED_SIGNATURE_END;
        type = ((uint32_t)s->current_id >> ((4 * s->nibble_index++) & 31)) & 15;
        require(s, type != JBED_SIGNATURE_CLASS_ID, "inline signature contains a class ID escape");
    } else {
        int32_t pos = (int32_t)s->nibble_index >> 1;
        bool high = (s->nibble_index & 1) != 0;
        require(s, pos < s->byte_count, "signature lacks an end type");
        uint8_t b = *byte_at(s, pos);
        type = (b >> (high ? 4 : 0)) & 15;
        if (type == JBED_SIGNATURE_CLASS_ID) {
            uint32_t head = high ? *byte_at(s, pos + 1) & 15 : b >> 4;
            if (head & LONG_CLASS_ID) {
                uint32_t remaining = head & 7;
                s->nibble_index += remaining + 3;
                if (high) {
                    type = *byte_at(s, pos + 1) >> 4;
                    pos += 2;
                } else {
                    type = 0;
                    ++pos;
                    ++remaining;
                }
                while (remaining > 1) {
                    type = (type << 8) | *byte_at(s, pos++);
                    remaining -= 2;
                }
                if (remaining)
                    type = (type << 4) | (*byte_at(s, pos) & 15);
            } else {
                type = head << 8;
                type |= high ? (*byte_at(s, pos + 1) & 0xf0) | (*byte_at(s, pos + 2) & 15)
                             : *byte_at(s, pos + 1);
                s->nibble_index += 4;
            }
        } else {
            ++s->nibble_index;
            if (type == JBED_SIGNATURE_VOID || type == JBED_SIGNATURE_END)
                require(s, pos == s->byte_count - 1, "signature terminates before its final byte");
        }
    }
    switch (type) {
    case JBED_SIGNATURE_OBJECT:
        return s->services->types.object;
    case JBED_SIGNATURE_STRING:
        return s->services->types.string;
    case JBED_SIGNATURE_INT_ARRAY:
        return s->services->types.int_array;
    case JBED_SIGNATURE_BYTE_ARRAY:
        return s->services->types.byte_array;
    case JBED_SIGNATURE_CHAR_ARRAY:
        return s->services->types.char_array;
    case JBED_SIGNATURE_VOID:
        return 0;
    default:
        return type;
    }
}

/* closeSignature, 0x147a44. */
void jbed_signature_close(JbedSignatureEncoder *s, JbedSignatureId id)
{
    require(s, s->current_id == id, "closing a different signature ID");
    s->current_id = 0;
}

/* NumPar (0x169aa0) retains one pending type: the E terminator makes it the
 * return value, while D consumes the pending parameter and returns void. */
void jbed_signature_unpack(JbedSignatureEncoder *s, JbedSignatureId id, JbedSignatureArguments *out)
{
    jbed_signature_open(s, id);
    out->count = 0;
    JbedTypeId pending = 0;
    for (;;) {
        JbedTypeId next = jbed_signature_next(s);
        if (next == JBED_SIGNATURE_END)
            break;
        if (pending) {
            if (out->count == out->capacity) {
                size_t capacity = out->capacity ? out->capacity * 2 : 8;
                JbedTypeId *parameters = jbed_alloc(s->services->runtime, capacity * sizeof *parameters);
                if (out->count)
                    memcpy(parameters, out->parameters, out->count * sizeof *parameters);
                out->parameters = parameters;
                out->capacity = capacity;
            }
            out->parameters[out->count++] = pending;
        }
        pending = next;
        if (!next)
            break;
    }
    out->result = pending;
    jbed_signature_close(s, id);
}

static void append(JbedSignatureEncoder *s, char **buffer, size_t *length, const char *text)
{
    size_t n = strlen(text);
    char *next = jbed_alloc(s->services->runtime, *length + n + 1);
    if (*length)
        memcpy(next, *buffer, *length);
    memcpy(next + *length, text, n + 1);
    *length += n;
    *buffer = next;
}

typedef struct DescriptorState {
    JbedSignatureEncoder *encoder;
    char *arguments;
    size_t length;
    const char *previous;
} DescriptorState;

static void descriptor_body(void *argument)
{
    DescriptorState *state = argument;
    JbedSignatureEncoder *s = state->encoder;
    static const char *const primitive[] = {"V", NULL, NULL, NULL, "Z", "C",
                                            "F", "D",  "B",  "S",  "I", "J"};
    for (;;) {
        JbedTypeId type = jbed_signature_next(s);
        if (type == JBED_SIGNATURE_END)
            break;
        append(s, &state->arguments, &state->length, state->previous);
        if (type <= JBED_TYPE_LONG && primitive[type]) {
            state->previous = primitive[type];
            if (type == 0)
                break;
        } else {
            bool array = false;
            const char *name;
            if (s->services->class_name) {
                name = s->services->class_name(s->services->context, type, &array);
            } else {
                JbedClassAccess *access = s->services->class_access;
                array = jbed_class_params(access, type).dimensions != 0;
                name = jbed_class_object(access, type) ? jbed_class_name(access, type) : NULL;
            }
            if (!name)
                state->previous = type == UINT32_C(0xffff8000) ? "Lcom.jbed.BAD_CLASS;"
                                                               : "Lcom.jbed.UNKNOWN_CLASS;";
            else if (array)
                state->previous = name;
            else {
                char *wrapped = NULL;
                size_t n = 0;
                append(s, &wrapped, &n, "L");
                append(s, &wrapped, &n, name);
                append(s, &wrapped, &n, ";");
                state->previous = wrapped;
            }
        }
    }
}

/* idToSignature, 0x1475e4. The final decoded type becomes the return type.
 * Handler 0x147744 closes the decoder before rethrowing a formatting failure. */
char *jbed_signature_descriptor(JbedSignatureEncoder *s, JbedSignatureId id)
{
    jbed_signature_open(s, id);
    DescriptorState state = {.encoder = s, .previous = ""};
    JbedRuntime *runtime = s->services->runtime;
    JbedError caught;
    if (!runtime->protected_call(runtime->context, descriptor_body, &state, &caught)) {
        jbed_signature_close(s, id);
        jbed_raise(runtime, &caught);
    }
    jbed_signature_close(s, id);
    char *result = NULL;
    size_t result_length = 0;
    append(s, &result, &result_length, "(");
    append(s, &result, &result_length, state.arguments ? state.arguments : "");
    append(s, &result, &result_length, ")");
    append(s, &result, &result_length, state.previous);
    return result;
}

static void add_type(JbedSignatureEncoder *s, JbedTypeId type)
{
    const JbedSignatureTypes *t = &s->services->types;
    if (type >= JBED_TYPE_BOOLEAN && type <= JBED_TYPE_LONG)
        jbed_signature_add_primitive(s, type);
    else if (type == t->object)
        jbed_signature_add_short(s, JBED_SIGNATURE_OBJECT);
    else if (type == t->string)
        jbed_signature_add_short(s, JBED_SIGNATURE_STRING);
    else if (type == t->int_array)
        jbed_signature_add_short(s, JBED_SIGNATURE_INT_ARRAY);
    else if (type == t->byte_array)
        jbed_signature_add_short(s, JBED_SIGNATURE_BYTE_ARRAY);
    else if (type == t->char_array)
        jbed_signature_add_short(s, JBED_SIGNATURE_CHAR_ARRAY);
    else
        jbed_signature_add_class_id(s, type);
}

JbedSignatureId jbed_signature_build_types(JbedSignatureEncoder *s, const JbedTypeId *arguments,
                                           size_t count, JbedTypeId result, bool returns_void)
{
    jbed_signature_start(s);
    for (size_t i = 0; i < count; ++i)
        add_type(s, arguments[i]);
    if (returns_void)
        jbed_signature_add_void(s);
    else
        add_type(s, result);
    return jbed_signature_finish(s);
}
