; ================================================
; Key Concepts:
;   1. Pointer chasing algorithms
;   2. Linked list traversal
;   3. Memory corruption vulnerabilities
; ================================================

section .text
    global _start

; -------------------------------------------------------------------
; PART 1: HRM Literal Translation
; -------------------------------------------------------------------
hrm_chain_traversal:
    mov esi, inbox          ; INBOX pointer
    mov edi, output         ; OUTBOX pointer

.process_chain:
    lodsd                   ; Get address (COPYTO 7)
    test eax, eax
    jz .done

    mov ebx, eax            ; ebx = current node

.traverse_loop:
    ; Security Note: No memory validation - attacker controls all pointers
    mov eax, [ebx]          ; COPYFROM [7] (get data)
    stosd                   ; OUTBOX

    ; Get next pointer (at ebx+4)
    mov ebx, [ebx+4]        ; BUMPUP 7 + COPYFROM [7]
    test ebx, ebx
    js .process_chain       ; JUMPN if negative

    jmp .traverse_loop

.done:
    ret

; -------------------------------------------------------------------
; PART 2: Weaponized Analysis
; -------------------------------------------------------------------
exploit_chain:
    ; Attack scenario: Malicious chain structure
    ; 1. Create circular reference to exhaust CPU
    ; 2. Pointer to kernel memory for LPE
    mov eax, [inbox]        ; Attacker-controlled start
    mov ebx, 0xDEADBEEF     ; Kernel pointer
    mov [eax+4], ebx        ; Poison pointer

    ; Infinite loop primitive
    mov ecx, loop_memory
    mov [ecx], ecx          ; node->next = node
    jmp hrm_chain_traversal

; -------------------------------------------------------------------
; PART 3: Secure Implementation
; -------------------------------------------------------------------
secure_traversal:
    mov esi, inbox
    mov edi, output
    mov ecx, MAX_DEPTH      ; Loop counter

.process_secure:
    lodsd
    test eax, eax
    jz .safe_exit

    ; Validate address range
    cmp eax, MEMORY_MIN
    jb .invalid_addr
    cmp eax, MEMORY_MAX
    ja .invalid_addr

    mov ebx, eax
    mov edx, ecx            ; Save counter

.traverse_safe:
    ; Check depth limit
    dec edx
    jz .invalid_chain

    ; Validate node contents
    mov eax, [ebx]
    stosd

    mov ebx, [ebx+4]
    test ebx, ebx
    js .process_secure

    ; Validate next pointer
    cmp ebx, MEMORY_MIN
    jb .invalid_addr
    cmp ebx, MEMORY_MAX
    ja .invalid_addr
    jmp .traverse_safe

.invalid_addr:
    mov eax, 0xBADADD12
    stosd
    jmp .process_secure

.invalid_chain:
    mov eax, 0xDEADCHAIN
    stosd

.safe_exit:
    ret

; -------------------------------------------------------------------
; Data Section
; -------------------------------------------------------------------
section .data
    inbox dd 0x1000, 0       ; Input addresses
    output times 256 dd 0
    loop_memory dd 0, 0      ; Attack memory
    MEMORY_MIN equ 0x1000
    MEMORY_MAX equ 0x1FFF
    MAX_DEPTH equ 20

; Real chain example
    chain_node1 dd 42, chain_node2
    chain_node2 dd 17, chain_node3
    chain_node3 dd 99, -1

section .text
_start:
    call hrm_chain_traversal
    ; call exploit_chain      ; (Disabled)
    call secure_traversal
    mov eax, 60
    xor edi, edi
    syscall
