# Kernel en C — Episode 2

| Archivo | Descripción |
|---------|-------------|
| `main.c` | `kernel_main()` — banner del grupo y bucle `hlt` |
| `vga.h` | Declaraciones de consola VGA |
| `vga.c` | `print()` y `clear_screen()` sobre `0xB8000` |

Personaliza el mensaje editando las macros `GROUP_BANNER_LINE*` en `main.c`.

Compilación: `gcc -m64 -ffreestanding -fno-pic -mno-red-zone -nostdlib`.
