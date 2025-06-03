; ==============================================================
;   1. Speed-optimized (register-heavy, minimal branching)
;   2. Size-optimized (compact jumps, reuse registers)
; Core concept: Sum numbers until a zero is encountered, then output.
; ==============================================================

section .text
    global _start

_start:
    ; --- Simulate zero-terminated input (replace with syscalls) ---
    ; Example string: [5, 3, 0] → Sum = 8
    mov     esi, input_string ; Pointer to current number
    mov     edi, 0           ; Sum accumulator (starts at 0)

.sum_loop:
    lodsd                   ; Load next number into EAX 
    test    eax, eax        ; Check if zero 
    jz      .output_sum     ; If zero, output and reset
    add     edi, eax        ; Add to sum
    jmp     .sum_loop       ; Repeat 

.output_sum:
    mov     [output], edi   
    mov     edi, 0          ; Reset sum for next string
    jmp     .sum_loop       ; Process next string

section .data
input_string dd 5, 3, 0, 2, 4, 0  ; Zero-terminated strings
output       dd 0                  ; Result buffer

section .text
    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall
