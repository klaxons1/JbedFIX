#include "rom_reflection.h"
#include "execution.h"
#include "compiler.h"
#include "metadata_init.h"
#include "../compiler/method_ranges.h"
#include "../compiler/vm/vm_words.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

enum {
    CLASS_METHOD_COUNT = 52, CLASS_FIELD_COUNT = 54,
    CLASS_MEMBERS = 56, MEMBER_BYTES = 16, CLASS_REF_TABLE_IMAGE = 12,
    ARRAY_LENGTH = 12, ARRAY_DATA = 16,
    TABLE_IMAGE = 12, TABLE_BUCKET_SHIFT = 16, TABLE_BUCKET_MASK = 20,
    TABLE_INDEX_MASK = 24, TABLE_DYNAMIC_BUCKET_BITS = 28, TABLE_DYNAMIC_INDEX_BITS = 32,
    TABLE_DYNAMIC_SHIFT = 36, TABLE_DYNAMIC_BUCKET_MASK = 40, TABLE_DYNAMIC_INDEX_MASK = 44,
    TABLE_EXTRA_BIT = 48, TABLE_DYNAMIC_BUCKETS = 52, TABLE_DYNAMIC_REFERENCE = 72,
    TABLE_DYNAMIC_BYTES = 56, TABLE_DYNAMIC_ENTRIES = 60,
    TABLE_FULL_BUCKETS = 64, TABLE_USED_BUCKETS = 68,
    STRING_CHARACTERS = 12, STRING_OFFSET = 16, STRING_LENGTH = 20,
    PACKAGE_TABLE_STATIC = 920, BASE_NAME_TABLE_STATIC = 924,
    DYNAMIC_NAME_ID = 0x8000,
    CLASS_ID = 16, CLASS_REF_BUCKET_MASK = 16, CLASS_REF_OVERFLOW_LIMIT = 20,
    CLASS_REF_COUNT = 24, CLASS_REF_INDEX = 32, CLASS_REF_RECORD_SIZE = 12
};

static uint8_t array_byte(JbedVm *, JbRef, uint32_t);

static JbedVm *active(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm)
        jbed_vm_fatal(NULL, "Reflection call outside a Jbed VM");
    return vm;
}

JbedClassAccess *jbed_vm_class_access_for_object(JbedVm *vm, JbRef object)
{
    if (!object)
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    JbedClassAccess *compiler = jbed_vm_compiler_classes(vm);
    JbedClassAccess *views[] = {&vm->classes, compiler};
    for (size_t i = 0; i < sizeof(views) / sizeof(*views); ++i)
        if (views[i] && views[i]->guest_root &&
            jbed_vm_word(vm->heap.memory, views[i]->guest_root) == object)
            return views[i];
    jbed_vm_fatal(vm, "ClassAccess object has no runtime context");
}

static int32_t add(int32_t a, int32_t b)
{
    return (int32_t)((uint32_t)a + (uint32_t)b);
}

static uint16_t half(const uint8_t *p)
{
    return (uint16_t)(p[0] | (uint16_t)p[1] << 8);
}

static uint32_t word(const uint8_t *p)
{
    return half(p) | (uint32_t)half(p + 2) << 16;
}

static JbedReflectionTable *shared_table(JbedVm *vm, JbRef object)
{
    if (!object)
        return NULL;
    JbedReflectionTable *tables[] = {&vm->packages, &vm->base_names,
        &vm->method_names, &vm->field_names, &vm->signatures};
    for (size_t i = 0; i < sizeof(tables) / sizeof(*tables); ++i)
        if (vm->reflection_roots[i] && object == jbed_vm_word(vm->heap.memory, vm->reflection_roots[i]))
            return tables[i];
    return NULL;
}

static void table_statistics(JbedVm *vm, JbRef object, const JbedReflectionTable *table)
{
    jbed_vm_put_word(vm->heap.memory, object + TABLE_DYNAMIC_BYTES, table->encoded_bytes);
    jbed_vm_put_word(vm->heap.memory, object + TABLE_DYNAMIC_ENTRIES, table->entries);
    jbed_vm_put_word(vm->heap.memory, object + TABLE_FULL_BUCKETS, table->full_buckets);
    jbed_vm_put_word(vm->heap.memory, object + TABLE_USED_BUCKETS, table->used_buckets);
}

static void resident_view(JbedVm *vm, JbRef object, JbedReflectionTable *table)
{
    if (!object)
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    JbedBuffer memory = vm->heap.memory;
    JbedImageView image = {memory.data, memory.size, memory.address};
    if (!jbed_reflection_init(table, &vm->services, image,
                              jbed_vm_word(memory, object + TABLE_IMAGE)))
        jbed_vm_fatal(vm, "Invalid reflection table image");
}

int32_t ReflectionTable_getStaticChainEntry(JbRef object, uint32_t hash, int32_t length,
                                            const uint8_t *bytes)
{
    JbedVm *vm = active();
    JbedReflectionTable view, *table = shared_table(vm, object);
    if (!table) {
        resident_view(vm, object, &view);
        table = &view;
    }
    return jbed_reflection_static_id(table, hash, bytes, (uint32_t)length);
}

int32_t ReflectionTable_getStaticStringId(JbRef object, const uint8_t *string)
{
    uint32_t hash = 0;
    const uint8_t *end = string;
    while (*end)
        hash = 31 * hash + *end++;
    return ReflectionTable_getStaticChainEntry(object, hash, (int32_t)(end - string), string);
}

static uint16_t dynamic_name(JbedVm *vm, JbRef object, uint32_t hash,
                              const uint8_t *bytes, int32_t length, bool create)
{
    JbedReflectionTable *shared = shared_table(vm, object);
    if (shared) {
        uint16_t id = jbed_reflection_dynamic_id(shared, hash, bytes, (uint32_t)length, create);
        table_statistics(vm, object, shared);
        return id;
    }
    JbedBuffer memory = vm->heap.memory;
    JbedReflectionTable view;
    resident_view(vm, object, &view);
    uint32_t count = view.dynamic.bucket_mask + 1;
    view.buckets = calloc(count, sizeof(*view.buckets));
    if (!view.buckets)
        jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, NULL);
    JbRef buckets = jbed_vm_word(memory, object + TABLE_DYNAMIC_BUCKETS);
    if (buckets) {
        for (uint32_t i = 0; i < count; ++i) {
            if (i >= jbed_vm_word(memory, buckets + ARRAY_LENGTH))
                jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
            JbRef array = jbed_vm_word(memory, buckets + ARRAY_DATA + 4 * i);
            if (array)
                view.buckets[i] = (JbedReflectionBucket){jbed_vm_at(memory, array + ARRAY_DATA),
                    jbed_vm_word(memory, array + ARRAY_LENGTH)};
        }
    }
    view.encoded_bytes = jbed_vm_word(memory, object + TABLE_DYNAMIC_BYTES);
    view.entries = jbed_vm_word(memory, object + TABLE_DYNAMIC_ENTRIES);
    view.full_buckets = jbed_vm_word(memory, object + TABLE_FULL_BUCKETS);
    view.used_buckets = jbed_vm_word(memory, object + TABLE_USED_BUCKETS);
    uint32_t previous_entries = view.entries;
    uint16_t id = jbed_reflection_dynamic_id(&view, hash, bytes, (uint32_t)length, create);
    if (view.entries != previous_entries) {
        uint32_t index = (id >> view.dynamic.shift) & view.dynamic.bucket_mask;
        JbedReflectionBucket bucket = view.buckets[index];
        JbRef array = buckets ? jbed_vm_word(memory, buckets + ARRAY_DATA + 4 * index) : 0;
        if (!array || jbed_vm_word(memory, array + ARRAY_LENGTH) != bucket.capacity) {
            JbedVmHeapRoot root = {object, object, vm->heap.temporary_roots};
            vm->heap.temporary_roots = &root;
            if (!buckets) {
                buckets = jbed_vm_allocate_array(vm, jbed_vm_find_class(vm, "[[B"), (int32_t)count, false);
                jbed_vm_put_word(memory, root.value + TABLE_DYNAMIC_BUCKETS, buckets);
            }
            array = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_BYTE],
                                            (int32_t)bucket.capacity, false);
            object = root.value;
            vm->heap.temporary_roots = root.previous;
            buckets = jbed_vm_word(memory, object + TABLE_DYNAMIC_BUCKETS);
            memcpy(jbed_vm_at(memory, array + ARRAY_DATA), bucket.bytes, bucket.capacity);
            jbed_vm_put_word(memory, buckets + ARRAY_DATA + 4 * index, array);
        }
        table_statistics(vm, object, &view);
    }
    free(view.buckets);
    return id;
}

int32_t ReflectionTable_dataToId(JbRef object, JbRef array, int32_t offset,
                                  const uint8_t *address, int32_t length, bool create)
{
    JbedVm *vm = active();
    uint32_t hash = 0;
    if (array) {
        int32_t end = add(offset, length);
        for (int32_t i = offset; i < end; i = add(i, 1))
            hash = 31 * hash + array_byte(vm, array, (uint32_t)i);
        address = jbed_vm_at(vm->heap.memory, array + ARRAY_DATA + (uint32_t)offset);
    } else {
        for (int32_t i = 0; i < length; ++i)
            hash = 31 * hash + address[i];
    }
    int32_t id = ReflectionTable_getStaticChainEntry(object, hash, length, address);
    if (id)
        return id;
    JbedReflectionTable *shared = shared_table(vm, object);
    JbRef reference = jbed_vm_word(vm->heap.memory, object + TABLE_DYNAMIC_REFERENCE);
    if ((shared && shared->referenced) || reference) {
        id = shared && shared->referenced
            ? jbed_reflection_static_id(shared->referenced, hash, address, (uint32_t)length)
            : ReflectionTable_getStaticChainEntry(reference, hash, length, address);
        if (id)
            return id | DYNAMIC_NAME_ID;
        if (create)
            jbed_vm_fatal(vm, "Cannot add a name to a referenced reflection table");
        return 0;
    }
    /* The ROM passes zero as the raw source on this particular call. */
    return dynamic_name(vm, object, hash, array ? address : NULL, length, create);
}

void ReflectionTable_init(JbRef table, const uint8_t *image)
{
    JbedBuffer memory = active()->heap.memory;
    unsigned bucket_bits = image[0] & 15, index_bits = image[0] >> 4;
    unsigned dynamic_bucket_bits = image[1] & 15, dynamic_index_bits = image[1] >> 4;
    jbed_vm_put_word(memory, table + TABLE_IMAGE, (uint32_t)(uintptr_t)image);
    jbed_vm_put_word(memory, table + TABLE_BUCKET_SHIFT, index_bits);
    jbed_vm_put_word(memory, table + TABLE_BUCKET_MASK, (1u << bucket_bits) - 1);
    jbed_vm_put_word(memory, table + TABLE_INDEX_MASK, (1u << index_bits) - 1);
    jbed_vm_put_word(memory, table + TABLE_DYNAMIC_BUCKET_BITS, dynamic_bucket_bits);
    jbed_vm_put_word(memory, table + TABLE_DYNAMIC_INDEX_BITS, dynamic_index_bits);
    jbed_vm_put_word(memory, table + TABLE_DYNAMIC_SHIFT, dynamic_index_bits);
    jbed_vm_put_word(memory, table + TABLE_DYNAMIC_BUCKET_MASK, (1u << dynamic_bucket_bits) - 1);
    jbed_vm_put_word(memory, table + TABLE_DYNAMIC_INDEX_MASK, (1u << dynamic_index_bits) - 1);
    if (image[2]) {
        jbed_vm_put_word(memory, table + TABLE_EXTRA_BIT, 1u << index_bits);
        jbed_vm_put_word(memory, table + TABLE_BUCKET_SHIFT, index_bits + 1);
    }
}

typedef struct NameEntry {
    const uint8_t *bytes;
    int32_t length;
    JbRef array;
    uint32_t offset;
} NameEntry;

static uint8_t array_byte(JbedVm *vm, JbRef array, uint32_t index)
{
    if (index >= jbed_vm_word(vm->heap.memory, array + ARRAY_LENGTH))
        jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    return *jbed_vm_at(vm->heap.memory, array + ARRAY_DATA + index);
}

static NameEntry name_entry(JbedVm *vm, JbRef table, int32_t id)
{
    JbedBuffer memory = vm->heap.memory;
    if (!table)
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    if (id & DYNAMIC_NAME_ID) {
        JbRef reference = jbed_vm_word(memory, table + TABLE_DYNAMIC_REFERENCE);
        if (reference)
            return name_entry(vm, reference, id & (DYNAMIC_NAME_ID - 1));
        uint32_t shift = jbed_vm_word(memory, table + TABLE_DYNAMIC_SHIFT) & 31;
        uint32_t bucket = (uint32_t)(id >> shift) & jbed_vm_word(memory, table + TABLE_DYNAMIC_BUCKET_MASK);
        int32_t ordinal = id & jbed_vm_word(memory, table + TABLE_DYNAMIC_INDEX_MASK);
        JbRef buckets = jbed_vm_word(memory, table + TABLE_DYNAMIC_BUCKETS);
        if (!buckets)
            return (NameEntry){.length = -1};
        if (bucket >= jbed_vm_word(memory, buckets + ARRAY_LENGTH))
            jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
        JbRef array = jbed_vm_word(memory, buckets + ARRAY_DATA + 4 * bucket);
        if (!array)
            return (NameEntry){.length = -1};
        uint32_t index = 0, length = 0;
        int8_t byte = (int8_t)array_byte(vm, array, index);
        while (byte) {
            length = (uint8_t)byte & 127;
            ++index;
            while (byte > 0) {
                byte = (int8_t)array_byte(vm, array, index++);
                length = length << 7 | ((uint8_t)byte & 127);
            }
            if (ordinal > 0 && !--ordinal)
                break;
            index += length;
            byte = (int8_t)array_byte(vm, array, index);
        }
        return (NameEntry){.bytes = jbed_vm_at(memory, array + ARRAY_DATA + index),
            .length = byte ? (int32_t)length : -1, .array = array, .offset = index};
    }
    if (!id)
        return (NameEntry){.length = -1};
    uint32_t shift = jbed_vm_word(memory, table + TABLE_BUCKET_SHIFT) & 31;
    uint32_t bucket = (uint32_t)(id >> shift) & jbed_vm_word(memory, table + TABLE_BUCKET_MASK);
    int32_t ordinal = id & jbed_vm_word(memory, table + TABLE_INDEX_MASK);
    uint32_t image = jbed_vm_word(memory, table + TABLE_IMAGE);
    uint32_t chain = jbed_vm_word(memory, image + 4 + 4 * bucket);
    uint64_t entry = ReflectionTable_getStaticAdr(table, (const int8_t *)(uintptr_t)chain, ordinal);
    return (NameEntry){.bytes = (const uint8_t *)(uintptr_t)(uint32_t)entry,
        .length = (int32_t)(entry >> 32)};
}

int32_t ReflectionTable_getData(JbRef table, int32_t id, JbRef array, uint8_t *destination)
{
    JbedVm *vm = active();
    JbedReflectionTable *shared = shared_table(vm, table);
    if (shared) {
        int32_t length = jbed_reflection_data(shared, (uint16_t)id, NULL, 0);
        if (length > 0) {
            if (array && (int32_t)jbed_vm_word(vm->heap.memory, array + ARRAY_LENGTH) >= length)
                jbed_reflection_data(shared, (uint16_t)id,
                    jbed_vm_at(vm->heap.memory, array + ARRAY_DATA), (uint32_t)length);
            if (destination)
                jbed_reflection_data(shared, (uint16_t)id, destination, (uint32_t)length);
        }
        return length;
    }
    NameEntry entry = name_entry(vm, table, id);
    if (entry.length > 0) {
        if (array && (int32_t)jbed_vm_word(vm->heap.memory, array + ARRAY_LENGTH) >= entry.length) {
            if (entry.array) {
                uint32_t source_length = jbed_vm_word(vm->heap.memory, entry.array + ARRAY_LENGTH);
                if (entry.offset > source_length || (uint32_t)entry.length > source_length - entry.offset)
                    jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
            }
            memmove(jbed_vm_at(vm->heap.memory, array + ARRAY_DATA), entry.bytes, (size_t)entry.length);
        }
        if (destination)
            memmove(destination, entry.bytes, (size_t)entry.length);
    }
    return entry.length;
}

int32_t ReflectionTable_getFirstByte(JbRef table, int32_t id)
{
    JbedVm *vm = active();
    JbedReflectionTable *shared = shared_table(vm, table);
    if (shared)
        return jbed_reflection_first_byte(shared, (uint16_t)id);
    NameEntry entry = name_entry(vm, table, id);
    if (entry.length <= 0)
        return -1;
    return entry.array ? array_byte(vm, entry.array, entry.offset) : *entry.bytes;
}

void ReflectionTable_clearDynamicHash(JbRef table)
{
    JbedVm *vm = active();
    JbedReflectionTable *shared = shared_table(vm, table);
    if (shared)
        jbed_reflection_clear_dynamic(shared);
    jbed_vm_put_word(vm->heap.memory, table + TABLE_DYNAMIC_BUCKETS, 0);
    jbed_vm_put_word(vm->heap.memory, table + TABLE_DYNAMIC_REFERENCE, 0);
    for (unsigned field = TABLE_DYNAMIC_BYTES; field <= TABLE_USED_BUCKETS; field += 4)
        jbed_vm_put_word(vm->heap.memory, table + field, 0);
}

void ReflectionTable_referenceDynamicTable(JbRef table, const uint8_t *image)
{
    JbedVm *vm = active();
    JbedReflectionTable *shared = shared_table(vm, table);
    JbedVmHeapRoot root = {table, table, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbRef reference = jbed_vm_allocate_object(vm,
        jbed_vm_find_class(vm, "com/jbed/reflect/ReflectionTable"), false);
    ReflectionTable_init(reference, image);
    table = root.value;
    vm->heap.temporary_roots = root.previous;
    jbed_vm_put_word(vm->heap.memory, table + TABLE_DYNAMIC_REFERENCE, reference);
    if (shared) {
        JbedBuffer memory = vm->heap.memory;
        JbedImageView view = {memory.data, memory.size, memory.address};
        if (!jbed_reflection_reference(shared, view, (uint32_t)(uintptr_t)image))
            jbed_vm_fatal(vm, "Invalid referenced reflection table image");
    }
}

static _Noreturn void string_bounds(JbedVm *vm)
{
    JbRef exception = jbed_vm_new_throwable(vm, "java/lang/StringIndexOutOfBoundsException");
    JbedError error = {.kind = JBED_ERROR_THROWABLE,
        .runtime_throwable = jbed_vm_at(vm->heap.memory, exception)};
    jbed_raise(&vm->services, &error);
}

static uint16_t string_character(JbedVm *vm, JbRef string, int32_t index)
{
    JbedBuffer memory = vm->heap.memory;
    if ((uint32_t)index >= jbed_vm_word(memory, string + STRING_LENGTH))
        string_bounds(vm);
    uint32_t characters = jbed_vm_word(memory, string + STRING_CHARACTERS) +
                          jbed_vm_word(memory, string + STRING_OFFSET);
    return jbed_vm_half(memory, characters + 2 * (uint32_t)index);
}

static JbRef utf8_slice(JbedVm *vm, JbRef string, int32_t start, int32_t end)
{
    JbedBuffer memory = vm->heap.memory;
    if (start < 0 || start > end || end > (int32_t)jbed_vm_word(memory, string + STRING_LENGTH))
        string_bounds(vm);
    uint32_t size = 0;
    for (int32_t i = start; i < end; ++i) {
        uint16_t ch = string_character(vm, string, i);
        size += ch && ch < 0x80 ? 1 : ch < 0x800 ? 2 : 3;
    }
    JbedVmHeapRoot root = {string, string, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbRef array = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_BYTE], (int32_t)size, false);
    string = root.value;
    vm->heap.temporary_roots = root.previous;
    uint8_t *output = jbed_vm_at(memory, array + ARRAY_DATA);
    for (int32_t i = start; i < end; ++i) {
        uint16_t ch = string_character(vm, string, i);
        if (ch && ch < 0x80) {
            *output++ = (uint8_t)ch;
        } else {
            output[0] = (uint8_t)(0xc0 | ((ch >> 6) & 31));
            output[1] = (uint8_t)(0x80 | (ch & 63));
            /* String.getUtf8Bytes leaves the third byte zero for these units. */
            output += ch < 0x800 ? 2 : 3;
        }
    }
    return array;
}

static int32_t string_slice_id(JbedVm *vm, JbRef table, JbRef string,
                                int32_t start, int32_t end, bool create)
{
    JbedVmHeapRoot root = {table, table, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbRef bytes = utf8_slice(vm, string, start, end);
    table = root.value;
    vm->heap.temporary_roots = root.previous;
    return ReflectionTable_dataToId(table, bytes, 0, NULL,
        (int32_t)jbed_vm_word(vm->heap.memory, bytes + ARRAY_LENGTH), create);
}

int32_t ReflectionTable_stringToId(JbRef table, JbRef string, bool create)
{
    JbedVm *vm = active();
    if (!string)
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    return string_slice_id(vm, table, string, 0,
        (int32_t)jbed_vm_word(vm->heap.memory, string + STRING_LENGTH), create);
}

uint64_t ClassAccess_getClassParams(JbRef access, JbRef string, const uint8_t *address,
                                     int32_t length, bool create)
{
    (void)access;
    JbedVm *vm = active();
    int32_t dimensions = 0;
    while (dimensions < length && (string ? string_character(vm, string, dimensions)
                                          : address[dimensions]) == '[')
        ++dimensions;
    if (dimensions == length)
        return 0;
    int32_t start = 0, end = length;
    if (dimensions) {
        uint16_t character = string ? string_character(vm, string, dimensions) : address[dimensions];
        const char *primitive_codes = "ZCFDBSIJ";
        const char *primitive = character && character < 128 ? strchr(primitive_codes, (char)character) : NULL;
        if (character == 'L') {
            start = dimensions + 1;
            end = length - 1;
        } else {
            if (!primitive || dimensions + 1 != (string
                    ? (int32_t)jbed_vm_word(vm->heap.memory, string + STRING_LENGTH) : length))
                return 0;
            return (uint32_t)(JBED_TYPE_BOOLEAN + (primitive - primitive_codes)) << 16 |
                   (uint64_t)(uint32_t)dimensions << 32;
        }
    }
    if (start >= end)
        return 0;
    int32_t slash = string ? (int32_t)jbed_vm_word(vm->heap.memory, string + STRING_LENGTH) - 1 : end - 1;
    int32_t limit = string ? 0 : start;
    while (slash >= limit && (string ? string_character(vm, string, slash) : address[slash]) != '/')
        --slash;
    JbRef packages = jbed_vm_word(vm->heap.memory, vm->isolate_statics + PACKAGE_TABLE_STATIC);
    JbRef bases = jbed_vm_word(vm->heap.memory, vm->isolate_statics + BASE_NAME_TABLE_STATIC);
    int32_t package = 0, base;
    if (string) {
        JbedVmHeapRoot root = {string, string, vm->heap.temporary_roots};
        vm->heap.temporary_roots = &root;
        if (slash > start)
            package = string_slice_id(vm, packages, root.value, start, slash, create);
        bases = jbed_vm_word(vm->heap.memory, vm->isolate_statics + BASE_NAME_TABLE_STATIC);
        base = string_slice_id(vm, bases, root.value, slash > start ? slash + 1 : start, end, create);
        vm->heap.temporary_roots = root.previous;
    } else {
        if (slash > start)
            package = ReflectionTable_dataToId(packages, 0, 0, address + start, slash - start, create);
        base = ReflectionTable_dataToId(bases, 0, 0, address + (slash > start ? slash + 1 : start),
                                         end - (slash > start ? slash + 1 : start), create);
    }
    if (!base || (!package && slash > start))
        return 0;
    return (uint16_t)package | (uint32_t)(uint16_t)base << 16 |
           (uint64_t)(uint32_t)dimensions << 32;
}

int32_t ClassAccess_getClassNameUtf8(int32_t package, int32_t base, int32_t dimensions,
                                   uint8_t *destination, int32_t capacity)
{
    JbedVm *vm = active();
    uint32_t primitive = (uint32_t)base - JBED_TYPE_BOOLEAN;
    if (primitive <= JBED_TYPE_LONG - JBED_TYPE_BOOLEAN) {
        int32_t required = add(dimensions, 2);
        if (capacity < required) {
            if (capacity > 0) *destination = 0;
            return required;
        }
        for (int32_t i = 0; i < dimensions; ++i)
            *destination++ = '[';
        *destination++ = (uint8_t)"ZCFDBSIJ"[primitive];
        *destination = 0;
        return required;
    }

    JbRef packages = jbed_vm_word(vm->heap.memory, vm->isolate_statics + PACKAGE_TABLE_STATIC);
    JbRef bases = jbed_vm_word(vm->heap.memory, vm->isolate_statics + BASE_NAME_TABLE_STATIC);
    int32_t package_size = package ? ReflectionTable_getData(packages, package, 0, NULL) : 0;
    int32_t base_size = ReflectionTable_getData(bases, base, 0, NULL);
    int32_t required = add(add(package_size, package != 0), base_size);
    if (dimensions != 0)
        required = add(required, add(dimensions, 2));
    required = add(required, 1);
    if (capacity < required) {
        if (capacity > 0) *destination = 0;
        return required;
    }
    if (dimensions > 0) {
        for (int32_t i = 0; i < dimensions; ++i)
            *destination++ = '[';
        *destination++ = 'L';
    }
    if (package) {
        ReflectionTable_getData(packages, package, 0, destination);
        destination += package_size;
        *destination++ = '/';
    }
    ReflectionTable_getData(bases, base, 0, destination);
    destination += base_size;
    if (dimensions > 0)
        *destination++ = ';';
    *destination = 0;
    return required;
}

void Field_init(JbRef field, JbRef owner, const uint8_t *record)
{
    JbedBuffer memory = active()->heap.memory;
    uint32_t flags = word(record), type = half(record + 6);
    jbed_vm_put_word(memory, field + 12, owner);
    jbed_vm_put_word(memory, field + 16, flags);
    memcpy(jbed_vm_at(memory, field + 20), record + 4, 2);
    jbed_vm_put_word(memory, field + 24, type);
    if (!(flags & JBED_FIELD_CONSTANT))
        jbed_vm_put_word(memory, field + 28, word(record + 8));
    else if (!(type >> 4) && type % 4 == 3) {
        jbed_vm_put_word(memory, field + 32, word(record + 12));
        jbed_vm_put_word(memory, field + 36, word(record + 8));
    } else
        jbed_vm_put_word(memory, field + 32, word(record + 8));
}

void Method_init(JbRef method, JbRef owner, const uint8_t *record)
{
    JbedBuffer memory = active()->heap.memory;
    jbed_vm_put_word(memory, method + 12, owner);
    memcpy(jbed_vm_at(memory, method + 16), record, 16);
    jbed_vm_put_word(memory, method + 32, (uint32_t)(uintptr_t)record | 1);
}

uint64_t ReflectionTable_getStaticAdr(JbRef table, const int8_t *chain, int32_t ordinal)
{
    (void)table;
    uint32_t length = 0;
    int8_t byte = *chain;
    while (byte) {
        length = (uint8_t)byte & 127;
        ++chain;
        while (byte > 0) {
            byte = *chain++;
            length = length << 7 | ((uint8_t)byte & 127);
        }
        ordinal = add(ordinal, -1);
        if (!ordinal)
            break;
        chain += length;
        byte = *chain;
    }
    uint32_t size = byte ? length : UINT32_MAX;
    return (uint32_t)(uintptr_t)chain | (uint64_t)size << 32;
}

int32_t Method_getOffset(uint32_t address, uint32_t flags, uint32_t size,
                         uint32_t pc, const uint32_t *ranges)
{
    if (!address)
        return -1;
    if (!(flags & JBED_METHOD_CODE_RANGES)) {
        int32_t offset = (int32_t)(pc - address);
        return offset >= 0 && (int32_t)(pc - (address + size)) < 0 ? offset : -1;
    }
    ranges += 2 * size;
    uint32_t preceding = 0;
    for (; ranges[0]; ranges += 2) {
        uint32_t first = ranges[0], end = ranges[1] + 1;
        uint32_t length = end - first;
        if ((int32_t)length <= 0)
            jbed_vm_fatal(active(), "Corrupted method info");
        int32_t offset = (int32_t)(pc - first);
        if (offset >= 0 && (int32_t)(pc - end) < 0)
            return (int32_t)(preceding + (uint32_t)offset);
        preceding += length;
    }
    return -1;
}

JbedAddress Method_getCodeRangeBase(JbRef klass)
{
    JbedVm *vm = active();
    if (!klass)
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    uint32_t count = jbed_vm_half(vm->heap.memory, klass + CLASS_METHOD_COUNT) +
                     jbed_vm_half(vm->heap.memory, klass + CLASS_FIELD_COUNT);
    return klass + CLASS_MEMBERS + count * MEMBER_BYTES;
}

JbedAddress Method_searchMethodByPc(JbRef klass, uint32_t pc)
{
    JbedVm *vm = active();
    if (!klass)
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    const uint8_t *object = jbed_vm_at(vm->heap.memory, klass);
    const uint8_t *method = jbed_search_rom_method_by_pc(&vm->services, object,
        vm->heap.memory.size - (klass - vm->heap.memory.address), pc);
    return method ? klass + (uint32_t)(method - object) : 0;
}

JbedAddress ClassRefTable_bucketAdr(JbRef table, int32_t bucket)
{
    JbedVm *vm = active();
    uint32_t image = jbed_vm_word(vm->heap.memory, table + CLASS_REF_TABLE_IMAGE);
    return jbed_vm_word(vm->heap.memory, image + 8 + 4 * (uint32_t)bucket);
}

static JbRef class_reference(JbedVm *vm, JbRef object)
{
    JbedClass *class_class = jbed_vm_class_at(&vm->resident, vm->class_class);
    return jbed_vm_checkcast(&vm->resident, vm->heap.memory, object, class_class);
}

void ClassRefTable_init(JbRef table, const uint8_t *image)
{
    JbedVm *vm = active();
    JbedBuffer memory = vm->heap.memory;
    uint32_t bucket_mask = (1u << (image[0] & 15)) - 1;
    uint32_t overflow_limit = (1u << (image[0] >> 4)) - 1;
    uint32_t count = half(image + 4), index_size = half(image + 6);
    jbed_vm_put_word(memory, table + CLASS_REF_TABLE_IMAGE, (uint32_t)(uintptr_t)image);
    jbed_vm_put_word(memory, table + CLASS_REF_BUCKET_MASK, bucket_mask);
    jbed_vm_put_word(memory, table + CLASS_REF_OVERFLOW_LIMIT, overflow_limit);
    jbed_vm_put_word(memory, table + CLASS_REF_COUNT, count);
    JbedVmHeapRoot root = {table, table, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    JbRef index = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_INT],
                                         (int32_t)index_size, false);
    table = root.value;
    vm->heap.temporary_roots = root.previous;
    jbed_vm_put_word(memory, table + CLASS_REF_INDEX, index);
    uint32_t found = 0;
    for (uint32_t bucket = 0; found < count; ++bucket) {
        if (bucket > bucket_mask)
            jbed_vm_fatal(vm, "error data in reflection table");
        uint32_t chain = ClassRefTable_bucketAdr(table, (int32_t)bucket);
        if (!chain)
            continue;
        int32_t entries = (int32_t)jbed_vm_word(memory, chain);
        for (int32_t i = 0; i < entries; ++i) {
            uint32_t record = chain + 4 + CLASS_REF_RECORD_SIZE * (uint32_t)i;
            JbRef klass = class_reference(vm, jbed_vm_word(memory, record + 8));
            if (!klass)
                jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
            uint32_t slot = (jbed_vm_word(memory, klass + CLASS_ID) & 0xffff) - 1;
            if (slot >= index_size)
                jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
            jbed_vm_put_word(memory, index + ARRAY_DATA + 4 * slot, record);
            ++found;
        }
    }
}

static JbedAddress class_record(JbedVm *vm, JbRef table, int32_t id)
{
    JbedBuffer memory = vm->heap.memory;
    JbRef index = jbed_vm_word(memory, table + CLASS_REF_INDEX);
    uint32_t slot = ((uint32_t)id & 0xffff) - 1;
    if (!index || slot >= jbed_vm_word(memory, index + ARRAY_LENGTH))
        return 0;
    return jbed_vm_word(memory, index + ARRAY_DATA + 4 * slot);
}

uint64_t ClassRefTable_classParams(JbRef table, int32_t id)
{
    JbedVm *vm = active();
    JbedBuffer memory = vm->heap.memory;
    JbRef index = jbed_vm_word(memory, table + CLASS_REF_INDEX);
    uint32_t slot = ((uint32_t)id & 0xffff) - 1;
    if (!index || slot >= jbed_vm_word(memory, index + ARRAY_LENGTH))
        return 0;
    uint32_t record = jbed_vm_word(memory, index + ARRAY_DATA + 4 * slot);
    return jbed_vm_word(memory, record) | (uint64_t)jbed_vm_half(memory, record + 4) << 32;
}

JbRef ClassRefTable_classObject(JbRef table, int32_t id)
{
    JbedVm *vm = active();
    if ((uint32_t)id - JBED_TYPE_BOOLEAN <= JBED_TYPE_LONG - JBED_TYPE_BOOLEAN) {
        JbedClass *klass = jbed_class_object(&vm->classes, (uint32_t)id);
        if (!klass)
            jbed_vm_fatal(vm, "Primitive class is absent from the boot image");
        return jbed_class_target_address(&vm->classes, klass);
    }
    uint32_t record = class_record(vm, table, id);
    return record ? class_reference(vm, jbed_vm_word(vm->heap.memory, record + 8)) : 0;
}

JbRef ClassRefTable_getNextClass(JbRef table, JbRef previous)
{
    JbedVm *vm = active();
    JbedBuffer memory = vm->heap.memory;
    uint32_t slot = previous ? jbed_vm_word(memory, previous + CLASS_ID) & 0xffff : 0;
    JbRef index = jbed_vm_word(memory, table + CLASS_REF_INDEX);
    if (!index)
        return 0;
    uint32_t length = jbed_vm_word(memory, index + ARRAY_LENGTH);
    for (; slot < length; ++slot) {
        uint32_t record = jbed_vm_word(memory, index + ARRAY_DATA + 4 * slot);
        if (record)
            return class_reference(vm, jbed_vm_word(memory, record + 8));
    }
    return 0;
}

JbRef ClassRefTable_lookupClass(JbRef table, int32_t hash, int32_t package,
                               int32_t base, int32_t dimensions, bool include_hidden)
{
    JbedVm *vm = active();
    JbedBuffer memory = vm->heap.memory;
    uint32_t mask = jbed_vm_word(memory, table + CLASS_REF_BUCKET_MASK);
    uint32_t first = (uint32_t)hash & mask, bucket = first;
    do {
        uint32_t chain = ClassRefTable_bucketAdr(table, (int32_t)bucket);
        if (!chain)
            return 0;
        int32_t count = (int32_t)jbed_vm_word(memory, chain);
        for (int32_t i = 0; i < count; ++i) {
            uint32_t record = chain + 4 + CLASS_REF_RECORD_SIZE * (uint32_t)i;
            if (jbed_vm_half(memory, record) != package ||
                jbed_vm_half(memory, record + 2) != base ||
                jbed_vm_half(memory, record + 4) != dimensions)
                continue;
            JbRef klass = class_reference(vm, jbed_vm_word(memory, record + 8));
            if (include_hidden)
                return klass;
            if (!klass)
                jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
            return jbed_vm_class_visible(jbed_vm_class_at(&vm->resident, klass)) ? klass : 0;
        }
        if (count <= (int32_t)jbed_vm_word(memory, table + CLASS_REF_OVERFLOW_LIMIT))
            return 0;
        bucket = (bucket + 1) & mask;
    } while (bucket != first);
    return 0;
}

static JbedAddress class_access_slot(JbedVm *vm, const char *name)
{
    JbedAddress slot = jbed_vm_static_field_slot(vm, "com/jbed/reflect/ClassAccess", name);
    if (!slot) jbed_vm_fatal(vm, "Missing ClassAccess static field");
    return slot;
}

static JbRef bundle_space(JbedVm *vm, int32_t bundle)
{
    JbedAddress slot = class_access_slot(vm, "classRefTables");
    JbRef array = jbed_vm_word(vm->heap.memory, slot);
    int32_t required = add(bundle, 1);
    uint32_t length = array ? jbed_vm_word(vm->heap.memory, array + ARRAY_LENGTH) : 0;
    if (array && (int32_t)length >= required) return array;
    if (!array && required < 16) required = 16;
    JbRef grown = jbed_vm_allocate_array(vm,
        jbed_vm_find_class(vm, "[Lcom/jbed/reflect/ClassRefTable;"), required, false);
    array = jbed_vm_word(vm->heap.memory, slot);
    if (length) memcpy(jbed_vm_at(vm->heap.memory, grown + ARRAY_DATA),
                       jbed_vm_at(vm->heap.memory, array + ARRAY_DATA), 4u * length);
    jbed_vm_put_word(vm->heap.memory, slot, grown);
    return grown;
}

static void put_bundle(JbedVm *vm, int32_t bundle, JbedAddress image)
{
    JbRef table = jbed_vm_allocate_object(vm,
        jbed_vm_find_class(vm, "com/jbed/reflect/ClassRefTable"), false);
    JbedVmHeapRoot root = {table, table, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    ClassRefTable_init(table, jbed_vm_at(vm->heap.memory, image));
    JbRef array = jbed_vm_word(vm->heap.memory, class_access_slot(vm, "classRefTables"));
    if ((uint32_t)bundle >= jbed_vm_word(vm->heap.memory, array + ARRAY_LENGTH))
        jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    jbed_vm_put_word(vm->heap.memory, array + ARRAY_DATA + 4u * (uint32_t)bundle, root.value);
    vm->heap.temporary_roots = root.previous;
}

typedef struct BundleLoad {
    JbedVm *vm;
    int32_t bundle;
    JbedAddress image, packages, bases;
    bool dynamic;
} BundleLoad;

static void load_bundle(void *context)
{
    BundleLoad *load = context;
    JbedVm *vm = load->vm;
    if (load->bundle > 1 || (load->dynamic && load->bundle != 1))
        jbed_vm_fatal(vm, "Invalid class bundle number");
    if (load->dynamic && vm->classes.next_low_id != 1)
        jbed_vm_fatal(vm, "Dynamic classes already allocated");
    JbRef array = bundle_space(vm, load->bundle);
    if ((uint32_t)load->bundle >= jbed_vm_word(vm->heap.memory, array + ARRAY_LENGTH))
        jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    JbRef existing = jbed_vm_word(vm->heap.memory, array + ARRAY_DATA + 4u * (uint32_t)load->bundle);
    if (existing) {
        if (load->dynamic) jbed_vm_fatal(vm, "Class bundle already loaded");
        return;
    }
    if (load->dynamic) {
        JbedBuffer memory = vm->heap.memory;
        JbedImageView image = {memory.data, memory.size, memory.address};
        ReflectionTable_referenceDynamicTable(jbed_vm_word(memory, vm->reflection_roots[0]),
                                               jbed_vm_at(memory, load->packages));
        ReflectionTable_referenceDynamicTable(jbed_vm_word(memory, vm->reflection_roots[1]),
                                               jbed_vm_at(memory, load->bases));
        JbedVmClassTable *table = jbed_alloc(&vm->services, sizeof(*table));
        jbed_vm_class_table_load(table, &vm->services, image, load->image, &vm->resident);
        put_bundle(vm, load->bundle, load->image);
        vm->classes.bundles[1] = table;
        ++vm->classes.dynamic_bundle;
        jbed_vm_put_word(memory, class_access_slot(vm, "loadedBundleId"), (uint32_t)load->bundle);
        JbedAddress dynamic = class_access_slot(vm, "dynamicBundleId");
        jbed_vm_put_word(memory, dynamic, jbed_vm_word(memory, dynamic) + 1);
    } else {
        const JbedVmClassTable *table = vm->classes.bundles[load->bundle];
        if (!table) jbed_vm_fatal(vm, "Class bundle has no resident image");
        put_bundle(vm, load->bundle, table->index);
    }
}

static void synchronized_bundle_load(BundleLoad *load)
{
    JbedVm *vm = load->vm;
    JbedAddress monitor = jbed_vm_find_class(vm, "com/jbed/reflect/ClassAccess");
    JbedVmMonitorResult entered = jbed_vm_monitor_enter(&vm->monitors, monitor);
    if (entered != JBED_MONITOR_DONE)
        jbed_vm_raise(vm, entered == JBED_MONITOR_ALLOCATION_FAILED
            ? JBED_ERROR_OUT_OF_MEMORY : JBED_ERROR_INTERNAL, "Cannot enter class bundle monitor");
    JbedError error;
    JbedVmHeapRoot *roots = vm->heap.temporary_roots;
    bool success = vm->services.protected_call(vm->services.context, load_bundle, load, &error);
    vm->heap.temporary_roots = roots;
    if (jbed_vm_monitor_exit(&vm->monitors, monitor) != JBED_MONITOR_DONE)
        jbed_vm_fatal(vm, "Cannot leave class bundle monitor");
    if (!success) jbed_raise(&vm->services, &error);
}

void ClassAccess_loadBundle(int32_t bundle)
{
    BundleLoad load = {.vm = active(), .bundle = bundle};
    synchronized_bundle_load(&load);
}

void ClassAccess_loadDynamicBundle(int32_t bundle, JbedAddress image,
                                   JbedAddress packages, JbedAddress bases)
{
    BundleLoad load = {.vm = active(), .bundle = bundle, .image = image,
        .packages = packages, .bases = bases, .dynamic = true};
    synchronized_bundle_load(&load);
}

void ClassAccess_resetTables(void)
{
    JbedVm *vm = active();
    ReflectionTable_clearDynamicHash(jbed_vm_word(vm->heap.memory, vm->reflection_roots[1]));
    ReflectionTable_clearDynamicHash(jbed_vm_word(vm->heap.memory, vm->reflection_roots[0]));
    jbed_vm_put_word(vm->heap.memory, class_access_slot(vm, "dynamicBundleId"), 1);
    vm->classes.dynamic_bundle = 1;
}

static void initialize_class_iterator(JbedVm *vm)
{
    JbedAddress slot = jbed_vm_static_field_slot(vm, "com/jbed/reflect/Field", "classList");
    JbedAddress address = jbed_vm_find_class(vm, "com/jbed/reflect/ClassAccess$ClassIterator");
    if (!slot || !address) jbed_vm_fatal(vm, "Missing class iterator metadata");
    JbedClass *klass = jbed_class_from_target(&vm->classes, address);
    JbedSignatureServices services = {.runtime = &vm->services,
        .reflection_table = &vm->signatures, .types = jbed_signature_rom_types(),
        .class_access = &vm->classes};
    JbedSignatureEncoder encoder;
    jbed_signature_init(&encoder, &services);
    JbedTypeId arguments[] = {jbed_vm_word(vm->heap.memory,
        vm->classes.heap_image.class_access_class + CLASS_ID), JBED_TYPE_BOOLEAN};
    JbedSignatureId signature = jbed_signature_build_types(&encoder, arguments, 2, 0, true);
    JbedNameId name = jbed_reflection_id(&vm->method_names, (const uint8_t *)"<init>", 6, false);
    JbedMethod *constructor = klass->methods;
    while (constructor && (constructor->name_id != name || constructor->signature_id != signature))
        constructor = constructor->next;
    if (!constructor || !constructor->code_address)
        jbed_vm_raise(vm, JBED_ERROR_NO_SUCH_METHOD, "ClassAccess.ClassIterator constructor");
    JbRef object = jbed_vm_allocate_object(vm, address, false);
    JbedVmHeapRoot root = {object, object, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    uint32_t values[] = {object, jbed_vm_word(vm->heap.memory, vm->classes.guest_root), false};
    uint64_t ignored;
    bool success = jbed_vm_invoke(vm, constructor->code_address, values, 3, &ignored);
    object = root.value;
    vm->heap.temporary_roots = root.previous;
    if (!success) jbed_raise(&vm->services, &(JbedError){.kind = JBED_ERROR_THROWABLE,
        .runtime_throwable = jbed_vm_at(vm->heap.memory, vm->pending_exception)});
    jbed_vm_put_word(vm->heap.memory, slot, object);
}

void ClassAccess_initClassAccess(void)
{
    JbedVm *vm = active();
    JbedClassHeapImage anchors = {
        .class_access_class = jbed_vm_find_class(vm, "com/jbed/reflect/ClassAccess"),
        .class_class = vm->class_class,
        .class_array_class = jbed_vm_find_class(vm, "[Ljava/lang/Class;"),
        .compiler_root = jbed_vm_static_field_slot(vm, "com/jbed/tbcc/Compiler", "classes"),
        .registered_root = jbed_vm_static_field_slot(vm, "java/lang/Class", "classes")
    };
    if (!anchors.class_access_class || !anchors.class_class || !anchors.class_array_class ||
        !anchors.compiler_root || !anchors.registered_root)
        jbed_vm_fatal(vm, "ClassAccess initialization requires its class metadata and static roots");
    static const struct { const char *owner, *field; } reflection_fields[] = {
        {"com/jbed/reflect/ClassAccess", "packageNameTable"},
        {"com/jbed/reflect/ClassAccess", "baseNameTable"},
        {"com/jbed/reflect/Method", "reflTable"},
        {"com/jbed/reflect/Field", "reflTable"},
        {"com/jbed/reflect/SignatureEncoder", "reflTable"}
    };
    for (size_t i = 0; i < sizeof(reflection_fields) / sizeof(*reflection_fields); ++i) {
        vm->reflection_roots[i] = jbed_vm_static_field_slot(vm,
            reflection_fields[i].owner, reflection_fields[i].field);
        if (!vm->reflection_roots[i]) jbed_vm_fatal(vm, "Missing reflection table static root");
    }
    JbedVmHeapRoot compiler_root = {jbed_vm_word(vm->heap.memory, anchors.compiler_root), 0,
        vm->heap.temporary_roots};
    compiler_root.relocated = compiler_root.value;
    vm->heap.temporary_roots = &compiler_root;
    jbed_class_access_init(&vm->classes, &vm->services, &vm->resident,
        &vm->packages, &vm->base_names, true);
    vm->classes.isolate_statics = vm->isolate_statics;
    jbed_class_bind_heap_image(&vm->classes, &vm->heap, anchors);
    jbed_class_publish(&vm->classes);
    jbed_vm_put_word(vm->heap.memory, anchors.compiler_root, compiler_root.value);
    vm->heap.temporary_roots = compiler_root.previous;
    JbedReflectionTable *tables[] = {&vm->packages, &vm->base_names,
        &vm->method_names, &vm->field_names, &vm->signatures};
    JbedAddress klass = jbed_vm_find_class(vm, "com/jbed/reflect/ReflectionTable");
    for (size_t i = 0; i < sizeof(tables) / sizeof(*tables); ++i) {
        jbed_reflection_clear_dynamic(tables[i]);
        JbRef object = jbed_vm_allocate_object(vm, klass, false);
        ReflectionTable_init(object, tables[i]->bucket_words - 4);
        jbed_vm_put_word(vm->heap.memory, vm->reflection_roots[i], object);
        if (i == 2 || i == 3) {
            JbedAddress alias = jbed_vm_static_field_slot(vm, "com/jbed/tbcc/Pool",
                i == 2 ? "methNameTable" : "fieldNameTable");
            if (alias) jbed_vm_put_word(vm->heap.memory, alias, object);
        }
    }
    jbed_vm_put_word(vm->heap.memory, class_access_slot(vm, "dynamicBundleId"), 1);
    initialize_class_iterator(vm);
    ClassAccess_loadBundle(0);
}
