#include "block_stream.h"
#include "rom_objects.h"

#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <zlib.h>

#define FILE_MAGIC UINT32_C(0xcafeb00b)
#define FILE_FLAGS UINT32_C(0x64000004)

static _Noreturn void fail(JbedWriter *w, const char *message)
{
    jbed_writer_fault(w, JBED_WRITER_ASSERTION, message);
    abort();
}

static void require(JbedWriter *w, bool condition, const char *message)
{
    if (!condition)
        fail(w, message);
}

static void *resize(JbedWriter *w, void *old, size_t size)
{
    void *p = realloc(old, size ? size : 1);
    if (!p) {
        jbed_writer_fault(w, JBED_WRITER_OUT_OF_MEMORY, "block stream allocation");
        abort();
    }
    return p;
}

static void ensure(JbedWriter *w, JbedBlockVector *v, uint32_t count)
{
    if (count <= v->length)
        return;
    require(w, count <= UINT32_MAX - 31, "block vector size overflow");
    uint32_t length = (count + 31) & ~UINT32_C(31);
    require(w, (uint64_t)length * sizeof(uint32_t) <= SIZE_MAX, "block vector size overflow");
    v->values = resize(w, v->values, (size_t)length * sizeof(*v->values));
    memset(v->values + v->length, 0, (length - v->length) * sizeof(*v->values));
    v->length = length;
}

static void clear_vector(JbedWriter *w, JbedBlockVector *v, uint32_t count)
{
    ensure(w, v, count);
    if (v->length)
        memset(v->values, 0, (size_t)v->length * sizeof(*v->values));
}

static void dispose_vector(JbedBlockVector *v)
{
    free(v->values);
    memset(v, 0, sizeof(*v));
}

static uint32_t get_le32(const uint8_t *p)
{
    return (uint32_t)p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
}

static void put_le32(uint8_t *p, uint32_t value)
{
    for (unsigned i = 0; i < 4; ++i)
        p[i] = (uint8_t)(value >> (i * 8));
}

static uint32_t get_be32(const uint8_t *p)
{
    return (uint32_t)p[0] << 24 | (uint32_t)p[1] << 16 | (uint32_t)p[2] << 8 | p[3];
}

static void put_be32(uint8_t *p, uint32_t value)
{
    for (unsigned i = 0; i < 4; ++i)
        p[i] = (uint8_t)(value >> ((3 - i) * 8));
}

static void output(JbedWriter *w, JbedBlockIo *io, const void *bytes, uint32_t length)
{
    require(w, io->write && io->write(io->context, bytes, length), "block stream write failed");
}

static void output_word(JbedWriter *w, JbedBlockIo *io, uint32_t word)
{
    uint8_t bytes[4];
    put_be32(bytes, word);
    output(w, io, bytes, 4);
}

static void input(JbedWriter *w, JbedBlockIo *io, void *bytes, uint32_t length)
{
    require(w, io->read && io->read(io->context, bytes, length), "truncated block stream");
}

static uint32_t input_word(JbedWriter *w, JbedBlockIo *io)
{
    uint8_t bytes[4];
    input(w, io, bytes, 4);
    return get_be32(bytes);
}

static void seek_to(JbedWriter *w, JbedBlockIo *io, uint32_t position)
{
    require(w, io->seek && io->seek(io->context, position), "block stream seek failed");
}

static void read_code(JbedWriter *w, const JbedBlockServices *s, JbedAddress address, void *bytes,
                      uint32_t size)
{
    require(w, s->read_code && s->read_code(s->context, address, bytes, size),
            "code block read failed");
}

static void write_code(JbedWriter *w, const JbedBlockServices *s, JbedAddress address,
                       const void *bytes, uint32_t size)
{
    require(w, s->write_code && s->write_code(s->context, address, bytes, size),
            "code block write failed");
}

static JbedBuffer *allocate_large(JbedWriter *w, const JbedBlockServices *s, uint32_t size)
{
    JbedBuffer *buffer = s->allocate_large_block ? s->allocate_large_block(s->context, size) : NULL;
    if (!buffer || buffer->address == UINT32_MAX || buffer->size < size) {
        jbed_writer_fault(w, JBED_WRITER_OUT_OF_CODE, "cannot allocate large code block");
        abort();
    }
    return buffer;
}

static void allocate_blocks(JbedWriter *w, const JbedBlockServices *s, uint32_t count,
                            JbedAddress *addresses)
{
    if (!s->allocate_blocks || !s->allocate_blocks(s->context, count, addresses)) {
        jbed_writer_fault(w, JBED_WRITER_OUT_OF_CODE, "cannot allocate code blocks");
        abort();
    }
}

/* BlockStreamWriter, 0x175f70..0x176434. */
static void truncate_vector(JbedBlockStreamWriter *s, JbedBlockVector *v, uint32_t count)
{
    for (uint32_t i = 0; i < count; ++i)
        if (v->values[i])
            v->values[i] = jbed_code_truncate_chain(
                &s->base, v->values[i], s->base.allocation_start, s->base.allocation_limit);
}

static void stream_allocation_undone(JbedCodeBlockWriter *base)
{
    JbedBlockStreamWriter *s = (JbedBlockStreamWriter *)base;
    truncate_vector(s, &s->static_data_chains, s->static_data_count);
    truncate_vector(s, &s->dynamic_chains, s->dynamic_chains.length);
    truncate_vector(s, &s->large_chains, s->large_chains.length);
    truncate_vector(s, &s->label_chains, s->label_chains.length);
    truncate_vector(s, &s->static_chains, s->static_chains.length);
}

static void stream_flush(JbedCodeBlockWriter *base, uint32_t count)
{
    JbedBlockStreamWriter *s = (JbedBlockStreamWriter *)base;
    if (s->blocks->flush_fixups)
        s->blocks->flush_fixups(s->blocks->context, jbed_code_block_base(base, count));
    require(&base->writer, s->store_blocks != NULL, "abstract block store");
    s->store_blocks(s, count);
}

static void stream_label_fixup(JbedCodeBlockWriter *base, JbedAddress site, uint32_t label,
                               uint32_t flags)
{
    jbed_block_stream_add_label_fixup((JbedBlockStreamWriter *)base, site, label, flags);
}

static void add_fixup(JbedBlockStreamWriter *s, JbedBlockVector *heads, uint32_t page,
                      JbedAddress site, uint32_t offset_flags)
{
    ensure(&s->base.writer, heads, page + 1);
    heads->values[page] = jbed_code_add_fixup(&s->base, heads->values[page], site, offset_flags);
}

void jbed_block_stream_add_static_fixup(JbedBlockStreamWriter *s, JbedAddress site,
                                        JbedAddress target, uint32_t flags)
{
    uint32_t base = target & ~JBED_FIXUP_PAGE_MASK, page = 0;
    while (page < s->static_page_count && s->static_pages.values[page] != base)
        ++page;
    if (page == s->static_page_count) {
        ensure(&s->base.writer, &s->static_pages, page + 1);
        ensure(&s->base.writer, &s->static_chains, page + 1);
        s->static_pages.values[page] = base;
        ++s->static_page_count;
    }
    add_fixup(s, &s->static_chains, page, site, (target & JBED_FIXUP_PAGE_MASK) | flags);
}

void jbed_block_stream_add_dynamic_fixup(JbedBlockStreamWriter *s, JbedAddress site,
                                         JbedAddress target, uint32_t flags)
{
    add_fixup(s, &s->dynamic_chains, (target - JBED_CODE_BASE) >> JBED_FIXUP_PAGE_SHIFT, site,
              (target & JBED_FIXUP_PAGE_MASK) | flags);
}

void jbed_block_stream_add_large_fixup(JbedBlockStreamWriter *s, JbedAddress site,
                                       JbedAddress target)
{
    add_fixup(s, &s->large_chains, (target - JBED_LARGE_BASE) >> JBED_FIXUP_PAGE_SHIFT, site,
              target & JBED_FIXUP_PAGE_MASK);
}

void jbed_block_stream_add_label_fixup(JbedBlockStreamWriter *s, JbedAddress site, uint32_t label,
                                       uint32_t flags)
{
    add_fixup(s, &s->label_chains, label >> JBED_FIXUP_PAGE_SHIFT, site,
              (label & JBED_FIXUP_PAGE_MASK) | flags);
}

static void stream_reloc(JbedWriter *w, JbedAddress site, JbedAddress target, bool absolute)
{
    JbedBlockStreamWriter *s = (JbedBlockStreamWriter *)w;
    if (absolute)
        w->ops->put_word(w, site, target);
    else if ((int32_t)target >= (int32_t)JBED_LARGE_BASE)
        jbed_block_stream_add_large_fixup(s, site, target);
    else
        jbed_block_stream_add_dynamic_fixup(s, site, target, 0);
}

static void stream_call(JbedWriter *w, JbedAddress site, uint32_t instruction, bool absolute)
{
    JbedAddress target = jbed_thumb_call_destination(site, instruction);
    if (absolute)
        jbed_block_stream_add_static_fixup((JbedBlockStreamWriter *)w, site, target, JBED_FIXUP_CALL);
    else {
        require(w, (int32_t)target < (int32_t)JBED_LARGE_BASE, "call target outside code space");
        jbed_block_stream_add_dynamic_fixup((JbedBlockStreamWriter *)w, site, target, JBED_FIXUP_CALL);
    }
}

static void stream_static(JbedWriter *w, JbedAddress site, JbedAddress value)
{
    require(w, (value >> 24) != 0xe5, "relative static pointer in absolute write");
    w->ops->put_word(w, site, value);
}

static bool stream_reusable(JbedWriter *w)
{
    (void)w;
    return true;
}

void jbed_block_stream_init(JbedBlockStreamWriter *s, const JbedWriterServices *writer_services,
                            const JbedBlockServices *blocks)
{
    memset(s, 0, sizeof(*s));
    jbed_code_writer_init(&s->base, writer_services, NULL);
    s->blocks = blocks;
    s->ops = *s->base.writer.ops;
    if (s->base.hooks)
        s->hooks = *s->base.hooks;
    s->ops.reusable = stream_reusable;
    s->ops.put_reloc = stream_reloc;
    s->ops.put_call = stream_call;
    s->ops.put_static = stream_static;
    s->hooks.allocation_undone = stream_allocation_undone;
    s->hooks.flush_blocks = stream_flush;
    s->hooks.add_label_fixup = stream_label_fixup;
    s->base.writer.ops = &s->ops;
    s->base.hooks = &s->hooks;
}

void jbed_block_stream_dispose(JbedBlockStreamWriter *s)
{
    dispose_vector(&s->dynamic_chains);
    dispose_vector(&s->large_chains);
    dispose_vector(&s->label_chains);
    dispose_vector(&s->static_chains);
    dispose_vector(&s->static_pages);
    dispose_vector(&s->static_data_chains);
    jbed_code_writer_dispose(&s->base);
}

bool jbed_block_stream_reusable(const JbedBlockStreamWriter *s)
{
    (void)s;
    return true;
}

void jbed_block_stream_store(JbedBlockStreamWriter *s)
{
    jbed_code_flush_all(&s->base);
    require(&s->base.writer, s->close_store != NULL, "abstract block close");
    s->close_store(s);
}

typedef struct MemoryIo {
    JbedWriter *writer;
    uint8_t *bytes;
    uint32_t size, capacity, position;
} MemoryIo;

static bool memory_read(void *context, void *bytes, uint32_t size)
{
    MemoryIo *m = context;
    if (size > m->size - m->position)
        return false;
    if (size)
        memcpy(bytes, m->bytes + m->position, size);
    m->position += size;
    return true;
}

static bool memory_write(void *context, const void *bytes, uint32_t size)
{
    MemoryIo *m = context;
    require(m->writer, size <= UINT32_MAX - m->position, "stream size overflow");
    uint32_t end = m->position + size;
    if (end > m->capacity) {
        uint32_t capacity = end < UINT32_MAX / 2 ? end * 2 : end;
        m->bytes = resize(m->writer, m->bytes, capacity);
        m->capacity = capacity;
    }
    if (size)
        memcpy(m->bytes + m->position, bytes, size);
    m->position = end;
    if (m->size < end)
        m->size = end;
    return true;
}

static bool memory_seek(void *context, uint32_t position)
{
    MemoryIo *m = context;
    if (position > m->size)
        return false;
    m->position = position;
    return true;
}
static uint32_t memory_position(void *context)
{
    return ((MemoryIo *)context)->position;
}
static uint32_t memory_length(void *context)
{
    return ((MemoryIo *)context)->size;
}
static JbedBlockIo memory_io(MemoryIo *m)
{
    return (JbedBlockIo){
        m, memory_read, memory_write, memory_seek, memory_position, memory_length, NULL};
}

typedef struct Deflater {
    z_stream z;
    JbedWriter *writer;
    JbedBlockIo output;
    uint8_t bytes[4096];
} Deflater;

static void deflate_bytes(Deflater *d, const void *bytes, uint32_t size, int flush)
{
    d->z.next_in = (Bytef *)bytes;
    d->z.avail_in = size;
    int status;
    do {
        d->z.next_out = d->bytes;
        d->z.avail_out = sizeof(d->bytes);
        status = deflate(&d->z, flush);
        require(d->writer, status == Z_OK || status == Z_STREAM_END, "deflate failed");
        output(d->writer, &d->output, d->bytes, sizeof(d->bytes) - d->z.avail_out);
    } while (d->z.avail_in || (flush == Z_FINISH && status != Z_STREAM_END));
}

static bool deflater_write(void *context, const void *bytes, uint32_t size)
{
    deflate_bytes(context, bytes, size, Z_NO_FLUSH);
    return true;
}

static JbedBlockIo compressed_output(JbedFileBlockWriter *f)
{
    return (JbedBlockIo){.context = f->deflater, .write = deflater_write};
}

static void store_chains(JbedFileBlockWriter *f, JbedBlockIo *out, JbedBlockVector *heads,
                         const JbedBlockVector *pages, uint32_t count, uint32_t blocks)
{
    JbedCodeBlockWriter *base = &f->stream.base;
    uint32_t start = out->position(out->context), stored = 0;
    output_word(&base->writer, out, 0);
    for (uint32_t i = 0; i < count; ++i) {
        if (!heads->values[i])
            continue;
        heads->values[i] = jbed_code_split_chain(base, heads->values[i], blocks);
        require(&base->writer, blocks != jbed_code_blocks_present(base) || !heads->values[i],
                "fixup chain remains beyond final block");
        if (base->split_chain_head) {
            output_word(&base->writer, out, pages ? pages->values[i] : i);
            output_word(&base->writer, out, base->split_chain_head);
            ++stored;
        }
    }
    uint32_t end = out->position(out->context);
    seek_to(&base->writer, out, start);
    output_word(&base->writer, out, stored);
    seek_to(&base->writer, out, end);
}

static void store_chain_info(JbedFileBlockWriter *f, uint32_t blocks)
{
    JbedBlockStreamWriter *s = &f->stream;
    MemoryIo memory = {.writer = &s->base.writer};
    JbedBlockIo io = memory_io(&memory), compressed = compressed_output(f);
    store_chains(f, &io, &s->dynamic_chains, NULL, s->dynamic_chains.length, blocks);
    store_chains(f, &io, &s->large_chains, NULL, s->large_chains.length, blocks);
    store_chains(f, &io, &s->label_chains, NULL, s->label_chains.length, blocks);
    store_chains(f, &io, &s->static_chains, &s->static_pages, s->static_page_count, blocks);
    output_word(&s->base.writer, &compressed, memory.size);
    output(&s->base.writer, &compressed, memory.bytes, memory.size);
    free(memory.bytes);
}

void jbed_file_writer_store_blocks(JbedFileBlockWriter *f, uint32_t count)
{
    JbedCodeBlockWriter *base = &f->stream.base;
    JbedWriter *w = &base->writer;
    JbedBlockIo compressed = compressed_output(f);
    require(w, count <= jbed_code_blocks_present(base), "invalid block count");
    store_chain_info(f, count);
    uint32_t groups = 0;
    for (uint32_t i = 0; i < count; i = jbed_code_last_joined(base, i) + 1)
        ++groups;
    output_word(w, &compressed, groups);
    for (uint32_t i = 0; i < count;) {
        uint32_t last = jbed_code_last_joined(base, i);
        require(w, last < count, "joined block extends beyond flush");
        uint32_t size = (last - i) * JBED_BLOCK_SIZE + base->used[last];
        output_word(w, &compressed, size);
        output(w, &compressed, base->bytes + i * JBED_BLOCK_SIZE, size);
        if (last != i) {
            ensure(w, &f->joined_ranges, f->joined_words + 2);
            f->joined_ranges.values[f->joined_words++] = f->blocks_stored + i;
            f->joined_ranges.values[f->joined_words++] = size;
        }
        i = last + 1;
    }
    f->blocks_stored += count;
}

static void file_store_blocks(JbedBlockStreamWriter *s, uint32_t count)
{
    jbed_file_writer_store_blocks((JbedFileBlockWriter *)s, count);
}

static void file_store_large(JbedCodeBlockWriter *base)
{
    JbedFileBlockWriter *f = (JbedFileBlockWriter *)base;
    JbedBlockIo compressed = compressed_output(f);
    for (uint32_t i = 0; i < base->large_count; ++i) {
        JbedBuffer *block = base->large_blocks[i];
        output_word(&base->writer, &compressed, block->size);
        output(&base->writer, &compressed, block->data, block->size);
    }
}

void jbed_file_writer_close(JbedFileBlockWriter *f)
{
    JbedCodeBlockWriter *base = &f->stream.base;
    JbedWriter *w = &base->writer;
    require(w, f->deflater && f->output.position, "file writer already closed");
    Deflater *d = f->deflater;
    deflate_bytes(d, NULL, 0, Z_FINISH);
    deflateEnd(&d->z);
    free(d);
    f->deflater = NULL;
    uint32_t footer = f->output.position(f->output.context);
    output_word(w, &f->output, jbed_code_blocks_generated(base));
    output_word(w, &f->output, f->joined_words);
    for (uint32_t i = 0; i < f->joined_words; ++i)
        output_word(w, &f->output, f->joined_ranges.values[i]);
    output_word(w, &f->output, base->large_count);
    for (uint32_t i = 0; i < base->large_count; ++i) {
        output_word(w, &f->output, base->large_bases[i]);
        output_word(w, &f->output, base->large_blocks[i]->size);
    }
    output_word(w, &f->output, w->last_label);
    for (uint32_t i = 1; i <= w->last_label; ++i) {
        require(w, i < w->label_capacity && w->labels[i], "undefined label at file close");
        output_word(w, &f->output, w->labels[i]);
    }
    require(w, jbed_rom_store(base->rom_objects, &f->output), "RomObjects serialization failed");
    seek_to(w, &f->output, 24);
    output_word(w, &f->output, footer);
    if (f->output.close)
        require(w, f->output.close(f->output.context), "file close failed");
}

static void file_close(JbedBlockStreamWriter *s)
{
    jbed_file_writer_close((JbedFileBlockWriter *)s);
}

void jbed_file_writer_init(JbedFileBlockWriter *f, const JbedWriterServices *writer_services,
                           const JbedBlockServices *blocks, JbedBlockIo output_stream,
                           const JbedBlockIdentity *identity)
{
    memset(f, 0, sizeof(*f));
    jbed_block_stream_init(&f->stream, writer_services, blocks);
    f->output = output_stream;
    f->stream.store_blocks = file_store_blocks;
    f->stream.close_store = file_close;
    f->stream.hooks.store_large_blocks = file_store_large;
    JbedWriter *w = &f->stream.base.writer;
    output_word(w, &f->output, FILE_MAGIC);
    output_word(w, &f->output, identity->fingerprint);
    output_word(w, &f->output, identity->system_info_address);
    output_word(w, &f->output, identity->build_id);
    output_word(w, &f->output, FILE_FLAGS | (identity->full_debug_info ? 2 : 0));
    output_word(w, &f->output, JBED_BLOCK_SIZE);
    output_word(w, &f->output, 0);
    Deflater *d = resize(w, NULL, sizeof(*d));
    memset(d, 0, sizeof(*d));
    d->writer = w;
    d->output = f->output;
    /* createDeflater 0xa5d54 selects level 3; CPL_deflate_start uses raw
     * DEFLATE with a 16KiB window and memory level 7. */
    require(w, deflateInit2(&d->z, 3, Z_DEFLATED, -14, 7, Z_DEFAULT_STRATEGY) == Z_OK,
            "cannot initialize deflater");
    f->deflater = d;
}

void jbed_file_writer_dispose(JbedFileBlockWriter *f)
{
    if (f->deflater) {
        Deflater *d = f->deflater;
        deflateEnd(&d->z);
        free(d);
    }
    f->deflater = NULL;
    dispose_vector(&f->joined_ranges);
    jbed_block_stream_dispose(&f->stream);
}

/* DirectCodeBlockWriter, 0x162200..0x162a58. */
static void direct_allocate_space(JbedDirectCodeWriter *d, uint32_t count)
{
    JbedCodeBlockWriter *base = &d->base;
    JbedWriter *w = &base->writer;
    require(w, count <= jbed_code_blocks_generated(base), "allocation exceeds generated code");
    ensure(w, &d->code_addresses, count);
    ensure(w, &d->group_first, count);
    uint32_t local = d->blocks_allocated - d->blocks_stored;
    while (d->blocks_allocated < count) {
        uint32_t last = jbed_code_last_joined(base, local);
        if (last == local) {
            allocate_blocks(w, d->blocks, 1, &d->code_addresses.values[d->blocks_allocated]);
            d->group_first.values[d->blocks_allocated] = d->blocks_allocated;
            ++d->blocks_allocated;
            ++local;
        } else {
            uint32_t size = (last - local) * JBED_BLOCK_SIZE + base->used[last];
            JbedAddress address = allocate_large(w, d->blocks, size)->address;
            uint32_t first = d->blocks_allocated;
            ensure(w, &d->code_addresses, first + last - local + 1);
            ensure(w, &d->group_first, first + last - local + 1);
            while (local <= last) {
                d->code_addresses.values[d->blocks_allocated] = address;
                d->group_first.values[d->blocks_allocated++] = first;
                address += JBED_BLOCK_SIZE;
                ++local;
            }
            jbed_code_prevent_allocations(base, last);
        }
    }
}

JbedAddress jbed_direct_relocate(JbedDirectCodeWriter *d, JbedAddress address)
{
    JbedCodeBlockWriter *base = &d->base;
    JbedWriter *w = &base->writer;
    if ((int32_t)address < (int32_t)JBED_LARGE_BASE) {
        uint32_t index = (address - JBED_CODE_BASE) / JBED_BLOCK_SIZE;
        if (index >= d->blocks_allocated)
            direct_allocate_space(d, index + 1);
        return d->code_addresses.values[index] + (address & (JBED_BLOCK_SIZE - 1));
    }
    uint32_t i = 0;
    while (i < base->large_count && (int32_t)address >= (int32_t)base->large_bases[i])
        ++i;
    require(w, i != 0, "address precedes large blocks");
    return base->large_blocks[i - 1]->address + address - base->large_bases[i - 1];
}

static void direct_check(JbedCodeBlockWriter *base, JbedAddress address, uint32_t size)
{
    if ((int32_t)address >= (int32_t)base->buffer_base)
        jbed_code_check_address(base, address, size);
    else
        require(&base->writer, address >= JBED_CODE_BASE && size <= base->buffer_base - address,
                "address outside generated code");
}

static void direct_put_byte(JbedWriter *w, JbedAddress address, uint8_t value)
{
    JbedDirectCodeWriter *d = (JbedDirectCodeWriter *)w;
    if ((int32_t)address >= (int32_t)d->base.buffer_base)
        d->buffered_ops.put_byte(w, address, value);
    else
        write_code(w, d->blocks, jbed_direct_relocate(d, address), &value, 1);
}

static void direct_put_halfword(JbedWriter *w, JbedAddress address, uint16_t value)
{
    JbedDirectCodeWriter *d = (JbedDirectCodeWriter *)w;
    if ((int32_t)address >= (int32_t)d->base.buffer_base)
        d->buffered_ops.put_halfword(w, address, value);
    else {
        uint8_t bytes[] = {(uint8_t)value, (uint8_t)(value >> 8)};
        write_code(w, d->blocks, jbed_direct_relocate(d, address), bytes, 2);
    }
}

static void direct_put_word(JbedWriter *w, JbedAddress address, uint32_t value)
{
    JbedDirectCodeWriter *d = (JbedDirectCodeWriter *)w;
    if ((int32_t)address >= (int32_t)d->base.buffer_base)
        d->buffered_ops.put_word(w, address, value);
    else {
        uint8_t bytes[4];
        put_le32(bytes, value);
        write_code(w, d->blocks, jbed_direct_relocate(d, address), bytes, 4);
    }
}

static int16_t direct_get_halfword(JbedWriter *w, JbedAddress address)
{
    JbedDirectCodeWriter *d = (JbedDirectCodeWriter *)w;
    if ((int32_t)address >= (int32_t)d->base.buffer_base)
        return d->buffered_ops.get_halfword(w, address);
    uint8_t bytes[2];
    read_code(w, d->blocks, jbed_direct_relocate(d, address), bytes, 2);
    return (int16_t)((uint16_t)bytes[0] | (uint16_t)bytes[1] << 8);
}

static uint32_t direct_get_word(JbedWriter *w, JbedAddress address)
{
    JbedDirectCodeWriter *d = (JbedDirectCodeWriter *)w;
    if ((int32_t)address >= (int32_t)d->base.buffer_base)
        return d->buffered_ops.get_word(w, address);
    uint8_t bytes[4];
    read_code(w, d->blocks, jbed_direct_relocate(d, address), bytes, 4);
    return get_le32(bytes);
}

static void direct_flush(JbedCodeBlockWriter *base, uint32_t count)
{
    JbedDirectCodeWriter *d = (JbedDirectCodeWriter *)base;
    direct_allocate_space(d, d->blocks_stored + count);
    for (uint32_t i = 0; i < count;) {
        uint32_t last = jbed_code_last_joined(base, i);
        require(&base->writer, last < count, "joined block extends beyond direct flush");
        uint32_t size = (last - i) * JBED_BLOCK_SIZE + base->used[last];
        write_code(&base->writer, d->blocks, d->code_addresses.values[d->blocks_stored],
                   base->bytes + i * JBED_BLOCK_SIZE, size);
        d->blocks_stored += last - i + 1;
        i = last + 1;
    }
}

static JbedBuffer *direct_new_large(JbedCodeBlockWriter *base, uint32_t size)
{
    return allocate_large(&base->writer, ((JbedDirectCodeWriter *)base)->blocks, size);
}

static void direct_store_large(JbedCodeBlockWriter *base)
{
    (void)base;
}

static void direct_add_label(JbedCodeBlockWriter *base, JbedAddress site, uint32_t label,
                             uint32_t flags)
{
    JbedDirectCodeWriter *d = (JbedDirectCodeWriter *)base;
    require(&base->writer, flags == 0, "direct call-label fixup is unsupported");
    ensure(&base->writer, &d->label_chains, label + 1);
    direct_put_word(&base->writer, site, d->label_chains.values[label]);
    d->label_chains.values[label] = site;
}

JbedAddress jbed_direct_relocate_label(JbedDirectCodeWriter *d, uint32_t label)
{
    if (!label)
        return 0;
    JbedWriter *w = &d->base.writer;
    require(w, label < w->label_capacity && w->labels[label], "undefined direct label");
    return jbed_direct_relocate(d, w->labels[label]);
}

static void direct_reloc(JbedWriter *w, JbedAddress site, JbedAddress target, bool absolute)
{
    JbedDirectCodeWriter *d = (JbedDirectCodeWriter *)w;
    if (!absolute) {
        direct_check(&d->base, target, 0);
        target = jbed_direct_relocate(d, target);
    }
    direct_put_word(w, site, target);
}

static void direct_call(JbedWriter *w, JbedAddress site, uint32_t instruction, bool absolute)
{
    JbedDirectCodeWriter *d = (JbedDirectCodeWriter *)w;
    JbedAddress target = jbed_thumb_call_destination(site, instruction);
    if (!absolute)
        target = jbed_direct_relocate(d, target);
    uint32_t encoded;
    require(w, jbed_thumb_call_encode(jbed_direct_relocate(d, site), target, &encoded),
            "direct Thumb call is out of range");
    direct_put_word(w, site, encoded);
}

void jbed_direct_write_call_label(JbedDirectCodeWriter *d, JbedAddress site, uint32_t instruction,
                                  uint32_t label)
{
    (void)site;
    (void)instruction;
    (void)label;
    fail(&d->base.writer, "DirectCodeBlockWriter.writeCallLabel is unsupported by the VM");
}

static uint32_t direct_call_label(JbedWriter *w, JbedAddress site, uint32_t instruction,
                                  uint32_t label)
{
    jbed_direct_write_call_label((JbedDirectCodeWriter *)w, site, instruction, label);
    return 0;
}

static JbedAddress direct_address(void *context, JbedAddress address)
{
    return jbed_direct_relocate(context, address);
}

static JbedAddress direct_label(void *context, uint32_t label)
{
    return jbed_direct_relocate_label(context, label);
}

void jbed_direct_cleanup(JbedDirectCodeWriter *d)
{
    JbedWriter *w = &d->base.writer;
    jbed_code_flush_all(&d->base);
    for (uint32_t i = 1; i < d->label_chains.length; ++i) {
        for (JbedAddress site = d->label_chains.values[i]; site;) {
            JbedAddress next = direct_get_word(w, site);
            require(w, i < w->label_capacity, "label chain outside label table");
            direct_reloc(w, site, w->labels[i], w->labels[i] == 0);
            site = next;
        }
    }
    JbedRomRelocator relocator = {d, direct_address, direct_label};
    jbed_rom_prepare_generated(d->base.rom_objects, &relocator);
}

static void cleanup_direct_writer(JbedWriter *w)
{
    jbed_direct_cleanup((JbedDirectCodeWriter *)w);
}

void jbed_direct_writer_init(JbedDirectCodeWriter *d, const JbedWriterServices *writer_services,
                             const JbedBlockServices *blocks)
{
    memset(d, 0, sizeof(*d));
    jbed_code_writer_init(&d->base, writer_services, NULL);
    d->blocks = blocks;
    d->buffered_ops = *d->base.writer.ops;
    d->ops = d->buffered_ops;
    if (d->base.hooks)
        d->hooks = *d->base.hooks;
    d->ops.put_word = direct_put_word;
    d->ops.put_halfword = direct_put_halfword;
    d->ops.put_byte = direct_put_byte;
    d->ops.put_reloc = direct_reloc;
    d->ops.put_static = stream_static;
    d->ops.put_call = direct_call;
    d->ops.get_word = direct_get_word;
    d->ops.get_halfword = direct_get_halfword;
    d->ops.write_call_label = direct_call_label;
    d->ops.cleanup = cleanup_direct_writer;
    d->hooks.flush_blocks = direct_flush;
    d->hooks.new_large_block = direct_new_large;
    d->hooks.store_large_blocks = direct_store_large;
    d->hooks.add_label_fixup = direct_add_label;
    d->hooks.check_address = direct_check;
    d->base.writer.ops = &d->ops;
    d->base.hooks = &d->hooks;
}

void jbed_direct_writer_dispose(JbedDirectCodeWriter *d)
{
    dispose_vector(&d->label_chains);
    dispose_vector(&d->code_addresses);
    dispose_vector(&d->group_first);
    jbed_code_writer_dispose(&d->base);
}

/* XipBlockStreamWriter, 0x175394..0x175f70. */
static int32_t chain_delta(uint32_t word)
{
    int32_t delta = (int32_t)(word >> JBED_FIXUP_DELTA_SHIFT);
    return (word & UINT32_C(0x80000000)) ? delta - JBED_FIXUP_DELTA_RANGE : delta;
}

static void xip_allocate_code(JbedXipBlockWriter *x)
{
    JbedCodeBlockWriter *base = &x->stream.base;
    JbedWriter *w = &base->writer;
    uint32_t count = jbed_code_blocks_generated(base);
    ensure(w, &x->code_addresses, count);
    require(w, JBED_CODE_BASE + x->blocks_stored * JBED_BLOCK_SIZE == base->buffer_base,
            "XIP allocation and buffer base disagree");
    uint32_t local = x->blocks_allocated - x->blocks_stored;
    while (x->blocks_allocated < count) {
        uint32_t last = jbed_code_last_joined(base, local);
        if (last == local) {
            allocate_blocks(w, x->stream.blocks, 1,
                            &x->code_addresses.values[x->blocks_allocated++]);
            ++local;
        } else {
            uint32_t size = (last - local) * JBED_BLOCK_SIZE + base->used[last];
            JbedAddress address = allocate_large(w, x->stream.blocks, size)->address;
            while (local <= last) {
                x->code_addresses.values[x->blocks_allocated++] = address;
                address += JBED_BLOCK_SIZE;
                ++local;
            }
            jbed_code_prevent_allocations(base, last);
        }
    }
}

static void xip_allocate_large(JbedXipBlockWriter *x)
{
    JbedCodeBlockWriter *base = &x->stream.base;
    ensure(&base->writer, &x->large_addresses, base->large_count);
    while (x->large_allocated < base->large_count) {
        uint32_t i = x->large_allocated++;
        x->large_addresses.values[i] =
            allocate_large(&base->writer, x->stream.blocks, base->large_blocks[i]->size)->address;
    }
}

JbedAddress jbed_xip_relocate(JbedXipBlockWriter *x, JbedAddress address)
{
    JbedCodeBlockWriter *base = &x->stream.base;
    if ((int32_t)address < (int32_t)JBED_LARGE_BASE) {
        uint32_t index = (address - JBED_CODE_BASE) / JBED_BLOCK_SIZE;
        if (index >= x->blocks_allocated)
            xip_allocate_code(x);
        require(&base->writer, index < x->blocks_allocated, "XIP address exceeds generated code");
        return x->code_addresses.values[index] + (address & (JBED_BLOCK_SIZE - 1));
    }
    require(&base->writer, base->large_count != 0, "XIP large address without allocation");
    uint32_t i = 1;
    while (i < base->large_count && (int32_t)address >= (int32_t)base->large_bases[i])
        ++i;
    --i;
    if (i >= x->large_allocated)
        xip_allocate_large(x);
    return x->large_addresses.values[i] + address - base->large_bases[i];
}

bool jbed_xip_label_defined(const JbedXipBlockWriter *x, uint32_t label)
{
    const JbedWriter *w = &x->stream.base.writer;
    return label < w->label_capacity && w->labels[label] != 0;
}

JbedAddress jbed_xip_relocate_label(JbedXipBlockWriter *x, uint32_t label)
{
    require(&x->stream.base.writer, jbed_xip_label_defined(x, label), "undefined XIP label");
    return x->stream.base.writer.labels[label];
}

static void xip_reloc(JbedWriter *w, JbedAddress site, JbedAddress target, bool absolute)
{
    if (!absolute)
        target = jbed_xip_relocate((JbedXipBlockWriter *)w, target);
    w->ops->put_word(w, site, target);
}

static uint32_t encode_call(JbedWriter *w, JbedAddress site, JbedAddress target)
{
    uint32_t word;
    require(w, jbed_thumb_call_encode(site, target, &word), "Thumb call is out of range");
    return word;
}

static void xip_call(JbedWriter *w, JbedAddress site, uint32_t instruction, bool absolute)
{
    JbedXipBlockWriter *x = (JbedXipBlockWriter *)w;
    JbedAddress target = jbed_thumb_call_destination(site, instruction);
    if (!absolute)
        target = jbed_xip_relocate(x, target);
    w->ops->put_word(w, site, encode_call(w, jbed_xip_relocate(x, site), target));
}

static uint32_t xip_write_label(JbedWriter *w, JbedAddress site, uint32_t label)
{
    JbedXipBlockWriter *x = (JbedXipBlockWriter *)w;
    if (!label || !jbed_xip_label_defined(x, label))
        return jbed_code_write_label(&x->stream.base, site, label);
    w->ops->put_word(w, site, w->labels[label]);
    return label;
}

uint32_t jbed_xip_write_call_label(JbedXipBlockWriter *x, JbedAddress site, uint32_t instruction,
                                   uint32_t label)
{
    JbedWriter *w = &x->stream.base.writer;
    if (!label || !jbed_xip_label_defined(x, label))
        return jbed_code_write_call_label(&x->stream.base, site, instruction, label);
    w->ops->put_word(w, site, encode_call(w, jbed_xip_relocate(x, site), w->labels[label]));
    return label;
}

static uint32_t xip_call_label(JbedWriter *w, JbedAddress site, uint32_t instruction,
                               uint32_t label)
{
    return jbed_xip_write_call_label((JbedXipBlockWriter *)w, site, instruction, label);
}

static void xip_set_label(JbedWriter *w, uint32_t label, JbedAddress address)
{
    jbed_writer_define_label(w, label, jbed_xip_relocate((JbedXipBlockWriter *)w, address));
}

static JbedAddress xip_fix_label_chain(JbedXipBlockWriter *x, JbedAddress site, uint32_t page,
                                       JbedAddress cutoff)
{
    JbedCodeBlockWriter *base = &x->stream.base;
    JbedWriter *w = &base->writer;
    JbedAddress retained = 0;
    while (site) {
        uint32_t word = w->ops->get_word(w, site);
        uint32_t label = (page << JBED_FIXUP_PAGE_SHIFT) | (word & JBED_FIXUP_PAGE_MASK);
        uint32_t replacement;
        if (!cutoff || jbed_xip_label_defined(x, label)) {
            JbedAddress target = jbed_xip_relocate_label(x, label);
            replacement =
                (word & JBED_FIXUP_CALL) ? encode_call(w, jbed_xip_relocate(x, site), target) : target;
        } else if (site >= cutoff) {
            replacement = word & JBED_FIXUP_METADATA_MASK;
            if (retained)
                replacement |= (retained - site) << 15;
            retained = site;
        } else {
            uint32_t index = jbed_code_block_index(base, site);
            require(w, index < JBED_BUFFER_BLOCKS, "XIP deferred chain outside buffer");
            replacement = word & JBED_FIXUP_METADATA_MASK;
            if (x->deferred_heads[index])
                replacement |= (x->deferred_heads[index] - site) << 15;
            x->deferred_heads[index] = site;
        }
        w->ops->put_word(w, site, replacement);
        int32_t delta = chain_delta(word);
        if (!delta)
            break;
        site += (uint32_t)delta;
    }
    return retained;
}

static void xip_fix_labels(JbedXipBlockWriter *x, uint32_t count)
{
    JbedBlockStreamWriter *s = &x->stream;
    memset(x->deferred_heads, 0, sizeof(x->deferred_heads));
    JbedAddress cutoff = jbed_code_block_base(&s->base, count);
    for (uint32_t page = 0; page < s->label_chains.length; ++page) {
        s->label_chains.values[page] =
            xip_fix_label_chain(x, s->label_chains.values[page], page, cutoff);
        ensure(&s->base.writer, &x->pending_heads, x->pending_count + JBED_BUFFER_BLOCKS);
        ensure(&s->base.writer, &x->pending_pages, x->pending_count + JBED_BUFFER_BLOCKS);
        for (uint32_t i = 0; i < JBED_BUFFER_BLOCKS; ++i) {
            if (!x->deferred_heads[i])
                continue;
            x->pending_heads.values[x->pending_count] = x->deferred_heads[i];
            x->pending_pages.values[x->pending_count++] = page;
            x->deferred_heads[i] = 0;
        }
    }
}

static void xip_store_blocks(JbedBlockStreamWriter *s, uint32_t count)
{
    JbedXipBlockWriter *x = (JbedXipBlockWriter *)s;
    xip_allocate_code(x);
    xip_fix_labels(x, count);
    if (s->blocks->begin_write)
        s->blocks->begin_write(s->blocks->context);
    for (uint32_t i = 0; i < count; ++i)
        write_code(&s->base.writer, s->blocks, x->code_addresses.values[x->blocks_stored++],
                   s->base.bytes + i * JBED_BLOCK_SIZE, s->base.used[i]);
    if (s->blocks->end_write)
        s->blocks->end_write(s->blocks->context);
}

static void xip_store_large(JbedCodeBlockWriter *base)
{
    JbedXipBlockWriter *x = (JbedXipBlockWriter *)base;
    xip_allocate_large(x);
    for (uint32_t i = 0; i < base->large_count; ++i)
        write_code(&base->writer, x->stream.blocks, x->large_addresses.values[i],
                   base->large_blocks[i]->data, base->large_blocks[i]->size);
}

static void xip_generate_extra(JbedCodeBlockWriter *base)
{
    JbedXipBlockWriter *x = (JbedXipBlockWriter *)base;
    x->install_address = jbed_rom_generate_xip(base->rom_objects);
}

static void xip_close(JbedBlockStreamWriter *s)
{
    JbedXipBlockWriter *x = (JbedXipBlockWriter *)s;
    JbedWriter *w = &s->base.writer;
    require(w, s->base.used[0] == 0, "XIP close requires an empty staging block");
    uint8_t bytes[JBED_BLOCK_SIZE];
    if (s->blocks->begin_write)
        s->blocks->begin_write(s->blocks->context);
    for (uint32_t i = 0; i < x->pending_count; ++i) {
        JbedAddress site = x->pending_heads.values[i];
        if (!site)
            continue;
        uint32_t index = (site - JBED_CODE_BASE) / JBED_BLOCK_SIZE;
        require(w, index < x->blocks_allocated, "deferred XIP block is unallocated");
        JbedAddress virtual_base = site & ~(JBED_BLOCK_SIZE - 1);
        JbedAddress actual_base = x->code_addresses.values[index];
        read_code(w, s->blocks, actual_base, bytes, sizeof(bytes));
        for (;;) {
            uint32_t offset = site - virtual_base;
            require(w, offset <= JBED_BLOCK_SIZE - 4, "XIP deferred chain crosses a block");
            uint32_t word = get_le32(bytes + offset);
            uint32_t label =
                (x->pending_pages.values[i] << JBED_FIXUP_PAGE_SHIFT) | (word & JBED_FIXUP_PAGE_MASK);
            JbedAddress target = jbed_xip_relocate_label(x, label);
            put_le32(bytes + offset,
                     (word & JBED_FIXUP_CALL) ? encode_call(w, actual_base + offset, target) : target);
            int32_t delta = chain_delta(word);
            if (!delta)
                break;
            site += (uint32_t)delta;
        }
        write_code(w, s->blocks, actual_base, bytes, sizeof(bytes));
        x->pending_heads.values[i] = 0;
    }
    if (s->blocks->end_write)
        s->blocks->end_write(s->blocks->context);
    s->base.access_forbidden = true;
}

JbedAddress jbed_xip_install_address(JbedXipBlockWriter *x)
{
    require(&x->stream.base.writer, x->install_address != 0, "XIP installation address is unset");
    return jbed_xip_relocate(x, x->install_address);
}

void jbed_xip_writer_init(JbedXipBlockWriter *x, const JbedWriterServices *writer_services,
                          const JbedBlockServices *blocks)
{
    memset(x, 0, sizeof(*x));
    jbed_block_stream_init(&x->stream, writer_services, blocks);
    x->buffered_ops = x->stream.ops;
    x->stream.ops.put_reloc = xip_reloc;
    x->stream.ops.put_call = xip_call;
    x->stream.ops.write_label = xip_write_label;
    x->stream.ops.write_call_label = xip_call_label;
    x->stream.ops.set_label = xip_set_label;
    x->stream.hooks.store_large_blocks = xip_store_large;
    x->stream.hooks.generate_extra_data = xip_generate_extra;
    x->stream.store_blocks = xip_store_blocks;
    x->stream.close_store = xip_close;
}

void jbed_xip_writer_dispose(JbedXipBlockWriter *x)
{
    dispose_vector(&x->code_addresses);
    dispose_vector(&x->large_addresses);
    dispose_vector(&x->pending_heads);
    dispose_vector(&x->pending_pages);
    jbed_block_stream_dispose(&x->stream);
}

/* FileBlockStreamLoader, 0x1609be..0x1615d8. */
static _Noreturn void load_fault(JbedFileBlockLoader *l, JbedBlockLoadFault code,
                                 const char *message)
{
    if (l->blocks->load_fault)
        l->blocks->load_fault(l->blocks->context, code, message);
    fail(&l->diagnostics, message);
}

typedef struct Inflater {
    z_stream z;
    JbedWriter *writer;
    JbedBlockIo source;
    uint32_t remaining;
    bool ended;
    uint8_t bytes[4096];
} Inflater;

static bool inflater_read(void *context, void *bytes, uint32_t size)
{
    Inflater *d = context;
    d->z.next_out = bytes;
    d->z.avail_out = size;
    while (d->z.avail_out) {
        if (d->ended)
            return false;
        if (!d->z.avail_in && d->remaining) {
            uint32_t n = d->remaining < sizeof(d->bytes) ? d->remaining : sizeof(d->bytes);
            input(d->writer, &d->source, d->bytes, n);
            d->z.next_in = d->bytes;
            d->z.avail_in = n;
            d->remaining -= n;
        }
        uInt before = d->z.avail_out;
        int status = inflate(&d->z, Z_NO_FLUSH);
        if (status == Z_STREAM_END)
            d->ended = true;
        else if (status != Z_OK)
            return false;
        if (before == d->z.avail_out && !d->z.avail_in && !d->remaining)
            return false;
    }
    return true;
}

JbedAddress jbed_file_loader_relocate(JbedFileBlockLoader *l, JbedAddress address)
{
    if (!address)
        return 0;
    if ((int32_t)address < (int32_t)JBED_LARGE_BASE) {
        uint32_t index = (address - JBED_CODE_BASE) / JBED_BLOCK_SIZE;
        require(&l->diagnostics, index < l->code_count, "code relocation outside block table");
        return l->code_addresses.values[index] + (address & (JBED_BLOCK_SIZE - 1));
    }
    require(&l->diagnostics, l->large_count != 0, "large relocation without large blocks");
    uint32_t i = 1;
    while (i < l->large_count && (int32_t)address >= (int32_t)l->large_bases.values[i])
        ++i;
    return l->large_addresses.values[i - 1] + address - l->large_bases.values[i - 1];
}

JbedAddress jbed_file_loader_relocate_label(JbedFileBlockLoader *l, uint32_t label)
{
    require(&l->diagnostics, label <= l->label_count, "label relocation outside label table");
    return l->labels.values[label];
}

JbedAddress jbed_file_loader_fixup(JbedFileBlockLoader *l, JbedAddress site,
                                   JbedAddress target_base, bool relocate, bool label)
{
    JbedWriter *w = &l->diagnostics;
    uint32_t offset = site & (JBED_BLOCK_SIZE - 1);
    JbedAddress actual = jbed_file_loader_relocate(l, site);
    for (;;) {
        require(w, offset <= JBED_BLOCK_SIZE - 4 && offset + 4 <= l->buffer_size,
                "fixup word crosses a staging block");
        uint32_t word = get_le32(l->buffer + offset);
        JbedAddress target = target_base + (word & JBED_FIXUP_PAGE_MASK);
        if (relocate)
            target = jbed_file_loader_relocate(l, target);
        else if (label)
            target = jbed_file_loader_relocate_label(l, target);
        put_le32(l->buffer + offset, (word & JBED_FIXUP_CALL) ? encode_call(w, actual, target) : target);
        int32_t delta = chain_delta(word);
        if (!delta)
            return 0;
        site += (uint32_t)delta;
        actual += (uint32_t)delta;
        int64_t next = (int64_t)offset + delta;
        require(w, next >= 0, "fixup chain precedes current block");
        if (next >= JBED_BLOCK_SIZE)
            return site;
        offset = (uint32_t)next;
    }
}

static void read_chain_group(JbedFileBlockLoader *l, JbedBlockIo *io, JbedBlockVector *chains,
                             uint32_t pages)
{
    clear_vector(&l->diagnostics, chains, pages);
    uint32_t count = input_word(&l->diagnostics, io);
    require(&l->diagnostics, count <= pages, "too many relocation chains");
    for (uint32_t i = 0; i < count; ++i) {
        uint32_t page = input_word(&l->diagnostics, io);
        JbedAddress head = input_word(&l->diagnostics, io);
        require(&l->diagnostics, page < pages && !chains->values[page], "invalid relocation page");
        chains->values[page] = head;
    }
}

static void load_chain_info(JbedFileBlockLoader *l, JbedBlockIo *io)
{
    read_chain_group(l, io, &l->dynamic_chains,
                     (l->code_count * JBED_BLOCK_SIZE >> JBED_FIXUP_PAGE_SHIFT) + 1);
    read_chain_group(l, io, &l->large_chains, (l->large_extent >> JBED_FIXUP_PAGE_SHIFT) + 1);
    read_chain_group(l, io, &l->label_chains, ((l->label_count + 1) >> JBED_FIXUP_PAGE_SHIFT) + 1);
    uint32_t count = input_word(&l->diagnostics, io);
    clear_vector(&l->diagnostics, &l->static_chains, count);
    clear_vector(&l->diagnostics, &l->static_pages, count);
    for (uint32_t i = 0; i < count; ++i) {
        l->static_pages.values[i] = input_word(&l->diagnostics, io);
        l->static_chains.values[i] = input_word(&l->diagnostics, io);
    }
}

static void fix_group(JbedFileBlockLoader *l, JbedBlockVector *chains, const JbedBlockVector *pages,
                      JbedAddress base, JbedAddress end, bool relocate, bool label)
{
    for (uint32_t i = 0; i < chains->length; ++i) {
        JbedAddress site = chains->values[i];
        if (site && site < end) {
            JbedAddress target = pages ? pages->values[i] : base + (i << JBED_FIXUP_PAGE_SHIFT);
            chains->values[i] = jbed_file_loader_fixup(l, site, target, relocate, label);
        }
    }
}

static void exhausted(JbedFileBlockLoader *l, const JbedBlockVector *chains)
{
    for (uint32_t i = 0; i < chains->length; ++i)
        require(&l->diagnostics, chains->values[i] == 0, "unconsumed relocation chain");
}

static uint32_t load_code_batch(JbedFileBlockLoader *l, JbedBlockIo *io, uint32_t next)
{
    JbedWriter *w = &l->diagnostics;
    uint32_t groups = input_word(w, io);
    require(w, groups && groups <= l->code_count - next, "invalid code group count");
    for (uint32_t i = 0; i < groups; ++i) {
        uint32_t remaining = input_word(w, io);
        require(w,
                remaining && ((uint64_t)remaining + JBED_BLOCK_SIZE - 1) / JBED_BLOCK_SIZE <=
                                 l->code_count - next,
                "invalid joined block size");
        while (remaining) {
            uint32_t size = remaining < JBED_BLOCK_SIZE ? remaining : JBED_BLOCK_SIZE;
            JbedAddress virtual_base = JBED_CODE_BASE + next * JBED_BLOCK_SIZE;
            memset(l->buffer, 0, JBED_BLOCK_SIZE);
            input(w, io, l->buffer, size);
            JbedAddress end = virtual_base + size;
            fix_group(l, &l->dynamic_chains, NULL, JBED_CODE_BASE, end, true, false);
            fix_group(l, &l->large_chains, NULL, JBED_LARGE_BASE, end, true, false);
            fix_group(l, &l->static_chains, &l->static_pages, 0, end, false, false);
            fix_group(l, &l->label_chains, NULL, 0, end, false, true);
            write_code(w, l->blocks, jbed_file_loader_relocate(l, virtual_base), l->buffer, size);
            ++next;
            remaining -= size;
        }
    }
    exhausted(l, &l->dynamic_chains);
    exhausted(l, &l->large_chains);
    exhausted(l, &l->static_chains);
    exhausted(l, &l->label_chains);
    return next;
}

static void read_binary(JbedFileBlockLoader *l, JbedBlockIo source, uint32_t compressed_length,
                        uint32_t largest_block)
{
    JbedWriter *w = &l->diagnostics;
    l->buffer_size = largest_block > JBED_BLOCK_SIZE ? largest_block : JBED_BLOCK_SIZE;
    l->buffer = resize(w, l->buffer, l->buffer_size);
    Inflater inflater = {.writer = w, .source = source, .remaining = compressed_length};
    require(w, inflateInit2(&inflater.z, -14) == Z_OK, "cannot initialize inflater");
    JbedBlockIo compressed = {.context = &inflater, .read = inflater_read};
    MemoryIo chain_data = {.writer = w};
    uint32_t next = 0;
    while (next < l->code_count) {
        uint32_t size = input_word(w, &compressed);
        require(w, size >= 16 && !(size & 3), "invalid chain metadata size");
        chain_data.bytes = resize(w, chain_data.bytes, size);
        chain_data.size = chain_data.capacity = size;
        chain_data.position = 0;
        input(w, &compressed, chain_data.bytes, size);
        JbedBlockIo chains = memory_io(&chain_data);
        load_chain_info(l, &chains);
        require(w, chain_data.position == size, "extra chain metadata words");
        next = load_code_batch(l, &compressed, next);
    }
    free(chain_data.bytes);
    for (uint32_t i = 0; i < l->large_count; ++i) {
        uint32_t size = input_word(w, &compressed);
        require(w, size <= l->buffer_size, "large block exceeds staging buffer");
        input(w, &compressed, l->buffer, size);
        write_code(w, l->blocks, l->large_addresses.values[i], l->buffer, size);
    }
    inflateEnd(&inflater.z);
    free(l->buffer);
    l->buffer = NULL;
    l->buffer_size = 0;
    dispose_vector(&l->dynamic_chains);
    dispose_vector(&l->large_chains);
    dispose_vector(&l->label_chains);
    dispose_vector(&l->static_chains);
    dispose_vector(&l->static_pages);
}

static uint32_t read_header(JbedFileBlockLoader *l, JbedBlockIo *io)
{
    JbedWriter *w = &l->diagnostics;
    uint32_t magic = input_word(w, io);
    if (magic != FILE_MAGIC)
        load_fault(l, JBED_BLOCK_BAD_MAGIC, "invalid compiled-file magic");
    uint32_t fingerprint = input_word(w, io), system_info = input_word(w, io);
    if (fingerprint != l->identity.fingerprint || system_info != l->identity.system_info_address)
        load_fault(l, JBED_BLOCK_WRONG_VM, "compiled file belongs to another VM image");
    if (input_word(w, io) != l->identity.build_id)
        load_fault(l, JBED_BLOCK_WRONG_BUILD, "compiled file belongs to another build");
    l->flags = input_word(w, io);
    require(w, (int32_t)l->flags >> 24 >= 100 && (l->flags & 4),
            "unsupported compiled-file format");
    require(w, input_word(w, io) == JBED_BLOCK_SIZE, "compiled block size mismatch");
    return input_word(w, io);
}

static JbedAddress loader_address(void *context, JbedAddress address)
{
    return jbed_file_loader_relocate(context, address);
}

static JbedAddress loader_label(void *context, uint32_t label)
{
    return jbed_file_loader_relocate_label(context, label);
}

void jbed_file_loader_load(JbedFileBlockLoader *l, JbedBlockIo source)
{
    JbedWriter *w = &l->diagnostics;
    uint32_t footer_offset = read_header(l, &source);
    require(w, source.length != NULL, "compiled input is not seekable");
    uint32_t length = source.length(source.context);
    require(w, footer_offset >= 28 && footer_offset <= length, "invalid compiled footer offset");
    seek_to(w, &source, footer_offset);
    MemoryIo footer = {.writer = w, .size = length - footer_offset};
    footer.bytes = resize(w, NULL, footer.size);
    footer.capacity = footer.size;
    input(w, &source, footer.bytes, footer.size);
    JbedBlockIo io = memory_io(&footer);
    l->code_count = input_word(w, &io);
    require(w,
            l->code_count > 0 &&
                l->code_count <= (JBED_LARGE_BASE - JBED_CODE_BASE) / JBED_BLOCK_SIZE,
            "invalid compiled code block count");
    clear_vector(w, &l->code_addresses, l->code_count);
    uint32_t joined_words = input_word(w, &io), next = 0;
    require(w, !(joined_words & 1) && joined_words / 2 <= l->code_count,
            "invalid joined-block table");
    for (uint32_t i = 0; i <= joined_words; i += 2) {
        uint32_t start = i == joined_words ? l->code_count : input_word(w, &io);
        uint32_t size = i == joined_words ? 0 : input_word(w, &io);
        require(w, start >= next && start <= l->code_count, "unordered joined-block table");
        if (start != next)
            allocate_blocks(w, l->blocks, start - next, l->code_addresses.values + next);
        next = start;
        if (size) {
            uint32_t count = (uint32_t)(((uint64_t)size + JBED_BLOCK_SIZE - 1) / JBED_BLOCK_SIZE);
            require(w, count <= l->code_count - next, "joined range exceeds code table");
            JbedAddress address = allocate_large(w, l->blocks, size)->address;
            for (uint32_t j = 0; j < count; ++j) {
                l->code_addresses.values[next++] = address;
                address += JBED_BLOCK_SIZE;
            }
        }
    }
    JbedAddress low = UINT32_MAX, high = 0;
    for (uint32_t i = 0; i < l->code_count; ++i) {
        JbedAddress address = l->code_addresses.values[i];
        require(w, address <= UINT32_MAX - JBED_BLOCK_SIZE, "code allocation address overflow");
        if (address < low)
            low = address;
        if (address + JBED_BLOCK_SIZE > high)
            high = address + JBED_BLOCK_SIZE;
    }
    require(w, high > low && high - low < UINT32_C(0x400000),
            "code allocations exceed Thumb call range");
    l->large_count = input_word(w, &io);
    require(w, l->large_count <= (footer.size - footer.position) / 8, "invalid large-block table");
    clear_vector(w, &l->large_addresses, l->large_count);
    clear_vector(w, &l->large_bases, l->large_count);
    uint32_t largest = 0;
    l->large_extent = 0;
    for (uint32_t i = 0; i < l->large_count; ++i) {
        JbedAddress virtual_base = input_word(w, &io);
        uint32_t size = input_word(w, &io);
        require(w,
                virtual_base >= JBED_LARGE_BASE && size <= UINT32_MAX - virtual_base &&
                    (!i || virtual_base > l->large_bases.values[i - 1]),
                "invalid large-block address");
        l->large_bases.values[i] = virtual_base;
        l->large_addresses.values[i] = allocate_large(w, l->blocks, size)->address;
        l->large_extent = virtual_base + size - JBED_LARGE_BASE;
        if (size > largest)
            largest = size;
    }
    l->label_count = input_word(w, &io);
    require(w, l->label_count < UINT32_MAX && l->label_count <= (footer.size - footer.position) / 4,
            "invalid label table");
    clear_vector(w, &l->labels, l->label_count + 1);
    for (uint32_t i = 1; i <= l->label_count; ++i)
        l->labels.values[i] = jbed_file_loader_relocate(l, input_word(w, &io));
    require(w, l->blocks->rom_services != NULL, "missing ROM runtime services");
    JbedRomRelocator relocator = {l, loader_address, loader_label};
    JbedRomObjects *objects = jbed_rom_load(l->blocks->rom_services, &io, &relocator);
    (void)jbed_rom_primitive_statics_base(objects);
    (void)jbed_rom_pointer_statics_base(objects);
    (void)jbed_rom_init_flags_base(objects);
    free(footer.bytes);
    seek_to(w, &source, 28);
    read_binary(l, source, footer_offset - 28, largest);
    jbed_rom_prepare_loaded(objects);
}

void jbed_file_loader_init(JbedFileBlockLoader *l, const JbedWriterServices *writer_services,
                           const JbedBlockServices *blocks, const JbedBlockIdentity *identity)
{
    memset(l, 0, sizeof(*l));
    jbed_writer_init(&l->diagnostics, writer_services);
    l->blocks = blocks;
    l->identity = *identity;
}

void jbed_file_loader_dispose(JbedFileBlockLoader *l)
{
    dispose_vector(&l->code_addresses);
    dispose_vector(&l->large_addresses);
    dispose_vector(&l->large_bases);
    dispose_vector(&l->labels);
    dispose_vector(&l->dynamic_chains);
    dispose_vector(&l->large_chains);
    dispose_vector(&l->label_chains);
    dispose_vector(&l->static_chains);
    dispose_vector(&l->static_pages);
    free(l->buffer);
    l->buffer = NULL;
    jbed_writer_dispose(&l->diagnostics);
}
