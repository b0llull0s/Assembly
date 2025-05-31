section .text
    global _start

_start:
    ; Assume input values are preloaded in memory (for illustration)
    mov   eax, [input]   ; Load value into eax (like INBOX)

    ; Check if zero
    test  eax, eax       ; Compare eax with itself (sets Zero Flag if eax=0)
    jz    _start         ; Jump to _start if zero (like JUMPZ b in HRM)

    ; Output (store to memory for simplicity)
    mov   [output], eax  ; Like OUTBOX

    ; Repeat
    jmp   _start         ; Like JUMP a in HRM

section .data
    input  dd 42, 0, 10, 0  ; Example inputs (including zeros)
    output dd 0             ; Output storage
