; ==============================================================
;   1. Speed-optimized (pointer arithmetic, `lodsb`)
;   2. Size-optimized (compact loop)
; Core concept: Print a null-terminated string from a memory address.
; ==============================================================

section .text
    global _start

_start:
    ; --- Simulate HRM's floor (replace with syscalls) ---
    mov     esi, inbox       ; esi = INBOX (list of addresses)
    mov     edi, string_data ; edi = Floor tiles (string storage)

.process_address:
    lodsd                   ; eax = [esi++] (INBOX: get address)
    add     eax, edi        ; Convert HRM "tile number" to memory address
    mov     ebx, eax        ; ebx = current char pointer (COPYTO 24)

.output_loop:
    mov     al, [ebx]       ; al = [ebx] (COPYFROM [24])
    test    al, al          ; Check for zero terminator (JUMPZ)
    jz      .process_address
    ; --- Simulate OUTBOX (replace with syscall) ---
    mov     [output], al    ; Print character
    inc     ebx             ; BUMPUP 24
    jmp     .output_loop

section .data
    inbox       dd 0, 5, 2  ; Example addresses (0=start of 'Hello', 5=start of 'World')
    string_data db 'H', 'e', 'l', 'l', 'o', 0, 'W', 'o', 'r', 'l', 'd', 0  ; Null-terminated strings
    output      db 0         ; OUTBOX buffer

section .text
    ; --- Exit (Linux syscall) ---
    mov     eax, 60          ; sys_exit
    xor     edi, edi         ; status 0
    syscall
; For large strings, use SSE (pcmpistri) to find the null terminator faster!

