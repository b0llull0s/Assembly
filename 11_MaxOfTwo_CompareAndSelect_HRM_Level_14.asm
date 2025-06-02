; ==============================================================
; File: MaxOfTwo_CompareAndSelect.asm
;   1. Speed-optimized (register-centric, minimal branches)
;   2. Size-optimized (compact jumps, reuse registers)
; Core concept: Compare two values and output the larger one.
; ==============================================================

section .text
    global _start

_start:
    ; --- Simulate two test inputs (replace with syscalls) ---
    mov     eax, 42          ; First input (A)
    mov     ebx, 24          ; Second input (B) - Test case: A > B
    ; mov    ebx, 42         ; Equal case
    ; mov    ebx, 100        ; B > A case

    ; === Approach 1: Speed-Optimized ===
    ; Goal: Minimize branches and memory accesses
    cmp     eax, ebx         ; Compare A and B
    jge     .output_a        ; If A >= B, output A
    mov     eax, ebx         ; Else, output B
.output_a:
    mov     [output_speed], eax 

    ; === Approach 2: Size-Optimized ===
    ; Goal: Minimal instruction bytes
    mov     ecx, eax         ; ecx = A
    sub     ecx, ebx         ; ecx = A - B
    jns     .output_a_size   ; If A - B >= 0, output A
    mov     eax, ebx         ; Else, output B
.output_a_size:
    mov     [output_size], eax 

    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output_speed    dd  0    ; Result from speed-optimized
    output_size     dd  0    ; Result from size-optimized
