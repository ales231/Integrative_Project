# Episode 2 — Long mode y kernel en C

| Archivo | Descripción |
|---------|-------------|
| `gdt.asm` | Descriptor nulo + segmento de código 64-bit; puntero para `lgdt` |
| `paging.asm` | PML4/PDPT/PD, mapa identidad 1 GiB con páginas de 2 MiB |
| `long_mode.asm` | `long_mode_start`: limpia segmentos y llama `kernel_main` |

Flujo desde `boot/main.asm`:

1. `call set_up_page_tables`
2. `call enable_paging`
3. `lgdt [gdt64.pointer]`
4. `jmp gdt64.code:long_mode_start`

Ver [../../EPISODE2.md](../../EPISODE2.md).
