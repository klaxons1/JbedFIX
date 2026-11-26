#include "reflection_table.h"

#include <limits.h>
#include <string.h>

enum { DYNAMIC_ID = 0x8000 };

typedef struct Chain {
    const uint8_t *next, *end;
} Chain;

typedef struct Entry {
    const uint8_t *data;
    uint32_t length;
} Entry;

static JbedReflectionLayout layout(uint8_t bits, bool extra_bit)
{
    unsigned b = bits & 15, i = bits >> 4;
    return (JbedReflectionLayout){.bucket_bits = b,
                                  .index_bits = i,
                                  .shift = i + extra_bit,
                                  .extra = extra_bit ? 1u << i : 0,
                                  .bucket_mask = (1u << b) - 1,
                                  .index_mask = (1u << i) - 1};
}

/* ReflectionTable.<init>, 0x12a2dc; referenceDynamicTable, 0x12a35a. */
bool jbed_reflection_init(JbedReflectionTable *t, JbedRuntime *runtime, JbedImageView image,
                          JbedAddress address)
{
    if (!image.bytes || address < image.base)
        return false;
    size_t offset = address - image.base;
    if (offset > image.size || image.size - offset < 4)
        return false;
    const uint8_t *p = image.bytes + offset;
    JbedReflectionLayout resident = layout(p[0], p[2] != 0);
    JbedReflectionLayout dynamic = layout(p[1], false);
    if (image.size - offset - 4 < 4 * (resident.bucket_mask + 1) ||
        resident.bucket_bits + resident.shift > 15 || dynamic.bucket_bits + dynamic.shift > 15)
        return false;
    *t = (JbedReflectionTable){.runtime = runtime,
                               .image = image,
                               .bucket_words = p + 4,
                               .resident = resident,
                               .dynamic = dynamic};
    return true;
}

bool jbed_reflection_reference(JbedReflectionTable *t, JbedImageView image, JbedAddress addr)
{
    JbedReflectionTable view;
    if (!jbed_reflection_init(&view, t->runtime, image, addr))
        return false;
    JbedReflectionTable *referenced = jbed_alloc(t->runtime, sizeof *referenced);
    *referenced = view;
    t->referenced = referenced;
    return true;
}

void jbed_reflection_clear_dynamic(JbedReflectionTable *t)
{
    t->buckets = NULL;
    t->referenced = NULL;
    t->encoded_bytes = t->entries = t->used_buckets = t->full_buckets = 0;
}

static Chain resident_chain(const JbedReflectionTable *t, uint32_t bucket)
{
    const uint8_t *p = t->bucket_words + 4 * bucket;
    uint32_t addr = p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
    if (!addr)
        return (Chain){0};
    size_t offset = (uint32_t)(addr - t->image.base);
    if (addr < t->image.base || offset >= t->image.size)
        jbed_raise_internal(t->runtime, "Invalid reflection bucket address");
    return (Chain){t->image.bytes + offset, t->image.bytes + t->image.size};
}

static Chain dynamic_chain(const JbedReflectionTable *t, uint32_t bucket)
{
    if (!t->buckets || !t->buckets[bucket].bytes)
        return (Chain){0};
    JbedReflectionBucket *b = &t->buckets[bucket];
    return (Chain){b->bytes, b->bytes + b->capacity};
}

/* The Thumb loops continue while the signed length byte is positive.
 * A zero inside a multi-byte prefix ends that prefix early. */
static bool next_entry(const JbedReflectionTable *t, Chain *chain, Entry *entry)
{
    if (!chain->next)
        return false;
    if (chain->next == chain->end)
        jbed_raise_internal(t->runtime, "Unterminated reflection bucket");
    if (!*chain->next)
        return false;
    uint32_t length = 0;
    uint8_t byte;
    do {
        if (chain->next == chain->end || length > (INT32_MAX >> 7))
            jbed_raise_internal(t->runtime, "Invalid reflection entry length");
        byte = *chain->next++;
        length = (length << 7) | (byte & 127);
    } while (byte > 0 && byte < 128);
    if (length > (size_t)(chain->end - chain->next))
        jbed_raise_internal(t->runtime, "Truncated reflection entry");
    *entry = (Entry){chain->next, length};
    chain->next += length;
    return true;
}

static uint16_t append_entry(JbedReflectionTable *t, uint32_t index, uint32_t ordinal,
                             uint32_t offset, const uint8_t *bytes, size_t length)
{
    if (!t->buckets)
        t->buckets = jbed_alloc(t->runtime, (t->dynamic.bucket_mask + 1) * sizeof *t->buckets);
    JbedReflectionBucket *b = &t->buckets[index];
    uint64_t needed = offset + (uint64_t)length + 6;
    if (needed > INT32_MAX)
        jbed_raise_internal(t->runtime, "Reflection bucket exceeds the VM array size");
    if (b->capacity < needed) {
        uint32_t capacity = b->capacity ? b->capacity : 16;
        while (capacity < needed) {
            if (capacity > INT32_MAX / 2)
                jbed_raise_internal(t->runtime, "Reflection bucket exceeds the VM array size");
            capacity *= 2;
        }
        uint8_t *p = jbed_alloc(t->runtime, capacity);
        if (b->bytes)
            memcpy(p, b->bytes, b->capacity);
        b->bytes = p;
        b->capacity = capacity;
    }
    uint8_t *p = b->bytes + offset;
    unsigned shift = 0;
    for (size_t n = length; n > 127; n >>= 7)
        shift += 7;
    for (; shift; shift -= 7)
        *p++ = (length >> shift) & 127;
    *p++ = (uint8_t)(length | 128);
    if (length)
        memcpy(p, bytes, length);
    p[length] = 0;
    t->encoded_bytes += (uint32_t)(p + length - (b->bytes + offset));
    ++t->entries;
    if (ordinal == 1)
        ++t->used_buckets;
    else if (ordinal == t->dynamic.index_mask)
        ++t->full_buckets;
    return DYNAMIC_ID | (index << t->dynamic.shift) | ordinal;
}

static bool match_chain(const JbedReflectionTable *t, Chain *chain, const uint8_t *bytes,
                        size_t length, uint32_t *ordinal)
{
    Entry entry;
    for (*ordinal = 1; next_entry(t, chain, &entry); ++*ordinal) {
        if (entry.length == length && (!length || memcmp(entry.data, bytes, length) == 0))
            return true;
    }
    return false;
}

/* getStaticChainEntry, 0x12a384. */
uint16_t jbed_reflection_static_id(const JbedReflectionTable *t, uint32_t hash,
                              const uint8_t *bytes, size_t length)
{
    const JbedReflectionLayout *l = &t->resident;
    uint32_t start = hash & l->bucket_mask, index = start;
    do {
        Chain chain = resident_chain(t, index);
        if (!chain.next)
            return 0;
        uint32_t ordinal;
        if (match_chain(t, &chain, bytes, length, &ordinal))
            return (uint16_t)((index << l->shift) + l->extra + ordinal);
        if (ordinal <= l->index_mask)
            return 0;
        index = (index + 1) & l->bucket_mask;
    } while (index != start);
    return 0;
}

/* getOrCreateDynamicChainEntry, 0x12a446. Append at the terminator found
 * by the scan, even if it falls inside a previously written payload. */
uint16_t jbed_reflection_dynamic_id(JbedReflectionTable *t, uint32_t hash, const uint8_t *bytes,
                             size_t length, bool create)
{
    const JbedReflectionLayout *l = &t->dynamic;
    uint32_t start = hash & l->bucket_mask, index = start;
    do {
        Chain chain = dynamic_chain(t, index);
        const uint8_t *begin = chain.next;
        uint32_t ordinal;
        if (match_chain(t, &chain, bytes, length, &ordinal))
            return (uint16_t)(DYNAMIC_ID | (index << l->shift) | ordinal);
        if (ordinal <= l->index_mask) {
            uint32_t offset = begin ? (uint32_t)(chain.next - begin) : 0;
            return create ? append_entry(t, index, ordinal, offset, bytes, length) : 0;
        }
        if (!begin)
            break;
        index = (index + 1) & l->bucket_mask;
    } while (index != start);
    if (create)
        jbed_halt(t->runtime, 0, "Reflection hash table full");
    return 0;
}

/* dataToId, 0x12a78c. Bytes are unsigned even for non-ASCII signatures. */
uint16_t jbed_reflection_id(JbedReflectionTable *t, const uint8_t *bytes, size_t length,
                            bool create)
{
    uint32_t hash = 0;
    for (size_t i = 0; i < length; ++i)
        hash = 31 * hash + bytes[i];
    uint16_t id = jbed_reflection_static_id(t, hash, bytes, length);
    if (id)
        return id;
    if (!t->referenced)
        return jbed_reflection_dynamic_id(t, hash, bytes, length, create);
    id = jbed_reflection_static_id(t->referenced, hash, bytes, length);
    if (id)
        return id | DYNAMIC_ID;
    if (create)
        jbed_halt(t->runtime, 0, "Cannot add a name to a referenced reflection table");
    return 0;
}

static bool entry_by_id(const JbedReflectionTable *t, uint16_t id, Entry *entry)
{
    if (!id)
        return false;
    bool dynamic = (id & DYNAMIC_ID) != 0;
    if (dynamic && t->referenced)
        return entry_by_id(t->referenced, id & ~DYNAMIC_ID, entry);
    const JbedReflectionLayout *l = dynamic ? &t->dynamic : &t->resident;
    uint32_t ordinal = id & l->index_mask;
    uint32_t index = (id >> l->shift) & l->bucket_mask;
    Chain chain = dynamic ? dynamic_chain(t, index) : resident_chain(t, index);
    /* getStaticAdr / getDynamicOffset (0x12a97c / 0x12a8f8) report -1
     * when the selected length prefix ended on zero. */
    while (next_entry(t, &chain, entry)) {
        if (ordinal && !--ordinal)
            return entry->data[-1] != 0;
    }
    return false;
}

/* getData / getFirstByte, 0x12a9c6 / 0x12aae8. */
int32_t jbed_reflection_data(const JbedReflectionTable *t, uint16_t id, uint8_t *out, size_t size)
{
    Entry entry;
    if (!entry_by_id(t, id, &entry))
        return -1;
    if (out && size >= entry.length)
        memcpy(out, entry.data, entry.length);
    return (int32_t)entry.length;
}

int jbed_reflection_first_byte(const JbedReflectionTable *t, uint16_t id)
{
    Entry entry;
    return entry_by_id(t, id, &entry) && entry.length ? entry.data[0] : -1;
}

/* genDynamicTable, 0x12ac36. Writer records relocated pointers for populated
 * buckets. The original reserves a terminator byte even for unused buckets. */
JbedAddress jbed_reflection_generate(const JbedReflectionTable *t, JbedWriter *w)
{
    if (!t->buckets) {
        JbedAddress addr = jbed_writer_allocate(w, NULL, 8);
        jbed_writer_put_word(w, addr, 0);
        jbed_writer_put_word(w, addr + 4, 0);
        return addr;
    }
    uint32_t count = t->dynamic.bucket_mask + 1;
    uint64_t size = 4 + 5 * count + (uint64_t)t->encoded_bytes;
    if (size > INT32_MAX)
        jbed_raise_internal(t->runtime, "Reflection image exceeds the VM array size");
    JbedAddress addr = jbed_writer_allocate(w, NULL, (uint32_t)size);
    jbed_writer_put_byte(w, addr, (uint8_t)(t->dynamic.index_bits << 4 | t->dynamic.bucket_bits));
    jbed_writer_put_byte(w, addr + 1, 0);
    jbed_writer_put_byte(w, addr + 2, 0);
    JbedAddress ptr = addr + 4, data = ptr + 4 * count;
    for (uint32_t i = 0; i < count; ++i, ptr += 4) {
        const JbedReflectionBucket *bucket = &t->buckets[i];
        if (bucket->bytes) {
            jbed_writer_put_reloc(w, ptr, data, false);
            Chain chain = dynamic_chain(t, i);
            Entry entry;
            while (next_entry(t, &chain, &entry))
                ;
            uint32_t size = (uint32_t)(chain.next - bucket->bytes) + 1;
            jbed_writer_write_block(w, data, bucket->bytes, size);
            data += size;
        } else {
            jbed_writer_put_word(w, ptr, 0);
        }
    }
    return addr;
}
