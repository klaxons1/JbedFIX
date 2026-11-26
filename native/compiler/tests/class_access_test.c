#include "class_access.h"
#include "rom_objects.h"
#include "vm_words.h"

#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdlib.h>
#include <string.h>

static uint32_t write_label(JbedWriter *w, JbedAddress site, uint32_t label)
{
    assert(label < w->label_capacity && w->labels[label]);
    jbed_writer_put_word(w, site, w->labels[label]);
    return 0;
}

static void write_bytes(JbedWriter *w, JbedAddress site, const uint8_t *data, uint32_t count)
{
    for (uint32_t i = 0; i < count; ++i)
        jbed_writer_put_byte(w, site + i, data[i]);
}

static JbedAddress allocate_ref_table(JbedWriter *w, JbedCodeOwner *owner, uint32_t size)
{
    JbedClassAccess *a = w->services->context;
    uint32_t count[8] = {0};
    for (JbedClass *klass = NULL; (klass = jbed_class_next(a, klass));) {
        uint32_t bucket = (((klass->package_id >> 4) & 0xff0) | (klass->base_id >> 8)) & 7;
        JbedTypeId expected = (((bucket << 13) | ++count[bucket]) << 16) | (uint16_t)klass->id;
        assert(klass->id == expected);
        assert(jbed_vm_word(a->heap->memory, klass->guest_address + 16) == expected);
    }
    JbedWriter direct;
    jbed_writer_init(&direct, w->services);
    return direct.ops->allocate(w, owner, size);
}

void test_class_access(JbedAndroidRomTables *tables)
{
    JbedVmClassTable *base = &tables->classes;
    JbedRuntime *rt = base->runtime;
    JbedClassAccess *a = &tables->access;
    JbedBuffer memory = {.size = 0x420000, .data = calloc(1, 0x420000)};
    assert(memory.data && base->image.size <= memory.size);
    memcpy(memory.data, base->image.bytes, base->image.size);
    JbedVmHeap heap;
    jbed_vm_heap_init(&heap, memory, 0);
    assert(jbed_vm_heap_add_chunk(&heap, 0x410000, 0x10000, true));
    JbedClassHeapImage heap_image = {.class_access_class = 0x208b58,
        .class_class = 0x216898, .class_array_class = 0x25e270,
        .compiler_root = 0x400000, .registered_root = 0x400004};
    jbed_class_bind_heap_image(a, &heap, heap_image);
    assert(a->guest_root == heap_image.compiler_root);
    const uint8_t name[] = "test/Rider";
    assert(jbed_class_name_id(a, (const uint8_t *)"java/lang/Object", 0, 16, 9, 0) == 462);
    assert(jbed_class_primitive_array(a, 10, 1) == 463);
    JbedTypeId cube_id = jbed_class_name_id(a, name, 0, 10, 4, 3);
    assert(!strcmp(jbed_class_name(a, cube_id), "[[[Ltest.Rider;"));
    assert(!strcmp(jbed_class_name(a, 463), "[I"));
    assert(cube_id == 0x10001 && !jbed_class_object(a, cube_id));
    JbedTypeId rider_id = jbed_class_name_id(a, name, 0, 10, 4, 0);
    assert(rider_id == 0x10004);
    JbedClass *rider = jbed_class_get_or_create(a, rider_id);
    JbedClass *object = jbed_vm_class_by_id(base, 462);
    JbedField serial = {.owner = rider,
                        .name_id = 4163,
                        .type_id = 11,
                        .flags = 0x1000019,
                        .constant_value = UINT64_C(0x0123456789abcdef)};
    rider->fields = &serial;
    rider->field_count = 1;
    rider->superclass = object;
    rider->flags |= JBED_ACC_PUBLIC;
    JbedClass *cube = jbed_class_object(a, cube_id);
    assert(cube && cube->superclass->superclass->superclass == rider);
    assert(cube->flags == 0x2c80411 && cube->vtable_size == object->vtable_size);
    JbedAddress guest = jbed_class_target_address(a, cube);
    assert(jbed_class_from_target(a, guest) == cube);
    assert(jbed_vm_word(memory, guest + 4) & 0xf0);
    assert(jbed_vm_word(memory, guest + 16) == cube_id);
    assert(jbed_vm_word(memory, guest + 20) == cube->superclass->guest_address);
    assert(jbed_vm_word(memory, guest + 56) == jbed_vm_word(memory, a->guest_root));
    assert(jbed_vm_word(memory, guest + 64) == 3);
    JbedAddress access = jbed_vm_word(memory, a->guest_root);
    jbed_class_publish(a);
    jbed_class_release_compiler_root(a);
    assert(a->guest_root == heap_image.registered_root);
    assert(jbed_vm_word(memory, heap_image.registered_root) == access);
    assert(jbed_vm_word(memory, heap_image.compiler_root) == 0);
    assert(jbed_class_array_of(a, cube->superclass->id) == cube_id);
    assert(jbed_class_next(a, NULL) == cube && !jbed_class_next(a, rider));
    assert(jbed_class_name_id(a, (const uint8_t *)"test/Missing", 0, 12, 4, 0) == 0x10005);
    assert(jbed_class_next_unresolved(a, 0) == 0x10005);
    assert(!jbed_class_next_unresolved(a, 0x10005));

    uint8_t bytes[8192] = {0};
    JbedBuffer buffer = {.data = bytes, .size = sizeof bytes, .address = 0x12000000};
    JbedWriter writer;
    jbed_writer_init(&writer, NULL);
    JbedWriterOps direct = *writer.ops;
    direct.write_label = write_label;
    direct.write_block = write_bytes;
    writer.ops = &direct;
    writer.buffer = &buffer;
    writer.cursor = buffer.address;
    writer.limit = writer.cursor + buffer.size;
    JbedRomServices services = {.context = base, .runtime = rt, .class_access = a};
    JbedRomObjects rom;
    jbed_rom_init(&rom, &services, &writer, true);
    jbed_rom_register_class(&rom, cube);
    assert(rom.object_count == 4);
    assert(jbed_rom_pointer_kind(&rom, guest) == JBED_POINTER_COMPILED_CLASS);
    assert(jbed_rom_pointer_kind(&rom, jbed_class_target_address(a, object)) ==
           JBED_POINTER_RESIDENT_CLASS);
    for (unsigned i = 0; i < rom.object_count; ++i)
        jbed_writer_set_label(&writer, rom.object_labels[i],
                              jbed_rom_class(&rom, rom.objects[i].klass));
    JbedWriterServices services_during_index = {.context = a};
    writer.services = &services_during_index;
    JbedWriterOps index_ops = direct;
    index_ops.allocate = allocate_ref_table;
    writer.ops = &index_ops;
    JbedAddress index = jbed_class_generate(a, &writer, &rom);
    writer.ops = &direct;
    writer.services = NULL;
    assert(cube->id == cube_id && jbed_vm_word(memory, guest + 16) == cube_id);
    JbedAddress package_table = jbed_reflection_generate(&tables->packages, &writer);
    JbedAddress base_names = jbed_reflection_generate(&tables->base_names, &writer);
    uint32_t assigned_hash = (uint32_t)jbed_vm_identity_hash(&heap, guest);
    assert(jbed_writer_get_word(&writer, writer.labels[cube->label] + 4) ==
           (assigned_hash << 8 | 7u));

    JbedVmClassTable compiled;
    JbedImageView output = {buffer.data, buffer.size, buffer.address};
    jbed_vm_class_table_load(&compiled, rt, output, index, base);
    jbed_reflection_clear_dynamic(&tables->packages);
    jbed_reflection_clear_dynamic(&tables->base_names);
    jbed_class_access_init(a, rt, base, &tables->packages, &tables->base_names, true);
    jbed_class_access_load_bundle(a, &compiled, output, package_table, base_names);
    assert(compiled.id_limit == 5 && !jbed_class_object(a, 0x10005));
    JbedClass *loaded = jbed_class_object(a, cube_id);
    assert(loaded && loaded != cube && loaded->id == cube_id);
    JbedClass *loaded_rider = loaded->superclass->superclass->superclass;
    assert(loaded_rider->superclass == object);
    assert(loaded_rider->field_count == 1 &&
           loaded_rider->fields->constant_value == serial.constant_value);
    assert(jbed_class_name_id(a, name, 0, 10, 4, 3) == cube_id);
    assert(jbed_class_array_of(a, cube_id) == 0x20001);
    JbedTypeId wide = jbed_class_primitive_array(a, 10, 65536);
    assert(jbed_class_params(a, wide).dimensions == 65536);
    assert(jbed_class_primitive_array(a, 10, 65536) != wide);
    jbed_writer_dispose(&writer);
    free(memory.data);
}
