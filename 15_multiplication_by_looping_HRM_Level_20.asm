; ==============================================================
;   1. Speed-optimized (loop unrolling for small multipliers)
;   2. Size-optimized (compact loop structure)
; Core concept: Multiply two numbers using repeated addition.
; ==============================================================

section .text
    global _start

_start:
    ; --- Input simulation (replace with syscalls) ---
    mov     eax, 5           ; First input (A)
    mov     ebx, 4           ; Second input (B) → 5 * 4 = 20

    ; === Approach 1: Speed-Optimized ===
    ; Goal: Minimize branches for small multipliers (e.g., B ≤ 8)
    xor     ecx, ecx         ; ecx = result 
    mov     edx, ebx         ; edx = counter
.mult_loop_speed:
    test    edx, edx         ; Check if counter is zero 
    jz      .output_speed    ; If zero, exit loop
    add     ecx, eax         ; result += A 
    dec     edx              ; counter-- 
    jmp     .mult_loop_speed
.output_speed:
    mov     [output_speed], ecx 

    ; === Approach 2: Size-Optimized ===
    ; Goal: Minimal code size (generic loop)
    xor     esi, esi         ; esi = result 
    mov     edi, ebx         ; edi = counter 
.mult_loop_size:
    test    edi, edi         ; Check counter 
    jz      .output_size     ; If zero, exit loop
    add     esi, eax         ; result += A
    dec     edi              ; counter--
    jmp     .mult_loop_size
.output_size:
    mov     [output_size], esi 

    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output_speed    dd  0    ; Result from speed-optimized
    output_size     dd  0    ; Result from size-optimized
