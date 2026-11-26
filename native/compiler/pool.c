#include "pool.h"
#include "vm_strings.h"
#include "class_access.h"
#include "vm_types.h"
#include "signatures.h"
#include "reader.h"
#include "compiler.h"

#include <limits.h>
#include <string.h>

static bool pool_error(JbedError *error, JbedErrorKind kind, const char *message)
{
    if (error) {
        *error = (JbedError){0};
        error->kind = kind;
        error->is_java_error = kind != JBED_ERROR_IO && kind != JBED_ERROR_RUNTIME_EXCEPTION &&
                               kind != JBED_ERROR_NULL_POINTER && kind != JBED_ERROR_ARRAY_INDEX &&
                               kind != JBED_ERROR_CLASS_CAST && kind != JBED_ERROR_ARITHMETIC;
        error->bytecode_offset = -1;
        error->message = message;
    }
    return false;
}

static bool pool_diagnostic(JbedPool *pool, JbedError *error, JbedEmitterDiagnostic diagnostic,
                            JbedTypeId type, JbedNameId name, JbedSignatureId signature)
{
    JbedError failure =
        jbed_emitter_error(pool->services->emitter, diagnostic, type, name, signature, 0);
    if (error)
        *error = failure;
    return false;
}

static bool pool_format_error(JbedPool *pool, JbedError *error)
{
    return pool_diagnostic(pool, error, JBED_EMITTER_CLASS_FORMAT, 0, 0, 0);
}

static void *pool_alloc(JbedPool *pool, size_t count, size_t size)
{
    if (size && count > SIZE_MAX / size)
        jbed_raise_internal(pool->services->runtime, "Pool allocation overflow");
    return jbed_alloc(pool->services->runtime, count * size);
}

/* Constructors 0x12c678/0x12c6c6. Original static init/reset at 0x12c57c/
 * 0x12c634 bind reflection services; the explicit service object replaces
 * those process-global references and cached attribute-name byte arrays. */
void jbed_pool_init(JbedPool *pool, const JbedPoolServices *services, JbedClass *owner)
{
    memset(pool, 0, sizeof(*pool));
    pool->services = services;
    pool->owner = owner;
}

void jbed_pool_reset(JbedPool *pool)
{
    memset(pool, 0, sizeof(*pool));
}

enum {
    UTF8_STRING = 1,
    UTF8_CLASS_NAME = 2,
    UTF8_FIELD_NAME = 4,
    UTF8_FIELD_TYPE = 8,
    UTF8_METHOD_NAME = 16,
    UTF8_METHOD_SIGNATURE = 32,
    UTF8_REFERENCED_METHOD = 64,
    NAME_TYPE_FIELD = 1,
    NAME_TYPE_METHOD = 2,
    SIGNATURE_RETURNS_VOID = 0x10000
};

/* Pool.checkTag, 0x12d2ac: forward references establish a tag before its entry
 * is read. Repeated references OR their distinct UTF8/NameAndType uses. */
static bool check_tag(JbedPool *pool, uint32_t index, uint8_t tag, uint8_t use, JbedError *error)
{
    if (index == 0 || index >= pool->count || (pool->tags[index] && pool->tags[index] != tag))
        return pool_format_error(pool, error);
    if (!pool->tags[index]) {
        pool->tags[index] = tag;
        pool->resolve_flags[index] = use;
    } else {
        pool->resolve_flags[index] |= use;
    }
    return true;
}

/* Pool.setNameTypeFlags, 0x12d614. */
static bool set_name_type_flags(JbedPool *pool, JbedError *error)
{
    for (uint32_t i = 1; i < pool->count; ++i) {
        if (pool->tags[i] != JBED_POOL_NAME_AND_TYPE || !pool->resolve_flags[i])
            continue;
        uint16_t name = (uint16_t)(pool->values[i] >> 16);
        uint16_t type = (uint16_t)pool->values[i];
        if (pool->resolve_flags[i] == NAME_TYPE_FIELD) {
            pool->resolve_flags[name] |= UTF8_FIELD_NAME;
            pool->resolve_flags[type] |= UTF8_FIELD_TYPE;
        } else if (pool->resolve_flags[i] == NAME_TYPE_METHOD) {
            pool->resolve_flags[name] |= UTF8_METHOD_NAME | UTF8_REFERENCED_METHOD;
            pool->resolve_flags[type] |= UTF8_METHOD_SIGNATURE;
        } else {
            return pool_format_error(pool, error);
        }
    }
    return true;
}

/* Pool.readPool, 0x12d2ea; switch targets verified at 0x12d390–0x12d5ea. */
bool jbed_pool_read(JbedPool *pool, JbedReader *reader, JbedError *error)
{
    reader->runtime = pool->services->runtime;
    reader->emitter = pool->services->emitter;
    pool->count = jbed_reader_u2(reader);
    pool->tags = pool_alloc(pool, pool->count, sizeof(*pool->tags));
    pool->values = pool_alloc(pool, pool->count, sizeof(*pool->values));
    pool->resolve_flags = pool_alloc(pool, pool->count, sizeof(*pool->resolve_flags));
    pool->utf8 = pool_alloc(pool, pool->count, sizeof(*pool->utf8));
    pool->utf8_info = pool_alloc(pool, pool->count, sizeof(*pool->utf8_info));
    for (uint32_t i = 1; i < pool->count; ++i) {
        uint8_t tag = jbed_reader_read(reader);
        if (!check_tag(pool, i, tag, 0, error))
            return false;
        switch (tag) {
        case JBED_POOL_UTF8: {
            uint16_t length = jbed_reader_u2(reader);
            pool->utf8[i].length = length;
            pool->utf8[i].bytes = pool_alloc(pool, (size_t)length + 2, 1);
            if (!jbed_reader_bytes(reader, pool->utf8[i].bytes, length, error))
                return false;
            break;
        }
        case JBED_POOL_INTEGER:
        case JBED_POOL_FLOAT:
            pool->values[i] = jbed_reader_s4(reader);
            break;
        case JBED_POOL_LONG:
        case JBED_POOL_DOUBLE:
            if (!check_tag(pool, i + 1, JBED_POOL_WIDE_TAIL, 0, error))
                return false;
            pool->values[i] = jbed_reader_s4(reader);
            pool->values[++i] = jbed_reader_s4(reader);
            break;
        case JBED_POOL_CLASS:
        case JBED_POOL_STRING: {
            uint16_t reference = jbed_reader_u2(reader);
            if (!check_tag(pool, reference, JBED_POOL_UTF8,
                           tag == JBED_POOL_CLASS ? UTF8_CLASS_NAME : UTF8_STRING, error))
                return false;
            pool->values[i] = reference;
            ++pool->object_count;
            break;
        }
        case JBED_POOL_FIELDREF:
        case JBED_POOL_METHODREF:
        case JBED_POOL_INTERFACE_METHODREF:
        case JBED_POOL_NAME_AND_TYPE: {
            uint16_t first = jbed_reader_u2(reader), second = jbed_reader_u2(reader);
            if (tag == JBED_POOL_NAME_AND_TYPE) {
                if (!check_tag(pool, first, JBED_POOL_UTF8, 0, error) ||
                    !check_tag(pool, second, JBED_POOL_UTF8, 0, error))
                    return false;
            } else {
                if (!check_tag(pool, first, JBED_POOL_CLASS, 0, error) ||
                    !check_tag(pool, second, JBED_POOL_NAME_AND_TYPE,
                               tag == JBED_POOL_FIELDREF ? NAME_TYPE_FIELD : NAME_TYPE_METHOD, error))
                    return false;
            }
            pool->values[i] = (uint32_t)first << 16 | second;
            break;
        }
        default:
            return pool_format_error(pool, error);
        }
    }
    pool->objects = pool_alloc(pool, pool->object_count, sizeof(*pool->objects));
    return set_name_type_flags(pool, error);
}

/* Pool.getAttrString/eq, 0x12d7b4/0x12d790. Attribute identity is cached in vals. */
bool jbed_pool_attribute(JbedPool *pool, uint16_t index, JbedAttribute *attribute, JbedError *error)
{
    static const char *const names[] = {
        "Code",         "StackMap",      "Exceptions",      "SourceFile",
        "InnerClasses", "ConstantValue", "LineNumberTable", "LocalVariableTable"};
    if (!index || index >= pool->count || pool->tags[index] != JBED_POOL_UTF8 || !pool->utf8)
        return pool_format_error(pool, error);
    uint32_t cached = pool->values[index];
    if (!cached) {
        cached = 9;
        for (size_t i = 0; i < sizeof(names) / sizeof(names[0]); ++i) {
            size_t length = strlen(names[i]);
            if (pool->utf8[index].length == length &&
                !memcmp(pool->utf8[index].bytes, names[i], length)) {
                cached = (uint32_t)i + 1;
                break;
            }
        }
        pool->values[index] = cached;
    }
    *attribute = cached <= 8 ? (JbedAttribute)cached : JBED_ATTRIBUTE_UNKNOWN;
    return true;
}

/* Pool.markFieldIds/markMethodIds, 0x12d72c/0x12d75e. */
bool jbed_pool_mark_field(JbedPool *pool, const JbedField *field, JbedError *error)
{
    return check_tag(pool, field->name_id, JBED_POOL_UTF8, UTF8_FIELD_NAME, error) &&
           check_tag(pool, field->type_id, JBED_POOL_UTF8, UTF8_FIELD_TYPE, error);
}

bool jbed_pool_mark_method(JbedPool *pool, const JbedMethod *method, JbedError *error)
{
    return check_tag(pool, method->name_id, JBED_POOL_UTF8, UTF8_METHOD_NAME, error) &&
           check_tag(pool, method->signature_id, JBED_POOL_UTF8, UTF8_METHOD_SIGNATURE, error);
}

/* Pool.primTypeFromCharacter, 0x12c74c; primitiveType, 0x12c7be. */
bool jbed_pool_primitive_character(JbedEmitter *emitter, uint16_t character, JbedTypeId *type,
                                   JbedError *error)
{
    switch (character) {
    case 'Z':
        *type = 4;
        return true;
    case 'B':
        *type = 8;
        return true;
    case 'C':
        *type = 5;
        return true;
    case 'S':
        *type = 9;
        return true;
    case 'I':
        *type = 10;
        return true;
    case 'J':
        *type = 11;
        return true;
    case 'F':
        *type = 6;
        return true;
    case 'D':
        *type = 7;
        return true;
    default: {
        JbedError failure = jbed_emitter_error(emitter, JBED_EMITTER_CLASS_FORMAT, 0, 0, 0, 0);
        if (error)
            *error = failure;
        return false;
    }
    }
}

JbedTypeId jbed_pool_primitive_type(JbedTypeId type)
{
    return type >= 16 ? 2 : type;
}

/* Pool.badVisibilityFlags, 0x12e014. The isPublic/isPrivate/isProtected/
 * isStatic/isSuper/isInterface/isAbstract/isConstructor helpers at 0x12c6ec–
 * 0x12c74c are represented by the same direct bit tests at their call sites. */
bool jbed_pool_bad_visibility(uint32_t flags)
{
    uint32_t visibility = flags & (JBED_ACC_PUBLIC | JBED_ACC_PRIVATE | JBED_ACC_PROTECTED);
    return (visibility & (visibility - 1)) != 0;
}

static void ensure_characters(JbedPool *pool, size_t extra)
{
    if (extra <= pool->character_capacity - pool->character_count)
        return;
    size_t capacity = pool->character_capacity * 2;
    if (capacity < pool->character_count + extra)
        capacity = pool->character_count + extra;
    uint16_t *characters = pool_alloc(pool, capacity, sizeof(*characters));
    if (pool->character_count)
        memcpy(characters, pool->characters, pool->character_count * sizeof(*characters));
    pool->characters = characters;
    pool->character_capacity = capacity;
}

/* The original decoder deliberately does not validate continuation-byte
 * prefixes. Preserve its 1/2/3-byte masks and its two-byte zero padding. */
static bool decode_character(JbedPool *pool, const JbedPoolUtf8 *utf8, size_t *position,
                             uint16_t *value, JbedError *error)
{
    size_t i = *position;
    if (i >= (size_t)utf8->length + 2)
        return pool_format_error(pool, error);
    uint8_t lead = utf8->bytes[i++];
    if (lead < 0x80) {
        if (!lead)
            return pool_format_error(pool, error);
        *value = lead;
    } else if (lead < 0xe0) {
        if (i >= (size_t)utf8->length + 2)
            return pool_format_error(pool, error);
        *value = (uint16_t)((lead & 31) << 6 | (utf8->bytes[i++] & 63));
    } else {
        if (i + 1 >= (size_t)utf8->length + 2)
            return pool_format_error(pool, error);
        *value =
            (uint16_t)((lead & 15) << 12 | (utf8->bytes[i] & 63) << 6 | (utf8->bytes[i + 1] & 63));
        i += 2;
    }
    *position = i;
    return true;
}

static bool name_character(uint16_t ch)
{
    return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9') ||
           ch == '_' || ch == '$' || ch <= 8 || (ch >= 14 && ch <= 27) || ch >= 127;
}

/* Pool.checkUtf8Type, 0x12e760. States: 0=text, 1=descriptor,
 * 2=array component, 3=class name, 4=identifier/class-name body. */
static bool check_utf8_type(JbedPool *pool, const JbedPoolUtf8 *utf8, size_t start, int state,
                            size_t *end, JbedError *error)
{
    pool->last_slash = 0;
    size_t position = start;
    while (position < utf8->length) {
        size_t previous = position;
        uint16_t ch;
        if (!decode_character(pool, utf8, &position, &ch, error))
            return false;
        ensure_characters(pool, 1);
        pool->characters[pool->character_count++] = ch;
        if (state == 1 || state == 3) {
            pool->parsed_dimensions = 0;
            pool->type_end = pool->type_start = 0;
            pool->parsed_type = 0;
            if (ch == '[') {
                pool->parsed_dimensions = 1;
                state = 2;
                continue;
            }
            if (state == 1) {
                if (ch == 'L') {
                    pool->type_start = position;
                    state = 4;
                    continue;
                }
                if (!jbed_pool_primitive_character(pool->services->emitter, ch, &pool->parsed_type,
                                                   error))
                    return false;
                *end = position;
                return true;
            }
            pool->type_start = previous;
            state = 4;
        } else if (state == 2) {
            if (ch == 'L') {
                pool->type_start = position;
                state = 4;
                continue;
            }
            if (ch == '[') {
                if (++pool->parsed_dimensions > 255)
                    return pool_format_error(pool, error);
                continue;
            }
            if (!jbed_pool_primitive_character(pool->services->emitter, ch, &pool->parsed_type,
                                               error))
                return false;
            *end = position;
            return true;
        }
        if (state != 4 || name_character(ch))
            continue;
        if (ch == '/') {
            if (pool->type_start == previous ||
                (pool->last_slash && pool->last_slash == previous - 1))
                return pool_format_error(pool, error);
            pool->last_slash = previous;
        } else if (ch == ';') {
            pool->type_end = previous;
            *end = position;
            return true;
        } else {
            return pool_format_error(pool, error);
        }
    }
    *end = position;
    return true;
}

static bool class_name_id(const JbedPoolServices *s, const uint8_t *data, size_t start, size_t end,
                          size_t slash, uint16_t dimensions, JbedTypeId *id, JbedError *error)
{
    if (s->class_id)
        return s->class_id(s->context, data, start, end, slash, dimensions, id, error);
    if (!s->class_access)
        return pool_error(error, JBED_ERROR_INTERNAL, "Missing class-name interner");
    *id = jbed_class_name_id(s->class_access, data, start, end, slash, dimensions);
    return true;
}

static bool load_class(const JbedPoolServices *s, JbedTypeId id, JbedClass **klass, JbedError *error)
{
    if (s->load_class)
        return s->load_class(s->context, id, klass, error);
    if (!s->class_access)
        return pool_error(error, JBED_ERROR_INTERNAL, "Missing class loader");
    *klass = jbed_class_object(s->class_access, id);
    return true;
}

static bool parsed_type_id(JbedPool *pool, const JbedPoolUtf8 *utf8, bool descriptor,
                           JbedTypeId *type, JbedError *error)
{
    const JbedPoolServices *svc = pool->services;
    if (pool->parsed_type) {
        *type = pool->parsed_type;
        if (!pool->parsed_dimensions)
            return true;
        if (svc->primitive_array_id)
            return svc->primitive_array_id(svc->context, *type, pool->parsed_dimensions, type, error);
        if (!svc->class_access)
            return pool_error(error, JBED_ERROR_INTERNAL, "Missing primitive-array interner");
        *type = jbed_class_primitive_array(svc->class_access, *type, pool->parsed_dimensions);
        return true;
    }
    if (descriptor || pool->parsed_dimensions) {
        if (!pool->type_end)
            return pool_format_error(pool, error);
    } else {
        if (pool->type_end)
            return pool_format_error(pool, error);
        pool->type_end = utf8->length;
    }
    return class_name_id(svc, utf8->bytes, pool->type_start, pool->type_end, pool->last_slash,
                         pool->parsed_dimensions, type, error);
}

/* Pool.resolveUtf8Signature, 0x12e486. SignatureEncoder owns the resulting
 * signature ID; this function preserves Reader's descriptor state machine. */
static bool resolve_signature(JbedPool *pool, const JbedPoolUtf8 *utf8, uint32_t *signature,
                              JbedError *error)
{
    const JbedPoolServices *svc = pool->services;
    JbedTypeId *arguments = pool_alloc(pool, (size_t)utf8->length + 1, sizeof(*arguments));
    size_t count = 0, position = 0;
    unsigned state = 0;
    bool returns_void = false;
    JbedTypeId return_type = 0;
    while (position < utf8->length) {
        size_t previous = position;
        uint16_t ch;
        if (!decode_character(pool, utf8, &position, &ch, error))
            return false;
        ensure_characters(pool, 1);
        pool->characters[pool->character_count++] = ch;
        if (!state) {
            if (ch != '(')
                return pool_format_error(pool, error);
            state = 1;
            continue;
        }
        if (state == 3)
            return pool_format_error(pool, error);
        if (ch == ')') {
            if (state != 1)
                return pool_format_error(pool, error);
            state = 2;
            continue;
        }
        JbedTypeId type;
        if (ch == 'V') {
            if (state != 2)
                return pool_format_error(pool, error);
            returns_void = true;
            state = 3;
            continue;
        }
        if (ch == 'L' || ch == '[') {
            --pool->character_count;
            if (!check_utf8_type(pool, utf8, previous, 1, &position, error))
                return false;
            if (!pool->parsed_type && pool->type_start == pool->type_end)
                return pool_format_error(pool, error);
            if (!parsed_type_id(pool, utf8, true, &type, error))
                return false;
        } else if (!jbed_pool_primitive_character(pool->services->emitter, ch, &type, error)) {
            return false;
        }
        if (state == 1)
            arguments[count++] = type;
        else {
            return_type = type;
            state = 3;
        }
    }
    if (state != 3 || position != utf8->length)
        return pool_format_error(pool, error);
    JbedSignatureId id;
    if (svc->signature_id) {
        if (!svc->signature_id(svc->context, arguments, count, return_type, returns_void, &id, error))
            return false;
    } else if (svc->signature_encoder) {
        id = jbed_signature_build_types(svc->signature_encoder, arguments, count, return_type,
                                        returns_void);
    } else {
        return pool_error(error, JBED_ERROR_INTERNAL, "Missing signature encoder");
    }
    *signature = id | (returns_void ? SIGNATURE_RETURNS_VOID : 0);
    return true;
}

static bool member_name(const JbedPoolServices *svc, bool method, const JbedPoolUtf8 *utf8,
                        bool create, JbedNameId *name, JbedError *error)
{
    if (svc->name_id)
        return svc->name_id(svc->context, method, utf8->bytes, utf8->length, create, name, error);
    JbedReflectionTable *table = method ? svc->method_names : svc->field_names;
    if (!table)
        return pool_error(error, JBED_ERROR_INTERNAL, "Missing reflection name table");
    *name = jbed_reflection_id(table, utf8->bytes, utf8->length, create);
    return true;
}

/* Pool.resolveUtf8, 0x12e026. The existing-name fast path is significant:
 * it recognizes <init>/<clinit> before ordinary identifier validation. */
static bool resolve_utf8(JbedPool *pool, uint32_t index, JbedError *error)
{
    const JbedPoolServices *svc = pool->services;
    JbedPoolUtf8 *utf8 = &pool->utf8[index];
    JbedPoolUtf8Info *info = &pool->utf8_info[index];
    uint8_t use = pool->resolve_flags[index];
    bool needs_name = use & (UTF8_FIELD_NAME | UTF8_METHOD_NAME);
    bool needs_type = use & (UTF8_CLASS_NAME | UTF8_FIELD_TYPE);
    bool found = false;
    JbedNameId field_name = (uint16_t)info->names, method_name = (uint16_t)(info->names >> 16);
    if (needs_name) {
        if (use & UTF8_FIELD_NAME) {
            if (!member_name(svc, false, utf8, false, &field_name, error))
                return false;
            found = field_name != 0;
        }
        if (use & UTF8_METHOD_NAME) {
            if (!member_name(svc, true, utf8, found, &method_name, error))
                return false;
            if (method_name) {
                if ((method_name == JBED_NAME_INIT || method_name == JBED_NAME_CLINIT) &&
                    (use & (UTF8_CLASS_NAME | UTF8_FIELD_NAME | UTF8_FIELD_TYPE)))
                    return pool_format_error(pool, error);
                if (method_name == JBED_NAME_CLINIT && (use & UTF8_REFERENCED_METHOD))
                    return pool_format_error(pool, error);
                if (!found && (use & UTF8_FIELD_NAME) &&
                    !member_name(svc, false, utf8, true, &field_name, error))
                    return false;
                found = true;
            }
        }
        if (found) {
            info->names = (uint32_t)method_name << 16 | field_name;
            if (use & UTF8_FIELD_TYPE) {
                if (utf8->length != 1)
                    return pool_format_error(pool, error);
                if (!jbed_pool_primitive_character(pool->services->emitter, utf8->bytes[0],
                                                   &info->type_or_signature, error))
                    return false;
            }
            if (use & UTF8_CLASS_NAME) {
                if (!class_name_id(svc, utf8->bytes, 0, utf8->length, 0, 0, &info->class_id, error))
                    return false;
            }
            if (!(use & UTF8_STRING))
                return true;
            needs_name = needs_type = false;
        }
    }
    size_t end;
    if (needs_type) {
        bool descriptor = (use & UTF8_FIELD_TYPE) != 0;
        if (!check_utf8_type(pool, utf8, 0, descriptor ? 1 : 3, &end, error))
            return false;
        if (end != utf8->length)
            return pool_format_error(pool, error);
        JbedTypeId type;
        if (!parsed_type_id(pool, utf8, descriptor, &type, error))
            return false;
        if (descriptor) {
            if (needs_name && type >= 16)
                return pool_format_error(pool, error);
            info->type_or_signature = type;
            if (use & UTF8_CLASS_NAME) {
                if (pool->parsed_dimensions)
                    info->class_id = type;
                else {
                    if (type >= 16)
                        return pool_format_error(pool, error);
                    if (!class_name_id(svc, utf8->bytes, 0, utf8->length, 0, 0, &info->class_id, error))
                        return false;
                }
            }
        } else {
            if (needs_name && pool->last_slash)
                return pool_format_error(pool, error);
            info->class_id = type;
        }
    }
    if (needs_name) {
        if (!needs_type) {
            if (!check_utf8_type(pool, utf8, 0, 4, &end, error))
                return false;
            if (end != utf8->length || pool->last_slash)
                return pool_format_error(pool, error);
        }
        if ((use & UTF8_METHOD_NAME) &&
            !member_name(svc, true, utf8, true, &method_name, error))
            return false;
        if ((use & UTF8_FIELD_NAME) &&
            !member_name(svc, false, utf8, true, &field_name, error))
            return false;
        info->names = (uint32_t)method_name << 16 | field_name;
    } else if (!needs_type) {
        if (!check_utf8_type(pool, utf8, 0, 0, &end, error))
            return false;
        if (end != utf8->length)
            return pool_format_error(pool, error);
    }
    return true;
}

/* Pool.resolveUtf8s, 0x12d9b0. Only newly interned strings retain their segment
 * of the shared UTF16 buffer; other parses rewind the character cursor. */
static bool resolve_utf8s(JbedPool *pool, JbedError *error)
{
    JbedVmStrings *strings = pool->services->intern_string ? NULL : pool->services->vm_strings;
    pool->character_capacity = 1024;
    if (strings && !jbed_vm_pool_character_buffer(strings, 0, pool->character_capacity, error))
        return false;
    pool->characters = pool_alloc(pool, 1024, sizeof(*pool->characters));
    for (uint32_t i = 1; i < pool->count; ++i) {
        if (pool->tags[i] != JBED_POOL_UTF8)
            continue;
        size_t start = pool->character_count;
        size_t capacity = pool->character_capacity;
        ensure_characters(pool, pool->utf8[i].length);
        if (strings && capacity != pool->character_capacity &&
            !jbed_vm_pool_character_buffer(strings, start, pool->character_capacity, error))
            return false;
        uint8_t use = pool->resolve_flags[i];
        if (use & UTF8_METHOD_SIGNATURE) {
            if (use & (UTF8_CLASS_NAME | UTF8_FIELD_NAME | UTF8_FIELD_TYPE | UTF8_METHOD_NAME))
                return pool_format_error(pool, error);
            if (!resolve_signature(pool, &pool->utf8[i], &pool->utf8_info[i].type_or_signature,
                                   error))
                return false;
        } else if (!resolve_utf8(pool, i, error))
            return false;
        if (use & UTF8_STRING) {
            JbedPoolString *string;
            bool retained;
            if (strings) {
                if (!jbed_vm_pool_intern(pool, start, &string, &retained, error))
                    return false;
            } else {
                if (!pool->services->intern_string)
                    return pool_error(error, JBED_ERROR_INTERNAL, "Missing string interner");
                if (!pool->services->intern_string(pool->services->context, pool->characters + start,
                                                   pool->character_count - start, &string, &retained,
                                                   error))
                    return false;
            }
            if (pool->object_position >= pool->object_count)
                return pool_format_error(pool, error);
            pool->objects[pool->object_position].string = string;
            pool->utf8_info[i].string_index = (uint32_t)pool->object_position++;
            if (!retained)
                pool->character_count = start;
        } else {
            pool->character_count = start;
        }
    }
    if (strings)
        jbed_vm_pool_finish_characters(strings, (uint32_t)pool->character_count);
    pool->utf8 = NULL;
    return true;
}

/* Pool.resolveIds, 0x12db88: NameAndType low half either contains the type ID
 * or indexes the separate type_ids array with bit 15 set. */
static bool resolve_ids(JbedPool *pool, JbedError *error)
{
    pool->type_ids = pool_alloc(pool, pool->count, sizeof(*pool->type_ids));
    for (uint32_t i = 1; i < pool->count; ++i) {
        uint32_t value = pool->values[i];
        if (pool->tags[i] == JBED_POOL_CLASS)
            pool->values[i] = pool->utf8_info[value].class_id;
        else if (pool->tags[i] == JBED_POOL_STRING)
            pool->values[i] = pool->utf8_info[value].string_index;
        else if (pool->tags[i] == JBED_POOL_NAME_AND_TYPE) {
            JbedPoolUtf8Info *name = &pool->utf8_info[value >> 16];
            uint32_t type = pool->utf8_info[(uint16_t)value].type_or_signature;
            if (pool->resolve_flags[i] == NAME_TYPE_FIELD) {
                if (type >> 15) {
                    pool->type_ids[pool->type_id_count] = type;
                    type = (uint32_t)pool->type_id_count++ | 0x8000;
                }
                pool->values[i] = (name->names << 16) | type;
            } else if (pool->resolve_flags[i] == NAME_TYPE_METHOD) {
                if ((name->names >> 16) == JBED_NAME_INIT && !(type & SIGNATURE_RETURNS_VOID))
                    return pool_format_error(pool, error);
                pool->values[i] = (name->names & 0xffff0000) | (uint16_t)type;
            }
        }
    }
    pool->resolve_flags = NULL;
    return true;
}

/* Pool.resolve/readComplete, 0x12c6a4/0x12c6c0. */
bool jbed_pool_resolve(JbedPool *pool, JbedError *error)
{
    return resolve_utf8s(pool, error) && resolve_ids(pool, error);
}

void jbed_pool_read_complete(JbedPool *pool)
{
    pool->utf8_info = NULL;
}

/* Pool.constType/constVal, 0x12c820/0x12c87c. Wide constants retain the
 * classfile's high-word/low-word order in adjacent pool slots. */
bool jbed_pool_constant_type(JbedPool *pool, uint32_t index, JbedTypeId *type, JbedError *error)
{
    if (index >= pool->count)
        return pool_diagnostic(pool, error, JBED_EMITTER_VERIFY, 0, 0, 0);
    switch (pool->tags[index]) {
    case JBED_POOL_INTEGER:
        *type = 10;
        return true;
    case JBED_POOL_FLOAT:
        *type = 6;
        return true;
    case JBED_POOL_LONG:
        *type = 11;
        return true;
    case JBED_POOL_DOUBLE:
        *type = 7;
        return true;
    case JBED_POOL_STRING:
        *type = 2;
        return true;
    case JBED_POOL_CLASS:
    case JBED_POOL_CACHED_CLASS:
        if (pool->services->boot_image) {
            *type = JBED_TYPE_REFERENCE;
            return true;
        }
        return pool_diagnostic(pool, error, JBED_EMITTER_VERIFY, 0, 0, 0);
    default:
        return pool_diagnostic(pool, error, JBED_EMITTER_VERIFY, 0, 0, 0);
    }
}

bool jbed_pool_constant_word(JbedPool *pool, uint32_t index, uint32_t *word, JbedError *error)
{
    if (index >= pool->count)
        return pool_error(error, JBED_ERROR_ARRAY_INDEX, "Invalid constant index");
    *word = pool->values[index];
    if (pool->tags[index] == JBED_POOL_STRING) {
        if (*word >= pool->object_count || !pool->objects[*word].string)
            return pool_error(error, JBED_ERROR_INTERNAL, "Unresolved string constant");
        *word = pool->objects[*word].string->address;
    } else if ((pool->tags[index] & 15) == JBED_POOL_CLASS && pool->services->boot_image) {
        JbedClass *klass;
        if (!pool->services->class_object_address)
            return pool_error(error, JBED_ERROR_INTERNAL, "Missing boot class address service");
        if (!jbed_pool_class(pool, index, false, &klass, error)) return false;
        *word = pool->services->class_object_address(pool->services->context, klass);
    }
    return true;
}

/* Pool.nameId/typeId/signatureId, 0x12c8f4/0x12c91a/0x12c968. */
bool jbed_pool_name_id(JbedPool *pool, uint32_t index, JbedNameId *name, JbedError *error)
{
    if (index >= pool->count)
        return pool_error(error, JBED_ERROR_ARRAY_INDEX, "Invalid name index");
    *name = (uint16_t)(pool->values[index] >> 16);
    return true;
}

bool jbed_pool_type_id(JbedPool *pool, uint32_t index, JbedTypeId *type, JbedError *error)
{
    if (index >= pool->count)
        return pool_error(error, JBED_ERROR_ARRAY_INDEX, "Invalid type index");
    uint16_t value = (uint16_t)pool->values[index];
    if (value & 0x8000) {
        if ((value & 0x7fff) >= pool->type_id_count)
            return pool_error(error, JBED_ERROR_ARRAY_INDEX, "Invalid extended type index");
        *type = pool->type_ids[value & 0x7fff];
    } else
        *type = value;
    return true;
}

bool jbed_pool_signature_id(JbedPool *pool, uint32_t index, JbedSignatureId *signature,
                            JbedError *error)
{
    if (index >= pool->count)
        return pool_error(error, JBED_ERROR_ARRAY_INDEX, "Invalid signature index");
    *signature = (uint16_t)pool->values[index];
    return true;
}

/* Pool.classId, 0x12ca20. Tag 0x17 is a cached class object, not a new CP tag. */
bool jbed_pool_class_id(JbedPool *pool, uint32_t index, JbedTypeId *id, JbedError *error)
{
    if (!index || index >= pool->count || (pool->tags[index] & 15) != JBED_POOL_CLASS)
        return pool_format_error(pool, error);
    *id = pool->values[index];
    if (pool->tags[index] == JBED_POOL_CACHED_CLASS) {
        if (*id >= pool->object_count || !pool->objects[*id].class_object)
            return pool_error(error, JBED_ERROR_INTERNAL, "Invalid cached class");
        *id = pool->objects[*id].class_object->id;
    }
    return true;
}

/* Pool.resolveClassIds, 0x12dd8c. */
bool jbed_pool_resolve_class_ids(JbedPool *pool, uint16_t self, uint16_t super,
                                 uint16_t *interfaces, size_t count, JbedError *error)
{
    JbedTypeId id;
    if (!jbed_pool_class_id(pool, self, &id, error))
        return false;
    if (id != pool->owner->id) {
        return pool_diagnostic(pool, error, JBED_EMITTER_NO_CLASS, pool->owner->id, 0, 0);
    }
    /* A boot-image compilation includes Object itself; suite compilation only
     * sees subclasses of the resident Object. */
    if (!super && id == JBED_ROM_CLASS_OBJECT)
        pool->owner->unresolved_super_id = 0;
    else if (!jbed_pool_class_id(pool, super, &pool->owner->unresolved_super_id, error))
        return false;
    pool->owner->unresolved_interface_count = count;
    if (count) {
        pool->owner->unresolved_interface_ids = pool_alloc(pool, count, sizeof(JbedTypeId));
        for (size_t i = 0; i < count; ++i)
            if (!jbed_pool_class_id(pool, interfaces[i], &pool->owner->unresolved_interface_ids[i],
                                    error))
                return false;
    }
    return true;
}

/* Pool.resolveFieldIds, 0x12ddfc. */
bool jbed_pool_resolve_field_ids(JbedPool *pool, JbedField *field, JbedError *error)
{
    if (!pool->utf8_info)
        return pool_error(error, JBED_ERROR_NULL_POINTER, "Missing field-name resolution data");
    if (field->name_id >= pool->count || field->type_id >= pool->count)
        return pool_error(error, JBED_ERROR_ARRAY_INDEX, "Invalid field name or type index");
    const uint32_t interface_flags = JBED_ACC_PUBLIC | JBED_ACC_STATIC | JBED_ACC_FINAL;
    const uint32_t final_volatile = JBED_ACC_FINAL | JBED_ACC_VOLATILE;
    if (((field->owner->flags & JBED_ACC_INTERFACE) && (field->flags & 0xff) != interface_flags) ||
        jbed_pool_bad_visibility(field->flags) || (field->flags & final_volatile) == final_volatile)
        return pool_format_error(pool, error);
    field->name_id = (uint16_t)pool->utf8_info[field->name_id].names;
    field->type_id = pool->utf8_info[field->type_id].type_or_signature;
    if (field->constant_index) {
        JbedTypeId expected = 2, actual;
        if (field->type_id < 4 || field->type_id > 11) {
            if (field->type_id != 466)
                return pool_format_error(pool, error);
        } else {
            expected = field->type_id % 4 < 2 ? 10 : field->type_id;
        }
        if (!jbed_pool_constant_type(pool, field->constant_index, &actual, error))
            return false;
        if (expected != actual)
            return pool_format_error(pool, error);
        uint32_t first, second;
        if (!jbed_pool_constant_word(pool, field->constant_index, &first, error))
            return false;
        field->constant_value = first;
        if (expected % 4 == 3) {
            if (!jbed_pool_constant_word(pool, field->constant_index + 1, &second, error))
                return false;
            field->constant_value = (uint64_t)first << 32 | second;
        }
    }
    return true;
}

/* Pool.resolveMethodIds, 0x12def4. */
bool jbed_pool_resolve_method_ids(JbedPool *pool, JbedMethod *method, JbedError *error)
{
    if (!pool->utf8_info)
        return pool_error(error, JBED_ERROR_NULL_POINTER, "Missing method-name resolution data");
    if (method->name_id >= pool->count || method->signature_id >= pool->count)
        return pool_error(error, JBED_ERROR_ARRAY_INDEX, "Invalid method name or signature index");
    method->name_id = (uint16_t)(pool->utf8_info[method->name_id].names >> 16);
    uint32_t signature = pool->utf8_info[method->signature_id].type_or_signature;
    method->signature_id = (uint16_t)signature;
    const uint32_t no_code = JBED_ACC_NATIVE | JBED_ACC_ABSTRACT;
    const uint32_t ctor_forbidden = no_code | JBED_ACC_STATIC | JBED_ACC_FINAL | JBED_ACC_SYNCHRONIZED;
    if (method->name_id == JBED_NAME_CLINIT && method->signature_id == JBED_SIGNATURE_VOID_NO_ARGS) {
        method->flags &= ~(ctor_forbidden | JBED_ACC_PUBLIC | JBED_ACC_PRIVATE | JBED_ACC_PROTECTED);
        method->flags |= JBED_METHOD_CLASS_INITIALIZER | JBED_ACC_STATIC;
        method->dispatch_slot = (int16_t)pool->owner->static_initializer_count;
        pool->owner->static_initializer_count = 0;
        if (!method->code)
            return pool_format_error(pool, error);
    } else {
        if (method->name_id == JBED_NAME_INIT) {
            if ((method->flags & ctor_forbidden) || !(signature & SIGNATURE_RETURNS_VOID))
                return pool_format_error(pool, error);
            method->flags |= JBED_METHOD_CONSTRUCTOR;
        }
        const uint32_t interface_flags = JBED_ACC_PUBLIC | JBED_ACC_ABSTRACT;
        if ((pool->owner->flags & JBED_ACC_INTERFACE) &&
            (method->flags & interface_flags) != interface_flags)
            return pool_format_error(pool, error);
    }
    const uint32_t abstract_forbidden = JBED_ACC_PRIVATE | JBED_ACC_STATIC | JBED_ACC_FINAL |
                                        JBED_ACC_SYNCHRONIZED | JBED_ACC_NATIVE | JBED_ACC_STRICT;
    if (((method->flags & JBED_ACC_ABSTRACT) && (method->flags & abstract_forbidden)) ||
        jbed_pool_bad_visibility(method->flags) || ((method->flags & no_code) && method->code))
        return pool_format_error(pool, error);
    return true;
}

/* Pool.samePackage/accessible/checkAccess, 0x12c7cc/0x12c990/0x12c9ee. */
bool jbed_pool_same_package(JbedPool *pool, const JbedClass *a, const JbedClass *b, bool *same,
                            JbedError *error)
{
    if (!pool->services->package_id) {
        if (!pool->services->class_access)
            return pool_error(error, JBED_ERROR_INTERNAL, "Missing package-ID lookup");
        JbedClassAccess *access = pool->services->class_access;
        *same = jbed_class_params(access, a->id).package_id == jbed_class_params(access, b->id).package_id;
        return true;
    }
    uint16_t first, second;
    if (!pool->services->package_id(pool->services->context, a->id, &first, error) ||
        !pool->services->package_id(pool->services->context, b->id, &second, error))
        return false;
    *same = first == second;
    return true;
}

bool jbed_pool_trusted_access(const JbedPool *pool, const JbedClass *from, const JbedClass *owner)
{
    const JbedPoolServices *services = pool->services;
    return services->trusted_access && services->trusted_access(services->context, from, owner);
}

bool jbed_pool_accessible(JbedPool *pool, const JbedClass *from, const JbedClass *owner,
                          uint32_t flags, bool *accessible, JbedError *error)
{
    *accessible = true;
    if ((flags & JBED_ACC_PUBLIC) || from == owner || jbed_pool_trusted_access(pool, from, owner))
        return true;
    if (flags & JBED_ACC_PROTECTED) {
        if (!jbed_vm_pool_assignable(pool->services, owner, from, accessible, error))
            return false;
        if (*accessible)
            return true;
    }
    *accessible = false;
    if (flags & JBED_ACC_PRIVATE)
        return true;
    return jbed_pool_same_package(pool, owner, from, accessible, error);
}

bool jbed_pool_check_access(JbedPool *pool, const JbedClass *from, const JbedClass *owner,
                            uint32_t flags, JbedError *error)
{
    bool accessible;
    if (!jbed_pool_accessible(pool, from, owner, flags, &accessible, error))
        return false;
    if (accessible)
        return true;
    return pool_diagnostic(pool, error, JBED_EMITTER_INCOMPATIBLE_CLASS, owner->id, 0, 0);
}

/* Pool.classObj, 0x12cab0. Failed class preparation is rethrown from the
 * class's saved Error even when the constant has already been cached. */
bool jbed_pool_class(JbedPool *pool, uint32_t index, bool allow_missing, JbedClass **klass,
                     JbedError *error)
{
    JbedTypeId id;
    if (!jbed_pool_class_id(pool, index, &id, error))
        return false;
    if (pool->tags[index] == JBED_POOL_CACHED_CLASS) {
        *klass = pool->objects[pool->values[index]].class_object;
    } else {
        if (!load_class(pool->services, id, klass, error))
            return false;
        if (!*klass) {
            if (allow_missing)
                return true;
            return pool_diagnostic(pool, error, JBED_EMITTER_NO_CLASS, id, 0, 0);
        }
        if (!jbed_pool_check_access(pool, pool->owner, *klass, (*klass)->flags & ~JBED_ACC_PRIVATE,
                                    error))
            return false;
        if (pool->object_position >= pool->object_count)
            return pool_error(error, JBED_ERROR_INTERNAL, "Class object-table overflow");
        pool->values[index] = (uint32_t)pool->object_position;
        pool->objects[pool->object_position++].class_object = *klass;
        pool->tags[index] = JBED_POOL_CACHED_CLASS;
    }
    if ((*klass)->instance_size < 0) {
        if (!(*klass)->has_error)
            return pool_error(error, JBED_ERROR_NULL_POINTER,
                              "Failed class has no saved exception");
        if (!(*klass)->error.is_java_error)
            return pool_error(error, JBED_ERROR_CLASS_CAST,
                              "Saved throwable is not java.lang.Error");
        if (error)
            *error = jbed_class_error(*klass);
        return false;
    }
    return true;
}

/* Pool.arrayOfClass/arrayOfType, 0x12cbe4/0x12cc64. */
bool jbed_pool_array_of_class(JbedPool *pool, uint32_t index, JbedClass **array, JbedError *error)
{
    JbedClass *component;
    JbedTypeId id;
    const JbedPoolServices *svc = pool->services;
    if (!jbed_pool_class(pool, index, false, &component, error))
        return false;
    if (svc->array_class_id) {
        if (!svc->array_class_id(svc->context, component->id, &id, error))
            return false;
    } else if (svc->class_access) {
        id = jbed_class_array_of(svc->class_access, component->id);
    } else {
        return pool_error(error, JBED_ERROR_INTERNAL, "Missing array-class resolver");
    }
    if (!load_class(svc, id, array, error))
        return false;
    if (!*array)
        jbed_halt(svc->runtime, 0, "Array class resolution failed");
    return jbed_pool_check_access(pool, pool->owner, *array, (*array)->flags & ~JBED_ACC_PRIVATE,
                                  error);
}

bool jbed_pool_array_of_type(JbedPool *pool, JbedTypeId type, JbedClass **array, JbedError *error)
{
    *array = NULL;
    if (type < 4 || type > 11)
        return true;
    *array = pool->services->primitive_array_classes[type - 4];
    if (!*array && pool->services->class_access) {
        JbedClassAccess *access = pool->services->class_access;
        *array = jbed_class_object(access, jbed_class_primitive_array(access, type, 1));
    }
    if (!*array)
        return pool_error(error, JBED_ERROR_INTERNAL, "Missing resident primitive-array class");
    return true;
}

/* Pool.searchMethod/searchField/resolveMethod/resolveField,
 * 0x12cd00/0x12d060/0x12cd62/0x12d0c2. */
static bool search_method(JbedPool *pool, JbedClass *klass, JbedNameId name,
                          JbedSignatureId signature, JbedMethod **method, JbedError *error)
{
    if (!jbed_vm_find_method(pool->services, klass, name, signature, method, error))
        return false;
    for (size_t i = 0; !*method && i < klass->interface_count; ++i)
        if (!search_method(pool, klass->interfaces[i], name, signature, method, error))
            return false;
    return true;
}

static bool search_field(JbedPool *pool, JbedClass *klass, JbedNameId name, JbedTypeId type,
                         JbedField **field, JbedError *error)
{
    if (!jbed_vm_find_field(pool->services, klass, name, type, field, error))
        return false;
    for (size_t i = 0; !*field && i < klass->interface_count; ++i)
        if (!search_field(pool, klass->interfaces[i], name, type, field, error))
            return false;
    return true;
}

static bool resolve_method(JbedPool *pool, JbedClass *klass, JbedNameId name,
                           JbedSignatureId signature, JbedMethod **method, JbedError *error)
{
    *method = NULL;
    for (JbedClass *base = klass; base && !*method; base = base->superclass)
        if (!jbed_vm_find_method(pool->services, base, name, signature, method, error))
            return false;
    for (; klass && !*method; klass = klass->superclass)
        if (!search_method(pool, klass, name, signature, method, error))
            return false;
    return true;
}

static bool resolve_field(JbedPool *pool, JbedClass *klass, JbedNameId name, JbedTypeId type,
                          JbedField **field, JbedError *error)
{
    *field = NULL;
    for (; klass && !*field; klass = klass->superclass)
        if (!search_field(pool, klass, name, type, field, error))
            return false;
    return true;
}

/* Pool.getErrorAddress, 0x12cdae. */
uint32_t jbed_pool_error_address(const JbedPool *pool, const JbedError *error)
{
    return !error || error->kind == JBED_ERROR_NONE || error->kind == JBED_ERROR_NO_CLASS_DEF
               ? pool->services->throw_no_class_address
               : pool->services->throw_abstract_address;
}

/* Pool.method and Pool.field use this.getClass() as the owner when the
 * referenced class itself could not be resolved. Pool is ROM class 47. */
static bool deferred_owner(const JbedPoolServices *services, JbedClass **owner, JbedError *error)
{
    if (!*owner) {
        *owner = services->pool_runtime_class;
        if (!*owner && !load_class(services, 47, owner, error))
            return false;
    }
    return *owner || pool_error(error, JBED_ERROR_INTERNAL, "Missing runtime Pool class");
}

/* Pool.method, 0x12cdd8; catch blocks 0x12cf6c–0x12cffa explicitly create
 * a method whose entry throws a deferred linkage error. OOM is rethrown. */
bool jbed_pool_method(JbedPool *pool, uint32_t index, uint32_t expected, JbedMethod **method,
                      JbedError *error)
{
    JbedNameId name = 0;
    JbedSignatureId signature = 0;
    JbedClass *klass = NULL;
    JbedError caught = {0};
    const JbedPoolServices *svc = pool->services;
    if (index >= pool->count) {
        pool_error(&caught, JBED_ERROR_ARRAY_INDEX, "Invalid method reference");
        goto deferred;
    }
    uint16_t nt = (uint16_t)pool->values[index];
    if (!jbed_pool_name_id(pool, nt, &name, &caught) ||
        !jbed_pool_signature_id(pool, nt, &signature, &caught) ||
        !jbed_pool_class(pool, pool->values[index] >> 16, false, &klass, &caught))
        goto deferred;
    if ((klass->flags ^ expected) & JBED_ACC_INTERFACE) {
        pool_diagnostic(pool, &caught, JBED_EMITTER_INCOMPATIBLE_CLASS, klass->id, 0, 0);
        goto deferred;
    }
    if ((expected & JBED_ACC_SUPER) && name != JBED_NAME_INIT) {
        JbedClass *superclass = pool->owner ? pool->owner->superclass : NULL;
        if (!superclass) {
            pool_error(&caught, JBED_ERROR_NULL_POINTER, "Missing caller superclass");
            goto deferred;
        }
        bool assignable;
        if (!jbed_vm_pool_assignable(svc, klass, superclass, &assignable, &caught))
            goto deferred;
        if (assignable)
            klass = superclass;
    }
    if (!resolve_method(pool, klass, name, signature, method, &caught))
        goto deferred;
    if (!*method || !jbed_vm_method_visible(svc, *method) ||
        (((*method)->flags & JBED_METHOD_CONSTRUCTOR) && (*method)->owner != klass)) {
        pool_diagnostic(pool, &caught, JBED_EMITTER_NO_METHOD, klass->id, name, signature);
        goto deferred;
    }
    if (((*method)->flags ^ expected) & JBED_ACC_STATIC) {
        pool_diagnostic(pool, &caught, JBED_EMITTER_INCOMPATIBLE_CLASS, klass->id, 0, 0);
        goto deferred;
    }
    if (!(expected & JBED_ACC_INTERFACE) &&
        ((*method)->flags & ~klass->flags & JBED_ACC_ABSTRACT)) {
        pool_diagnostic(pool, &caught, JBED_EMITTER_ABSTRACT_METHOD, klass->id, name, signature);
        goto deferred;
    }
    if (!jbed_pool_check_access(pool, pool->owner, (*method)->owner, (*method)->flags, &caught))
        goto deferred;
    return true;
deferred:
    if (svc->boot_image || caught.kind == JBED_ERROR_OUT_OF_MEMORY) {
        if (error)
            *error = caught;
        return false;
    }
    if (!deferred_owner(svc, &klass, error))
        return false;
    *method = pool_alloc(pool, 1, sizeof(**method));
    (*method)->owner = klass;
    (*method)->flags = JBED_ACC_PUBLIC | (expected & JBED_ACC_STATIC);
    if (name == JBED_NAME_INIT)
        (*method)->flags |= JBED_METHOD_CONSTRUCTOR;
    (*method)->name_id = name;
    (*method)->signature_id = signature;
    (*method)->code_address = jbed_pool_error_address(pool, &caught);
    (*method)->dispatch_slot = -1;
    return true;
}

/* Pool.field, 0x12d0f4; deferred linkage handler at 0x12d1d6. */
bool jbed_pool_field(JbedPool *pool, uint32_t index, uint32_t expected, JbedField **field,
                     JbedError *error)
{
    JbedNameId name = 0;
    JbedTypeId type = 0;
    JbedClass *klass = NULL;
    JbedError caught = {0};
    const JbedPoolServices *svc = pool->services;
    if (index >= pool->count) {
        pool_error(&caught, JBED_ERROR_ARRAY_INDEX, "Invalid field reference");
        goto deferred;
    }
    uint16_t nt = (uint16_t)pool->values[index];
    if (!jbed_pool_name_id(pool, nt, &name, &caught) ||
        !jbed_pool_type_id(pool, nt, &type, &caught) ||
        !jbed_pool_class(pool, pool->values[index] >> 16, false, &klass, &caught) ||
        !resolve_field(pool, klass, name, type, field, &caught))
        goto deferred;
    if (!*field || !jbed_vm_field_visible(svc, *field)) {
        pool_diagnostic(pool, &caught, JBED_EMITTER_NO_FIELD, klass->id, name, 0);
        goto deferred;
    }
    if (((*field)->flags ^ expected) & JBED_ACC_STATIC) {
        pool_diagnostic(pool, &caught, JBED_EMITTER_INCOMPATIBLE_CLASS, klass->id, 0, 0);
        goto deferred;
    }
    if (!jbed_pool_check_access(pool, pool->owner, (*field)->owner, (*field)->flags, &caught))
        goto deferred;
    return true;
deferred:
    if (svc->boot_image || caught.kind == JBED_ERROR_OUT_OF_MEMORY) {
        if (error)
            *error = caught;
        return false;
    }
    if (!deferred_owner(svc, &klass, error))
        return false;
    *field = pool_alloc(pool, 1, sizeof(**field));
    (*field)->owner = klass;
    (*field)->flags = JBED_ACC_PUBLIC | JBED_FIELD_CONSTANT | JBED_FIELD_UNRESOLVED |
                      (expected & JBED_ACC_STATIC);
    (*field)->name_id = name;
    (*field)->type_id = type;
    return true;
}

static bool swap_write(JbedCompilerSwap *stream, uint32_t value, unsigned width, JbedError *error)
{
    uint8_t bytes[4];
    for (unsigned i = 0; i < width; ++i)
        bytes[i] = (uint8_t)(value >> (8 * i));
    return stream->write(stream->context, bytes, width, error);
}

static bool swap_read(JbedCompilerSwap *stream, uint32_t *value, unsigned width, JbedError *error)
{
    uint8_t bytes[4];
    if (!stream->read(stream->context, bytes, width, error))
        return false;
    *value = 0;
    for (unsigned i = 0; i < width; ++i)
        *value |= (uint32_t)bytes[i] << (8 * i);
    return true;
}

/* Pool.swapOut, 0x12e93a. This is the compiler's same-process scratch stream;
 * interned strings are retained by their original target addresses. */
bool jbed_pool_swap_out(JbedPool *pool, JbedCompilerSwap *stream, JbedError *error)
{
    for (size_t i = 1; i < pool->count; ++i) {
        if (pool->tags[i] == JBED_POOL_CACHED_CLASS) {
            pool->tags[i] = JBED_POOL_CLASS;
            pool->values[i] = pool->objects[pool->values[i]].class_object->id;
        }
    }
    if (!swap_write(stream, pool->count, 2, error) ||
        !stream->write(stream->context, pool->tags, pool->count, error))
        return false;
    for (size_t i = 0; i < pool->count; ++i)
        if (!swap_write(stream, pool->values[i], 4, error))
            return false;
    if (!swap_write(stream, (uint32_t)pool->type_id_count, 2, error))
        return false;
    for (size_t i = 0; i < pool->type_id_count; ++i)
        if (!swap_write(stream, pool->type_ids[i], 4, error))
            return false;
    if (!swap_write(stream, (uint32_t)pool->object_count, 2, error) ||
        !swap_write(stream, (uint32_t)pool->character_count, 4, error))
        return false;
    for (size_t i = 0; i < pool->character_count; ++i)
        if (!swap_write(stream, pool->characters[i], 2, error))
            return false;
    for (size_t i = 1; i < pool->count; ++i)
        if (pool->tags[i] == JBED_POOL_STRING &&
            !swap_write(stream, pool->objects[pool->values[i]].string->address, 4, error))
            return false;
    return true;
}

/* Pool.swapIn, 0x12eae4. Cached classes become unresolved class IDs; strings
 * rebuild the object table in constant-pool order. */
bool jbed_pool_swap_in(JbedPool *pool, JbedCompilerSwap *stream, JbedError *error)
{
    uint32_t value;
    if (!swap_read(stream, &value, 2, error))
        return false;
    pool->count = (uint16_t)value;
    pool->tags = pool_alloc(pool, pool->count, 1);
    pool->values = pool_alloc(pool, pool->count, sizeof(*pool->values));
    if (!stream->read(stream->context, pool->tags, pool->count, error))
        return false;
    for (size_t i = 0; i < pool->count; ++i)
        if (!swap_read(stream, &pool->values[i], 4, error))
            return false;
    if (!swap_read(stream, &value, 2, error))
        return false;
    pool->type_id_count = value;
    pool->type_ids = pool_alloc(pool, value, sizeof(*pool->type_ids));
    for (size_t i = 0; i < pool->type_id_count; ++i)
        if (!swap_read(stream, &pool->type_ids[i], 4, error))
            return false;
    if (!swap_read(stream, &value, 2, error))
        return false;
    pool->object_count = value;
    pool->objects = pool_alloc(pool, value, sizeof(*pool->objects));
    pool->object_position = 0;
    if (!swap_read(stream, &value, 4, error))
        return false;
    pool->character_count = pool->character_capacity = value;
    pool->characters = pool_alloc(pool, value, sizeof(*pool->characters));
    for (size_t i = 0; i < pool->character_count; ++i) {
        if (!swap_read(stream, &value, 2, error))
            return false;
        pool->characters[i] = (uint16_t)value;
    }
    for (size_t i = 1; i < pool->count; ++i) {
        if (pool->tags[i] != JBED_POOL_STRING)
            continue;
        if (!swap_read(stream, &value, 4, error))
            return false;
        if (pool->object_position >= pool->object_count)
            return pool_error(error, JBED_ERROR_ARRAY_INDEX, "Swapped pool object table overflow");
        JbedPoolString **string = &pool->objects[pool->object_position].string;
        if (pool->services->string_at) {
            if (!pool->services->string_at(pool->services->context, value, string, error))
                return false;
        } else if (pool->services->vm_strings)
            *string = jbed_vm_pool_string_at(pool->services, value);
        else
            return pool_error(error, JBED_ERROR_INTERNAL, "Missing swapped-string resolver");
        pool->values[i] = (uint32_t)pool->object_position++;
    }
    return true;
}
