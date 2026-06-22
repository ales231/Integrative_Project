; src/boot/main.asm — Punto de entrada del kernel (Episode 1)
;
; Escribe "OK" en la memoria de video texto (0xB8000) y detiene la CPU.

section .text

global _start

_start:
    mov edi, 0xB8000                      ; base del buffer VGA modo texto

    mov word [edi], 0x074F                ; 'O' + atributo 0x07 (gris claro sobre negro)
    mov word [edi + 2], 0x074B            ; 'K' en la siguiente celda (2 bytes por carácter)

.hang:
    hlt                                   ; baja consumo hasta la siguiente interrupción
    jmp .hang                             ; bucle infinito: el kernel no retorna
