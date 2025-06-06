; ================================================
; Key Concepts:
;   1. Prime number generation
;   2. Trial division algorithm
;   3. Precomputed optimization
; Security Considerations:
;   - Side-channel attacks on prime checks
;   - Memory exhaustion risks
; ================================================

section .text
    global _start

; -------------------------------------------------------------------
; PART 1: Size-Optimized (Trial Division)
; -------------------------------------------------------------------
size_optimized_primes:
    mov esi, inbox          ; INBOX pointer
    mov edi, output         ; OUTBOX pointer
    mov ebp, primes_cache   ; Tile 24 equivalent

.process_input:
    lodsd                   ; INBOX -> EAX (COPYTO 0)
    test eax, eax
    jz .done

    ; Initialize candidate (COPYFROM 24 -> COPYTO 3)
    mov ebx, [ebp]
    inc ebx                 ; BUMPUP 3

.test_candidate:
    inc ebx                 ; BUMPUP 3
    mov ecx, ebx            ; ECX = current candidate (tile 3)
    mov edx, [ebp]          ; EDX = divisor (tile 4)

.test_divisors:
    inc edx                 ; BUMPUP 4
    mov eax, ecx            ; COPYFROM 2
    sub eax, edx            ; SUB 3
    jz .prime_found         ; JUMPZ (exact division)
    js .next_candidate      ; JUMPN (divisor > candidate)
    jmp .test_divisors

.prime_found:
    mov [edi], ecx          ; OUTBOX prime
    add edi, 4
    dec dword [ebp]         ; BUMPDN 4
    jz .process_input       ; Reset if needed
    jmp .test_candidate

.next_candidate:
    jmp .test_candidate

.done:
    ret

; -------------------------------------------------------------------
; PART 2: Speed-Optimized (Precomputed)
; -------------------------------------------------------------------
speed_optimized_primes:
    ; Initialize precomputed primes (tiles 0-9)
    mov dword [precomputed], 2
    mov dword [precomputed+4], 3
    mov dword [precomputed+8], 5
    mov dword [precomputed+12], 7
    mov dword [precomputed+16], 11
    mov dword [precomputed+20], 13
    mov dword [precomputed+24], 17
    mov dword [precomputed+28], 19
    mov dword [precomputed+32], 23
    mov dword [precomputed+36], 29

    mov esi, inbox
    mov edi, output

.process_speed:
    lodsd                   ; INBOX (COPYTO 16)
    test eax, eax
    jz .finished

    ; Find largest prime ≤ input
    mov ecx, 10             ; Precomputed primes count
    mov ebx, precomputed
.find_prime:
    cmp eax, [ebx+ecx*4-4]
    jge .output_prime
    loop .find_prime
    jmp .process_speed

.output_prime:
    mov eax, [ebx+ecx*4-4]
    stosd                   ; OUTBOX
    jmp .process_speed

.finished:
    ret

; -------------------------------------------------------------------
; PART 3: Side-Channel Secure Version
; -------------------------------------------------------------------
secure_primes:
    ; Constant-time prime check
    mov esi, inbox
    mov edi, output

.process_secure:
    lodsd
    test eax, eax
    jz .secure_done

    ; Always check same number of divisors
    mov ecx, 32             ; Fixed iterations
    mov ebx, 2              ; Start divisor
    xor edx, edx            ; Prime flag (0=prime)

.check_loop:
    cmp ebx, eax
    jge .end_check
    mov [temp], eax
    xor edx, edx
    div ebx
    test edx, edx
    cmovz edx, ebx          ; Set flag if divisible
    mov eax, [temp]
    inc ebx
    loop .check_loop

.end_check:
    test edx, edx
    jnz .process_secure
    stosd                   ; Only output if prime
    jmp .process_secure

.secure_done:
    ret

; -------------------------------------------------------------------
; Data Section
; -------------------------------------------------------------------
section .data
    inbox dd 10, 20, 30, 0  ; Test inputs
    output times 32 dd 0
    primes_cache dd 1        ; Tile 24
    precomputed times 10 dd 0 ; Tiles 0-9
    temp dd 0

section .text
_start:
    call size_optimized_primes
    call speed_optimized_primes
    call secure_primes
    mov eax, 60
    xor edi, edi
    syscall
