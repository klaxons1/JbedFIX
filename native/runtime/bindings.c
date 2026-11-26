#include "runtime.h"
#include "../compiler/vm/vm_words.h"

#include <stdlib.h>
#include <string.h>

static _Thread_local JbedVm *current_vm;

JbRef *Jbed_ParamPtr;
void **Jbed_nativeCallStateAdr;
uint8_t *Jbed_relativeStaticsBase;
uint32_t Jbed_noAllocation;

JbedVm *jbed_vm_current(void) { return current_vm; }

JbedVm *jbed_vm_bind(JbedVm *vm)
{
    JbedVm *previous = current_vm;
    if (previous) {
        previous->native_roots_top = Jbed_nativeCallStateAdr;
        previous->parameters = Jbed_ParamPtr;
        previous->heap.no_allocation = (int32_t)Jbed_noAllocation;
    }
    current_vm = vm;
    Jbed_ParamPtr = vm ? vm->parameters : NULL;
    Jbed_nativeCallStateAdr = vm ? vm->native_roots_top : NULL;
    Jbed_relativeStaticsBase = vm && vm->isolate_statics
        ? jbed_vm_at(vm->heap.memory, vm->isolate_statics) : NULL;
    Jbed_noAllocation = vm ? (uint32_t)vm->heap.no_allocation : 0;
    return previous;
}

_Noreturn void jbed_vm_raise(JbedVm *vm, JbedErrorKind kind, const char *message)
{
    JbedError error = {.kind = kind, .message = message,
                       .is_java_error = kind == JBED_ERROR_OUT_OF_MEMORY || kind == JBED_ERROR_INTERNAL};
    jbed_raise(&vm->services, &error);
}

_Noreturn void jbed_vm_fatal(JbedVm *vm, const char *message)
{
    if (vm)
        jbed_halt(&vm->services, 0, message);
    abort();
}

static JbedVm *active(void)
{
    JbedVm *vm = current_vm;
    if (!vm)
        jbed_vm_fatal(NULL, "Native call outside a Jbed VM");
    return vm;
}

JbedAddress Object_getClass(JbedAddress object)
{
    JbedBuffer memory = active()->heap.memory;
    return jbed_vm_word(memory, jbed_vm_word(memory, object));
}

static void heap_error(JbedVm *vm)
{
    switch (vm->heap.fault) {
    case JBED_HEAP_OK:
    case JBED_HEAP_OUT_OF_MEMORY:
        jbed_vm_raise(vm, JBED_ERROR_OUT_OF_MEMORY, "Java heap exhausted");
    case JBED_HEAP_NEGATIVE_ARRAY:
        jbed_vm_raise(vm, JBED_ERROR_NEGATIVE_ARRAY_SIZE, "Negative array length");
    case JBED_HEAP_NULL_POINTER:
        jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, "Null object");
    default:
        jbed_vm_fatal(vm, "Invalid native allocation state");
    }
}

static JbedAddress allocate(JbedVm *vm, JbedAddress klass, int32_t length, bool array, bool kni)
{
    if (vm == current_vm)
        vm->heap.no_allocation = (int32_t)Jbed_noAllocation;
    JbedAddress result = array
        ? (kni ? jbed_vm_kni_new_array(&vm->heap, length, klass)
               : jbed_vm_new_array(&vm->heap, length, klass))
        : (kni ? jbed_vm_kni_new_object(&vm->heap, klass)
               : jbed_vm_new_object(&vm->heap, klass));
    if (!result && (!kni || (vm->heap.fault != JBED_HEAP_OK &&
                             vm->heap.fault != JBED_HEAP_OUT_OF_MEMORY)))
        heap_error(vm);
    return result;
}

JbedAddress jbed_vm_allocate_object(JbedVm *vm, JbedAddress klass, bool kni)
{
    return allocate(vm, klass, 0, false, kni);
}

JbedAddress jbed_vm_allocate_array(JbedVm *vm, JbedAddress klass, int32_t length, bool kni)
{
    return allocate(vm, klass, length, true, kni);
}

static JbedAddress class_address(JbedVm *vm, JbedClass *klass)
{
    if (!klass)
        return 0;
    if (klass->guest_address)
        return klass->guest_address;
    for (size_t i = 0; i < 2; ++i) {
        JbedAddress address = jbed_vm_class_address(vm->classes.bundles[i], klass);
        if (address) return address;
    }
    return 0;
}

static JbedClass *class_record(JbedVm *vm, JbedAddress address)
{
    JbedTypeId id = jbed_vm_word(vm->heap.memory, address + 16);
    JbedClass *klass = jbed_class_object(&vm->classes, id);
    if (!klass || class_address(vm, klass) != address)
        jbed_vm_fatal(vm, "Native class reference is not registered");
    return klass;
}

static JbedClass *object_class(JbedVm *vm, JbedAddress object)
{
    JbedAddress tag = jbed_vm_word(vm->heap.memory, object);
    return class_record(vm, jbed_vm_word(vm->heap.memory, tag));
}

JbedTypeId jbed_vm_lookup_type(JbedVm *vm, const char *name, size_t length,
                                bool include_hidden, bool create_arrays)
{
    JbedClassParams params = {0};
    while (length && *name == '[') {
        ++params.dimensions;
        ++name;
        --length;
    }
    if (!length) return 0;
    const char *primitives = "ZCFDBSIJ";
    const char *primitive = params.dimensions && length == 1 ? strchr(primitives, *name) : NULL;
    if (primitive && *name) {
        params.base_id = (uint16_t)(JBED_TYPE_BOOLEAN + (primitive - primitives));
    } else {
        if (params.dimensions) {
            if (*name != 'L' || length < 3) return 0;
            /* ClassAccess discards the final descriptor character without testing it. */
            ++name;
            length -= 2;
        }
        size_t slash = 0;
        for (size_t i = 0; i < length; ++i)
            if (name[i] == '/') slash = i;
        if (slash) {
            params.package_id = jbed_reflection_id(vm->classes.packages,
                (const uint8_t *)name, slash, false);
            if (!params.package_id) return 0;
        }
        size_t base = slash ? slash + 1 : 0;
        params.base_id = jbed_reflection_id(vm->classes.base_names,
            (const uint8_t *)name + base, length - base, false);
        if (!params.base_id) return 0;
    }
    JbedTypeId id = jbed_class_id(&vm->classes, params, false, include_hidden);
    if (!id && create_arrays && params.dimensions > 0) {
        JbedClassParams component = params;
        component.dimensions = 0;
        if (jbed_class_id(&vm->classes, component, false, include_hidden))
            id = jbed_class_id(&vm->classes, params, true, include_hidden);
    }
    return id;
}

static JbedTypeId descriptor_type(JbedVm *vm, const char *descriptor)
{
    size_t length = strlen(descriptor);
    const char *codes = "ZCFDBSIJ";
    const char *primitive = length == 1 ? strchr(codes, *descriptor) : NULL;
    if (primitive) return (JbedTypeId)(JBED_TYPE_BOOLEAN + (primitive - codes));
    if (length > 1 && *descriptor == 'L') {
        ++descriptor;
        length -= 2;
    }
    return jbed_vm_lookup_type(vm, descriptor, length, true, false);
}

JbedAddress jbed_vm_find_class(JbedVm *vm, const char *name)
{
    if (!name)
        jbed_vm_fatal(vm, "Null native class name");
    JbedClass *klass = jbed_class_object(&vm->classes, jbed_vm_lookup_type(vm, name, strlen(name), true, false));
    return class_address(vm, klass);
}

JbRef JbedKNI_LookupClass(const char *name)
{
    JbedVm *vm = active();
    JbedAddress address = jbed_vm_find_class(vm, name);
    JbedClass *klass = address ? class_record(vm, address) : NULL;
    return klass && klass->instance_size >= 0 && (klass->flags & JBED_CLASS_TRANSLATED)
        ? address : 0;
}

JbRef JbedKNI_VerifyObject(JbRef object, int kind)
{
    JbedVm *vm = active();
    if (!object) {
        if (kind != 'o' && kind != 'c' && kind != 's' && kind != 'a')
            jbed_vm_fatal(vm, "Null native object reference");
        return 0;
    }
    if (!vm->isolate_statics)
        jbed_vm_fatal(vm, "Native object access without an isolate");
    JbedClass *klass = object_class(vm, object);
    JbedAddress address = class_address(vm, klass);
    if ((kind == 's' || kind == 'S') && address != vm->string_class)
        jbed_vm_fatal(vm, "Native string reference has the wrong class");
    if ((kind == 'c' || kind == 'C') && address != vm->class_class)
        jbed_vm_fatal(vm, "Native class reference has the wrong class");
    if ((kind == 'a' || kind == 'A') && !(klass->flags & JBED_CLASS_ARRAY))
        jbed_vm_fatal(vm, "Native array reference has the wrong class");
    return object;
}

static void verify_reference(JbedVm *vm, JbedClass *target, JbRef value)
{
    JbedKNI_VerifyObject(value, 'o');
    if (!target || (value && !jbed_vm_assignable(target, object_class(vm, value))))
        jbed_vm_fatal(vm, "Native reference store has the wrong class");
}

void *JbedKNI_VerifyArray(JbRef array, int index, int kind, JbRef value)
{
    JbedVm *vm = active();
    JbedKNI_VerifyObject(array, 'A');
    JbedClass *component = object_class(vm, array)->superclass;
    int32_t length = (int32_t)jbed_vm_word(vm->heap.memory, array + 12);
    if (index < 0 || index >= length)
        jbed_vm_fatal(vm, "Native array index outside bounds");
    unsigned size;
    if (component->flags & JBED_CLASS_PRIMITIVE) {
        if (component->id != (JbedTypeId)kind)
            jbed_vm_fatal(vm, "Native array element has the wrong primitive type");
        size = (unsigned)component->instance_size;
    } else {
        if (kind != JBED_TYPE_REFERENCE)
            jbed_vm_fatal(vm, "Native object array accessed as a primitive array");
        verify_reference(vm, component, value);
        size = sizeof(JbRef);
    }
    return jbed_vm_at(vm->heap.memory, array + 16 + (uint32_t)index * size);
}

void JbedKNI_VerifyArraySetObj(JbRef array, int index, int kind, JbRef value)
{
    JbRef *slot = JbedKNI_VerifyArray(array, index, kind, value);
    *slot = value;
}

void JbedKNI_VerifyArrayCopy(JbRef array, unsigned offset, unsigned size, void *native, int to_java)
{
    JbedVm *vm = active();
    JbedKNI_VerifyObject(array, 'A');
    JbedClass *component = object_class(vm, array)->superclass;
    if (!(component->flags & JBED_CLASS_PRIMITIVE))
        jbed_vm_fatal(vm, "Native byte copy requires a primitive array");
    uint32_t bytes = jbed_vm_word(vm->heap.memory, array + 12) * (uint32_t)component->instance_size;
    if ((int32_t)offset < 0 || (int32_t)size < 0 || offset > bytes || size > bytes - offset)
        jbed_vm_fatal(vm, "Native array copy outside bounds");
    void *data = jbed_vm_at(vm->heap.memory, array + 16 + offset);
    if (to_java)
        memmove(data, native, size);
    else
        memmove(native, data, size);
}

static uint32_t field_address(JbedVm *vm, JbedField *field, size_t index)
{
    if (field->owner->flags & JBED_CLASS_DYNAMIC)
        jbed_vm_fatal(vm, "Native field lookup requires a prepared class");
    if (field->flags & JBED_FIELD_CONSTANT) {
        uint32_t address = class_address(vm, field->owner) + 56 +
            16 * (uint32_t)(field->owner->method_count + index) + 8;
        if ((int32_t)address < 0)
            jbed_vm_fatal(vm, "Native constant field address cannot be encoded");
        return 0u - address;
    }
    if ((field->flags & (JBED_FIELD_RELATIVE_STATIC | JBED_ACC_STATIC)) == JBED_ACC_STATIC)
        jbed_vm_fatal(vm, "Native access to VM-global static field");
    return field->offset;
}

uint32_t JbedKNI_GetFieldAddress(JbRef class_ref, const char *name, const char *descriptor, int flags)
{
    JbedVm *vm = active();
    JbedClass *klass = class_record(vm, class_ref);
    uint16_t name_id = jbed_reflection_id(&vm->field_names, (const uint8_t *)name, strlen(name), false);
    if (!name_id)
        return 0;
    JbedTypeId type = descriptor_type(vm, descriptor);
    if (flags != JBED_ACC_STATIC)
        while (klass && (klass->flags & JBED_CLASS_DYNAMIC))
            klass = klass->superclass;
    do {
        size_t index = 0;
        for (JbedField *field = klass ? klass->fields : NULL; field; field = field->next, ++index)
            if (field->name_id == name_id && field->type_id == type &&
                (field->flags & JBED_ACC_STATIC) == (uint32_t)flags)
                return field_address(vm, field, index);
        if (flags == JBED_ACC_STATIC)
            break;
        klass = klass ? klass->superclass : NULL;
    } while (klass);
    return 0;
}

static JbedTypeId field_type(JbedVm *vm, JbRef object, uint32_t field_id)
{
    if (object) {
        for (JbedClass *klass = object_class(vm, object); klass; klass = klass->superclass)
            for (JbedField *field = klass->fields; field; field = field->next)
                if (!(field->flags & JBED_ACC_STATIC) && field->offset == field_id)
                    return field->type_id;
    } else {
        for (uint32_t bundle = 0; bundle < 2; ++bundle) {
            const JbedVmClassTable *table = vm->classes.bundles[bundle];
            for (uint32_t id = 1; table && id <= table->id_limit; ++id) {
                JbedClass *klass = jbed_vm_class_by_id(table, (bundle << 16) | id);
                size_t index = 0;
                for (JbedField *field = klass ? klass->fields : NULL; field; field = field->next, ++index)
                    if ((field->flags & JBED_ACC_STATIC) &&
                        (field->flags & (JBED_FIELD_CONSTANT | JBED_FIELD_RELATIVE_STATIC)) &&
                        field_address(vm, field, index) == field_id)
                        return field->type_id;
            }
        }
    }
    jbed_vm_fatal(vm, "Native field does not belong to the object or isolate");
}

void *JbedKNI_VerifyField(JbRef object, uint32_t field, int kind, JbRef value)
{
    JbedVm *vm = active();
    if (!field || !vm->isolate_statics)
        jbed_vm_fatal(vm, "Invalid native field address");
    if (object)
        JbedKNI_VerifyObject(object, 'O');
    JbedTypeId type = field_type(vm, object, field);
    if (kind == JBED_TYPE_REFERENCE)
        verify_reference(vm, jbed_class_object(&vm->classes, type), value);
    else if (type != (JbedTypeId)kind)
        jbed_vm_fatal(vm, "Native field has the wrong primitive type");
    JbedAddress address = object ? object + field :
        (int32_t)field < 0 ? 0u - field : vm->isolate_statics + field;
    return jbed_vm_at(vm->heap.memory, address);
}

_Noreturn void JbedKNI_FatalError(const char *message)
{
    jbed_vm_fatal(active(), message);
}

int Jbed_currentIsolate(void) { return active()->isolate_id; }
