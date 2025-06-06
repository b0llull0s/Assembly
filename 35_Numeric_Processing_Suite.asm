; ================================================
;   1. Digit decomposition (with negative handling)
;   2. BCD conversion
;   3. Fault injection analysis
;   4. Security applications
; ================================================

section .text
    global _start

; -------------------------------------------------------------------
; PART 1: Enhanced Digit Exploder with Negative Support
; -------------------------------------------------------------------
digit_exploder:
    mov esi, inbox
    mov edi, output
    mov ebp, 10             ; Base 10

.process_number:
    lodsd                   ; Load number
    test eax, eax
    jz .done

    ; Handle negative numbers
    mov ebx, eax
    and ebx, 0x80000000
    jz .positive
    neg eax                 ; Convert to positive
    mov byte [sign_flag], 1

.positive:
    ; Extract digits (optimized division)
    mov ecx, 1000          ; Support 4-digit numbers
    call .extract_digit
    mov ecx, 100
    call .extract_digit
    mov ecx, 10
    call .extract_digit
    
    ; Output units and sign if needed
    cmp byte [sign_flag], 0
    je .output_units
    mov byte [edi], '-'
    add edi, 1

.output_units:
    mov [edi], al
    add edi, 4
    jmp .process_number

.extract_digit:
    xor edx, edx
    div ecx                 ; eax = quotient, edx = remainder
    test eax, eax
    jz .skip_digit
    add al, '0'             ; ASCII conversion
    mov [edi], al
    add edi, 1
.skip_digit:
    mov eax, edx
    ret

.done:
    ret

; -------------------------------------------------------------------
; PART 2: BCD Conversion Utilities
; -------------------------------------------------------------------
to_bcd:
    ; Input: EAX = binary number
    ; Output: EAX = packed BCD
    xor edx, edx
    mov ecx, 10
    div ecx                 ; units in DL, rest in EAX
    shl eax, 4
    or eax, edx
    ret

from_bcd:
    ; Input: AL = packed BCD
    ; Output: AL = binary
    mov ah, al
    and al, 0x0F            ; units
    shr ah, 4               ; tens
    mov cl, 10
    mul cl
    add al, ah
    ret

; -------------------------------------------------------------------
; PART 3: Fault Injection Analysis
; -------------------------------------------------------------------
fault_injection_target:
    ; Simulate cryptographic operation
    mov eax, [crypto_buffer]
    call to_bcd
    ; Vulnerable point - can skip instructions via fault
    mov [result], eax
    ret

detect_faults:
    ; Checksum verification
    mov esi, crypto_buffer
    mov ecx, 4
    xor eax, eax
.checksum_loop:
    lodsb
    add ah, al
    loop .checksum_loop
    cmp ah, [expected_checksum]
    jne .fault_detected
    ret

.fault_detected:
    ; Critical error handling
    mov byte [fault_flag], 1
    ret

; -------------------------------------------------------------------
; PART 4: Security Applications
; -------------------------------------------------------------------

; A. Password PIN Decomposition
process_pin:
    mov eax, [pin_code]
    call digit_exploder     ; Get individual digits
    ; Additional PIN processing...
    ret

; B. Luhn Checksum Calculation
luhn_checksum:
    mov esi, card_number
    mov ecx, 16
    xor ebx, ebx
.luhn_loop:
    lodsb
    call from_bcd
    ; Double every second digit
    test cl, 1
    jnz .no_double
    add al, al
    cmp al, 10
    jb .no_double
    sub al, 9
.no_double:
    add bl, al
    loop .luhn_loop
    mov [checksum], bl
    ret

; C. Financial Data Processing
format_currency:
    mov eax, [amount]
    call digit_exploder
    ; Insert decimal point...
    ret

; D. Cryptography (Digit Manipulation)
digit_permutation:
    mov eax, [crypto_key]
    call digit_exploder
    ; Apply cryptographic permutation...
    ret

; -------------------------------------------------------------------
; Data Section
; -------------------------------------------------------------------
section .data
    inbox dd 1234, -567, 0
    output times 32 db 0
    sign_flag db 0

    ; BCD Data
    bcd_number dd 0x1234

    ; Fault Injection
    crypto_buffer db 0x12, 0x34, 0x56, 0x78
    expected_checksum db 0x54
    fault_flag db 0
    result dd 0

    ; Security Apps
    pin_code dd 1234
    card_number times 8 db 0x34, 0x12  ; Fake card data
    checksum db 0
    amount dd 9999
    crypto_key dd 13579

section .text
_start:
    call digit_exploder
    call fault_injection_target
    call detect_faults
    call process_pin
    call luhn_checksum
    mov eax, 60
    xor edi, edi
    syscall
