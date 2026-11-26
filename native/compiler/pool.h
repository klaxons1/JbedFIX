#ifndef JBED_COMPILER_POOL_H
#define JBED_COMPILER_POOL_H

#include "emitter.h"
#include "reflection_table.h"

typedef struct JbedReader JbedReader;
typedef struct JbedCompilerSwap JbedCompilerSwap;

typedef enum JbedPoolTag {
    JBED_POOL_UTF8 = 1,
    JBED_POOL_INTEGER = 3,
    JBED_POOL_FLOAT = 4,
    JBED_POOL_LONG = 5,
    JBED_POOL_DOUBLE = 6,
    JBED_POOL_CLASS = 7,
    JBED_POOL_STRING = 8,
    JBED_POOL_FIELDREF = 9,
    JBED_POOL_METHODREF = 10,
    JBED_POOL_INTERFACE_METHODREF = 11,
    JBED_POOL_NAME_AND_TYPE = 12,
    JBED_POOL_WIDE_TAIL = 13,
    JBED_POOL_CACHED_CLASS = 0x10 | JBED_POOL_CLASS,
} JbedPoolTag;

typedef struct JbedPoolString {
    void *object;
    uint32_t address;
    const uint16_t *characters;
    size_t length;
} JbedPoolString;

/* ReflectionTable, ClassAccess, SignatureEncoder and String.intern are runtime
 * dependencies of Pool. Byte ranges below use the original modified UTF-8;
 * end and last_slash are byte offsets, not decoded character indices. */
typedef struct JbedPoolServices {
    JbedRuntime *runtime;
    void *context;
    JbedEmitter *emitter;
    bool (*name_id)(void *, bool method, const uint8_t *, size_t, bool create, JbedNameId *,
                    JbedError *);
    bool (*class_id)(void *, const uint8_t *, size_t start, size_t end, size_t last_slash,
                     uint16_t dimensions, JbedTypeId *, JbedError *);
    bool (*primitive_array_id)(void *, JbedTypeId, uint16_t, JbedTypeId *, JbedError *);
    bool (*array_class_id)(void *, JbedTypeId, JbedTypeId *, JbedError *);
    bool (*signature_id)(void *, const JbedTypeId *arguments, size_t argument_count,
                         JbedTypeId return_type, bool returns_void, JbedSignatureId *, JbedError *);
    bool (*intern_string)(void *, const uint16_t *, size_t, JbedPoolString **,
                          bool *retained_characters, JbedError *);
    bool (*string_at)(void *, uint32_t, JbedPoolString **, JbedError *);
    bool (*load_class)(void *, JbedTypeId, JbedClass **, JbedError *);
    bool (*package_id)(void *, JbedTypeId, uint16_t *, JbedError *);
    bool (*assignable)(void *, const JbedClass *, const JbedClass *, bool *, JbedError *);
    bool (*find_method)(void *, JbedClass *, JbedNameId, JbedSignatureId, JbedMethod **,
                        JbedError *);
    bool (*find_field)(void *, JbedClass *, JbedNameId, JbedTypeId, JbedField **, JbedError *);
    bool (*method_visible)(void *, const JbedMethod *);
    bool (*field_visible)(void *, const JbedField *);
    JbedClass *pool_runtime_class;
    JbedClass *primitive_array_classes[8]; /* Resident arrays for type IDs 4..11. */
    uint32_t throw_no_class_address;
    uint32_t throw_abstract_address;
    JbedReflectionTable *method_names, *field_names;
    JbedClassAccess *class_access;
    struct JbedSignatureEncoder *signature_encoder;
    struct JbedVmStrings *vm_strings;
    /* Boot sources can express recovered Class literals directly. MIDlet
     * classfiles retain the CLDC constant restrictions. */
    bool boot_image;
    uint32_t (*class_object_address)(void *, JbedClass *);
    bool (*trusted_access)(void *, const JbedClass *from, const JbedClass *owner);
} JbedPoolServices;

typedef struct JbedPoolUtf8 {
    uint8_t *bytes; /* Original UTF8 arrays have two trailing zero bytes. */
    uint16_t length;
} JbedPoolUtf8;

typedef struct JbedPoolUtf8Info {
    uint32_t string_index;
    JbedTypeId class_id;
    uint32_t type_or_signature; /* Signature bit 16 records a void return. */
    uint32_t names;             /* Field name low 16, method name high 16. */
} JbedPoolUtf8Info;

typedef struct JbedPoolObject {
    JbedClass *class_object;
    JbedPoolString *string;
} JbedPoolObject;

struct JbedPool {
    const JbedPoolServices *services;
    JbedClass *owner;
    uint16_t count;
    uint8_t *tags;
    uint32_t *values;
    JbedTypeId *type_ids;
    size_t type_id_count;
    JbedPoolObject *objects;
    size_t object_count, object_position;
    uint16_t *characters;
    size_t character_count, character_capacity;
    uint8_t *resolve_flags;
    JbedPoolUtf8 *utf8;
    JbedPoolUtf8Info *utf8_info;
    JbedTypeId parsed_type;
    uint16_t parsed_dimensions;
    size_t type_start, last_slash, type_end;
};

typedef enum JbedAttribute {
    JBED_ATTRIBUTE_UNKNOWN,
    JBED_ATTRIBUTE_CODE,
    JBED_ATTRIBUTE_STACK_MAP,
    JBED_ATTRIBUTE_EXCEPTIONS,
    JBED_ATTRIBUTE_SOURCE_FILE,
    JBED_ATTRIBUTE_INNER_CLASSES,
    JBED_ATTRIBUTE_CONSTANT_VALUE,
    JBED_ATTRIBUTE_LINE_NUMBERS,
    JBED_ATTRIBUTE_LOCAL_VARIABLES
} JbedAttribute;

void jbed_pool_init(JbedPool *, const JbedPoolServices *, JbedClass *);
void jbed_pool_reset(JbedPool *);
bool jbed_pool_read(JbedPool *, JbedReader *, JbedError *);
bool jbed_pool_resolve(JbedPool *, JbedError *);
void jbed_pool_read_complete(JbedPool *);
bool jbed_pool_attribute(JbedPool *, uint16_t, JbedAttribute *, JbedError *);
bool jbed_pool_mark_field(JbedPool *, const JbedField *, JbedError *);
bool jbed_pool_mark_method(JbedPool *, const JbedMethod *, JbedError *);
bool jbed_pool_resolve_class_ids(JbedPool *, uint16_t self, uint16_t super, uint16_t *interfaces,
                                 size_t count, JbedError *);
bool jbed_pool_resolve_field_ids(JbedPool *, JbedField *, JbedError *);
bool jbed_pool_resolve_method_ids(JbedPool *, JbedMethod *, JbedError *);
bool jbed_pool_class_id(JbedPool *, uint32_t, JbedTypeId *, JbedError *);
bool jbed_pool_class(JbedPool *, uint32_t, bool allow_missing, JbedClass **, JbedError *);
bool jbed_pool_array_of_class(JbedPool *, uint32_t, JbedClass **, JbedError *);
bool jbed_pool_array_of_type(JbedPool *, JbedTypeId, JbedClass **, JbedError *);
bool jbed_pool_name_id(JbedPool *, uint32_t, JbedNameId *, JbedError *);
bool jbed_pool_type_id(JbedPool *, uint32_t, JbedTypeId *, JbedError *);
bool jbed_pool_signature_id(JbedPool *, uint32_t, JbedSignatureId *, JbedError *);
bool jbed_pool_constant_type(JbedPool *, uint32_t, JbedTypeId *, JbedError *);
bool jbed_pool_constant_word(JbedPool *, uint32_t, uint32_t *, JbedError *);
bool jbed_pool_method(JbedPool *, uint32_t, uint32_t expected_flags, JbedMethod **, JbedError *);
bool jbed_pool_field(JbedPool *, uint32_t, uint32_t expected_flags, JbedField **, JbedError *);
uint32_t jbed_pool_error_address(const JbedPool *, const JbedError *);
bool jbed_pool_same_package(JbedPool *, const JbedClass *, const JbedClass *, bool *, JbedError *);
bool jbed_pool_trusted_access(const JbedPool *, const JbedClass *, const JbedClass *);
bool jbed_pool_accessible(JbedPool *, const JbedClass *from, const JbedClass *owner, uint32_t flags,
                          bool *, JbedError *);
bool jbed_pool_check_access(JbedPool *, const JbedClass *, const JbedClass *, uint32_t,
                            JbedError *);
bool jbed_pool_primitive_character(JbedEmitter *, uint16_t, JbedTypeId *, JbedError *);
JbedTypeId jbed_pool_primitive_type(JbedTypeId);
bool jbed_pool_bad_visibility(uint32_t);
bool jbed_pool_swap_out(JbedPool *, JbedCompilerSwap *, JbedError *);
bool jbed_pool_swap_in(JbedPool *, JbedCompilerSwap *, JbedError *);

#endif
