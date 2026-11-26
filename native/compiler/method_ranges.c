#include "method_ranges.h"
#include "class_access.h"

#include <inttypes.h>
#include <stdio.h>
#include <string.h>

/* ArrayOps.ensureSpace, 0x145924/0x14597c, on int[] storage. */
static void ensure_words(JbedRuntime *rt, uint32_t **words, size_t *capacity, ptrdiff_t requested,
                         size_t initial)
{
    if (*words && (ptrdiff_t)*capacity >= requested)
        return;
    size_t length = *words ? *capacity : initial;
    while ((ptrdiff_t)length <= requested)
        length *= 2;
    uint32_t *larger = jbed_alloc(rt, length * sizeof(*larger));
    if (*words)
        memcpy(larger, *words, *capacity * sizeof(*larger));
    *words = larger;
    *capacity = length;
}

static _Noreturn void bad_index(JbedRuntime *rt)
{
    const JbedError error = {.kind = JBED_ERROR_ARRAY_INDEX};
    jbed_raise(rt, &error);
}

/* Method.addCodeRange, 0x12f360. Endpoints are inclusive target addresses. */
int32_t jbed_method_add_range(JbedRuntime *rt, uint32_t first, uint32_t last)
{
    if ((int32_t)last < (int32_t)first) {
        char message[160];
        snprintf(message, sizeof(message),
                 "Bad Code range: begin=0x%" PRIx32 " block[%" PRIu32 "]+%" PRIu32
                 " end=0x%" PRIx32 " block[%" PRIu32 "]+%" PRIu32,
                 first, (first - JBED_CODE_BASE) / JBED_BLOCK_SIZE, first & (JBED_BLOCK_SIZE - 1),
                 last, (last - JBED_CODE_BASE) / JBED_BLOCK_SIZE, last & (JBED_BLOCK_SIZE - 1));
        jbed_halt(rt, 0, message);
    }
    int32_t index = rt->method_ranges.next_index;
    int32_t word = index * 2;
    ensure_words(rt, &rt->method_ranges.words, &rt->method_ranges.capacity, word + 1, 16);
    if (word < 0)
        bad_index(rt);
    rt->method_ranges.words[word] = first;
    rt->method_ranges.words[word + 1] = last;
    rt->method_ranges.next_index = (int16_t)(index + 1);
    return index;
}

/* 0x12f4b0 only drops the array. The isolate's short index survives. */
void jbed_method_discard_ranges(JbedRuntime *rt)
{
    rt->method_ranges.words = NULL;
    rt->method_ranges.capacity = 0;
}

/* Method.getCodeRanges, 0x12f4c0. The serialized size is a class-local
 * pair index, replacing the isolate index before genClass writes the record. */
void jbed_method_pack_ranges(JbedRuntime *rt, JbedMethod *method, uint32_t **words,
                             size_t *used, size_t *capacity)
{
    if (!(method->flags & JBED_METHOD_CODE_RANGES))
        return;
    size_t source = 2u * method->generated_size;
    size_t destination = *used;
    uint32_t *packed = *words;
    size_t packed_capacity = *capacity;
    method->generated_size = (uint16_t)(destination / 2);
    do {
        ensure_words(rt, &packed, &packed_capacity, (ptrdiff_t)destination + 2, destination + 2);
        if (!rt->method_ranges.words) {
            const JbedError error = {.kind = JBED_ERROR_NULL_POINTER};
            jbed_raise(rt, &error);
        }
        if (source >= rt->method_ranges.capacity)
            bad_index(rt);
        packed[destination++] = rt->method_ranges.words[source++];
        if (source >= rt->method_ranges.capacity)
            bad_index(rt);
        packed[destination++] = rt->method_ranges.words[source++];
    } while (packed[destination - 2]);
    *words = packed;
    *capacity = packed_capacity;
    *used = destination;
}

static int32_t pc_offset(uint32_t pc, uint32_t first, uint32_t size)
{
    int32_t offset = (int32_t)(pc - first);
    return offset >= 0 && (int32_t)(pc - (first + size)) < 0 ? offset : -1;
}

static uint32_t range_length(JbedRuntime *rt, uint32_t first, uint32_t last)
{
    uint32_t size = last + 1 - first;
    if ((int32_t)size <= 0)
        jbed_halt(rt, 0, "Corrupted method info");
    return size;
}

/* Method.getOffset(Method,int), 0x12ef68. This overload shifts the size by
 * two to obtain its initial int[] index; getCodeRanges shifts it by one. */
int32_t jbed_method_pc_offset(JbedRuntime *rt, const JbedMethod *method, uint32_t pc)
{
    if (!(method->flags & JBED_METHOD_CODE_RANGES))
        return pc_offset(pc, method->code_address, method->generated_size);
    if (!rt->method_ranges.words)
        return -1;
    uint32_t preceding = 0;
    for (size_t i = 4u * method->generated_size; ; i += 2) {
        if (i >= rt->method_ranges.capacity)
            bad_index(rt);
        uint32_t first = rt->method_ranges.words[i];
        if (!first)
            return -1;
        if (i + 1 >= rt->method_ranges.capacity)
            bad_index(rt);
        uint32_t size = range_length(rt, first, rt->method_ranges.words[i + 1]);
        int32_t offset = pc_offset(pc, first, size);
        if (offset >= 0)
            return (int32_t)(preceding + (uint32_t)offset);
        preceding += size;
    }
}

/* Method.searchDynMethodByPc, 0x12f11c. */
JbedMethod *jbed_search_dynamic_method_by_pc(JbedRuntime *rt, const JbedClass *owner, uint32_t pc)
{
    for (JbedMethod *m = owner->methods; m; m = m->next)
        if (jbed_method_pc_offset(rt, m, pc) >= 0)
            return m;
    return NULL;
}

static uint32_t halfword(const uint8_t *p)
{
    return (uint32_t)p[0] | (uint32_t)p[1] << 8;
}

static uint32_t word(const uint8_t *p)
{
    return halfword(p) | halfword(p + 2) << 16;
}

/* searchMethodByPc/getCodeRangeBase and the five-int getOffset overload,
 * 0x12f0c8/0x12f0a8/0x12f028. Serialized size indexes pairs of words. */
const uint8_t *jbed_search_rom_method_by_pc(JbedRuntime *rt, const uint8_t *object, size_t bytes,
                                            uint32_t pc)
{
    if (bytes < 56)
        return NULL;
    uint32_t methods = halfword(object + 52), fields = halfword(object + 54);
    size_t ranges = 56 + 16u * (methods + fields);
    if (ranges > bytes)
        return NULL;
    for (uint32_t i = 0; i < methods; ++i) {
        const uint8_t *record = object + 56 + i * 16;
        uint32_t address = word(record + 8), size = halfword(record + 14);
        if (!address)
            continue;
        if (!(word(record) & JBED_METHOD_CODE_RANGES)) {
            if (pc_offset(pc, address, size) >= 0)
                return record;
            continue;
        }
        size_t index = ranges + size * 8;
        uint32_t preceding = 0;
        while (index <= bytes && bytes - index >= 8) {
            uint32_t first = word(object + index);
            if (!first)
                break;
            uint32_t length = range_length(rt, first, word(object + index + 4));
            int32_t offset = pc_offset(pc, first, length);
            if (offset >= 0) {
                if ((int32_t)(preceding + (uint32_t)offset) >= 0)
                    return record;
                break;
            }
            preceding += length;
            index += 8;
        }
    }
    return NULL;
}

/* Method.getMethodByClassesAndPc 0x12f200. ClassIterator.nextClass enumerates
 * each read-only bundle by low class ID, followed by the isolate's classes.
 * The loaded Method records already live in the resident class table. */
JbedMethod *jbed_method_by_pc(const JbedClassAccess *access, uint32_t pc, JbedMethodSearch scope)
{
    pc |= 1;
    if (scope != JBED_METHOD_DYNAMIC_BUNDLE) {
        unsigned first = scope == JBED_METHOD_LOADED_BUNDLE ? 1 : 0;
        for (unsigned bundle = first; bundle < 2; ++bundle) {
            const JbedVmClassTable *table = access->bundles[bundle];
            if (!table)
                continue;
            for (uint32_t id = 1; id <= table->id_limit; ++id) {
                JbedClass *klass = jbed_vm_class_by_id(table, (bundle << 16) | id);
                if (!klass || !klass->method_count)
                    continue;
                uint32_t offset = jbed_vm_class_address(table, klass) - table->image.base;
                const uint8_t *object = table->image.bytes + offset;
                const uint8_t *record = jbed_search_rom_method_by_pc(
                    access->runtime, object, table->image.size - offset, pc);
                if (record)
                    return &klass->methods[(record - (object + 56)) / 16];
            }
        }
    }
    if (scope != JBED_METHOD_LOADED_BUNDLE) {
        for (JbedClass *klass = NULL; (klass = jbed_class_next(access, klass)) != NULL;) {
            JbedMethod *method = jbed_search_dynamic_method_by_pc(access->runtime, klass, pc);
            if (method)
                return method;
        }
    }
    return NULL;
}
