; Key Concepts:
;   1. State maintenance (seen values)
;   2. Linear search through history
;   3. Early rejection of duplicates
; Optimizations:
;   1. Memory-efficient history buffer
;   2. Branch prediction hints
;   3. Dual-pointer traversal
; ================================================

section .text
    global _start

; -------------------------------------------------------------------
; PART 1: HRM Literal Translation
; -------------------------------------------------------------------
hrm_duplicate_filter:
    mov esi, inbox          ; INBOX pointer
    mov edi, history        ; History buffer (tile 14)
    mov ebp, edi            ; Current item pointer

.process_item:
    lodsb                   ; INBOX -> AL
    test al, al
    jz .done

    ; Store new item (COPYTO [14])
    mov [ebp], al
    inc ebp                 ; BUMPUP 14

    ; Output if unique (first occurrence)
    mov [output], al
    inc output

    ; Check history (tile 13 scan)
    mov ebx, ebp            ; ebx = tile 13
    sub ebx, 2              ; Start at previous item

.check_history:
    cmp ebx, edi
    jl .process_item        ; JUMPN (end of history)

    mov dl, [ebx]           ; COPYFROM [13]
    cmp al, dl              ; SUB [13] + JUMPZ
    je .process_item        ; Duplicate found

    dec ebx                 ; BUMPDN 13
    jmp .check_history

.done:
    ret

; -------------------------------------------------------------------
; PART 2: Optimized Hash-Based Version
; -------------------------------------------------------------------
optimized_filter:
    mov esi, inbox
    mov edi, output
    xor eax, eax

    ; Initialize bitmap (256 bits = 32 bytes)
    mov ecx, 8
    xor ebx, ebx
.init_bitmap:
    mov [bitmap + ecx*4 - 4], ebx
    loop .init_bitmap

.process_byte:
    lodsb
    test al, al
    jz .finished

    ; Check bitmap
    movzx edx, al
    bt [bitmap], edx
    jc .process_byte        ; Already seen

    ; Mark as seen and output
    bts [bitmap], edx
    stosb
    jmp .process_byte

.finished:
    ret

; -------------------------------------------------------------------
; Data Section
; -------------------------------------------------------------------
section .data
    inbox db 'A','B','A','C','B','D',0
    history times 256 db 0
    output times 256 db 0
    bitmap times 32 db 0    ; 256-bit presence bitmap

section .text
_start:
    call hrm_duplicate_filter
    call optimized_filter
    mov eax, 60
    xor edi, edi
    syscall
