section .data
    ; Define memory addresses
    ; ? are arbitrary values (could be 0 or any byte) used to avoid breaking the index mapping
    mem db 'U', '?', '?', 'G', 'B'  ; mem[0]=U, mem[3]=G, mem[4]=B

section .text
    global _start

_start:
    ; Output 'B' (mem[4])
    movzx eax, byte [mem + 4]  ; Load mem[4] into EAX
    call write_char             ; Output it

    ; Output 'U' (mem[0])
    movzx eax, byte [mem + 0]  ; Load mem[0]
    call write_char

    ; Output 'G' (mem[3])
    movzx eax, byte [mem + 3]  ; Load mem[3]
    call write_char

    ; Exit
    mov eax, 1      ; sys_exit
    xor ebx, ebx    ; status=0 (EBX=0 is the status code for success) xor between identical values always gives 0.
    int 0x80

; Helper: Write ASCII char in AL to stdout
write_char:
    mov [char], al      ; Store the character (from AL, which is part of EAX) into memory at [char]
    mov eax, 4          ; Syscall number 4 = sys_write (output)
    mov ebx, 1          ; File descriptor 1 = stdout (screen)
    mov ecx, char       ; Pointer to the character to print
    mov edx, 1          ; Length = 1 byte
    int 0x80            ; Call the kernel to execute the syscall
    ret                 ; Return to where the function was called
; [char] = value at char; char = address of char.
section .bss
    char resb 1     ; Temp storage for output
