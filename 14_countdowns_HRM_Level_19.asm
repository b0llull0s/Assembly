; ==============================================================
;   1. Speed-optimized (loop unrolling for small counts)
;   2. Size-optimized (compact loop structure)
; Core concept: Output a number and all values down/up to zero.
; ==============================================================

section .text
    global _start

_start:
    ; --- Input simulation (replace with syscalls) ---
    mov     eax, 3           ; Test input: 3 → 3,2,1,0
    ; mov    eax, -2         ; Test input: -2 → -2,-1,0

    ; === Approach 1: Speed-Optimized ===
    ; Goal: Minimize branches for small counts (e.g., |n| ≤ 8)
    mov     ebx, eax         ; ebx = current value 
    mov     ecx, eax         ; ecx = original value (for direction check)
.output_loop_speed:
    mov     [output_speed], ebx 
    test    ebx, ebx         ; Check if zero 
    jz      .reset_speed     ; If zero, restart
    test    ecx, ecx         ; Check original sign 
    js      .count_up        ; If original was negative
.count_down:
    dec     ebx              ; BUMPDN 0
    jmp     .output_loop_speed
.count_up:
    inc     ebx              ; BUMPUP 0
    jmp     .output_loop_speed
.reset_speed:
    ; --- Repeat for next input (simulated) ---
    jmp     .exit

    ; === Approach 2: Size-Optimized ===
    ; Goal: Minimal code size (generic loop)
    mov     edx, eax         ; edx = current value 
.output_loop_size:
    mov     [output_size], edx 
    test    edx, edx         ; Check if zero 
    jz      .reset_size      ; If zero, restart
    test    eax, eax         ; Check original sign 
    js      .increment       ; If original was negative
.decrement:
    dec     edx              
    jmp     .output_loop_size
.increment:
    inc     edx              
    jmp     .output_loop_size
.reset_size:
    ; --- Repeat for next input (simulated) ---

.exit:
    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall

section .data
    output_speed    dd  0    ; Output buffer (speed-optimized)
    output_size     dd  0    ; Output buffer (size-optimized)
