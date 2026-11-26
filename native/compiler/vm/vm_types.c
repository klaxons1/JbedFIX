#include "vm_types.h"
#include "vm_words.h"
#include "vm_memory.h"

/* Class.isAssignableFrom, 0xb58dc. The superclass slot of an array contains
 * its component. A primitive's identity check precedes the primitive guard. */
bool jbed_vm_assignable(const JbedClass *destination, const JbedClass *source)
{
    if (destination == source)
        return true;
    if ((destination->flags | source->flags) & JBED_CLASS_PRIMITIVE)
        return false;
    if (!destination->superclass)
        return true;
    if (destination->flags & JBED_CLASS_ARRAY)
        return (source->flags & JBED_CLASS_ARRAY) &&
               jbed_vm_assignable(destination->superclass, source->superclass);
    if (source->depth > 1 && jbed_vm_assignable(destination, source->superclass))
        return true;
    if (destination->flags & JBED_ACC_INTERFACE) {
        for (size_t i = 0; i < source->interface_count; ++i)
            if (jbed_vm_assignable(destination, source->interfaces[i]))
                return true;
    }
    return false;
}

/* Class/Method/Field.visibleToDynamicCode, 0xb5aa8/0x12ec9a/0x12c1f2. */
bool jbed_vm_class_visible(const JbedClass *klass)
{
    while (klass->flags & JBED_CLASS_ARRAY)
        klass = klass->superclass;
    return (klass->flags & (JBED_CLASS_DYNAMIC | JBED_ACC_IN_PROFILE)) != 0;
}

bool jbed_vm_method_visible(const JbedPoolServices *services, const JbedMethod *method)
{
    if (services->method_visible)
        return services->method_visible(services->context, method);
    return (method->owner->flags & JBED_CLASS_DYNAMIC) || (method->flags & JBED_ACC_IN_PROFILE);
}

bool jbed_vm_field_visible(const JbedPoolServices *services, const JbedField *field)
{
    if (services->field_visible)
        return services->field_visible(services->context, field);
    return (field->owner->flags & JBED_CLASS_DYNAMIC) || (field->flags & JBED_ACC_IN_PROFILE);
}

/* Method.getMethod and Field.getField only scan direct declarations; Pool
 * supplies the separate search order for classes and superinterfaces. */
bool jbed_vm_find_method(const JbedPoolServices *s, JbedClass *klass, JbedNameId name,
                         JbedSignatureId signature, JbedMethod **out, JbedError *error)
{
    if (s->find_method)
        return s->find_method(s->context, klass, name, signature, out, error);
    JbedMethod *method = klass->methods;
    while (method && (method->name_id != name || method->signature_id != signature))
        method = method->next;
    *out = method;
    return true;
}

bool jbed_vm_find_field(const JbedPoolServices *s, JbedClass *klass, JbedNameId name,
                        JbedTypeId type, JbedField **out, JbedError *error)
{
    if (s->find_field)
        return s->find_field(s->context, klass, name, type, out, error);
    JbedField *field = klass->fields;
    if ((klass->flags & JBED_CLASS_DYNAMIC) && (!name || !type))
        field = NULL;
    while (field && (field->name_id != name || field->type_id != type))
        field = field->next;
    *out = field;
    return true;
}

JbedMethod *jbed_vm_method_by_number(JbedClass *klass, int32_t slot)
{
    for (; klass; klass = klass->superclass)
        for (JbedMethod *method = klass->methods; method; method = method->next)
            if (method->dispatch_slot == slot)
                return method;
    return NULL;
}

bool jbed_vm_pool_assignable(const JbedPoolServices *s, const JbedClass *to, const JbedClass *from,
                             bool *result, JbedError *error)
{
    if (s->assignable)
        return s->assignable(s->context, to, from, result, error);
    *result = jbed_vm_assignable(to, from);
    return true;
}

struct JbedVmClassSlot {
    uint32_t address;
    JbedClass klass;
};

static const uint8_t *bytes_at(const JbedVmClassTable *t, uint32_t address, size_t size)
{
    for (const JbedVmClassTable *map = t; map; map = map->parent) {
        uint32_t offset = address - map->image.base;
        if (address >= map->image.base && offset <= map->image.size &&
            size <= map->image.size - offset)
            return map->image.bytes + offset;
    }
    jbed_raise_internal(t->runtime, "Class table address outside bundle images");
}

static uint16_t halfword(const uint8_t *p) { return (uint16_t)(p[0] | p[1] << 8); }

static uint32_t word(const uint8_t *p) { return halfword(p) | ((uint32_t)halfword(p + 2) << 16); }

static uint32_t at(const JbedVmClassTable *t, uint32_t address)
{
    return word(bytes_at(t, address, 4));
}

static JbedVmClassSlot *slot_by_id(const JbedVmClassTable *t, JbedTypeId id)
{
    uint16_t index = (uint16_t)id;
    for (; t; t = t->parent) {
        if (index > 0 && index <= t->id_limit) {
            JbedVmClassSlot *slot = &t->slots[index];
            if (slot->address && slot->klass.id == id)
                return slot;
        }
    }
    return NULL;
}

JbedClass *jbed_vm_class_by_id(const JbedVmClassTable *t, JbedTypeId id)
{
    JbedVmClassSlot *slot = slot_by_id(t, id);
    return slot ? &slot->klass : NULL;
}

JbedAddress jbed_vm_class_address(const JbedVmClassTable *t, const JbedClass *klass)
{
    const JbedVmClassSlot *slot = klass ? slot_by_id(t, klass->id) : NULL;
    return slot && &slot->klass == klass ? slot->address : 0;
}

JbedClass *jbed_vm_class_at(const JbedVmClassTable *t, uint32_t address)
{
    if (!address)
        return NULL;
    JbedTypeId id = word(bytes_at(t, address, 20) + 16);
    JbedVmClassSlot *slot = slot_by_id(t, id);
    if (!slot || slot->address != address)
        jbed_raise_internal(t->runtime, "Class reference outside loaded bundles");
    return &slot->klass;
}

/* Method.<init> 0x12ec66 and Field.<init> 0x12c1a2. Wide constants are
 * stored low word first in the packed records (Field.to precedes Field.from).
 */
static void load_members(const JbedVmClassTable *t, uint32_t address, JbedClass *klass)
{
    size_t nm = klass->method_count, nf = klass->field_count;
    const uint8_t *p = bytes_at(t, address, 56 + 16 * (nm + nf)) + 56;
    if (nm)
        klass->methods = jbed_alloc(t->runtime, nm * sizeof *klass->methods);
    for (size_t i = 0; i < nm; ++i, p += 16) {
        JbedMethod *m = &klass->methods[i];
        m->owner = klass;
        m->flags = word(p);
        m->name_id = halfword(p + 4);
        m->signature_id = halfword(p + 6);
        m->code_address = word(p + 8);
        m->dispatch_slot = (int16_t)halfword(p + 12);
        m->generated_size = halfword(p + 14);
        m->profiling_info = (address + 56 + 16u * (uint32_t)i) | 1;
        if (i + 1 < nm)
            m->next = m + 1;
    }
    if (nf)
        klass->fields = jbed_alloc(t->runtime, nf * sizeof *klass->fields);
    for (size_t i = 0; i < nf; ++i, p += 16) {
        JbedField *f = &klass->fields[i];
        f->owner = klass;
        f->flags = word(p);
        f->name_id = halfword(p + 4);
        f->type_id = halfword(p + 6);
        if (!(f->flags & JBED_FIELD_CONSTANT))
            f->offset = word(p + 8);
        else if (f->type_id < 16 && f->type_id % 4 == 3)
            f->constant_value = (uint64_t)word(p + 12) << 32 | word(p + 8);
        else
            f->constant_value = word(p + 8);
        if (i + 1 < nf)
            f->next = f + 1;
    }
}

static void define_class(JbedVmClassTable *t, uint32_t address, uint16_t package, uint16_t base,
                         uint16_t dimensions)
{
    const uint8_t *p = bytes_at(t, address, 56);
    JbedTypeId id = word(p + 16);
    uint16_t index = (uint16_t)id;
    if (!index || index > t->id_limit)
        jbed_raise_internal(t->runtime, "Invalid resident class ID");
    JbedVmClassSlot *slot = &t->slots[index];
    if (slot->address)
        jbed_raise_internal(t->runtime, "Duplicate resident class ID");
    slot->address = address;
    slot->klass = (JbedClass){.id = id,
                              .package_id = package,
                              .base_id = base,
                              .array_dimensions = dimensions,
                              .flags = word(p + 12),
                              .instance_size = (int32_t)word(p + 28),
                              .depth = (int16_t)halfword(p + 32),
                              .vtable_size = (int16_t)halfword(p + 34),
                              .descriptor_address = word(p + 36),
                              .default_constructor_address = word(p + 40),
                              .initializer_address = word(p + 44),
                              .init_flags = word(p + 48),
                              .method_count = halfword(p + 52),
                              .field_count = halfword(p + 54)};
    load_members(t, address, &slot->klass);
}

/* ClassRefTable.<init> 0x13421e builds the sparse, low-ID reverse index.
 * Primitive Class objects have fixed identities 4..11 and no bucket entries.
 * Their one-dimensional array classes point directly to those objects. */
void jbed_vm_class_table_load(JbedVmClassTable *out, JbedRuntime *runtime, JbedImageView image,
                              uint32_t index, const JbedVmClassTable *parent)
{
    JbedVmClassTable t = {.runtime = runtime, .image = image, .index = index, .parent = parent};
    const uint8_t *header = bytes_at(&t, index, 8);
    t.bucket_mask = (uint16_t)((1u << (header[0] & 15)) - 1);
    t.overflow_limit = (uint16_t)((1u << (header[0] >> 4)) - 1);
    t.id_limit = halfword(header + 6);
    t.slots = jbed_alloc(runtime, ((size_t)t.id_limit + 1) * sizeof *t.slots);
    uint32_t remaining = halfword(header + 4);
    const uint8_t *buckets = bytes_at(&t, index, 8 + 4u * (t.bucket_mask + 1)) + 8;
    for (unsigned b = 0; b <= t.bucket_mask && remaining; ++b) {
        uint32_t bucket = word(buckets + 4 * b);
        if (!bucket)
            continue;
        uint32_t count = at(&t, bucket);
        if (count > remaining)
            jbed_raise_internal(runtime, "Invalid resident class bucket count");
        remaining -= count;
        const uint8_t *record = bytes_at(&t, bucket, 4 + 12 * count) + 4;
        for (unsigned j = 0; j < count; ++j, record += 12) {
            uint16_t package = halfword(record), base = halfword(record + 2);
            uint16_t dimensions = halfword(record + 4);
            uint32_t address = word(record + 8);
            define_class(&t, address, package, base, dimensions);
            if (!parent && package == 0 && base >= JBED_TYPE_BOOLEAN && base <= JBED_TYPE_LONG && dimensions == 1)
                define_class(&t, at(&t, address + 20), 0, base, 0);
        }
    }
    if (remaining)
        jbed_raise_internal(runtime, "Missing resident class bucket");
    for (unsigned i = 1; i <= t.id_limit; ++i) {
        const JbedVmClassSlot *slot = &t.slots[i];
        if (!slot->address)
            continue;
        JbedClass *klass = &t.slots[i].klass;
        klass->superclass = jbed_vm_class_at(&t, at(&t, slot->address + 20));
        uint32_t interfaces = at(&t, slot->address + 24);
        if (interfaces) {
            klass->interface_count = word(bytes_at(&t, interfaces, 16) + 12);
            if (klass->interface_count > (SIZE_MAX - 16) / 4 ||
                klass->interface_count > SIZE_MAX / sizeof *klass->interfaces)
                jbed_raise_internal(runtime, "Invalid resident interface count");
            const uint8_t *entries = bytes_at(&t, interfaces, 16 + 4 * klass->interface_count) + 16;
            klass->interfaces =
                jbed_alloc(runtime, klass->interface_count * sizeof *klass->interfaces);
            for (size_t j = 0; j < klass->interface_count; ++j)
                klass->interfaces[j] = jbed_vm_class_at(&t, word(entries + 4 * j));
        }
    }
    *out = t;
}

void jbed_vm_class_table_init(JbedVmClassTable *out, JbedRuntime *runtime, JbedImageView image,
                              uint32_t index)
{
    jbed_vm_class_table_load(out, runtime, image, index, NULL);
}

/* ClassAccess.getClassId 0x1172d0 / ClassRefTable.lookupClass 0x134314.
 * Saturated buckets continue into the following bucket, wrapping at the mask.
 */
JbedClass *jbed_vm_lookup_class(const JbedVmClassTable *t, uint16_t package, uint16_t base,
                                int32_t dimensions, bool include_hidden)
{
    if (!package && base >= JBED_TYPE_BOOLEAN && base <= JBED_TYPE_LONG && !dimensions)
        return jbed_vm_class_by_id(t, base);
    unsigned hash = ((package >> 4) & 0xff0) | (base >> 8);
    unsigned start = hash & t->bucket_mask, b = start;
    do {
        uint32_t bucket = at(t, t->index + 8 + 4 * b);
        if (!bucket)
            break;
        unsigned count = at(t, bucket);
        const uint8_t *record = bytes_at(t, bucket, 4 + 12u * count) + 4;
        for (unsigned i = 0; i < count; ++i, record += 12) {
            if (halfword(record) == package && halfword(record + 2) == base &&
                halfword(record + 4) == dimensions) {
                JbedClass *klass = jbed_vm_class_at(t, word(record + 8));
                return include_hidden || jbed_vm_class_visible(klass) ? klass : NULL;
            }
        }
        if (count <= t->overflow_limit)
            break;
        b = (b + 1) & t->bucket_mask;
    } while (b != start);
    return NULL;
}

static uint32_t interface_table(const JbedVmClassTable *t, uint32_t tag, const JbedClass *iface)
{
    while ((tag = at(t, tag + 4)) != 0)
        if (jbed_vm_class_at(t, at(t, tag)) == iface)
            return tag;
    return 0;
}

/* Base.InstanceOf, 0xe2d5c. The four
 * shallow superclasses precede the tag and its size word. Arrays have a
 * negative size word and use the component relation in Class.isAssignableFrom.
 */
bool jbed_vm_instance_of(const JbedVmClassTable *t, uint32_t tag, const JbedClass *target)
{
    if (!tag)
        return false;
    if (tag == target->descriptor_address)
        return true;
    if (target->depth > JBED_TAG_SUPERCLASS_SLOTS)
        return jbed_vm_assignable(target, jbed_vm_class_at(t, at(t, tag)));
    if (target == jbed_vm_class_by_id(t, JBED_ROM_CLASS_OBJECT))
        return true;
    uint32_t ancestor = at(t, tag - 4u - 4u * target->depth);
    if (ancestor && ancestor == jbed_vm_class_address(t, target))
        return true;
    if (target->flags & JBED_ACC_INTERFACE)
        return interface_table(t, tag, target) != 0;
    return (int32_t)at(t, tag - 4) < 0 &&
           jbed_vm_assignable(target, jbed_vm_class_at(t, at(t, tag)));
}

/* ArchBase.interfaceStub 0xe08b4 returns the matching table in r3. The
 * generated JBedFCoderThumb.CallVirtual reads the entry at table + 8 + 4 *
 * slot. */
uint32_t jbed_vm_interface_method(const JbedVmClassTable *t, uint32_t tag, const JbedClass *iface,
                                  unsigned slot)
{
    uint32_t table = interface_table(t, tag, iface);
    if (!table) {
        const JbedError error = {.kind = JBED_ERROR_ERROR, .is_java_error = true, .detail_code = 5};
        jbed_raise(t->runtime, &error);
    }
    return at(t, table + 8 + 4 * slot);
}

/* Objects can live in the writable heap or in a resident bundle. */
static uint32_t object_tag(const JbedVmClassTable *t, JbedBuffer heap, JbedAddress object)
{
    if (object >= heap.address && object - heap.address < heap.size)
        return jbed_vm_word(heap, object);
    return at(t, object);
}

JbedAddress jbed_vm_checkcast(const JbedVmClassTable *t, JbedBuffer heap, JbedAddress object,
                              const JbedClass *target)
{
    if (object && !jbed_vm_instance_of(t, object_tag(t, heap, object), target))
        jbed_raise(t->runtime, &(JbedError){.kind = JBED_ERROR_CLASS_CAST});
    return object;
}

/* Base.arraystore 0xe2e08 checks the component before the index.
 * Base.arraystoreWithoutCastcheck 0xe2e70 enters at the null/bounds checks. */
void jbed_vm_store_array_ref(const JbedVmClassTable *t, JbedBuffer heap, JbedAddress array,
                             int32_t index, JbedAddress value, bool check_type)
{
    if (!array)
        jbed_raise(t->runtime, &(JbedError){.kind = JBED_ERROR_NULL_POINTER});
    if (check_type && value) {
        const JbedClass *klass = jbed_vm_class_at(t, at(t, jbed_vm_word(heap, array)));
        if (!jbed_vm_instance_of(t, object_tag(t, heap, value), klass->superclass))
            jbed_raise(t->runtime, &(JbedError){.kind = JBED_ERROR_ARRAY_STORE});
    }
    if ((uint32_t)index >= jbed_vm_word(heap, array + 12))
        jbed_raise(t->runtime, &(JbedError){.kind = JBED_ERROR_ARRAY_INDEX});
    jbed_vm_put_word(heap, array + 16 + 4u * (uint32_t)index, value);
}
