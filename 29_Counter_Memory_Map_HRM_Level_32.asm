; ==============================================================
; File: InventoryReport_Complete.asm
;   1. Original HRM logic translation
;   2. Optimized x86 version
;   3. SIMD-accelerated counting
;   4. Malware-inspired obfuscation
; ==============================================================

section .text
    global _start

; -------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------
%define FLOOR_SIZE 20
%define FLOOR_ADDR 0x1000

; -------------------------------------------------------------------
; PART 1: HRM Logic Direct Translation
; -------------------------------------------------------------------
hrm_inventory:
    mov esi, inbox          ; INBOX pointer
    mov edi, floor_data     ; FLOOR memory (tiles 0-19)
    mov ebp, FLOOR_ADDR + (14 * 4) ; Tile 14 pointer

.process_inbox:
    lodsb                   ; INBOX -> AL (COPYTO 15)
    test al, al             ; Handle empty inbox
    jz .done

    ; Initialize counters (HRM tiles 18, 19)
    mov ebx, FLOOR_ADDR     ; ebx = tile 18 (current pointer)
    mov ecx, 0              ; ecx = tile 19 (count)

.scan_floor:
    mov edx, [ebx]          ; COPYFROM [18]
    test edx, edx           ; JUMPZ (end of floor)
    jz .output_count

    cmp edx, eax            ; SUB 15 + JUMPZ
    jne .next_item
    inc ecx                 ; BUMPUP 19

.next_item:
    add ebx, 4              ; BUMPUP 18
    jmp .scan_floor

.output_count:
    mov [output], ecx       ; OUTBOX
    jmp .process_inbox

.done:
    ret

; -------------------------------------------------------------------
; PART 2: Optimized x86 Version
; -------------------------------------------------------------------
optimized_inventory:
    mov esi, inbox
    mov edi, floor_data
    mov ecx, FLOOR_SIZE

.process_item:
    lodsb                   ; Get next search item
    test al, al
    jz .finished

    xor edx, edx            ; Counter
    mov ebx, edi            ; Floor pointer
    mov ebp, ecx            ; Save floor size

.search_floor:
    cmp byte [ebx], 0       ; End of floor?
    je .store_result
    cmp al, [ebx]
    sete dl
    add edx, ebx            ; Conditional increment
    inc ebx
    jmp .search_floor

.store_result:
    mov [output], edx
    jmp .process_item

.finished:
    ret

; -------------------------------------------------------------------
; PART 3: SIMD-accelerated Counting
; -------------------------------------------------------------------
simd_inventory:
    mov esi, inbox
    mov edi, floor_data
    pxor xmm0, xmm0         ; Zero counter

.process_simd:
    lodsb                   ; Get search byte
    test al, al
    jz .simd_done

    ; Broadcast search byte to XMM1
    movd xmm1, eax
    pshufb xmm1, xmm0       ; Splat AL across XMM1

    ; Process 16 floor items at once
    movdqu xmm2, [edi]
    pcmpeqb xmm2, xmm1      ; Compare floor items
    pmovmskb edx, xmm2      ; Get bitmask of matches
    popcnt edx, edx         ; Count matches
    add edi, 16
    mov [output], edx
    jmp .process_simd

.simd_done:
    ret

; -------------------------------------------------------------------
; PART 4: Obfuscated Malware-style Version
; -------------------------------------------------------------------
obfuscated_inventory:
    mov esi, inbox
    mov edi, floor_data
    xor eax, eax

.obfs_loop:
    lodsb
    test al, al
    jz .obfs_done

    push eax
    call count_matches
    add esp, 4
    mov [output], eax
    jmp .obfs_loop

count_matches:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8]        ; Get search char
    xor ecx, ecx            ; Counter
    mov edx, edi            ; Floor ptr

    ; Obfuscated comparison loop
    xor ebx, ebx
.cmp_loop:
    mov bl, [edx]
    test bl, bl
    jz .loop_end
    cmp al, bl
    sete bl
    movzx ebx, bl
    add ecx, ebx
    inc edx
    jmp .cmp_loop

.loop_end:
    mov eax, ecx
    pop ebp
    ret

.obfs_done:
    ret

; -------------------------------------------------------------------
; MAIN PROGRAM
; -------------------------------------------------------------------
_start:
    call hrm_style_reverse  ; For comparison
    call optimized_reverse
    call simd_reverse
    call stealth_reverse

    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

section .data
    inbox db 3, 5, 7, 0     ; Sample items to count
    floor_data db 3,5,3,7,5,3,0 ; Floor items (terminated)
    output dd 0
