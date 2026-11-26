#include "writer.h"
#include <stdlib.h>
#include <string.h>

static void check(JbedWriter *w, bool ok, const char *message)
{
    if (!ok)
        jbed_writer_fault(w, JBED_WRITER_ASSERTION, message);
}
static void grow(JbedWriter *w, uint32_t **words, uint32_t *capacity)
{
    uint32_t n = *capacity ? *capacity * 2 : 256;
    uint32_t *p = calloc(n, sizeof(*p));
    if (!p)
        jbed_writer_fault(w, JBED_WRITER_OUT_OF_MEMORY, "stack map words");
    if (*words)
        memcpy(p, *words, *capacity * sizeof(*p));
    free(*words);
    *words = p;
    *capacity = n;
}
/* StackMapArray constructors 0x17853a/0x178554. */
void jbed_stack_map_init(JbedStackMapArray *m, uint32_t max_bytes)
{
    memset(m, 0, sizeof(*m));
    m->max_long_words = 1;
    m->max_bytes = max_bytes;
}
void jbed_stack_map_dispose(JbedStackMapArray *m)
{
    if (m->next) {
        jbed_stack_map_dispose(m->next);
        free(m->next);
    }
    free(m->entries);
    free(m->long_words);
    memset(m, 0, sizeof(*m));
}
static JbedStackMapArray *tail(JbedStackMapArray *m, JbedWriter *w)
{
    if (m->ended) {
        check(w, m->next != NULL, "ended stack map has no successor");
        while (m->next)
            m = m->next;
    }
    return m;
}
/* 0x178758. Adjacent identical maps coalesce, but end follows the last PC. */
bool jbed_stack_map_add_short(JbedStackMapArray *m, JbedWriter *w, JbedAddress pc,
                              uint32_t descriptor)
{
    check(w, descriptor < JBED_STACK_MAP_DESCRIPTOR_LIMIT, "stack map descriptor exceeds 12 bits");
    m = tail(m, w);
    if (!m->entries)
        grow(w, &m->entries, &m->entry_capacity);
    if (m->max_bytes && 4u * (m->count + 1 + m->long_count + JBED_STACK_MAP_HEADER_BYTES / 4) > m->max_bytes)
        return false;
    if (!m->start)
        m->start = pc;
    if (m->count == m->entry_capacity)
        grow(w, &m->entries, &m->entry_capacity);
    if (m->count && (m->entries[m->count - 1] >> JBED_STACK_MAP_DESCRIPTOR_SHIFT) == descriptor) {
        check(w, pc >= m->end, "stack maps out of order");
    } else {
        check(w, (int32_t)(pc - m->start) >= 0 && pc - m->start < (JBED_STACK_MAP_PC_MASK + 1u) * 4u,
              "stack map PC span");
        check(w, !m->count || pc >= m->end, "stack maps out of order");
        check(w, !m->count || pc >= m->end + 4, "stack maps less than four bytes apart");
        m->entries[m->count++] = (descriptor << JBED_STACK_MAP_DESCRIPTOR_SHIFT) + ((pc - m->start) >> 2);
    }
    m->end = pc;
    return true;
}
/* 0x178572: long bitmap sequences terminate with a clear high bit. Search only
 * sequence starts; the tentative append guarantees a final self-match. */
bool jbed_stack_map_add_long(JbedStackMapArray *m, JbedWriter *w, JbedAddress pc,
                             const uint32_t *words, uint32_t count)
{
    m = tail(m, w);
    if (!m->long_words)
        grow(w, &m->long_words, &m->long_capacity);
    if (!count)
        jbed_writer_fault(w, JBED_WRITER_ARRAY_INDEX, "empty long stack map");
    uint32_t old = m->long_count, end = old;
    for (uint32_t i = 0; i < count; ++i) {
        if (end == m->long_capacity)
            grow(w, &m->long_words, &m->long_capacity);
        m->long_words[end++] = words[i] | (i + 1 < count ? JBED_STACK_MAP_CONTINUATION : 0);
    }
    uint32_t candidate = 0;
    for (;;) {
        uint32_t appended = old;
        while (m->long_words[candidate] == m->long_words[appended]) {
            ++candidate;
            if (++appended == end)
                break;
        }
        if (appended == end)
            break;
        while (m->long_words[candidate] & JBED_STACK_MAP_CONTINUATION)
            ++candidate;
        ++candidate;
    }
    uint32_t found = candidate - count;
    if (found == old) {
        if (found >= JBED_STACK_MAP_DESCRIPTOR_LIMIT / 2 ||
            (m->max_bytes &&
             4u * (m->count + 1 + end + JBED_STACK_MAP_HEADER_BYTES / 4) > m->max_bytes)) {
            jbed_stack_map_set_end(m, w, pc - 1);
            m->next = calloc(1, sizeof(*m->next));
            if (!m->next)
                jbed_writer_fault(w, JBED_WRITER_OUT_OF_MEMORY, "stack map successor");
            jbed_stack_map_init(m->next, m->max_bytes);
            return jbed_stack_map_add_long(m->next, w, pc, words, count);
        }
        if (count > m->max_long_words)
            m->max_long_words = count;
        m->long_count = end;
    }
    return jbed_stack_map_add_short(m, w, pc, found * 2u + JBED_STACK_MAP_LONG);
}
/* 0x1788e4: five words, compact entries, then long bitmap words. */
JbedAddress jbed_stack_map_write(JbedStackMapArray *m, JbedWriter *w)
{
    if (m->count) {
        JbedAddress p = jbed_writer_allocate(
            w, w->owner, 4u * (m->count + m->long_count + JBED_STACK_MAP_HEADER_BYTES / 4));
        if (!p)
            jbed_writer_fault(w, JBED_WRITER_OUT_OF_CODE, "stack map allocation");
        m->emitted = p;
        jbed_writer_put_reloc(w, p + JBED_STACK_MAP_HEADER_PC, m->start, false);
        jbed_writer_put_word(w, p + JBED_STACK_MAP_HEADER_NEXT, 0);
        jbed_writer_put_word(w, p + JBED_STACK_MAP_HEADER_LENGTH, m->end - m->start + (m->ended ? 0u : 16u));
        jbed_writer_put_word(w, p + JBED_STACK_MAP_HEADER_COUNT, m->count);
        jbed_writer_put_word(w, p + JBED_STACK_MAP_HEADER_CAPACITY, m->max_long_words);
        p += JBED_STACK_MAP_HEADER_BYTES;
        for (uint32_t i = 0; i < m->count; i++, p += 4)
            jbed_writer_put_word(w, p, m->entries[i]);
        for (uint32_t i = 0; i < m->long_count; i++, p += 4)
            jbed_writer_put_word(w, p, m->long_words[i]);
    }
    return m->emitted;
}
void jbed_stack_map_set_end(JbedStackMapArray *m, JbedWriter *w, JbedAddress end)
{
    check(w, !m->ended, "stack map already ended");
    m->end = end;
    m->ended = true;
} /* 0x1789f8 */
void jbed_stack_map_recycle(JbedStackMapArray *m)
{
    /* 0x178a28 leaves max_long_words and ended unchanged. Detached successors
     * become unreachable to the Java GC; release their host equivalents here. */
    if (m->next) {
        jbed_stack_map_dispose(m->next);
        free(m->next);
    }
    m->count = 0;
    m->long_count = 0;
    m->start = 0;
    m->end = 0;
    m->emitted = 0;
    m->next = NULL;
}
