#include "rom_objects.h"
#include "class_access.h"
#include "writer.h"
#include <stdlib.h>
#include <string.h>

static void check(JbedCodeBlockWriter *b, bool ok, const char *message)
{
    if (!ok)
        jbed_writer_fault(&b->writer, JBED_WRITER_ASSERTION, message);
}
static void dependency(JbedCodeBlockWriter *b, bool ok, const char *message)
{
    if (!ok)
        jbed_writer_fault(&b->writer, JBED_WRITER_UNSUPPORTED, message);
}
static uint32_t round_word(uint32_t n)
{
    return (n + 3u) & ~UINT32_C(3);
}
static JbedCodeBlockWriter *block(JbedWriter *w)
{
    return (JbedCodeBlockWriter *)w;
}
static void check_address(JbedCodeBlockWriter *b, JbedAddress a, uint32_t n)
{
    if (b->hooks && b->hooks->check_address)
        b->hooks->check_address(b, a, n);
    else
        jbed_code_check_address(b, a, n);
}

/* 0x1764b0..0x176546: eight 8 KiB slots, addressed in the signed virtual
 * interval 0xd0000000..0xdfffffff. Large objects start at 0xe0000000. */
uint32_t jbed_code_block_index(const JbedCodeBlockWriter *b, JbedAddress a)
{
    return (a - b->buffer_base) >> 13;
}
JbedAddress jbed_code_block_base(const JbedCodeBlockWriter *b, uint32_t i)
{
    return b->buffer_base + (i << 13);
}
uint32_t jbed_code_blocks_present(const JbedCodeBlockWriter *b)
{
    return (b->top - b->buffer_base + 8191u) >> 13;
}
uint32_t jbed_code_blocks_generated(const JbedCodeBlockWriter *b)
{
    return (b->top - JBED_CODE_BASE + 8191u) >> 13;
}
uint32_t jbed_code_last_joined(const JbedCodeBlockWriter *b, uint32_t i)
{
    while (b->joined_mask & (UINT32_C(1) << (i & 31)))
        i++;
    return i;
}
uint32_t jbed_code_total_size(const JbedCodeBlockWriter *b)
{
    uint32_t n = jbed_code_blocks_generated(b) << 13;
    for (uint32_t i = 0; i < b->large_count; i++)
        n += b->large_blocks[i]->size;
    return n;
}
uint32_t jbed_code_load(const JbedCodeBlockWriter *b)
{
    uint32_t n = jbed_code_blocks_generated(b);
    return n ? b->flushed_bytes / n : 0;
}

/* 0x17749c/0x17755c/0x177586: original access assertions. */
void jbed_code_check_address(JbedCodeBlockWriter *b, JbedAddress a, uint32_t n)
{
    bool valid = true;
    if ((int32_t)a >= (int32_t)JBED_LARGE_BASE)
        valid = (int32_t)(a + n) <= (int32_t)b->large_top;
    else if (!b->allocation_limit || (int32_t)a < (int32_t)b->allocation_start ||
             (int32_t)(a + n) > (int32_t)b->allocation_limit) {
        uint32_t i = jbed_code_block_index(b, a);
        JbedAddress base = jbed_code_block_base(b, i), end = base;
        for (; i < 8; i++) {
            if (!(b->joined_mask & (UINT32_C(1) << i))) {
                end += b->used[i];
                break;
            }
            end += 8192;
        }
        valid = (int32_t)a >= (int32_t)base && (int32_t)(a + n) <= (int32_t)end;
    }
    check(b, valid, "CodeBlockWriter address outside allocated data");
}
void jbed_code_check_access(JbedCodeBlockWriter *b, JbedAddress a, uint32_t n)
{
    check(b, !b->access_forbidden, "CodeBlockWriter already flushed");
    check_address(b, a, n);
}

static void put_byte(JbedWriter *w, JbedAddress a, uint8_t v)
{
    JbedCodeBlockWriter *b = block(w);
    jbed_code_check_access(b, a, 1);
    b->bytes[a - b->buffer_base] = v;
}
static void put_half(JbedWriter *w, JbedAddress a, uint16_t v)
{
    JbedCodeBlockWriter *b = block(w);
    jbed_code_check_access(b, a, 2);
    uint8_t *p = b->bytes + (a - b->buffer_base);
    p[0] = (uint8_t)v;
    p[1] = (uint8_t)(v >> 8);
}
static int16_t get_half(JbedWriter *w, JbedAddress a)
{
    JbedCodeBlockWriter *b = block(w);
    jbed_code_check_access(b, a, 2);
    const uint8_t *p = b->bytes + (a - b->buffer_base);
    return (int16_t)((uint16_t)p[0] | ((uint16_t)p[1] << 8));
}
/* Arch overrides 0x183938/0x18397c preserve halfword-aligned BL words. */
static void put_word(JbedWriter *w, JbedAddress a, uint32_t v)
{
    if (a & 3u) {
        jbed_writer_put_halfword(w, a, (uint16_t)v);
        jbed_writer_put_halfword(w, a + 2, (uint16_t)(v >> 16));
        return;
    }
    JbedCodeBlockWriter *b = block(w);
    jbed_code_check_access(b, a, 4);
    uint8_t *p = b->bytes + (a - b->buffer_base);
    p[0] = (uint8_t)v;
    p[1] = (uint8_t)(v >> 8);
    p[2] = (uint8_t)(v >> 16);
    p[3] = (uint8_t)(v >> 24);
}
static uint32_t get_word(JbedWriter *w, JbedAddress a)
{
    if (a & 3u)
        return (uint16_t)jbed_writer_get_halfword(w, a) |
               ((uint32_t)(uint16_t)jbed_writer_get_halfword(w, a + 2) << 16);
    JbedCodeBlockWriter *b = block(w);
    jbed_code_check_access(b, a, 4);
    const uint8_t *p = b->bytes + (a - b->buffer_base);
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}
static void write_block(JbedWriter *w, JbedAddress a, const uint8_t *source, uint32_t n)
{
    JbedCodeBlockWriter *b = block(w);
    if ((int32_t)a < (int32_t)JBED_LARGE_BASE) {
        jbed_code_check_access(b, a, n);
        memmove(b->bytes + (a - b->buffer_base), source, n);
    } else {
        check(b, !b->access_forbidden, "CodeBlockWriter already flushed");
        uint32_t i = 0;
        while (i < b->large_count && (int32_t)a >= (int32_t)b->large_bases[i])
            i++;
        check(b, i != 0, "large block address precedes first allocation");
        i--;
        check(b, (int32_t)(a + n) <= (int32_t)(b->large_bases[i] + b->large_blocks[i]->size),
              "large block write crosses allocation");
        memmove(b->large_blocks[i]->data + (a - b->large_bases[i]), source, n);
    }
}
static void put_reloc(JbedWriter *w, JbedAddress a, JbedAddress v, bool d)
{
    (void)d;
    jbed_writer_put_word(w, a, v);
}
static void put_static(JbedWriter *w, JbedAddress a, JbedAddress v)
{
    jbed_writer_put_word(w, a, v);
}
static void put_call(JbedWriter *w, JbedAddress a, uint32_t v, bool d)
{
    (void)d;
    jbed_writer_put_halfword(w, a, (uint16_t)v);
    jbed_writer_put_halfword(w, a + 2, (uint16_t)(v >> 16));
}

/* 0x176f90: movable objects become labels; compiled Class objects are emitted
 * through RomObjects. Resident ROM pointers remain absolute in the baseline. */
static void put_pointer(JbedWriter *w, JbedAddress a, JbedAddress value)
{
    JbedCodeBlockWriter *b = block(w);
    const JbedWriterServices *s = w->services;
    JbedPointerKind kind = s && s->pointer_kind ? s->pointer_kind(s->context, value)
                                               : jbed_rom_pointer_kind(b->rom_objects, value);
    switch (kind) {
    case JBED_POINTER_RESIDENT_OBJECT:
    case JBED_POINTER_RESIDENT_CLASS:
        jbed_writer_put_word(w, a, value);
        break;
    case JBED_POINTER_MOVABLE_OBJECT:
        jbed_writer_write_label(w, a, jbed_rom_register_object(b->rom_objects, value));
        break;
    case JBED_POINTER_COMPILED_CLASS: {
        JbedClass *c = s && s->class_at ? s->class_at(s->context, value) :
            jbed_class_from_target(b->rom_objects->services->class_access, value);
        dependency(b, c != NULL, "Class object address");
        jbed_rom_register_class(b->rom_objects, c);
        jbed_rom_write_class(b->rom_objects, a, c);
        break;
    }
    }
}
void jbed_code_register_class(JbedCodeBlockWriter *b, JbedClass *c)
{
    jbed_rom_register_class(b->rom_objects, c);
}
void jbed_code_set_relative_statics(JbedCodeBlockWriter *b, uint32_t size, const uint32_t *ranges,
                                    uint32_t count)
{
    jbed_rom_register_relative_statics(b->rom_objects, size, ranges, count);
}

/* Allocation state machine 0x1767e0. requested is the preferred capacity and
 * minimum is the amount required to begin this compilation attempt. */
JbedAddress jbed_code_allocate(JbedCodeBlockWriter *b, uint32_t requested, uint32_t minimum)
{
    check(b, !b->allocation_forbidden, "allocation after flushAll");
    check(b, requested != 0, "zero code allocation");
    if (b->allocation_limit) {
        if (b->hooks && b->hooks->allocation_undone)
            b->hooks->allocation_undone(b);
        b->allocation_limit = 0;
        b->allocation_start = b->top;
    }
    for (;;) {
        check(b, b->allocation_start == b->top, "allocation cursor mismatch");
        uint32_t index = jbed_code_block_index(b, b->top);
        check(b, index < 8, "buffer full");
        check(b, (b->no_alloc_mask & (UINT32_C(1) << index)) == 0,
              "allocation into protected slot");
        uint32_t remaining = 8192u - (b->top & 8191u);
        if (remaining >= requested) {
            b->top += requested;
            b->allocation_limit = b->top;
            return b->allocation_start;
        }
        if (minimum >= 8192) {
            if (minimum > 65536)
                jbed_writer_fault(&b->writer, JBED_WRITER_OUT_OF_CODE,
                                  "allocation exceeds writer window");
            if (remaining < 8192)
                b->allocation_start = b->top += remaining;
            uint32_t available = 65536u - (b->top - b->buffer_base);
            if (available >= minimum) {
                b->top = b->allocation_start + minimum;
                b->allocation_limit = b->top;
                return b->allocation_start;
            }
            jbed_code_flush_blocks(b, (minimum - available + 8191u) >> 13);
            continue;
        }
        if (minimum > requested)
            minimum = requested;
        if (remaining >= minimum) {
            b->top += remaining < requested ? remaining : requested;
            b->allocation_limit = b->top;
            return b->allocation_start;
        }
        if (index >= 7) {
            jbed_code_flush_blocks(b, 1);
            continue;
        }
        b->allocation_start = b->top + remaining;
        b->top = b->allocation_start + (requested < 8192 ? requested : 8192);
        b->allocation_limit = b->top;
        return b->allocation_start;
    }
}
/* closeAllocIntern 0x176984: record joined slots and release unused tail. */
void jbed_code_close_allocation(JbedCodeBlockWriter *b, JbedAddress end)
{
    check(b, (int32_t)end <= (int32_t)b->allocation_limit, "allocation exceeds limit");
    b->actual_bytes += end - b->allocation_start;
    check_address(b, end, 0);
    uint32_t first = jbed_code_block_index(b, b->allocation_start),
             last = jbed_code_block_index(b, end - 1);
    for (; first < last; first++) {
        b->used[first] = 8192;
        b->joined_mask |= UINT32_C(1) << first;
    }
    JbedAddress rounded = round_word(end);
    uint32_t used = rounded - jbed_code_block_base(b, first);
    check(b, first < 8 && used > b->used[first], "allocation did not extend its last slot");
    b->used[first] = used;
    JbedAddress old_top = b->top;
    bool last_allocation = b->allocation_limit == old_top;
    b->allocation_limit = 0;
    if (last_allocation) {
        if (b->no_alloc_mask & (UINT32_C(1) << (jbed_code_block_index(b, rounded) & 31)))
            rounded = (rounded & ~UINT32_C(8191)) + 8192;
        jbed_code_move_top(b, rounded);
    } else
        b->allocation_start = old_top;
}
static JbedAddress allocate_code(JbedWriter *w, JbedCodeOwner *owner, uint32_t n, uint32_t minimum)
{
    (void)owner;
    return jbed_code_allocate(block(w), n, minimum);
}
static JbedAddress allocate_data(JbedWriter *w, JbedCodeOwner *owner, uint32_t n)
{
    (void)owner;
    JbedCodeBlockWriter *b = block(w);
    JbedAddress a = jbed_code_allocate(b, n, n);
    jbed_code_close_allocation(b, b->allocation_limit);
    return a;
}
static JbedAddress allocate_raw(JbedWriter *w, JbedCodeOwner *owner, uint32_t n)
{
    return n <= 8192 ? allocate_data(w, owner, n) : jbed_code_allocate_large(block(w), n);
}
static void flush_code(JbedWriter *w, JbedCodeOwner *owner, JbedAddress end)
{
    (void)owner;
    jbed_code_close_allocation(block(w), end);
}

void jbed_code_prevent_allocations(JbedCodeBlockWriter *b, uint32_t index)
{
    b->no_alloc_mask |= UINT32_C(1) << (index & 31);
    if (!b->allocation_limit && index == jbed_code_block_index(b, b->top)) {
        check(b, (b->top & 8191u) != 0, "protecting an empty slot");
        jbed_code_move_top(b, (b->top & ~UINT32_C(8191)) + 8192);
    }
}
void jbed_code_move_top(JbedCodeBlockWriter *b, JbedAddress top)
{
    b->top = b->allocation_start = top;
    uint32_t index = jbed_code_block_index(b, top);
    if (index > 7) {
        jbed_code_flush_blocks(b, index - 7);
        check(b, jbed_code_block_index(b, b->top) < 8, "flush did not free a slot");
    }
}
void jbed_code_flush_blocks(JbedCodeBlockWriter *b, uint32_t minimum)
{
    /* 0x176b5c: flush at least four when available, extending through all joined
     * allocations. Preserve old_base for the maps' PC ranges after sliding. */
    check(b, b->allocation_limit == 0, "flush during open allocation");
    uint32_t present = jbed_code_blocks_present(b);
    check(b, minimum <= present, "flush more slots than present");
    uint32_t count = present <= 4 ? present : (minimum < 4 ? 4 : minimum);
    count = jbed_code_last_joined(b, count - 1) + 1;
    check(b, count <= present, "joined allocation crosses available slots");
    dependency(b, b->hooks && b->hooks->flush_blocks, "CodeBlockWriter.flushBlocks abstract hook");
    b->hooks->flush_blocks(b, count);
    for (uint32_t i = 0; i < count; i++) {
        b->flushed_bytes += b->used[i];
        if (b->joined_mask & (UINT32_C(1) << i))
            b->total_joined++;
    }
    jbed_code_queue_maps(b, count);
    uint32_t remaining = present - count;
    if (remaining) {
        memmove(b->bytes, b->bytes + count * 8192u, remaining * 8192u);
        memmove(b->maps, b->maps + count, remaining * sizeof(*b->maps));
        memmove(b->used, b->used + count, remaining * sizeof(*b->used));
    }
    for (uint32_t i = remaining; i < 8; i++) {
        b->maps[i] = NULL;
        b->used[i] = 0;
    }
    b->joined_mask >>= count & 31;
    b->no_alloc_mask >>= count & 31;
    JbedAddress old_base = b->buffer_base;
    b->buffer_base += count * 8192u;
    if ((int32_t)b->top < (int32_t)b->buffer_base)
        b->top = b->allocation_start = b->buffer_base;
    jbed_code_flush_maps(b, old_base);
}
static JbedBuffer *new_large_block(JbedCodeBlockWriter *b, uint32_t size)
{
    if (b->hooks && b->hooks->new_large_block)
        return b->hooks->new_large_block(b, size);
    JbedBuffer *buffer = calloc(1, sizeof(*buffer));
    if (buffer)
        buffer->data = calloc(size, 1);
    if (!buffer || !buffer->data)
        jbed_writer_fault(&b->writer, JBED_WRITER_OUT_OF_MEMORY, "large code block");
    buffer->size = size;
    return buffer;
}
JbedAddress jbed_code_allocate_large(JbedCodeBlockWriter *b, uint32_t size)
{
    check(b, !b->allocation_forbidden, "large allocation after flushAll");
    JbedAddress address = b->large_top;
    b->large_top = round_word(address + size);
    if (b->large_count == b->large_capacity) {
        uint32_t capacity = b->large_capacity ? b->large_capacity * 2 : 32;
        JbedAddress *bases = calloc(capacity, sizeof(*bases));
        JbedBuffer **buffers = calloc(capacity, sizeof(*buffers));
        if (!bases || !buffers)
            jbed_writer_fault(&b->writer, JBED_WRITER_OUT_OF_MEMORY, "large block index");
        if (b->large_count) {
            memcpy(bases, b->large_bases, b->large_count * sizeof(*bases));
            memcpy(buffers, b->large_blocks, b->large_count * sizeof(*buffers));
        }
        free(b->large_bases);
        free(b->large_blocks);
        b->large_bases = bases;
        b->large_blocks = buffers;
        b->large_capacity = capacity;
    }
    b->large_blocks[b->large_count] = new_large_block(b, size);
    b->large_bases[b->large_count++] = address;
    return address;
}

void jbed_code_queue_maps(JbedCodeBlockWriter *b, uint32_t count)
{
    for (uint32_t i = 0; i < count; i++) {
        check(b, b->pending_count < 16, "stack map queue full");
        b->pending_maps[b->pending_count++] = b->maps[i];
        b->maps[i] = NULL;
    }
}
void jbed_code_flush_maps(JbedCodeBlockWriter *b, JbedAddress old_base)
{
    if (b->flushing_maps)
        return;
    b->flushing_maps = true;
    for (uint32_t i = 0; i < b->pending_count; i++) {
        JbedStackMapArray *m = b->pending_maps[i];
        b->pending_maps[i] = NULL;
        while (m) {
            JbedStackMapArray *next = m->next;
            if (!next)
                jbed_stack_map_set_end(m, &b->writer, old_base + (i + 1) * 8192u - 1);
            b->flushed_map_count += m->count;
            b->flushed_long_words += m->long_count;
            jbed_stack_map_write(m, &b->writer);
            jbed_rom_register_stack_map(b->rom_objects, m->emitted);
            /* Java removes the array reference before writing, making it
             * collectible afterwards. The semantic host owns these vectors. */
            m->next = NULL;
            jbed_stack_map_dispose(m);
            free(m);
            m = next;
        }
    }
    b->pending_count = 0;
    for (unsigned i = 0; i < 16; i++)
        check(b, b->pending_maps[i] == NULL, "stack map queue not empty");
    b->flushing_maps = false;
}
void jbed_code_flush_all(JbedCodeBlockWriter *b)
{
    jbed_code_queue_maps(b, jbed_code_blocks_present(b));
    jbed_code_flush_maps(b, b->buffer_base);
    jbed_rom_generate(b->rom_objects);
    if (b->hooks && b->hooks->generate_extra_data)
        b->hooks->generate_extra_data(b);
    jbed_code_flush_blocks(b, jbed_code_blocks_present(b));
    dependency(b, b->hooks && b->hooks->store_large_blocks,
               "CodeBlockWriter.storeLargeBlocks abstract hook");
    b->hooks->store_large_blocks(b);
    b->access_forbidden = b->allocation_forbidden = b->maps_forbidden = true;
}
JbedStackMapArray *jbed_code_stack_map(JbedCodeBlockWriter *b, JbedAddress pc)
{
    check_address(b, pc, 0);
    check(b,
          b->allocation_limit && (int32_t)pc >= (int32_t)b->allocation_start &&
              (int32_t)pc <= (int32_t)b->allocation_limit,
          "stack map outside open allocation");
    uint32_t i = jbed_code_block_index(b, b->allocation_start);
    check(b, i == jbed_code_block_index(b, b->allocation_limit - 1),
          "stack map allocation spans slots");
    check(b, !b->maps_forbidden && i < 8, "stack maps unavailable");
    if (!b->maps[i]) {
        b->maps[i] = calloc(1, sizeof(*b->maps[i]));
        if (!b->maps[i])
            jbed_writer_fault(&b->writer, JBED_WRITER_OUT_OF_MEMORY, "block stack maps");
        jbed_stack_map_init(b->maps[i], 8192);
    }
    JbedStackMapArray *m = b->maps[i];
    while (m->next)
        m = m->next;
    return m;
}
uint32_t jbed_code_write_label(JbedCodeBlockWriter *b, JbedAddress site, uint32_t label)
{
    if (!label)
        label = jbed_writer_get_label(&b->writer);
    dependency(b, b->hooks && b->hooks->add_label_fixup, "addLabelFixup abstract hook");
    b->hooks->add_label_fixup(b, site, label, 0);
    return label;
}
uint32_t jbed_code_write_call_label(JbedCodeBlockWriter *b, JbedAddress site, uint32_t instruction,
                                    uint32_t label)
{
    (void)instruction; /* Arch.callInstrExtras 0x1839c4 always returns zero. */
    if (!label)
        label = jbed_writer_get_label(&b->writer);
    dependency(b, b->hooks && b->hooks->add_label_fixup, "addLabelFixup abstract hook");
    b->hooks->add_label_fixup(b, site, label, UINT32_C(0x4000));
    return label;
}
static uint32_t write_label(JbedWriter *w, JbedAddress a, uint32_t l)
{
    return jbed_code_write_label(block(w), a, l);
}
static uint32_t write_call_label(JbedWriter *w, JbedAddress a, uint32_t i, uint32_t l)
{
    return jbed_code_write_call_label(block(w), a, i, l);
}
static uint32_t write_long_jump_label(JbedWriter *w, JbedAddress a, uint32_t l)
{
    (void)a;
    (void)l;
    jbed_writer_fault(w, JBED_WRITER_HALT, "CodeBlockWriter.writeLongJumpLabel");
    return 0;
}
static bool not_reusable(JbedWriter *w)
{
    (void)w;
    return false;
}

const JbedWriterOps jbed_code_writer_ops = {.reusable = not_reusable,
                                            .allocate_code = allocate_code,
                                            .allocate = allocate_data,
                                            .allocate_raw = allocate_raw,
                                            .flush_code = flush_code,
                                            .put_word = put_word,
                                            .put_halfword = put_half,
                                            .put_byte = put_byte,
                                            .put_pointer = put_pointer,
                                            .put_static = put_static,
                                            .put_reloc = put_reloc,
                                            .put_call = put_call,
                                            .get_halfword = get_half,
                                            .get_word = get_word,
                                            .write_block = write_block,
                                            .write_label = write_label,
                                            .write_call_label = write_call_label,
                                            .write_long_jump_label = write_long_jump_label,
                                            .set_label = jbed_writer_define_label};

/* 0x177394. A zero property selects the original random prefix allocation;
 * random_value is an actual java.util.Random.nextInt() result supplied by the
 * adapter. Keeping this explicit makes differential tests reproducible. */
void jbed_code_allocation_test(JbedCodeBlockWriter *b, int32_t configured, uint32_t random_value)
{
    int32_t prefix = configured;
    if (!prefix) {
        prefix = (int32_t)(random_value & 8191u);
        if (8192 - prefix < 128)
            prefix -= 128;
    }
    if (prefix > 0)
        (void)jbed_writer_allocate(&b->writer, NULL, (uint32_t)prefix);
}
void jbed_code_writer_init(JbedCodeBlockWriter *b, const JbedWriterServices *s,
                           const JbedCodeBlockHooks *hooks)
{
    memset(b, 0, sizeof(*b));
    jbed_writer_init(&b->writer, s);
    b->writer.ops = &jbed_code_writer_ops;
    b->writer.block_writer = b;
    b->hooks = hooks;
    b->top = b->buffer_base = b->allocation_start = JBED_CODE_BASE;
    b->large_top = JBED_LARGE_BASE;
    dependency(b, s && s->rom_services && s->allocation_test_property,
               "CodeBlockWriter constructor runtime adapters");
    b->rom_objects = jbed_alloc(s->rom_services->runtime, sizeof(*b->rom_objects));
    jbed_rom_init(b->rom_objects, s->rom_services, &b->writer, s->full_debug_info);
    int32_t configured = s->allocation_test_property(s->context);
    uint32_t random_value = 0;
    if (!configured) {
        dependency(b, s->random_int != NULL, "java.util.Random adapter");
        random_value = s->random_int(s->context);
    }
    jbed_code_allocation_test(b, configured, random_value);
}
void jbed_code_writer_dispose(JbedCodeBlockWriter *b)
{
    jbed_writer_dispose(&b->writer);
    for (unsigned i = 0; i < 8; i++)
        if (b->maps[i]) {
            jbed_stack_map_dispose(b->maps[i]);
            free(b->maps[i]);
        }
    for (unsigned i = 0; i < 16; i++)
        if (b->pending_maps[i]) {
            jbed_stack_map_dispose(b->pending_maps[i]);
            free(b->pending_maps[i]);
        }
    /* Runtime-provided large blocks belong to that runtime. */
    if (!b->hooks || !b->hooks->new_large_block)
        for (uint32_t i = 0; i < b->large_count; i++) {
            free(b->large_blocks[i]->data);
            free(b->large_blocks[i]);
        }
    free(b->large_bases);
    free(b->large_blocks);
}
