#ifndef KERNEL_VGA_H
#define KERNEL_VGA_H

/* Consola VGA modo texto 80×25 @ 0xB8000 */

#define VGA_BUFFER  ((volatile unsigned short *)0xB8000)
#define VGA_WIDTH   80
#define VGA_HEIGHT  25
#define VGA_ATTR    0x07   /* gris claro sobre negro */

void clear_screen(void);
void print(const char *str);

#endif
