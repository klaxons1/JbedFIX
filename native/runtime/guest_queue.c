#include "guest_queue.h"
#include "guest_call.h"
#include "metadata_init.h"
#include "../compiler/vm/vm_words.h"
#include <string.h>

static uint32_t get(JbedVm *vm, JbRef object, uint32_t offset)
{
    if (!object) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    return jbed_vm_word(vm->heap.memory, object + offset);
}
static void put(JbedVm *vm, JbRef object, uint32_t offset, uint32_t value)
{
    if (!object) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    jbed_vm_put_word(vm->heap.memory, object + offset, value);
}

/* GlobalCallHandler.tryAddEntry 0xbbae0. The target's CallHandler is accessed
 * under its statics base, while allocation/constructor run in the caller. */
int32_t GlobalCallHandler_tryAddEntry(JbRef isolate, JbRef context, JbRef replacement)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "GlobalCallHandler outside a Jbed VM");
    if (!isolate) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    JbedVmHeapRoot target = {isolate, isolate, vm->heap.temporary_roots};
    JbedVmHeapRoot call = {context, context, &target};
    JbedVmHeapRoot expanded = {replacement, replacement, &call};
    JbedVmHeapRoot handler = {0, 0, &expanded};
    vm->heap.temporary_roots = &handler;
    if (*jbed_vm_at(vm->heap.memory, target.value + 24)) {
        uint32_t args[1];
        handler.value = (JbRef)jbed_vm_guest_call(vm, JBED_GUEST_STATIC, "com/jbed/util/CallHandler",
            "getHandler", "()Lcom/jbed/util/CallHandler;", args, 0);
    } else {
        if ((int32_t)get(vm, target.value, 20) >= 4) {
            vm->heap.temporary_roots = target.previous;
            return -1;
        }
        JbedAddress previous = jbed_vm_switch_statics(vm, get(vm, target.value, 80) + 16);
        JbedAddress slot = jbed_vm_static_field_slot(vm, "com/jbed/util/CallHandler", "handler");
        handler.value = jbed_vm_word(vm->heap.memory, slot);
        jbed_vm_switch_statics(vm, previous);
        if (!handler.value) {
            handler.value = jbed_vm_allocate_object(vm, jbed_vm_find_class(vm, "com/jbed/util/CallHandler"), false);
            uint32_t args[] = {handler.value};
            jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/util/CallHandler", "<init>", "()V", args, 1);
            previous = jbed_vm_switch_statics(vm, get(vm, target.value, 80) + 16);
            slot = jbed_vm_static_field_slot(vm, "com/jbed/util/CallHandler", "handler");
            jbed_vm_put_word(vm->heap.memory, slot, handler.value);
            jbed_vm_switch_statics(vm, previous);
        }
    }
    ++Jbed_noAllocation;
    JbRef entries = get(vm, handler.value, 24);
    uint32_t capacity = get(vm, entries, 12), head = get(vm, handler.value, 28), tail = get(vm, handler.value, 32);
    if (capacity < 2 || ((capacity - 1) & capacity))
        jbed_vm_fatal(vm, "CallHandler queue capacity is not a power of two");
    if (expanded.value) {
        if (tail < head) {
            memmove(jbed_vm_span(vm->heap.memory, expanded.value + 16 + 4 * tail, 4 * (head - tail)),
                jbed_vm_span(vm->heap.memory, entries + 16 + 4 * tail, 4 * (head - tail)), 4 * (head - tail));
        } else {
            memmove(jbed_vm_span(vm->heap.memory, expanded.value + 16 + 4 * tail, 4 * (capacity - tail)),
                jbed_vm_span(vm->heap.memory, entries + 16 + 4 * tail, 4 * (capacity - tail)), 4 * (capacity - tail));
            memmove(jbed_vm_span(vm->heap.memory, expanded.value + 16 + 4 * capacity, 4 * head),
                jbed_vm_span(vm->heap.memory, entries + 16, 4 * head), 4 * head);
            head += capacity;
            put(vm, handler.value, 28, head);
        }
        entries = expanded.value;
        put(vm, handler.value, 24, entries);
        capacity = get(vm, entries, 12);
    }
    uint32_t next = (head + 1) & (capacity - 1);
    if (next == tail) {
        --Jbed_noAllocation;
        vm->heap.temporary_roots = target.previous;
        return (int32_t)(2 * capacity);
    }
    if (head >= get(vm, entries, 12)) jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    put(vm, entries, 16 + 4 * head, call.value);
    if (*jbed_vm_at(vm->heap.memory, handler.value + 40)) {
        uint32_t args[] = {get(vm, handler.value, 36)};
        jbed_vm_guest_call(vm, JBED_GUEST_DIRECT, "com/jbed/runtime/Signal", "send", "()V", args, 1);
    }
    put(vm, handler.value, 28, next);
    --Jbed_noAllocation;
    vm->heap.temporary_roots = target.previous;
    return 0;
}
