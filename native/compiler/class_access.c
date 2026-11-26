#include "class_access.h"
#include "rom_objects.h"
#include "vm_words.h"
#include <string.h>

/* ClassAccess.dynClassInfo stores four shorts per entry; zero marks the end
 * of a bucket, so the package ID is stored one greater than its actual value. */
typedef struct ClassEntry {
    uint16_t package_plus_one, base, dimensions, low_id;
} ClassEntry;

struct JbedClassBucket {
    ClassEntry *entries;
    uint32_t capacity;
};

enum {
    COMPILER_CLASS_ACCESS = 1092,
    REGISTERED_CLASSES = 1476,
    ROM_CLASS_ACCESS = 0x208b58,
    ROM_CLASS = 0x216898,
    ROM_CLASS_ARRAY = 0x25e270
};

static void guest_allocation_error(JbedClassAccess *a, JbedVmHeap *heap)
{
    if (heap->fault == JBED_HEAP_OUT_OF_MEMORY)
        jbed_raise(a->runtime,
                   &(JbedError){.kind = JBED_ERROR_OUT_OF_MEMORY, .is_java_error = true});
    jbed_raise_internal(a->runtime, "Cannot allocate guest class metadata");
}

static bool contains(JbedBuffer memory, JbedAddress address, uint32_t size)
{
#if defined(JBED_NATIVE_ADDRESS_SPACE)
    (void)memory;
    return address && size <= UINT32_MAX - address;
#else
    return address && address >= memory.address && size <= memory.size &&
           address - memory.address <= memory.size - size;
#endif
}

void jbed_class_bind_heap_image(JbedClassAccess *a, JbedVmHeap *heap, JbedClassHeapImage image)
{
    if (!heap || !contains(heap->memory, image.class_access_class, 40) ||
        !contains(heap->memory, image.class_class, 40) ||
        !contains(heap->memory, image.class_array_class, 40) ||
        !contains(heap->memory, image.compiler_root, 4) ||
        !contains(heap->memory, image.registered_root, 4))
        jbed_raise_internal(a->runtime, "Missing ClassAccess heap image anchors");
    if (a->guest_root) {
        if (a->heap != heap ||
            a->heap_image.class_access_class != image.class_access_class ||
            a->heap_image.class_class != image.class_class ||
            a->heap_image.class_array_class != image.class_array_class ||
            a->heap_image.compiler_root != image.compiler_root ||
            a->heap_image.registered_root != image.registered_root)
            jbed_raise_internal(a->runtime, "ClassAccess already belongs to an isolate");
        return;
    }
    if (jbed_vm_word(heap->memory, image.class_access_class + 28) < 36 ||
        jbed_vm_word(heap->memory, image.class_class + 28) < 72 ||
        !(jbed_vm_word(heap->memory, image.class_array_class + 12) & JBED_CLASS_ARRAY))
        jbed_raise_internal(a->runtime, "Invalid ClassAccess heap image classes");
    JbedAddress object = jbed_vm_new_object(heap, image.class_access_class);
    if (!object)
        guest_allocation_error(a, heap);
    a->heap = heap;
    a->heap_image = image;
    a->guest_root = image.compiler_root;
    jbed_vm_put_word(heap->memory, a->guest_root, object);
    jbed_vm_put_word(heap->memory, object + 32, a->next_low_id);
    *jbed_vm_at(heap->memory, object + 24) = a->all_classes;
}

void jbed_class_bind_heap(JbedClassAccess *a, JbedVmHeap *heap, JbedAddress statics)
{
    JbedAddress base = a->bundles[0]->image.base;
    jbed_class_bind_heap_image(a, heap,
        (JbedClassHeapImage){base + ROM_CLASS_ACCESS, base + ROM_CLASS,
                             base + ROM_CLASS_ARRAY, statics + COMPILER_CLASS_ACCESS,
                             statics + REGISTERED_CLASSES});
    a->isolate_statics = statics;
}

static JbedAddress guest_access(JbedClassAccess *a)
{
    if (!a->guest_root)
        jbed_raise_internal(a->runtime, "ClassAccess is not bound to its heap image");
    return jbed_vm_word(a->heap->memory, a->guest_root);
}

void jbed_class_publish(JbedClassAccess *a)
{
    if (a->heap) {
        JbedBuffer mem = a->heap->memory;
        JbedAddress object = guest_access(a);
        a->guest_root = a->heap_image.registered_root;
        jbed_vm_put_word(mem, a->guest_root, object);
        *jbed_vm_at(mem, object + 24) = 1;
    }
    a->runtime->registered_classes = a;
    a->all_classes = true;
}

void jbed_class_release_compiler_root(JbedClassAccess *a)
{
    if (a && a->heap && a->heap_image.compiler_root)
        jbed_vm_put_word(a->heap->memory, a->heap_image.compiler_root, 0);
}

void jbed_class_access_init(JbedClassAccess *a, JbedRuntime *runtime,
                            const JbedVmClassTable *resident, JbedReflectionTable *packages,
                            JbedReflectionTable *bases, bool all_classes)
{
    *a = (JbedClassAccess){.runtime = runtime,
                           .packages = packages,
                           .base_names = bases,
                           .bundles = {resident, NULL},
                           .next_low_id = 1,
                           .dynamic_bundle = 1,
                           .all_classes = all_classes};
}

/* ClassAccess.initClassAccess (0x116c3c) loads bundle zero; the other
 * three ReflectionTable constructors are in initReflectionTables (0x12ae80). */
void jbed_android_rom_tables_init(JbedAndroidRomTables *t, JbedRuntime *rt, JbedImageView image,
                                  bool all_classes)
{
    if (image.base > UINT32_MAX - 0x2813e8u)
        jbed_raise_internal(rt, "Android ROM table addresses exceed the target address space");
    if (!jbed_reflection_init(&t->packages, rt, image, image.base + 0x26256c) ||
        !jbed_reflection_init(&t->base_names, rt, image, image.base + 0x262c8c) ||
        !jbed_reflection_init(&t->method_names, rt, image, image.base + 0x269814) ||
        !jbed_reflection_init(&t->field_names, rt, image, image.base + 0x2813e8) ||
        !jbed_reflection_init(&t->signatures, rt, image, image.base + 0x266850))
        jbed_raise_internal(rt, "Invalid Android ROM reflection tables");
    jbed_vm_class_table_init(&t->classes, rt, image, image.base + 0x25f548);
    jbed_class_access_init(&t->access, rt, &t->classes, &t->packages, &t->base_names, all_classes);
}

/* ClassAccess.loadDynamicBundle, 0x116e3c. Bundle one supplies its own name
 * chains. Subsequent dynamic identities use bundle two. */
void jbed_class_access_load_bundle(JbedClassAccess *a, const JbedVmClassTable *bundle,
                                   JbedImageView image, JbedAddress packages, JbedAddress bases)
{
    if (!bundle || a->bundles[1] || a->next_low_id != 1)
        jbed_halt(a->runtime, 0, "Cannot replace an active class bundle");
    if (!jbed_reflection_reference(a->packages, image, packages) ||
        !jbed_reflection_reference(a->base_names, image, bases))
        jbed_raise_internal(a->runtime, "Invalid bundle name table");
    a->bundles[1] = bundle;
    a->dynamic_bundle = 2;
}

static bool dynamic(const JbedClassAccess *a, JbedTypeId id)
{
    return (id >> 16) == a->dynamic_bundle;
}

static uint32_t grow(uint32_t n, uint32_t increment)
{
    return n < increment ? n * 2 : n + increment;
}

static void *grow_array(JbedRuntime *rt, const void *old, size_t old_size, size_t capacity,
                        size_t cell_size)
{
    void *new_array = jbed_alloc(rt, capacity * cell_size);
    if (old)
        memcpy(new_array, old, old_size * cell_size);
    return new_array;
}

/* ClassAccess.registerClass, 0x116f60. The ID is allocated even before the
 * class file has been defined; params and class objects have separate arrays. */
static uint16_t register_class(JbedClassAccess *a, JbedClassParams params)
{
    JbedAddress access = a->heap ? guest_access(a) : 0;
    uint32_t id = a->next_low_id++;
    if (a->heap)
        jbed_vm_put_word(a->heap->memory, access + 32, a->next_low_id);
    if (id > UINT16_MAX)
        jbed_halt(a->runtime, 0, "More than 64k dynamic classes.");
    if (a->next_low_id >= a->param_capacity) {
        uint32_t capacity = a->param_capacity ? grow(a->param_capacity, 1024) : 32;
        a->params =
            grow_array(a->runtime, a->params, a->param_capacity, capacity, sizeof *a->params);
        a->param_capacity = capacity;
    }
    a->params[id - 1] = params;
    return (uint16_t)id;
}

static unsigned class_hash(JbedClassParams p)
{
    return ((p.package_id >> 4) & 0xff0u) | (p.base_id >> 8);
}

/* getClassId(IIIZZ), 0x1172d0. The resident table may hide a class from a
 * suite. In that case its class name can acquire a separate dynamic identity. */
JbedTypeId jbed_class_id(JbedClassAccess *a, JbedClassParams p, bool create, bool include_hidden)
{
    if (!p.package_id && !p.dimensions && p.base_id >= 4 && p.base_id <= 11)
        return p.base_id;
    for (unsigned i = 0; i < 2; ++i) {
        if (!a->bundles[i])
            continue;
        JbedClass *klass = jbed_vm_lookup_class(a->bundles[i], p.package_id, p.base_id,
                                                p.dimensions, include_hidden && a->all_classes);
        if (klass)
            return klass->id;
    }

    if (!a->buckets) {
        if (!create)
            return 0;
        a->buckets = jbed_alloc(a->runtime, 256 * sizeof *a->buckets);
    }
    JbedClassBucket *bucket = &a->buckets[class_hash(p) & 255];
    JbedTypeId prefix = (uint32_t)a->dynamic_bundle << 16;
    unsigned i = 0;
    for (; i < bucket->capacity; ++i) {
        ClassEntry *e = &bucket->entries[i];
        if (!e->package_plus_one)
            break;
        if (e->package_plus_one == (unsigned)p.package_id + 1 && e->base == p.base_id &&
            e->dimensions == p.dimensions)
            return prefix | e->low_id;
    }
    if (!create)
        return 0;
    if (i == bucket->capacity) {
        uint32_t capacity = bucket->capacity ? grow(bucket->capacity, 100) : 4;
        bucket->entries = grow_array(a->runtime, bucket->entries, bucket->capacity, capacity,
                                     sizeof *bucket->entries);
        bucket->capacity = capacity;
    }
    ClassEntry *e = &bucket->entries[i];
    e->package_plus_one = (uint16_t)(p.package_id + 1);
    e->base = p.base_id;
    e->dimensions = (uint16_t)p.dimensions;
    e->low_id = register_class(a, p);
    return prefix | e->low_id;
}

/* Byte-slice overload, 0x11722a. Base name is interned before the package. */
JbedTypeId jbed_class_name_id(JbedClassAccess *a, const uint8_t *bytes, size_t start, size_t end,
                              size_t slash, int32_t dimensions)
{
    if (end < start || (slash && (slash < start || slash >= end)))
        jbed_raise_internal(a->runtime, "Invalid class name slice");
    size_t base_start = slash ? slash + 1 : start;
    uint16_t base = jbed_reflection_id(a->base_names, bytes + base_start, end - base_start, true);
    uint16_t package =
        slash ? jbed_reflection_id(a->packages, bytes + start, slash - start, true) : 0;
    return jbed_class_id(a, (JbedClassParams){package, base, dimensions}, true, true);
}

static JbedClass *lookup(const JbedClassAccess *a, JbedTypeId id)
{
    uint32_t low = (uint16_t)id;
    if (dynamic(a, id))
        return low && low <= a->object_capacity ? a->classes[low - 1] : NULL;
    uint32_t bundle = id >> 16;
    return bundle < 2 && a->bundles[bundle] ? jbed_vm_class_by_id(a->bundles[bundle], id) : NULL;
}

/* ClassAccess.createClassObject keeps a movable Class[] in its first
 * reference field. Individual Class objects are pinned before construction. */
static JbedAddress guest_identity(JbedClassAccess *a, JbedClass *klass)
{
    if (!a || !klass)
        return 0;
    if (!klass->dynamic_class_access) {
        for (unsigned i = 0; i < 2; ++i) {
            JbedAddress address = jbed_vm_class_address(a->bundles[i], klass);
            if (address)
                return address;
        }
        return 0;
    }
    a = klass->dynamic_class_access;
    if (!a->heap || klass->guest_address)
        return klass->guest_address;

    JbedVmHeap *heap = a->heap;
    JbedBuffer mem = heap->memory;
    JbedAddress access = guest_access(a);
    JbedAddress array = jbed_vm_word(mem, access + 12);
    uint32_t length = array ? jbed_vm_word(mem, array + 12) : 0;
    if (length < a->object_capacity) {
        JbedAddress grown =
            jbed_vm_new_array(heap, (int32_t)a->object_capacity, a->heap_image.class_array_class);
        if (!grown)
            guest_allocation_error(a, heap);
        access = jbed_vm_word(mem, a->guest_root);
        array = jbed_vm_word(mem, access + 12);
        if (length)
            memcpy(jbed_vm_at(mem, grown + 16), jbed_vm_at(mem, array + 16), 4 * (size_t)length);
        jbed_vm_put_word(mem, access + 12, grown);
    }
    if (!jbed_vm_next_allocate_locked(heap))
        guest_allocation_error(a, heap);
    JbedAddress object = jbed_vm_new_object(heap, a->heap_image.class_class);
    if (!object)
        guest_allocation_error(a, heap);
    access = jbed_vm_word(mem, a->guest_root);
    array = jbed_vm_word(mem, access + 12);
    jbed_vm_put_word(mem, array + 16 + 4 * ((uint16_t)klass->id - 1), object);
    klass->guest_address = object;
    jbed_vm_put_word(mem, object + 16, klass->id);
    jbed_vm_put_word(mem, object + 56, access);
    jbed_vm_put_word(mem, object + 60, klass->base_id | (uint32_t)klass->package_id << 16);
    jbed_vm_put_word(mem, object + 64, klass->array_dimensions);
    return object;
}

JbedAddress jbed_class_target_address(JbedClassAccess *a, JbedClass *klass)
{
    JbedAddress object = guest_identity(a, klass);
    if (!object || !klass->dynamic_class_access)
        return object;
    a = klass->dynamic_class_access;
    JbedBuffer mem = a->heap->memory;
    jbed_vm_put_word(mem, object + 12, klass->flags);
    jbed_vm_put_word(mem, object + 20, guest_identity(a, klass->superclass));
    if (klass->interface_count) {
        JbedAddress interfaces = jbed_vm_word(mem, object + 24);
        if (!interfaces || jbed_vm_word(mem, interfaces + 12) != klass->interface_count) {
            interfaces = jbed_vm_new_array(a->heap, (int32_t)klass->interface_count,
                                           a->heap_image.class_array_class);
            if (!interfaces)
                guest_allocation_error(a, a->heap);
            jbed_vm_put_word(mem, object + 24, interfaces);
        }
        for (size_t i = 0; i < klass->interface_count; ++i) {
            JbedAddress iface = guest_identity(a, klass->interfaces[i]);
            interfaces = jbed_vm_word(mem, object + 24);
            jbed_vm_put_word(mem, interfaces + 16 + 4 * (uint32_t)i, iface);
        }
    } else {
        jbed_vm_put_word(mem, object + 24, 0);
    }
    jbed_vm_put_word(mem, object + 28, (uint32_t)klass->instance_size);
    jbed_vm_put_word(mem, object + 32,
                     (uint16_t)klass->depth | (uint32_t)(uint16_t)klass->vtable_size << 16);
    jbed_vm_put_word(mem, object + 36, klass->descriptor_address);
    jbed_vm_put_word(mem, object + 40, klass->default_constructor_address);
    jbed_vm_put_word(mem, object + 44, klass->initializer_address);
    jbed_vm_put_word(mem, object + 48, klass->init_flags);
    jbed_vm_put_word(mem, object + 52,
                     (uint16_t)klass->method_count | (uint32_t)(uint16_t)klass->field_count << 16);
    jbed_vm_put_word(mem, object + 68, klass->label);
    return object;
}

JbedClass *jbed_class_from_target(JbedClassAccess *a, JbedAddress address)
{
    if (!a || !a->heap || !address)
        return NULL;
    JbedBuffer mem = a->heap->memory;
    JbedTypeId id = jbed_vm_word(mem, address + 16);
    JbedClass *klass = lookup(a, id);
    if (!klass)
        return NULL;
    JbedAddress identity =
        klass->dynamic_class_access ? klass->guest_address : guest_identity(a, klass);
    return identity == address ? klass : NULL;
}

JbedError jbed_class_error(const JbedClass *klass)
{
    JbedError error = klass->error;
    JbedClassAccess *access = klass->dynamic_class_access;
    if (error.runtime_throwable && access && access->heap && klass->guest_address) {
        enum { CLASS_ANCHOR = 76 };
        JbedBuffer memory = access->heap->memory;
        JbedAddress throwable = jbed_vm_word(memory, klass->guest_address + CLASS_ANCHOR);
        error.runtime_throwable = throwable ? jbed_vm_at(memory, throwable) : NULL;
    }
    return error;
}

/* getClassParams, 0x1179f0; getArrayOfClass, 0x117550. */
JbedClassParams jbed_class_params(const JbedClassAccess *a, JbedTypeId id)
{
    uint32_t low = (uint16_t)id;
    if (dynamic(a, id)) {
        if (low && low < a->next_low_id)
            return a->params[low - 1];
    } else {
        JbedClass *klass = lookup(a, id);
        if (klass)
            return (JbedClassParams){klass->package_id, klass->base_id, klass->array_dimensions};
    }
    return (JbedClassParams){0};
}

/* getPackageName 0x117070 and createNameString 0x117e50: package names
 * preserve '/', while Class.getName returns '.' even inside array names. */
const char *jbed_class_package_name(JbedClassAccess *a, JbedTypeId id)
{
    uint16_t package = jbed_class_params(a, id).package_id;
    if (!package)
        return "";
    int32_t size = jbed_reflection_data(a->packages, package, NULL, 0);
    if (size < 0)
        return NULL;
    char *name = jbed_alloc(a->runtime, (size_t)size + 1);
    jbed_reflection_data(a->packages, package, (uint8_t *)name, (size_t)size);
    return name;
}

const char *jbed_class_name(JbedClassAccess *a, JbedTypeId id)
{
    uint32_t bundle = id >> 16, low = (uint16_t)id;
    if (!low || bundle >= 3)
        return NULL;
    if (low <= a->name_capacity[bundle] && a->names[bundle][low - 1])
        return a->names[bundle][low - 1];
    JbedClassParams p = jbed_class_params(a, id);
    if (!p.base_id)
        return NULL;
    bool primitive = p.base_id >= 4 && p.base_id <= 11;
    int32_t base_size = primitive ? 1 : jbed_reflection_data(a->base_names, p.base_id, NULL, 0);
    int32_t pkg_size = p.package_id ? jbed_reflection_data(a->packages, p.package_id, NULL, 0) : 0;
    if (base_size < 0 || pkg_size < 0)
        return NULL;
    size_t dimensions = p.dimensions > 0 ? (size_t)p.dimensions : 0;
    size_t size = dimensions + (size_t)base_size + (size_t)pkg_size + (p.package_id != 0) +
                  2 * (!primitive && dimensions != 0) + 1;
    char *name = jbed_alloc(a->runtime, size);
    memset(name, '[', dimensions);
    char *dest = name + dimensions;
    if (primitive) {
        *dest++ = "ZCFDBSIJ"[p.base_id - 4];
    } else {
        if (dimensions)
            *dest++ = 'L';
        if (p.package_id) {
            jbed_reflection_data(a->packages, p.package_id, (uint8_t *)dest, (size_t)pkg_size);
            for (int32_t i = 0; i < pkg_size; ++i)
                if (dest[i] == '/')
                    dest[i] = '.';
            dest += pkg_size;
            *dest++ = '.';
        }
        jbed_reflection_data(a->base_names, p.base_id, (uint8_t *)dest, (size_t)base_size);
        dest += base_size;
        if (dimensions)
            *dest++ = ';';
    }
    *dest = 0;
    if (low > a->name_capacity[bundle]) {
        uint32_t capacity = a->name_capacity[bundle] ? a->name_capacity[bundle] : 32;
        while (low > capacity)
            capacity = grow(capacity, 1024);
        a->names[bundle] = grow_array(a->runtime, a->names[bundle], a->name_capacity[bundle],
                                      capacity, sizeof *a->names[bundle]);
        a->name_capacity[bundle] = capacity;
    }
    return a->names[bundle][low - 1] = name;
}

JbedTypeId jbed_class_array_of(JbedClassAccess *a, JbedTypeId component)
{
    JbedClassParams p = jbed_class_params(a, component);
    p.dimensions = (int32_t)((uint32_t)p.dimensions + 1);
    return jbed_class_id(a, p, true, true);
}

JbedTypeId jbed_class_primitive_array(JbedClassAccess *a, JbedTypeId primitive, int32_t dimensions)
{
    if (primitive < 4 || primitive > 11)
        jbed_halt(a->runtime, 0, "Invalid primitive array type");
    return jbed_class_id(a, (JbedClassParams){0, (uint16_t)primitive, dimensions}, true, true);
}

/* createClassObject 0x117734 and java.lang.Class.<init> 0xb54a0. */
static JbedClass *create_object(JbedClassAccess *a, JbedTypeId id, JbedClassParams p,
                                JbedClass *component)
{
    if (!dynamic(a, id) || lookup(a, id))
        jbed_halt(a->runtime, 0, "Invalid dynamic class creation");
    uint32_t low = (uint16_t)id;
    uint32_t capacity = a->object_capacity;
    if (capacity) {
        while (low > capacity)
            capacity = grow(capacity, 1024);
    } else {
        capacity = 32;
    }
    if (a->object_capacity != capacity) {
        a->classes =
            grow_array(a->runtime, a->classes, a->object_capacity, capacity, sizeof *a->classes);
        a->object_capacity = capacity;
    }
    JbedClass *klass = jbed_alloc(a->runtime, sizeof *klass);
    klass->id = id;
    klass->dynamic_class_access = a;
    klass->package_id = p.package_id;
    klass->base_id = p.base_id;
    klass->array_dimensions = (uint16_t)p.dimensions;
    if (component) {
        /* All Class objects are instances of java.lang.Class, whose superclass
         * supplies the vtable size. The value is independent of the component. */
        JbedTypeId class_id = a->heap_image.class_class
            ? jbed_vm_word(a->heap->memory, a->heap_image.class_class + 16)
            : JBED_ROM_CLASS_CLASS;
        JbedClass *class_class = lookup(a, class_id);
        if (!class_class || !class_class->superclass)
            jbed_raise_internal(a->runtime, "Missing java.lang.Class superclass");
        klass->flags = JBED_CLASS_ARRAY | JBED_CLASS_DYNAMIC | JBED_CLASS_INSTANTIABLE |
                       JBED_CLASS_TRANSLATED | JBED_ACC_ABSTRACT | JBED_ACC_FINAL |
                       (component->flags & JBED_ACC_PUBLIC);
        klass->vtable_size = class_class->superclass->vtable_size;
        klass->superclass = component;
        klass->instance_size = 16;
        klass->depth = 1;
    } else {
        klass->flags = JBED_CLASS_DYNAMIC;
    }
    if (!low || low > capacity) {
        const JbedError error = {.kind = JBED_ERROR_ARRAY_INDEX};
        jbed_raise(a->runtime, &error);
    }
    if (a->heap)
        jbed_class_target_address(a, klass);
    a->classes[low - 1] = klass;
    return klass;
}

/* getClassObject/createArrayClass, 0x117588/0x117664. Descending first
 * preserves the ID order, even when no component object exists yet. */
JbedClass *jbed_class_object(JbedClassAccess *a, JbedTypeId id)
{
    JbedClass *klass = lookup(a, id);
    if (klass || !dynamic(a, id))
        return klass;
    JbedClassParams p = jbed_class_params(a, id);
    if (p.dimensions <= 0)
        return NULL;
    int32_t dimensions = p.dimensions, level = dimensions;
    do {
        p.dimensions = --level;
        JbedTypeId component = jbed_class_id(a, p, true, true);
        klass = lookup(a, component);
    } while (!klass && level > 0);
    if (!klass)
        return NULL;
    while (++level < dimensions) {
        p.dimensions = level;
        JbedTypeId array = jbed_class_id(a, p, true, true);
        klass = create_object(a, array, p, klass);
    }
    p.dimensions = dimensions;
    return create_object(a, id, p, klass);
}

/* getOrCreateClassObject, 0x1175f0. Only the definition path creates
 * a non-array class that has so far been named by unresolved references. */
JbedClass *jbed_class_get_or_create(JbedClassAccess *a, JbedTypeId id)
{
    if (!dynamic(a, id))
        jbed_halt(a->runtime, 0, "Expected dynamic class ID");
    JbedClass *klass = jbed_class_object(a, id);
    if (klass)
        return klass;
    JbedClassParams p = jbed_class_params(a, id);
    if (p.dimensions)
        jbed_halt(a->runtime, 0, "Missing array component");
    return create_object(a, id, p, NULL);
}

JbedClass *jbed_class_next(const JbedClassAccess *a, const JbedClass *previous)
{
    for (uint32_t i = previous ? (uint16_t)previous->id : 0; i < a->object_capacity; ++i)
        if (a->classes[i])
            return a->classes[i];
    return NULL;
}

JbedTypeId jbed_class_next_unresolved(const JbedClassAccess *a, JbedTypeId previous)
{
    if (previous && !dynamic(a, previous))
        jbed_halt(a->runtime, 0, "Expected dynamic class ID");
    for (uint32_t i = (uint16_t)previous; i < a->object_capacity && i + 1 < a->next_low_id; ++i)
        if (!a->classes[i] && !a->params[i].dimensions)
            return ((uint32_t)a->dynamic_bundle << 16) | (i + 1);
    return 0;
}

static void set_class_id(JbedClass *klass, uint32_t high)
{
    klass->id = (high << 16) | (uint16_t)klass->id;
    if (klass->guest_address)
        jbed_vm_put_word(klass->dynamic_class_access->heap->memory, klass->guest_address + 16,
                         klass->id);
}

/* genClassRefTable, 0x11807c. The header's count excludes registered IDs
 * without class objects; the low-ID limit includes them. */
JbedAddress jbed_class_generate(JbedClassAccess *a, JbedWriter *w, JbedRomObjects *rom)
{
    uint32_t count = 0;
    for (JbedClass *c = NULL; (c = jbed_class_next(a, c)) != NULL;)
        ++count;
    if (count > 0x8000)
        jbed_writer_fault(w, JBED_WRITER_OUT_OF_CODE, "Too many classes in bundle");
    unsigned bits = 5;
    while ((1u << bits) < count)
        ++bits;
    unsigned bucket_shift = 18 - bits;
    uint32_t buckets = 1u << (bits - 2), mask = buckets - 1, chain_limit = 1u << (17 - bits);
    uint32_t *positions = jbed_alloc(a->runtime, buckets * sizeof *positions);
    for (JbedClass *c = NULL; (c = jbed_class_next(a, c)) != NULL;) {
        unsigned b =
            class_hash((JbedClassParams){c->package_id, c->base_id, c->array_dimensions}) & mask;
        while (positions[b] == chain_limit)
            b = (b + 1) & mask;
        set_class_id(c, (b << bucket_shift) | ++positions[b]);
    }
    JbedAddress addr = jbed_writer_allocate(w, NULL, 8 * buckets + 8 + 12 * count);
    jbed_writer_put_byte(w, addr, (uint8_t)((17 - bits) << 4 | (bits - 2)));
    jbed_writer_put_byte(w, addr + 1, 0);
    jbed_writer_put_halfword(w, addr + 4, (uint16_t)count);
    jbed_writer_put_halfword(w, addr + 6, (uint16_t)(a->next_low_id - 1));
    JbedAddress records = addr + 8 + 4 * buckets;
    for (unsigned b = 0; b < buckets; ++b) {
        JbedAddress word = addr + 8 + 4 * b;
        uint32_t size = positions[b];
        if (size) {
            jbed_writer_put_reloc(w, word, records, false);
            jbed_writer_put_word(w, records, size);
            positions[b] = records + 4;
            records += 4 + 12 * size;
        } else {
            jbed_writer_put_word(w, word, 0);
        }
    }
    for (JbedClass *c = NULL; (c = jbed_class_next(a, c)) != NULL;) {
        uint32_t *next = &positions[(c->id >> (16 + bucket_shift)) & mask];
        jbed_writer_put_halfword(w, *next, c->package_id);
        jbed_writer_put_halfword(w, *next + 2, c->base_id);
        jbed_writer_put_halfword(w, *next + 4, c->array_dimensions);
        set_class_id(c, a->dynamic_bundle);
        jbed_rom_write_class(rom, *next + 8, c);
        *next += 12;
    }
    return addr;
}
