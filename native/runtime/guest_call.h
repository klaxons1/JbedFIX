#ifndef JBED_RUNTIME_GUEST_CALL_H
#define JBED_RUNTIME_GUEST_CALL_H

#include "runtime.h"

typedef enum JbedGuestCallKind { JBED_GUEST_STATIC, JBED_GUEST_DIRECT, JBED_GUEST_VIRTUAL } JbedGuestCallKind;
/* Exact descriptor lookup in current-image metadata (never original ROM slots).
 * arguments use managed JVM words, including the receiver for instance calls.
 * Reference arguments are rooted and updated in place across execution. */
uint64_t jbed_vm_guest_call(JbedVm *, JbedGuestCallKind, const char *owner,
    const char *name, const char *descriptor, uint32_t *arguments, size_t count);

#endif
