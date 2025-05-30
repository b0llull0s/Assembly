# Assembly
## Core Execution Model
### Registers & Data Movement
- Key Ops:
```asm
mov eax, 10     ; Load immediate value 10 into EAX register 
mov ebx, eax    ; Copy value from EAX to EBX register  
mov [mem], ecx  ; Store value from ECX into memory at 'mem' address
mov edx, [mem]  ; Load value from memory at 'mem' into EDX register  
```
- `EAX` (Accumulator Register): Primary register for arithmetic operations and function return values.
- `EBX` (Base Register): Often used as a pointer to data (e.g., memory addresses).
- `ECX` (Counter Register): Used for loops/string operations (e.g., rep prefixes).
- `EDX` (Data Register): Extends EAX for large operations (e.g., 64-bit math via EDX:EAX).
#### Key Difference:
EAX is optimized for arithmetic, ECX for counting, EBX/EDX for data/pointers. All are 32-bit (4 bytes) in x86.
#### Exercises: Swap two registers without a third.
### Basic Arithmetic/Logic
- Must-Know Instructions:
```asm
add/sub eax, ebx  ; Add/subtract EBX from EAX, result in EAX  
inc/dec ecx       ; Increment/decrement ECX by 1  
and/or/xor edx, 0xFF ; Bitwise AND/OR/XOR EDX with 0xFF 
shl/shr eax, 2    ; Shift EAX left/right by 2 bits (multiply/divide by 4)   
```
- `Bitwise`: Operations that work on individual bits (not decimal numbers).
  - `AND`: Turns bits off (1 AND 0 = 0).
  - `OR`: Turns bits on (1 OR 0 = 1).
  - `XOR`: Toggles bits (1 XOR 1 = 0).
- `0xFF`: A hexadecimal value where all 8 bits are 1 (binary: 11111111). Used to mask/extract the lowest byte of a register.
- `shl eax, 2`: Shift all bits in EAX left by 2 positions.
  - Equivalent to multiplying by `4` (since `2^2 = 4`).
- `shr eax, 2`: Shift all bits right by 2 positions.
  - Equivalent to dividing by `4` (truncates remainder).
#### Exercise: Calculate (eax * 5) + 3 using only add, shl.
## Control Flow
### Labels & Unconditional Jump
- Syntax:
```asm
start:           ; Define label named 'start'  
    jmp start    ; Unconditionally jump back to 'start' label  
```  
### Flags:
```asm
ZF (Zero), SF (Sign), CF (Carry).  ; Processor status flags
```
- `ZF` (Zero Flag): Set to `1` if the result of an operation is zero (e.g., `cmp eax, 10` sets `ZF=1` if `eax == 10`).
- `SF` (Sign Flag): Set to `1` if the result is negative (`MSB = 1`).
- `CF` (Carry Flag): Set to `1` if an arithmetic operation overflows (e.g., adding two large numbers exceeds 32 bits).
#### Conditionals Jumps
```asm
je   ; Jump if equal (ZF=1)
jne  ; Jump if not equal (ZF=0)
jz   ; Jump if zero (same as je)
```
- Pattern:
```asm
cmp eax, 10     ; Compare EAX with 10, sets flags  
jg greater_than ; Jump to 'greater_than' if EAX > 10
```
- Jumps if `eax > 10` (signed comparison).
- How? After `cmp eax, 10`:
  - `ZF=0` (result not zero) and `SF=OF` (sign flag equals overflow flag).
#### Exercise: Loop until eax is negative.
## Memory & Addressing
### Memory Access Modes
Examples:
```asm
mov eax, [ebx]         ; Load value from memory address in EBX into EAX  
mov ecx, [array+esi*4] ; Load value from array at index ESI (scaled by 4)   
```
- `array`: Base address of the array.
- `esi`: Index (e.g., 0 for first element).
- `*4`: Scale factor (each element is 4 bytes).
### Stack Operations
- LIFO Basics:
```asm
push eax  ; Decrement ESP by 4, then store EAX at [ESP]  
pop ebx   ; Load value from [ESP] into EBX, then increment ESP by 4  
```
- `ESP` (Stack Pointer): Points to the top of the stack (grows downward in memory).
- `push eax`:
  - Decrements `ESP` by 4 (32-bit systems use 4-byte stack slots).
  - Stores `eax` at [ESP].
- `add esp, 8`:
  - After pushing two 4-byte arguments, this "cleans" the stack by moving ESP back up 8 bytes.
#### Exercise: Reverse a string using the stack.
## System Calls & I/O
- Linux x86 Example:
```asm
mov eax, 1    ; Set syscall number (1 = sys_exit)  
mov ebx, 0    ; Set exit status code (0 = success)  
mov ecx, msg  ; Set pointer to message string  
mov edx, len  ; Set message length in bytes  
int 0x80      ; Trigger software interrupt to invoke kernel  

section .data  
    msg db "Hello", 0xA  ; Define string "Hello" with newline (0xA)  
    len equ $ - msg      ; Calculate string length (current pos - msg start)  
```
### Function Calls
- cdecl Convention:
```asm
push arg2     ; Push second argument onto stack  
push arg1     ; Push first argument onto stack  
call my_func  ; Call function (pushes return address)  
add esp, 8    ; Clean stack by removing 8 bytes (2 args * 4 bytes each)   
```





