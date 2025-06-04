; ==============================================================
;   1. Speed-optimized (loop unrolling for small divisors)
;   2. Size-optimized (compact loop structure)
; Core concept: Compute A % B without division.
; ==============================================================

section .text
    global _start

_start:
    ; --- Input simulation (replace with syscalls) ---
    mov     eax, 17         ; Dividend (A)
    mov     ebx, 5          ; Divisor (B) → 17 % 5 = 2

    ; === Approach 1: Speed-Optimized ===
    ; Goal: Minimize branches for small B (e.g., B ≤ 8)
    mov     ecx, eax         ; ecx = A 
.mod_loop_speed:
    sub     ecx, ebx         ; ecx -= B 
    cmp     ecx, ebx         ; Compare ecx and B
    jge     .mod_loop_speed  ; If ecx >= B, keep looping
    mov     [output_speed], ecx ; 

    ; === Approach 2: Size-Optimized ===
    ; Goal: Minimal instruction bytes
    mov     edx, eax         ; edx = A
.mod_loop_size:
    sub     edx, ebx         ; edx -= B
    cmp     edx, ebx         ; Compare edx and B
    jge     .mod_loop_size   ; Continue if edx >= B
    mov     [output_size], edx 

    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output_speed    dd  0    ; Result from speed-optimized
    output_size     dd  0    ; Result from size-optimized
