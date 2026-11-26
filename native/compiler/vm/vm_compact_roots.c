#include "vm_compactor.h"
#include "vm_words.h"

/* visitStackReference, 0xea386. A tagged saved register pins its object.
 * References threaded earlier to that object are unwound immediately. */
static void visit_stack(void *context, JbedAddress slot)
{
    JbedVmCompactor *c = context;
    if (!(slot & JBED_ROOT_PINNED)) {
        jbed_vm_thread_slot(c, slot);
        return;
    }
    JbedAddress object = jbed_vm_word(c->memory, slot & ~(uint32_t)JBED_ROOT_PINNED);
    if (!object)
        return;
    uint32_t link = jbed_vm_word(c->memory, object + 4);
    while (!(link & JBED_OBJECT_MARKED)) {
        uint32_t next = jbed_vm_word(c->memory, link);
        jbed_vm_put_word(c->memory, link, object);
        link = next;
    }
    jbed_vm_put_word(c->memory, object + 4, link | JBED_OBJECT_PINNED);
    ++c->stack_locked;
}

/* visitTempRootInternalPointer, 0xea3cc. Preserve the displacement from the
 * containing object while the native frame's owner reference is threaded. */
static void visit_interior(void *context, JbedAddress slot)
{
    JbedVmCompactor *c = context;
    JbedAddress pointer_slot = jbed_vm_word(c->memory, slot);
    JbedAddress base = jbed_vm_word(c->memory, slot + 4);
    jbed_vm_put_word(c->memory, pointer_slot, jbed_vm_word(c->memory, pointer_slot) - base);
    jbed_vm_thread_slot(c, slot + 4);
}

JbedVmRootVisitor jbed_vm_compact_root_visitor(JbedVmCompactor *c)
{
    return (JbedVmRootVisitor){c, visit_stack, visit_interior};
}

/* ThreadFinalizedList / ThreadAsyncFinalizedQueues, 0xea8f4 / 0xea94c.
 * The VM-wide finalizer head may live in the host-side heap structure.
 * For that head MoveHeap updates the mirror at the same time as guest roots. */
static void thread_finalized_list(JbedVmCompactor *c, JbedAddress slot, JbedAddress object)
{
    while (object) {
        if (slot)
            jbed_vm_thread_field(c, slot);
        slot = jbed_vm_finalizer_link(c->collector->marker.heap, object);
        object = jbed_vm_word(c->memory, slot);
    }
}

static void thread_async_queues(JbedVmCompactor *c, JbedAddress slot)
{
    JbedAddress queue, pending;
    while ((queue = jbed_vm_word(c->memory, slot)) != 0) {
        jbed_vm_thread_field(c, slot);
        for (JbedAddress entry = queue + 16; (pending = jbed_vm_word(c->memory, entry)) != 0;
             entry = pending + 12)
            jbed_vm_thread_field(c, entry);
        slot = queue + 12;
    }
}

static void thread_range(void *context, JbedAddress first, JbedAddress end)
{
    JbedVmCompactor *c = context;
    for (JbedAddress slot = first; slot < end; slot += 4)
        jbed_vm_thread_field(c, slot);
}

/* runCompactor, 0xea698: ThreadIsolates, ThreadFinalizeds, ThreadAsyncFinalizeds,
 * then ThreadGlobals (isolate statics first, absolute VM statics last). */
void jbed_vm_compact_roots(JbedVmCompactor *c)
{
    JbedVmCollector *gc = c->collector;
    JbedVmHeap *heap = gc->marker.heap;
    JbedAddress isolates = gc->isolates;
    JbedVmRootVisitor visitor = jbed_vm_compact_root_visitor(c);
    jbed_vm_visit_isolate_stacks(heap, isolates, &gc->stacks, &visitor, &visitor);
    if (gc->visit_roots)
        gc->visit_roots(gc->context, &visitor, &visitor);

    if (c->finalized_slot)
        jbed_vm_put_word(c->memory, c->finalized_slot, heap->finalized);
    thread_finalized_list(c, c->finalized_slot, heap->finalized);
    uint32_t count = jbed_vm_word(c->memory, isolates + 12);
    for (uint32_t i = 0; i < count; ++i) {
        JbedAddress isolate = jbed_vm_word(c->memory, isolates + 16 + 4 * i);
        if (isolate)
            thread_finalized_list(c, isolate + JBED_ISOLATE_FINALIZERS,
                                  jbed_vm_word(c->memory, isolate + JBED_ISOLATE_FINALIZERS));
    }
    for (uint32_t i = 0; i < count; ++i) {
        JbedAddress isolate = jbed_vm_word(c->memory, isolates + 16 + 4 * i);
        if (isolate)
            thread_async_queues(c, isolate + JBED_ISOLATE_FINALIZER_QUEUES);
    }
    jbed_vm_visit_isolate_ranges(c->memory, isolates, gc->static_pointer_offset,
                                 gc->static_pointer_size, c, thread_range);
    thread_range(c, gc->global_start, gc->global_end);
}

/* C represents these scheduler globals as target addresses in host records.
 * Keep them in step with the guest's absolute root slots during MoveHeap. */
void jbed_vm_compact_relocate_roots(JbedVmCompactor *c, JbedAddress source, JbedAddress destination)
{
    JbedVmCollector *gc = c->collector;
    JbedVmHeap *heap = gc->marker.heap;
    if (gc->isolates == source)
        gc->isolates = destination;
    if (heap->current_isolate == source)
        heap->current_isolate = destination;
    if (gc->stacks.vm_dummy == source)
        gc->stacks.vm_dummy = destination;
    if (heap->finalized == source)
        heap->finalized = destination;
}

/* FixThreadInternalPointers / FixInternalPointers, 0xea708 / 0xea778. The
 * owner slots now contain relocated object addresses. */
void jbed_vm_compact_fix_interior(JbedVmCompactor *c)
{
    const JbedVmNativeFrames *native = c->collector->stacks.native_frames;
    if (!native || !native->base)
        return;
    JbedAddress frame = native->frame;
    while ((int32_t)(frame - native->base) > 4) {
        JbedAddress end = frame - 8;
        frame = jbed_vm_word(c->memory, end);
        if (!frame)
            frame = native->base;
        for (JbedAddress slot = frame + JBED_NATIVE_FRAME_ROOTS; (int32_t)slot < (int32_t)end; slot += 4) {
            if (jbed_vm_word(c->memory, slot) == JBED_NATIVE_ROOT_INTERIOR) {
                JbedAddress pointer_slot = jbed_vm_word(c->memory, slot + 4);
                JbedAddress base = jbed_vm_word(c->memory, slot + 8);
                jbed_vm_put_word(c->memory, pointer_slot,
                                 jbed_vm_word(c->memory, pointer_slot) + base);
                slot += 8;
            }
        }
    }
}
