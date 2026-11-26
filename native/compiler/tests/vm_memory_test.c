#ifdef NDEBUG
#undef NDEBUG
#endif
#include "vm_collector.h"
#include "vm_words.h"

#include <assert.h>
#include <string.h>

static const JbedAddress raw = 0x20000, object_class = 0x20200, array_class = 0x20300;
static const JbedAddress component = 0x20100, object_tag = 0x20144, array_tag = 0x20164;

static unsigned phases[4], count;
static void release_soft(void *unused, JbedVmHeap *heap, bool clear_soft)
{
    (void)unused;
    phases[count++] = clear_soft ? 2 : 1;
    heap->soft_references = clear_soft ? 0 : 1;
}

static bool reserve(void *unused, uint32_t requested, JbedAddress *base, uint32_t *size)
{
    (void)unused;
    phases[count++] = 3;
    assert(requested == 96);
    *base = raw + 0x1000;
    *size = 256;
    return true;
}

typedef struct FinalizerCalls {
    JbedAddress objects[2], isolates[2];
    unsigned count;
} FinalizerCalls;

static void finalize(void *context, JbedAddress isolate, JbedAddress object)
{
    FinalizerCalls *calls = context;
    assert(calls->count < 2);
    calls->objects[calls->count] = object;
    calls->isolates[calls->count++] = isolate;
}

static void collect_on_exhaustion(JbedBuffer map)
{
    JbedVmHeap heap;
    jbed_vm_heap_init(&heap, map, 0);
    heap.int_array_tag = array_tag;
    jbed_vm_put_word(map, object_tag - 24, 0);
    jbed_vm_put_word(map, object_class + 4, 1); /* Resident class is always marked. */
    jbed_vm_put_word(map, object_class + 12, 0x10000000);
    jbed_vm_put_word(map, object_class + 20, component);
    jbed_vm_put_word(map, component + 12, 0);
    assert(jbed_vm_heap_add_chunk(&heap, raw + 0x400, 256, true));
    JbedAddress roots = raw + 0x1800, isolates = roots + 16, retiring = isolates + 32;
    memset(jbed_vm_at(map, roots), 0, 256);
    jbed_vm_put_word(map, isolates + 12, 1);
    jbed_vm_put_word(map, isolates + 16, retiring);
    jbed_vm_put_word(map, retiring + 20, 4);
    JbedAddress keep = jbed_vm_new_object(&heap, object_class);
    JbedAddress dead = jbed_vm_new_object(&heap, object_class);
    heap.current_isolate = retiring;
    JbedAddress transfer = jbed_vm_new_object(&heap, object_class);
    JbedAddress retire_dead = jbed_vm_new_object(&heap, object_class);
    jbed_vm_put_word(map, roots, keep);
    jbed_vm_put_word(map, roots + 4, transfer);
    assert(jbed_vm_kni_new_object(&heap, object_class));
    assert(jbed_vm_kni_new_object(&heap, object_class));
    assert(!heap.free_count);
    FinalizerCalls calls = {0};
    JbedVmCollector gc = {.marker.heap = &heap, .isolates = isolates, .global_start = roots,
                          .global_end = roots + 8, .context = &calls, .invoke_finalizer = finalize};
    heap.collector = &gc;
    assert(jbed_vm_kni_new_object(&heap, object_class) == dead);
    assert(gc.collections == 1 && !heap.collecting && gc.checkpoint_requested);
    assert(calls.count == 2 && calls.objects[0] == dead && calls.isolates[0] == 0);
    assert(calls.objects[1] == retire_dead && calls.isolates[1] == retiring);
    assert(heap.current_isolate == retiring && heap.finalized == transfer);
    assert(jbed_vm_word(map, jbed_vm_finalizer_link(&heap, transfer)) == keep);
    assert(!jbed_vm_word(map, retiring + 104) && !jbed_vm_word(map, jbed_vm_finalizer_link(&heap, keep)));
}

static void collect_while_building_arrays(JbedBuffer map)
{
    JbedVmHeap heap;
    jbed_vm_heap_init(&heap, map, 0);
    heap.int_array_tag = array_tag;
    const JbedAddress refs = raw + 0x360, ref_tag = raw + 0x1a4, isolates = raw + 0x1800;
    jbed_vm_put_word(map, isolates + 12, 0);
    jbed_vm_put_word(map, refs + 4, 1);
    jbed_vm_put_word(map, refs + 20, array_class);
    jbed_vm_put_word(map, refs + 36, ref_tag);
    jbed_vm_put_word(map, ref_tag - 4, 0x80000102);
    jbed_vm_put_word(map, ref_tag, refs);
    jbed_vm_put_word(map, array_tag - 24, 0);
    jbed_vm_put_word(map, array_class + 4, 1);
    assert(jbed_vm_heap_add_chunk(&heap, raw + 0x400, 416, true));
    JbedVmCollector gc = {.marker.heap = &heap, .isolates = isolates};
    heap.collector = &gc;
    JbedAddress leaf = jbed_vm_new_array(&heap, 2, array_class);
    jbed_vm_put_word(map, leaf + 16, 123);
    JbedAddress row = jbed_vm_new_array_n(&heap, 2, leaf, refs);
    for (unsigned i = 0; i < 4; ++i)
        assert(jbed_vm_new_array(&heap, 0, array_class));
    JbedAddress outer = jbed_vm_new_array_n(&heap, 3, row, refs);
    assert(outer && gc.collections == 1 && !heap.temporary_roots);
    assert(jbed_vm_word(map, outer + 16) == row);
    assert(jbed_vm_word(map, row + 16) == leaf && jbed_vm_word(map, leaf + 16) == 123);
    JbedAddress rows[2] = {jbed_vm_word(map, outer + 20), jbed_vm_word(map, outer + 24)};
    assert(rows[0] != row && rows[1] != row && rows[0] != rows[1]);
    for (unsigned i = 0; i < 2; ++i) {
        JbedAddress a = jbed_vm_word(map, rows[i] + 16), b = jbed_vm_word(map, rows[i] + 20);
        assert(a != b && a != leaf && b != leaf && jbed_vm_word(map, a + 12) == 2);
        assert(jbed_vm_word(map, a + 16) == 0 && jbed_vm_word(map, b + 16) == 0);
    }
}

typedef struct ReleasedChunks {
    JbedAddress address[3];
    unsigned count;
} ReleasedChunks;

static void release_chunk(void *context, JbedAddress address, uint32_t size)
{
    ReleasedChunks *released = context;
    assert(released->count < 3 && size == 256);
    released->address[released->count++] = address;
}

static void release_empty_chunks(JbedBuffer map)
{
    JbedVmHeap heap;
    jbed_vm_heap_init(&heap, map, 0);
    heap.int_array_tag = array_tag;
    JbedAddress a = raw + 0x400, b = raw + 0x800, c = raw + 0xc00;
    ReleasedChunks released = {0};
    heap.services.context = &released;
    heap.services.release_chunk = release_chunk;
    assert(jbed_vm_heap_add_chunk(&heap, a, 256, true));
    assert(jbed_vm_heap_add_chunk(&heap, b, 256, true));
    assert(jbed_vm_heap_add_chunk(&heap, c, 256, true));
    *jbed_vm_at(map, b + 28) = 1;
    assert(jbed_vm_heap_sort_chunks(&heap, true));
    assert(heap.first_chunk == b && jbed_vm_word(map, b + 24) == a);
    assert(jbed_vm_word(map, a + 24) == c && !jbed_vm_word(map, c + 24));
    assert(jbed_vm_heap_sort_chunks(&heap, false));
    assert(heap.first_chunk == a && jbed_vm_word(map, a + 24) == c);
    assert(jbed_vm_word(map, c + 24) == b && !jbed_vm_word(map, b + 24));
    assert(jbed_vm_heap_release_empty_chunk(&heap, c));
    assert(released.count == 1 && released.address[0] == c);
    assert(heap.heap_size == 448 && heap.allocated == 64 && heap.free_count == 2);
    assert(jbed_vm_kni_new_object(&heap, object_class) == a + 64);
    assert(!jbed_vm_heap_release_empty_chunk(&heap, a) && heap.fault == JBED_HEAP_OK);
    jbed_vm_heap_shutdown(&heap);
    assert(released.count == 3 && released.address[1] == a && released.address[2] == b);
    assert(!heap.first_chunk && heap.free_list == heap.sentinel && !heap.heap_size);
}

int main(void)
{
    uint8_t ram[8192];
    memset(ram, 0x55, sizeof ram);
    JbedBuffer map = {.data = ram, .address = raw, .size = sizeof ram};
    JbedVmHeap heap;
    jbed_vm_heap_init(&heap, map, 0);
    heap.int_array_tag = array_tag;
    jbed_vm_put_word(map, component + 28, 4);
    jbed_vm_put_word(map, array_class + 20, component);
    jbed_vm_put_word(map, array_class + 36, array_tag);
    jbed_vm_put_word(map, array_tag - 4, 0x80000002);
    jbed_vm_put_word(map, array_tag, array_class);
    jbed_vm_put_word(map, object_tag - 4, 20);
    jbed_vm_put_word(map, object_tag, object_class);
    jbed_vm_put_word(map, object_class + 12, 0);
    jbed_vm_put_word(map, object_class + 28, 20);
    jbed_vm_put_word(map, object_class + 36, object_tag);

    assert(jbed_vm_heap_add_chunk(&heap, raw + 0x400, 256, true));
    const JbedAddress table = raw + 0x420;
    assert(jbed_vm_heap_largest_free(&heap) == 192);
    JbedAddress a = jbed_vm_new_object(&heap, object_class);
    JbedAddress b = jbed_vm_new_array(&heap, 7, array_class);
    heap.allocation_end = 1;
    JbedAddress c = jbed_vm_new_object(&heap, object_class);
    assert(a == table + 32 && b == table + 64 && c == table + 192);
    assert(jbed_vm_heap_find_table(&heap, c + 7) == table);
    assert(jbed_vm_word(map, c + 4) == 16 && heap.allocation_end == 0);
    assert(jbed_vm_word(map, table + 16) == 0x47);
    assert(jbed_vm_object_size(&heap, b) == 44 && jbed_vm_word(map, b + 16) == 0);
    assert(!jbed_vm_kni_new_array(&heap, -1, array_class) && heap.fault == JBED_HEAP_OK);
    assert(!jbed_vm_new_array(&heap, -1, array_class) && heap.fault == JBED_HEAP_NEGATIVE_ARRAY);

    jbed_vm_put_word(map, b + 4, 1);
    jbed_vm_heap_sweep(&heap);
    assert(heap.allocated == 96 && heap.live_objects == 2 && heap.freed_objects == 2);
    assert(heap.free_count == 2 && jbed_vm_word(map, table + 16) == 5);
    assert(jbed_vm_heap_largest_free(&heap) == 96);
    heap.allocation_end = -1;
    assert(jbed_vm_kni_new_object(&heap, object_class) == c);
    heap.allocation_end = 0;
    assert(jbed_vm_new_object(&heap, object_class) == a);
    assert(jbed_vm_new_array(&heap, 12, array_class) == table + 128);
    assert(!heap.free_count);

    heap.services.collect = release_soft;
    heap.services.reserve_chunk = reserve;
    assert(jbed_vm_new_object(&heap, object_class) == raw + 0x1040);
    assert(phases[0] == 1 && phases[1] == 2 && phases[2] == 3 && count == 3);
    assert(heap.heap_size == 448);
    release_empty_chunks(map);
    collect_on_exhaustion(map);
    collect_while_building_arrays(map);
    return 0;
}
