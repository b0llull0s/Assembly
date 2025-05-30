;===============================================
; Linux x86 System Call Reference (32-bit)
; To use: 
;   1) Set input registers (see each function)
;   2) call function_name
;   3) Check return value (if any) in EAX/AL
;===============================================

;-------------------------------
; 1) Print a Single Character
;-------------------------------
section .data
    ; (No initialized data needed for this example)

section .bss
    char resb 1  ; Reserve 1 byte of uninitialized memory for character storage

section .text
    global _start  ; Declare _start as the entry point for the linker

_start:
    mov al, 'X'       ; Load ASCII 'X' into AL register (lower 8 bits of EAX)
    call _print_char  ; Call the character printing function
    
    ; Exit the program
    mov eax, 1        ; sys_exit system call number
    mov ebx, 0        ; Exit status code (0 = success)
    int 0x80          ; Invoke kernel to execute system call

_print_char:
    mov [char], al    ; Store the character from AL into memory at [char]
    mov eax, 4        ; sys_write system call number
    mov ebx, 1        ; File descriptor 1 (stdout = screen output)
    mov ecx, char     ; Pointer to the character to print
    mov edx, 1        ; Number of bytes to print (just 1 character)
    int 0x80          ; Invoke kernel to execute system call
    ret               ; Return from function to caller

;-------------------------------
; 2) Print a String
;-------------------------------
section .data
    msg db "Hello World!", 0xA  ; Define string with newline (0xA)
    len equ $ - msg             ; Calculate string length (current pos - start)

section .text
    global _start

_start:
    mov esi, msg    ; Load address of string into ESI register
    mov edx, len    ; Load pre-calculated string length into EDX
    call _print_string  ; Call the string printing function
    
    ; Exit
    mov eax, 1
    mov ebx, 0
    int 0x80

_print_string:
    mov eax, 4      ; sys_write system call
    mov ebx, 1      ; stdout
    mov ecx, esi    ; Move string address from ESI to ECX (where sys_write expects it)
    int 0x80        ; Execute system call
    ret             ; Return to caller

;-------------------------------
; 3) Read character from keyboard
;-------------------------------
section .bss
    char resb 1  ; Reserve 1 byte for input character storage

section .text
    global _start

_start:
    call _read_char  ; Call function to read character (result will be in AL)
    
    ; Exit
    mov eax, 1
    mov ebx, 0
    int 0x80

_read_char:
    mov eax, 3      ; sys_read system call
    mov ebx, 0      ; stdin (file descriptor 0 = keyboard input)
    mov ecx, char   ; Buffer to store the read character
    mov edx, 1      ; Read exactly 1 byte
    int 0x80        ; Execute system call
    mov al, [char]  ; Move the read character from memory to AL register
    ret             ; Return with character in AL

;-------------------------------
; 4) Open a file
;-------------------------------
section .data
    filename db "test.txt", 0  ; Null-terminated filename string

section .text
    global _start

_start:
    mov ebx, filename  ; Pointer to filename string
    mov ecx, 0         ; Flags (0 = O_RDONLY = read-only)
    call _open_file    ; Call function (returns file descriptor in EAX)
    
    ; Exit
    mov eax, 1
    mov ebx, 0
    int 0x80

_open_file:
    mov eax, 5      ; sys_open system call
    int 0x80        ; Execute (returns file descriptor in EAX or error code)
    ret             ; Return to caller with result in EAX

;-------------------------------
; 5) Create a File
;-------------------------------
section .data
    filename db "newfile.txt", 0  ; Null-terminated filename

section .text
    global _start

_start:
    mov ebx, filename  ; Pointer to filename string
    mov ecx, 0644o     ; File permissions (octal 644 = rw-r--r--)
    call _create_file  ; Call function (returns file descriptor in EAX)
    
    ; Exit
    mov eax, 1
    mov ebx, 0
    int 0x80

_create_file:
    mov eax, 8      ; sys_creat system call
    int 0x80        ; Execute (returns file descriptor in EAX)
    ret             ; Return to caller
