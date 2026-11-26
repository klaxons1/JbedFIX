#include "vm_memory.h"
#include "vm_collector.h"
#include "vm_compactor.h"
#include "vm_words.h"

#include <limits.h>
#include <string.h>

enum {
    TAG = 0, FLAGS = 4, LINK = 8, LENGTH = 12, DATA = 16,
    CHUNK_TABLE = 12, CHUNK_RAW = 16, CHUNK_SIZE = 20, CHUNK_NEXT = 24,
    CHUNK_LOCKED = 28, CHUNK_LOCKABLE = 29,
    CLASS_FLAGS = 12, CLASS_SUPER = 20, CLASS_SIZE = 28, CLASS_TAG = 36,
    ROM_CHUNK_TAG = 0x1dd668, ROM_INT_ARRAY_TAG = 0x1ecce8, ROM_FREE_LIST_SENTINEL = 0xab3a8,
    IDENTITY_HASH_SEED = 0x0f123456, IDENTITY_HASH_SHIFT = 8, IDENTITY_HASH_SIGN = 0x800000,
    TRACE_SAMPLE_BYTES = 16384, MAX_ARRAY_PAYLOAD_BYTES = 0x7fff0000,
    CHUNK_HEADER_BYTES = 32, CHUNK_ALLOCATION_OVERHEAD = 64,
    BITMAP_WORD_COVERAGE_SHIFT = JBED_HEAP_BLOCK_SHIFT + 5,
    BITMAP_WORD_COVERAGE = 1 << BITMAP_WORD_COVERAGE_SHIFT
};

static uint32_t align_block(uint32_t bytes)
{
    return (bytes + JBED_HEAP_BLOCK_MASK) & ~JBED_HEAP_BLOCK_MASK;
}

static void set_link(JbedVmHeap *heap, JbedAddress previous, JbedAddress next)
{
    if (previous)
        jbed_vm_put_word(heap->memory, previous + LINK, next);
    else
        heap->free_list = next;
}

static void free_block(JbedBuffer map, JbedAddress block, uint32_t size, JbedAddress table)
{
    jbed_vm_put_word(map, block + TAG, block + DATA);
    jbed_vm_put_word(map, block + FLAGS, 0);
    jbed_vm_put_word(map, block + LENGTH, size); /* Read as tag[-1] by CollectorBase.next. */
    jbed_vm_put_word(map, block + DATA, table);
}

static void record_object(JbedBuffer map, JbedAddress table, JbedAddress object, bool live)
{
    uint32_t index = (object - table) >> JBED_HEAP_BLOCK_SHIFT;
    JbedAddress word = table + DATA + 4 * (index >> 5);
    uint32_t bit = UINT32_C(1) << (index & 31);
    uint32_t bits = jbed_vm_word(map, word);
    jbed_vm_put_word(map, word, live ? bits | bit : bits & ~bit);
}

void jbed_vm_heap_init_image(JbedVmHeap *heap, JbedBuffer map, JbedVmHeapImage image)
{
    *heap = (JbedVmHeap){.memory = map, .chunk_tag = image.chunk_tag,
        .int_array_tag = image.int_array_tag, .sentinel = image.free_list_sentinel,
        .free_list = image.free_list_sentinel, .last_size = INT32_MAX, .heap_start = UINT32_MAX,
        .identity_hash_state = IDENTITY_HASH_SEED};
}

void jbed_vm_heap_init(JbedVmHeap *heap, JbedBuffer map, JbedAddress rom_base)
{
    jbed_vm_heap_init_image(heap, map, (JbedVmHeapImage){rom_base + ROM_CHUNK_TAG,
        rom_base + ROM_INT_ARRAY_TAG, rom_base + ROM_FREE_LIST_SENTINEL});
}

/* Base.getHashCode, 0xe2678. Object identity hashes occupy the signed high
 * 24 bits of the flags word and survive object relocation. */
int32_t jbed_vm_identity_hash(JbedVmHeap *heap, JbedAddress object)
{
    uint32_t flags = jbed_vm_word(heap->memory, object + FLAGS);
    if (!(flags >> IDENTITY_HASH_SHIFT)) {
        uint32_t s = heap->identity_hash_state;
        heap->identity_hash_state = s << 1 | ((s >> 13 ^ s >> 22) & 1);
        flags |= heap->identity_hash_state << IDENTITY_HASH_SHIFT;
        jbed_vm_put_word(heap->memory, object + FLAGS, flags);
    }
    return (int32_t)((flags >> IDENTITY_HASH_SHIFT) ^ (uint32_t)IDENTITY_HASH_SIGN) - IDENTITY_HASH_SIGN;
}

/* Memory.initHeapBlock, 0xdff00. HeapChunk lives before the aligned int[]
 * bitmap. Bit 0 describes the bitmap itself; one word covers 1024 heap bytes. */
bool jbed_vm_heap_add_chunk(JbedVmHeap *heap, JbedAddress raw, uint32_t size, bool lockable)
{
    JbedBuffer map = heap->memory;
    uint64_t limit = (uint64_t)raw + size;
    uint64_t start = ((uint64_t)raw + CHUNK_HEADER_BYTES + JBED_HEAP_BLOCK_MASK) &
                     ~(uint64_t)JBED_HEAP_BLOCK_MASK;
    if (!raw || raw < map.address || limit > UINT32_MAX || limit - map.address > map.size ||
        start >= limit || limit - start > INT32_MAX)
        return false;
    JbedAddress table = (JbedAddress)start;
    uint32_t usable = (uint32_t)(limit - start) & ~JBED_HEAP_BLOCK_MASK;
    uint32_t words = (usable + (BITMAP_WORD_COVERAGE - 1u)) >> BITMAP_WORD_COVERAGE_SHIFT;
    uint32_t overhead = align_block(DATA + words * 4);
    if (usable < overhead + JBED_HEAP_BLOCK_BYTES || heap->heap_size > (uint32_t)INT32_MAX - usable)
        return false;
    for (JbedAddress c = heap->first_chunk; c; c = jbed_vm_word(map, c + CHUNK_NEXT)) {
        JbedAddress other = jbed_vm_word(map, c + CHUNK_RAW);
        JbedAddress end = jbed_vm_word(map, c + CHUNK_TABLE) + jbed_vm_word(map, c + CHUNK_SIZE);
        if (raw < end && other < limit)
            return false;
    }
    JbedAddress chunk = (raw + 3u) & ~3u;
    memset(jbed_vm_at(map, chunk), 0, CHUNK_HEADER_BYTES);
    memset(jbed_vm_at(map, table), 0, usable);
    jbed_vm_put_word(map, chunk + TAG, heap->chunk_tag);
    jbed_vm_put_word(map, chunk + FLAGS, JBED_OBJECT_MARKED | JBED_OBJECT_PINNED);
    jbed_vm_put_word(map, chunk + CHUNK_TABLE, table);
    jbed_vm_put_word(map, chunk + CHUNK_RAW, raw);
    jbed_vm_put_word(map, chunk + CHUNK_SIZE, usable);
    jbed_vm_put_word(map, chunk + CHUNK_NEXT, heap->first_chunk);
    *jbed_vm_at(map, chunk + CHUNK_LOCKABLE) = lockable;
    heap->first_chunk = chunk;
    if (table < heap->heap_start)
        heap->heap_start = table;
    if (table > heap->heap_end)
        heap->heap_end = table + usable;
    heap->heap_size += usable;
    jbed_vm_put_word(map, table + TAG, heap->int_array_tag);
    jbed_vm_put_word(map, table + FLAGS, JBED_OBJECT_LOCK_UNIT);
    jbed_vm_put_word(map, table + LENGTH, words);
    jbed_vm_put_word(map, table + DATA, 1);
    heap->allocated += overhead;
    JbedAddress block = table + overhead;
    free_block(map, block, usable - overhead, table);
    jbed_vm_put_word(map, block + LINK, heap->free_list);
    heap->free_list = block;
    ++heap->free_count;
    heap->last_size = INT32_MAX;
    return true;
}

JbedAddress jbed_vm_heap_find_table(const JbedVmHeap *heap, JbedAddress object)
{
    JbedBuffer map = heap->memory;
    for (JbedAddress c = heap->first_chunk; c; c = jbed_vm_word(map, c + CHUNK_NEXT)) {
        JbedAddress table = jbed_vm_word(map, c + CHUNK_TABLE);
        if (object >= table && object - table < jbed_vm_word(map, c + CHUNK_SIZE))
            return table;
    }
    return 0;
}

static bool chunk_contains(JbedBuffer map, JbedAddress chunk, JbedAddress address)
{
    JbedAddress start = jbed_vm_word(map, chunk + CHUNK_TABLE);
    return address >= start && address - start < jbed_vm_word(map, chunk + CHUNK_SIZE);
}

/* HeapChunk.moveToEnd also moves the chunk's contiguous free-list run. */
static void move_chunk_to_end(JbedVmHeap *heap, JbedAddress chunk)
{
    JbedBuffer map = heap->memory;
    JbedAddress previous = heap->first_chunk;
    if (previous == chunk) {
        JbedAddress next = jbed_vm_word(map, chunk + CHUNK_NEXT);
        if (next) heap->first_chunk = next;
    } else {
        while (jbed_vm_word(map, previous + CHUNK_NEXT) != chunk)
            previous = jbed_vm_word(map, previous + CHUNK_NEXT);
        jbed_vm_put_word(map, previous + CHUNK_NEXT, jbed_vm_word(map, chunk + CHUNK_NEXT));
    }
    while (jbed_vm_word(map, previous + CHUNK_NEXT))
        previous = jbed_vm_word(map, previous + CHUNK_NEXT);
    jbed_vm_put_word(map, previous + CHUNK_NEXT, chunk);
    jbed_vm_put_word(map, chunk + CHUNK_NEXT, 0);

    JbedAddress first_previous = 0, last = 0, tail = 0;
    for (JbedAddress block = heap->free_list; block != heap->sentinel;
         tail = block, block = jbed_vm_word(map, block + LINK)) {
        if (chunk_contains(map, chunk, block)) {
            if (!last) first_previous = tail;
            last = block;
        }
    }
    if (last && last != tail) {
        JbedAddress first = first_previous ? jbed_vm_word(map, first_previous + LINK) : heap->free_list;
        JbedAddress after = jbed_vm_word(map, last + LINK);
        jbed_vm_put_word(map, tail + LINK, first);
        set_link(heap, first_previous, after);
        jbed_vm_put_word(map, last + LINK, heap->sentinel);
    }
    if (tail) heap->last_size = INT32_MAX;
}

bool jbed_vm_heap_sort_chunks(JbedVmHeap *heap, bool locked_first)
{
    JbedBuffer map = heap->memory;
    JbedAddress first = 0, last = heap->first_chunk;
    if (!last) { heap->fault = JBED_HEAP_NULL_POINTER; return false; }
    bool mixed = false;
    for (;;) {
        if ((*jbed_vm_at(map, last + CHUNK_LOCKED) != 0) == locked_first) {
            if (first) mixed = true;
        } else if (!first) {
            first = last;
        }
        JbedAddress next = jbed_vm_word(map, last + CHUNK_NEXT);
        if (!next) break;
        last = next;
    }
    if (mixed) {
        for (JbedAddress chunk = first;;) {
            JbedAddress next = jbed_vm_word(map, chunk + CHUNK_NEXT);
            if ((*jbed_vm_at(map, chunk + CHUNK_LOCKED) != 0) != locked_first)
                move_chunk_to_end(heap, chunk);
            if (next == last) break;
            chunk = next;
        }
    }
    heap->fault = JBED_HEAP_OK;
    return true;
}

bool jbed_vm_heap_release_empty_chunk(JbedVmHeap *heap, JbedAddress chunk)
{
    JbedBuffer map = heap->memory;
    JbedAddress table = jbed_vm_word(map, chunk + CHUNK_TABLE);
    uint32_t size = jbed_vm_word(map, chunk + CHUNK_SIZE);
    uint32_t bitmap_size = align_block(jbed_vm_object_size(heap, table));
    JbedAddress first = table + bitmap_size;
    heap->fault = JBED_HEAP_OK;
    if (jbed_vm_word(map, first + TAG) != first + DATA ||
        first + align_block(jbed_vm_object_size(heap, first)) < table + size)
        return false;
    uint32_t freed = 0;
    JbedAddress previous = 0, last_removed = 0;
    for (JbedAddress block = heap->free_list; block != heap->sentinel;) {
        JbedAddress next = jbed_vm_word(map, block + LINK);
        if (chunk_contains(map, chunk, block)) {
            if (last_removed && block <= last_removed) {
                heap->fault = JBED_HEAP_BAD_FREE_LIST;
                return false;
            }
            freed += jbed_vm_word(map, block + LENGTH);
            set_link(heap, previous, next);
            --heap->free_count;
            last_removed = block;
        } else {
            previous = block;
        }
        block = next;
    }
    if (last_removed) heap->last_size = INT32_MAX;
    if (freed + bitmap_size != size) {
        heap->fault = JBED_HEAP_BAD_FREE_LIST;
        return false;
    }
    heap->allocated -= bitmap_size;
    heap->heap_size -= size;
    JbedAddress next = jbed_vm_word(map, chunk + CHUNK_NEXT);
    if (heap->first_chunk == chunk) {
        heap->first_chunk = next;
    } else {
        previous = heap->first_chunk;
        while (jbed_vm_word(map, previous + CHUNK_NEXT) != chunk)
            previous = jbed_vm_word(map, previous + CHUNK_NEXT);
        jbed_vm_put_word(map, previous + CHUNK_NEXT, next);
    }
    JbedAddress raw = jbed_vm_word(map, chunk + CHUNK_RAW);
    if (heap->services.release_chunk)
        heap->services.release_chunk(heap->services.context, raw, table + size - raw);
    return true;
}

void jbed_vm_heap_shutdown(JbedVmHeap *heap)
{
    JbedBuffer map = heap->memory;
    for (JbedAddress chunk = heap->first_chunk; chunk;) {
        JbedAddress next = jbed_vm_word(map, chunk + CHUNK_NEXT);
        JbedAddress raw = jbed_vm_word(map, chunk + CHUNK_RAW);
        uint32_t size = jbed_vm_word(map, chunk + CHUNK_TABLE) +
                         jbed_vm_word(map, chunk + CHUNK_SIZE) - raw;
        if (heap->services.release_chunk)
            heap->services.release_chunk(heap->services.context, raw, size);
        chunk = next;
    }
    heap->first_chunk = 0;
    heap->free_list = heap->sentinel;
    heap->allocated = heap->heap_size = heap->free_count = 0;
    heap->last_size = INT32_MAX;
}

static void collect(JbedVmHeap *heap, bool clear_soft)
{
    if (heap->collector)
        jbed_vm_collect(heap->collector, clear_soft);
    else if (heap->services.collect)
        heap->services.collect(heap->services.context, heap, clear_soft);
}

static void compact(JbedVmHeap *heap)
{
    if (heap->compactor)
        jbed_vm_compact(heap->compactor, false);
    else if (heap->services.compact)
        heap->services.compact(heap->services.context, heap);
}

static void account_trace_sample(JbedVmHeap *heap, uint32_t size)
{
    if (!heap->trace_usage)
        return;
    if (heap->trace_allocations >= TRACE_SAMPLE_BYTES) {
        collect(heap, false);
        heap->trace_allocations = 0;
    }
    heap->trace_allocations += size;
}

/* Memory.collectorTest, 0xdf4c0. This ROM uses java.util.Random's 48-bit LCG. */
void jbed_vm_collector_test(JbedVmHeap *heap, int32_t threshold)
{
    if (threshold <= 0)
        return;
    const uint64_t multiplier = UINT64_C(0x5deece66d), addend = 11;
    const uint64_t seed_mask = (UINT64_C(1) << 48) - 1;
    heap->collector_test_seed = (heap->collector_test_seed * multiplier + addend) & seed_mask;
    if ((int32_t)(heap->collector_test_seed >> 17) >= threshold)
        return;
    int saved = heap->allocation_end;
    heap->allocation_end = 0;
    collect(heap, false);
    compact(heap);
    heap->allocation_end = saved;
}

/* Memory.tryAlloc, 0xdf510. A request no smaller than the last successful
 * low-end request can resume at its predecessor. End allocations choose the
 * last fitting block from the same suffix and split it from the other side. */
JbedAddress jbed_vm_heap_try_alloc(JbedVmHeap *heap, uint32_t bytes)
{
    JbedBuffer map = heap->memory;
    heap->fault = JBED_HEAP_OK;
    if (!bytes || bytes > INT32_MAX - JBED_HEAP_BLOCK_MASK) {
        heap->fault = JBED_HEAP_OUT_OF_MEMORY;
        return 0;
    }
    uint32_t size = align_block(bytes);
    account_trace_sample(heap, size);
    if (heap->no_allocation > 0) {
        heap->fault = JBED_HEAP_ALLOCATION_DISABLED;
        return 0;
    }
    jbed_vm_collector_test(heap, heap->collector_test_threshold);
    JbedAddress previous = size >= heap->last_size ? heap->last_predecessor : 0;
    JbedAddress block = previous ? jbed_vm_word(map, previous + LINK) : heap->free_list;
    JbedAddress chosen = 0, predecessor = 0;
    for (; block != heap->sentinel; previous = block, block = jbed_vm_word(map, block + LINK)) {
        if (jbed_vm_word(map, block + LENGTH) >= size) {
            chosen = block;
            predecessor = previous;
            if (!heap->allocation_end)
                break;
        }
    }
    if (!chosen) {
        heap->last_size = INT32_MAX;
        heap->failed_size = size;
        return 0;
    }
    heap->last_size = heap->allocation_end ? INT32_MAX : size;
    uint32_t remaining = jbed_vm_word(map, chosen + LENGTH) - size;
    JbedAddress table = jbed_vm_word(map, chosen + DATA);
    JbedAddress next = jbed_vm_word(map, chosen + LINK);
    if (!remaining) {
        set_link(heap, predecessor, next);
        heap->last_predecessor = predecessor;
        --heap->free_count;
    } else if (heap->allocation_end) {
        jbed_vm_put_word(map, chosen + LENGTH, remaining);
        chosen += remaining;
        jbed_vm_put_word(map, chosen + TAG, chosen + DATA);
    } else {
        JbedAddress tail = chosen + size;
        free_block(map, tail, remaining, table);
        jbed_vm_put_word(map, tail + LINK, next);
        set_link(heap, predecessor, tail);
        heap->last_predecessor = predecessor;
    }
    record_object(map, table, chosen, true);
    if (!heap->accounting_disabled) {
        heap->allocated += size;
        if (heap->allocated > heap->max_allocated)
            heap->max_allocated = heap->allocated;
        heap->usage += size;
        if (heap->trace_usage && heap->usage > heap->max_total_usage)
            heap->max_total_usage = heap->usage;
    }
    memset(jbed_vm_at(map, chosen + 4), 0, size - 4);
    if (heap->allocation_end > 0) {
        heap->allocation_end = 0;
        jbed_vm_put_word(map, chosen + FLAGS, JBED_OBJECT_LOCK_UNIT);
    }
    return chosen;
}

uint32_t jbed_vm_heap_largest_free(const JbedVmHeap *heap)
{
    uint32_t largest = 0;
    for (JbedAddress b = heap->free_list; b != heap->sentinel;
         b = jbed_vm_word(heap->memory, b + LINK)) {
        uint32_t size = jbed_vm_word(heap->memory, b + LENGTH);
        if (size > largest)
            largest = size;
    }
    return largest;
}

/* Base.objectSize 0xe32a4, followed by CollectorBase.next's alignment at 0xe9f00. */
uint32_t jbed_vm_object_size(const JbedVmHeap *heap, JbedAddress object)
{
    JbedBuffer map = heap->memory;
    JbedAddress tag = jbed_vm_word(map, object + TAG);
    uint32_t kind = jbed_vm_word(map, tag - 4);
    if ((int32_t)kind < 0)
        return DATA + (jbed_vm_word(map, object + LENGTH) << (kind & JBED_ARRAY_ELEMENT_SHIFT_MASK));
    return kind;
}

static void append_free_run(JbedVmHeap *heap, JbedAddress *tail, JbedAddress table,
                            JbedAddress run, JbedAddress end)
{
    free_block(heap->memory, run, end - run, table);
    set_link(heap, *tail, run);
    *tail = run;
    ++heap->free_count;
}

/* Collector.Sweep, 0xe9890. Rebuild in chunk/physical order. Live mark bits are
 * consumed, including the artificial mark on every chunk's bitmap. */
void jbed_vm_heap_sweep(JbedVmHeap *heap)
{
    JbedBuffer map = heap->memory;
    JbedAddress tail = 0;
    uint32_t live_bytes = 0;
    heap->live_objects = heap->freed_objects = heap->free_count = 0;
    for (JbedAddress chunk = heap->first_chunk; chunk;
         chunk = jbed_vm_word(map, chunk + CHUNK_NEXT)) {
        JbedAddress table = jbed_vm_word(map, chunk + CHUNK_TABLE);
        JbedAddress end = table + jbed_vm_word(map, chunk + CHUNK_SIZE);
        jbed_vm_put_word(map, table + FLAGS, jbed_vm_word(map, table + FLAGS) | JBED_OBJECT_MARKED);
        JbedAddress run = 0;
        for (JbedAddress b = table; b < end;) {
            uint32_t size = align_block(jbed_vm_object_size(heap, b));
            assert(size && size <= end - b);
            uint32_t flags = jbed_vm_word(map, b + FLAGS);
            if (flags & JBED_OBJECT_MARKED) {
                if (run) {
                    append_free_run(heap, &tail, table, run, b);
                    run = 0;
                }
                ++heap->live_objects;
                live_bytes += size;
                jbed_vm_put_word(map, b + FLAGS, flags & ~(uint32_t)JBED_OBJECT_MARKED);
            } else {
                bool already_free = jbed_vm_word(map, b + TAG) == b + DATA;
                if (!already_free)
                    ++heap->freed_objects;
                if (heap->collector_test_threshold > 0 && (!already_free || run))
                    memset(jbed_vm_at(map, b), 0xff, already_free ? 20 : size);
                record_object(map, table, b, false);
                if (!run)
                    run = b;
            }
            b += size;
        }
        if (run)
            append_free_run(heap, &tail, table, run, end);
    }
    set_link(heap, tail, heap->sentinel);
    heap->last_size = INT32_MAX;
    heap->usage = heap->allocated = live_bytes;
}

static bool room_after_collection(const JbedVmHeap *heap, uint32_t size)
{
    return (uint64_t)heap->allocated + size < heap->heap_size;
}

/* Memory.tryAllocGc 0xdf6b4. The lock-chunk arm (state 3) has no incoming
 * transition in this build. The saved end/pin mode applies to every retry. */
static JbedAddress retry_allocation(JbedVmHeap *heap)
{
    uint32_t size = heap->failed_size;
    int saved_end = heap->allocation_end;
    enum { COLLECT, CLEAR_SOFT, COMPACT, GROW, EXHAUSTED } phase = COLLECT;
    while (phase != EXHAUSTED) {
        heap->allocation_end = 0;
        switch (phase) {
        case COLLECT:
        case CLEAR_SOFT:
            collect(heap, phase == CLEAR_SOFT);
            phase = phase == COLLECT && heap->soft_references ? CLEAR_SOFT : COMPACT;
            break;
        case COMPACT:
            phase = GROW;
            if (!room_after_collection(heap, size))
                continue;
            compact(heap);
            break;
        case GROW: {
            phase = EXHAUSTED;
            JbedAddress raw;
            uint32_t bytes;
            if (!heap->services.reserve_chunk ||
                !heap->services.reserve_chunk(heap->services.context, size + CHUNK_ALLOCATION_OVERHEAD,
                                              &raw, &bytes) ||
                !jbed_vm_heap_add_chunk(heap, raw, bytes, true))
                continue;
            break;
        }
        default:
            break;
        }
        heap->allocation_end = saved_end;
        if (room_after_collection(heap, size)) {
            JbedAddress result = jbed_vm_heap_try_alloc(heap, size);
            if (result || heap->fault)
                return result;
        }
    }
    ++heap->allocation_failures;
    heap->allocation_end = 0;
    return 0;
}

static JbedAddress allocate(JbedVmHeap *heap, uint32_t bytes)
{
    JbedAddress object = jbed_vm_heap_try_alloc(heap, bytes);
    return object || heap->fault ? object : retry_allocation(heap);
}

/* Memory.checkClassTagConsistency, 0xdf880. Array tags encode the element
 * shift in bits 0..1 and reference elements in bit 8. */
static bool valid_tag(JbedBuffer map, JbedAddress klass, bool array)
{
    if (!klass)
        return false;
    JbedAddress tag = jbed_vm_word(map, klass + CLASS_TAG);
    if (!tag || (tag & 3))
        return false;
    uint32_t kind = jbed_vm_word(map, tag - 4);
    if (!array)
        return kind == jbed_vm_word(map, klass + CLASS_SIZE) && jbed_vm_word(map, tag) == klass;
    JbedAddress component = jbed_vm_word(map, klass + CLASS_SUPER);
    if ((int32_t)kind >= 0 || !component)
        return false;
    if (kind & JBED_ARRAY_REFERENCES)
        return (kind & JBED_ARRAY_ELEMENT_SHIFT_MASK) == 2;
    return (1u << (kind & JBED_ARRAY_ELEMENT_SHIFT_MASK)) == jbed_vm_word(map, component + CLASS_SIZE);
}

static JbedAddress fail(JbedVmHeap *heap, JbedHeapFault reason)
{
    heap->fault = reason;
    return 0;
}

static void push_root(JbedVmHeap *heap, JbedVmHeapRoot *root, JbedAddress object)
{
    *root = (JbedVmHeapRoot){object, object, heap->temporary_roots};
    heap->temporary_roots = root;
}

static JbedAddress new_array(JbedVmHeap *heap, int32_t length, JbedAddress klass, bool kni)
{
    JbedBuffer map = heap->memory;
    heap->fault = JBED_HEAP_OK;
    if (heap->collecting)
        return fail(heap, JBED_HEAP_ALLOCATION_DISABLED);
    if (length < 0) {
        if (kni)
            return 0;
        heap->allocation_end = 0;
        return fail(heap, JBED_HEAP_NEGATIVE_ARRAY);
    }
    if (!valid_tag(map, klass, true))
        return fail(heap, JBED_HEAP_BAD_CLASS_TAG);
    JbedAddress tag = jbed_vm_word(map, klass + CLASS_TAG);
    uint32_t shift = jbed_vm_word(map, tag - 4) & JBED_ARRAY_ELEMENT_SHIFT_MASK;
    if ((uint32_t)length >= ((uint32_t)MAX_ARRAY_PAYLOAD_BYTES >> shift)) {
        if (kni)
            return 0;
        heap->allocation_end = 0;
        return fail(heap, JBED_HEAP_OUT_OF_MEMORY);
    }
    JbedAddress object = allocate(heap, DATA + ((uint32_t)length << shift));
    if (!object)
        return heap->fault || kni ? 0 : fail(heap, JBED_HEAP_OUT_OF_MEMORY);
    jbed_vm_put_word(map, object + TAG, jbed_vm_word(map, klass + CLASS_TAG));
    jbed_vm_put_word(map, object + LENGTH, (uint32_t)length);
    return object;
}

/* Memory.nextFinalizedOffset, 0xdf81c. The link belongs to the first
 * finalizable superclass, so subclasses can append their own instance data. */
JbedAddress jbed_vm_finalizer_link(const JbedVmHeap *heap, JbedAddress object)
{
    JbedBuffer map = heap->memory;
    JbedAddress tag = jbed_vm_word(map, object + TAG);
    JbedAddress klass = jbed_vm_word(map, tag);
    JbedAddress super = jbed_vm_word(map, klass + CLASS_SUPER);
    while (jbed_vm_word(map, super + CLASS_FLAGS) & JBED_CLASS_FINALIZED) {
        klass = super;
        super = jbed_vm_word(map, klass + CLASS_SUPER);
    }
    return object + jbed_vm_word(map, klass + CLASS_SIZE) - 4;
}

static JbedAddress new_object(JbedVmHeap *heap, JbedAddress klass, bool kni)
{
    JbedBuffer map = heap->memory;
    heap->fault = JBED_HEAP_OK;
    if (heap->collecting)
        return fail(heap, JBED_HEAP_ALLOCATION_DISABLED);
    if (!klass)
        return fail(heap, JBED_HEAP_BAD_CLASS_TAG);
    if (!kni && (jbed_vm_word(map, klass + CLASS_FLAGS) & (JBED_ACC_ABSTRACT | JBED_ACC_INTERFACE))) {
        heap->allocation_end = 0;
        return fail(heap, JBED_HEAP_INSTANTIATION_ERROR);
    }
    if (!valid_tag(map, klass, false))
        return fail(heap, JBED_HEAP_BAD_CLASS_TAG);
    JbedAddress object = allocate(heap, jbed_vm_word(map, klass + CLASS_SIZE));
    if (!object)
        return heap->fault || kni ? 0 : fail(heap, JBED_HEAP_OUT_OF_MEMORY);
    jbed_vm_put_word(map, object + TAG, jbed_vm_word(map, klass + CLASS_TAG));
    if (kni) {
        jbed_vm_put_word(map, object + LENGTH, 0);
        return object;
    }
    if (jbed_vm_word(map, klass + CLASS_FLAGS) & JBED_CLASS_TRACE) {
        if (!heap->services.fill_trace)
            return fail(heap, JBED_HEAP_MISSING_TRACE);
        JbedVmHeapRoot throwable;
        push_root(heap, &throwable, object);
        heap->services.fill_trace(heap->services.context, &throwable.value);
        object = throwable.value;
        heap->temporary_roots = throwable.previous;
    }
    if (jbed_vm_word(map, klass + CLASS_FLAGS) & JBED_CLASS_FINALIZED) {
        JbedAddress link = jbed_vm_finalizer_link(heap, object);
        if (heap->current_isolate) {
            JbedAddress head = heap->current_isolate + JBED_ISOLATE_FINALIZERS;
            jbed_vm_put_word(map, link, jbed_vm_word(map, head));
            jbed_vm_put_word(map, head, object);
        } else {
            jbed_vm_put_word(map, link, heap->finalized);
            heap->finalized = object;
        }
    }
    return object;
}

/* Memory.newObject/newArray 0xdf948/0xdfa24 and xKniNewObject/xKniNewArray
 * 0xdfaec/0xdfb38. KNI skips Throwable traces and finalizer registration. */
JbedAddress jbed_vm_new_object(JbedVmHeap *heap, JbedAddress klass)
{
    return new_object(heap, klass, false);
}

JbedAddress jbed_vm_new_array(JbedVmHeap *heap, int32_t length, JbedAddress klass)
{
    return new_array(heap, length, klass, false);
}

JbedAddress jbed_vm_kni_new_object(JbedVmHeap *heap, JbedAddress klass)
{
    return new_object(heap, klass, true);
}

JbedAddress jbed_vm_kni_new_array(JbedVmHeap *heap, int32_t length, JbedAddress klass)
{
    return new_array(heap, length, klass, true);
}

/* Memory.resize, 0xdfc34. Shrinking creates an unreferenced array in the
 * released span; the next sweep reclaims it through ordinary object walking. */
JbedAddress jbed_vm_resize_array(JbedVmHeap *heap, JbedAddress array, uint32_t length)
{
    heap->fault = JBED_HEAP_OK;
    if (!array)
        return 0;
    JbedBuffer map = heap->memory;
    JbedAddress tag = jbed_vm_word(map, array + TAG);
    JbedAddress klass = jbed_vm_word(map, tag);
    if (!(jbed_vm_word(map, klass + CLASS_FLAGS) & JBED_CLASS_ARRAY))
        return array;
    JbedAddress component = jbed_vm_word(map, klass + CLASS_SUPER);
    uint32_t width = jbed_vm_word(map, component + CLASS_SIZE);
    if ((uint64_t)length * width >= (uint32_t)MAX_ARRAY_PAYLOAD_BYTES)
        return fail(heap, JBED_HEAP_OUT_OF_MEMORY);
    uint32_t old_bytes = align_block(DATA + jbed_vm_word(map, array + LENGTH) * width);
    uint32_t bytes = align_block(DATA + length * width);
    if (bytes > old_bytes)
        return jbed_vm_new_array(heap, (int32_t)length, klass);
    if (bytes < old_bytes) {
        JbedAddress tail = array + bytes;
        JbedAddress table = jbed_vm_heap_find_table(heap, tail);
        assert(table && width);
        jbed_vm_put_word(map, tail + TAG, tag);
        jbed_vm_put_word(map, tail + FLAGS, 0);
        jbed_vm_put_word(map, tail + LINK, 0);
        jbed_vm_put_word(map, tail + LENGTH, (old_bytes - bytes - DATA) / width);
        record_object(map, table, tail, true);
    }
    jbed_vm_put_word(map, array + LENGTH, length);
    return array;
}

/* Memory.structCopy, 0xdfbac. Every row is shaped from element zero of the
 * prototype, even when its later elements have other sizes. */
JbedAddress jbed_vm_struct_copy(JbedVmHeap *heap, JbedAddress prototype)
{
    if (!prototype)
        return fail(heap, JBED_HEAP_NULL_POINTER);
    JbedBuffer map = heap->memory;
    JbedVmHeapRoot source, copy;
    push_root(heap, &source, prototype);
    JbedAddress tag = jbed_vm_word(map, prototype + TAG);
    JbedAddress klass = jbed_vm_word(map, tag);
    int32_t length = (int32_t)jbed_vm_word(map, prototype + LENGTH);
    JbedAddress result = jbed_vm_new_array(heap, length, klass);
    push_root(heap, &copy, result);
    if (result && length > 0 && (jbed_vm_word(map, tag - 4) & JBED_ARRAY_REFERENCES) &&
        jbed_vm_word(map, source.value + DATA)) {
        for (int32_t i = 0; i < length; ++i) {
            JbedAddress child = jbed_vm_struct_copy(heap, jbed_vm_word(map, source.value + DATA));
            if (!child) {
                copy.value = 0;
                break;
            }
            jbed_vm_put_word(map, copy.value + DATA + 4u * (uint32_t)i, child);
        }
    }
    heap->temporary_roots = source.previous;
    return copy.value;
}

/* Memory.newArrayN, 0xdfc00. The first element is the supplied array itself. */
JbedAddress jbed_vm_new_array_n(JbedVmHeap *heap, int32_t length, JbedAddress prototype,
                               JbedAddress klass)
{
    JbedBuffer map = heap->memory;
    JbedVmHeapRoot first, array;
    push_root(heap, &first, prototype);
    JbedAddress result = jbed_vm_new_array(heap, length, klass);
    push_root(heap, &array, result);
    if (result && length > 0) {
        jbed_vm_put_word(map, result + DATA, first.value);
        for (int32_t i = 1; i < length; ++i) {
            JbedAddress child = jbed_vm_struct_copy(heap, first.value);
            if (!child) {
                array.value = 0;
                break;
            }
            jbed_vm_put_word(map, array.value + DATA + 4u * (uint32_t)i, child);
        }
    }
    heap->temporary_roots = first.previous;
    return array.value;
}

/* Memory.nextAllocateLocked 0xdf7c8, lock 0xdf2e8, unlock 0xdf334. */
bool jbed_vm_next_allocate_locked(JbedVmHeap *heap)
{
    if (heap->allocation_end) {
        heap->fault = JBED_HEAP_PIN_ALREADY_PENDING;
        return false;
    }
    heap->fault = JBED_HEAP_OK;
    heap->allocation_end = 1;
    return true;
}

static bool update_lock(JbedVmHeap *heap, JbedAddress object, bool lock)
{
    heap->fault = JBED_HEAP_OK;
    if (!object)
        return true;
    JbedBuffer map = heap->memory;
    uint32_t flags = jbed_vm_word(map, object + FLAGS);
    if (flags & JBED_OBJECT_PINNED)
        return true;
    uint32_t count = flags & JBED_OBJECT_LOCK_MASK;
    if (count == (lock ? JBED_OBJECT_LOCK_MASK : 0u)) {
        heap->fault = JBED_HEAP_LOCK_COUNT;
        return false;
    }
    jbed_vm_put_word(map, object + FLAGS,
                     lock ? flags + JBED_OBJECT_LOCK_UNIT : flags - JBED_OBJECT_LOCK_UNIT);
    return true;
}

bool jbed_vm_lock_object(JbedVmHeap *heap, JbedAddress object)
{
    return update_lock(heap, object, true);
}

bool jbed_vm_unlock_object(JbedVmHeap *heap, JbedAddress object)
{
    return update_lock(heap, object, false);
}
