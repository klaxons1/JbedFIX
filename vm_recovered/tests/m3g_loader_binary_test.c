#include "m3g_loader_binary.h"

#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef struct BinaryProbe {
    int prepares;
    int completes;
    int content_bytes;
    int records;
    uint8_t object_type;
    uint32_t object_length;
    uint8_t payload[8];
} BinaryProbe;

static uint32_t test_adler(const uint8_t *data, size_t length)
{
    uint32_t a = 1;
    uint32_t b = 0;
    while (length-- != 0u) {
        a += *data++;
        a %= 65521u;
        b += a;
        b %= 65521u;
    }
    return (b << 16) | a;
}

static int on_prepare(void *opaque, uint8_t compression_method)
{
    BinaryProbe *probe = (BinaryProbe *)opaque;
    assert(compression_method == 0u);
    ++probe->prepares;
    return 1;
}

static int on_content(void *opaque, const uint8_t *data, uint32_t length)
{
    BinaryProbe *probe = (BinaryProbe *)opaque;
    probe->content_bytes += (int)length;
    assert(data != NULL || length == 0u);
    return 1;
}

static int on_complete(void *opaque)
{
    BinaryProbe *probe = (BinaryProbe *)opaque;
    ++probe->completes;
    return 1;
}

static int on_record(void *opaque, uint8_t object_type,
                    const uint8_t *payload, uint32_t length)
{
    BinaryProbe *probe = (BinaryProbe *)opaque;
    ++probe->records;
    probe->object_type = object_type;
    probe->object_length = length;
    assert(length <= sizeof(probe->payload));
    if (length != 0u) {
        memcpy(probe->payload, payload, length);
    }
    return 1;
}

static size_t make_raw_file(uint8_t *out, const uint8_t *content,
                            size_t content_length)
{
    uint32_t file_size = (uint32_t)(13u + content_length);
    uint32_t checksum;
    size_t offset = 0;

    memcpy(out + offset, jbed_m3g_magic_jsr184, 12);
    offset += 12;
    out[offset++] = 0;
    out[offset++] = (uint8_t)file_size;
    out[offset++] = (uint8_t)(file_size >> 8);
    out[offset++] = (uint8_t)(file_size >> 16);
    out[offset++] = (uint8_t)(file_size >> 24);
    out[offset++] = (uint8_t)content_length;
    out[offset++] = (uint8_t)(content_length >> 8);
    out[offset++] = (uint8_t)(content_length >> 16);
    out[offset++] = (uint8_t)(content_length >> 24);
    memcpy(out + offset, content, content_length);
    offset += content_length;
    checksum = test_adler(out + 12, 1u + 4u + 4u + content_length);
    out[offset++] = (uint8_t)checksum;
    out[offset++] = (uint8_t)(checksum >> 8);
    out[offset++] = (uint8_t)(checksum >> 16);
    out[offset++] = (uint8_t)(checksum >> 24);
    return offset;
}

static void test_raw_binary_and_records(void)
{
    static const uint8_t content[] = {1, 3, 0, 0, 0, 'a', 'b', 'c'};
    uint8_t file[64];
    size_t file_length = make_raw_file(file, content, sizeof(content));
    JbedM3GObjectParser parser;
    JbedM3GBinaryDecoder decoder;
    BinaryProbe probe;
    JbedM3GBinaryCallbacks callbacks;

    memset(&probe, 0, sizeof(probe));
    memset(&callbacks, 0, sizeof(callbacks));
    callbacks.prepare = on_prepare;
    callbacks.content = on_content;
    callbacks.complete = on_complete;
    callbacks.context = &probe;
    jbed_m3g_binary_init(&decoder, 0, &callbacks, NULL);
    for (size_t i = 0; i < file_length; ++i) {
        int result = jbed_m3g_binary_feed(&decoder, file + i, 1);
        assert(result == (i + 1u == file_length
                        ? JBED_M3G_BINARY_COMPLETE : JBED_M3G_BINARY_MORE));
    }
    assert(probe.prepares == 1);
    assert(probe.completes == 1);
    assert(probe.content_bytes == (int)sizeof(content));
    assert(decoder.file_size == 13u + sizeof(content));
    assert(decoder.content_size == sizeof(content));

    jbed_m3g_object_parser_init(&parser, 0, on_record, &probe);
    for (size_t i = 0; i < sizeof(content); ++i) {
        assert(jbed_m3g_object_parser_feed(&parser, content + i, 1) == 1);
    }
    assert(jbed_m3g_object_parser_finish(&parser) == 1);
    assert(probe.records == 1);
    assert(probe.object_type == 1u);
    assert(probe.object_length == 3u);
    assert(memcmp(probe.payload, "abc", 3) == 0);
    jbed_m3g_object_parser_dispose(&parser);
}

static void test_binary_rejections(void)
{
    static const uint8_t content[] = {24, 0, 0, 0, 0};
    uint8_t file[64];
    size_t file_length = make_raw_file(file, content, sizeof(content));
    JbedM3GBinaryDecoder decoder;
    JbedM3GBinaryCallbacks callbacks;
    BinaryProbe probe;
    JbedM3GObjectParser parser;

    memset(&probe, 0, sizeof(probe));
    memset(&callbacks, 0, sizeof(callbacks));
    callbacks.context = &probe;
    jbed_m3g_binary_init(&decoder, 0, &callbacks, NULL);
    file[0] ^= 1u;
    assert(jbed_m3g_binary_feed(&decoder, file, (uint32_t)file_length) ==
           JBED_M3G_BINARY_ERROR);
    assert(decoder.error_code == -7);

    make_raw_file(file, content, sizeof(content));
    file[file_length - 1u] ^= 1u;
    jbed_m3g_binary_init(&decoder, 0, &callbacks, NULL);
    assert(jbed_m3g_binary_feed(&decoder, file, (uint32_t)file_length) ==
           JBED_M3G_BINARY_ERROR);
    assert(decoder.error_code == -9);

    memcpy(file, jbed_m3g_magic_jsr184, 12);
    file[12] = 1;
    jbed_m3g_binary_init(&decoder, 0, &callbacks, NULL);
    assert(jbed_m3g_binary_feed(&decoder, file, 13) ==
           JBED_M3G_BINARY_ERROR);
    assert(decoder.error_code == -8);

    jbed_m3g_object_parser_init(&parser, 0, on_record, &probe);
    assert(jbed_m3g_object_parser_feed(&parser, content, sizeof(content)) == 0);
    jbed_m3g_object_parser_dispose(&parser);
}

int main(void)
{
    test_raw_binary_and_records();
    test_binary_rejections();
    return 0;
}
