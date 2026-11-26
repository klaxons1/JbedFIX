#ifndef JBED_RUNTIME_ARM32_H
#define JBED_RUNTIME_ARM32_H

#include <stddef.h>
#include <stdint.h>
#include "coder.h"
#include "thumb.h"

typedef enum JbedArm32Operation {
#define JBED_ARM32_OPERATION(upper, lower) JBED_ARM32_##upper,
#include "arm32_ops.h"
#undef JBED_ARM32_OPERATION
    JBED_ARM32_NATIVE_CALL
} JbedArm32Operation;

/* Captured before entering C. sp and lr are the managed call site's values;
 * pc is initially lr and can be replaced when transferring to a catch block. */
typedef struct JbedArm32Frame {
    uint32_t r[13];
    uint32_t sp, lr, pc;
} JbedArm32Frame;

typedef struct JbedArm32Context JbedArm32Context;
typedef struct JbedArm32Activation {
    JbedArm32Frame *caller_frame;
    struct JbedArm32Activation *previous;
} JbedArm32Activation;
struct JbedArm32Context {
    uintptr_t host_sp;
    void *statics;
    uintptr_t stack_limit, stack_top;
    uint32_t checkpoint_budget;
    void (*service)(JbedArm32Context *, JbedArm32Operation, JbedArm32Frame *);
    void *user;
    JbedArm32Frame *frame;
    unsigned host_depth;
    JbedArm32Activation *activations;
};

/* Arguments are JVM words: long/double use adjacent low/high words, without
 * AAPCS argument-alignment holes. Return words are r0 and r1. */
uint64_t jbed_arm32_call(JbedArm32Context *, uintptr_t entry,
                        const uint32_t *arguments, size_t word_count);
/* A service can select this continuation after recording an uncaught throwable. */
void jbed_arm32_leave(void);
/* Native-method veneers put their binding index in ip and save r3 on stack. */
void jbed_arm32_native_call(void);
/* Managed scheduler primitives. save retains a six-word context on the Java
 * stack and returns zero; restore resumes that call with a result of one. */
int32_t jbed_arm32_save_thread_state(JbedAddress scheduled);
void jbed_arm32_restore_thread_state(JbedAddress scheduled);
JbedThumbRuntimeAddresses jbed_arm32_thumb_helpers(void);
JbedCoderRuntimeAddresses jbed_arm32_coder_helpers(void);

#define JBED_ARM32_OPERATION(upper, lower) void jbed_arm32_##lower(void);
#include "arm32_ops.h"
#undef JBED_ARM32_OPERATION

#endif
