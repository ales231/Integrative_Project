; src/arch/gdt.asm — Global Descriptor Table de 64 bits (Episode 2)

section .rodata

global gdt64
global gdt64_code_selector
global gdt64_pointer

gdt64:
    dq 0
gdt64_code:
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)

gdt64_code_selector equ gdt64_code - gdt64

gdt64_pointer:
    dw gdt64_code_end - gdt64 - 1
    dd gdt64
gdt64_code_end:
