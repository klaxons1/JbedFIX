#include "reflection.h"
#include "class_init.h"
#include "execution.h"
#include "../compiler/vm/vm_words.h"

#include <stdlib.h>

enum {
    CLASS_FLAGS = 12, CLASS_ID = 16, CLASS_SIZE = 28,
    CLASS_TAG = 36, CLASS_DEFAULT_CONSTRUCTOR = 40,
    STRING_CHARACTERS = 12, STRING_OFFSET = 16, STRING_LENGTH = 20,
    STRING_CONSTRUCTOR_SIGNATURE = 0xf0d1
};

static JbedAddress throw_new(JbedVm *vm, const char *name)
{
    vm->pending_exception = jbed_vm_new_throwable(vm, name);
    return 0;
}

static JbedAddress class_not_found(JbedVm *vm, JbedAddress name)
{
    JbedAddress address = jbed_vm_find_class(vm, "java/lang/ClassNotFoundException");
    if (!address) jbed_vm_fatal(vm, "ClassNotFoundException is absent from the boot image");
    JbedClass *klass = jbed_class_object(&vm->classes,
        jbed_vm_word(vm->heap.memory, address + CLASS_ID));
    JbedMethod *constructor = klass ? klass->methods : NULL;
    while (constructor && (constructor->name_id != JBED_NAME_INIT ||
                           constructor->signature_id != STRING_CONSTRUCTOR_SIGNATURE))
        constructor = constructor->next;
    if (!constructor || !constructor->code_address)
        jbed_vm_fatal(vm, "ClassNotFoundException(String) is absent from the boot image");

    JbedVmHeapRoot message = {name, name, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &message;
    JbedAddress exception = jbed_vm_allocate_object(vm, address, false);
    JbedVmHeapRoot root = {exception, exception, &message};
    vm->heap.temporary_roots = &root;
    uint32_t arguments[] = {exception, message.value};
    uint64_t ignored;
    if (jbed_vm_invoke(vm, constructor->code_address, arguments, 2, &ignored))
        vm->pending_exception = root.value;
    vm->heap.temporary_roots = message.previous;
    return 0;
}

static char *class_name(JbedVm *vm, JbedAddress string, size_t *length)
{
    JbedBuffer memory = vm->heap.memory;
    uint32_t count = jbed_vm_word(memory, string + STRING_LENGTH);
    if (!count) return NULL;
    JbedAddress chars = jbed_vm_word(memory, string + STRING_CHARACTERS) +
                        jbed_vm_word(memory, string + STRING_OFFSET);
    for (uint32_t i = 0; i < count; ++i)
        if (jbed_vm_half(memory, chars + 2 * i) == '/') return NULL;
    char *name = malloc((size_t)count * 3 + 1);
    if (!name) {
        throw_new(vm, "java/lang/OutOfMemoryError");
        return NULL;
    }
    size_t used = 0;
    for (uint32_t i = 0; i < count; ++i) {
        unsigned ch = jbed_vm_half(memory, chars + 2 * i);
        if (ch == '.') ch = '/';
        if (ch && ch < 0x80) {
            name[used++] = (char)ch;
        } else if (ch < 0x800) {
            name[used++] = (char)(0xc0 | ch >> 6);
            name[used++] = (char)(0x80 | (ch & 63));
        } else {
            name[used++] = (char)(0xe0 | ch >> 12);
            name[used++] = (char)(0x80 | (ch >> 6 & 63));
            name[used++] = (char)(0x80 | (ch & 63));
        }
    }
    name[used] = 0;
    *length = used;
    return name;
}

JbedAddress jbed_vm_class_for_name(JbedVm *vm, JbedAddress name, JbedAddress caller, bool checked)
{
    if (!name) return throw_new(vm, "java/lang/NullPointerException");
    if (!checked) caller = vm->class_class;
    JbedVmHeapRoot root = {name, name, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    size_t length = 0;
    char *text = class_name(vm, name, &length);
    JbedAddress address = 0;
    if (text) {
        JbedTypeId id = jbed_vm_lookup_type(vm, text, length, caller == vm->class_class, true);
        free(text);
        JbedClass *klass = id ? jbed_class_object(&vm->classes, id) : NULL;
        if (klass) {
            address = jbed_class_target_address(&vm->classes, klass);
            if (klass->instance_size < 0)
                address = throw_new(vm, "java/lang/NoClassDefFoundError");
            else if (!(klass->flags & JBED_CLASS_TRANSLATED))
                address = 0;
            else if (!jbed_vm_initialize_class(vm, address))
                address = 0;
        }
    }
    if (!address && !vm->pending_exception) class_not_found(vm, root.value);
    vm->heap.temporary_roots = root.previous;
    return address;
}

JbedAddress jbed_vm_class_new_instance(JbedVm *vm, JbedAddress klass, JbedAddress caller, bool checked)
{
    if (!klass) return throw_new(vm, "java/lang/NullPointerException");
    if (!checked) caller = klass;
    JbedBuffer memory = vm->heap.memory;
    uint32_t flags = jbed_vm_word(memory, klass + CLASS_FLAGS);
    JbedAddress constructor = jbed_vm_word(memory, klass + CLASS_DEFAULT_CONSTRUCTOR);
    if ((flags & (JBED_ACC_ABSTRACT | JBED_ACC_INTERFACE | JBED_CLASS_PRIMITIVE | JBED_CLASS_ARRAY)) ||
        !constructor)
        return throw_new(vm, "java/lang/InstantiationException");
    if (!jbed_vm_word(memory, klass + CLASS_TAG))
        return throw_new(vm, "java/lang/IllegalAccessException");
    if (caller != klass && !(flags & JBED_CLASS_PUBLIC_DEFAULT_CTOR)) {
        if (flags & JBED_CLASS_PRIVATE_DEFAULT_CTOR)
            return throw_new(vm, "java/lang/IllegalAccessException");
        if (!caller) return throw_new(vm, "java/lang/NullPointerException");
        JbedClassParams target_package = jbed_class_params(&vm->classes,
            jbed_vm_word(memory, klass + CLASS_ID));
        JbedClassParams caller_package = jbed_class_params(&vm->classes,
            jbed_vm_word(memory, caller + CLASS_ID));
        if (target_package.package_id != caller_package.package_id)
            return throw_new(vm, "java/lang/IllegalAccessException");
    }
    if (!(flags & (JBED_CLASS_DYNAMIC | JBED_ACC_IN_PROFILE))) {
        if (!caller) return throw_new(vm, "java/lang/NullPointerException");
        if (jbed_vm_word(memory, caller + CLASS_FLAGS) & JBED_CLASS_DYNAMIC)
            return throw_new(vm, "java/lang/IllegalAccessException");
    }
    JbedAddress object = jbed_vm_allocate_object(vm, klass, false);
    JbedVmHeapRoot root = {object, object, vm->heap.temporary_roots};
    vm->heap.temporary_roots = &root;
    uint64_t ignored;
    bool success = jbed_vm_invoke(vm, constructor, &root.value, 1, &ignored);
    vm->heap.temporary_roots = root.previous;
    return success ? root.value : 0;
}

JbedAddress Class_checkedNewInstance(JbedAddress klass, JbedAddress caller)
{
    return jbed_vm_class_new_instance(jbed_vm_current(), klass, caller, true);
}
