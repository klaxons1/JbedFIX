#ifndef JBED_COMPILER_RUNTIME_H
#define JBED_COMPILER_RUNTIME_H

#include <stddef.h>
#include "model.h"

/* Services supplied by the VM hosting the reconstructed compiler. Allocations
 * have Java object lifetime: the host owns their reclamation. raise_error must
 * transfer control to the host's Java-exception boundary and must not return.
 * These are host pointers; target addresses in emitted code remain uint32_t. */
typedef struct JbedRuntime {
    void *context;
    void *(*allocate_zeroed)(void *context, size_t bytes);
    void (*raise_error)(void *context, const JbedError *error);
    void (*halt)(void *context, int32_t code, const char *message);
    /* Runs body within the host's exception boundary. False returns the caught
     * Java throwable; true means body completed normally. */
    bool (*protected_call)(void *context, void (*body)(void *), void *argument, JbedError *caught);
    struct {
        uint32_t *words;
        size_t capacity;
        int16_t next_index;
    } method_ranges; /* Method.codeRanges and numCodeRanges, per isolate. */
    JbedClassAccess *registered_classes; /* ClassAccess.registerWithRuntime, isolate +1476. */
} JbedRuntime;

void *jbed_alloc(JbedRuntime *runtime, size_t bytes);
_Noreturn void jbed_raise(JbedRuntime *runtime, const JbedError *error);
_Noreturn void jbed_raise_internal(JbedRuntime *runtime, const char *message);
_Noreturn void jbed_halt(JbedRuntime *runtime, int32_t code, const char *message);

#endif
