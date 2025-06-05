; A simple self-modifying decryptor that changes its signature each run
section .text
global _start

_start:
    jmp setup_data

decryptor:
    pop esi                 ; Get address of encrypted code
    mov ecx, (encrypted_end - encrypted_code)/4
    mov edi, esi            ; Copy to same location (overwrite)

decrypt_loop:
    lodsd                   ; Load dword from [esi] into eax
    xor eax, 0xDEADBEEF     ; Decrypt with current key (will be modified)
    stosd                   ; Store decrypted dword at [edi]
    loop decrypt_loop
    jmp encrypted_code      ; Jump to decrypted code

setup_data:
    call decryptor          ; Push address of encrypted_code onto stack

; This is the encrypted payload (a simple message print)
encrypted_code:
    dd 0x8D7DE5F1, 0x9D3DE5F1, 0x8D3DE5F1, 0x953DE5F1  ; "Hello" encrypted
    dd 0x8F3DE5F1, 0x813DE5F1, 0x9B3DE5F1, 0x853DE5F1  ; " World!" encrypted
    dd 0x0103DE5F1                                       ; Newline + null encrypted
encrypted_end:

; This is the code that will modify the decryptor
mutator:
    ; Generate a semi-random key (in reality you'd use a better RNG)
    rdtsc                  ; Read time-stamp counter (somewhat random)
    and eax, 0xFFFF0000    ; Mask to 16 bits
    or eax, 0xBEEF         ; Ensure it's not zero
    mov [decryptor+7], eax ; Modify the XOR key in the decryptor
    
    ; Now modify some instructions (change registers or operations)
    mov byte [decryptor+12], 0x8D  ; Could change from MOV EDI,ESI to something else
    mov byte [decryptor+17], 0x31  ; Could change XOR to something else
    
    ; Jump to the decryptor
    jmp decryptor

section .data
    ; No data section needed for this simple example
