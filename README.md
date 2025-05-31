# Assembly 101
### Core Registers
| Register | Primary Use                | Caller-Saved? |
|----------|----------------------------|---------------|
| EAX      | Return values, arithmetic  | Yes           |
| EBX      | Base pointer, syscall arg  | No            |
| ECX      | Loop counters, syscall arg | Yes           |
| EDX      | I/O ports, extended math   | Yes           |
| ESI      | Source Index               | No            |
| EDI      | Dest Index                 | No            |
| ESP      | Stack Pointer              | Special       |
| EBP      | Base Pointer               | Special       |
### Movement
```asm
mov eax, 0xDEADBEEF     ; Load immediate value into EAX register 
mov ebx, eax    ; Copy value from EAX to EBX register  
mov [mem], ecx  ; Store value from ECX into memory at 'mem' address
mov edx, [mem]  ; Load value from memory at 'mem' into EDX register
mov [temp], al
lea edi, [eax+ecx*4] ; Address calculation
; Size Overrides  
movzx eax, byte [mem] ; Zero-extend  
movsx edx, word [mem] ; Sign-extend 
```
### Arithmetic
```asm
add/sub eax, ebx  ; Add/subtract EBX from EAX, result in EAX
imul/idiv         ; */ (signed)
inc/dec ecx       ; Increment/decrement ECX by 1
imul eax, ebx        ; Signed ×  
div ebx              ; EAX÷EBX (EAX=quot, EDX=rem)
```
### Bitwise (Operations that work on individual bits)
```asm
and/or/xor edx, 0xFF ; Bit masking 
shl/shr eax, 2    ; Shift EAX left/right by 2 bits (multiply/divide by 4)
ror/rol eax, 8       ; Bit rotation
and eax, 0xFFFF0000   ; Mask upper 16 bits
xor eax, eax          ; Fast zero (ZF=1)
test al, 0x01         ; Check bit 0 (sets ZF)
bswap eax             ; Endian swap (32-bit)
```
- `AND`: Turns bits off (1 AND 0 = 0).
- `OR`: Turns bits on (1 OR 0 = 1).
- `XOR`: Toggles bits (1 XOR 1 = 0).
- `0xFF`: A hexadecimal value where all 8 bits are 1 (binary: 11111111). Used to mask/extract the lowest byte of a register.
### Labels
```asm
start:           ; Define label named 'start'  
```
### Flags:
```asm
cmp eax, ebx          ; ZF,SF,OF,CF
test eax, ebx         ; ZF,SF (AND without store)
; Flag Control  
stc/clc              ; Set/Clear CF  
cmc                  ; Complement CF  
```
- `ZF` (Zero Flag): Set to `1` if the result of an operation is zero (e.g., `cmp eax, 10` sets `ZF=1` if `eax == 10`).
- `SF` (Sign Flag): Set to `1` if the result is negative (`MSB = 1`).
- `CF` (Carry Flag): Set to `1` if an arithmetic operation overflows (e.g., adding two large numbers exceeds 32 bits).
### Unconditional Jump
```asm
jmp start    ; Unconditionally jump back to 'start' label
```
### Conditionals Jumps
```asm
; Equality Tests
je   ; Jump if equal (ZF=1) 
jne  ; Jump if not equal (ZF=0)
jz   ; Jump if zero (same as je)

; Signed Comparisons (for numbers)
jg   ; Jump if greater (SF=OF and ZF=0)
jge  ; Jump if greater/equal (SF=OF)
jl   ; Jump if less (SF≠OF)
jle  ; Jump if less/equal (SF≠OF or ZF=1)

; Unsigned Comparisons
ja   ; Jump if above (CF=0 and ZF=0)
jae  ; Jump if above/equal (CF=0)
jb   ; Jump if below (CF=1)
jbe  ; Jump if below/equal (CF=1 or ZF=1)

; Special Cases
js   ; Jump if negative (SF=1)
jns  ; Jump if not negative (SF=0)
jc   ; Jump if carry (CF=1)
jnc  ; Jump if no carry (CF=0)
jo       ; jump overflow (OF=1)
jno      ; jump no overflow (OF=0)
```
### Loops
```asm
loop label    ; ECX--, jump if ≠0  
loope/loopne  ; ECX-- + ZF check  
```
### Memory Access Modes
```asm
mov eax, [ebx]         ; Load value from memory address in EBX into EAX
mov eax, [ebx+8]     ; Displacement   
mov ecx, [array+esi*4] ; Load value from array at index ESI (scaled by 4)
; Segment Overrides  
mov eax, gs:[0x30]   ; GS segment  
```
### Stack Operations
```asm
push/pop eax         ; ESP ±4  
pusha/popa           ; All general regs  
pushfd/popfd         ; Flags register  

; Frame Management  
enter 16, 0          ; Allocate 16 bytes  
leave                ; Cleanup  

; LIFO Basics
push eax  ; Decrement ESP by 4, then store EAX at [ESP]  
pop ebx   ; Load value from [ESP] into EBX, then increment ESP by 4  
```
### Calling Convention (cdecl)
```asm
push arg2     ; Push second argument onto stack  
push arg1     ; Push first argument onto stack  
call my_func  ; Call function (pushes return address)  
add esp, 8    ; Clean stack by removing 8 bytes (2 args * 4 bytes each)
; Callee  
func:  
  push ebp  
  mov ebp, esp  
  sub esp, 16        ; Local vars  
  ...  
  leave  
  ret  
```
### Essential Directives
```asm
section .text        ; Code  
section .data        ; Initialized data  
  msg db "Hello",0xA ; String  
  len equ $-msg      ; Length  
section .bss         ; Uninitialized  
  buf resb 256       ; Reserve bytes  
```




