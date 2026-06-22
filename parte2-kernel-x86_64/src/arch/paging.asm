; src/arch/paging.asm — Paginación identidad del primer GiB con huge pages (Episode 2)
;
; Mapa identidad: VA == PA para 0x00000000 .. 0x3FFFFFFF (512 × 2 MiB).
; Jerarquía: PML4 → PDPT → PD (entradas de 2 MiB, bit PS/huge activo).

section .bss
align 4096
global p4_table
global p3_table
global p2_table

p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096

section .text
bits 32

global set_up_page_tables
global enable_paging

; Enlaza PML4[0] → PDPT, PDPT[0] → PD y rellena 512 entradas de 2 MiB.
set_up_page_tables:
    mov eax, p3_table
    or  eax, 0b11                   ; present + writable
    mov [p4_table], eax

    mov eax, p2_table
    or  eax, 0b11
    mov [p3_table], eax

    xor ecx, ecx
.map_p2_loop:
    mov eax, 0x200000               ; tamaño de cada huge page (2 MiB)
    mul ecx                         ; eax = ecx * 2 MiB
    or  eax, 0b10000011             ; present + writable + huge (PS)
    mov [p2_table + ecx * 8], eax
    inc ecx
    cmp ecx, 512                    ; 512 × 2 MiB = 1 GiB
    jne .map_p2_loop
    ret

; Activa PAE, carga CR3, habilita LME en EFER y enciende paginación (CR0.PG).
enable_paging:
    mov eax, p4_table
    mov cr3, eax

    mov eax, cr4
    or  eax, 1 << 5                 ; CR4.PAE
    mov cr4, eax

    mov ecx, 0xC0000080             ; MSR EFER
    rdmsr
    or  eax, 1 << 8                 ; EFER.LME
    wrmsr

    mov eax, cr0
    or  eax, 1 << 31                ; CR0.PG
    mov cr0, eax
    ret
