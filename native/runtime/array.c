#include "runtime.h"
#include "rom_reflection.h"
#include "../compiler/vm/vm_words.h"

#include <string.h>

enum { CLASS_FLAGS = 12, CLASS_COMPONENT = 20, CLASS_INSTANCE_SIZE = 28,
       CLASS_ACCESS = 56, ARRAY_LENGTH = 12, ARRAY_DATA = 16 };

static JbedClass *class_model(JbedVm *vm, JbedAddress klass)
{
    JbedBuffer memory = vm->heap.memory;
    if ((jbed_vm_word(memory, klass + 4) & 3) == 3)
        return jbed_vm_class_at(&vm->resident, klass);
    JbedClassAccess *access = jbed_vm_class_access_for_object(vm,
        jbed_vm_word(memory, klass + CLASS_ACCESS));
    return jbed_class_from_target(access, klass);
}

static JbedAddress object_class(JbedBuffer memory, JbedAddress object)
{
    return jbed_vm_word(memory, jbed_vm_word(memory, object));
}

void System_arraycopy(JbedAddress source, int32_t source_index, JbedAddress destination,
                       int32_t destination_index, int32_t count)
{
    JbedVm *vm = jbed_vm_current();
    if (!source || !destination)
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    JbedBuffer memory = vm->heap.memory;
    JbedAddress source_class = object_class(memory, source);
    JbedAddress destination_class = object_class(memory, destination);
    uint32_t source_flags = jbed_vm_word(memory, source_class + CLASS_FLAGS);
    uint32_t destination_flags = jbed_vm_word(memory, destination_class + CLASS_FLAGS);
    if (!(source_flags & destination_flags & JBED_CLASS_ARRAY))
        jbed_vm_raise(vm, JBED_ERROR_ARRAY_STORE, NULL);
    JbedAddress source_component = jbed_vm_word(memory, source_class + CLASS_COMPONENT);
    JbedAddress destination_component = jbed_vm_word(memory, destination_class + CLASS_COMPONENT);
    uint32_t component_flags = jbed_vm_word(memory, source_component + CLASS_FLAGS);
    if (source_component != destination_component &&
        ((component_flags | jbed_vm_word(memory, destination_component + CLASS_FLAGS)) & JBED_CLASS_PRIMITIVE))
        jbed_vm_raise(vm, JBED_ERROR_ARRAY_STORE, NULL);
    if (source_index < 0 || destination_index < 0 || count < 0 ||
        source_index > (int32_t)jbed_vm_word(memory, source + ARRAY_LENGTH) - count ||
        destination_index > (int32_t)jbed_vm_word(memory, destination + ARRAY_LENGTH) - count)
        jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    if (!count) return;

    uint32_t width = component_flags & JBED_CLASS_PRIMITIVE
        ? jbed_vm_word(memory, source_component + CLASS_INSTANCE_SIZE) : sizeof(JbedAddress);
    JbedAddress from = source + ARRAY_DATA + (uint32_t)source_index * width;
    JbedAddress to = destination + ARRAY_DATA + (uint32_t)destination_index * width;
    if (source == destination || source_component == destination_component ||
        jbed_vm_assignable(class_model(vm, destination_component), class_model(vm, source_component))) {
        memmove(jbed_vm_at(memory, to), jbed_vm_at(memory, from), (uint32_t)count * width);
        return;
    }

    JbedClass *component = class_model(vm, destination_component);
    for (int32_t i = 0; i < count; ++i) {
        JbedAddress value = jbed_vm_word(memory, from + (uint32_t)i * sizeof(JbedAddress));
        if (value && !jbed_vm_assignable(component, class_model(vm, object_class(memory, value))))
            jbed_vm_raise(vm, JBED_ERROR_ARRAY_STORE, NULL);
        jbed_vm_put_word(memory, to + (uint32_t)i * sizeof(JbedAddress), value);
    }
}
