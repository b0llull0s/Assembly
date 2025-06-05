; ==============================================================
; Techniques:
;   1. Zero-width spaces (invisible chars)
;   2. Homoglyphs (lookalike chars)
;   3. Overlong UTF-8 encoding (bypass string checks)
;   4. Right-to-Left (RTL) override (reversing text)
; ==============================================================

section .text
    global _start

_start:
    ; --- Technique 1: Zero-width spaces in filenames ---
    ; "cmd.exe" -> "c<ZWS>m<ZWS>d.exe" (invisible to humans)
    mov     esi, filename_zws
    call    print_string

    ; --- Technique 2: Homoglyph substitution ---
    ; "powershell" -> "рօwеrѕһеll" (Cyrillic/Greek letters)
    mov     esi, filename_homoglyph
    call    print_string

    ; --- Technique 3: Overlong UTF-8 encoding ---
    ; "/bin/sh" -> "/b\xC0\xAFin/sh" (non-canonical path)
    mov     esi, path_overlong
    call    print_string

    ; --- Technique 4: RTL override ---
    ; "evil.dll" -> "evil<RTLO>lld." (displays as "evil.dll" but reverses)
    mov     esi, filename_rtlo
    call    print_string

    ; --- Exit ---
    mov     eax, 60
    xor     edi, edi
    syscall

print_string:
    ; Syscall to write string (simplified)
    mov     eax, 1          ; sys_write
    mov     edi, 1          ; stdout
    mov     rdx, rsi        ; length (placeholder)
    syscall
    ret

section .data
    ; --- Obfuscated Strings ---
    filename_zws       db 'c', 0xE2, 0x80, 0x8B, 'm', 0xE2, 0x80, 0x8B, 'd.exe', 0
    filename_homoglyph db 0xD1, 0x80, 0xD6, 0x85, 0x77, 0xD0, 0xB5, 0xD1, 0x80, 0xD1, 0x95, 0xD1, 0x88, 0xD0, 0xB5, 0x6C, 0x6C, 0  ; "рօwеrѕһеll"
    path_overlong      db '/', 'b', 0xC0, 0xAF, 'i', 'n', '/', 's', 'h', 0  ; "/b\xC0\xAFin/sh"
    filename_rtlo      db 'e', 'v', 'i', 'l', 0xE2, 0x80, 0xAE, 'l', 'l', 'd', '.', 0  ; "evil<RTLO>lld."
