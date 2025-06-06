; ================================================
; Key Concepts:
;   1. String comparison algorithms
;   2. Memory-address manipulation
; 3. Offensive: Pointer abuse potential
; ================================================

section .text
    global _start

; -------------------------------------------------------------------
; PART 1: HRM Literal Translation (With Security Notes)
; -------------------------------------------------------------------
hrm_alphabetizer:
    mov esi, inbox          ; INBOX pointer
    mov edi, word_buffer    ; Tile 23 equivalent
    mov ebp, edi            ; Current pointer (Tile 22)

; Read first word (terminated by 0)
.read_word1:
    lodsb
    test al, al
    jz .read_word2
    mov [edi], al           ; COPYTO [23]
    inc edi                 ; BUMPUP 23
    jmp .read_word1

.read_word2:
    mov ebp, edi            ; Reset pointer for comparison

.compare_loop:
    lodsb                   ; INBOX (second word)
    test al, al
    jz .output_word1        ; End of second word

    ; Security Note: No bounds checking - potential overflow
    cmp al, [ebp]          ; SUB [22]
    jb .output_word2       ; JUMPN (second word is first)
    ja .output_word1       ; First word is first
    inc ebp                ; BUMPUP 22
    jmp .compare_loop

.output_word1:
    ; Offensive Tip: Could embed shellcode in "word" buffers
    mov esi, word_buffer
    jmp .output_result

.output_word2:
    mov esi, inbox
    add esi, 5              ; Skip first word

.output_result:
    lodsb
    test al, al
    jz .done
    mov [output], al        ; OUTBOX
    jmp .output_result

.done:
    ret

; -------------------------------------------------------------------
; PART 2: Optimized + Weaponized Version
; -------------------------------------------------------------------
weaponized_comparison:
    ; Attack surface: Unbounded writes to word_buffer
    mov edi, word_buffer
    mov ecx, 0xFFFFFFFF    ; Maximum length 
    rep movsb              ; Buffer overflow potential

    ; ROP chain setup example (hypothetical)
    mov eax, [word_buffer+256] ; Overwrite return address
    jmp eax

; -------------------------------------------------------------------
; Data Section
; -------------------------------------------------------------------
section .data
    inbox db 'hello',0,'world',0
    word_buffer times 256 db 0
    output times 256 db 0

section .text
_start:
    call hrm_alphabetizer
    ; call weaponized_comparison ; (Disabled for safety)
    mov eax, 60
    xor edi, edi
    syscall
