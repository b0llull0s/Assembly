; ================================================
; HRM-to-x86-64 Assembly
; ================================================

; -------------------------------------------------------------------
; UNOPTIMIZED VERSION (Educational)
; - Uses .bss for HRM-like "slots" (input, var0, output)
; -------------------------------------------------------------------
section .bss
    input  resb 4    ; HRM "INBOX" buffer
    var0   resb 4    ; HRM "slot 0"
    output resb 4    ; HRM "OUTBOX" buffer

section .text
    global _start

_start_unoptimized:
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    lea ecx, [input]    ; use .bss buffer
    mov edx, 4
    int 0x80

    mov eax, [input]
    mov [var0], eax     ; store to .bss slot

    add eax, [var0]
    add eax, [var0]

    mov [output], eax
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    lea ecx, [output]   ; .bss buffer
    mov edx, 4
    int 0x80

    jmp _start_unoptimized

; -------------------------------------------------------------------
; OPTIMIZED VERSION 
; - Uses stack instead of .bss
; -------------------------------------------------------------------
section .text
_start_optimized:
    mov edx, 4          ; length for syscalls

.loop:
    mov eax, 3          ; sys_read
    xor ebx, ebx        ; stdin=0
    mov ecx, esp        ; buffer = stack pointer
    int 0x80

    mov eax, [esp]
    lea eax, [eax + eax*2]

    mov [esp], eax
    mov eax, 4          ; sys_write
    inc ebx             ; stdout=1
    int 0x80

    jmp .loop
; -------------------------------------------------
; KEY OPTIMIZATION CONCEPTS
; -------------------------------------------------
; 1. LEA vs ADD:
;    - LEA (Load Effective Address) can do math in 1 instruction.
;    - 'lea eax, [eax + eax*2]' replaces two 'add' instructions.
;
; 2. Stack vs Static Memory:
;    - Using 'esp' as a buffer avoids .bss section (smaller binary).
;
; 3. Register Reuse:
;    - 'xor ebx, ebx' + 'inc ebx' is shorter than two 'mov' instructions.
;
; 4. Syscall Efficiency:
;    - Reusing 'edx=4' for both read/write saves instructions.
;
; 5. Pipeline Friendliness:
;    - Fewer memory accesses (optimized version touches memory only twice).
; -------------------------------------------------
