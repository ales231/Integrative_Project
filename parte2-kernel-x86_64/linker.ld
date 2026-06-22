/* linker.ld — Script de enlazado del kernel (Episode 1)
 *
 * Carga el kernel en 1 MiB (convención común para Multiboot2).
 * Orden: header Multiboot2 → código → datos → BSS.
 */

ENTRY(_start)

SECTIONS
{
    . = 1M;

    .multiboot_header : {
        *(.multiboot_header)
    }

    .text : {
        *(.text)
    }

    .rodata : {
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(COMMON)
        *(.bss)
    }
}
