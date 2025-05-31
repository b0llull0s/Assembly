# x86 Assembly Cheat Sheet

## Core Registers (32-bit)
| Register | Primary Use                     | Preserved by Callee? |
|----------|--------------------------------|---------------------|
| EAX      | Return values, arithmetic      | No (caller-saved)   |
| EBX      | General purpose, base pointer  | Yes (callee-saved)  |
| ECX      | Loop counters, function args   | No (caller-saved)   |
| EDX      | I/O operations, extended math  | No (caller-saved)   |
| ESI      | Source index for string ops    | Yes (callee-saved)  |
| EDI      | Destination index for strings  | Yes (callee-saved)  |
| ESP      | Stack pointer (top of stack)   | Special (managed)   |
| EBP      | Base/frame pointer             | Yes (callee-saved)  |

**Note**: Each register has smaller variants (e.g., AX=lower 16 bits of EAX, AL=lower 8 bits)

## Data Movement
```asm
; Basic moves
mov eax, 42           ; Load immediate value 42 into EAX
mov ebx, eax          ; Copy EAX value to EBX
mov eax, [ebx]        ; Load value from memory address in EBX
mov [address], ecx    ; Store ECX value at memory address

; Size-specific moves
mov al, 0xFF          ; Move byte (8-bit) to AL
mov ax, 0x1234        ; Move word (16-bit) to AX
mov eax, 0x12345678   ; Move dword (32-bit) to EAX

; Zero/sign extension
movzx eax, byte [mem] ; Zero-extend byte to 32-bit
movsx eax, word [mem] ; Sign-extend word to 32-bit

; Address calculation
lea edi, [eax+ecx*4]  ; Load effective address (eax + ecx*4)
```

## Arithmetic Operations
```asm
; Basic arithmetic
add eax, ebx          ; EAX = EAX + EBX
sub eax, ebx          ; EAX = EAX - EBX
inc eax               ; EAX = EAX + 1 (faster than add eax, 1)
dec eax               ; EAX = EAX - 1

; Multiplication
imul eax, ebx         ; EAX = EAX * EBX (signed)
imul eax, ebx, 10     ; EAX = EBX * 10 (signed)
mul ebx               ; EDX:EAX = EAX * EBX (unsigned, 64-bit result)

; Division
idiv ebx              ; EAX = EDX:EAX / EBX, EDX = remainder (signed)
div ebx               ; EAX = EDX:EAX / EBX, EDX = remainder (unsigned)
; Note: Clear EDX before division: xor edx, edx (for positive numbers)

; Negate
neg eax               ; EAX = -EAX (two's complement)
```

## Bitwise Operations
```asm
; Logical operations
and eax, 0xFF         ; Keep only lowest 8 bits (mask)
or eax, 0x80000000    ; Set highest bit
xor eax, ebx          ; Bitwise XOR
not eax               ; Bitwise NOT (flip all bits)
xor eax, eax          ; Fast way to zero EAX

; Bit shifts
shl eax, 2            ; Shift left 2 bits (multiply by 4)
shr eax, 2            ; Shift right 2 bits (unsigned divide by 4)
sar eax, 2            ; Arithmetic shift right (signed divide by 4)

; Bit rotation
rol eax, 8            ; Rotate left 8 bits
ror eax, 8            ; Rotate right 8 bits

; Bit testing
test eax, 0x01        ; Test if bit 0 is set (sets ZF)
bt eax, 5             ; Test bit 5 (sets CF)
bswap eax             ; Reverse byte order (endian swap)
```

## Flags Register
Common flags affected by operations:
- **ZF (Zero Flag)**: Set if result is zero
- **SF (Sign Flag)**: Set if result is negative (MSB = 1)
- **CF (Carry Flag)**: Set if arithmetic overflow/underflow occurs
- **OF (Overflow Flag)**: Set if signed overflow occurs
- **PF (Parity Flag)**: Set if result has even number of 1 bits

```asm
; Comparison (sets flags without storing result)
cmp eax, ebx          ; Compare EAX with EBX (sets ZF, SF, CF, OF)
test eax, eax         ; Test if EAX is zero (sets ZF, SF)

; Flag manipulation
stc                   ; Set carry flag (CF = 1)
clc                   ; Clear carry flag (CF = 0)
cmc                   ; Complement carry flag
```

## Control Flow

### Unconditional Jumps
```asm
jmp label             ; Jump to label
jmp eax               ; Jump to address in EAX
```

### Conditional Jumps (use after cmp or test)
```asm
; Equality
je/jz  label          ; Jump if equal/zero (ZF = 1)
jne/jnz label         ; Jump if not equal/not zero (ZF = 0)

; Signed comparisons
jg/jnle label         ; Jump if greater (signed)
jge/jnl label         ; Jump if greater or equal (signed)
jl/jnge label         ; Jump if less (signed)
jle/jng label         ; Jump if less or equal (signed)

; Unsigned comparisons
ja/jnbe label         ; Jump if above (unsigned)
jae/jnb label         ; Jump if above or equal (unsigned)
jb/jnae label         ; Jump if below (unsigned)
jbe/jna label         ; Jump if below or equal (unsigned)

; Flag-based jumps
js label              ; Jump if negative (SF = 1)
jns label             ; Jump if not negative (SF = 0)
jc label              ; Jump if carry (CF = 1)
jnc label             ; Jump if no carry (CF = 0)
jo label              ; Jump if overflow (OF = 1)
jno label             ; Jump if no overflow (OF = 0)
```

### Loops
```asm
loop label            ; Decrement ECX, jump if ECX ≠ 0
loope label           ; Decrement ECX, jump if ECX ≠ 0 AND ZF = 1
loopne label          ; Decrement ECX, jump if ECX ≠ 0 AND ZF = 0

; Example loop
mov ecx, 10           ; Set loop counter
my_loop:
    ; ... loop body ...
    loop my_loop      ; Repeat 10 times
```

## Memory Addressing Modes
```asm
; Direct addressing
mov eax, [0x401000]   ; Load from absolute address

; Register indirect
mov eax, [ebx]        ; Load from address in EBX

; Register + displacement
mov eax, [ebx+8]      ; Load from EBX + 8 bytes

; Scaled indexing
mov eax, [ebx+ecx*4]  ; Load from EBX + (ECX * 4)
mov eax, [ebx+ecx*4+8]; Load from EBX + (ECX * 4) + 8

; Array access example
mov esi, 0            ; Index = 0
mov eax, [array+esi*4]; Load array[index] (4 bytes per element)
```

## Stack Operations
The stack grows downward (toward lower addresses).

```asm
; Basic operations
push eax              ; ESP -= 4, then [ESP] = EAX
pop ebx               ; EBX = [ESP], then ESP += 4

; Multiple registers
pusha/pushad          ; Push all general-purpose registers
popa/popad            ; Pop all general-purpose registers
pushf/pushfd          ; Push flags register
popf/popfd            ; Pop flags register

; Stack frame management
push ebp              ; Save old base pointer
mov ebp, esp          ; Set new base pointer
sub esp, 16           ; Allocate 16 bytes for local variables
; ... function body ...
mov esp, ebp          ; Restore stack pointer
pop ebp               ; Restore old base pointer
; Or use: leave        ; Equivalent to above two instructions
```

## Function Calls (cdecl convention)
```asm
; Calling a function
push 20               ; Push second argument
push 10               ; Push first argument
call my_function      ; Call function (pushes return address)
add esp, 8            ; Clean up stack (2 args × 4 bytes)
; Return value is in EAX

; Function definition
my_function:
    push ebp          ; Save caller's base pointer
    mov ebp, esp      ; Set up new base pointer
    sub esp, 8        ; Allocate local variables
    
    ; Access arguments
    mov eax, [ebp+8]  ; First argument
    mov ebx, [ebp+12] ; Second argument
    
    ; Function body here
    ; Return value goes in EAX
    
    mov esp, ebp      ; Clean up local variables
    pop ebp           ; Restore caller's base pointer
    ret               ; Return to caller
```

## Assembly Structure & Directives
```asm
section .data         ; Initialized data segment
    msg db "Hello, World!", 0x0A, 0  ; String with newline and null terminator
    number dd 42      ; 32-bit integer
    array dd 1, 2, 3, 4, 5  ; Array of integers
    
section .bss          ; Uninitialized data segment
    buffer resb 256   ; Reserve 256 bytes
    counter resd 1    ; Reserve 1 dword (4 bytes)
    
section .text         ; Code segment
    global _start     ; Entry point for linker
    
_start:
    ; Your code here
    ; Exit program (Linux)
    mov eax, 1        ; sys_exit
    mov ebx, 0        ; exit status
    int 0x80          ; system call
```

## Data Types & Sizes
```asm
; Data declarations
db 0x42               ; Define byte (8-bit)
dw 0x1234             ; Define word (16-bit)
dd 0x12345678         ; Define dword (32-bit)
dq 0x123456789ABCDEF0 ; Define qword (64-bit)

; String data
msg db "Hello", 0     ; Null-terminated string
len equ $ - msg       ; Calculate string length

; Arrays
numbers dd 10, 20, 30, 40  ; Array of 32-bit integers
```

## Common Patterns & Tips

### Clearing a register (fastest methods)
```asm
xor eax, eax          ; Fastest way to zero EAX
mov eax, 0            ; Also works but slightly slower
```

### Comparing with zero
```asm
test eax, eax         ; Faster than cmp eax, 0
```

### Multiplying/dividing by powers of 2
```asm
shl eax, 3            ; Multiply by 8 (2^3)
shr eax, 2            ; Divide by 4 (2^2)
```

### Setting/clearing specific bits
```asm
or eax, 0x80          ; Set bit 7
and eax, 0x7F         ; Clear bit 7 (0x7F = ~0x80)
xor eax, 0x80         ; Toggle bit 7
```
