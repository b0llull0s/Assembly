; ================================================
; Key Concepts:
;   1. Bubble sort implementation
;   2. In-place array manipulation
;   3. Pointer arithmetic
; Security Considerations:
;   - Memory corruption via unbounded writes
;   - Timing side channels
; ================================================

section .text
    global _start

; -------------------------------------------------------------------
; PART 1: HRM Literal Translation 
; -------------------------------------------------------------------
hrm_bubblesort:
    mov esi, inbox          ; INBOX pointer
    mov edi, array          ; Tile 20 equivalent
    mov ebp, edi            ; Current pointer

.load_loop:
    lodsb                   ; INBOX -> AL (COPYTO [20])
    test al, al
    jz .sort_phase
    mov [ebp], al           ; Store in array
    inc ebp                 ; BUMPUP 20
    jmp .load_loop

.sort_phase:
    dec ebp                 ; Last element (n-1)
    mov ecx, ebp            ; Outer loop counter

.outer_loop:
    mov edx, array          ; Inner loop pointer (tile 21)
    mov ebx, edx            ; Tile 22 (next element)

.inner_loop:
    inc ebx                 ; BUMPUP 22
    cmp ebx, ecx
    ja .end_inner

    ; Compare adjacent elements
    mov al, [edx]           ; COPYFROM [21]
    cmp al, [ebx]           ; SUB [22]
    jle .no_swap

    ; Swap elements
    mov ah, [ebx]           ; COPYFROM [22]
    mov [ebx], al           ; COPYTO [21]
    mov [edx], ah           ; COPYTO [22] via tile 23

.no_swap:
    inc edx                 ; BUMPUP 21
    jmp .inner_loop

.end_inner:
    loop .outer_loop

.output_loop:
    mov esi, array
.output:
    lodsb                   ; COPYFROM [20]
    test al, al
    jz .done
    mov [output], al        ; OUTBOX
    jmp .output

.done:
    ret

; -------------------------------------------------------------------
; PART 2: Optimized 
; -------------------------------------------------------------------
optimized_bubblesort:
    mov esi, inbox
    mov edi, array
    mov ecx, MAX_SIZE

.load_data:
    lodsb
    test al, al
    jz .start_sort
    mov [edi], al
    inc edi
    dec ecx
    jnz .load_data

.start_sort:
    mov ebp, edi            ; ebp = n
    sub ebp, array

.outer:
    dec ebp
    jz .output
    xor ebx, ebx            ; swapped flag

.inner:
    mov al, [array + ebx]
    cmp al, [array + ebx + 1]
    jle .no_swap_opt
    ; Swap with XOR (no temp)
    xor al, [array + ebx + 1]
    xor [array + ebx + 1], al
    xor al, [array + ebx + 1]
    mov [array + ebx], al
    mov ebx, 1              ; set swapped

.no_swap_opt:
    inc ebx
    cmp ebx, ebp
    jb .inner
    test ebx, ebx           ; check swapped
    jnz .outer

.output:
    ; ... (same output as before)
    ret

; -------------------------------------------------------------------
; PART 3: Weaponized Sort (Hypothetical Exploit)
; -------------------------------------------------------------------
weaponized_sort:
    ; Attack vector: Out-of-bounds write via overflow
    mov ecx, [inbox]        ; Attacker-controlled length
    mov esi, inbox + 4
    mov edi, array

.malicious_load:
    lodsd
    stosd                   ; Unbounded copy
    loop .malicious_load

    ; Corrupt adjacent memory
    mov dword [array + MAX_SIZE*4], 0xDEADBEEF
    ret

; -------------------------------------------------------------------
; Data Section
; -------------------------------------------------------------------
section .data
    inbox db 5,3,8,6,2,0    ; Test input
    array times 256 db 0
    output times 256 db 0
    MAX_SIZE equ 64

section .text
_start:
    call hrm_bubblesort
    call optimized_bubblesort
    ; call weaponized_sort    ; (Disabled)
    mov eax, 60
    xor edi, edi
    syscall
