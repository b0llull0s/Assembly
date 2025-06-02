; ==============================================================
; File: EqualityCheck_SubtractAndJump.asm
;   1. Speed-optimized (register-centric, minimal branches)
;   2. Size-optimized (compact jumps, reuse registers)
; Core concept: Test equality via subtraction and conditional jumps.
; ==============================================================

section .text
    global _start

_start:
    ; --- Simulate two test inputs (replace with syscalls) ---
    mov     eax, 42          ; First input (A)
    mov     ebx, 42          ; Second input (B) - Equal case
    ; mov    ebx, 100        ; Uncomment for unequal case

    ; === Approach 1: Speed-Optimized ===
    ; Goal: Minimize branches and memory accesses
    mov     ecx, eax         ; ecx = A 
    sub     ecx, ebx         ; ecx = A - B 
    jz      .equal           ; if A == B
    jmp     .unequal         ; if A != B

.equal:
    mov     edx, eax         ; reuse original A
    mov     [output_speed], edx ; 
    jmp     .exit

.unequal:
    ; Optional: Handle unequal case 
    jmp     .exit

    ; === Approach 2: Size-Optimized ===
    ; Goal: Minimal instruction bytes
    mov     esi, eax         ; esi = A 
    sub     esi, ebx         ; esi = A - B 
    jnz     .skip            ; A != B
    mov     edi, eax         ; reuse A
    mov     [output_size], edi 
.skip:

.exit:
    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output_speed    dd  0    ; Result from speed-optimized
    output_size     dd  0    ; Result from size-optimized
