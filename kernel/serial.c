#include "serial.h"

#define COM1 0x3f8

int serial_init(void)
{
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x80);
    outb(COM1 + 0, 0x03);
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x03);
    outb(COM1 + 2, 0xc7);
    outb(COM1 + 4, 0x0b);
    outb(COM1 + 4, 0x1e);

    outb(COM1 + 0, 0xae);
    if (inb(COM1 + 0) != 0xae)
        return 0;

    outb(COM1 + 4, 0x0f);
    return 1;
}

void serial_putc(char c)
{
    while ((inb(COM1 + 5) & 0x20) == 0)
        ;

    outb(COM1, (uint8_t)c);

    if (c == '\n')
        serial_putc('\r');
}

void serial_write(const char *s)
{
    while (*s)
        serial_putc(*s++);
}
