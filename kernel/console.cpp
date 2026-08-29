#include "console.hpp"
#include "vga.h"
#include "serial.h"

VgaSink vga_sink;
SerialSink serial_sink;
Console console;

VgaSink::VgaSink()
{
    vga_init();
    ready = true;
}

void VgaSink::put(char c)
{
    vga_putc(c);
}

SerialSink::SerialSink()
{
    ready = serial_init() != 0;
}

void SerialSink::put(char c)
{
    if (ready)
        serial_putc(c);
}

Console::Console()
{
    count = 0;
    attach(&vga_sink);
    attach(&serial_sink);
}

void Console::attach(OutputSink *sink)
{
    if (count < max_sinks)
        sinks[count++] = sink;
}

void Console::put(char c)
{
    for (int i = 0; i < count; i++)
        sinks[i]->put(c);
}

void Console::write(const char *text)
{
    while (*text)
        put(*text++);
}

Console &Console::operator<<(const char *text)
{
    write(text);
    return *this;
}

Console &Console::operator<<(char c)
{
    put(c);
    return *this;
}

Console &Console::operator<<(uint64_t value)
{
    char digits[21];
    int i = 0;

    if (value == 0) {
        put('0');
        return *this;
    }

    while (value > 0 && i < 20) {
        digits[i++] = (char)('0' + (int)(value % 10));
        value /= 10;
    }

    while (i > 0)
        put(digits[--i]);

    return *this;
}

Console &Console::operator<<(Hex value)
{
    static const char *table = "0123456789abcdef";

    write("0x");

    for (int shift = (value.width - 1) * 4; shift >= 0; shift -= 4)
        put(table[(value.value >> shift) & 0xf]);

    return *this;
}
