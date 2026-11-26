#include "vm_compactor.h"
#include "vm_words.h"

#include <string.h>

enum {
    TAG = 0, FLAGS = 4, LINK = 8, LENGTH = 12, DATA = 16,
    CHUNK_TABLE = 12, CHUNK_SIZE = 20, CHUNK_NEXT = 24,
    CHAIN_END = JBED_OBJECT_MARKED
};

void jbed_vm_compactor_init(JbedVmCompactor *c, JbedVmCollector *gc, JbedAddress finalized_slot)
{
    *c = (JbedVmCompactor){.collector = gc, .memory = gc->marker.heap->memory,
                           .finalized_slot = finalized_slot};
}

/* CollectorBase.localAssert, 0xea34c. */
static void gc_assert(JbedVmCompactor *c, bool condition, int32_t code)
{
    if (!condition)
        jbed_halt(c->collector->marker.runtime, code, "GC assert");
}

static uint32_t block_size(JbedVmCompactor *c, JbedAddress object)
{
    return (jbed_vm_object_size(c->collector->marker.heap, object) + JBED_HEAP_BLOCK_MASK) & ~JBED_HEAP_BLOCK_MASK;
}

/* threadPointer, 0xea6d2. The target object's flag word points to its incoming
 * slots. The last slot holds the original flags with the low bit set. */
static void thread_slot(JbedVmCompactor *c, JbedAddress slot, bool check_alignment)
{
    JbedAddress object = jbed_vm_word(c->memory, slot);
    if (!object)
        return;
    uint32_t flags = jbed_vm_word(c->memory, object + FLAGS);
    if (flags & JBED_OBJECT_PINNED)
        return;
    if (check_alignment && (object & JBED_HEAP_BLOCK_MASK))
        jbed_halt(c->collector->marker.runtime, (int32_t)object, "no heap object, misaligned");
    jbed_vm_put_word(c->memory, object + FLAGS, slot);
    jbed_vm_put_word(c->memory, slot, flags);
}

void jbed_vm_thread_slot(JbedVmCompactor *c, JbedAddress slot)
{
    thread_slot(c, slot, true);
}

void jbed_vm_thread_field(JbedVmCompactor *c, JbedAddress slot)
{
    thread_slot(c, slot, false);
}

static uint32_t unthread(JbedVmCompactor *c, uint32_t link, JbedAddress destination)
{
    while (!(link & CHAIN_END)) {
        JbedAddress slot = link;
        link = jbed_vm_word(c->memory, slot);
        jbed_vm_put_word(c->memory, slot, destination);
    }
    return link;
}

/* makeFree, 0xead1c. The free list is ordered by when each hole appeared.
 * MoveHeap clears the temporary order numbers after the final insertion. */
static void make_free(JbedVmCompactor *c, JbedVmHole hole)
{
    if (hole.size < JBED_HEAP_BLOCK_BYTES)
        return;
    JbedVmHeap *heap = c->collector->marker.heap;
    JbedAddress start = hole.start;
    JbedBuffer m = c->memory;
    if (heap->collector_test_threshold > 0 &&
        (jbed_vm_word(m, start) != start + DATA || jbed_vm_word(m, start + LENGTH) != hole.size))
        memset(jbed_vm_at(m, start), 0xff, hole.size);
    jbed_vm_put_word(m, start, start + DATA);
    jbed_vm_put_word(m, start + FLAGS, hole.order);
    jbed_vm_put_word(m, start + LENGTH, hole.size);
    JbedAddress prev = 0;
    JbedAddress next = heap->free_list;
    if (next != heap->sentinel && jbed_vm_word(m, next + FLAGS) <= hole.order) {
        do {
            prev = next;
            next = jbed_vm_word(m, next + LINK);
        } while (next != heap->sentinel && jbed_vm_word(m, next + FLAGS) < hole.order);
    }
    jbed_vm_put_word(m, start + LINK, next);
    if (prev)
        jbed_vm_put_word(m, prev + LINK, start);
    else {
        heap->free_list = start;
        heap->last_size = INT32_MAX;
    }
    jbed_vm_put_word(m, start + DATA, jbed_vm_heap_find_table(heap, start));
    ++heap->free_count;
}

/* addHole/freeHoles/findHole, 0xea3ec..0xea59f. Keep the six largest holes
 * ahead of the slide cursor. Best fit uses size, maximum compaction uses age. */
static void add_hole(JbedVmCompactor *c, JbedAddress start, uint32_t size, bool moving)
{
    JbedVmHole *small = &c->holes[0];
    for (unsigned i = 1; i < JBED_COMPACTOR_HOLE_COUNT; ++i)
        if (c->holes[i].size < small->size)
            small = &c->holes[i];
    if (small->size < size) {
        if (moving && small->size)
            make_free(c, *small);
        *small = (JbedVmHole){size, start, c->next_order++};
    } else if (moving) {
        make_free(c, (JbedVmHole){size, start, c->next_order++});
    }
    if (size > c->largest_hole)
        c->largest_hole = size;
}

static void finish_holes(JbedVmCompactor *c, bool moving)
{
    for (unsigned i = 0; i < JBED_COMPACTOR_HOLE_COUNT; ++i) {
        if (moving && c->holes[i].size)
            make_free(c, c->holes[i]);
        c->holes[i].size = 0;
    }
    c->largest_hole = c->next_order = 0;
}

static JbedAddress place(JbedVmCompactor *c, uint32_t size, JbedAddress *cursor)
{
    if (size >= c->largest_hole) {
        JbedAddress start = *cursor;
        *cursor += size;
        return start;
    }
    JbedVmHole *chosen = NULL;
    for (unsigned i = 0; i < JBED_COMPACTOR_HOLE_COUNT; ++i) {
        JbedVmHole *h = &c->holes[i];
        if (h->size >= size && (!chosen || (c->oldest_hole ? h->order < chosen->order
                                                           : h->size < chosen->size)))
            chosen = h;
    }
    gc_assert(c, chosen != NULL, 0);
    JbedAddress start = chosen->start;
    chosen->start += size;
    chosen->size -= size;
    c->largest_hole = 0;
    for (unsigned i = 0; i < JBED_COMPACTOR_HOLE_COUNT; ++i)
        if (c->holes[i].size > c->largest_hole)
            c->largest_hole = c->holes[i].size;
    return start;
}

static void thread_fields(JbedVmCompactor *c, JbedAddress object, JbedAddress tag)
{
    uint32_t kind = jbed_vm_word(c->memory, tag - 4);
    if ((int32_t)kind < 0 && (kind & JBED_ARRAY_REFERENCES)) {
        int32_t bytes = (int32_t)(4 * jbed_vm_word(c->memory, object + LENGTH));
        for (int32_t i = 0; i < bytes; i += 4)
            jbed_vm_thread_field(c, object + DATA + (uint32_t)i);
    } else {
        gc_assert(c, tag != object + DATA, 21);
        for (JbedAddress desc = tag - JBED_TAG_POINTER_MAP_OFFSET;; desc -= 2) {
            int16_t offset = (int16_t)jbed_vm_half(c->memory, desc);
            if (offset <= 0)
                break;
            jbed_vm_thread_field(c, object + (uint32_t)offset);
        }
    }
}

static void check_slot(JbedVmCompactor *c, JbedAddress slot)
{
    JbedAddress object = jbed_vm_word(c->memory, slot);
    if (object)
        gc_assert(c, jbed_vm_word(c->memory, object) != object + DATA, 80);
}

/* CollectorBase.checkConsistency(object), 0xea1be. */
static void check_references(JbedVmCompactor *c, JbedAddress object, JbedAddress tag)
{
    uint32_t kind = jbed_vm_word(c->memory, tag - 4);
    if ((int32_t)kind >= 0) {
        for (JbedAddress desc = tag - JBED_TAG_POINTER_MAP_OFFSET;; desc -= 2) {
            int16_t offset = (int16_t)jbed_vm_half(c->memory, desc);
            if (offset <= 0)
                break;
            check_slot(c, object + (uint32_t)offset);
        }
    } else if (kind & JBED_ARRAY_REFERENCES) {
        JbedAddress start = object + DATA;
        JbedAddress end = start + 4 * jbed_vm_word(c->memory, object + LENGTH);
        for (JbedAddress slot = start; (int32_t)slot < (int32_t)end; slot += 4)
            check_slot(c, slot);
    }
}

/* CollectorBase.checkConsistency(), 0xea210. */
static void check_heap(JbedVmCompactor *c)
{
    JbedVmHeap *heap = c->collector->marker.heap;
    JbedBuffer m = c->memory;
    for (JbedAddress chunk = heap->first_chunk; chunk; chunk = jbed_vm_word(m, chunk + CHUNK_NEXT)) {
        JbedAddress table = jbed_vm_word(m, chunk + CHUNK_TABLE);
        JbedAddress end = table + jbed_vm_word(m, chunk + CHUNK_SIZE);
        for (JbedAddress obj = table; obj < end;) {
            gc_assert(c, obj >= heap->heap_start, 30);
            gc_assert(c, !(obj & JBED_HEAP_BLOCK_MASK), 31);
            JbedAddress tag = jbed_vm_word(m, obj);
            gc_assert(c, tag != 0, 32);
            gc_assert(c, !(tag & 3u), 33);
            uint32_t size = jbed_vm_object_size(heap, obj);
            gc_assert(c, (int32_t)size > 0, 37);
            bool is_free = tag == obj + DATA;
            if (!is_free)
                check_references(c, obj, tag);
            uint32_t index = (obj - table) >> JBED_HEAP_BLOCK_SHIFT;
            bool bit = (jbed_vm_word(m, table + DATA + 4 * (index >> 5)) >> (index & 31)) & 1;
            if (!is_free)
                gc_assert(c, bit, 34);
            else if (jbed_vm_word(m, obj + LINK))
                gc_assert(c, !bit, 36);
            obj += (size + JBED_HEAP_BLOCK_MASK) & ~JBED_HEAP_BLOCK_MASK;
        }
    }
}

/* Prepare, 0xea98e. Lock counts pin objects before any incoming slot can be threaded. */
static void prepare(JbedVmCompactor *c)
{
    JbedBuffer m = c->memory;
    for (JbedAddress chunk = c->collector->marker.heap->first_chunk; chunk;
         chunk = jbed_vm_word(m, chunk + CHUNK_NEXT)) {
        JbedAddress obj = jbed_vm_word(m, chunk + CHUNK_TABLE);
        JbedAddress end = obj + jbed_vm_word(m, chunk + CHUNK_SIZE);
        for (; obj < end; obj += block_size(c, obj)) {
            uint32_t flags = jbed_vm_word(m, obj + FLAGS);
            gc_assert(c, !(flags & CHAIN_END), 10);
            flags |= CHAIN_END;
            if (flags & JBED_OBJECT_LOCK_MASK)
                flags |= JBED_OBJECT_PINNED;
            jbed_vm_put_word(m, obj + FLAGS, flags);
        }
    }
}

/* Both passes use the same slide cursor and hole-selection rule. A threaded
 * header takes precedence over the free-block and pin tests. */
static JbedAddress destination(JbedVmCompactor *c, JbedAddress object, uint32_t flags,
                               uint32_t size, JbedAddress *cursor, bool moving)
{
    if (flags & CHAIN_END) {
        if (jbed_vm_word(c->memory, object) == object + DATA)
            return 0;
        if (flags & JBED_OBJECT_PINNED) {
            if (*cursor < object)
                add_hole(c, *cursor, object - *cursor, moving);
            *cursor = object + size;
            return object;
        }
    }
    return place(c, size, cursor);
}

/* ThreadHeap, 0xea9fc. Resolve forward references, then thread each outgoing
 * field. The inlined field loops in the ROM skip the root alignment check. */
static void thread_heap(JbedVmCompactor *c)
{
    JbedVmHeap *heap = c->collector->marker.heap;
    JbedBuffer m = c->memory;
    for (JbedAddress chunk = heap->first_chunk; chunk; chunk = jbed_vm_word(m, chunk + CHUNK_NEXT)) {
        JbedAddress table = jbed_vm_word(m, chunk + CHUNK_TABLE);
        memset(jbed_vm_at(m, table + DATA), 0, 4u * jbed_vm_word(m, table + LENGTH));
    }
    for (JbedAddress chunk = heap->first_chunk; chunk; chunk = jbed_vm_word(m, chunk + CHUNK_NEXT)) {
        JbedAddress table = jbed_vm_word(m, chunk + CHUNK_TABLE);
        JbedAddress end = table + jbed_vm_word(m, chunk + CHUNK_SIZE);
        JbedAddress cursor = table;
        for (JbedAddress obj = table, next; obj < end; obj = next) {
            uint32_t size = block_size(c, obj);
            next = obj + size;
            JbedAddress tag = jbed_vm_word(m, obj);
            uint32_t flags = jbed_vm_word(m, obj + FLAGS);
            JbedAddress dest = destination(c, obj, flags, size, &cursor, false);
            if (!dest)
                continue;
            if (!(flags & CHAIN_END)) {
                flags = unthread(c, flags, dest);
                jbed_vm_put_word(m, obj + FLAGS, flags);
                gc_assert(c, !(flags & JBED_OBJECT_PINNED), 20);
            }
            jbed_vm_thread_field(c, obj + LINK);
            thread_fields(c, obj, tag);

            JbedAddress bitmap = jbed_vm_heap_find_table(heap, dest);
            uint32_t index = (dest - bitmap) >> JBED_HEAP_BLOCK_SHIFT;
            JbedAddress slot = bitmap + DATA + 4 * (index >> 5);
            jbed_vm_put_word(m, slot, jbed_vm_word(m, slot) | (1u << (index & 31)));
        }
        if (cursor < end)
            add_hole(c, cursor, end - cursor, false);
    }
    finish_holes(c, false);
}

/* MoveHeap, 0xeabdc. Resolve backward references before copying, consume the
 * header bits, and rebuild the free list in the order the holes appeared. */
static void move_heap(JbedVmCompactor *c)
{
    JbedVmHeap *heap = c->collector->marker.heap;
    JbedBuffer m = c->memory;
    heap->free_list = heap->sentinel;
    heap->last_size = INT32_MAX;
    heap->free_count = heap->allocated = 0;
    for (JbedAddress chunk = heap->first_chunk; chunk; chunk = jbed_vm_word(m, chunk + CHUNK_NEXT)) {
        JbedAddress table = jbed_vm_word(m, chunk + CHUNK_TABLE);
        JbedAddress end = table + jbed_vm_word(m, chunk + CHUNK_SIZE);
        JbedAddress cursor = table;
        for (JbedAddress obj = table, next; obj < end; obj = next) {
            uint32_t size = block_size(c, obj);
            next = obj + size;
            uint32_t flags = jbed_vm_word(m, obj + FLAGS);
            JbedAddress dest = destination(c, obj, flags, size, &cursor, true);
            if (!dest)
                continue;
            if (!(flags & CHAIN_END))
                flags = unthread(c, flags, dest);
            jbed_vm_put_word(m, obj + FLAGS, flags & ~(uint32_t)(CHAIN_END | JBED_OBJECT_PINNED));
            if (dest != obj) {
                memmove(jbed_vm_at(m, dest), jbed_vm_at(m, obj), size);
                jbed_vm_compact_relocate_roots(c, obj, dest);
                for (JbedVmHeapRoot *root = heap->temporary_roots; root; root = root->previous)
                    if (root->value == obj)
                        root->relocated = dest;
                ++c->moved;
            }
            heap->allocated += size;
        }
        if (cursor < end)
            add_hole(c, cursor, end - cursor, true);
    }
    finish_holes(c, true);
    for (JbedAddress block = heap->free_list; block != heap->sentinel;
         block = jbed_vm_word(m, block + LINK))
        jbed_vm_put_word(m, block + FLAGS, 0);
}

/* Compactor.run / runCompactor, 0xea5a0 / 0xea698. The host supplies the
 * stopped thread snapshot at the Scheduling.saveThreadState boundary. */
void jbed_vm_compact(JbedVmCompactor *c, bool oldest_hole)
{
    JbedVmHeap *heap = c->collector->marker.heap;
    c->oldest_hole = oldest_hole;
    c->moved = c->stack_locked = 0;
    check_heap(c);
    heap->collecting = true;
    prepare(c);
    jbed_vm_compact_roots(c);
    thread_heap(c);
    for (JbedVmHeapRoot *root = heap->temporary_roots; root; root = root->previous)
        root->relocated = root->value;
    move_heap(c);
    for (JbedVmHeapRoot *root = heap->temporary_roots; root; root = root->previous)
        root->value = root->relocated;
    jbed_vm_compact_fix_interior(c);
    heap->collecting = false;
    check_heap(c);
    ++c->runs;
}
