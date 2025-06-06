; ================================================
; Key Concepts:
;   1. Base-10 digit extraction
;   2. Division via subtraction
;   3. Place value tracking
; ================================================

section .text
    global _start

; -------------------------------------------------------------------
; PART 1: HRM Literal Translation (Educational)
; -------------------------------------------------------------------
hrm_digit_exploder:
    mov esi, inbox          ; INBOX pointer
    mov edi, output         ; OUTBOX pointer

.process_number:
    lodsd                   ; Get number (COPYTO 2)
    test eax, eax
    jz .done

    ; Initialize place counters (tile 0=100s, tile 1=10s)
    xor ebx, ebx            ; ebx = tile 0
    xor ecx, ecx            ; ecx = tile 1

.extract_100s:
    cmp eax, 100            ; SUB 11 (HRM's 100)
    jl .extract_10s
    sub eax, 100
    inc ebx                 ; BUMPUP 0
    jmp .extract_100s

.extract_10s:
    cmp eax, 10             ; SUB 10
    jl .output_digits
    sub eax, 10
    inc ecx                 ; BUMPUP 1
    jmp .extract_10s

.output_digits:
    ; Output hundreds place if present
    test ebx, ebx
    jz .skip_hundreds
    mov [edi], bl           ; OUTBOX tile 0
    add edi, 4

.skip_hundreds:
    ; Output tens place if present
    test ecx, ecx
    jz .output_units
    mov [edi], cl           ; OUTBOX tile 1
    add edi, 4

.output_units:
    mov [edi], al           ; OUTBOX tile 2
    add edi, 4
    jmp .process_number

.done:
    ret

; -------------------------------------------------------------------
; PART 2: Optimized Division-Based Version
; -------------------------------------------------------------------
optimized_exploder:
    mov esi, inbox
    mov edi, output
    mov ebp, 10             ; Base 10 divisor

.process_num:
    lodsd
    test eax, eax
    jz .finished

    ; Count digits by place value
    mov ecx, 100            ; Start with hundreds place
    call .extract_digit
    mov ecx, 10             ; Tens place
    call .extract_digit
    mov [edi], eax          ; Units place
    add edi, 4
    jmp .process_num

.extract_digit:
    xor edx, edx
    div ecx                 ; EDX:EAX / ECX
    test eax, eax
    jz .no_digit
    mov [edi], eax
    add edi, 4
.no_digit:
    mov eax, edx            ; Remainder
    ret

.finished:
    ret

; -------------------------------------------------------------------
; PART 3: SIMD Parallel Decomposition
; -------------------------------------------------------------------
simd_exploder:
    ; Processes 4 numbers simultaneously
    movdqu xmm0, [inbox]    ; Load 4 numbers
    movdqa xmm1, xmm0
    movdqa xmm2, xmm0

    ; Extract hundreds (x/100)
    mov eax, 100
    movd xmm3, eax
    pshufd xmm3, xmm3, 0
    pdivud xmm1, xmm3       ; AVX-512 division

    ; Extract tens ((x%100)/10)
    pmodud xmm2, xmm3       ; Modulo
    mov eax, 10
    movd xmm3, eax
    pshufd xmm3, xmm3, 0
    pdivud xmm2, xmm3

    ; Units are x%10
    pmodud xmm0, xmm3

    ; Store results
    movdqu [output], xmm1
    movdqu [output+16], xmm2
    movdqu [output+32], xmm0
    ret

; -------------------------------------------------------------------
; Data Section
; -------------------------------------------------------------------
section .data
    inbox dd 123, 45, 7, 0
    output times 32 dd 0

section .text
_start:
    call hrm_digit_exploder
    call optimized_exploder
    call simd_exploder
    mov eax, 60
    xor edi, edi
    syscall
