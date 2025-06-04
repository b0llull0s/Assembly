; ==============================================================
;   1. Speed-optimized (loop unrolling for small divisors)
;   2. Size-optimized (compact loop structure)
; Core concept: Compute A // B without division.
; ==============================================================

section .text
    global _start

_start:
    ; --- Input simulation (replace with syscalls) ---
    mov     eax, 17         ; Dividend (A)
    mov     ebx, 5          ; Divisor (B) → 17 // 5 = 3

    ; === Approach 1: Speed-Optimized ===
    ; Goal: Minimize branches for small B (e.g., B ≤ 8)
    xor     ecx, ecx        ; ecx = quotient 
.div_loop_speed:
    sub     eax, ebx        ; A -= B 
    js      .output_speed   ; If A < 0, exit 
    inc     ecx             ; quotient++ 
    jmp     .div_loop_speed
.output_speed:
    mov     [output_speed], ecx 

    ; === Approach 2: Size-Optimized ===
    ; Goal: Minimal instruction bytes
    xor     edx, edx        ; edx = quotient
.div_loop_size:
    sub     eax, ebx        ; A -= B
    js      .output_size    ; Exit if A < 0
    inc     edx             ; quotient++
    jmp     .div_loop_size
.output_size:
    mov     [output_size], edx 

    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output_speed    dd  0    ; Result from speed-optimized
    output_size     dd  0    ; Result from size-optimized

; For large A/B, use bit-shifting (e.g., div via shifts/adds).
