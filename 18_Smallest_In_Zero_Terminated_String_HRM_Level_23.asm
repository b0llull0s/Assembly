; ==============================================================
;   1. Speed-optimized (branchless min-finding with CMOV)
;   2. Size-optimized (compact conditional jumps)
; Core concept: Find the smallest number in a zero-terminated string.
; ==============================================================

section .text
    global _start

_start:
    ; --- Simulate zero-terminated input (replace with syscalls) ---
    mov     esi, input_string ; Pointer to current number
    mov     edi, 0x7FFFFFFF   ; Initialize min with INT_MAX 

.find_min_loop:
    lodsd                   ; Load next number into EAX 
    test    eax, eax        ; Check if zero 
    jz      .output_min     ; If zero, output current min
    cmp     eax, edi        ; Compare with current min (
    cmovl   edi, eax        ; Update min if EAX < EDI 
    jmp     .find_min_loop

.output_min:
    mov     [output], edi   
    ; --- Reset for next string ---
    mov     edi, 0x7FFFFFFF ; Reset min
    jmp     .find_min_loop

section .data
input_string dd 5, 3, 8, 2, 0, 7, 1, 4, 0  ; Zero-terminated strings
output       dd 0                            ; Output buffer

section .text
    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall
