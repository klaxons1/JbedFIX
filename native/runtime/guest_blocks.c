#include "guest_blocks.h"
#include "metadata_init.h"
#include "memory.h"
#include "../compiler/vm/vm_words.h"
#include <string.h>

static JbedVm *active(void)
{
    JbedVm *vm = jbed_vm_current();
    if (!vm) jbed_vm_fatal(NULL, "HeapCodeBlocks outside a Jbed VM");
    return vm;
}
static uint32_t get(JbedVm *vm, JbRef object, uint32_t offset)
{
    if (!object) jbed_vm_raise(vm, JBED_ERROR_NULL_POINTER, NULL);
    return jbed_vm_word(vm->heap.memory, object + offset);
}
static JbedAddress item(JbedVm *vm, JbRef array, uint32_t i)
{
    if (i >= get(vm, array, 12)) jbed_vm_raise(vm, JBED_ERROR_ARRAY_INDEX, NULL);
    return array + 16 + 4 * i;
}
static JbedAddress slot(JbedVm *vm, const char *name)
{
    JbedAddress result = jbed_vm_static_field_slot(vm, "com/jbed/runtime/HeapCodeBlocks", name);
    if (!result) jbed_vm_fatal(vm, "Missing HeapCodeBlocks static field");
    return result;
}

/* 0x16187e: only exact block payload bases identify a cached allocation. */
JbRef HeapCodeBlocks_getArrayForBlock(JbRef self, JbedAddress address)
{
    (void)self;
    JbedVm *vm = active();
    JbRef blocks = jbed_vm_word(vm->heap.memory, slot(vm, "blocks"));
    uint32_t count = get(vm, blocks, 12);
    for (uint32_t i = 0; i < count; ++i) {
        JbRef array = jbed_vm_word(vm->heap.memory, item(vm, blocks, i));
        if (array && array + 16 == address) return array;
    }
    jbed_vm_fatal(vm, "HeapCodeBlocks: block is not in cache");
}

/* 0x1616a0. Cache entries survive release for reuse, but only entries with a
 * zero owner ID are available. Exposed payload addresses require pinned arrays. */
bool HeapCodeBlocks_getCodeBlocks(JbRef self, int32_t count, JbRef output, int32_t size)
{
    JbedVm *vm = active();
    JbedAddress blocks_slot = slot(vm, "blocks"), ids_slot = slot(vm, "blockIds"), used_slot = slot(vm, "blocksUsed");
    int32_t needed = (int32_t)(jbed_vm_word(vm->heap.memory, used_slot) + (uint32_t)count);
    if (needed > 1024) return false;
    JbedVmHeapRoot object = {self, self, vm->heap.temporary_roots};
    JbedVmHeapRoot out = {output, output, &object};
    JbedVmHeapRoot grown = {0, 0, &out};
    vm->heap.temporary_roots = &grown;
    JbRef blocks = jbed_vm_word(vm->heap.memory, blocks_slot);
    uint32_t capacity = get(vm, blocks, 12);
    if (needed > (int32_t)capacity) {
        uint32_t larger = capacity;
        if (!larger) jbed_vm_fatal(vm, "HeapCodeBlocks cache has zero capacity");
        while ((int32_t)larger < needed) larger *= 2;
        JbedAddress klass = jbed_vm_find_class(vm, "[[B");
        grown.value = jbed_vm_allocate_array(vm, klass, (int32_t)larger, false);
        System_arraycopy(jbed_vm_word(vm->heap.memory, blocks_slot), 0, grown.value, 0, (int32_t)capacity);
        JbRef ids = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_INT], (int32_t)larger, false);
        System_arraycopy(jbed_vm_word(vm->heap.memory, ids_slot), 0, ids, 0, (int32_t)capacity);
        jbed_vm_put_word(vm->heap.memory, blocks_slot, grown.value);
        jbed_vm_put_word(vm->heap.memory, ids_slot, ids);
    }
    uint32_t i = 0;
    for (int32_t n = 0; n < count; ++i) {
        JbRef ids = jbed_vm_word(vm->heap.memory, ids_slot);
        if (jbed_vm_word(vm->heap.memory, item(vm, ids, i))) continue;
        blocks = jbed_vm_word(vm->heap.memory, blocks_slot);
        JbRef array = jbed_vm_word(vm->heap.memory, item(vm, blocks, i));
        uint32_t k = i;
        if (!array || size != (int32_t)get(vm, array, 12)) {
            if (array) {
                uint32_t limit = get(vm, blocks, 12);
                for (k = i + 1; k < limit && jbed_vm_word(vm->heap.memory, item(vm, blocks, k)); ++k) {}
                if (k == limit) k = i;
            }
            Memory_nextAllocateLocked();
            array = jbed_vm_allocate_array(vm, vm->primitive_array_classes[JBED_TYPE_BYTE], size, false);
            blocks = jbed_vm_word(vm->heap.memory, blocks_slot);
            jbed_vm_put_word(vm->heap.memory, item(vm, blocks, k), array);
        }
        ids = jbed_vm_word(vm->heap.memory, ids_slot);
        jbed_vm_put_word(vm->heap.memory, item(vm, ids, k), get(vm, object.value, 16));
        array = jbed_vm_word(vm->heap.memory, item(vm, jbed_vm_word(vm->heap.memory, blocks_slot), k));
        jbed_vm_put_word(vm->heap.memory, item(vm, out.value, (uint32_t)n++), array + 16);
        jbed_vm_put_word(vm->heap.memory, used_slot, jbed_vm_word(vm->heap.memory, used_slot) + 1);
    }
    vm->heap.temporary_roots = object.previous;
    return true;
}

/* 0x161904: resolve only blocks owned by this CodeBlocks instance, then use
 * System.arraycopy so source/destination slice errors keep Java semantics. */
void HeapCodeBlocks_writeBlock(JbRef self, JbedAddress address, JbRef source, int32_t offset, int32_t length)
{
    JbedVm *vm = active();
    JbRef blocks = jbed_vm_word(vm->heap.memory, slot(vm, "blocks"));
    JbRef ids = jbed_vm_word(vm->heap.memory, slot(vm, "blockIds"));
    uint32_t count = get(vm, blocks, 12), owner = get(vm, self, 16);
    for (uint32_t i = 0; i < count; ++i) {
        if (jbed_vm_word(vm->heap.memory, item(vm, ids, i)) != owner) continue;
        JbRef array = jbed_vm_word(vm->heap.memory, item(vm, blocks, i));
        JbedAddress base = array + 16;
        if (address < base) continue;
        uint32_t size = get(vm, array, 12);
        if (address >= base + size) continue;
        if (address + (uint32_t)length > base + size)
            jbed_vm_fatal(vm, "HeapCodeBlocks write exceeds block");
        System_arraycopy(source, offset, array, (int32_t)(address - base), length);
        return;
    }
    jbed_vm_fatal(vm, "HeapCodeBlocks write has no owned block");
}
