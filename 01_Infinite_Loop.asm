section .text
    global _start   ; Entry point for the program

_start:    ; Label
    ; Read from input (sys_read)
    mov eax, 3      ; syscall number for sys_read
    mov ebx, 0      ; file descriptor 0 (stdin)
    mov ecx, buffer ; buffer to store input
    mov edx, 1      ; read 1 byte at a time
    int 0x80        ; call kernel

    ; Write to output (sys_write)
    mov eax, 4      ; syscall number for sys_write
    mov ebx, 1      ; file descriptor 1 (stdout)
    mov ecx, buffer ; buffer containing the byte to write
    mov edx, 1      ; write 1 byte
    int 0x80        ; call kernel

    ; Jump back to _start (loop forever)
    jmp _start

section .bss
    buffer resb 1   ; Reserve 1 byte for input/output
