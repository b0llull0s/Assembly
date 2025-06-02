; ==============================================================
;   1. Speed-optimized (branchless with CMOV)
;   2. Size-optimized (compact conditional jumps)
; Core concept: Output absolute values of INBOX items.
; ==============================================================

section .text
    global _start

_start:
    ; --- Input simulation (replace with syscalls) ---
    mov     ebx, -7          ; Test input (negative)
    ; mov    ebx, 12         ; Test input (positive)

    ; === Approach 1: Speed-Optimized (Branchless) ===
    ; Goal: Avoid branch mispredictions
    mov     eax, ebx         ; eax = input
    neg     eax              ; eax = -input (temporary)
    test    ebx, ebx         ; Check if original was negative
    cmovs   eax, ebx         ; If negative, keep original (already negated)
    mov     [output_speed], eax 

    ; === Approach 2: Size-Optimized ===
    ; Goal: Minimal instruction bytes
    mov     ecx, ebx         ; ecx = input
    test    ecx, ecx         ; Check sign
    jns     .positive        ; Skip if non-negative
    neg     ecx              ; Negate if negative
.positive:
    mov     [output_size], ecx 

    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output_speed    dd  0    ; Result from speed-optimized
    output_size     dd  0    ; Result from size-optimized
