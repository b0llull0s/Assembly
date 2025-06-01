; ==============================================================
; File: ShiftVsAdd_Optimization.asm
; Demonstrates x86 optimization strategies for multiplying by 8:
;   1. Speed-optimized (shl/lea)
;   2. Size-optimized (add chain)
;   3. Hybrid (balanced)
; ==============================================================

section .text
    global _start

_start:
    ; --- Input simulation (replace with syscall in real code) ---
    mov     eax, [input]      ; Assume input = 3 (for testing)

    ; === Approach 1: Speed-Optimized (shl) ===
    ; Goal: Minimal cycles (1 shift vs 3 adds)
    mov     ebx, eax          ; Copy input to ebx
    shl     ebx, 3            ; ebx = input * 8 (1 instruction)
    mov     [output_speed], ebx

    ; === Approach 2: Size-Optimized (add chain) ===
    ; Goal: Minimal code size (smaller instructions)
    mov     ecx, eax          ; Copy input to ecx
    add     ecx, ecx          ; ecx *= 2 (2 bytes)
    add     ecx, ecx          ; ecx *= 4 (2 bytes)
    add     ecx, ecx          ; ecx *= 8 (2 bytes)
    mov     [output_size], ecx

    ; === Approach 3: Hybrid (lea) ===
    ; Goal: Speed of shl + flexibility of arithmetic
    lea     edx, [eax*8]      ; edx = input * 8 (1 instruction, 3 bytes)
    mov     [output_hybrid], edx

    ; --- Exit (Linux syscall) ---
    mov     eax, 60           ; sys_exit
    xor     edi, edi          ; status 0
    syscall

section .data
    input           dd  3      ; Test input (e.g., 3*8=24)
    output_speed    dd  0      ; Result from Approach 1
    output_size     dd  0      ; Result from Approach 2
    output_hybrid   dd  0      ; Result from Approach 3
