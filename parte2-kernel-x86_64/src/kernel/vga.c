/* src/kernel/vga.c — Consola VGA modo texto (Episode 2) */

#include "vga.h"
#include "serial.h"

static unsigned int row;
static unsigned int col;

static unsigned short vga_entry(char c)
{
    return (unsigned short)c | ((unsigned short)VGA_ATTR << 8);
}

void clear_screen(void)
{
    for (unsigned int y = 0; y < VGA_HEIGHT; y++) {
        for (unsigned int x = 0; x < VGA_WIDTH; x++) {
            VGA_BUFFER[y * VGA_WIDTH + x] = vga_entry(' ');
        }
    }
    row = 0;
    col = 0;
}

static void newline(void)
{
    col = 0;
    if (++row >= VGA_HEIGHT) {
        row = VGA_HEIGHT - 1;
        for (unsigned int y = 0; y < VGA_HEIGHT - 1; y++) {
            for (unsigned int x = 0; x < VGA_WIDTH; x++) {
                VGA_BUFFER[y * VGA_WIDTH + x] =
                    VGA_BUFFER[(y + 1) * VGA_WIDTH + x];
            }
        }
        for (unsigned int x = 0; x < VGA_WIDTH; x++) {
            VGA_BUFFER[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = vga_entry(' ');
        }
    }
}

void print(const char *str)
{
    for (; *str; str++) {
        serial_putchar(*str);
        if (*str == '\n') {
            newline();
            continue;
        }
        VGA_BUFFER[row * VGA_WIDTH + col] = vga_entry(*str);
        if (++col >= VGA_WIDTH) {
            newline();
        }
    }
}
