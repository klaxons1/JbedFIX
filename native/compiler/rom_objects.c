#include "rom_objects.h"
#include "class_access.h"
#include "vm_stackmap.h"
#include "vm_monitor.h"
#include "method_ranges.h"
#include "vm_words.h"

#include <string.h>

static void require(JbedRomObjects *r, bool condition, const char *message)
{
    if (!condition)
        jbed_halt(r->services->runtime, 0, message);
}

static uint32_t sync_table_size(const JbedRomServices *services)
{
    return services->sync_table_size ? services->sync_table_size(services->context)
                                     : jbed_vm_monitor_rom_slots(services->monitors);
}

/* <init>, 0x13290c/0x132922. The no-writer form is used by loadObjects. */
void jbed_rom_init(JbedRomObjects *r, const JbedRomServices *services, JbedWriter *writer,
                   bool debug_info)
{
    *r = (JbedRomObjects){.services = services, .writer = writer, .debug_info = debug_info};
    if (writer) {
        r->object_capacity = 256;
        r->objects = jbed_alloc(services->runtime, 256 * sizeof *r->objects);
        r->object_labels = jbed_alloc(services->runtime, 256 * sizeof *r->object_labels);
    }
}

/* ensureSpace, 0x132970. Both parallel arrays double at the same boundary. */
static void ensure_space(JbedRomObjects *r)
{
    if (r->object_count != r->object_capacity)
        return;
    uint32_t capacity = r->object_count * 2;
    JbedRomObjectView *objects = jbed_alloc(r->services->runtime, capacity * sizeof *objects);
    uint32_t *labels = jbed_alloc(r->services->runtime, capacity * sizeof *labels);
    memcpy(objects, r->objects, r->object_count * sizeof *objects);
    memcpy(labels, r->object_labels, r->object_count * sizeof *labels);
    r->objects = objects;
    r->object_labels = labels;
    r->object_capacity = capacity;
}

static JbedRomObjectView class_view(JbedRomObjects *r, JbedClass *klass, bool hash)
{
    const JbedRomServices *s = r->services;
    if (s->class_object)
        return s->class_object(s->context, klass);
    JbedClassAccess *a = s->class_access;
    require(r, a && a->heap, "Missing managed Class object");
    JbedAddress object = jbed_class_target_address(a, klass);
    require(r, object != 0, "Missing managed Class address");
    return (JbedRomObjectView){.kind = JBED_ROM_CLASS,
                               .identity = object,
                               .klass = klass,
                               .header_class = jbed_vm_word(a->heap->memory, object),
                               .hash = hash ? (uint32_t)jbed_vm_identity_hash(a->heap, object) : 0};
}

static JbedRomObjectView string_view(JbedRomObjects *r, JbedAddress object)
{
    const JbedRomServices *s = r->services;
    JbedClassAccess *a = s->class_access;
    require(r, a && a->heap, "Missing managed String object");
    JbedBuffer mem = a->heap->memory;
    uint32_t count = jbed_vm_word(mem, object + 20);
    JbedAddress data = jbed_vm_word(mem, object + 12) + jbed_vm_word(mem, object + 16);
    uint16_t *characters =
        count ? jbed_alloc(a->runtime, (size_t)count * sizeof *characters) : NULL;
    uint32_t hash = 0;
    for (uint32_t i = 0; i < count; ++i) {
        characters[i] = jbed_vm_half(mem, data + 2 * i);
        hash = 31 * hash + characters[i];
    }
    return (JbedRomObjectView){.kind = JBED_ROM_STRING,
                               .identity = object,
                               .header_class = jbed_vm_word(mem, object),
                               .hash = hash,
                               .characters = characters,
                               .character_count = count};
}

JbedPointerKind jbed_rom_pointer_kind(JbedRomObjects *r, JbedAddress object)
{
    JbedClassAccess *a = r->services->class_access;
    require(r, a && a->heap && object, "Missing managed object for pointer relocation");
    JbedBuffer mem = a->heap->memory;
    JbedAddress tag = jbed_vm_word(mem, object);
    JbedAddress base = a->bundles[0]->image.base;
    if (jbed_vm_word(mem, tag) == base + 0x2179e8)
        return *jbed_vm_at(mem, object + 29) ? JBED_POINTER_RESIDENT_OBJECT
                                             : JBED_POINTER_MOVABLE_OBJECT;
    require(r, jbed_vm_word(mem, tag) == base + 0x216898, "Expected String or Class literal");
    return (jbed_vm_word(mem, object + 12) & 0x800000) ? JBED_POINTER_COMPILED_CLASS
                                                       : JBED_POINTER_RESIDENT_CLASS;
}

/* registerClass, 0x1329d8. Dependency classes precede their users. */
void jbed_rom_register_class(JbedRomObjects *r, JbedClass *klass)
{
    if (!klass || !(klass->flags & JBED_CLASS_DYNAMIC))
        return;
    if (klass->superclass)
        jbed_rom_register_class(r, klass->superclass);
    for (size_t i = 0; i < klass->interface_count; ++i)
        jbed_rom_register_class(r, klass->interfaces[i]);
    if (klass->label)
        return;
    ensure_space(r);
    klass->label = jbed_writer_get_label(r->writer);
    r->object_labels[r->object_count] = klass->label;
    r->objects[r->object_count++] = class_view(r, klass, false);
    ++r->class_count;
}

/* register, 0x132a7e. References to the same object share its label. */
uint32_t jbed_rom_register_object(JbedRomObjects *r, JbedAddress identity)
{
    JbedRomObjectView object = {.kind = JBED_ROM_OTHER, .identity = identity};
    if (r->services->object) {
        object = r->services->object(r->services->context, identity);
        object.identity = identity;
    } else if (identity) {
        JbedClassAccess *a = r->services->class_access;
        require(r, a && a->heap, "Missing managed object");
        JbedBuffer mem = a->heap->memory;
        JbedAddress klass = jbed_vm_word(mem, jbed_vm_word(mem, identity));
        JbedAddress base = a->bundles[0]->image.base;
        if (klass == base + 0x216898)
            object.kind = JBED_ROM_CLASS;
        else if (klass == base + 0x2179e8)
            object.kind = JBED_ROM_STRING;
    }
    require(r, object.kind != JBED_ROM_CLASS, "class object requires registerClass");
    ensure_space(r);
    r->objects[r->object_count] = object;
    uint32_t index = 0;
    while (r->objects[index].identity != identity)
        ++index;
    if (index == r->object_count) {
        ++r->object_count;
        r->object_labels[index] = jbed_writer_get_label(r->writer);
    }
    return r->object_labels[index];
}

/* registerStackMapAdr, 0x132b38. ArrayOps.ensureSpace (0x145924) begins at
 * 32 cells, then doubles until strictly larger than the requested count. */
void jbed_rom_register_stack_map(JbedRomObjects *r, JbedAddress address)
{
    if (r->stack_map_count == r->stack_map_capacity) {
        uint32_t capacity = r->stack_map_capacity ? r->stack_map_capacity : 32;
        while (capacity <= r->stack_map_count + 1)
            capacity *= 2;
        JbedAddress *maps = jbed_alloc(r->services->runtime, capacity * sizeof *maps);
        if (r->stack_map_count)
            memcpy(maps, r->stack_maps, r->stack_map_count * sizeof *maps);
        r->stack_maps = maps;
        r->stack_map_capacity = capacity;
    }
    r->stack_maps[r->stack_map_count++] = address;
}

/* registerRelativeStatics, 0x132b6e. The original retains the supplied array. */
void jbed_rom_register_relative_statics(JbedRomObjects *r, uint32_t size, const uint32_t *ranges,
                                        uint32_t count)
{
    r->relative_statics_size = size;
    r->pointer_ranges = ranges;
    r->pointer_range_count = count;
}

/* getPrimStatics/getPtrStatics/getInitFlags, 0x132b74/0x132bb8/0x132bfc. */
JbedAddress jbed_rom_primitive_statics(JbedRomObjects *r)
{
    if (!r->primitive_statics)
        r->primitive_statics = r->services->new_empty_locked_array(r->services->context, false);
    return r->primitive_statics;
}
JbedAddress jbed_rom_pointer_statics(JbedRomObjects *r)
{
    if (!r->pointer_statics)
        r->pointer_statics = r->services->new_empty_locked_array(r->services->context, true);
    return r->pointer_statics;
}
JbedAddress jbed_rom_init_flags(JbedRomObjects *r)
{
    if (!r->init_flags)
        r->init_flags = r->services->new_empty_locked_array(r->services->context, false);
    return r->init_flags;
}
/* 0x132ba0 / 0x132be4 / 0x132c28: Jbed array payload starts at byte 16. */
JbedAddress jbed_rom_primitive_statics_base(JbedRomObjects *r)
{
    return jbed_rom_primitive_statics(r) + 16;
}
JbedAddress jbed_rom_pointer_statics_base(JbedRomObjects *r)
{
    return jbed_rom_pointer_statics(r) + 16;
}
JbedAddress jbed_rom_init_flags_base(JbedRomObjects *r)
{
    return jbed_rom_init_flags(r) + 16;
}

static JbedAddress resident_address(const JbedRomServices *services, const JbedClass *klass)
{
    const JbedClassAccess *access = services->class_access;
    if (access) {
        for (unsigned i = 0; i < 2; ++i) {
            JbedAddress address = jbed_vm_class_address(access->bundles[i], klass);
            if (address)
                return address;
        }
    }
    return 0;
}

JbedAddress jbed_rom_class_address(const JbedRomServices *services, const JbedClass *klass)
{
    if (!klass)
        return 0;
    if (services->class_address)
        return services->class_address(services->context, klass);
    return services->class_access ? jbed_class_target_address(services->class_access, (JbedClass *)klass) : 0;
}

/* writeClassObj, 0x132cb0. Read-only classes are literal pointers in the stock
 * VM; this deliberately preserves the baseline format rather than the adapter's
 * later ASLR-safe static-relocation patch. */
void jbed_rom_write_class(JbedRomObjects *r, JbedAddress site, JbedClass *klass)
{
    if (!klass)
        jbed_writer_put_word(r->writer, site, 0);
    else if (r->services->resident_class ? r->services->resident_class(r->services->context, klass)
                                         : resident_address(r->services, klass) != 0) {
        JbedAddress target = jbed_rom_class_address(r->services, klass);
        require(r, target != 0, "Missing resident class address");
        jbed_writer_put_word(r->writer, site, target);
    } else {
        require(r, klass->label != 0, "unregistered mutable class object");
        jbed_writer_write_label(r->writer, site, klass->label);
    }
}

/* writeCodeAdr, 0x132d30. The abstract/no-class stubs are resident literals. */
void jbed_rom_write_code(JbedRomObjects *r, JbedAddress site, JbedAddress target)
{
    if (!target || target == r->services->throw_abstract || target == r->services->throw_no_class)
        jbed_writer_put_word(r->writer, site, target);
    else
        jbed_writer_put_reloc(r->writer, site, target, false);
}

/* genObjectHeader, 0x132da0. Lock-word low bit stays set; unique monitor slots
 * are reserved only for string/class objects, not the generated arrays. */
void jbed_rom_object_header(JbedRomObjects *r, JbedAddress address, const JbedRomObjectView *object,
                            bool hash, bool synchronizer)
{
    jbed_writer_put_word(r->writer, address, object->header_class);
    jbed_writer_put_word(r->writer, address + 4, (hash ? object->hash << 8 : 0) | 7);
    jbed_writer_put_word(r->writer, address + 8, synchronizer ? (r->sync_index++ << 1) | 1 : 1);
}

/* genStringData, 0x132c40. Characters are copied as ARM little-endian UTF-16. */
JbedAddress jbed_rom_string_data(JbedRomObjects *r, const JbedRomObjectView *string)
{
    JbedAddress address = jbed_writer_allocate_raw(r->writer, NULL, string->character_count * 2);
    const uint16_t endian = 1;
    if (*(const uint8_t *)&endian == 1) {
        jbed_writer_write_block(r->writer, address, (const uint8_t *)string->characters,
                                string->character_count * 2);
    } else {
        /* Preserve the original no-allocation copy boundary on big-endian
         * hosts. writeBlock, unlike scalar writes, also supports large blocks. */
        uint8_t bytes[256];
        for (uint32_t i = 0; i < string->character_count;) {
            uint32_t count = string->character_count - i;
            if (count > sizeof bytes / 2)
                count = sizeof bytes / 2;
            for (uint32_t j = 0; j < count; ++j) {
                uint16_t value = string->characters[i + j];
                bytes[2 * j] = (uint8_t)value;
                bytes[2 * j + 1] = (uint8_t)(value >> 8);
            }
            jbed_writer_write_block(r->writer, address + i * 2, bytes, count * 2);
            i += count;
        }
    }
    return address;
}

/* genString, 0x132e52. Hash bucket heads remain labels until relocation. */
JbedAddress jbed_rom_string(JbedRomObjects *r, const JbedRomObjectView *string, uint32_t label)
{
    JbedAddress address = jbed_writer_allocate(r->writer, NULL, 32);
    jbed_rom_object_header(r, address, string, true, true);
    jbed_writer_put_word(r->writer, address + 12, 0);
    jbed_writer_put_reloc(r->writer, address + 16, jbed_rom_string_data(r, string), false);
    jbed_writer_put_word(r->writer, address + 20, string->character_count);
    uint32_t bucket = string->hash & (r->string_table_count - 1);
    if (r->string_table[bucket])
        jbed_writer_write_label(r->writer, address + 24, r->string_table[bucket]);
    else
        jbed_writer_put_word(r->writer, address + 24, 0);
    r->string_table[bucket] = label;
    jbed_writer_put_byte(r->writer, address + 28, 1);
    return address;
}

/* genClassArray, 0x132f7e; genIntArray, 0x133002. */
JbedAddress jbed_rom_class_array(JbedRomObjects *r, JbedClass *const *classes, uint32_t count)
{
    JbedAddress address = jbed_writer_allocate(r->writer, NULL, count * 4 + 16);
    JbedRomObjectView view = {.header_class = r->services->class_array_header};
    jbed_rom_object_header(r, address, &view, false, false);
    jbed_writer_put_word(r->writer, address + 12, count);
    for (uint32_t i = 0; i < count; ++i)
        jbed_rom_write_class(r, address + 16 + i * 4, classes[i]);
    return address;
}
JbedAddress jbed_rom_int_array(JbedRomObjects *r, const uint32_t *values, uint32_t count)
{
    JbedAddress address = jbed_writer_allocate(r->writer, NULL, count * 4 + 16);
    JbedRomObjectView view = {.header_class = r->services->int_array_header};
    jbed_rom_object_header(r, address, &view, false, false);
    jbed_writer_put_word(r->writer, address + 12, count);
    for (uint32_t i = 0; i < count; ++i)
        jbed_writer_put_word(r->writer, address + 16 + i * 4, values[i]);
    return address;
}

/* genClass, 0x13308e. Debug records preserve the ROM's 16-byte method/field
 * format. Absent records advance through the allocation without writes. */
JbedAddress jbed_rom_class(JbedRomObjects *r, JbedClass *klass)
{
    JbedAddress interfaces =
        klass->interfaces
            ? jbed_rom_class_array(r, klass->interfaces, (uint32_t)klass->interface_count)
            : 0;
    uint32_t size = 56;
    if (r->debug_info) {
        size += 16 * (uint32_t)(klass->method_count + klass->field_count);
        r->method_code_range_count = 0;
        size_t count = 0;
        for (JbedMethod *m = klass->methods; m && count < klass->method_count; m = m->next, ++count) {
            if (r->services->append_code_ranges)
                r->services->append_code_ranges(r->services->context, m, &r->method_code_ranges,
                                                &r->method_code_range_count,
                                                &r->method_code_range_capacity);
            else
                jbed_method_pack_ranges(r->services->runtime, m, &r->method_code_ranges,
                                        &r->method_code_range_count, &r->method_code_range_capacity);
        }
        size += 4 * (uint32_t)r->method_code_range_count;
    }
    JbedAddress address = jbed_writer_allocate(r->writer, NULL, size);
    JbedRomObjectView object = class_view(r, klass, true);
    jbed_rom_object_header(r, address, &object, true, true);
    jbed_writer_put_word(r->writer, address + 12, klass->flags);
    jbed_writer_put_word(r->writer, address + 16, klass->id);
    jbed_rom_write_class(r, address + 20, klass->superclass);
    if (interfaces)
        jbed_writer_put_reloc(r->writer, address + 24, interfaces, false);
    else
        jbed_writer_put_word(r->writer, address + 24, 0);
    jbed_writer_put_word(r->writer, address + 28, (uint32_t)klass->instance_size);
    if (klass->instance_size >= 0) {
        jbed_writer_put_halfword(r->writer, address + 32, (uint16_t)klass->depth);
        jbed_writer_put_halfword(r->writer, address + 34, (uint16_t)klass->vtable_size);
        jbed_rom_write_code(r, address + 36, klass->descriptor_address);
        jbed_rom_write_code(r, address + 40, klass->default_constructor_address);
        jbed_rom_write_code(r, address + 44, klass->initializer_address);
    } else {
        jbed_writer_put_halfword(r->writer, address + 32, 0);
        jbed_writer_put_halfword(r->writer, address + 34, 0);
        jbed_writer_put_word(r->writer, address + 36, 0);
        jbed_writer_put_word(r->writer, address + 40, 0);
        jbed_writer_put_word(r->writer, address + 44, 0);
    }
    jbed_writer_put_word(r->writer, address + 48, klass->init_flags);
    if (!r->debug_info || klass->instance_size < 0) {
        jbed_writer_put_word(r->writer, address + 52, 0);
        return address;
    }
    jbed_writer_put_halfword(r->writer, address + 52, (uint16_t)klass->method_count);
    jbed_writer_put_halfword(r->writer, address + 54, (uint16_t)klass->field_count);
    JbedAddress record = address + 56;
    size_t remaining = klass->method_count;
    for (JbedMethod *m = klass->methods; m && remaining; m = m->next, --remaining) {
        jbed_writer_put_word(r->writer, record, m->flags);
        jbed_writer_put_halfword(r->writer, record + 4, m->name_id);
        jbed_writer_put_halfword(r->writer, record + 6, m->signature_id);
        jbed_rom_write_code(r, record + 8, m->code_address);
        jbed_writer_put_halfword(r->writer, record + 12, (uint16_t)m->dispatch_slot);
        jbed_writer_put_halfword(r->writer, record + 14, m->generated_size);
        record += 16;
    }
    record += 16 * (uint32_t)remaining;
    remaining = klass->field_count;
    for (JbedField *f = klass->fields; f && remaining; f = f->next, --remaining) {
        jbed_writer_put_word(r->writer, record, f->flags);
        jbed_writer_put_halfword(r->writer, record + 4, f->name_id);
        jbed_writer_put_halfword(r->writer, record + 6, (uint16_t)f->type_id);
        if (!(f->flags & JBED_FIELD_CONSTANT))
            jbed_writer_put_word(r->writer, record + 8, f->offset);
        else if (f->type_id >> 4)
            jbed_writer_put_word(r->writer, record + 8, 0);
        else if ((f->type_id & 3) == 3) {
            jbed_writer_put_word(r->writer, record + 8, (uint32_t)f->constant_value);
            jbed_writer_put_word(r->writer, record + 12, (uint32_t)(f->constant_value >> 32));
        } else
            jbed_writer_put_word(r->writer, record + 8, (uint32_t)f->constant_value);
        record += 16;
    }
    record += 16 * (uint32_t)remaining;
    for (size_t i = 0; i < r->method_code_range_count; ++i, record += 4) {
        if (r->method_code_ranges[i])
            jbed_writer_put_reloc(r->writer, record, r->method_code_ranges[i], false);
        else
            jbed_writer_put_word(r->writer, record, 0);
    }
    return address;
}

static JbedAddress generate_table(JbedRomObjects *r, JbedRomTable kind)
{
    if (kind == JBED_ROM_CLASS_REFS && r->services->class_access)
        return jbed_class_generate(r->services->class_access, r->writer, r);
    JbedReflectionTable *table = r->services->reflection_tables[kind];
    if (table && kind != JBED_ROM_CLASS_REFS)
        return jbed_reflection_generate(table, r->writer);
    return r->services->generate_table(r->services->context, kind, r->writer, r);
}

/* genObjects, 0x13358c. Reflection-table generation may register more objects;
 * therefore object_count is read afresh for each iteration. */
void jbed_rom_generate(JbedRomObjects *r)
{
    void *context = r->services->context;
    r->sync_index = sync_table_size(r->services);
    r->bundle_id = r->services->dynamic_bundle_id ? r->services->dynamic_bundle_id(context)
                                                  : r->services->class_access->dynamic_bundle;
    r->base_name_table = generate_table(r, JBED_ROM_BASE_NAMES);
    r->package_table = generate_table(r, JBED_ROM_PACKAGES);
    r->class_ref_table = generate_table(r, JBED_ROM_CLASS_REFS);
    if (r->debug_info) {
        r->field_name_table = generate_table(r, JBED_ROM_FIELDS);
        r->method_name_table = generate_table(r, JBED_ROM_METHODS);
        r->signature_table = generate_table(r, JBED_ROM_SIGNATURES);
    }
    r->string_table_count = r->services->string_table_size(context);
    r->string_table =
        jbed_alloc(r->services->runtime, r->string_table_count * sizeof *r->string_table);
    for (uint32_t i = 0; i < r->object_count; ++i) {
        /* Keep a value copy: nested generation can grow the registration array. */
        JbedRomObjectView object = r->objects[i];
        JbedAddress address;
        if (object.kind == JBED_ROM_STRING) {
            if (!r->services->object)
                object = string_view(r, object.identity);
            address = jbed_rom_string(r, &object, r->object_labels[i]);
        } else {
            require(r, object.kind == JBED_ROM_CLASS, "unsupported registered ROM object");
            address = jbed_rom_class(r, object.klass);
        }
        jbed_writer_set_label(r->writer, r->object_labels[i], address);
    }
    r->pointer_ranges_address = jbed_rom_int_array(r, r->pointer_ranges, r->pointer_range_count);
}

/* genXipData, 0x133714. The XIP record has a fingerprint and no reserved word;
 * storeObjects uses its distinct stream representation below. */
JbedAddress jbed_rom_generate_xip(JbedRomObjects *r)
{
    JbedWriter *w = r->writer;
    uint32_t words = r->string_table_count + 6 + r->stack_map_count + 1 + 7;
    JbedAddress base = jbed_writer_allocate(w, NULL, words * 4);
    jbed_writer_put_word(w, base, r->services->fingerprint);
    jbed_writer_put_word(w, base + 4, r->debug_info);
    jbed_writer_put_word(w, base + 8, r->sync_index);
    jbed_writer_put_word(w, base + 12, r->relative_statics_size);
    jbed_writer_put_reloc(w, base + 16, r->pointer_ranges_address, false);
    jbed_writer_put_word(w, base + 20, r->string_table_count);
    JbedAddress cursor = base + 24;
    for (uint32_t i = 0; i < r->string_table_count; ++i, cursor += 4) {
        if (r->string_table[i])
            jbed_writer_write_label(w, cursor, r->string_table[i]);
        else
            jbed_writer_put_word(w, cursor, 0);
    }
    jbed_writer_put_word(w, cursor, r->stack_map_count);
    cursor += 4;
    for (uint32_t i = 0; i < r->stack_map_count; ++i, cursor += 4)
        jbed_writer_put_reloc(w, cursor, r->stack_maps[i], false);
    jbed_writer_put_reloc(w, cursor, r->package_table, false);
    jbed_writer_put_reloc(w, cursor + 4, r->base_name_table, false);
    jbed_writer_put_reloc(w, cursor + 8, r->class_ref_table, false);
    if (r->debug_info) {
        jbed_writer_put_reloc(w, cursor + 12, r->field_name_table, false);
        jbed_writer_put_reloc(w, cursor + 16, r->method_name_table, false);
        jbed_writer_put_reloc(w, cursor + 20, r->signature_table, false);
    } else {
        jbed_writer_put_word(w, cursor + 12, 0);
        jbed_writer_put_word(w, cursor + 16, 0);
        jbed_writer_put_word(w, cursor + 20, 0);
    }
    jbed_writer_put_word(w, cursor + 24, r->bundle_id);
    return base;
}

static bool write_be32(JbedBlockIo *io, uint32_t value)
{
    uint8_t bytes[] = {(uint8_t)(value >> 24), (uint8_t)(value >> 16), (uint8_t)(value >> 8),
                       (uint8_t)value};
    return io->write(io->context, bytes, sizeof bytes);
}
static bool read_be32(JbedBlockIo *io, uint32_t *value)
{
    uint8_t bytes[4];
    if (!io->read(io->context, bytes, sizeof bytes))
        return false;
    *value =
        (uint32_t)bytes[0] << 24 | (uint32_t)bytes[1] << 16 | (uint32_t)bytes[2] << 8 | bytes[3];
    return true;
}

/* storeObjects, 0x133990. Labels are stored unrelocated; code pointers remain
 * virtual block addresses for the corresponding FileBlockStreamLoader. */
bool jbed_rom_store(const JbedRomObjects *r, JbedBlockIo *io)
{
    if (!write_be32(io, r->debug_info) || !write_be32(io, r->sync_index) ||
        !write_be32(io, r->relative_statics_size) || !write_be32(io, r->pointer_ranges_address) ||
        !write_be32(io, 0) || !write_be32(io, r->string_table_count))
        return false;
    for (uint32_t i = 0; i < r->string_table_count; ++i)
        if (!write_be32(io, r->string_table[i]))
            return false;
    if (!write_be32(io, r->stack_map_count))
        return false;
    for (uint32_t i = 0; i < r->stack_map_count; ++i)
        if (!write_be32(io, r->stack_maps[i]))
            return false;
    return write_be32(io, r->package_table) && write_be32(io, r->base_name_table) &&
           write_be32(io, r->class_ref_table) && write_be32(io, r->field_name_table) &&
           write_be32(io, r->method_name_table) && write_be32(io, r->signature_table) &&
           write_be32(io, r->bundle_id);
}

/* internLoadObjects, 0x133a9e. Debug table pointers relocate only when flag 1 is
 * set; a non-debug file retains the unused raw table words exactly. */
bool jbed_rom_read(JbedRomObjects *r, JbedBlockIo *io, const JbedRomRelocator *reloc)
{
    uint32_t flags, address, reserved;
    if (!read_be32(io, &flags))
        return false;
    r->debug_info = (flags & 1) != 0;
    if (!read_be32(io, &r->sync_index) || !read_be32(io, &r->relative_statics_size) ||
        !read_be32(io, &address))
        return false;
    r->pointer_ranges_address = reloc->address(reloc->context, address);
    if (!read_be32(io, &reserved) || !read_be32(io, &r->string_table_count))
        return false;
    r->string_table =
        jbed_alloc(r->services->runtime, r->string_table_count * sizeof *r->string_table);
    for (uint32_t i = 0; i < r->string_table_count; ++i) {
        if (!read_be32(io, &address))
            return false;
        r->string_table[i] = reloc->label(reloc->context, address);
    }
    if (!read_be32(io, &r->stack_map_count))
        return false;
    r->stack_map_capacity = r->stack_map_count;
    r->stack_maps = jbed_alloc(r->services->runtime, r->stack_map_count * sizeof *r->stack_maps);
    for (uint32_t i = 0; i < r->stack_map_count; ++i) {
        if (!read_be32(io, &address))
            return false;
        r->stack_maps[i] = reloc->address(reloc->context, address);
    }
    if (!read_be32(io, &address))
        return false;
    r->package_table = reloc->address(reloc->context, address);
    if (!read_be32(io, &address))
        return false;
    r->base_name_table = reloc->address(reloc->context, address);
    if (!read_be32(io, &address))
        return false;
    r->class_ref_table = reloc->address(reloc->context, address);
    if (!read_be32(io, &r->field_name_table) || !read_be32(io, &r->method_name_table) ||
        !read_be32(io, &r->signature_table))
        return false;
    if (r->debug_info) {
        r->field_name_table = reloc->address(reloc->context, r->field_name_table);
        r->method_name_table = reloc->address(reloc->context, r->method_name_table);
        r->signature_table = reloc->address(reloc->context, r->signature_table);
    }
    return read_be32(io, &r->bundle_id);
}

/* loadObjects, 0x133c80. */
JbedRomObjects *jbed_rom_load(const JbedRomServices *services, JbedBlockIo *io,
                              const JbedRomRelocator *relocator)
{
    JbedRomObjects *r = jbed_alloc(services->runtime, sizeof *r);
    jbed_rom_init(r, services, NULL, false);
    if (!jbed_rom_read(r, io, relocator)) {
        const JbedError error = {.kind = JBED_ERROR_IO, .message = "truncated ROM object metadata"};
        jbed_raise(services->runtime, &error);
    }
    return r;
}

/* prepareCommon, 0x133dec. VM-specific publication has a strict ordering:
 * synchronization/static storage, interned strings, maps, bundle, debug tables,
 * then the CodeAnchor's parameters. */
static void prepare_common(JbedRomObjects *r)
{
    void *ctx = r->services->context;
    int32_t delta = (int32_t)(r->sync_index - sync_table_size(r->services));
    if (r->services->extend_synchronizers)
        r->services->extend_synchronizers(ctx, delta);
    else {
        JbedErrorKind kind = jbed_vm_monitor_extend_table(r->services->monitors, delta);
        if (kind != JBED_ERROR_NONE) {
            JbedError error = {.kind = kind, .is_java_error = kind == JBED_ERROR_OUT_OF_MEMORY,
                               .message = "Cannot extend isolate monitor table"};
            jbed_raise(r->services->runtime, &error);
        }
    }
    r->services->extend_statics(ctx, r->relative_statics_size, r->pointer_ranges_address);
    r->services->install_string_table(ctx, r->string_table, r->string_table_count);
    JbedVmStackMaps *registry = r->services->stack_map_registry;
    uint32_t map_id = registry ? jbed_vm_stack_map_id(registry) : r->services->stack_map_id(ctx);
    for (uint32_t i = 0; i < r->stack_map_count; ++i) {
        if (registry)
            jbed_vm_stack_map_add(registry, r->stack_maps[i], map_id);
        else
            r->services->add_stack_map(ctx, r->stack_maps[i], map_id);
    }
    JbedClassAccess *access = r->services->load_class_access ? r->services->load_class_access
                                                             : r->services->class_access;
    if (r->services->load_bundle) {
        r->services->load_bundle(ctx, r->bundle_id, r->class_ref_table, r->package_table,
                                 r->base_name_table);
    } else {
        if (!access || r->bundle_id != 1)
            jbed_raise_internal(r->services->runtime, "Invalid dynamic class bundle");
        JbedVmClassTable *table = jbed_alloc(access->runtime, sizeof *table);
        JbedImageView image = r->services->loaded_image;
        jbed_vm_class_table_load(table, access->runtime, image, r->class_ref_table, access->bundles[0]);
        jbed_class_access_load_bundle(access, table, image, r->package_table, r->base_name_table);
    }
    if (r->debug_info) {
        const JbedRomTable kinds[] = {JBED_ROM_FIELDS, JBED_ROM_METHODS, JBED_ROM_SIGNATURES};
        const JbedAddress addresses[] = {r->field_name_table, r->method_name_table, r->signature_table};
        for (unsigned i = 0; i < 3; ++i) {
            JbedReflectionTable *table = r->services->reflection_tables[kinds[i]];
            if (table && r->services->loaded_image.bytes) {
                if (!jbed_reflection_reference(table, r->services->loaded_image, addresses[i]))
                    jbed_raise_internal(r->services->runtime, "Invalid loaded reflection table");
            } else {
                r->services->reference_table(ctx, kinds[i], addresses[i]);
            }
        }
        r->services->trace_debug_symbols(ctx, r->bundle_id);
    }
    r->services->set_anchor_parameters(ctx, map_id, r->objects, r->object_count);
}

/* prepareLoaded, 0x133cb0; prepareGenerated, 0x133cca. */
void jbed_rom_prepare_loaded(JbedRomObjects *r)
{
    prepare_common(r);
}
void jbed_rom_prepare_generated(JbedRomObjects *r, const JbedRomRelocator *reloc)
{
    for (uint32_t i = 0; i < r->string_table_count; ++i)
        r->string_table[i] = reloc->label(reloc->context, r->string_table[i]);
    for (uint32_t i = 0; i < r->stack_map_count; ++i)
        r->stack_maps[i] = reloc->address(reloc->context, r->stack_maps[i]);
    r->package_table = reloc->address(reloc->context, r->package_table);
    r->base_name_table = reloc->address(reloc->context, r->base_name_table);
    r->class_ref_table = reloc->address(reloc->context, r->class_ref_table);
    if (r->debug_info) {
        r->field_name_table = reloc->address(reloc->context, r->field_name_table);
        r->method_name_table = reloc->address(reloc->context, r->method_name_table);
        r->signature_table = reloc->address(reloc->context, r->signature_table);
    }
    r->pointer_ranges_address = reloc->address(reloc->context, r->pointer_ranges_address);
    prepare_common(r);
}
