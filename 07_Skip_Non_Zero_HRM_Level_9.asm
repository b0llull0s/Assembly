section .text
    global _start

; Copies zeroes from input to output and discards non-zero values

; ---------------------------------------------------------------------------
; SIZE-OPTIMIZED VERSION 
; ---------------------------------------------------------------------------
size_optimized:
    .loop_inbox:
        call read_input    ; Value will be in eax
        
        test eax, eax      ; Test if value is zero
        jz .output_zero    ; If zero, jump to output section
        
        jmp .loop_inbox
    
    .output_zero:
        call write_output
        
        jmp size_optimized

; ---------------------------------------------------------------------------
; SPEED-OPTIMIZED VERSION 
; ---------------------------------------------------------------------------
speed_optimized:
    jmp .input_loop       ; Initial jump to start reading input
    
    .output_zero:
        call write_output
    
    .input_loop:
        call read_input   ; Value will be in eax
        
        test eax, eax     ; Test if value is zero
        jz .output_zero   ; If zero, jump to output
        
        jmp .input_loop

; ---------------------------------------------------------------------------
; Helper functions and main program
; ---------------------------------------------------------------------------

; Read input value into eax
read_input:
    ; In a real implementation, this would read from stdin or another input source
    ; For demonstration, we'll just return alternating values ending with 0
    mov eax, [current_input]
    add dword [current_input], 1
    ret

; Write value from eax to output
write_output:
    ; In a real implementation, this would write to stdout
    ; For demonstration, we'll just track the count
    add dword [output_count], 1
    ret

_start:
    ; Initialize test data
    mov dword [current_input], 1
    mov dword [output_count], 0
    
    ; Run the speed-optimized version by default
    call speed_optimized
    
    ; Exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

section .data
current_input dd 0
output_count dd 0
