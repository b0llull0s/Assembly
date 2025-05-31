section .data
    inbox   dd  3, 7, -1, 2, -999  ; Pairs: (3+7), (-1+2), then terminate
    outbox  dd  0                   ; Output storage

section .text
    global _start
_start:
    mov  esi, inbox               ; ESI = pointer to inbox (like HRM's conveyor belt)

process_pair:
    ; Read first num (or terminate)
    mov  eax, [esi]               ; INBOX -> EAX
    cmp  eax, -999                ; Check for terminator
    je   exit                     ; If terminator, exit
    mov  [temp], eax              ; COPYTO 0 (store in temp memory)

    ; Read second num (must exist if first wasn't -999)
    add  esi, 4                   ; Move to next number
    mov  eax, [esi]               ; INBOX -> EAX
    add  eax, [temp]              ; ADD 0 (add first num)

    ; Output result
    mov  [outbox], eax            ; OUTBOX
    ; (In real code, you'd print this or store it elsewhere)

    ; Prepare for next pair
    add  esi, 4                   ; Move to next pair
    jmp  process_pair             ; JUMP a

exit:
    ; Terminate program (Linux sys_exit)
    mov  eax, 1
    xor  ebx, ebx
    int  0x80

section .bss
    temp    resd 1                ; Floor tile 0 (temporary storage)
