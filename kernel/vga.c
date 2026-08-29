#include "vga.h"

static volatile uint16_t *const buffer = (volatile uint16_t *)0xb8000;
static size_t cursor_row;
static size_t cursor_col;
static uint8_t color;

static uint16_t entry(char c, uint8_t attr)
{
    return (uint16_t)c | ((uint16_t)attr << 8);
}

static void update_cursor(void)
{
    uint16_t pos = (uint16_t)(cursor_row * VGA_WIDTH + cursor_col);

    outb(0x3d4, 0x0f);
    outb(0x3d5, (uint8_t)(pos & 0xff));
    outb(0x3d4, 0x0e);
    outb(0x3d5, (uint8_t)((pos >> 8) & 0xff));
}

static void scroll(void)
{
    size_t x;
    size_t y;

    for (y = 1; y < VGA_HEIGHT; y++) {
        for (x = 0; x < VGA_WIDTH; x++)
            buffer[(y - 1) * VGA_WIDTH + x] = buffer[y * VGA_WIDTH + x];
    }

    for (x = 0; x < VGA_WIDTH; x++)
        buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + x] = entry(' ', color);

    cursor_row = VGA_HEIGHT - 1;
}

void vga_set_color(uint8_t fg, uint8_t bg)
{
    color = (uint8_t)(fg | (bg << 4));
}

void vga_clear(void)
{
    size_t i;

    for (i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++)
        buffer[i] = entry(' ', color);

    cursor_row = 0;
    cursor_col = 0;
    update_cursor();
}

void vga_init(void)
{
    vga_set_color(VGA_LIGHT_GREY, VGA_BLACK);
    vga_clear();
}

void vga_putc(char c)
{
    if (c == '\n') {
        cursor_col = 0;
        cursor_row++;
    } else if (c == '\r') {
        cursor_col = 0;
    } else if (c == '\t') {
        cursor_col = (cursor_col + 4) & ~(size_t)3;
    } else {
        buffer[cursor_row * VGA_WIDTH + cursor_col] = entry(c, color);
        cursor_col++;
    }

    if (cursor_col >= VGA_WIDTH) {
        cursor_col = 0;
        cursor_row++;
    }

    if (cursor_row >= VGA_HEIGHT)
        scroll();

    update_cursor();
}

void vga_write(const char *s)
{
    while (*s)
        vga_putc(*s++);
}
