#ifndef JBED_REFLECTION_TABLE_H
#define JBED_REFLECTION_TABLE_H

#include "runtime.h"
#include "writer.h"

typedef struct JbedReflectionLayout {
    unsigned bucket_bits, index_bits, shift, extra;
    uint32_t bucket_mask, index_mask;
} JbedReflectionLayout;

typedef struct JbedReflectionBucket {
    uint8_t *bytes;
    uint32_t capacity;
} JbedReflectionBucket;
typedef struct JbedReflectionTable {
    JbedRuntime *runtime;
    JbedImageView image;
    const uint8_t *bucket_words;
    JbedReflectionLayout resident, dynamic;
    JbedReflectionBucket *buckets;
    struct JbedReflectionTable *referenced;
    uint32_t encoded_bytes, entries, used_buckets, full_buckets;
} JbedReflectionTable;

/* The image is a borrowed, relocated 32-bit address space. New buckets use
 * the runtime allocator's managed lifetime, like the ROM's byte[][] chains. */
bool jbed_reflection_init(JbedReflectionTable *, JbedRuntime *, JbedImageView, JbedAddress);
bool jbed_reflection_reference(JbedReflectionTable *, JbedImageView, JbedAddress);
void jbed_reflection_clear_dynamic(JbedReflectionTable *);
uint16_t jbed_reflection_id(JbedReflectionTable *, const uint8_t *, size_t, bool create);
uint16_t jbed_reflection_static_id(const JbedReflectionTable *, uint32_t hash,
                                   const uint8_t *, size_t);
uint16_t jbed_reflection_dynamic_id(JbedReflectionTable *, uint32_t hash,
                                    const uint8_t *, size_t, bool create);
/* getData returns the payload length even when the destination is too small.
 * -1 denotes a missing entry. */
int32_t jbed_reflection_data(const JbedReflectionTable *, uint16_t, uint8_t *, size_t);
int jbed_reflection_first_byte(const JbedReflectionTable *, uint16_t);
JbedAddress jbed_reflection_generate(const JbedReflectionTable *, JbedWriter *);

#endif
