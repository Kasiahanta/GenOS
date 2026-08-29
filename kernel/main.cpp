#include "console.hpp"
#include "vga.h"

extern "C" void kmain(void *boot_info)
{
    (void)boot_info;

    vga_set_color(VGA_LIGHT_GREEN, VGA_BLACK);
    console << "Hallo, Mascha!\n";

    vga_set_color(VGA_LIGHT_GREY, VGA_BLACK);
    console << "GenOS v1 laeuft im Long Mode.\n";

    cpu_halt();
}
