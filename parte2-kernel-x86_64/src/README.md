# Código fuente — Parte 2 Kernel x86_64

Organización por episodios del tutorial *Write Your Own 64-bit Operating System*.

## Episode 1

| Archivo | Rol |
|---------|-----|
| `boot/header.asm` | Cabecera Multiboot2 |
| `boot/main_ep1.asm` | `_start`: escribir `OK` en `0xB8000` |

```bash
make episode1 && make run
```

## Episode 2

| Archivo | Rol |
|---------|-----|
| `boot/header.asm` | Cabecera Multiboot2 (compartida) |
| `boot/main.asm` | Verificaciones + paging + GDT + far jump |
| `arch/gdt.asm` | GDT de 64 bits |
| `arch/paging.asm` | Paginación identidad 1 GiB (huge pages) |
| `arch/long_mode.asm` | Entrada 64-bit, llama `kernel_main` |
| `kernel/main.c` | Mensaje personalizado del grupo |
| `kernel/vga.c` | Función `print()` |

```bash
make episode2 && make run
```

Guía completa: [../EPISODE2.md](../EPISODE2.md).

## Convenciones de build

| Episodio | NASM | Enlazado | C |
|----------|------|----------|---|
| 1 | `-f elf32` | `ld -m elf_i386` | — |
| 2 | `-f elf64` | `ld -T linker.ld` | `gcc -m64 -ffreestanding` |

Los artefactos van a `build/`, `iso/` y `output/` (no versionados).
