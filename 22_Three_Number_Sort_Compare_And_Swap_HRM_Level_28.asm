; ==============================================================
;   1. Speed-optimized (branchless with CMOV)
;   2. Size-optimized (conditional jumps)
; Core concept: Sort three numbers from smallest to largest.
; ==============================================================

section .text
    global _start

_start:
    ; --- Input simulation (replace with syscalls) ---
    mov     eax, 3          ; First input  (A)
    mov     ebx, 1          ; Second input (B)
    mov     ecx, 2          ; Third input  (C) → Sorted: 1, 2, 3

    ; === Approach 1: Speed-Optimized (Branchless) ===
    ; Goal: Avoid branches using conditional moves
    ; Step 1: Sort A and B
    mov     edx, eax        ; edx = A
    cmp     eax, ebx        ; Compare A and B
    cmovg   eax, ebx        ; If A > B, eax = B (min(A,B))
    cmovg   ebx, edx        ; If A > B, ebx = A (max(A,B))

    ; Step 2: Insert C into the sorted A,B pair
    cmp     ecx, eax        ; Compare C and min(A,B)
    cmovl   edx, eax        ; If C < min, shift min → edx
    cmovl   eax, ecx        ; If C < min, new min = C
    cmovge  edx, ecx        ; Else, compare C with max(A,B)
    cmp     ecx, ebx
    cmovg   ebx, ecx        ; If C > max, new max = C
    cmovle  edx, ecx        ; Else, C is the median

    ; Output sorted values
    mov     [output_speed], eax    ; Smallest
    mov     [output_speed+4], edx  ; Median
    mov     [output_speed+8], ebx  ; Largest

    ; === Approach 2: Size-Optimized (Branched) ===
    ; Goal: Minimal instruction bytes 
    ; Step 1: Sort A and B 
    cmp     eax, ebx
    jle     .skip_swap_ab
    xchg    eax, ebx        ; Swap A and B if A > B
.skip_swap_ab:
    ; Step 2: Handle C 
    cmp     ecx, eax
    jl      .c_smallest
    cmp     ecx, ebx
    jg      .c_largest
    ; C is median
    mov     edx, ecx
    jmp     .output_sorted
.c_smallest:
    mov     edx, eax
    mov     eax, ecx
    jmp     .output_sorted
.c_largest:
    mov     edx, ebx
    mov     ebx, ecx
.output_sorted:
    mov     [output_size], eax    ; Smallest
    mov     [output_size+4], edx  ; Median
    mov     [output_size+8], ebx  ; Largest

    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output_speed    dd  0, 0, 0  ; Results (speed-optimized)
    output_size     dd  0, 0, 0  ; Results (size-optimized)

; For more than 3 numbers, use sorting networks or SIMD (e.g., pminsd/pmaxsd)
