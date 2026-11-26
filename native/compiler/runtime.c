#include "runtime.h"

#include <stdlib.h>

/* This file adapts Java allocation/throw boundaries; it is not a recovered VM
 * allocator or exception unwinder. The reconstructed algorithms call it where
 * the ROM calls Memory.newArray/newObject or ArchBase.Throw. */
_Noreturn void jbed_raise(JbedRuntime *runtime, const JbedError *error)
{
    runtime->raise_error(runtime->context, error);
    abort(); /* A returning host exception callback violates the contract. */
}

void *jbed_alloc(JbedRuntime *runtime, size_t bytes)
{
    void *memory = runtime->allocate_zeroed(runtime->context, bytes ? bytes : 1);
    if (memory == NULL) {
        const JbedError error = {.kind = JBED_ERROR_OUT_OF_MEMORY,
                                 .is_java_error = true,
                                 .message = "compiler allocation failed"};
        jbed_raise(runtime, &error);
    }
    return memory;
}

_Noreturn void jbed_raise_internal(JbedRuntime *runtime, const char *message)
{
    const JbedError error = {
        .kind = JBED_ERROR_INTERNAL, .is_java_error = true, .message = message};
    jbed_raise(runtime, &error);
}

_Noreturn void jbed_halt(JbedRuntime *runtime, int32_t code, const char *message)
{
    runtime->halt(runtime->context, code, message);
    abort();
}
