#include "vm_mark.h"
#include "vm_words.h"
#include "vm_scheduler.h"

enum { HASH_FLAGS = 4, SYNCHRONIZER = 8, ARRAY_LENGTH = 12, ARRAY_DATA = 16 };
enum { FIELD_LINK, ARRAY_LINK, SYNC_LINK, CLASS_LINK, LINK_KIND_MASK = 3 };

static bool marked(JbedBuffer memory, JbedAddress object)
{
    return (jbed_vm_word(memory, object + HASH_FLAGS) & JBED_OBJECT_MARKED) != 0;
}

/* MarkDescendants, 0xe9550. The low two bits of a backlink select the place
 * where the previous link was saved. A class tag's pointer map runs backward
 * from tag-22; its final signed delta restores the original tag. */
void jbed_vm_mark_descendants(JbedVmMarker *marker, JbedAddress object)
{
    enum { DESCEND, SCAN_FIELDS, SCAN_ELEMENTS, ASCEND } phase = DESCEND;
    JbedBuffer memory = marker->heap->memory;
    JbedAddress link = 0, tag = 0;
    for (;;) {
        switch (phase) {
        case DESCEND: {
            tag = jbed_vm_word(memory, object);
            jbed_vm_put_word(memory, object + HASH_FLAGS,
                             jbed_vm_word(memory, object + HASH_FLAGS) | JBED_OBJECT_MARKED);
            if (tag == object + ARRAY_DATA)
                jbed_halt(marker->runtime, (int32_t)object, "Found reference to free block");
            JbedAddress klass = jbed_vm_word(memory, tag);
            if (!klass)
                jbed_halt(marker->runtime, 0, "Class ptr is null");
            if (marker->marking_vm_globals && (jbed_vm_word(memory, klass + 12) & JBED_CLASS_DYNAMIC))
                jbed_halt(marker->runtime, 0, "Abs statics referencing MIDlet object");
            if (!marked(memory, klass)) {
                jbed_vm_put_word(memory, object, link);
                link = object | CLASS_LINK;
                object = klass;
                break;
            }
            JbedAddress sync = jbed_vm_word(memory, object + SYNCHRONIZER);
            if (sync && !marked(memory, sync)) {
                jbed_vm_put_word(memory, object + SYNCHRONIZER, link);
                link = object | SYNC_LINK;
                object = sync;
                break;
            }
            uint32_t layout = jbed_vm_word(memory, tag - 4);
            if ((int32_t)layout < 0 && (layout & JBED_ARRAY_REFERENCES)) {
                uint32_t length = jbed_vm_word(memory, object + ARRAY_LENGTH);
                jbed_vm_put_word(memory, object + ARRAY_LENGTH, (length << 1) | 1);
                object += ARRAY_LENGTH + length * 4;
                phase = SCAN_ELEMENTS;
            } else {
                phase = SCAN_FIELDS;
            }
            break;
        }
        case SCAN_FIELDS: {
            int16_t offset;
            for (; (offset = (int16_t)jbed_vm_half(memory, tag - JBED_TAG_POINTER_MAP_OFFSET)) > 0; tag -= 2) {
                JbedAddress slot = object + (uint32_t)offset;
                JbedAddress child = jbed_vm_word(memory, slot);
                if (child && !marked(memory, child)) {
                    jbed_vm_put_word(memory, object, tag);
                    jbed_vm_put_word(memory, slot, link);
                    link = object | FIELD_LINK;
                    object = child;
                    phase = DESCEND;
                    break;
                }
            }
            if (offset <= 0) {
                jbed_vm_put_word(memory, object, tag - (uint32_t)offset);
                phase = ASCEND;
            }
            break;
        }
        case SCAN_ELEMENTS: {
            /* The tagged length word terminates the backwards element scan. */
            JbedAddress child = jbed_vm_word(memory, object);
            while (!(child & 1) && (!child || marked(memory, child))) {
                object -= 4;
                child = jbed_vm_word(memory, object);
            }
            if (child & 1) {
                jbed_vm_put_word(memory, object, child >> 1);
                object -= ARRAY_LENGTH;
                phase = ASCEND;
            } else {
                jbed_vm_put_word(memory, object, link);
                link = object | ARRAY_LINK;
                object = child;
                phase = DESCEND;
            }
            break;
        }
        case ASCEND: {
            if (!link)
                return;
            JbedAddress parent = link & ~(uint32_t)LINK_KIND_MASK;
            switch (link & LINK_KIND_MASK) {
            case FIELD_LINK: {
                tag = jbed_vm_word(memory, parent);
                JbedAddress slot = parent + (uint32_t)(int16_t)jbed_vm_half(
                    memory, tag - JBED_TAG_POINTER_MAP_OFFSET);
                link = jbed_vm_word(memory, slot);
                jbed_vm_put_word(memory, slot, object);
                tag -= 2;
                object = parent;
                phase = SCAN_FIELDS;
                break;
            }
            case ARRAY_LINK:
                link = jbed_vm_word(memory, parent);
                jbed_vm_put_word(memory, parent, object);
                object = parent - 4;
                phase = SCAN_ELEMENTS;
                break;
            case SYNC_LINK:
                link = jbed_vm_word(memory, parent + SYNCHRONIZER);
                jbed_vm_put_word(memory, parent + SYNCHRONIZER, object);
                object = parent;
                phase = DESCEND;
                break;
            case CLASS_LINK:
                link = jbed_vm_word(memory, parent);
                jbed_vm_put_word(memory, parent, jbed_vm_word(memory, object + 36));
                object = parent;
                phase = DESCEND;
                break;
            }
            break;
        }
        }
    }
}

/* markPointer, 0xe91aa. Precise stack references inside a heap chunk must
 * address its allocated 32-byte block boundary. ROM references bypass this
 * bitmap. */
void jbed_vm_mark_pointer(JbedVmMarker *marker, JbedAddress object)
{
    JbedVmHeap *heap = marker->heap;
    JbedBuffer memory = heap->memory;
    if (object >= heap->heap_start && object < heap->heap_end &&
        ((object & 3) || !marked(memory, object))) {
        JbedAddress table = jbed_vm_heap_find_table(heap, object);
        if (table) {
            uint32_t block = (object - table) >> JBED_HEAP_BLOCK_SHIFT;
            if (object & JBED_HEAP_BLOCK_MASK)
                jbed_halt(marker->runtime, (int32_t)object, "no heap object, misaligned");
            uint32_t bits = jbed_vm_word(memory, table + ARRAY_DATA + (block >> 5) * 4);
            if (!(bits & (1u << (block & 31))))
                jbed_halt(marker->runtime, (int32_t)object, "no heap object");
        }
    }
    if (!marked(memory, object))
        jbed_vm_mark_descendants(marker, object);
}

/* visitStackReference / visitTempRootInternalPointer, 0xe9230 / 0xe924e.
 * The second word of an interior-root pair holds the containing object. */
void jbed_vm_mark_stack_reference(JbedVmMarker *marker, JbedAddress slot)
{
    JbedAddress object = jbed_vm_word(marker->heap->memory, slot & ~(uint32_t)JBED_ROOT_PINNED);
    if (object)
        jbed_vm_mark_pointer(marker, object);
}

void jbed_vm_mark_internal_pointer(JbedVmMarker *marker, JbedAddress slot)
{
    jbed_vm_mark_stack_reference(marker, slot + 4);
}

void jbed_vm_mark_range(JbedVmMarker *marker, JbedAddress start, JbedAddress end)
{
    JbedBuffer memory = marker->heap->memory;
    for (JbedAddress slot = start; slot < end; slot += 4) {
        JbedAddress object = jbed_vm_word(memory, slot);
        if (object && !marked(memory, object))
            jbed_vm_mark_descendants(marker, object);
    }
}

/* MarkGlobals, 0xe94ac. Isolate.ptrRanges is an int[] of start/end byte
 * offsets into the isolate's statics. Earlier bundles share the VM's range. */
void jbed_vm_visit_isolate_ranges(JbedBuffer memory, JbedAddress isolates, uint32_t default_offset,
                                  uint32_t default_size, void *context,
                                  void (*range)(void *, JbedAddress, JbedAddress))
{
    uint32_t count = jbed_vm_word(memory, isolates + ARRAY_LENGTH);
    for (uint32_t i = 0; i < count; ++i) {
        JbedAddress isolate = jbed_vm_word(memory, isolates + ARRAY_DATA + i * 4);
        if (!isolate ||
            (int32_t)jbed_vm_word(memory, isolate + JBED_ISOLATE_STATE) >= JBED_ISOLATE_STATE_EXITED)
            continue;
        JbedAddress statics = jbed_vm_word(memory, isolate + JBED_ISOLATE_STATICS);
        if (!statics)
            continue;
        JbedAddress base = statics + ARRAY_DATA;
        JbedAddress ranges = jbed_vm_word(memory, isolate + JBED_ISOLATE_POINTER_RANGES);
        if (!ranges) {
            range(context, base + default_offset, base + default_offset + default_size);
            continue;
        }
        uint32_t words = jbed_vm_word(memory, ranges + ARRAY_LENGTH);
        for (uint32_t j = 0; j < words; j += 2) {
            JbedAddress pair = ranges + ARRAY_DATA + j * 4;
            range(context, base + jbed_vm_word(memory, pair),
                  base + jbed_vm_word(memory, pair + 4));
        }
    }
}

static void mark_range(void *context, JbedAddress start, JbedAddress end)
{
    jbed_vm_mark_range(context, start, end);
}

void jbed_vm_mark_globals(JbedVmMarker *marker, JbedAddress start, JbedAddress end,
                          JbedAddress isolates, uint32_t default_offset, uint32_t default_size)
{
    marker->marking_vm_globals = true;
    jbed_vm_mark_range(marker, start, end);
    marker->marking_vm_globals = false;
    jbed_vm_visit_isolate_ranges(marker->heap->memory, isolates, default_offset, default_size,
                                 marker, mark_range);
}

/* MarkLocals / MarkIsolates, 0xe9268..0xe92e8 / 0xe9424. Isolate.switchTo
 * changes the statics base; the scheduler's current isolate remains global. */
void jbed_vm_visit_isolate_stacks(const JbedVmHeap *heap, JbedAddress isolates,
                                  const JbedVmMarkStacks *stacks, const JbedVmRootVisitor *visitor,
                                  const JbedVmRootVisitor *dummy_visitor)
{
    if (stacks->stack_provider) {
        stacks->stack_provider(stacks->provider_context, visitor, dummy_visitor);
        return;
    }
    JbedBuffer memory = heap->memory;
    bool in_isolate = heap->current_isolate &&
                      *jbed_vm_at(memory, heap->current_isolate + JBED_ISOLATE_ACTIVE);
    uint32_t count = jbed_vm_word(memory, isolates + ARRAY_LENGTH);
    for (uint32_t i = 0; i < count; ++i) {
        JbedAddress isolate = jbed_vm_word(memory, isolates + ARRAY_DATA + 4 * i);
        if (!isolate)
            continue;
        uint32_t state = jbed_vm_word(memory, isolate + JBED_ISOLATE_STATE);
        if (state == JBED_ISOLATE_STATE_INITIALIZED || state == JBED_ISOLATE_STATE_EXITING) {
            JbedAddress statics = jbed_vm_word(memory, isolate + JBED_ISOLATE_STATICS) + ARRAY_DATA;
            JbedAddress active =
                in_isolate ? jbed_vm_word(memory, statics + CURRENT) : stacks->vm_dummy;
            jbed_vm_traverse_scheduled(stacks->maps,
                                       jbed_vm_word(memory, statics + SCHEDULED_THREADS), active,
                                       stacks->native_frames, visitor);
        }
    }
    JbedAddress active = stacks->vm_dummy, dummy = stacks->vm_dummy;
    if (in_isolate) {
        active = jbed_vm_word(memory, stacks->current_statics + CURRENT);
        dummy = jbed_vm_word(memory, stacks->current_statics + SCHEDULER_DUMMY);
    }
    jbed_vm_traverse_stack(stacks->maps, dummy, active, stacks->native_frames, dummy_visitor);
}

void jbed_vm_mark_isolates(JbedVmMarker *marker, JbedAddress isolates,
                           const JbedVmMarkStacks *stacks)
{
    JbedVmMarker global_marker = *marker;
    global_marker.marking_vm_globals = true;
    JbedVmRootVisitor visitor = jbed_vm_mark_root_visitor(marker);
    JbedVmRootVisitor dummy = jbed_vm_mark_root_visitor(&global_marker);
    jbed_vm_visit_isolate_stacks(marker->heap, isolates, stacks, &visitor, &dummy);
}

enum {
    REFERENCE_ROOT = 1512,
    HIDDEN_ROOT = 2320,
    REFERENT = 12,
    NEXT = 16,
    HIDDEN_REFERENT = 20,
    HIDDEN_NEXT = 24,
    TTL = 28
};

/* hideSpecialReferences, 0xe9a88. The hidden chain uses integer fields so its
 * referents and links are invisible to the class pointer map during marking. */
void jbed_vm_hide_special_references(JbedVmMarker *marker, JbedAddress statics)
{
    JbedBuffer memory = marker->heap->memory;
    JbedAddress node = jbed_vm_word(memory, statics + REFERENCE_ROOT);
    jbed_vm_put_word(memory, statics + REFERENCE_ROOT, 0);
    while (node && !jbed_vm_word(memory, node + REFERENT))
        node = jbed_vm_word(memory, node + NEXT);
    jbed_vm_put_word(memory, statics + HIDDEN_ROOT, node);
    if (!node)
        return;
    JbedAddress last = node;
    jbed_vm_put_word(memory, last + HIDDEN_REFERENT, jbed_vm_word(memory, last + REFERENT));
    jbed_vm_put_word(memory, last + REFERENT, 0);
    for (node = jbed_vm_word(memory, last + NEXT); node; node = jbed_vm_word(memory, node + NEXT)) {
        JbedAddress ref = jbed_vm_word(memory, node + REFERENT);
        if (ref) {
            jbed_vm_put_word(memory, node + HIDDEN_REFERENT, ref);
            jbed_vm_put_word(memory, node + REFERENT, 0);
            jbed_vm_put_word(memory, last + HIDDEN_NEXT, node);
            jbed_vm_put_word(memory, last + NEXT, 0);
            last = node;
        }
    }
    jbed_vm_put_word(memory, last + HIDDEN_NEXT, 0);
    jbed_vm_put_word(memory, last + NEXT, 0);
}

static bool live_referent(JbedVmMarker *marker, JbedAddress node)
{
    JbedBuffer memory = marker->heap->memory;
    JbedAddress ref = jbed_vm_word(memory, node + HIDDEN_REFERENT);
    if (!ref)
        jbed_raise(marker->runtime, &(JbedError){.kind = JBED_ERROR_NULL_POINTER});
    return marked(memory, node) && marked(memory, ref);
}

/* processReferences, 0xe9b5c. VmConfigBase.getTTLDecrementCount at 0x143f16
 * returns one in this build. Forced collection skips the entire retention pass.
 */
void jbed_vm_process_references(JbedVmMarker *marker, JbedAddress statics, bool clear_soft)
{
    JbedVmHeap *heap = marker->heap;
    JbedBuffer memory = heap->memory;
    JbedAddress head = jbed_vm_word(memory, statics + HIDDEN_ROOT);
    heap->soft_references = 0;
    if (!clear_soft) {
        for (JbedAddress node = head; node; node = jbed_vm_word(memory, node + HIDDEN_NEXT)) {
            JbedAddress ref = jbed_vm_word(memory, node + HIDDEN_REFERENT);
            int32_t ttl = (int32_t)jbed_vm_word(memory, node + TTL);
            if (marked(memory, node)) {
                if (!ref)
                    jbed_raise(marker->runtime, &(JbedError){.kind = JBED_ERROR_NULL_POINTER});
                if (marked(memory, ref) || ttl <= 0)
                    continue;
                jbed_vm_put_word(memory, node + TTL, (uint32_t)(ttl - 1));
                jbed_vm_mark_descendants(marker, ref);
                ++heap->soft_references;
            } else if (ttl > 0) {
                jbed_vm_put_word(memory, node + TTL, (uint32_t)(ttl - 1));
                jbed_vm_put_word(memory, node + REFERENT, ref);
            }
        }
    }
    head = jbed_vm_word(memory, statics + HIDDEN_ROOT);
    while (head && !live_referent(marker, head))
        head = jbed_vm_word(memory, head + HIDDEN_NEXT);
    jbed_vm_put_word(memory, statics + REFERENCE_ROOT, head);
    if (!head)
        return;
    jbed_vm_put_word(memory, head + REFERENT, jbed_vm_word(memory, head + HIDDEN_REFERENT));
    JbedAddress last = head;
    for (JbedAddress node = jbed_vm_word(memory, head + HIDDEN_NEXT); node;
         node = jbed_vm_word(memory, node + HIDDEN_NEXT)) {
        if (live_referent(marker, node)) {
            jbed_vm_put_word(memory, node + REFERENT, jbed_vm_word(memory, node + HIDDEN_REFERENT));
            jbed_vm_put_word(memory, last + NEXT, node);
            last = node;
        }
    }
}

/* hideIsolateSpecialReferences / processIsolateReferences, 0xe9a38 / 0xe9b08.
 * switchTo loads the statics array's payload address into r9. */
static void isolate_references(JbedVmMarker *marker, JbedAddress isolates, bool hide,
                               bool clear_soft)
{
    JbedBuffer memory = marker->heap->memory;
    uint32_t count = jbed_vm_word(memory, isolates + ARRAY_LENGTH);
    for (uint32_t i = 0; i < count; ++i) {
        JbedAddress isolate = jbed_vm_word(memory, isolates + ARRAY_DATA + i * 4);
        if (!isolate)
            continue;
        uint32_t state = jbed_vm_word(memory, isolate + JBED_ISOLATE_STATE);
        if (state == JBED_ISOLATE_STATE_INITIALIZED || state == JBED_ISOLATE_STATE_EXITING) {
            JbedAddress statics = jbed_vm_word(memory, isolate + JBED_ISOLATE_STATICS) + ARRAY_DATA;
            if (hide)
                jbed_vm_hide_special_references(marker, statics);
            else
                jbed_vm_process_references(marker, statics, clear_soft);
        }
    }
}

void jbed_vm_hide_isolate_references(JbedVmMarker *marker, JbedAddress isolates)
{
    isolate_references(marker, isolates, true, false);
}

void jbed_vm_process_isolate_references(JbedVmMarker *marker, JbedAddress isolates, bool clear_soft)
{
    isolate_references(marker, isolates, false, clear_soft);
}
