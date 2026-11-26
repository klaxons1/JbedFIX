#include "vm_stackmap.h"
#include "vm_mark.h"
#include "vm_scheduler.h"

#include <string.h>

struct JbedVmStackMapBlock {
    JbedAddress pc_base, pc_limit;
    uint32_t count, id;
    JbedAddress entries, long_maps;
    JbedVmStackMapBlock *next;
};

static uint32_t word(const JbedVmStackMaps *maps, JbedAddress address)
{
    return maps->memory.word(maps->memory.context, address);
}

void jbed_vm_stack_maps_init(JbedVmStackMaps *maps, JbedRuntime *runtime, JbedVmMemoryReader reader)
{
    *maps = (JbedVmStackMaps){.runtime = runtime, .memory = reader};
}

/* StackMapBlock.getMapId, 0xf3c58. ID zero belongs to the resident tables. */
uint32_t jbed_vm_stack_map_id(JbedVmStackMaps *maps)
{
    return ++maps->next_id;
}

/* StackMapBlock.add/init/insert, 0xf3b6c, 0xf38e8 and 0xf3bc6. */
void jbed_vm_stack_map_add(JbedVmStackMaps *maps, JbedAddress header, uint32_t id)
{
    header &= ~1u;
    if (header & 3u)
        jbed_halt(maps->runtime, 0, "addr misaligned");
    JbedVmStackMapBlock *b = jbed_alloc(maps->runtime, sizeof *b);
    b->pc_base = word(maps, header + JBED_STACK_MAP_HEADER_PC) & ~1u;
    b->pc_limit = b->pc_base + word(maps, header + JBED_STACK_MAP_HEADER_LENGTH);
    b->count = word(maps, header + JBED_STACK_MAP_HEADER_COUNT);
    b->entries = header + JBED_STACK_MAP_HEADER_BYTES;
    b->long_maps = b->entries + 4 * b->count;
    b->id = id;
    uint32_t capacity = word(maps, header + JBED_STACK_MAP_HEADER_CAPACITY);
    if (capacity > maps->capacity) {
        maps->bitmap = jbed_alloc(maps->runtime, (size_t)capacity * sizeof *maps->bitmap);
        maps->capacity = capacity;
    }
    maps->cached = false;
    JbedVmStackMapBlock **link = &maps->blocks;
    if (*link && (*link)->pc_base <= b->pc_base) {
        link = &(*link)->next;
        while (*link && (*link)->pc_base < b->pc_base)
            link = &(*link)->next;
    }
    b->next = *link;
    *link = b;
}

/* Collector.init, 0xe9e4c, and StackMapBlock.add(I), 0xf3ba0. */
void jbed_vm_stack_maps_add_resident(JbedVmStackMaps *maps, JbedAddress tables)
{
    if (tables == UINT32_MAX)
        return;
    uint32_t count = word(maps, tables);
    for (uint32_t i = 0; i < count; ++i) {
        JbedAddress header = word(maps, tables + 4 + 4 * i);
        uint32_t next;
        do {
            next = word(maps, header + JBED_STACK_MAP_HEADER_NEXT);
            jbed_vm_stack_map_add(maps, header, 0);
            header += next;
        } while (next);
    }
}

/* StackMapBlock.removeMapsById, 0xf3c18. */
void jbed_vm_stack_maps_remove(JbedVmStackMaps *maps, uint32_t id)
{
    if (!id)
        return;
    JbedVmStackMapBlock **link = &maps->blocks;
    while (*link) {
        if ((*link)->id == id)
            *link = (*link)->next;
        else
            link = &(*link)->next;
    }
    maps->cached = false;
}

static void xor_word(JbedVmStackMaps *m, uint32_t index, uint32_t bits)
{
    if (index >= m->capacity)
        jbed_raise(m->runtime, &(JbedError){.kind = JBED_ERROR_ARRAY_INDEX});
    m->bitmap[index] ^= bits;
    if (index > m->last_word)
        m->last_word = index;
}

/* StackMapBlock.find, 0xf3968. Compact deltas run backwards to the first
 * absolute descriptor. Each bitmap word holds 31 reference bits. */
static void decode(JbedVmStackMaps *m, const JbedVmStackMapBlock *b, JbedAddress pc)
{
    uint32_t offset = (pc - b->pc_base) >> 2;
    uint32_t entry = 0, limit = b->count;
    if (!limit)
        jbed_halt(m->runtime, 0, "numMaps <= 0");
    while (entry < limit) {
        uint32_t mid = entry + (limit - entry) / 2;
        uint32_t map_pc = word(m, b->entries + 4 * mid) & JBED_STACK_MAP_PC_MASK;
        if (map_pc == offset) {
            entry = mid;
            break;
        }
        if (map_pc > offset) {
            if (mid == entry)
                jbed_halt(m->runtime, 0, "diff > 0");
            limit = mid;
        } else {
            if (mid == entry)
                break;
            entry = mid;
        }
    }
    if (!m->capacity)
        jbed_raise(m->runtime, &(JbedError){.kind = JBED_ERROR_ARRAY_INDEX});
    memset(m->bitmap, 0, (size_t)(m->last_word + 1) * sizeof *m->bitmap);
    m->last_word = 0;
    for (;;) {
        uint32_t descriptor = word(m, b->entries + 4 * entry) >> JBED_STACK_MAP_DESCRIPTOR_SHIFT;
        if (descriptor & JBED_STACK_MAP_LONG) {
            JbedAddress addr = b->long_maps + 4 * (descriptor >> 1);
            uint32_t bits, i = 0;
            do {
                bits = word(m, addr);
                xor_word(m, i++, bits);
                addr += 4;
            } while (bits & JBED_STACK_MAP_CONTINUATION);
            return;
        }
        if (!(descriptor & JBED_STACK_MAP_DELTA)) {
            xor_word(m, 0, descriptor >> 2);
            return;
        }
        uint32_t offset_bits = descriptor >> JBED_STACK_MAP_DELTA_OFFSET_SHIFT;
        uint32_t mask = (descriptor >> 1) & JBED_STACK_MAP_DELTA_MASK;
        uint32_t index = offset_bits / JBED_STACK_MAP_BITMAP_BITS;
        uint32_t shift = offset_bits % JBED_STACK_MAP_BITMAP_BITS;
        xor_word(m, index, mask << shift);
        if (shift > JBED_STACK_MAP_BITMAP_BITS - 5)
            xor_word(m, index + 1, mask >> (JBED_STACK_MAP_BITMAP_BITS - shift));
        if (!entry)
            jbed_halt(m->runtime, 0, "Stack map delta lacks an absolute predecessor");
        --entry;
    }
}

/* StackMapBlock.getStackMap, 0xf3c68. Cache across words of the same PC. */
uint32_t jbed_vm_stack_map_word(JbedVmStackMaps *m, JbedAddress pc, uint32_t index)
{
    if (!m->cached || m->cached_pc != pc) {
        JbedVmStackMapBlock *b = m->blocks;
        while (b && b->pc_limit <= pc)
            b = b->next;
        if (!b || b->pc_base > pc)
            jbed_halt(m->runtime, (int32_t)pc, "missing stackmap");
        decode(m, b, pc);
        m->cached_pc = pc;
        m->cached = true;
    }
    if (index > m->last_word)
        jbed_halt(m->runtime, (int32_t)pc, "word index out of bounds");
    return (m->bitmap[index] & INT32_MAX) | (index < m->last_word ? JBED_STACK_MAP_CONTINUATION : 0);
}

static void visit_frame(JbedVmStackMaps *m, JbedVmStackRoots *frame, int32_t spills,
                        const JbedVmRootVisitor *v)
{
    uint32_t index = 0, raw;
    do {
        raw = jbed_vm_stack_map_word(m, frame->pc, index);
        uint32_t bits = raw & INT32_MAX;
        for (uint32_t bit = 0; bits; ++bit, bits >>= 1) {
            if (!(bits & 1))
                continue;
            uint32_t location = index * JBED_STACK_MAP_BITMAP_BITS + bit;
            if (location < 3) {
                if ((int32_t)location >= spills)
                    jbed_halt(m->runtime, 70, "Live register is outside frame spill area");
                v->stack_reference(v->context, frame->register_slots[location]);
            } else {
                v->stack_reference(v->context, frame->sp + 4 * (location - 3));
            }
        }
        ++index;
    } while (raw & JBED_STACK_MAP_CONTINUATION);
}

/* NativeCallStateStack.getPrevNcsp/getNativeRootsStart/getPrevNativeRootsEnd,
 * 0xf8a84..0xf8ad0. An ordinary native-root entry contains the slot address.
 * The -1 record carries a movable interior pointer and its owning object. */
static JbedAddress visit_native(JbedVmStackMaps *m, JbedVmStackRoots *frame, JbedAddress current,
                                JbedAddress base, const JbedVmRootVisitor *v)
{
    JbedAddress end = current - 8;
    JbedAddress prev = word(m, end);
    if (!prev)
        prev = base;
    frame->sp = word(m, prev + JBED_NATIVE_FRAME_SP);
    frame->pc = word(m, prev + JBED_NATIVE_FRAME_LR);
    frame->fp = word(m, prev + JBED_NATIVE_FRAME_FP);
    if (frame->fp)
        for (uint32_t i = 0; i < 3; ++i)
            frame->register_slots[i] = (prev + JBED_NATIVE_FRAME_R4 + 4 * i) | JBED_ROOT_PINNED;
    for (JbedAddress slot = prev + JBED_NATIVE_FRAME_ROOTS; (int32_t)slot < (int32_t)end; slot += 4) {
        uint32_t value = word(m, slot);
        if (value == JBED_NATIVE_ROOT_INTERIOR) {
            v->internal_pointer(v->context, slot + 4);
            slot += 8;
        } else if (value == JBED_NATIVE_ROOT_INVALID) {
            jbed_halt(m->runtime, 0, "Unexpected native root marker");
        } else {
            v->stack_reference(v->context, value);
        }
    }
    return prev;
}

static void traverse(JbedVmStackMaps *m, JbedVmStackRoots f, JbedAddress native_fp,
                      const JbedVmNativeFrames *native, const JbedVmRootVisitor *v)
{
    while (f.fp) {
        bool kni = f.fp == f.sp;
        JbedAddress top = kni ? f.fp + 24 : f.fp & ~7u;
        JbedAddress caller_fp_slot = (top & ~7u) - 8;
        int32_t spills = kni ? 3 : (int32_t)(caller_fp_slot - f.sp) / 4;
        if (spills > 3)
            spills = 3;
        visit_frame(m, &f, spills, v);
        for (int32_t i = 0; i < spills; ++i)
            f.register_slots[i] = caller_fp_slot - 4 * (uint32_t)(spills - i);
        f.sp = kni ? f.sp + word(m, f.sp) : top;
        f.fp = word(m, caller_fp_slot);
        if (f.fp)
            f.pc = word(m, top - 4);
        else if (native_fp && native->base && (int32_t)(native_fp - native->base) > 4)
            native_fp = visit_native(m, &f, native_fp, native->base, v);
    }
}

void jbed_vm_traverse_frames(JbedVmStackMaps *m, JbedVmStackRoots frame,
                             const JbedVmRootVisitor *visitor)
{
    traverse(m, frame, 0, NULL, visitor);
}

/* CollectorBase.traverseStack, 0xe9f28. The first frame takes r4..r6 from
 * Scheduled.context. Each caller inherits any register unsaved by its callee. */
void jbed_vm_traverse_stack(JbedVmStackMaps *m, JbedAddress scheduled, JbedAddress active,
                            const JbedVmNativeFrames *native, const JbedVmRootVisitor *v)
{
    if (!scheduled || (int32_t)word(m, scheduled + SCHEDULED_FIELD(status)) <= 1)
        return;
    JbedAddress context = word(m, scheduled + SCHEDULED_FIELD(context));
    JbedVmStackRoots frame = {.sp = context + 24, .fp = word(m, context + 16),
        .pc = word(m, context + 20), .register_slots = {context + 4, context + 8, context + 12}};
    traverse(m, frame, active == scheduled && native ? native->frame : 0, native, v);
}

void jbed_vm_traverse_scheduled(JbedVmStackMaps *m, JbedAddress threads, JbedAddress active,
                                const JbedVmNativeFrames *native, const JbedVmRootVisitor *v)
{
    uint32_t count = word(m, threads + 12);
    for (uint32_t i = 0; i < count; ++i)
        jbed_vm_traverse_stack(m, word(m, threads + 16 + 4 * i), active, native, v);
}

static void mark_reference(void *context, JbedAddress slot)
{
    jbed_vm_mark_stack_reference(context, slot);
}

static void mark_internal(void *context, JbedAddress slot)
{
    jbed_vm_mark_internal_pointer(context, slot);
}

JbedVmRootVisitor jbed_vm_mark_root_visitor(JbedVmMarker *marker)
{
    return (JbedVmRootVisitor){marker, mark_reference, mark_internal};
}
