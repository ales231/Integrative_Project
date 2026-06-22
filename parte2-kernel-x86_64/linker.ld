/* linker.ld — Script de enlazado del kernel (Episodes 1 y 2)
 *
 * Carga el kernel en 1 MiB (convención Multiboot2).
 * Orden: header Multiboot2 → código → datos → BSS (stack y tablas de página).
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
