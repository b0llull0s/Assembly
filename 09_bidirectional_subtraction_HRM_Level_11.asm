; ==============================================================
; File: AbsoluteDifference_DualApproach.asm
;   1. Speed-optimized
;   2. Size-optimized 
; Core concept: Compute both (A-B) and (B-A) without branching.
; ==============================================================

section .text
    global _start

_start:
    ; --- Input simulation (replace with syscalls in real code) ---
    mov     eax, 10          ; First input (A)
    mov     ebx, 7           ; Second input (B)

    ; === Approach 1: Speed-Optimized ===
    ; Avoid redundant memory operations (keep values in registers)
    mov     ecx, eax         ; ecx = A
    mov     edx, ebx         ; edx = B
    sub     edx, ecx         ; edx = B-A
    mov     [output1], edx   
    sub     ecx, ebx         ; ecx = A-B (uses original ebx)
    mov     [output2], ecx   

    ; === Approach 2: Size-Optimized ===
    ; Minimize instructions (but may sacrifice speed)
    xchg    eax, ebx        ; Swap A and B (ebx=A, eax=B)
    sub     eax, ebx        ; eax = B-A
    mov     [output1], eax  
    neg     eax             ; eax = -(B-A) = A-B
    mov     [output2], eax  

    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output1     dd  0         ; First output (B-A)
    output2     dd  0         ; Second output (A-B)
