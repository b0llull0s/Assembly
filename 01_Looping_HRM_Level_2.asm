section .bss
    small_buffer resb 1    ; 1-byte buffer for size/speed cases
    big_buffer   resb 256  ; 256-byte buffer for max-speed case

section .text
    global _start

; ======================================================================
; CASE 1: SIZE-OPTIMIZED 
; - Minimal code size
; - HIGH overhead: 2 syscalls + 1 jump PER BYTE
; ======================================================================
size_optimized:
    ; Syscall to READ 1 byte
    mov eax, 3             ; sys_read
    mov ebx, 0             ; stdin
    mov ecx, small_buffer  ; 
    mov edx, 1             ; 1 byte
    int 0x80

    ; Syscall to WRITE that byte
    mov eax, 4             ; sys_write
    mov ebx, 1             ; stdout
    ; ecx and edx already set!
    int 0x80

    ; Tight loop
    jmp size_optimized

; ======================================================================
; CASE 2: SPEED-OPTIMIZED WITH UNROLLING 
; - Larger code size
; - LOWER overhead: 2 syscalls + 1 jump PER 2 BYTES (50% less jumps)
; ======================================================================
speed_optimized:
    ; ---- BYTE 1 ----
    mov eax, 3             ; sys_read
    mov ebx, 0             ; stdin
    mov ecx, small_buffer
    mov edx, 1
    int 0x80
    mov eax, 4             ; sys_write
    mov ebx, 1             ; stdout
    int 0x80

    ; ---- BYTE 2 ----
    ; Registers still set from previous ops!
    mov eax, 3             ; sys_read
    int 0x80
    mov eax, 4             ; sys_write
    int 0x80

    ; Loop after processing 2 bytes
    jmp speed_optimized

; ======================================================================
; CASE 3: MAX-SPEED WITH BUFFERING 
; - Even larger code
; - LOWEST overhead: 2 syscalls + 1 jump PER 256 BYTES
; ======================================================================
max_speed:
    ; Read up to 256 bytes in one syscall
    mov eax, 3             ; sys_read
    mov ebx, 0             ; stdin
    mov ecx, big_buffer
    mov edx, 256           ; buffer size
    int 0x80

    ; Write all bytes we just read
    mov edx, eax           ; sys_read returns byte count in eax
    mov eax, 4             ; sys_write
    mov ebx, 1             ; stdout
    ; ecx still points to buffer
    int 0x80

    ; Loop
    jmp max_speed

; ======================================================================
; ENTRY POINT (Toggle which case to run by uncommenting)
; ======================================================================
_start:
    ; Uncomment ONE of these to test a specific case:
    ;jmp size_optimized
    ;jmp speed_optimized
    jmp max_speed
