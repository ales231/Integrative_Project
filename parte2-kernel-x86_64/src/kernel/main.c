/* src/kernel/main.c — Punto de entrada del kernel en C (Episode 2) */

#include "vga.h"
#include "serial.h"

/* Mensaje personalizado del grupo — editar nombres antes de entregar */
#define GROUP_BANNER_LINE1 "========================================"
#define GROUP_BANNER_LINE2 "  Proyecto Integrador - Kernel x86_64"
#define GROUP_BANNER_LINE3 "  Equipo: Integrative Project"
#define GROUP_BANNER_LINE4 "  Long Mode + C activos (Episode 2)"
#define GROUP_BANNER_LINE5 "========================================"

__attribute__((noreturn))
void kernel_main(void)
{
    serial_init();
    clear_screen();
    print(GROUP_BANNER_LINE1);
    print("\n");
    print(GROUP_BANNER_LINE2);
    print("\n");
    print(GROUP_BANNER_LINE3);
    print("\n");
    print(GROUP_BANNER_LINE4);
    print("\n");
    print(GROUP_BANNER_LINE5);
    print("\n");

    for (;;) {
        __asm__ volatile ("hlt");
    }
}
