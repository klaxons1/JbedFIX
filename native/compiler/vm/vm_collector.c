#include "vm_collector.h"
#include "vm_words.h"

enum {
    ARRAY_LENGTH = 12,
    ARRAY_DATA = 16,
    NEXT_QUEUE = 12,
    PENDING = 16,
    APPENDED = 20,
    HEAD = 24,
    QUEUED = 32
};

/* Collector.ProcessAsyncFinalizedQueues (0xe9306), ProcessAsyncFinalizeds
 * (0xe93e6), FinalizedQueue.enqueueUnmarkedObjects (0xfbe80). In this ROM
 * checkFinListConsistency at 0xfbf32 halts on the first nonempty finList. */
static void process_queues(JbedVmCollector *gc)
{
    JbedBuffer map = gc->marker.heap->memory;
    uint32_t count = jbed_vm_word(map, gc->isolates + ARRAY_LENGTH);
    for (uint32_t i = 0; i < count; ++i) {
        JbedAddress isolate = jbed_vm_word(map, gc->isolates + ARRAY_DATA + 4 * i);
        if (!isolate)
            continue;
        JbedAddress link = isolate + JBED_ISOLATE_FINALIZER_QUEUES;
        JbedAddress queue;
        while ((queue = jbed_vm_word(map, link)) != 0) {
            if (jbed_vm_word(map, queue + 4) & JBED_OBJECT_MARKED) {
                JbedAddress pending = jbed_vm_word(map, queue + PENDING);
                if (pending)
                    jbed_halt(gc->marker.runtime, (int32_t)pending,
                              "Non-AsyncFinalized object on async finalizer queue");
                jbed_vm_put_word(map, queue + APPENDED, jbed_vm_word(map, queue + HEAD));
                link = queue + NEXT_QUEUE;
            } else {
                if (jbed_vm_word(map, queue + QUEUED) || jbed_vm_word(map, queue + PENDING))
                    jbed_halt(gc->marker.runtime, (int32_t)queue,
                              "FinalizedQueue still in use but not referenced anymore");
                jbed_vm_put_word(map, link, jbed_vm_word(map, queue + NEXT_QUEUE));
            }
        }
    }
}

/* A finalizer can change its own link. Read it after each managed call. */
static JbedAddress finalize_unmarked(JbedVmCollector *gc, JbedAddress object)
{
    JbedVmHeap *heap = gc->marker.heap;
    while (object && !(jbed_vm_word(heap->memory, object + 4) & JBED_OBJECT_MARKED)) {
        if (!gc->invoke_finalizer)
            jbed_raise_internal(gc->marker.runtime, "Missing managed finalizer entry");
        gc->invoke_finalizer(gc->context, heap->current_isolate, object);
        object = jbed_vm_word(heap->memory, jbed_vm_finalizer_link(heap, object));
    }
    return object;
}

/* Collector.finalizeList, 0xe9738. Keep runs of marked objects linked and
 * splice around each unmarked run after its finalizers have completed. */
static JbedAddress finalize_list(JbedVmCollector *gc, JbedAddress head, JbedAddress tail)
{
    JbedVmHeap *heap = gc->marker.heap;
    JbedBuffer map = heap->memory;
    JbedAddress first = finalize_unmarked(gc, head);
    if (!first)
        return tail;
    JbedAddress last = first;
    for (;;) {
        JbedAddress link = jbed_vm_finalizer_link(heap, last);
        JbedAddress next = jbed_vm_word(map, link);
        if (next && (jbed_vm_word(map, next + 4) & JBED_OBJECT_MARKED)) {
            last = next;
            continue;
        }
        if (next) {
            next = finalize_unmarked(gc, next);
            link = jbed_vm_finalizer_link(heap, last);
        }
        jbed_vm_put_word(map, link, next ? next : tail);
        if (!next)
            break;
        last = next;
    }
    return first;
}

/* Collector.Finalize, 0xe97ec. Retiring isolates move their surviving
 * finalizers to the VM list; live isolates keep their own list. */
static void finalize(JbedVmCollector *gc)
{
    JbedVmHeap *heap = gc->marker.heap;
    JbedBuffer map = heap->memory;
    JbedAddress saved = heap->current_isolate;
    gc->finalizing = true;
    gc->finalizing_isolate = -1;
    heap->current_isolate = 0;
    heap->finalized = finalize_list(gc, heap->finalized, 0);
    for (uint32_t i = 0; i < jbed_vm_word(map, gc->isolates + ARRAY_LENGTH); ++i) {
        JbedAddress isolate = jbed_vm_word(map, gc->isolates + ARRAY_DATA + 4 * i);
        if (!isolate)
            continue;
        JbedAddress head = jbed_vm_word(map, isolate + JBED_ISOLATE_FINALIZERS);
        if (!head)
            continue;
        heap->current_isolate = isolate;
        gc->finalizing_isolate = (int32_t)jbed_vm_word(map, isolate + JBED_ISOLATE_ID);
        if ((int32_t)jbed_vm_word(map, isolate + JBED_ISOLATE_STATE) >= JBED_ISOLATE_STATE_EXITED) {
            heap->finalized = finalize_list(gc, head, heap->finalized);
            jbed_vm_put_word(map, isolate + JBED_ISOLATE_FINALIZERS, 0);
        } else {
            jbed_vm_put_word(map, isolate + JBED_ISOLATE_FINALIZERS, finalize_list(gc, head, 0));
        }
    }
    heap->current_isolate = saved;
    gc->finalizing_isolate = -1;
    gc->finalizing = false;
}

void jbed_vm_collector_shutdown(JbedVmCollector *gc)
{
    gc->marker.heap->collecting = true;
    finalize(gc);
    gc->marker.heap->collecting = false;
}

/* Collector.run, 0xe9c54. The mark bit must remain live through soft-reference
 * processing and both finalizer passes. Sweep clears it as it rebuilds the heap. */
void jbed_vm_collect(JbedVmCollector *gc, bool clear_soft_references)
{
    JbedVmMarker *marker = &gc->marker;
    JbedVmHeap *heap = marker->heap;
    if (!gc->isolates)
        jbed_raise_internal(marker->runtime, "Missing isolate list for collection");
    heap->collecting = true;
    ++gc->collections;
    jbed_vm_hide_isolate_references(marker, gc->isolates);
    jbed_vm_mark_globals(marker, gc->global_start, gc->global_end, gc->isolates,
                         gc->static_pointer_offset, gc->static_pointer_size);
    jbed_vm_mark_isolates(marker, gc->isolates, &gc->stacks);
    if (gc->visit_roots) {
        JbedVmMarker global_marker = *marker;
        global_marker.marking_vm_globals = true;
        JbedVmRootVisitor local = jbed_vm_mark_root_visitor(marker);
        JbedVmRootVisitor global = jbed_vm_mark_root_visitor(&global_marker);
        gc->visit_roots(gc->context, &local, &global);
    }
    for (JbedVmHeapRoot *root = heap->temporary_roots; root; root = root->previous)
        if (root->value)
            jbed_vm_mark_pointer(marker, root->value);
    jbed_vm_process_isolate_references(marker, gc->isolates, clear_soft_references);
    process_queues(gc);
    finalize(gc);
    jbed_vm_heap_sweep(heap);
    heap->collecting = false;
    gc->default_ttl = 2; /* VmConfigBase.getDefaultTTL, 0x143f12. */
    gc->checkpoint_requested = true;
}
