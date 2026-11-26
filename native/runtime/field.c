#include "field.h"
#include "compiler.h"
#include "execution.h"
#include "metadata_init.h"
#include "rom_reflection.h"
#include "../compiler/vm/vm_words.h"

#include <string.h>

enum {
    CLASS_FLAGS = 12, CLASS_SUPERCLASS = 20,
    CLASS_METHOD_COUNT = 52, CLASS_FIELD_COUNT = 54, CLASS_MEMBERS = 56,
    CLASS_FIELDS = 88, MEMBER_BYTES = 16,
    FIELD_OWNER = 12, FIELD_FLAGS = 16, FIELD_NAME = 20, FIELD_TYPE = 24,
    FIELD_OFFSET = 28, FIELD_FROM = 32, FIELD_TO = 36, FIELD_NEXT = 40
};

static JbedAddress first_record(JbedBuffer memory, JbedAddress owner)
{
    return owner + CLASS_MEMBERS +
        MEMBER_BYTES * jbed_vm_half(memory, owner + CLASS_METHOD_COUNT);
}

static void copy_field(JbedVm *vm, JbedAddress object, JbedAddress owner, const JbedField *field)
{
    JbedBuffer memory = vm->heap.memory;
    jbed_vm_put_word(memory, object + FIELD_OWNER, owner);
    jbed_vm_put_word(memory, object + FIELD_FLAGS, field->flags);
    jbed_vm_put_word(memory, object + FIELD_NAME, field->name_id);
    jbed_vm_put_word(memory, object + FIELD_TYPE, field->type_id);
    jbed_vm_put_word(memory, object + FIELD_OFFSET, field->offset);
    uint32_t from = (uint32_t)field->constant_value, to = 0;
    if (field->type_id < 16 && field->type_id % 4 == 3) {
        from = (uint32_t)(field->constant_value >> 32);
        to = (uint32_t)field->constant_value;
    }
    jbed_vm_put_word(memory, object + FIELD_FROM, from);
    jbed_vm_put_word(memory, object + FIELD_TO, to);
}

/* The C compiler owns dynamic member records; their Java identities stay in
 * Class.fields, just as the original Reader's linked Field objects did. */
static void materialize_fields(JbedVm *vm, JbedAddress owner)
{
    JbedClassAccess *access = jbed_vm_compiler_classes(vm);
    if (!access) access = &vm->classes;
    JbedClass *klass = jbed_class_from_target(access, owner);
    if (!klass || !klass->fields) return;
    JbedAddress field_class = jbed_vm_find_class(vm, "com/jbed/reflect/Field");
    JbedVmHeapRoot root = {owner, owner, vm->heap.temporary_roots};
    JbedVmHeapRoot tail = {0, 0, &root};
    vm->heap.temporary_roots = &tail;
    for (const JbedField *field = klass->fields; field; field = field->next) {
        JbedAddress object = jbed_vm_word(vm->heap.memory,
            tail.value ? tail.value + FIELD_NEXT : root.value + CLASS_FIELDS);
        if (!object)
            object = jbed_vm_allocate_object(vm, field_class, false);
        copy_field(vm, object, root.value, field);
        if (!tail.value)
            jbed_vm_put_word(vm->heap.memory, root.value + CLASS_FIELDS, object);
        else
            jbed_vm_put_word(vm->heap.memory, tail.value + FIELD_NEXT, object);
        tail.value = tail.relocated = object;
    }
    vm->heap.temporary_roots = root.previous;
}

JbRef Field_getField(JbRef owner, int32_t name, int32_t type)
{
    JbedVm *vm = jbed_vm_current();
    if (!owner) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    JbedBuffer memory = vm->heap.memory;
    if ((jbed_vm_word(memory, owner + 4) & 3) == 3) {
        JbedAddress record = first_record(memory, owner);
        uint32_t count = jbed_vm_half(memory, owner + CLASS_FIELD_COUNT);
        for (uint32_t i = 0; i < count; ++i, record += MEMBER_BYTES) {
            if ((uint32_t)name == jbed_vm_half(memory, record + 4) &&
                (uint32_t)type == jbed_vm_half(memory, record + 6)) {
                JbedAddress field_class = jbed_vm_find_class(vm, "com/jbed/reflect/Field");
                JbRef field = jbed_vm_allocate_object(vm, field_class, false);
                Field_init(field, owner, jbed_vm_at(memory, record));
                return field;
            }
        }
    } else if (name && type) {
        materialize_fields(vm, owner);
        for (JbRef field = jbed_vm_word(memory, owner + CLASS_FIELDS); field;
             field = jbed_vm_word(memory, field + FIELD_NEXT))
            if ((uint32_t)name == jbed_vm_half(memory, field + FIELD_NAME) &&
                (uint32_t)type == jbed_vm_word(memory, field + FIELD_TYPE))
                return field;
    }
    return 0;
}

int32_t Field_getFieldAddress(JbRef owner, int32_t name, int32_t type, int32_t is_static)
{
    JbedVm *vm = jbed_vm_current();
    if (!owner) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    JbedBuffer memory = vm->heap.memory;
    if (jbed_vm_word(memory, owner + CLASS_FLAGS) & JBED_CLASS_DYNAMIC)
        jbed_vm_fatal(vm, "Field address requires a resident class");
    JbedAddress record = first_record(memory, owner);
    uint32_t count = jbed_vm_half(memory, owner + CLASS_FIELD_COUNT);
    for (uint32_t i = 0; i < count; ++i, record += MEMBER_BYTES) {
        uint32_t flags = jbed_vm_word(memory, record);
        if ((uint32_t)name != jbed_vm_half(memory, record + 4) ||
            (uint32_t)type != jbed_vm_half(memory, record + 6) ||
            (uint32_t)is_static != (flags & JBED_ACC_STATIC))
            continue;
        if (flags & JBED_FIELD_CONSTANT) {
            JbedAddress value = record + 8;
            if ((int32_t)value < 0)
                jbed_vm_fatal(vm, "Constant field address cannot be encoded");
            return (int32_t)(0u - value);
        }
        if ((flags & (JBED_ACC_STATIC | JBED_FIELD_RELATIVE_STATIC)) == JBED_ACC_STATIC)
            jbed_vm_fatal(vm, "Absolute static field has no isolate-relative address");
        return (int32_t)jbed_vm_word(memory, record + 8);
    }
    return -1;
}

int32_t Field_getFieldTypeIdByOffset(JbRef owner, int32_t offset)
{
    JbedVm *vm = jbed_vm_current();
    JbedBuffer memory = vm->heap.memory;
    for (; owner; owner = jbed_vm_word(memory, owner + CLASS_SUPERCLASS)) {
        JbedAddress record = first_record(memory, owner);
        uint32_t count = jbed_vm_half(memory, owner + CLASS_FIELD_COUNT);
        for (uint32_t i = 0; i < count; ++i, record += MEMBER_BYTES)
            if ((uint32_t)offset == jbed_vm_word(memory, record + 8) &&
                !(jbed_vm_word(memory, record) & JBED_ACC_STATIC))
                return jbed_vm_half(memory, record + 6);
    }
    jbed_vm_fatal(vm, "No instance field has the requested offset");
}

static JbedAddress iterator_method(JbedVm *vm, const char *name, JbedTypeId result)
{
    JbedAddress address = jbed_vm_find_class(vm, "com/jbed/reflect/ClassAccess$ClassIterator");
    JbedClass *klass = jbed_class_from_target(&vm->classes, address);
    JbedNameId name_id = jbed_reflection_id(&vm->method_names,
        (const uint8_t *)name, strlen(name), false);
    JbedSignatureServices services = {.runtime = &vm->services,
        .reflection_table = &vm->signatures, .types = jbed_signature_rom_types(),
        .class_access = &vm->classes};
    JbedSignatureEncoder encoder;
    jbed_signature_init(&encoder, &services);
    JbedSignatureId signature = jbed_signature_build_types(&encoder, NULL, 0, result, false);
    for (JbedMethod *method = klass ? klass->methods : NULL; method; method = method->next)
        if (method->name_id == name_id && method->signature_id == signature && method->code_address)
            return method->code_address;
    jbed_vm_fatal(vm, "Field class iterator method is absent");
}

static JbedAddress call_iterator(JbedVm *vm, JbedAddress root, JbedAddress method)
{
    uint32_t argument = jbed_vm_word(vm->heap.memory, root);
    uint64_t result;
    if (!jbed_vm_invoke(vm, method, &argument, 1, &result))
        jbed_raise(&vm->services, &(JbedError){.kind = JBED_ERROR_THROWABLE,
            .runtime_throwable = jbed_vm_at(vm->heap.memory, vm->pending_exception)});
    return (JbedAddress)result;
}

int32_t Field_getFieldTypeIdByAddress(JbedAddress address)
{
    JbedVm *vm = jbed_vm_current();
    JbedBuffer memory = vm->heap.memory;
    JbedAddress root = jbed_vm_static_field_slot(vm, "com/jbed/reflect/Field", "classList");
    if (!root) jbed_vm_fatal(vm, "Field class iterator root is absent");
    JbedAddress reset = iterator_method(vm, "reset", 0);
    JbedAddress next = iterator_method(vm, "nextClass", JBED_ROM_CLASS_CLASS);
    call_iterator(vm, root, reset);
    for (JbedAddress owner = call_iterator(vm, root, next);;
         owner = call_iterator(vm, root, next)) {
        if (!owner) jbed_vm_fatal(vm, "No static field has the requested address");
        /* The original search does not advance past a writable Class. */
        while ((jbed_vm_word(memory, owner + 4) & 3) != 3) { }
        JbedAddress record = first_record(memory, owner);
        uint32_t count = jbed_vm_half(memory, owner + CLASS_FIELD_COUNT);
        for (uint32_t i = 0; i < count; ++i, record += MEMBER_BYTES) {
            uint32_t flags = jbed_vm_word(memory, record);
            if (!(flags & JBED_ACC_STATIC)) continue;
            bool match = flags & JBED_FIELD_CONSTANT
                ? record + 8 == address
                : (flags & JBED_FIELD_RELATIVE_STATIC) &&
                    jbed_vm_word(memory, record + 8) == address;
            if (match) return jbed_vm_half(memory, record + 6);
        }
    }
}
