#include "block_stream.h"
#include "rom_objects.h"

#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <zlib.h>

#define HEAP_BASE UINT32_C(0x10000000)

typedef struct {
    uint8_t heap[1024 * 1024];
    JbedBuffer buffers[128];
    uint32_t heap_next, buffer_count, empty_arrays, published;
    void *managed[256];
    uint32_t managed_count;
    JbedRuntime runtime;
    JbedRomServices rom;
    JbedWriterServices writer;
    JbedBlockServices blocks;
} Host;

typedef struct {
    uint8_t bytes[32768];
    uint32_t position, length;
} File;

static uint32_t le32(const uint8_t *p)
{
    return (uint32_t)p[0] | (uint32_t)p[1] << 8 | (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
}
static uint32_t be32(const uint8_t *p)
{
    return (uint32_t)p[0] << 24 | (uint32_t)p[1] << 16 | (uint32_t)p[2] << 8 | p[3];
}
static void set_le32(uint8_t *p, uint32_t v)
{
    for (unsigned i = 0; i < 4; ++i)
        p[i] = (uint8_t)(v >> (8 * i));
}

static void fault(void *context, JbedWriterFault kind, const char *message)
{
    (void)context;
    fprintf(stderr, "writer fault %d: %s\n", kind, message);
    abort();
}
static void raise_error(void *context, const JbedError *error)
{
    (void)context;
    fprintf(stderr, "runtime error: %s\n", error->message);
    abort();
}
static void *managed_allocate(void *context, size_t size)
{
    Host *h = context;
    assert(h->managed_count < 256);
    void *p = calloc(1, size ? size : 1);
    assert(p);
    h->managed[h->managed_count++] = p;
    return p;
}
static int32_t no_prefix(void *context)
{
    (void)context;
    return -1;
}
static uint32_t zero(void *context)
{
    (void)context;
    return 0;
}
static uint32_t map_id(void *context)
{
    (void)context;
    return 77;
}
static JbedAddress empty_array(void *context, bool references)
{
    Host *h = context;
    (void)references;
    return UINT32_C(0x20000000) + 16 * h->empty_arrays++;
}
static void sync_extend(void *context, int32_t count)
{
    (void)context;
    assert(count == 0);
}
static void statics_extend(void *context, uint32_t size, JbedAddress ranges)
{
    (void)context;
    assert(size == 0 && ranges == 0);
}
static void install_strings(void *context, const JbedAddress *strings, uint32_t count)
{
    (void)context;
    (void)strings;
    assert(count == 0);
}
static void load_bundle(void *context, uint32_t bundle, JbedAddress classes, JbedAddress packages,
                        JbedAddress names)
{
    Host *h = context;
    assert(!bundle && !classes && !packages && !names);
    ++h->published;
}
static void set_anchor(void *context, uint32_t id, const JbedRomObjectView *objects, uint32_t count)
{
    (void)context;
    (void)objects;
    assert(id == 77 && count == 0);
}

static JbedBuffer *large(void *context, uint32_t size)
{
    Host *h = context;
    uint32_t reserved = (size + 8191) & ~UINT32_C(8191);
    assert(h->buffer_count < 128 && reserved <= sizeof(h->heap) - h->heap_next);
    JbedBuffer *b = &h->buffers[h->buffer_count++];
    *b = (JbedBuffer){h->heap + h->heap_next, size, HEAP_BASE + h->heap_next};
    h->heap_next += reserved;
    return b;
}
static bool allocate_blocks(void *context, uint32_t count, JbedAddress *addresses)
{
    Host *h = context;
    for (uint32_t i = 0; i < count; ++i) {
        addresses[i] = large(h, JBED_BLOCK_SIZE)->address;
        /* Separate ordinary slots to detect accidental linear relocation. */
        assert(h->heap_next + JBED_BLOCK_SIZE <= sizeof(h->heap));
        h->heap_next += JBED_BLOCK_SIZE;
    }
    return true;
}
static bool heap_read(void *context, JbedAddress address, void *bytes, uint32_t size)
{
    Host *h = context;
    assert(address >= HEAP_BASE && address - HEAP_BASE <= sizeof(h->heap) - size);
    memcpy(bytes, h->heap + (address - HEAP_BASE), size);
    return true;
}
static bool heap_write(void *context, JbedAddress address, const void *bytes, uint32_t size)
{
    Host *h = context;
    assert(address >= HEAP_BASE && address - HEAP_BASE <= sizeof(h->heap) - size);
    memcpy(h->heap + (address - HEAP_BASE), bytes, size);
    return true;
}
static Host *new_host(void)
{
    Host *h = calloc(1, sizeof(*h));
    assert(h);
    h->runtime = (JbedRuntime){
        .context = h, .allocate_zeroed = managed_allocate, .raise_error = raise_error};
    h->rom = (JbedRomServices){.runtime = &h->runtime,
                               .context = h,
                               .new_empty_locked_array = empty_array,
                               .sync_table_size = zero,
                               .extend_synchronizers = sync_extend,
                               .extend_statics = statics_extend,
                               .install_string_table = install_strings,
                               .stack_map_id = map_id,
                               .load_bundle = load_bundle,
                               .set_anchor_parameters = set_anchor};
    h->writer = (JbedWriterServices){.context = h,
                                     .fault = fault,
                                     .rom_services = &h->rom,
                                     .allocation_test_property = no_prefix};
    h->blocks = (JbedBlockServices){.context = h,
                                    .allocate_blocks = allocate_blocks,
                                    .allocate_large_block = large,
                                    .read_code = heap_read,
                                    .write_code = heap_write,
                                    .rom_services = &h->rom};
    return h;
}
static void free_host(Host *h)
{
    for (uint32_t i = 0; i < h->managed_count; ++i)
        free(h->managed[i]);
    free(h);
}

static bool file_read(void *context, void *bytes, uint32_t size)
{
    File *f = context;
    if (size > f->length - f->position)
        return false;
    memcpy(bytes, f->bytes + f->position, size);
    f->position += size;
    return true;
}
static bool file_write(void *context, const void *bytes, uint32_t size)
{
    File *f = context;
    assert(size <= sizeof(f->bytes) - f->position);
    memcpy(f->bytes + f->position, bytes, size);
    f->position += size;
    if (f->position > f->length)
        f->length = f->position;
    return true;
}
static bool file_seek(void *context, uint32_t position)
{
    File *f = context;
    if (position > f->length)
        return false;
    f->position = position;
    return true;
}
static uint32_t file_position(void *context)
{
    return ((File *)context)->position;
}
static uint32_t file_length(void *context)
{
    return ((File *)context)->length;
}
static JbedBlockIo file_io(File *f)
{
    return (JbedBlockIo){f, file_read, file_write, file_seek, file_position, file_length, NULL};
}

static void file_roundtrip(void)
{
    Host *h = new_host();
    File file = {0};
    JbedBlockIdentity identity = {0x11223344, 0x12340000, 0x55667788, false};
    JbedFileBlockWriter writer;
    jbed_file_writer_init(&writer, &h->writer, &h->blocks, file_io(&file), &identity);
    JbedWriter *w = &writer.stream.base.writer;
    assert(jbed_writer_reusable(w));
    JbedAddress code = jbed_writer_allocate(w, NULL, 16);
    assert(code == JBED_CODE_BASE);
    jbed_writer_put_reloc(w, code, code + 12, false);
    uint32_t call;
    assert(jbed_thumb_call_encode(code + 4, code + 12, &call));
    jbed_writer_put_call(w, code + 4, call, false);
    uint32_t label = jbed_writer_write_label(w, code + 8, 0);
    jbed_writer_set_label(w, label, code + 12);
    jbed_writer_put_word(w, code + 12, 0x88776655);
    jbed_file_writer_store_blocks(&writer, 1);
    jbed_file_writer_close(&writer);

    static const uint8_t header[] = {0xca, 0xfe, 0xb0, 0x0b, 0x11, 0x22, 0x33, 0x44,
                                     0x12, 0x34, 0,    0,    0x55, 0x66, 0x77, 0x88,
                                     0x64, 0,    0,    4,    0,    0,    0x20, 0};
    assert(!memcmp(file.bytes, header, sizeof(header)));
    uint32_t footer = be32(file.bytes + 24);
    assert(footer > 28 && file.length == footer + 76);
    assert(be32(file.bytes + footer) == 1 && be32(file.bytes + footer + 4) == 0);
    assert(be32(file.bytes + footer + 8) == 0 && be32(file.bytes + footer + 12) == 1);
    assert(be32(file.bytes + footer + 16) == code + 12);
    for (uint32_t i = footer + 20; i < file.length; ++i)
        assert(file.bytes[i] == 0);

    static const uint8_t payload[] = {0, 0, 0, 32, 0,    0, 0, 1, 0, 0, 0, 0,    0xd0, 0,    0,
                                      0, 0, 0, 0,  0,    0, 0, 0, 1, 0, 0, 0,    0,    0xd0, 0,
                                      0, 8, 0, 0,  0,    0, 0, 0, 0, 1, 0, 0,    0,    16,   12,
                                      0, 2, 0, 12, 0x40, 0, 0, 1, 0, 0, 0, 0x55, 0x66, 0x77, 0x88};
    uint8_t decoded[128];
    z_stream z = {.next_in = file.bytes + 28,
                  .avail_in = footer - 28,
                  .next_out = decoded,
                  .avail_out = sizeof(decoded)};
    assert(inflateInit2(&z, -14) == Z_OK);
    assert(inflate(&z, Z_FINISH) == Z_STREAM_END);
    assert(z.total_out == sizeof(payload) && !memcmp(decoded, payload, sizeof(payload)));
    inflateEnd(&z);

    JbedFileBlockLoader loader;
    jbed_file_loader_init(&loader, &h->writer, &h->blocks, &identity);
    file.position = 0;
    jbed_file_loader_load(&loader, file_io(&file));
    assert(le32(h->heap) == HEAP_BASE + 12);
    assert(le32(h->heap + 4) == call);
    assert(le32(h->heap + 8) == HEAP_BASE + 12);
    assert(le32(h->heap + 12) == 0x88776655);
    assert(h->empty_arrays == 3 && h->published == 1);
    jbed_file_loader_dispose(&loader);
    jbed_file_writer_dispose(&writer);
    free_host(h);
}

static void crossing_chain(void)
{
    Host *h = new_host();
    JbedFileBlockLoader l;
    JbedBlockIdentity identity = {0};
    jbed_file_loader_init(&l, &h->writer, &h->blocks, &identity);
    l.code_count = 2;
    l.code_addresses.values = calloc(2, sizeof(uint32_t));
    l.code_addresses.length = 2;
    l.code_addresses.values[0] = HEAP_BASE;
    l.code_addresses.values[1] = HEAP_BASE + 0x4000;
    l.buffer_size = JBED_BLOCK_SIZE;
    l.buffer = calloc(1, l.buffer_size);
    set_le32(l.buffer + 8188, 5 | (4u << 15));
    assert(jbed_file_loader_fixup(&l, JBED_CODE_BASE + 8188, JBED_CODE_BASE, true, false) ==
           JBED_CODE_BASE + 8192);
    assert(le32(l.buffer + 8188) == HEAP_BASE + 5);
    set_le32(l.buffer, 9);
    assert(!jbed_file_loader_fixup(&l, JBED_CODE_BASE + 8192, JBED_CODE_BASE, true, false));
    assert(le32(l.buffer) == HEAP_BASE + 9);
    set_le32(l.buffer + 12, 7 | ((uint32_t)-8 << 15));
    set_le32(l.buffer + 4, 3);
    assert(!jbed_file_loader_fixup(&l, JBED_CODE_BASE + 12, JBED_CODE_BASE, true, false));
    assert(le32(l.buffer + 12) == HEAP_BASE + 7 && le32(l.buffer + 4) == HEAP_BASE + 3);
    jbed_file_loader_dispose(&l);
    free_host(h);
}

static void joined_and_large_blocks(void)
{
    Host *h = new_host();
    File file = {0};
    JbedBlockIdentity identity = {1, 2, 3, false};
    JbedFileBlockWriter writer;
    jbed_file_writer_init(&writer, &h->writer, &h->blocks, file_io(&file), &identity);
    JbedWriter *w = &writer.stream.base.writer;
    JbedAddress code = jbed_writer_allocate_code(w, NULL, 8200, 8200);
    jbed_writer_flush_code(w, NULL, code + 8200);
    JbedAddress large_address = jbed_writer_allocate_raw(w, NULL, 9000);
    uint8_t bytes[9000];
    for (uint32_t i = 0; i < sizeof(bytes); ++i)
        bytes[i] = (uint8_t)(i * 17);
    jbed_writer_write_block(w, large_address, bytes, sizeof(bytes));
    jbed_writer_put_reloc(w, code, code + 8196, false);
    jbed_writer_put_reloc(w, code + 4, large_address + 4, false);
    jbed_writer_put_word(w, code + 8196, 0x10203040);
    jbed_file_writer_store_blocks(&writer, 2);
    writer.stream.base.hooks->store_large_blocks(&writer.stream.base);
    jbed_file_writer_close(&writer);
    uint32_t footer = be32(file.bytes + 24);
    assert(be32(file.bytes + footer) == 2 && be32(file.bytes + footer + 4) == 2);
    assert(be32(file.bytes + footer + 8) == 0 && be32(file.bytes + footer + 12) == 8200);
    assert(be32(file.bytes + footer + 16) == 1 && be32(file.bytes + footer + 20) == large_address);
    assert(be32(file.bytes + footer + 24) == 9000);
    JbedFileBlockLoader loader;
    jbed_file_loader_init(&loader, &h->writer, &h->blocks, &identity);
    file.position = 0;
    jbed_file_loader_load(&loader, file_io(&file));
    assert(le32(h->heap) == HEAP_BASE + 8196);
    assert(le32(h->heap + 4) == HEAP_BASE + 16384 + 4);
    assert(le32(h->heap + 8196) == 0x10203040);
    assert(!memcmp(h->heap + 16384, bytes, sizeof(bytes)));
    jbed_file_loader_dispose(&loader);
    jbed_file_writer_dispose(&writer);
    free_host(h);
}

static void direct_and_xip(void)
{
    Host *h = new_host();
    JbedDirectCodeWriter direct;
    jbed_direct_writer_init(&direct, &h->writer, &h->blocks);
    JbedWriter *w = &direct.base.writer;
    JbedAddress a = jbed_writer_allocate(w, NULL, 16);
    jbed_writer_put_reloc(w, a, a + 12, false);
    uint32_t call;
    assert(jbed_thumb_call_encode(a + 4, a + 12, &call));
    jbed_writer_put_call(w, a + 4, call, false);
    jbed_code_flush_blocks(&direct.base, 1);
    assert(jbed_writer_get_word(w, a) == HEAP_BASE + 12);
    jbed_writer_put_word(w, a + 8, 0x12345678);
    assert(le32(h->heap + 8) == 0x12345678 && le32(h->heap + 4) == call);
    JbedAddress large_address = jbed_writer_allocate_raw(w, NULL, 9000);
    uint8_t bytes[9000];
    memset(bytes, 0xab, sizeof(bytes));
    jbed_writer_write_block(w, large_address, bytes, sizeof(bytes));
    assert(jbed_direct_relocate(&direct, large_address + 4) == HEAP_BASE + 0x4004);
    assert(!memcmp(h->heap + 0x4000, bytes, sizeof(bytes)));
    jbed_direct_writer_dispose(&direct);
    free_host(h);

    h = new_host();
    JbedXipBlockWriter xip;
    jbed_xip_writer_init(&xip, &h->writer, &h->blocks);
    w = &xip.stream.base.writer;
    a = jbed_writer_allocate(w, NULL, 16);
    uint32_t label = jbed_writer_write_label(w, a + 4, 0);
    jbed_writer_write_label(w, a + 12, label);
    jbed_code_flush_blocks(&xip.stream.base, 1);
    assert(xip.pending_count == 1);
    JbedAddress target = jbed_writer_allocate(w, NULL, 4);
    jbed_writer_set_label(w, label, target);
    assert(jbed_xip_relocate_label(&xip, label) == HEAP_BASE + 0x4000);
    jbed_code_flush_blocks(&xip.stream.base, 1);
    xip.stream.close_store(&xip.stream);
    assert(le32(h->heap + 4) == HEAP_BASE + 0x4000);
    assert(le32(h->heap + 12) == HEAP_BASE + 0x4000);
    jbed_xip_writer_dispose(&xip);
    free_host(h);
}

int main(void)
{
    file_roundtrip();
    crossing_chain();
    joined_and_large_blocks();
    direct_and_xip();
    puts("block-stream format, relocation and writer tests passed");
    return 0;
}
