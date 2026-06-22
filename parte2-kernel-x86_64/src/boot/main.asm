; src/boot/main.asm — Arranque en 32 bits: verificaciones y transición a long mode (Episode 2)
;
; Flujo: stack → Multiboot → CPUID → long mode → paging → GDT64 → far jump.

extern set_up_page_tables
extern enable_paging
extern long_mode_start
extern gdt64_pointer
extern gdt64_code_selector

section .text
bits 32

global _start

_start:
    mov esp, stack_top

    call check_multiboot
    call check_cpuid
    call check_long_mode

    call set_up_page_tables
    call enable_paging

    lgdt [gdt64_pointer]

    jmp gdt64_code_selector:long_mode_start

; Imprime "ERR: X" en VGA (fondo rojo) y detiene la CPU.
; Parámetro: código ASCII en AL.
error:
    mov dword [0xB8000], 0x4F524F45       ; 'ERR '
    mov dword [0xB8004], 0x4F3A4F52       ; 'R:  '
    mov dword [0xB8008], 0x4F204F20       ; '   '
    mov byte  [0xB800A], al
.hang_error:
    hlt
    jmp .hang_error

check_multiboot:
    cmp eax, 0x36D76289                   ; magic Multiboot2 en EAX
    jne .fail
    ret
.fail:
    mov al, '0'
    jmp error

check_cpuid:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    cmp eax, ecx
    je .fail
    ret
.fail:
    mov al, '1'
    jmp error

check_long_mode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb  .fail
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29                   ; LM bit
    jz  .fail
    ret
.fail:
    mov al, '2'
    jmp error

section .bss
align 16
stack_bottom:
    resb 16384                            ; 16 KiB de stack
stack_top:
