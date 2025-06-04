; ==============================================================
;   1. Speed-optimized (register-heavy, minimal branching)
;   2. Size-optimized (compact jumps, reuse registers)
; Core concept: Generate Fibonacci sequence ≤ input value.
; ==============================================================

section .text
    global _start

_start:
    ; --- Input simulation (replace with syscalls) ---
    mov     eax, 20          ; Test input (e.g., 20 → 1, 1, 2, 3, 5, 8, 13)

    ; === Approach 1: Speed-Optimized ===
    ; Goal: Minimal branches, register-only operations
    mov     ebx, eax         ; ebx = max_value 
    mov     ecx, 1           ; ecx = F(n-1) = 1 
    mov     edx, 1           ; edx = F(n) = 1 

.output_fib_speed:
    ; Output current Fibonacci number
    mov     [output_speed], edx 

    ; Calculate next Fibonacci number
    mov     esi, edx         ; esi = F(n) 
    add     edx, ecx         ; edx = F(n+1) = F(n) + F(n-1) 
    mov     ecx, esi         ; ecx = F(n) 

    ; Check if next number exceeds max_value
    cmp     edx, ebx         
    jle     .output_fib_speed ; If F(n+1) ≤ max_value, continue

    ; === Approach 2: Size-Optimized ===
    ; Goal: Minimal instruction bytes
    mov     edi, eax         ; edi = max_value
    mov     ecx, 1           ; F(n-1) = 1
    mov     edx, 1           ; F(n) = 1

.output_fib_size:
    mov     [output_size], edx 
    mov     esi, edx         ; Save F(n)
    add     edx, ecx         ; F(n+1) = F(n) + F(n-1)
    mov     ecx, esi         ; Update F(n-1)
    cmp     edx, edi
    jle     .output_fib_size

    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output_speed    dd  0    ; Output buffer (speed-optimized)
    output_size     dd  0    ; Output buffer (size-optimized)

; For very large inputs, use a lookup table or Binet’s formula for O(1) time!

