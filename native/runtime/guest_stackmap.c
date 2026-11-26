#include "runtime.h"
#include "metadata_init.h"
#include "../compiler/vm/vm_words.h"

/* StackMapBlock.init 0xf38e8. The header and code base use bit zero as a
 * relocation tag; all exposed addresses refer to pinned code memory. */
void StackMapBlock_init(JbRef self, JbedAddress header)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "StackMapBlock outside a Jbed VM");
    if (!self) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    header &= ~1u;
    if (header & 3) jbed_vm_fatal(vm, "Unaligned stack map header");
    uint32_t base = jbed_vm_word(vm->heap.memory, header) & ~1u;
    uint32_t count = jbed_vm_word(vm->heap.memory, header + 12);
    uint32_t capacity = jbed_vm_word(vm->heap.memory, header + 16);
    jbed_vm_put_word(vm->heap.memory, self + 12, base);
    jbed_vm_put_word(vm->heap.memory, self + 16, base + jbed_vm_word(vm->heap.memory, header + 8));
    jbed_vm_put_word(vm->heap.memory, self + 20, count);
    jbed_vm_put_word(vm->heap.memory, self + 24, header + 20);
    jbed_vm_put_word(vm->heap.memory, self + 28, header + 20 + 4 * count);
    JbedAddress last = jbed_vm_static_field_slot(vm, "com/jbed/runtime/StackMapBlock", "lastAddr");
    JbedAddress map = jbed_vm_static_field_slot(vm, "com/jbed/runtime/StackMapBlock", "lastMap");
    jbed_vm_put_word(vm->heap.memory, last, UINT32_MAX);
    JbRef array = jbed_vm_word(vm->heap.memory, map);
    if (!array || (int32_t)jbed_vm_word(vm->heap.memory, array + 12) < (int32_t)capacity) {
        JbedVmHeapRoot root = {self, self, vm->heap.temporary_roots};
        vm->heap.temporary_roots = &root;
        array = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_INT], (int32_t)capacity, false);
        jbed_vm_put_word(vm->heap.memory, map, array);
        vm->heap.temporary_roots = root.previous;
    }
}
