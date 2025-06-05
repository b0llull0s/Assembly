; ==============================================================
; Core features:
;   1. Handles 1-4 byte UTF-8 characters (including emojis).
;   2. Detects malformed UTF-8 (optional error handling).
; ==============================================================

section .text
    global _start

_start:
    ; --- Simulate input (addresses pointing to UTF-8 strings) ---
    mov     esi, inbox_addresses  ; List of string addresses
    mov     edi, utf8_data        ; Floor: UTF-8 strings (null-terminated)

.process_address:
    lodsd                         ; eax = address 
    add     eax, edi              ; Convert to memory address
    mov     ebx, eax             ; ebx = current char pointer 

.next_char:
    movzx   ecx, byte [ebx]       ; Load next byte 
    test    cl, cl                ; Check for null terminator 
    jz      .process_address      ; End of string? Move to next address.

    ; --- UTF-8 Decoding Logic ---
    ; Determine byte length of the character (1-4 bytes)
    cmp     cl, 0x80              ; ASCII (1-byte)?
    jb      .output_char          ; If yes, output directly.

    ; Multi-byte UTF-8 handling
    mov     edx, ecx              ; Save first byte
    inc     ebx                   ; Move to next byte
    mov     ch, [ebx]             ; Read second byte
    test    dl, 0xE0              ; 2-byte sequence (110xxxxx)?
    jz      .invalid_utf8         ; Handle error (optional)
    cmp     dl, 0xE0              ; 3-byte sequence (1110xxxx)?
    jb      .output_char_2byte
    cmp     dl, 0xF0              ; 4-byte sequence (11110xxx)?
    jb      .output_char_3byte

    ; 4-byte sequence (11110xxx 10xxxxxx ...)
    mov     cl, [ebx+1]           ; Read third byte
    mov     dh, [ebx+2]           ; Read fourth byte
    add     ebx, 3                ; Advance pointer by 3
    jmp     .output_char_utf8

.output_char_2byte:
    ; 2-byte sequence (110xxxxx 10xxxxxx)
    shl     edx, 8
    mov     dl, ch                ; Combine bytes
    inc     ebx                   ; Advance pointer
    jmp     .output_char_utf8

.output_char_3byte:
    ; 3-byte sequence (1110xxxx 10xxxxxx 10xxxxxx)
    mov     cl, [ebx+1]           ; Read third byte
    shl     edx, 16
    mov     dx, cx                ; Combine bytes
    add     ebx, 2                ; Advance pointer
    jmp     .output_char_utf8

.output_char:
    ; Single-byte ASCII (0xxxxxxx)
    mov     [output], cl          ; OUTBOX
    inc     ebx                   ; BUMPUP 24
    jmp     .next_char

.output_char_utf8:
    ; --- Placeholder: Process full UTF-8 codepoint (EDX) ---
    ; (In real code, convert to UTF-32 or process further)
    mov     [output], edx         
    jmp     .next_char

.invalid_utf8:
    ; Optional: Handle malformed UTF-8 (e.g., skip or error)
    inc     ebx                   ; Skip corrupt byte
    jmp     .next_char

section .data
    ; --- Example Data ---
    inbox_addresses dd 0, 6       ; Addresses of strings in utf8_data
    utf8_data       db 'A', 0                             ; "A" (ASCII)
                    db 0xC3, 0xA9, 0                     ; "é" (2-byte)
                    db 0xE2, 0x82, 0xAC, 0               ; "€" (3-byte)
                    db 0xF0, 0x9F, 0x98, 0x80, 0         ; "😀" (4-byte)
    output          dd 0           

section .text
    ; --- Exit (Linux syscall) ---
    mov     eax, 60               ; sys_exit
    xor     edi, edi              ; status 0
    syscall
