; ==============================================================
;   1. Speed-optimized (branchless with XOR/AND)
;   2. Size-optimized (conditional jumps)
; Core concept: Output 0 if signs match, 1 if signs differ.
; ==============================================================

section .text
    global _start

_start:
    ; --- Input simulation (replace with syscalls) ---
    mov     eax, -15         ; First input  (A)
    mov     ebx, 42          ; Second input (B) → Signs differ (output 1)
    ; mov    ebx, -30        ; Test case: Both negative (output 0)
    ; mov    ebx, 10         ; Test case: Both positive (output 0)

    ; === Approach 1: Speed-Optimized (Branchless) ===
    ; Goal: Avoid branches using arithmetic flags
    mov     ecx, eax         ; ecx = A
    xor     ecx, ebx         ; ecx = A XOR B (sign bit = 1 if signs differ)
    shr     ecx, 31          ; Shift sign bit to LSB (0 or 1)
    mov     [output_speed], ecx 

    ; === Approach 2: Size-Optimized ===
    ; Goal: Minimal instructions (5 bytes)
    test    eax, eax         ; Check A's sign (SF=1 if negative)
    js      .a_negative      ; Jump if A < 0
    test    ebx, ebx         ; Check B's sign
    jns     .same_sign       ; If B >= 0, same sign
    jmp     .diff_sign
.a_negative:
    test    ebx, ebx         ; Check B's sign
    js      .same_sign       ; If B < 0, same sign
.diff_sign:
    mov     edx, 1           ; Output 1 (different signs)
    jmp     .output
.same_sign:
    mov     edx, 0           ; Output 0 (same signs)
.output:
    mov     [output_size], edx 

    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output_speed    dd  0    ; Result from speed-optimized
    output_size     dd  0    ; Result from size-optimized
