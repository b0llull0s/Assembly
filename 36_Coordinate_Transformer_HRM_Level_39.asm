; ================================================
; Key Concepts:
;   1. Linear coordinate transformation
;   2. Memory-address manipulation
;   3. Arithmetic overflow risks
; Security Applications:
;   - Pointer arithmetic exploits
;   - Memory layout probing
; ================================================

section .text
    global _start

; -------------------------------------------------------------------
; PART 1: HRM Literal Translation
; -------------------------------------------------------------------
hrm_recoordinator:
    mov esi, inbox          ; INBOX pointer
    mov edi, output         ; OUTBOX pointer
    mov ebp, coord_buffer   ; Tile 10/14 equivalent

.process_pair:
    ; Initialize base (COPYFROM 14 -> COPYTO 10)
    mov eax, [base_value]
    mov [ebp], eax

    ; Get input value (INBOX)
    lodsd
    test eax, eax
    jz .done

.transform_loop:
    ; Subtract offset (SUB 15)
    sub eax, [offset_value]
    js .output_transformed  ; JUMPN (negative result)

    ; Store remainder and increment base (BUMPUP 10)
    mov [ebp+4], eax        ; Tile 11
    add dword [ebp], 1      ; BUMPUP 10

    ; Continue with remainder
    mov eax, [ebp+4]
    jmp .transform_loop

.output_transformed:
    ; Output transformed values (ADD 15 + OUTBOX)
    add eax, [offset_value]
    stosd                   ; OUTBOX transformed
    mov eax, [ebp]          ; COPYFROM 10
    stosd                   ; OUTBOX base
    jmp .process_pair

.done:
    ret

; -------------------------------------------------------------------
; PART 2: Weaponized Coordinate Transformation
; -------------------------------------------------------------------
weaponized_transform:
    ; Attack vector: Arithmetic overflow
    mov eax, [esi]          ; Attacker-controlled input
    sub eax, [offset_value] ; Potential underflow
    jc .overflow_exploit

    ; Normal operation
    call hrm_recoordinator
    ret

.overflow_exploit:
    ; Example: Use underflow to access forbidden memory
    mov eax, 0xFFFFFFFF
    sub eax, [offset_value] ; Wraps around
    mov [ebp], eax          ; Corrupt base pointer
    ret

; -------------------------------------------------------------------
; PART 3: Secure Implementation
; -------------------------------------------------------------------
secure_transform:
    ; Bounds checking
    mov eax, [esi]
    cmp eax, SAFE_MIN
    jl .invalid_input
    cmp eax, SAFE_MAX
    jg .invalid_input

    ; Overflow-protected subtraction
    mov edx, [offset_value]
    cmp eax, edx
    jl .underflow_protected
    sub eax, edx
    jmp secure_transform_continue

.underflow_protected:
    mov eax, 0              ; Clamp to zero

.secure_transform_continue:
    ; ... (rest of transformation)
    ret

.invalid_input:
    mov eax, 0xDEADBEEF     ; Error code
    ret

; -------------------------------------------------------------------
; Data Section
; -------------------------------------------------------------------
section .data
    inbox dd 30, 45, 60, 0  ; Test inputs
    output times 16 dd 0
    base_value dd 100       ; Tile 14 value
    offset_value dd 15      ; Tile 15 value
    coord_buffer times 8 dd 0 ; Tiles 10-11
    SAFE_MIN equ 0
    SAFE_MAX equ 0x7FFFFFFF

section .text
_start:
    call hrm_recoordinator
    ; call weaponized_transform ; (Disabled for safety)
    call secure_transform
    mov eax, 60
    xor edi, edi
    syscall
