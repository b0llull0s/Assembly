section .bss
    temp resd 1   ; Like HRM's floor tile 0

; Main Program
_start:
    call _read_int   ; Get first number → EAX
    mov [temp], eax  ; COPYTO 0
    
    call _read_int   ; Get second number → EAX
    call _print_int  ; OUTBOX (B first)
    
    mov eax, [temp]  ; COPYFROM 0
    call _print_int  ; OUTBOX (A second)
    
    call _exit

;--------------------
; Helpers
;--------------------
_read_int:
    ; sys_read into temp, then return value in EAX
    mov eax, 3       ; sys_read
    mov ebx, 0       ; stdin
    mov ecx, temp    ; Store input here
    mov edx, 4       ; Read 4 bytes
    int 0x80
    mov eax, [temp]  ; Return value
    ret

_print_int:
    ; Print value in EAX
    mov [temp], eax
    mov eax, 4       ; sys_write
    mov ebx, 1       ; stdout
    mov ecx, temp
    mov edx, 4
    int 0x80
    ret

_exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
