; ================================================
; Key Concepts:
;   1. Membership testing against constant set
;   2. Early rejection/acceptance patterns
; 3. Tradeoffs between branching vs. lookup
; ================================================

section .text
    global _start

; -------------------------------------------------------------------
; PART 1: HRM Literal Translation (Educational Baseline)
; -------------------------------------------------------------------
hrm_vowel_filter:
    mov esi, inbox          ; INBOX pointer
    mov edi, vowels         ; Vowel set (zero-terminated)
    mov ebp, output         ; OUTBOX pointer

.process_char:
    lodsb                   ; INBOX -> AL (COPYTO 6)
    test al, al
    jz .done

    mov ebx, edi            ; Vowel pointer (tile 7)
.check_vowel:
    mov dl, [ebx]          ; COPYFROM [7]
    test dl, dl             ; JUMPZ (end of vowels)
    jz .output_char

    cmp al, dl              ; SUB 6 + JUMPZ
    je .process_char        ; Skip vowel

    inc ebx                 ; BUMPUP 7
    jmp .check_vowel

.output_char:
    mov [ebp], al           ; OUTBOX
    inc ebp
    jmp .process_char

.done:
    ret

; -------------------------------------------------------------------
; PART 2: Optimized Branchless Version
; -------------------------------------------------------------------
optimized_filter:
    mov esi, inbox
    mov edi, output
    mov ecx, vowels_bitmask ; Precomputed bitmask

.process_byte:
    lodsb
    test al, al
    jz .finished

    ; Convert char to bit index
    movzx edx, al
    bt ecx, edx             ; Test vowel bit
    jc .process_byte        ; Skip if vowel

    stosb                   ; Store non-vowel
    jmp .process_byte

.finished:
    ret

; -------------------------------------------------------------------
; PART 3: SIMD Version (16 chars at once)
; -------------------------------------------------------------------
simd_filter:
    movdqu xmm0, [inbox]    ; Load 16 chars
    movdqa xmm1, [vowel_mask]
    pcmpeqb xmm0, xmm1      ; Compare against vowels
    pmovmskb eax, xmm0      ; Get match mask
    not eax                 ; Invert for non-vowels
    mov [output], eax       ; Store filtered
    ret

; -------------------------------------------------------------------
; Data Section
; -------------------------------------------------------------------
section .data
    inbox db 'H','e','l','l','o',' ','W','o','r','l','d',0
    vowels db 'a','e','i','o','u','A','E','I','O','U',0
    output times 256 db 0
    vowels_bitmask dd 0x8200800000000000 ; Bitmask for aeiouAEIOU
    vowel_mask db 'a','e','i','o','u','A','E','I','O','U',0,0,0,0,0,0

section .text
_start:
    call hrm_vowel_filter
    call optimized_filter
    call simd_filter
    mov eax, 60
    xor edi, edi
    syscall
