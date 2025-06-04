; ==============================================================
;   1. Speed-optimized (mathematical formula)
;   2. Size-optimized (loop-based)
; Core concept: Compute T(n) = n + (n-1) + ... + 1 + 0.
; ==============================================================

section .text
    global _start

_start:
    ; --- Input simulation (replace with syscalls) ---
    mov     eax, 3           ; Test input: 3 → 3+2+1+0 = 6

    ; === Approach 1: Speed-Optimized (Formula) ===
    ; Uses the mathematical identity: T(n) = n(n+1)/2
    mov     ebx, eax         ; ebx = n
    inc     ebx              ; ebx = n+1
    imul    eax, ebx         ; eax = n*(n+1)
    shr     eax, 1           ; eax = n(n+1)/2 (division by 2 via shift)
    mov     [output_speed], eax

    ; === Approach 2: Size-Optimized (Loop) ===
       mov     ecx, eax         ; ecx = n (counter)
    xor     edx, edx         ; edx = sum (initialized to 0)
.sum_loop:
    add     edx, ecx         ; sum += counter
    dec     ecx              ; counter--
    jns     .sum_loop        ; Continue if counter >= 0
    mov     [output_size], edx 

    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output_speed    dd  0    ; Result from speed-optimized (formula)
    output_size     dd  0    ; Result from size-optimized (loop)
