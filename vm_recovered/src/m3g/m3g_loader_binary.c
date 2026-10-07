/*
 * Binary framing recovered from 0x2ec47c and 0x2ecee8 in
 * docs/libjbedvm.so.c.  This file stops at typed boundaries where the ARM
 * loader calls its object factory or zlib wrapper; it does not invent object
 * payload layouts that are implemented by the individual M3G classes.
 */
#include "m3g_loader_binary.h"

#include <limits.h>
#include <stdlib.h>
#include <string.h>

const uint8_t jbed_m3g_magic_jsr184[12] = {
    0xab, 'J', 'S', 'R', '1', '8', '4', 0xbb, 0x0d, 0x0a, 0x1a, 0x0a
};

const uint8_t jbed_m3g_magic_swerve[12] = {
    0xbb, 'S', 'W', 'E', 'R', 'V', 'E', 0xab, 0x0d, 0x0a, 0x1a, 0x0a
};

static uint32_t adler32_update(uint32_t adler,
                               const uint8_t *data,
                               uint32_t length)
{
    uint32_t sum_a = adler & 0xffffu;
    uint32_t sum_b = adler >> 16;

    while (length != 0u) {
        uint32_t block = length > 5552u ? 5552u : length;
        length -= block;
        while (block-- != 0u) {
            sum_a += *data++;
            sum_b += sum_a;
        }
        sum_a %= 65521u;
        sum_b %= 65521u;
    }
    return (sum_b << 16) | sum_a;
}

static int fail_binary(JbedM3GBinaryDecoder *decoder, int32_t error_code)
{
    decoder->error_code = error_code;
    decoder->phase = JBED_M3G_BINARY_FAILED;
    return JBED_M3G_BINARY_ERROR;
}

static int binary_sink(void *opaque, const uint8_t *data, uint32_t length)
{
    JbedM3GBinaryDecoder *decoder = (JbedM3GBinaryDecoder *)opaque;

    if (decoder->content_produced > decoder->content_size ||
        length > decoder->content_size - decoder->content_produced) {
        (void)fail_binary(decoder, -1201);
        return 0;
    }
    if (decoder->callbacks.content != NULL &&
        !decoder->callbacks.content(decoder->callbacks.context, data,
                                     length)) {
        (void)fail_binary(decoder, -10);
        return 0;
    }
    decoder->content_produced += length;
    return 1;
}

static int binary_prepare_body(JbedM3GBinaryDecoder *decoder)
{
    if (decoder->callbacks.prepare != NULL &&
        !decoder->callbacks.prepare(decoder->callbacks.context,
                                    decoder->compression_method)) {
        return fail_binary(decoder, -10);
    }
    if (decoder->compression_method == 0u) {
        return 1;
    }
    if (decoder->compression_method != 1u ||
        decoder->inflate.start == NULL || decoder->inflate.data == NULL ||
        decoder->inflate.end == NULL ||
        !decoder->inflate.start(decoder->inflate.context,
                                decoder->compression_method,
                                &decoder->inflate_state)) {
        return fail_binary(decoder, -8);
    }
    return 1;
}

static int binary_finish_body(JbedM3GBinaryDecoder *decoder)
{
    if (decoder->compression_method == 1u) {
        if (decoder->inflate.end(decoder->inflate.context,
                                 decoder->inflate_state) == 0) {
            return fail_binary(decoder, -8);
        }
        decoder->inflate_state = NULL;
    }
    if (decoder->content_produced != decoder->content_size) {
        return fail_binary(decoder, -1201);
    }
    decoder->phase = JBED_M3G_BINARY_CHECKSUM;
    decoder->checksum_bytes = 0;
    return JBED_M3G_BINARY_MORE;
}

void jbed_m3g_binary_init(JbedM3GBinaryDecoder *decoder,
                          int allow_swerve,
                          const JbedM3GBinaryCallbacks *callbacks,
                          const JbedM3GInflateOps *inflate)
{
    memset(decoder, 0, sizeof(*decoder));
    decoder->phase = JBED_M3G_BINARY_MAGIC;
    decoder->allow_swerve = allow_swerve != 0;
    decoder->checksum_actual = 1u;
    if (callbacks != NULL) {
        decoder->callbacks = *callbacks;
    }
    if (inflate != NULL) {
        decoder->inflate = *inflate;
    }
}

int jbed_m3g_binary_feed(JbedM3GBinaryDecoder *decoder,
                         const uint8_t *data,
                         uint32_t length)
{
    if (decoder == NULL || (data == NULL && length != 0u)) {
        return JBED_M3G_BINARY_ERROR;
    }
    if (decoder->phase == JBED_M3G_BINARY_FAILED) {
        return JBED_M3G_BINARY_ERROR;
    }
    if (decoder->phase == JBED_M3G_BINARY_DONE) {
        return JBED_M3G_BINARY_COMPLETE;
    }

    while (length != 0u) {
        switch (decoder->phase) {
        case JBED_M3G_BINARY_MAGIC: {
            uint8_t expected_jsr;
            uint8_t expected_swerve;
            expected_jsr = jbed_m3g_magic_jsr184[decoder->header_bytes];
            expected_swerve = jbed_m3g_magic_swerve[decoder->header_bytes];
            if (data[0] != expected_jsr &&
                (!decoder->allow_swerve || data[0] != expected_swerve)) {
                return fail_binary(decoder, -7);
            }
            ++data;
            --length;
            ++decoder->header_bytes;
            if (decoder->header_bytes == 12u) {
                decoder->phase = JBED_M3G_BINARY_COMPRESSION;
                decoder->header_bytes = 0;
            }
            break;
        }
        case JBED_M3G_BINARY_COMPRESSION:
            decoder->compression_method = *data++;
            --length;
            decoder->checksum_actual = adler32_update(
                decoder->checksum_actual, &decoder->compression_method, 1);
            if (binary_prepare_body(decoder) == JBED_M3G_BINARY_ERROR) {
                return JBED_M3G_BINARY_ERROR;
            }
            decoder->phase = JBED_M3G_BINARY_FILE_SIZE;
            decoder->header_bytes = 0;
            break;
        case JBED_M3G_BINARY_FILE_SIZE:
            decoder->file_size |= (uint32_t)*data << (8u * decoder->header_bytes);
            decoder->checksum_actual = adler32_update(
                decoder->checksum_actual, data, 1);
            ++data;
            --length;
            ++decoder->header_bytes;
            if (decoder->header_bytes == 4u) {
                if (decoder->file_size < 13u) {
                    return fail_binary(decoder, -1201);
                }
                decoder->body_remaining = decoder->file_size - 13u;
                decoder->phase = JBED_M3G_BINARY_CONTENT_SIZE;
                decoder->header_bytes = 0;
            }
            break;
        case JBED_M3G_BINARY_CONTENT_SIZE:
            decoder->content_size |= (uint32_t)*data
                                   << (8u * decoder->header_bytes);
            decoder->checksum_actual = adler32_update(
                decoder->checksum_actual, data, 1);
            ++data;
            --length;
            ++decoder->header_bytes;
            if (decoder->header_bytes == 4u) {
                decoder->checksum = 0;
                decoder->content_produced = 0;
                decoder->phase = JBED_M3G_BINARY_BODY;
                decoder->header_bytes = 0;
            }
            break;
        case JBED_M3G_BINARY_BODY: {
            uint32_t take = decoder->body_remaining < length
                          ? decoder->body_remaining : length;
            int ok;

            decoder->checksum_actual = adler32_update(decoder->checksum_actual,
                                                      data, take);
            if (decoder->compression_method == 0u) {
                ok = binary_sink(decoder, data, take);
            } else {
                ok = decoder->inflate.data(
                    decoder->inflate.context, decoder->inflate_state, data,
                    take, binary_sink, decoder);
            }
            if (!ok) {
                return JBED_M3G_BINARY_ERROR;
            }
            data += take;
            length -= take;
            decoder->body_remaining -= take;
            if (decoder->body_remaining == 0u) {
                int body_result = binary_finish_body(decoder);
                if (body_result == JBED_M3G_BINARY_ERROR) {
                    return body_result;
                }
            }
            break;
        }
        case JBED_M3G_BINARY_CHECKSUM:
            decoder->checksum |= (uint32_t)*data
                               << (8u * decoder->checksum_bytes);
            ++data;
            --length;
            ++decoder->checksum_bytes;
            if (decoder->checksum_bytes == 4u) {
                if (decoder->checksum != decoder->checksum_actual) {
                    return fail_binary(decoder, -9);
                }
                if (decoder->callbacks.complete != NULL &&
                    !decoder->callbacks.complete(decoder->callbacks.context)) {
                    return fail_binary(decoder, -10);
                }
                decoder->phase = JBED_M3G_BINARY_DONE;
            }
            break;
        case JBED_M3G_BINARY_DONE:
            return JBED_M3G_BINARY_COMPLETE;
        case JBED_M3G_BINARY_FAILED:
        default:
            return JBED_M3G_BINARY_ERROR;
        }
    }

    return decoder->phase == JBED_M3G_BINARY_DONE
         ? JBED_M3G_BINARY_COMPLETE : JBED_M3G_BINARY_MORE;
}

enum {
    JBED_M3G_OBJECT_TYPE = 0,
    JBED_M3G_OBJECT_LENGTH,
    JBED_M3G_OBJECT_PAYLOAD
};

static int object_parser_fail(JbedM3GObjectParser *parser)
{
    parser->phase = 3u;
    return 0;
}

static int object_type_valid(const JbedM3GObjectParser *parser,
                             uint8_t object_type)
{
    if (object_type == 255u) {
        return 1;
    }
    if (object_type == 0u) {
        return 0;
    }
    return parser->allow_swerve ? object_type < 25u : object_type < 23u;
}

static int object_reserve(JbedM3GObjectParser *parser, uint32_t required)
{
    uint32_t capacity = parser->payload_capacity;
    uint8_t *grown;

    if (required <= capacity) {
        return 1;
    }
    if (capacity == 0u) {
        capacity = 32u;
    }
    while (capacity < required) {
        if (capacity > UINT32_MAX / 2u) {
            capacity = required;
            break;
        }
        capacity *= 2u;
    }
    grown = (uint8_t *)realloc(parser->payload, capacity);
    if (grown == NULL) {
        return 0;
    }
    parser->payload = grown;
    parser->payload_capacity = capacity;
    return 1;
}

void jbed_m3g_object_parser_init(JbedM3GObjectParser *parser,
                                  int allow_swerve,
                                  JbedM3GObjectRecordCallback callback,
                                  void *context)
{
    memset(parser, 0, sizeof(*parser));
    parser->allow_swerve = allow_swerve != 0;
    parser->callback = callback;
    parser->context = context;
}

void jbed_m3g_object_parser_dispose(JbedM3GObjectParser *parser)
{
    if (parser == NULL) {
        return;
    }
    free(parser->payload);
    parser->payload = NULL;
    parser->payload_capacity = 0;
}

int jbed_m3g_object_parser_feed(JbedM3GObjectParser *parser,
                                const uint8_t *data,
                                uint32_t length)
{
    if (parser == NULL || (data == NULL && length != 0u) ||
        parser->phase == 3u) {
        return 0;
    }
    while (length != 0u) {
        if (parser->phase == JBED_M3G_OBJECT_TYPE) {
            parser->object_type = *data++;
            --length;
            if (!object_type_valid(parser, parser->object_type)) {
                return object_parser_fail(parser);
            }
            parser->object_length = 0;
            parser->length_bytes = 0;
            parser->phase = JBED_M3G_OBJECT_LENGTH;
        } else if (parser->phase == JBED_M3G_OBJECT_LENGTH) {
            parser->object_length |= (uint32_t)*data
                                   << (8u * parser->length_bytes);
            ++parser->length_bytes;
            ++data;
            --length;
            if (parser->length_bytes == 4u) {
                if (!object_reserve(parser, parser->object_length)) {
                    return object_parser_fail(parser);
                }
                parser->payload_bytes = 0;
                parser->phase = JBED_M3G_OBJECT_PAYLOAD;
            }
        } else {
            uint32_t remaining = parser->object_length - parser->payload_bytes;
            uint32_t take = remaining < length ? remaining : length;
            if (take != 0u) {
                memcpy(parser->payload + parser->payload_bytes, data, take);
                parser->payload_bytes += take;
                data += take;
                length -= take;
            }
            if (parser->payload_bytes == parser->object_length) {
                if (parser->callback != NULL &&
                    !parser->callback(parser->context, parser->object_type,
                                      parser->payload, parser->object_length)) {
                    return object_parser_fail(parser);
                }
                parser->phase = JBED_M3G_OBJECT_TYPE;
            }
        }
    }
    return 1;
}

int jbed_m3g_object_parser_finish(const JbedM3GObjectParser *parser)
{
    return parser != NULL && parser->phase == JBED_M3G_OBJECT_TYPE;
}
