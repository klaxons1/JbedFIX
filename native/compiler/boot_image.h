#ifndef JBED_BOOT_IMAGE_H
#define JBED_BOOT_IMAGE_H

#include <stddef.h>
#include <stdint.h>

/* The offline compiler emits address-independent data. The loader copies it,
 * resolves these references, then changes the allocation from writable to
 * executable. No executable ELF section needs dynamic relocations. */
typedef enum JbedBootRelocationKind {
    JBED_BOOT_IMAGE_POINTER,
    JBED_BOOT_NATIVE_POINTER,
    JBED_BOOT_NATIVE_THUMB_CALL,
    JBED_BOOT_GLOBAL_POINTER,
    JBED_BOOT_RUNTIME_FIELD_POINTER
} JbedBootRelocationKind;

typedef struct JbedBootRelocation {
    uint32_t offset;
    uint32_t target; /* Image/global offset (including Thumb bit), or native/field index. */
    JbedBootRelocationKind kind;
} JbedBootRelocation;

typedef struct JbedBootNative {
    const char *name;
    void (*entry)(void);
} JbedBootNative;

typedef struct JbedBootMethod {
    const char *owner, *name, *descriptor;
    uint32_t offset, flags;
} JbedBootMethod;

typedef struct JbedBootClass {
    const char *name;
    uint32_t id, offset;
} JbedBootClass;

typedef enum JbedNativeConvention {
    JBED_NATIVE_JBNI,
    JBED_NATIVE_KNI
} JbedNativeConvention;

typedef struct JbedBootNativeMethod {
    const char *owner, *name, *descriptor;
    void (*entry)(void);
    uint32_t flags;
    JbedNativeConvention convention;
} JbedBootNativeMethod;

typedef struct JbedBootField {
    const char *owner, *name, *descriptor;
    void *(*resolve)(void *runtime);
} JbedBootField;

typedef struct JbedBootImage {
    const uint8_t *bytes;
    size_t size;
    const JbedBootRelocation *relocations;
    size_t relocation_count;
    const JbedBootNative *natives;
    size_t native_count;
    const JbedBootMethod *methods;
    size_t method_count;
    const JbedBootClass *classes;
    size_t class_count;
    uint32_t statics_size;
    uint32_t stack_maps;
    uint32_t class_index;
    uint32_t packages, base_names, method_names, field_names, signatures;
    uint32_t globals_size;
    const JbedBootNativeMethod *native_methods;
    size_t native_method_count;
    uint32_t sync_slots;
    uint32_t intern_table;
    const JbedBootField *fields;
    size_t field_count;
    uint32_t properties;
    uint32_t main_method;
    uint32_t initializers, initializer_count;
} JbedBootImage;

#endif
