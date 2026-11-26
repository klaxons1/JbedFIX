#ifndef JBED_COMPILER_MODEL_H
#define JBED_COMPILER_MODEL_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* Semantic records for the ROM compiler. These are host objects, not overlays
 * of the ARM Java heap; addresses stored in generated code remain uint32_t. */
typedef uint32_t JbedTypeId;
typedef uint16_t JbedNameId;
typedef uint16_t JbedSignatureId;

enum {
    JBED_NAME_INIT = 10017,        /* <init> */
    JBED_NAME_CLINIT = 27281,      /* <clinit> */
    JBED_SIGNATURE_VOID_NO_ARGS = 0xf00d
};

/* The VM's primitive type codes also occupy the negative stack-info values.
 * Nonnegative info carries a proven-null-check/bounds-check result. */
typedef enum JbedPrimitive {
    JBED_TYPE_REFERENCE = 2,
    JBED_TYPE_DOUBLE_HIGH = 3,
    JBED_TYPE_BOOLEAN = 4,
    JBED_TYPE_CHAR = 5,
    JBED_TYPE_FLOAT = 6,
    JBED_TYPE_DOUBLE = 7,
    JBED_TYPE_BYTE = 8,
    JBED_TYPE_SHORT = 9,
    JBED_TYPE_INT = 10,
    JBED_TYPE_LONG = 11,
    JBED_TYPE_VOID = 0,
    JBED_TYPE_LONG_HIGH = 15
} JbedPrimitive;


/* Class IDs in the resident ROM, shared by signature encoding and verification. */
enum {
    JBED_ROM_CLASS_OBJECT = 462,
    JBED_ROM_CLASS_STRING = 466,
    JBED_ROM_CLASS_THROWABLE = 20,
    JBED_ROM_CLASS_CLASS = 38,
    JBED_ROM_CLASS_OBJECT_ARRAY = 141,
    JBED_ROM_CLASS_BOOLEAN_ARRAY = 129,
    JBED_ROM_CLASS_BYTE_ARRAY = 467,
    JBED_ROM_CLASS_CHAR_ARRAY = 464,
    JBED_ROM_CLASS_SHORT_ARRAY = 59,
    JBED_ROM_CLASS_INT_ARRAY = 463,
    JBED_ROM_CLASS_LONG_ARRAY = 161,
    JBED_ROM_CLASS_FLOAT_ARRAY = 40,
    JBED_ROM_CLASS_DOUBLE_ARRAY = 465
};

typedef enum JbedErrorKind {
    JBED_ERROR_NONE,
    JBED_ERROR_CLASS_FORMAT,
    JBED_ERROR_NO_CLASS_DEF,
    JBED_ERROR_VERIFY,
    JBED_ERROR_CLASS_CIRCULARITY,
    JBED_ERROR_ILLEGAL_ACCESS,
    JBED_ERROR_INCOMPATIBLE_CLASS_CHANGE,
    JBED_ERROR_NO_SUCH_METHOD,
    JBED_ERROR_NO_SUCH_FIELD,
    JBED_ERROR_ABSTRACT_METHOD,
    JBED_ERROR_OUT_OF_MEMORY,
    JBED_ERROR_IO,
    JBED_ERROR_ERROR,
    JBED_ERROR_CLASS_CAST,
    JBED_ERROR_ARITHMETIC,
    JBED_ERROR_NULL_POINTER,
    JBED_ERROR_ARRAY_INDEX,
    JBED_ERROR_RUNTIME_EXCEPTION,
    JBED_ERROR_INTERNAL,
    JBED_ERROR_THROWABLE,
    JBED_ERROR_ARRAY_STORE,
    JBED_ERROR_NEGATIVE_ARRAY_SIZE
} JbedErrorKind;

typedef struct JbedError {
    JbedErrorKind kind;
    bool is_java_error;
    JbedTypeId class_id;
    uint32_t member_id;
    uint32_t detail_code;
    int32_t bytecode_offset;
    const char *message; /* Borrowed; the supplying runtime owns its lifetime. */
    void *runtime_throwable;
} JbedError;

enum {
    JBED_ACC_PUBLIC = 0x0001,
    JBED_ACC_PRIVATE = 0x0002,
    JBED_ACC_PROTECTED = 0x0004,
    JBED_ACC_STATIC = 0x0008,
    JBED_ACC_FINAL = 0x0010,
    JBED_ACC_SUPER = 0x0020,
    JBED_ACC_SYNCHRONIZED = 0x0020,
    JBED_ACC_VOLATILE = 0x0040,
    JBED_ACC_TRANSIENT = 0x0080,
    JBED_ACC_NATIVE = 0x0100,
    JBED_ACC_INTERFACE = 0x0200,
    JBED_ACC_ABSTRACT = 0x0400,
    JBED_ACC_STRICT = 0x0800
};

#define JBED_ACC_IN_PROFILE UINT32_C(0x80000000)

/* Jbed extends the classfile access flags when resolving and preparing members.
 * The same bit can have different meanings on a class, a method and a field. */
enum {
    JBED_CLASS_PUBLIC_DEFAULT_CTOR = 0x4000,
    JBED_CLASS_PRIVATE_DEFAULT_CTOR = 0x8000,
    JBED_CLASS_VERIFIED = 0x10000,
    JBED_CLASS_PREPARING = 0x20000,
    JBED_CLASS_PREPARED = 0x40000,
    JBED_CLASS_TRANSLATED = 0x80000,
    JBED_CLASS_INIT_STARTED = 0x100000,
    JBED_CLASS_SKIP_INIT_IN_CURRENT_IMAGE = 0x200000,
    JBED_CLASS_INSTANTIABLE = 0x400000,
    JBED_CLASS_DYNAMIC = 0x800000,
    JBED_CLASS_PRIMITIVE = 0x1000000,
    JBED_CLASS_ARRAY = 0x2000000,
    JBED_CLASS_TRACE = 0x8000000,
    JBED_CLASS_FINALIZED = 0x10000000,
    JBED_CLASS_SKIP_INIT_CHECK = 0x20000000,
    JBED_CLASS_DESCRIPTOR_WRITTEN = 0x40000000
};

enum {
    JBED_METHOD_SLOT0_ALWAYS_THIS = 0x2000,
    JBED_METHOD_HAS_HANDLERS = 0x10000,
    JBED_METHOD_CODE_RANGES = 0x80000,
    JBED_METHOD_NOT_LEAF = 0x100000,
    JBED_METHOD_VIRTUAL_DISPATCH = 0x200000,
    JBED_METHOD_DECLARED_EXCEPTIONS = 0x400000,
    JBED_METHOD_RETURNS_NONNULL = 0x800000,
    JBED_METHOD_CONSTRUCTOR = 0x4000000,
    JBED_METHOD_CLASS_INITIALIZER = 0x10000000,
    JBED_METHOD_NATIVE_CALL = 0x20000000
};

enum {
    JBED_FIELD_RELATIVE_STATIC = 0x10000,
    JBED_FIELD_CONSTANT = 0x1000000,
    JBED_FIELD_INITIALIZE_STATIC = 0x4000000,
    JBED_FIELD_UNRESOLVED = 0x8000000
};

typedef struct JbedClass JbedClass;
typedef struct JbedMethod JbedMethod;
typedef struct JbedField JbedField;
typedef struct JbedPool JbedPool;
typedef struct JbedClassAccess JbedClassAccess;

/* Reader.readMaps/readTypeList, 0x149bd2/0x149cdc: count; PCs[count];
 * pairs of locals/stack offsets; deduplicated [count, type...] vectors.
 * Offset zero denotes an empty vector. Object tokens are CP index + 7;
 * uninitialized-object tokens are allocation PC + 0x8000. */
typedef struct JbedStackMaps {
    uint16_t *words;
    size_t word_count;
} JbedStackMaps;

typedef struct JbedExceptionHandler {
    uint32_t start_pc;
    uint32_t end_pc;
    uint32_t handler_pc;
    uint32_t catch_index;
} JbedExceptionHandler;

/* DynamicMethod offsets: owner +12, flags +16, name/signature +20/+22,
 * generated address +24, dispatch slot +28, locals +30, max stack +40,
 * bytecodes +44, exception tuples +48, maps +52, next +60. */
struct JbedMethod {
    JbedClass *owner;
    uint32_t flags;
    JbedNameId name_id;
    JbedSignatureId signature_id;
    uint32_t code_address;
    int16_t dispatch_slot;
    uint16_t max_locals;
    uint16_t generated_size; /* +30 after translation; flags 0x80000 select a range index. */
    uint16_t max_stack;
    uint32_t profiling_info;
    uint32_t label;
    uint16_t local_hint;
    uint8_t *code;
    size_t code_length;
    JbedExceptionHandler *handlers;
    size_t handler_count;
    JbedStackMaps stack_maps;
    uint16_t *position_info;
    size_t position_info_count;
    JbedMethod *next;
};

/* Field offsets: owner +12, flags +16, name +20, type +24, offset +28,
 * constant-pool index/value +32, next +40. */
struct JbedField {
    JbedClass *owner;
    uint32_t flags;
    JbedNameId name_id;
    JbedTypeId type_id;
    uint32_t offset;
    uint16_t constant_index;
    uint64_t constant_value;
    JbedField *next;
};

/* Class.ReadClass/PrepareClass, 0x149848/0x148c48. The original class object
 * reuses slots while reading, loading and emitting; these stages are explicit. */
struct JbedClass {
    uint32_t flags;
    JbedTypeId id;
    JbedClass *superclass; /* Array classes use this link for their component. */
    JbedClass **interfaces;
    size_t interface_count;
    int32_t instance_size;
    int16_t depth;
    int16_t vtable_size;
    JbedTypeId unresolved_super_id;
    JbedTypeId *unresolved_interface_ids;
    size_t unresolved_interface_count;
    uint32_t descriptor_address;
    int32_t swap_offset;
    int32_t static_initializer_count;
    uint32_t relative_statics_id;
    uint32_t default_constructor_address;
    uint32_t initializer_address;
    uint32_t init_flags;
    JbedClassAccess *dynamic_class_access;
    uint16_t base_id;
    uint16_t package_id;
    uint16_t array_dimensions;
    uint32_t label;
    void *statics;
    void *anchor;
    const char *source;
    JbedPool *pool;
    JbedField *fields;
    size_t field_count;
    JbedMethod *methods;
    size_t method_count;
    bool has_error;
    JbedError error;
    uint32_t guest_address; /* Pinned compiler-side java.lang.Class object. */
};

#endif
