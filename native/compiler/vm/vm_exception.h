#ifndef JBED_VM_EXCEPTION_H
#define JBED_VM_EXCEPTION_H

#include "writer.h"
#include "../runtime.h"

typedef struct JbedVmMemoryReader {
    void *context;
    uint32_t (*word)(void *context, JbedAddress address);
} JbedVmMemoryReader;

enum {
    JBED_NATIVE_FRAME_SP = 0,
    JBED_NATIVE_FRAME_LR = 4,
    JBED_NATIVE_FRAME_R4 = 8,
    JBED_NATIVE_FRAME_R5 = 12,
    JBED_NATIVE_FRAME_R6 = 16,
    JBED_NATIVE_FRAME_FP = 20,
    JBED_NATIVE_FRAME_ROOTS = 24,
    JBED_ROOT_PINNED = 1,
    JBED_TRACE_PCS_PER_CHUNK = 4
};
#define JBED_NATIVE_ROOT_INTERIOR UINT32_MAX
#define JBED_NATIVE_ROOT_INVALID (UINT32_MAX - 1)

/* NativeCallStateStack and the active isolate's corresponding global slots. */
typedef struct JbedVmNativeFrames {
    JbedAddress base, frame, address;
    uint32_t no_allocation;
    JbedAddress limit;
} JbedVmNativeFrames;

typedef struct JbedVmExceptionState {
    JbedVmMemoryReader memory;
    JbedVmNativeFrames *native_frames;
    JbedAddress no_catch_tag, stack_overflow;
    JbedAddress stack_limit, reserved_stack_limit;
    bool no_catch;
} JbedVmExceptionState;

/* Registers at the throw site. lr is the Thumb return address, with bit 0 set.
 * fp is Jbed's r7, including its control-word flag. */
typedef struct JbedVmArmFrame {
    JbedAddress sp, fp, lr;
    uint32_t r4, r5, r6;
} JbedVmArmFrame;

typedef enum JbedVmExceptionAction {
    JBED_VM_ENTER_CATCH,
    JBED_VM_RELEASE_MONITOR,
    JBED_VM_UNCAUGHT,
    JBED_VM_NO_NATIVE_STATE,
    JBED_VM_THROW_FROM_KNI
} JbedVmExceptionAction;

/* Register state passed to Base.handleCatchingException or Base.handleFrameUnwind.
 * r0 is the throwable; r1 is the Thumb catch address or the monitor to release.
 * On monitor release, resume unwinding with this caller frame and the throwable
 * returned by Base.tryExit. */
typedef struct JbedVmExceptionTransfer {
    JbedVmExceptionAction action;
    JbedVmArmFrame frame;
    JbedAddress throwable, handler_or_monitor;
} JbedVmExceptionTransfer;

bool jbed_vm_exception_instance_of(JbedVmMemoryReader, JbedAddress exception_tag,
                                   JbedAddress catch_class);
/* Start with the allocated throwable, the active native-state snapshot and the
 * stack limit before Throw/reThrow reserves space for StackOverflowError. */
JbedVmExceptionTransfer jbed_vm_handle_exception(JbedVmExceptionState *, JbedAddress throwable,
                                                 JbedVmArmFrame);

typedef struct JbedVmTrace {
    struct JbedVmTrace *next;
    JbedAddress pcs[JBED_TRACE_PCS_PER_CHUNK];
} JbedVmTrace;

void jbed_vm_fill_trace(JbedRuntime *, const JbedVmExceptionState *, JbedVmTrace **trace,
                        JbedAddress call_address, JbedAddress fp);
JbedAddress jbed_vm_stack_pos(const JbedVmTrace *, int32_t depth);

#endif
