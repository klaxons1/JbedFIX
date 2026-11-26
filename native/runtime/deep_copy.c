#include "deep_copy.h"
#include "memory.h"
#include "../compiler/vm/vm_words.h"
#include <string.h>

static uint32_t get(JbedVm *vm, JbedAddress address) { return jbed_vm_word(vm->heap.memory, address); }
static void put(JbedVm *vm, JbedAddress address, uint32_t value) { jbed_vm_put_word(vm->heap.memory, address, value); }
static bool instance(JbedVm *vm, JbRef object, const char *name)
{
    JbedAddress address = jbed_vm_find_class(vm, name);
    return address && jbed_vm_instance_of(&vm->resident, get(vm, object), jbed_vm_class_at(&vm->resident, address));
}

/* Base.deepCopy, original 0xe2f78. This deliberately follows the original
 * tree-copy semantics (no alias/cycle memoization). ROM objects and Isolates
 * retain identity; only the original whitelist may cross isolate boundaries. */
JbRef Base_deepCopy(JbRef source, JbRef isolate)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "deepCopy outside a Jbed VM");
    if (!source || Memory_isStaticReadOnlyObject(source) || instance(vm, source, "com/jbed/runtime/Isolate")) return source;
    JbedVmHeapRoot from = {source, source, vm->heap.temporary_roots};
    JbedVmHeapRoot target = {isolate, isolate, &from};
    JbedVmHeapRoot to = {0, 0, &target};
    vm->heap.temporary_roots = &to;
    JbedAddress tag = get(vm, from.value), klass = get(vm, tag);
    if (instance(vm, from.value, "java/lang/String")) {
        uint32_t length = get(vm, from.value + 20);
        to.value = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_CHAR], (int32_t)length, false);
        JbedAddress data = get(vm, from.value + 12) + get(vm, from.value + 16);
        memcpy(jbed_vm_span(vm->heap.memory, to.value + 16, 2 * length), jbed_vm_span(vm->heap.memory, data, 2 * length), 2 * length);
        JbRef string = jbed_vm_allocate_object(vm, vm->string_class, false);
        put(vm, string + 12, to.value);
        put(vm, string + 16, 16);
        put(vm, string + 20, length);
        to.value = string;
    } else if ((int32_t)get(vm, tag - 4) < 0) {
        uint32_t kind = get(vm, tag - 4), length = get(vm, from.value + 12);
        to.value = jbed_vm_allocate_array(vm, klass, (int32_t)length, false);
        if (kind & JBED_ARRAY_REFERENCES) {
            for (uint32_t i = 0; i < length; ++i) {
                JbRef value = Base_deepCopy(get(vm, from.value + 16 + 4 * i), target.value);
                put(vm, to.value + 16 + 4 * i, value);
            }
        } else {
            uint32_t size = (length << (kind & JBED_ARRAY_ELEMENT_SHIFT_MASK)) + 4;
            memcpy(jbed_vm_span(vm->heap.memory, to.value + 12, size), jbed_vm_span(vm->heap.memory, from.value + 12, size), size);
        }
    } else {
        const char *allowed[] = {"com/jbed/runtime/Copyable", "java/lang/Boolean", "java/lang/Byte",
            "java/lang/Integer", "java/lang/Long", "java/lang/Short", "java/util/Vector", "java/util/Hashtable", "java/lang/Throwable"};
        bool copyable = false;
        for (unsigned i = 0; i < sizeof allowed / sizeof *allowed && !copyable; ++i)
            copyable = instance(vm, from.value, allowed[i]);
        if (!copyable || instance(vm, from.value, "com/jbed/runtime/FinalizedQueue"))
            jbed_vm_raise(vm, JBED_ERROR_ERROR, "Object class cannot be deep-copied between isolates");
        to.value = jbed_vm_allocate_object(vm, klass, false);
        uint32_t finalizer_offset = 0;
        if (vm->heap.current_isolate != target.value && (get(vm, klass + 12) & JBED_CLASS_FINALIZED)) {
            finalizer_offset = (uint32_t)Memory_nextFinalizedOffset(from.value);
            JbRef current = vm->heap.current_isolate;
            if (!current) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
            if (get(vm, current + JBED_ISOLATE_FINALIZERS) != to.value)
                jbed_vm_fatal(vm, "deepCopy: new finalizer is not the isolate list head");
            put(vm, current + JBED_ISOLATE_FINALIZERS, get(vm, to.value + finalizer_offset));
        }
        uint32_t size = get(vm, get(vm, from.value) - 4);
        memcpy(jbed_vm_span(vm->heap.memory, to.value + 12, size - 12), jbed_vm_span(vm->heap.memory, from.value + 12, size - 12), size - 12);
        /* Tag pointer maps are terminated descending halfwords at tag-22. */
        JbedAddress map = get(vm, from.value) - JBED_TAG_POINTER_MAP_OFFSET;
        for (;;) {
            int32_t offset = (int16_t)jbed_vm_half(vm->heap.memory, map);
            if (offset <= 0) break;
            if ((uint32_t)offset != finalizer_offset) {
                JbRef value = Base_deepCopy(get(vm, to.value + (uint32_t)offset), target.value);
                put(vm, to.value + (uint32_t)offset, value);
            }
            map -= 2;
        }
        if (finalizer_offset) {
            if (!target.value) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
            put(vm, to.value + finalizer_offset, get(vm, target.value + JBED_ISOLATE_FINALIZERS));
            put(vm, target.value + JBED_ISOLATE_FINALIZERS, to.value);
        }
    }
    JbRef result = to.value;
    vm->heap.temporary_roots = from.previous;
    return result;
}
