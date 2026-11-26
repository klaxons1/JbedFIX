#ifndef JBED_RUNTIME_INSTANCE_H
#define JBED_RUNTIME_INSTANCE_H

#include "boot_image.h"

typedef struct JbedInstance JbedInstance;
struct JbedVm;

JbedInstance *jbed_instance_create(const JbedBootImage *, uint32_t heap_bytes,
                                   uint32_t stack_bytes, char *error, size_t error_size);
bool jbed_instance_initialize(JbedInstance *, char *error, size_t error_size);
bool jbed_instance_start(JbedInstance *, JbedAddress arguments, int32_t *root_id,
                         char *error, size_t error_size);
bool jbed_instance_start_main(JbedInstance *, const char *owner, int argc,
                              const char *const *utf8_argv, int32_t *root_id,
                              char *error, size_t error_size);
/* Run on the same host thread as startup. A successful slice returns its delay
 * in milliseconds, or -3 when the root isolate exits; errors return false. */
bool jbed_instance_iterate(JbedInstance *, int32_t slice_ms, int32_t *delay,
                           int32_t *exit_code, char *error, size_t error_size);
typedef enum JbedInstanceState {
    JBED_INSTANCE_DOWN, JBED_INSTANCE_IDLE,
    JBED_INSTANCE_ACTIVE, JBED_INSTANCE_ACTIVE_FOREGROUND
} JbedInstanceState;
bool jbed_instance_request_state(JbedInstance *, JbedInstanceState);
struct JbedVm *jbed_instance_runtime(JbedInstance *);
void jbed_instance_destroy(JbedInstance *);
const JbedLoadedBoot *jbed_instance_image(const JbedInstance *);
bool jbed_instance_call(JbedInstance *, const char *owner, const char *name,
                        const char *descriptor, const uint32_t *arguments, size_t count,
                        uint64_t *result, JbedAddress *throwable);

#endif
