#include "signatures.h"

#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Input: little-endian ID, byte count, then that ROM reflection-table record.
 * Output: decoded type count and types, rebuilt ID, byte-equality flag. */
typedef struct Allocation {
    struct Allocation *next;
    unsigned char data[];
} Allocation;

static void *allocate(void *context, size_t size)
{
    Allocation **head = context;
    Allocation *a = calloc(1, sizeof *a + size);
    if (!a)
        return NULL;
    a->next = *head;
    *head = a;
    return a->data;
}

static void raise_error(void *context, const JbedError *error)
{
    (void)context;
    fprintf(stderr, "signature error: %s\n", error->message);
    exit(2);
}

static void write_bytes(JbedWriter *writer, JbedAddress addr, const uint8_t *data, uint32_t size)
{
    assert(addr >= writer->buffer->address &&
           addr - writer->buffer->address <= writer->buffer->size - size);
    memcpy(writer->buffer->data + (addr - writer->buffer->address), data, size);
}

static void roundtrip_dynamic_table(JbedRuntime *runtime)
{
    uint8_t image[512] = {0, 0x12}; /* Four dynamic buckets, one entry in each. */
    JbedImageView view = {image, sizeof image, 0x8000};
    JbedReflectionTable table;
    assert(jbed_reflection_init(&table, runtime, view, view.base));
    /* Both hashes end in 3. The second entry spills back into bucket zero. */
    const uint8_t key = 3;
    uint8_t long_key[160] = {0};
    long_key[159] = 0x83;
    assert(jbed_reflection_id(&table, &key, 1, true) == 0x8007);
    assert(jbed_reflection_id(&table, long_key, sizeof long_key, true) == 0x8001);
    assert(jbed_reflection_id(&table, &key, 1, true) == 0x8007 && table.entries == 2);
    JbedBuffer buffer = {image, sizeof image, view.base};
    JbedWriter writer;
    jbed_writer_init(&writer, NULL);
    JbedWriterOps ops = *writer.ops;
    ops.write_block = write_bytes;
    writer.ops = &ops;
    writer.buffer = &buffer;
    writer.cursor = view.base + 8;
    writer.limit = view.base + sizeof image;
    JbedAddress blob = jbed_reflection_generate(&table, &writer);
    assert(image[blob - view.base] == 0x12);
    jbed_reflection_clear_dynamic(&table);
    assert(!jbed_reflection_id(&table, long_key, sizeof long_key, false));
    assert(jbed_reflection_reference(&table, view, blob));
    assert(jbed_reflection_id(&table, long_key, sizeof long_key, false) == 0x8001);
    assert(jbed_reflection_first_byte(&table, 0x8007) == key);
    uint8_t result[160] = {0xff};
    assert(jbed_reflection_data(&table, 0x8001, result, 1) == 160 && result[0] == 0xff);
    assert(jbed_reflection_data(&table, 0x8001, result, sizeof result) == 160);
    assert(memcmp(result, long_key, sizeof result) == 0);

    /* 16384 encodes as 01 00 80. The signed-byte loop stops at the
     * middle zero, leaving the final prefix byte in the payload. */
    jbed_reflection_clear_dynamic(&table);
    static const uint8_t long_zeroes[16384];
    uint16_t id = jbed_reflection_id(&table, long_zeroes, sizeof long_zeroes, true);
    assert(jbed_reflection_data(&table, id, NULL, 0) == -1);
    uint8_t prefix_payload[128] = {0x80};
    assert(jbed_reflection_id(&table, prefix_payload, sizeof prefix_payload, false) == id);
}

static void word(uint32_t value)
{
    unsigned char bytes[] = {(uint8_t)value, (uint8_t)(value >> 8), (uint8_t)(value >> 16),
                             (uint8_t)(value >> 24)};
    if (fwrite(bytes, 1, sizeof bytes, stdout) != sizeof bytes)
        exit(3);
}

int main(int argc, char **argv)
{
    if (argc != 3)
        return 1;
    FILE *rom = fopen(argv[1], "rb");
    if (!rom || fseek(rom, 0, SEEK_END))
        return 1;
    long size = ftell(rom);
    if (size < 0 || fseek(rom, 0, SEEK_SET))
        return 1;
    uint8_t *image = malloc((size_t)size);
    if (!image || fread(image, 1, (size_t)size, rom) != (size_t)size)
        return 1;
    fclose(rom);

    Allocation *head = NULL;
    JbedRuntime runtime = {
        .context = &head, .allocate_zeroed = allocate, .raise_error = raise_error};
    roundtrip_dynamic_table(&runtime);
    JbedReflectionTable table;
    if (!jbed_reflection_init(&table, &runtime, (JbedImageView){image, (size_t)size, 0},
                              (JbedAddress)strtoul(argv[2], NULL, 0)))
        return 1;
    JbedSignatureServices services = {
        .runtime = &runtime, .reflection_table = &table, .types = jbed_signature_rom_types()};
    JbedSignatureEncoder encoder;
    jbed_signature_init(&encoder, &services);
    unsigned char header[4], expected[1286];
    while (fread(header, 1, sizeof header, stdin) == sizeof header) {
        uint16_t id = (uint16_t)(header[0] | (unsigned)header[1] << 8);
        size_t length = header[2] | (unsigned)header[3] << 8;
        if (length > sizeof expected || fread(expected, 1, length, stdin) != length)
            return 1;
        jbed_signature_open(&encoder, id);
        JbedTypeId types[258];
        size_t count = 0;
        for (;;) {
            JbedTypeId type = jbed_signature_next(&encoder);
            if (type == 14)
                break;
            if (count == sizeof types / sizeof types[0])
                abort();
            types[count++] = type;
            if (type == 0)
                break;
        }
        jbed_signature_close(&encoder, id);
        if (!count)
            abort();
        JbedSignatureId rebuilt = jbed_signature_build_types(
            &encoder, types, count - 1, types[count - 1], types[count - 1] == 0);
        word((uint32_t)count);
        for (size_t i = 0; i < count; ++i)
            word(types[i]);
        word(rebuilt);
        word(!length || ((int32_t)length == encoder.byte_count && !memcmp(expected, encoder.bytes, length)));
    }
    while (head) {
        Allocation *next = head->next;
        free(head);
        head = next;
    }
    free(image);
    return ferror(stdin) ? 1 : 0;
}
