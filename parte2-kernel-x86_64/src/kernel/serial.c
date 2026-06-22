/* src/kernel/serial.c — Salida COM1 (0x3F8) para QEMU -serial stdio */

#include "serial.h"

#define COM1 0x3F8

static inline void outb(unsigned short port, unsigned char value)
{
    __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

static inline unsigned char inb(unsigned short port)
{
    unsigned char value;
    __asm__ volatile ("inb %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}

void serial_init(void)
{
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x80);
    outb(COM1 + 0, 0x03);
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x03);
    outb(COM1 + 2, 0xC7);
    outb(COM1 + 4, 0x0B);
}

void serial_putchar(char c)
{
    while ((inb(COM1 + 5) & 0x20) == 0) {
    }
    outb(COM1, (unsigned char)c);
}

void serial_write(const char *str)
{
    for (; *str; str++) {
        serial_putchar(*str);
    }
}
