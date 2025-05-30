# Assembly
## Basic Concepts
- `Labels` mark locations in the code you can `JUMP` to. They often define functions or loops.
- `Input/Output` uses system calls (`sys_read/sys_write` in Linux) or hardware-specific instructions.
- Jump Instructions (`jmp`) unconditional jumps loop infinitely. You also have conditional jumps (`je`, `jne`,`jz`, etc.) for branching logic.
- Registers (`eax`, `ebx`, etc.)
- Memory Use `mov` with memory addresses (e.g., `mov [buffer], al`).
- Math Operations `add eax, ebx` or `sub eax, 1`.
- Stack operations (push/pop).
- Interrupts/system calls (like int 0x80 in Linux).
