; src/boot/header.asm — Cabecera Multiboot2 para GRUB
;
; GRUB busca esta estructura en los primeros 32 KiB del kernel y valida
; magic, arquitectura, longitud y checksum antes de saltar a _start.

section .multiboot_header

align 8
header_start:
    dd 0xE85250D6                       ; magic Multiboot2
    dd 0                                  ; arquitectura: 0 = i386 (protected mode)
    dd header_end - header_start          ; longitud total del header (incluye tags)
    dd -(0xE85250D6 + 0 + (header_end - header_start)) ; checksum (suma de campos = 0 mod 2^32)

    ; Tag de fin (obligatorio). type=0, flags=0, size=8
    dw 0                                  ; type: end tag
    dw 0                                  ; flags
    dd 8                                  ; tamaño del tag (8 bytes)
header_end:
