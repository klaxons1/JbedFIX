.syntax unified
.arm
.text
.p2align 2
.global jbed_call_host_stack
.hidden jbed_call_host_stack
.type jbed_call_host_stack, %function
/* void call(callback, argument, parked_native_sp). Save the VM stack and use
 * the same space below the parked frame as ArchBase.enterCommonStack. */
jbed_call_host_stack:
    push {r4-r11, r12, lr}
    mov r4, sp
    mov r5, r0
    mov r0, r1
    bic r2, r2, #7
    sub r2, r2, #8
    mov sp, r2
    blx r5
    mov sp, r4
    pop {r4-r11, r12, pc}
.size jbed_call_host_stack, .-jbed_call_host_stack

/* Restore regular/extended limits after the final reserved-stack scope. Native
 * dummy threads have no stack array and use a zero regular limit, which makes
 * the next outer VM entry derive bounds from its current native frame. */
.p2align 2
.global jbed_end_reserved_stack
.hidden jbed_end_reserved_stack
.type jbed_end_reserved_stack, %function
jbed_end_reserved_stack:
    ldr r5, .Lreserved_state
.Lreserved_state_pc:
    add r5, pc, r5
    ldr r5, [r5]
    str r1, [r5, #36]
    ldr r4, [r0, #40]
    cmp r4, #0
    ldrne r4, [r5, #516]
    addne r4, r1, r4
    mov r0, r5
    str r4, [r0, #40]
    ldr ip, .Lreserved_resume
.Lreserved_resume_pc:
    add ip, pc, ip
    ldr ip, [ip]
    bx ip
.Lreserved_state:
    .word jbed_runtime_state - (.Lreserved_state_pc + 8)
.Lreserved_resume:
    .word jbed_end_reserved_resume - (.Lreserved_resume_pc + 8)
.size jbed_end_reserved_stack, .-jbed_end_reserved_stack
.hidden jbed_runtime_state
.hidden jbed_end_reserved_resume

/* FileBlockStreamWriter stores ROM fixups as offsets. These veneers preserve
 * the VM's frame layout and return address; they never introduce a C frame
 * between compiled Java frames that the VM's collector would need to unwind. */
.p2align 2
.global jbed_store_rom_fixup
.hidden jbed_store_rom_fixup
.type jbed_store_rom_fixup, %function
jbed_store_rom_fixup:
    cmp r2, #0
    beq .Lstore_null
    ldr ip, .Lstore_base
.Lstore_base_pc:
    add ip, pc, ip
    ldr ip, [ip]
    sub r2, r2, ip
    /* Original instructions at 0x176100..0x176107. */
    push {r4-r7, lr}
    add r7, sp, #20
    sub sp, sp, #20
    mov r6, r0
    ldr ip, .Lstore_resume
.Lstore_resume_pc:
    add ip, pc, ip
    ldr ip, [ip]
    bx ip
.Lstore_null:
    /* A null pointer is an ordinary zero word, not a ROM relocation. */
    ldr ip, [r0]
    ldr ip, [ip, #84]
    bx ip
.p2align 2
.Lstore_base:
    .word jbed_rom_base - (.Lstore_base_pc + 8)
.Lstore_resume:
    .word jbed_store_rom_resume - (.Lstore_resume_pc + 8)
.size jbed_store_rom_fixup, .-jbed_store_rom_fixup

.p2align 2
.global jbed_load_rom_fixup
.hidden jbed_load_rom_fixup
.type jbed_load_rom_fixup, %function
jbed_load_rom_fixup:
    /* fixupCode(this, source, destinationBase, isDynamic, isLabel). */
    cmp r3, #0
    bne .Lload_replay
    ldr ip, [sp]
    cmp ip, #0
    bne .Lload_replay
    ldr ip, .Lload_base
.Lload_base_pc:
    add ip, pc, ip
    ldr ip, [ip]
    add r2, r2, ip
.Lload_replay:
    /* Original instructions at 0x161464..0x16146b. */
    push {r4-r7, lr}
    add r7, sp, #20
    sub sp, sp, #28
    str r0, [sp, #24]
    ldr ip, .Lload_resume
.Lload_resume_pc:
    add ip, pc, ip
    ldr ip, [ip]
    bx ip
.p2align 2
.Lload_base:
    .word jbed_rom_base - (.Lload_base_pc + 8)
.Lload_resume:
    .word jbed_load_rom_resume - (.Lload_resume_pc + 8)
.size jbed_load_rom_fixup, .-jbed_load_rom_fixup

/* Pointer-typed ROM object/string writes must retain virtual dispatch: the
 * same methods are also used by the in-memory DirectCodeBlockWriter. */
.p2align 2
.global jbed_write_rom_class
.hidden jbed_write_rom_class
.type jbed_write_rom_class, %function
jbed_write_rom_class:
    mov r1, r5
    ldr ip, [r0]
    ldr ip, [ip, #108]
    mov r3, #1
    ldr lr, .Lclass_resume
.Lclass_resume_pc:
    add lr, pc, lr
    ldr lr, [lr]
    bx ip
.Lclass_resume:
    .word jbed_write_class_resume - (.Lclass_resume_pc + 8)
.size jbed_write_rom_class, .-jbed_write_rom_class

.p2align 2
.global jbed_write_rom_pointer
.hidden jbed_write_rom_pointer
.type jbed_write_rom_pointer, %function
jbed_write_rom_pointer:
    mov r1, r4
    ldr r2, [sp]
    ldr ip, [r0]
    ldr ip, [ip, #108]
    mov r3, #1
    ldr lr, .Lpointer_resume
.Lpointer_resume_pc:
    add lr, pc, lr
    ldr lr, [lr]
    bx ip
.Lpointer_resume:
    .word jbed_write_pointer_resume - (.Lpointer_resume_pc + 8)
.size jbed_write_rom_pointer, .-jbed_write_rom_pointer

.p2align 2
.global jbed_write_rom_code
.hidden jbed_write_rom_code
.type jbed_write_rom_code, %function
jbed_write_rom_code:
    mov r2, r4
    mov r1, r5
    ldr ip, [r0]
    ldr ip, [ip, #108]
    mov r3, #1
    ldr lr, .Lcode_resume
.Lcode_resume_pc:
    add lr, pc, lr
    ldr lr, [lr]
    bx ip
.Lcode_resume:
    .word jbed_write_code_resume - (.Lcode_resume_pc + 8)
.size jbed_write_rom_code, .-jbed_write_rom_code

.p2align 2
.global jbed_write_rom_header
.hidden jbed_write_rom_header
.type jbed_write_rom_header, %function
jbed_write_rom_header:
    /* Replay the original load/null-check, keeping the original post-call
     * reload from RomObjects: the writer itself can move during collection. */
    ldr r2, [r6]
    cmp r0, #0
    beq .Lheader_null
    mov r1, r4
    ldr ip, [r0]
    ldr ip, [ip, #108]
    mov r3, #1
    ldr lr, .Lheader_resume
.Lheader_resume_pc:
    add lr, pc, lr
    ldr lr, [lr]
    bx ip
.Lheader_null:
    ldr lr, .Lheader_null_return
.Lheader_null_return_pc:
    add lr, pc, lr
    ldr lr, [lr]
    ldr ip, .Lheader_throw
.Lheader_throw_pc:
    add ip, pc, ip
    ldr ip, [ip]
    bx ip
.Lheader_resume:
    .word jbed_write_header_resume - (.Lheader_resume_pc + 8)
.Lheader_null_return:
    .word jbed_header_null_return - (.Lheader_null_return_pc + 8)
.Lheader_throw:
    .word jbed_throw_null - (.Lheader_throw_pc + 8)
.size jbed_write_rom_header, .-jbed_write_rom_header

.hidden jbed_rom_base
.hidden jbed_store_rom_resume
.hidden jbed_load_rom_resume
.hidden jbed_write_class_resume
.hidden jbed_write_pointer_resume
.hidden jbed_write_code_resume
.hidden jbed_write_header_resume
.hidden jbed_header_null_return
.hidden jbed_throw_null
.section .note.GNU-stack,"",%progbits
