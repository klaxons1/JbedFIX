.syntax unified
.arm
.text

/* The emitted Thumb uses r7 for its frame chain, r8 for the checkpoint counter,
 * r9 for isolate statics and r10 for the stack limit. r11 carries this boundary's
 * context and is preserved by both generated code and AAPCS native callees. */
.p2align 2
.global jbed_arm32_enter
.hidden jbed_arm32_enter
.type jbed_arm32_enter, %function
jbed_arm32_enter:
    push {r4-r11, ip, lr}
    mov r11, r0
    str sp, [r11]
    mov r4, r1
    mov r5, r2
    mov r6, r3
    ldr r9, [r11, #4]
    ldr r10, [r11, #8]
    ldr sp, [r11, #12]
    bic sp, sp, #7
    ldr r8, [r11, #16]
    cmp r6, #4
    ble .Larguments_in_registers
    sub r0, r6, #4
    lsl r0, r0, #2
    add r0, r0, #7
    bic r0, r0, #7
    sub sp, sp, r0
    add r1, r5, #16
    mov r2, sp
    sub r3, r6, #4
.Lcopy_arguments:
    ldr r0, [r1], #4
    str r0, [r2], #4
    subs r3, r3, #1
    bne .Lcopy_arguments
.Larguments_in_registers:
    mov r0, #0
    mov r1, #0
    mov r2, #0
    mov r3, #0
    cmp r6, #0
    ldrgt r0, [r5]
    cmp r6, #1
    ldrgt r1, [r5, #4]
    cmp r6, #2
    ldrgt r2, [r5, #8]
    cmp r6, #3
    ldrgt r3, [r5, #12]
    mov r7, #0
    blx r4
.global jbed_arm32_leave
.hidden jbed_arm32_leave
.type jbed_arm32_leave, %function
jbed_arm32_leave:
    ldr sp, [r11]
    pop {r4-r11, ip, pc}
.size jbed_arm32_leave, .-jbed_arm32_leave
.size jbed_arm32_enter, .-jbed_arm32_enter

/* Every slow helper arrives with the original managed LR and frame intact.
 * C runs below the parked host frame, never on a managed heap stack. */
.thumb
.p2align 2
.type jbed_arm32_service_gate, %function
.thumb_func
jbed_arm32_service_gate:
    sub sp, sp, #64
    stmia sp, {r0-r12}
    mov r1, ip
.Lservice_captured:
    add r0, sp, #64
    str r0, [sp, #52]
    str lr, [sp, #56]
    str lr, [sp, #60]
    mov r4, sp
    mov r0, r11
    mov r2, r4
    ldr sp, [r11]
    bl jbed_arm32_dispatch
    mov sp, r4
    ldmia sp, {r0-r11}
    ldr lr, [sp, #56]
    ldr ip, [sp, #60]
    ldr sp, [sp, #52]
    bx ip
.size jbed_arm32_service_gate, .-jbed_arm32_service_gate

.macro service name, operation
    .p2align 2
    .global jbed_arm32_\name
    .hidden jbed_arm32_\name
    .type jbed_arm32_\name, %function
    .thumb_func
jbed_arm32_\name:
    mov ip, #\operation
    b jbed_arm32_service_gate
    .size jbed_arm32_\name, .-jbed_arm32_\name
.endm

.set operation_number, 0
#define JBED_ARM32_OPERATION(upper, lower) service lower, operation_number ; .set operation_number, operation_number + 1
#include "arm32_ops.h"
#undef JBED_ARM32_OPERATION

.p2align 2
.global jbed_arm32_native_call
.hidden jbed_arm32_native_call
.type jbed_arm32_native_call, %function
.thumb_func
jbed_arm32_native_call:
    pop {r3}
    sub sp, sp, #64
    stmia sp, {r0-r12}
    mov r1, #operation_number
    b .Lservice_captured
.size jbed_arm32_native_call, .-jbed_arm32_native_call

/* Division by zero must capture the Java caller, before a C prologue has
 * replaced its frame pointer. The ordinary arithmetic path stays in C. */
.macro divide name, implementation, wide
    .p2align 2
    .global jbed_arm32_\name
    .hidden jbed_arm32_\name
    .type jbed_arm32_\name, %function
    .thumb_func
jbed_arm32_\name:
    .if \wide
    orrs ip, r2, r3
    .else
    cmp r1, #0
    .endif
    beq jbed_arm32_throw_arithmetic
    b jbed_arm32_\implementation
    .size jbed_arm32_\name, .-jbed_arm32_\name
.endm
divide integer_divide, idiv, 0
divide integer_remainder, irem, 0
divide ldiv, ldiv_nonzero, 1
divide lrem, lrem_nonzero, 1

/* Scheduled.context is [stack limit, r4, r5, r6, frame pointer, return PC].
 * The context remains on the managed stack until restore resumes the call. */
.equ SCHEDULED_CONTEXT, 20
.p2align 2
.global jbed_arm32_save_thread_state
.hidden jbed_arm32_save_thread_state
.type jbed_arm32_save_thread_state, %function
.thumb_func
jbed_arm32_save_thread_state:
    mov r3, r10
    push {r3-r7, lr}
    mov r1, sp
    str r1, [r0, #SCHEDULED_CONTEXT]
    movs r0, #0
    bx lr
.size jbed_arm32_save_thread_state, .-jbed_arm32_save_thread_state

.p2align 2
.global jbed_arm32_restore_thread_state
.hidden jbed_arm32_restore_thread_state
.type jbed_arm32_restore_thread_state, %function
.thumb_func
jbed_arm32_restore_thread_state:
    ldr r0, [r0, #SCHEDULED_CONTEXT]
    mov sp, r0
    mov.w r8, #255
    movs r0, #1
    pop {r3-r7}
    mov r10, r3
    pop {r2}
    bx r2
.size jbed_arm32_restore_thread_state, .-jbed_arm32_restore_thread_state

.p2align 2
.global ArchBase_stackPointer
.hidden ArchBase_stackPointer
.type ArchBase_stackPointer, %function
.thumb_func
ArchBase_stackPointer:
    push {r7, lr}
    add r7, sp, #8
    mov r0, sp
    pop {r7, pc}
.size ArchBase_stackPointer, .-ArchBase_stackPointer

.p2align 2
.global ArchBase_call
.hidden ArchBase_call
.type ArchBase_call, %function
.thumb_func
ArchBase_call:
    mov r2, r0
    mov r0, r1
    mov pc, r2
.size ArchBase_call, .-ArchBase_call

.macro indirect_call reg
    .global ArchBase_callViaR\reg
    .hidden ArchBase_callViaR\reg
    .type ArchBase_callViaR\reg, %function
    .thumb_func
ArchBase_callViaR\reg:
    mov pc, r\reg
    .size ArchBase_callViaR\reg, .-ArchBase_callViaR\reg
.endm
indirect_call 0
indirect_call 1
indirect_call 2
indirect_call 3
indirect_call 4
indirect_call 5
indirect_call 6

/* Host-stack call after native_call.c has inserted the AAPCS alignment holes. */
.arm
.p2align 2
.global jbed_arm32_call_c
.hidden jbed_arm32_call_c
.type jbed_arm32_call_c, %function
jbed_arm32_call_c:
    push {r4-r8, lr}
    mov r4, r0
    mov r5, r1
    mov r6, r2
    mov r7, sp
    cmp r6, #4
    ble .Lc_registers
    sub r0, r6, #4
    lsl r0, r0, #2
    add r0, r0, #7
    bic r0, r0, #7
    sub sp, sp, r0
    add r1, r5, #16
    mov r2, sp
    sub r3, r6, #4
.Lc_stack_arguments:
    ldr r0, [r1], #4
    str r0, [r2], #4
    subs r3, r3, #1
    bne .Lc_stack_arguments
.Lc_registers:
    mov r0, #0
    mov r1, #0
    mov r2, #0
    mov r3, #0
    cmp r6, #0
    ldrgt r0, [r5]
    cmp r6, #1
    ldrgt r1, [r5, #4]
    cmp r6, #2
    ldrgt r2, [r5, #8]
    cmp r6, #3
    ldrgt r3, [r5, #12]
    blx r4
    mov sp, r7
    pop {r4-r8, pc}
.size jbed_arm32_call_c, .-jbed_arm32_call_c

.section .note.GNU-stack,"",%progbits
