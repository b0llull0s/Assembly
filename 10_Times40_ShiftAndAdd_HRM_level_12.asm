; ==============================================================
; File: Times40_ShiftAndAdd.asm
;   1. Speed-optimized (shl + add)
;   2. Size-optimized (add chain)
; Core concept: Compute 40x = (32x + 8x) using shift/add.
; ==============================================================

section .text
    global _start

_start:
    ; --- Input simulation (replace with syscall) ---
    mov     eax, 5           ; Test input: 5*40=200

    ; === Approach 1: Speed-Optimized ===
    ; Goal: Minimal latency (3 instructions)
    mov     ebx, eax         ; ebx = x
    shl     ebx, 3           ; ebx = 8x (x << 3)
    mov     ecx, ebx         ; ecx = 8x (stored for later)
    shl     ebx, 2           ; ebx = 32x (8x << 2)
    add     ebx, ecx         ; ebx = 32x + 8x = 40x
    mov     [output_speed], ebx

    ; === Approach 2: Size-Optimized ===
    ; Goal: Minimal instruction bytes (6 instructions)
    mov     edx, eax         ; edx = x
    add     edx, edx         ; edx = 2x
    add     edx, edx         ; edx = 4x
    add     edx, edx         ; edx = 8x (stored implicitly in EDX)
    mov     esi, edx         ; esi = 8x (save for later)
    add     edx, edx         ; edx = 16x
    add     edx, edx         ; edx = 32x
    add     edx, esi         ; edx = 32x + 8x = 40x
    mov     [output_size], edx

    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output_speed    dd  0    ; Result from speed-optimized
    output_size     dd  0    ; Result from size-optimized
