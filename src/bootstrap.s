.global _start
_start:
        LDR PC, reset_addr
        LDR PC, hang_addr
        LDR PC, svc_top_handler_addr
        LDR PC, hang_addr
reset_addr:     .word reset
hang_addr:      .word hang
svc_top_handler_addr: .word svc_top_handler

.align 4

/** reset: args(void) returns(void)
 *  Resets registers, sets up the stack pointer, and then branches to the
 *  program entry point.
 */
.func
reset:
        MOV R0, #0x10000
        MOV R1, #0x00000
        LDMIA R0!, {R2-R5}
        STMIA R1!, {R2-R5}
        LDMIA R0!, {R2-R5}
        STMIA R1!, {R2-R5}

        MSR CPSR_c, 0x13                /* Supervisor mode */
        MOV SP, #0x10000
        MSR CPSR_c, 0x10                /* User mode */
        MOV SP, #0x9000

        BL main                         /* Branch to program entry */
.endfunc

/** hang: args(void) returns(void)
 */
.func
hang:
        B hang
.endfunc

/** svc_top_handler: args(void) returns(void)
 *  Called with SVC/SWI instruction, hands control to C SVC handler (e.g
 *  for printing characters). In the case of SVC 1, svc_handler() is stored
 *  in a local variable memory address to be retrieved after all the
 *  registers are restored.
 */
.func
svc_top_handler:
        SUB SP, SP, #4                  /* Create space for svc_handler() */
        STMFD SP!, {R0-R12,LR}
        
        LDR R0, [LR, #-4]               /* Get SVC instruction */
        BIC R0, #0xFF000000             /* Mask off SVC number */
        MOV R4, R0
        MOV R1, SP
        BL svc_handler

        STR R0, [SP, #60]
        CMP R4, #1

        LDMFD SP!, {R0-R12,LR}
        LDREQ R0, [SP, #4]              /* If SVC 1, get char from local vars */
        ADD SP, SP, #4
        BX LR
.endfunc

/** halt: args(void) returns(void)
 *  Generates reset signal, halting execution and exiting QEMU.
 */
SYS_LOCK:       .word 0x10000020
SYS_RESETCTL:   .word 0x10000040
unlock_signal:  .word 0x0000A05F
reset_signal:   .word 0b100000110
.global halt
.func
halt:
        LDR R0, SYS_LOCK
        LDR R1, unlock_signal
        STR R1, [R0]
        LDR R0, SYS_RESETCTL
        LDR R1, reset_signal
        STR R1, [R0]
.endfunc
