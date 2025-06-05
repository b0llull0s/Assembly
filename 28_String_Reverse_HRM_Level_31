; ==============================================================
;   1. Original HRM logic translation
;   2. Basic x86 optimization
;   3. Advanced SIMD optimization
;   4. Malware tricks
; ==============================================================

section .text
    global _start

; -------------------------------------------------------------------
; PART 1: HRM Logic Direct Translation (Educational Baseline)
; -------------------------------------------------------------------
hrm_style_reverse:
    mov edi, floor_memory   ; HRM's floor tiles (0-19)
    mov esi, inbox          ; INBOX pointer
    mov ebp, 0x2000         ; Tile 14 (stack pointer)

.push_loop:
    lodsb                   ; INBOX -> AL
    test al, al             ; JUMPZ
    jz .pop_loop_start
    mov [ebp], al           ; COPYTO [14]
    inc ebp                 ; BUMPUP 14
    jmp .push_loop

.pop_loop_start:
    dec ebp                 ; BUMPDN 14
    cmp ebp, 0x2000         ; JUMPZ
    jb .hrm_done
    mov al, [ebp]           ; COPYFROM [14]
    mov [output], al        ; OUTBOX
    jmp .pop_loop_start

.hrm_done:
    ret

; -------------------------------------------------------------------
; PART 2: Optimized x86 Version (Production-grade)
; -------------------------------------------------------------------
optimized_reverse:
    mov esi, inbox
.process_string:
    ; Find string end and length
    mov edi, esi
    xor ecx, ecx
    not ecx
    xor eax, eax
    repne scasb             ; Find null terminator
    not ecx
    dec ecx                 ; ECX = string length

    ; In-place reverse
    lea edi, [esi + ecx - 1] ; EDI = end pointer
.reverse_loop:
    cmp esi, edi
    jge .string_done
    mov al, [esi]
    mov ah, [edi]
    mov [esi], ah
    mov [edi], al
    inc esi
    dec edi
    jmp .reverse_loop

.string_done:
    ; Output reversed string
    mov edx, ecx
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    int 0x80
    ret

; -------------------------------------------------------------------
; PART 3: Advanced SIMD Optimization (For long strings)
; -------------------------------------------------------------------
simd_reverse:
    mov esi, inbox
    mov edi, output_buffer
    mov ecx, max_length

    ; Load 16 bytes at once
    movdqu xmm0, [esi]
    ; Reverse using shuffle mask
    pshufb xmm0, [reverse_mask]
    movdqu [edi], xmm0
    ret

reverse_mask db 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

; -------------------------------------------------------------------
; PART 4: Malware Tricks (For educational purposes)
; -------------------------------------------------------------------
stealth_reverse:
    ; XOR obfuscated strings
    mov esi, encrypted_string
    mov edi, esi
    mov ecx, string_len
.decrypt_loop:
    lodsb
    xor al, 0x55
    stosb
    loop .decrypt_loop

    ; Reverse while avoiding null terminators
    mov esi, encrypted_string
    call optimized_reverse
    ret

; -------------------------------------------------------------------
; MAIN PROGRAM
; -------------------------------------------------------------------
_start:
    ; Run all versions for comparison
    call hrm_style_reverse
    call optimized_reverse
    call simd_reverse
    call stealth_reverse

    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

section .data
    inbox db 'Hello',0,'World',0
    output times 256 db 0
    output_buffer times 16 db 0
    floor_memory times 20 db 0
    encrypted_string db 0x25,0x30,0x33,0x33,0x36,0x55 ; "Hello" XOR 0x55
    string_len equ $ - encrypted_string
    max_length equ 16
