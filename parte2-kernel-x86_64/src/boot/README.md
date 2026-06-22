# Episode 1 — Arranque Multiboot2

Archivos del Episode 1:

1. **`header.asm`** — Header Multiboot2 alineado (8 bytes), con tag de fin.
2. **`main_ep1.asm`** — Etiqueta global `_start` que escribe `OK` en la memoria de video texto.

> **Episode 2** usa `main.asm` (ver [../../EPISODE2.md](../../EPISODE2.md)).

## Memoria VGA texto

- Dirección base: **`0xB8000`**
- Cada celda: carácter ASCII + atributo de color (1 byte cada uno).
- Ejemplo: `'O'` en `0xB8000`, `'K'` en `0xB8002`.

## Flujo de build

```
header.asm + main_ep1.asm  →  nasm -f elf32  →  build/*.o
build/*.o + linker.ld      →  ld -m elf_i386 →  build/kernel-ep1.elf
kernel-ep1.elf             →  objcopy        →  output/kernel.bin
kernel.bin + grub.cfg      →  grub-mkrescue  →  output/kernel.iso
```

GRUB arranca con `multiboot2 /boot/kernel.bin` (ver `grub.cfg` en la raíz).
