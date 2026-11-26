#include "metadata_init.h"
#include "rom_reflection.h"
#include "../compiler/vm/vm_words.h"

#include <stdio.h>
#include <string.h>

JbedAddress jbed_vm_static_field_slot(JbedVm *vm, const char *owner, const char *name)
{
    JbedAddress address = jbed_vm_find_class(vm, owner);
    if (!address) return 0;
    JbedClass *klass = jbed_class_object(&vm->classes,
        jbed_vm_word(vm->heap.memory, address + 16));
    JbedNameId id = jbed_reflection_id(&vm->field_names, (const uint8_t *)name,
                                       strlen(name), false);
    if (!id) return 0;
    for (JbedField *field = klass ? klass->fields : NULL; field; field = field->next)
        if (field->name_id == id && (field->flags & JBED_ACC_STATIC) &&
            !(field->flags & JBED_FIELD_CONSTANT))
            return field->offset + ((field->flags & JBED_FIELD_RELATIVE_STATIC)
                                    ? vm->isolate_statics : 0);
    return 0;
}

static bool fail(char *error, size_t size, const char *message)
{
    if (error && size) snprintf(error, size, "%s", message);
    return false;
}

typedef struct ClassBinding {
    JbedVm *vm;
    JbedClassHeapImage image;
    JbedAddress reflection_class;
    JbedAddress reflection_slots[7];
} ClassBinding;

static void bind_classes(void *context)
{
    ClassBinding *binding = context;
    JbedClassAccess *classes = &binding->vm->classes;
    jbed_class_bind_heap_image(classes, &binding->vm->heap, binding->image);
    jbed_class_publish(classes);
    jbed_class_release_compiler_root(classes);
    JbedVm *vm = binding->vm;
    const JbedReflectionTable *tables[] = {&vm->packages, &vm->base_names,
        &vm->method_names, &vm->field_names, &vm->signatures};
    for (size_t i = 0; i < sizeof(tables) / sizeof(*tables); ++i) {
        JbRef table = jbed_vm_allocate_object(vm, binding->reflection_class, false);
        ReflectionTable_init(table, tables[i]->bucket_words - 4);
        jbed_vm_put_word(vm->heap.memory, binding->reflection_slots[i], table);
        if (i == 2 || i == 3)
            jbed_vm_put_word(vm->heap.memory, binding->reflection_slots[i + 3], table);
    }
}

bool jbed_vm_metadata_bootstrap(JbedVm *vm, JbedAddress intern_table, JbedAddress character_root,
                                 char *error, size_t error_size)
{
    ClassBinding binding = {.vm = vm, .image = {
        .class_access_class = jbed_vm_find_class(vm, "com/jbed/reflect/ClassAccess"),
        .class_class = vm->class_class,
        .class_array_class = jbed_vm_find_class(vm, "[Ljava/lang/Class;"),
        .compiler_root = jbed_vm_static_field_slot(vm, "com/jbed/tbcc/Compiler", "classes"),
        .registered_root = jbed_vm_static_field_slot(vm, "java/lang/Class", "classes")
    }, .reflection_class = jbed_vm_find_class(vm, "com/jbed/reflect/ReflectionTable"),
    .reflection_slots = {
        jbed_vm_static_field_slot(vm, "com/jbed/reflect/ClassAccess", "packageNameTable"),
        jbed_vm_static_field_slot(vm, "com/jbed/reflect/ClassAccess", "baseNameTable"),
        jbed_vm_static_field_slot(vm, "com/jbed/reflect/Method", "reflTable"),
        jbed_vm_static_field_slot(vm, "com/jbed/reflect/Field", "reflTable"),
        jbed_vm_static_field_slot(vm, "com/jbed/reflect/SignatureEncoder", "reflTable"),
        jbed_vm_static_field_slot(vm, "com/jbed/tbcc/Pool", "methNameTable"),
        jbed_vm_static_field_slot(vm, "com/jbed/tbcc/Pool", "fieldNameTable")
    }};
    JbedVmStringImage strings = {
        .string_class = vm->string_class,
        .char_array_class = vm->primitive_array_classes[JBED_TYPE_CHAR],
        .string_array_class = jbed_vm_find_class(vm, "[Ljava/lang/String;"),
        .intern_table = intern_table,
        .static_table_slot = jbed_vm_static_field_slot(vm, "java/lang/String", "staticHashtable"),
        .dynamic_table_slot = jbed_vm_static_field_slot(vm, "java/lang/String", "hashtable")
    };
    if (!binding.image.class_access_class || !binding.image.class_class ||
        !binding.image.class_array_class || !binding.image.compiler_root ||
        !binding.image.registered_root || !strings.string_class || !strings.char_array_class ||
        !strings.string_array_class || !strings.static_table_slot || !strings.dynamic_table_slot ||
        !intern_table || !character_root)
        return fail(error, error_size, "Metadata bootstrap requires ClassAccess, String intern tables and compiler roots");
    if (!binding.reflection_class)
        return fail(error, error_size, "Metadata bootstrap requires ReflectionTable");
    for (size_t i = 0; i < sizeof(binding.reflection_slots) / sizeof(*binding.reflection_slots); ++i)
        if (!binding.reflection_slots[i])
            return fail(error, error_size, "Metadata bootstrap requires reflection table roots");
    memcpy(vm->reflection_roots, binding.reflection_slots, sizeof(vm->reflection_roots));
    JbedError caught;
    JbedVm *previous = jbed_vm_bind(vm);
    bool initialized = vm->services.protected_call && vm->services.protected_call(vm->services.context,
            bind_classes, &binding, &caught);
    jbed_vm_bind(previous);
    if (!initialized)
        return fail(error, error_size, "Cannot allocate the runtime ClassAccess");
    if (!jbed_vm_strings_init_image(&vm->strings, &vm->heap, strings, character_root))
        return fail(error, error_size, "Cannot allocate the dynamic String intern table");
    return true;
}
