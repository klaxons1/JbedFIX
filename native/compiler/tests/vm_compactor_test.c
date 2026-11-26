#ifdef NDEBUG
#undef NDEBUG
#endif
#include "vm_compactor.h"
#include "vm_words.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

static void halt(void *ctx, int32_t code, const char *message)
{
    (void)ctx;
    fprintf(stderr, "%s (%d)\n", message, code);
    abort();
}

static JbedAddress object(JbedVmHeap *heap, JbedAddress tag, uint32_t flags)
{
    JbedAddress obj = jbed_vm_heap_try_alloc(heap, 32);
    assert(obj);
    jbed_vm_put_word(heap->memory, obj, tag);
    jbed_vm_put_word(heap->memory, obj + 4, flags);
    return obj;
}

static void visit_roots(void *context, const JbedVmRootVisitor *local,
                        const JbedVmRootVisitor *global)
{
    (void)global;
    local->stack_reference(local->context, *(JbedAddress *)context);
}

int main(void)
{
    enum { BASE = 0x400000, INT_TAG = BASE + 0x40, OBJ_TAG = BASE + 0x80,
           ARRAY_TAG = BASE + 0xc0, ROOTS = BASE + 0x100, ISOLATES = BASE + 0x140,
           CHUNK = BASE + 0x1000, TABLE = CHUNK + 32 };
    uint8_t bytes[0x2000] = {0};
    JbedBuffer m = {bytes, sizeof bytes, BASE};
    JbedVmHeap heap;
    jbed_vm_heap_init(&heap, m, 0);
    heap.int_array_tag = INT_TAG;
    jbed_vm_put_word(m, INT_TAG - 4, UINT32_C(0x80000002));
    jbed_vm_put_word(m, OBJ_TAG - 4, 32);
    jbed_vm_put_word(m, OBJ_TAG - 24, 12u << 16);
    jbed_vm_put_word(m, ARRAY_TAG - 4, UINT32_C(0x80000102));
    assert(jbed_vm_heap_add_chunk(&heap, CHUNK, 1024, true));

    object(&heap, OBJ_TAG, 0);
    object(&heap, OBJ_TAG, 0);
    JbedAddress pinned = object(&heap, OBJ_TAG, 17);
    JbedAddress left = object(&heap, OBJ_TAG, 1);
    object(&heap, OBJ_TAG, 0);
    JbedAddress right = object(&heap, OBJ_TAG, 1);
    JbedAddress array = object(&heap, ARRAY_TAG, 1);
    jbed_vm_put_word(m, left + 12, right);
    jbed_vm_put_word(m, right + 12, left);
    jbed_vm_put_word(m, pinned + 8, array);
    jbed_vm_put_word(m, array + 12, 4);
    jbed_vm_put_word(m, array + 16, left);
    jbed_vm_put_word(m, array + 28, right);
    jbed_vm_put_word(m, ROOTS, left);
    jbed_vm_put_word(m, ROOTS + 4, array);
    jbed_vm_put_word(m, ROOTS + 8, right);
    jbed_vm_heap_sweep(&heap);
    JbedVmHeapRoot temporary = {.value = right};
    heap.temporary_roots = &temporary;
    JbedRuntime runtime = {.halt = halt};
    JbedAddress additional_root = ROOTS + 8;
    JbedVmCollector gc = {.marker = {.heap = &heap, .runtime = &runtime}, .isolates = ISOLATES,
                          .global_start = ROOTS, .global_end = ROOTS + 8,
                          .context = &additional_root, .visit_roots = visit_roots};
    JbedVmCompactor c;
    jbed_vm_compactor_init(&c, &gc, 0);
    jbed_vm_compact(&c, false);
    assert(c.runs == 1 && c.moved == 3 && !heap.collecting);
    left = TABLE + 32;
    right = TABLE + 128;
    array = TABLE + 160;
    assert(temporary.value == right);
    assert(jbed_vm_word(m, ROOTS) == left && jbed_vm_word(m, ROOTS + 4) == array);
    assert(jbed_vm_word(m, additional_root) == right);
    assert(jbed_vm_word(m, left + 12) == right && jbed_vm_word(m, right + 12) == left);
    assert(jbed_vm_word(m, pinned + 8) == array && jbed_vm_word(m, pinned + 4) == 16);
    assert(jbed_vm_word(m, array + 16) == left && jbed_vm_word(m, array + 28) == right);
    assert(jbed_vm_word(m, TABLE + 16) == 0x3b);
    assert(heap.allocated == 160 && heap.free_count == 2);
    assert(heap.free_list == TABLE + 64 && jbed_vm_word(m, heap.free_list + 8) == TABLE + 192);
    return 0;
}
