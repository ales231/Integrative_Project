; src/arch/long_mode.asm — Punto de entrada en modo 64-bit (Episode 2)
;
; Tras el far jump desde el stub de 32 bits, limpiamos selectores de datos
; y llamamos a kernel_main() escrito en C.

extern kernel_main

global long_mode_start

section .text
bits 64

long_mode_start:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call kernel_main

.hang:
    hlt
    jmp .hang
