#ifndef JBED_RECOVERED_M3G_LOADER_BINARY_H
#define JBED_RECOVERED_M3G_LOADER_BINARY_H

#include <stddef.h>
#include <stdint.h>

#include "m3g_loader_stream.h"

#ifdef __cplusplus
extern "C" {
#endif

/* The two 12-byte identifiers accepted by the native loader. */
extern const uint8_t jbed_m3g_magic_jsr184[12];
extern const uint8_t jbed_m3g_magic_swerve[12];

#define JBED_M3G_BINARY_MORE JBED_M3G_LOAD_END
#define JBED_M3G_BINARY_COMPLETE JBED_M3G_LOAD_OK
#define JBED_M3G_BINARY_ERROR JBED_M3G_LOAD_ERROR

/*
 * A compressed body is deliberately an explicit boundary.  The ARM binary
 * uses zlib 1.2.3 with inflateInit_(..., 56), inflate(..., Z_SYNC_FLUSH), a
 * 1024-byte output buffer, and inflateEnd().  Keeping those operations typed
 * avoids silently substituting a host zlib with different ABI/ownership.
 */
typedef int (*JbedM3GInflateStartCallback)(void *context,
                                           uint8_t compression_method,
                                           void **out_state);
typedef int (*JbedM3GInflateDataCallback)(void *context,
                                          void *state,
                                          const uint8_t *data,
                                          uint32_t length,
                                          int (*sink)(void *sink_context,
                                                      const uint8_t *data,
                                                      uint32_t length),
                                          void *sink_context);
typedef int (*JbedM3GInflateEndCallback)(void *context, void *state);

typedef struct JbedM3GInflateOps {
    JbedM3GInflateStartCallback start;
    JbedM3GInflateDataCallback data;
    JbedM3GInflateEndCallback end;
    void *context;
} JbedM3GInflateOps;

typedef int (*JbedM3GBinaryPrepareCallback)(void *context,
                                            uint8_t compression_method);
typedef int (*JbedM3GBinaryContentCallback)(void *context,
                                            const uint8_t *data,
                                            uint32_t length);
typedef int (*JbedM3GBinaryCompleteCallback)(void *context);

typedef struct JbedM3GBinaryCallbacks {
    JbedM3GBinaryPrepareCallback prepare;
    JbedM3GBinaryContentCallback content;
    JbedM3GBinaryCompleteCallback complete;
    void *context;
} JbedM3GBinaryCallbacks;

typedef enum JbedM3GBinaryPhase {
    JBED_M3G_BINARY_MAGIC = 0,
    JBED_M3G_BINARY_COMPRESSION,
    JBED_M3G_BINARY_FILE_SIZE,
    JBED_M3G_BINARY_CONTENT_SIZE,
    JBED_M3G_BINARY_BODY,
    JBED_M3G_BINARY_CHECKSUM,
    JBED_M3G_BINARY_DONE,
    JBED_M3G_BINARY_FAILED
} JbedM3GBinaryPhase;

typedef struct JbedM3GBinaryDecoder {
    JbedM3GBinaryPhase phase;
    uint8_t allow_swerve;
    uint8_t compression_method;
    uint8_t header_bytes;
    uint8_t checksum_bytes;
    uint32_t file_size;
    uint32_t content_size;
    uint32_t checksum;
    uint32_t checksum_actual;
    uint32_t body_remaining;
    uint32_t content_produced;
    void *inflate_state;
    JbedM3GInflateOps inflate;
    JbedM3GBinaryCallbacks callbacks;
    int32_t error_code;
} JbedM3GBinaryDecoder;

void jbed_m3g_binary_init(JbedM3GBinaryDecoder *decoder,
                          int allow_swerve,
                          const JbedM3GBinaryCallbacks *callbacks,
                          const JbedM3GInflateOps *inflate);

/* Returns MORE, COMPLETE, or ERROR; partial headers are supported. */
int jbed_m3g_binary_feed(JbedM3GBinaryDecoder *decoder,
                         const uint8_t *data,
                         uint32_t length);

/*
 * M3G's decompressed content is a sequence of records:
 *   uint8_t object_type; uint32_t little_endian_length; payload[length].
 * The native object factory accepts standard types 1..22 for JSR-184 and
 * 1..24 for SWERVE mode, with 255 reserved for the extension record.
 */
typedef int (*JbedM3GObjectRecordCallback)(void *context,
                                           uint8_t object_type,
                                           const uint8_t *payload,
                                           uint32_t length);

typedef struct JbedM3GObjectParser {
    uint8_t allow_swerve;
    uint8_t phase;
    uint8_t object_type;
    uint8_t length_bytes;
    uint32_t object_length;
    uint32_t payload_bytes;
    uint8_t *payload;
    uint32_t payload_capacity;
    JbedM3GObjectRecordCallback callback;
    void *context;
} JbedM3GObjectParser;

void jbed_m3g_object_parser_init(JbedM3GObjectParser *parser,
                                  int allow_swerve,
                                  JbedM3GObjectRecordCallback callback,
                                  void *context);
void jbed_m3g_object_parser_dispose(JbedM3GObjectParser *parser);
int jbed_m3g_object_parser_feed(JbedM3GObjectParser *parser,
                                const uint8_t *data,
                                uint32_t length);
int jbed_m3g_object_parser_finish(const JbedM3GObjectParser *parser);

#ifdef __cplusplus
}
#endif

#endif
