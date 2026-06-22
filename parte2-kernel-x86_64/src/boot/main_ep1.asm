; src/boot/main_ep1.asm — Punto de entrada Episode 1 (solo VGA "OK")

section .text

global _start

_start:
    mov edi, 0xB8000
    mov word [edi], 0x074F
    mov word [edi + 2], 0x074B

.hang:
    hlt
    jmp .hang
