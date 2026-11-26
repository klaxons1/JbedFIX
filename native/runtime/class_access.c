#include "class_access.h"
#include "rom_reflection.h"
#include "metadata_init.h"
#include "../compiler/vm/vm_words.h"

#include <stdint.h>
#include <stdio.h>
#include <string.h>

enum { ARRAY_LENGTH = 12, ARRAY_DATA = 16, CLASS_ID = 16, STRING_LENGTH = 20,
       ACCESS_DYNAMIC_CLASSES = 12 };

static JbedVm *active(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "ClassAccess call outside a Jbed VM");
    return vm;
}

static JbedClassAccess *access_for(JbedVm *vm, JbRef object)
{
    return jbed_vm_class_access_for_object(vm, object);
}

static bool dynamic(const JbedClassAccess *access, uint32_t id)
{
    return id >> 16 == access->dynamic_bundle;
}

static JbRef resident_table(JbedVm *vm, uint32_t id)
{
    JbedAddress slot = jbed_vm_static_field_slot(vm, "com/jbed/reflect/ClassAccess", "classRefTables");
    JbRef tables = slot ? jbed_vm_word(vm->heap.memory, slot) : 0;
    if (!tables) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    /* The original bundle selector is arithmetic, then checked as an array index. */
    int32_t bundle = (int32_t)id >> 16;
    if ((uint32_t)bundle >= jbed_vm_word(vm->heap.memory, tables + ARRAY_LENGTH))
        jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    JbRef table = jbed_vm_word(vm->heap.memory, tables + ARRAY_DATA + 4u * (uint32_t)bundle);
    if (!table) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    return table;
}

static uint64_t pack(JbedClassParams params)
{
    return params.package_id | (uint64_t)params.base_id << 16 |
        (uint64_t)(uint32_t)params.dimensions << 32;
}

static JbedClassParams unpack(uint64_t params)
{
    return (JbedClassParams){(uint16_t)params, (uint16_t)(params >> 16),
        (int32_t)(params >> 32)};
}

bool ClassAccess_isDynamicId(JbRef object, int32_t id)
{
    JbedVm *vm = active();
    return dynamic(access_for(vm, object), (uint32_t)id);
}

uint64_t ClassAccess_getClassParamsId(JbRef object, int32_t id)
{
    JbedVm *vm = active();
    JbedClassAccess *access = access_for(vm, object);
    if (!dynamic(access, (uint32_t)id))
        return ClassRefTable_classParams(resident_table(vm, (uint32_t)id), id);
    return pack(jbed_class_params(access, (JbedTypeId)id));
}

int32_t ClassAccess_getArrayLevel(JbRef object, int32_t id)
{
    return (int32_t)(ClassAccess_getClassParamsId(object, id) >> 32);
}

int32_t ClassAccess_getPackageId(JbRef object, int32_t id)
{
    return (uint16_t)ClassAccess_getClassParamsId(object, id);
}

int32_t ClassAccess_getClassIdParams(JbRef object, int32_t package, int32_t base,
                                     int32_t dimensions, bool create, bool include_hidden)
{
    JbedVm *vm = active();
    return (int32_t)jbed_class_id(access_for(vm, object),
        (JbedClassParams){(uint16_t)package, (uint16_t)base, dimensions}, create, include_hidden);
}

int32_t ClassAccess_getClassIdString(JbRef object, JbRef string, bool create,
                                     bool create_array, bool include_hidden)
{
    JbedVm *vm = active();
    if (!string) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    JbedClassAccess *access = access_for(vm, object);
    uint64_t encoded = ClassAccess_getClassParams(object, string, NULL,
        (int32_t)jbed_vm_word(vm->heap.memory, string + STRING_LENGTH), create);
    if (!encoded) return 0;
    JbedClassParams params = unpack(encoded);
    JbedTypeId id = jbed_class_id(access, params, create, include_hidden);
    if (!id && create_array && params.dimensions > 0) {
        JbedClassParams component = params;
        component.dimensions = 0;
        if (jbed_class_id(access, component, false, include_hidden))
            id = jbed_class_id(access, params, true, include_hidden);
    }
    return (int32_t)id;
}

int32_t ClassAccess_getClassIdUtf8(JbRef object, const uint8_t *address,
                                   int32_t length, bool create)
{
    JbedVm *vm = active();
    JbedClassAccess *access = access_for(vm, object);
    uint64_t params = ClassAccess_getClassParams(object, 0, address, length, create);
    return params ? (int32_t)jbed_class_id(access, unpack(params), create, true) : 0;
}

int32_t ClassAccess_getClassIdBytes(JbRef object, JbRef bytes, int32_t start, int32_t end,
                                    int32_t slash, int32_t dimensions)
{
    JbedVm *vm = active();
    JbedClassAccess *access = access_for(vm, object);
    JbRef bases = jbed_vm_word(vm->heap.memory, vm->reflection_roots[1]);
    JbRef packages = jbed_vm_word(vm->heap.memory, vm->reflection_roots[0]);
    int32_t base_start = slash ? (int32_t)((uint32_t)slash + 1) : start;
    int32_t base = ReflectionTable_dataToId(bases, bytes, base_start, NULL,
        (int32_t)((uint32_t)end - (uint32_t)base_start), true);
    int32_t package = slash ? ReflectionTable_dataToId(packages, bytes, start, NULL,
        (int32_t)((uint32_t)slash - (uint32_t)start), true) : 0;
    return (int32_t)jbed_class_id(access,
        (JbedClassParams){(uint16_t)package, (uint16_t)base, dimensions}, true, true);
}

int32_t ClassAccess_getArrayOfClass(JbRef object, int32_t component)
{
    JbedVm *vm = active();
    JbedClassAccess *access = access_for(vm, object);
    JbedClassParams params = unpack(ClassAccess_getClassParamsId(object, component));
    params.dimensions = (int32_t)((uint32_t)params.dimensions + 1);
    return (int32_t)jbed_class_id(access, params, true, true);
}

int32_t ClassAccess_getPrimitiveArrayId(JbRef object, int32_t primitive, int32_t dimensions)
{
    JbedVm *vm = active();
    return (int32_t)jbed_class_primitive_array(access_for(vm, object),
        (JbedTypeId)primitive, dimensions);
}

JbRef ClassAccess_classObject(JbRef object, int32_t id)
{
    JbedVm *vm = active();
    JbedClassAccess *access = access_for(vm, object);
    uint32_t low = (uint16_t)id;
    JbedClass *klass = low && low <= access->object_capacity ? access->classes[low - 1] : NULL;
    return jbed_class_target_address(access, klass);
}

JbRef ClassAccess_getClassObject(JbRef object, int32_t id)
{
    JbedVm *vm = active();
    JbedClassAccess *access = access_for(vm, object);
    if (!dynamic(access, (uint32_t)id))
        return ClassRefTable_classObject(resident_table(vm, (uint32_t)id), id);
    return jbed_class_target_address(access, jbed_class_object(access, (JbedTypeId)id));
}

JbRef ClassAccess_getOrCreateClassObject(JbRef object, int32_t id)
{
    JbedVm *vm = active();
    JbedClassAccess *access = access_for(vm, object);
    return jbed_class_target_address(access, jbed_class_get_or_create(access, (JbedTypeId)id));
}

JbRef ClassAccess_getNextDynamicClass(JbRef object, JbRef previous)
{
    JbedVm *vm = active();
    JbedClassAccess *access = access_for(vm, object);
    JbedClass prior = {.id = previous ? jbed_vm_word(vm->heap.memory, previous + CLASS_ID) : 0};
    return jbed_class_target_address(access, jbed_class_next(access, previous ? &prior : NULL));
}

int32_t ClassAccess_getNextUnresolvedDynamicClassId(JbRef object, int32_t previous)
{
    JbedVm *vm = active();
    return (int32_t)jbed_class_next_unresolved(access_for(vm, object), (JbedTypeId)previous);
}

JbRef ClassAccess_getDynamicClasses(JbRef object)
{
    JbedVm *vm = active();
    JbedClassAccess *access = access_for(vm, object);
    for (uint32_t i = 0; i < access->object_capacity; ++i)
        if (access->classes[i]) jbed_class_target_address(access, access->classes[i]);
    JbRef actual = jbed_vm_word(vm->heap.memory, access->guest_root);
    return jbed_vm_word(vm->heap.memory, actual + ACCESS_DYNAMIC_CLASSES);
}

void jbed_vm_class_access_publish(JbedVm *vm, JbedClassAccess *access)
{
    jbed_class_publish(access);
    if (access != &vm->classes) vm->classes = *access;
    for (uint32_t i = 0; i < vm->classes.object_capacity; ++i)
        if (vm->classes.classes[i] && vm->classes.classes[i]->dynamic_class_access == access)
            vm->classes.classes[i]->dynamic_class_access = &vm->classes;
    vm->services.registered_classes = &vm->classes;
}

void ClassAccess_registerWithRuntime(JbRef object)
{
    JbedVm *vm = active();
    jbed_vm_class_access_publish(vm, access_for(vm, object));
}

JbRef ClassAccess_getName(JbRef object, int32_t id)
{
    JbedVm *vm = active();
    JbedClassAccess *access = access_for(vm, object);
    bool is_dynamic = dynamic(access, (uint32_t)id);
    JbRef holder = is_dynamic ? object : resident_table(vm, (uint32_t)id);
    uint32_t cache_field = is_dynamic ? 20 : 28;
    uint32_t low = (uint16_t)id;
    JbedVmHeapRoot root = {holder, holder, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbRef cache = jbed_vm_word(vm->heap.memory, holder + cache_field);
    uint32_t capacity = cache ? jbed_vm_word(vm->heap.memory, cache + ARRAY_LENGTH) : 0;
    if (low && low <= capacity) {
        JbRef name = jbed_vm_word(vm->heap.memory, cache + ARRAY_DATA + 4 * (low - 1));
        if (name) {
            vm->heap.temporary_roots = root.previous;
            return name;
        }
    }
    if (!is_dynamic && low == UINT16_MAX)
        jbed_vm_fatal(vm, "Invalid class name cache ID");
    if (!cache || low > capacity) {
        uint32_t size = capacity;
        if (!size) size = low > 32 ? low : 32;
        else if (is_dynamic) {
            while (size < low) size = size < 1024 ? size * 2 : size + 1024;
        } else {
            size = size < 1024 ? size * 2 : size + 1024;
            if (size < low) size = low;
        }
        JbRef grown = jbed_vm_allocate_array(vm, vm->strings.image.string_array_class, (int32_t)size, false);
        cache = jbed_vm_word(vm->heap.memory, root.value + cache_field);
        if (capacity) memcpy(jbed_vm_at(vm->heap.memory, grown + ARRAY_DATA),
            jbed_vm_at(vm->heap.memory, cache + ARRAY_DATA), 4 * capacity);
        jbed_vm_put_word(vm->heap.memory, root.value + cache_field, grown);
        cache = grown;
        capacity = size;
    }
    if (!low || low > capacity) jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    /* Read params through the canonical context; the holder may be a resident table. */
    JbedClassParams params = is_dynamic ? jbed_class_params(access, (JbedTypeId)id)
        : unpack(ClassRefTable_classParams(root.value, id));
    uint32_t dimensions = params.dimensions > 0 ? (uint32_t)params.dimensions : 0;
    bool primitive = (uint32_t)params.base_id - JBED_TYPE_BOOLEAN <= JBED_TYPE_LONG - JBED_TYPE_BOOLEAN;
    int32_t package_length = !primitive && params.package_id
        ? jbed_reflection_data(access->packages, params.package_id, NULL, 0) : 0;
    if (package_length < 0) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    int32_t base_length = primitive ? 1 : jbed_reflection_data(access->base_names, params.base_id, NULL, 0);
    bool null_name = base_length < 0;
    if (null_name) base_length = 4; /* StringBuffer.append(null). */
    uint32_t length = dimensions + (uint32_t)base_length + (uint32_t)package_length +
        (!primitive && params.package_id != 0) + 2u * (!primitive && dimensions != 0);
    char *bytes = jbed_alloc(&vm->services, length);
    memset(bytes, '[', dimensions);
    uint8_t *cursor = (uint8_t *)bytes + dimensions;
    if (primitive) {
        *cursor = (uint8_t)"ZCFDBSIJ"[params.base_id - JBED_TYPE_BOOLEAN];
    } else {
        if (dimensions) *cursor++ = 'L';
        if (params.package_id) {
            jbed_reflection_data(access->packages, params.package_id, cursor, (uint32_t)package_length);
            for (int32_t i = 0; i < package_length; ++i) if (cursor[i] == '/') cursor[i] = '.';
            cursor += package_length;
            *cursor++ = '.';
        }
        if (null_name) memcpy(cursor, "null", 4);
        else jbed_reflection_data(access->base_names, params.base_id, cursor, (uint32_t)base_length);
        cursor += base_length;
        if (dimensions) *cursor = ';';
    }
    JbRef name = jbed_vm_new_utf_string(vm, bytes, (int32_t)length, false);
    name = jbed_vm_string_intern(&vm->strings, name, true);
    if (!name) jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, NULL);
    cache = jbed_vm_word(vm->heap.memory, root.value + cache_field);
    jbed_vm_put_word(vm->heap.memory, cache + ARRAY_DATA + 4 * (low - 1), name);
    vm->heap.temporary_roots = root.previous;
    return name;
}

JbRef Class_getName(JbRef klass)
{
    JbedVm *vm = active();
    if (!klass) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    uint32_t id = jbed_vm_word(vm->heap.memory, klass + CLASS_ID);
    if (!id) {
        char name[sizeof("UnnamedSystemClass.at.0x") + 8];
        int length = snprintf(name, sizeof(name), "UnnamedSystemClass.at.0x%x", klass);
        return jbed_vm_new_utf_string(vm, name, length, false);
    }
    JbRef access = jbed_vm_word(vm->heap.memory, klass + 12) & JBED_CLASS_DYNAMIC
        ? jbed_vm_word(vm->heap.memory, klass + 56)
        : jbed_vm_word(vm->heap.memory, vm->classes.guest_root);
    return ClassAccess_getName(access, (int32_t)id);
}
