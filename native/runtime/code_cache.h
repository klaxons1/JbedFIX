#ifndef JBED_RUNTIME_CODE_CACHE_H
#define JBED_RUNTIME_CODE_CACHE_H

#include "runtime.h"
#include "../compiler/writer.h"

typedef struct JbedCodeCache JbedCodeCache;
typedef void (*JbedExtendStatics)(void *, uint32_t size, const uint32_t *ranges,
                                 uint32_t range_count);

/* One cache belongs to one isolate. Destroy it after the isolate has stopped. */
JbedCodeCache *jbed_code_cache_create(JbedVm *, JbedExtendStatics, void *context);
JbedWriter *jbed_code_cache_writer(JbedCodeCache *);
bool jbed_code_cache_publish(JbedCodeCache *, char *error, size_t error_size);
void jbed_code_cache_destroy(JbedCodeCache *);

#endif
