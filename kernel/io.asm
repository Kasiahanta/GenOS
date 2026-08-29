bits 64

section .text

global outb
outb:
    mov rdx, rdi
    mov rax, rsi
    out dx, al
    ret

global inb
inb:
    mov rdx, rdi
    xor eax, eax
    in al, dx
    ret

global outw
outw:
    mov rdx, rdi
    mov rax, rsi
    out dx, ax
    ret

global inw
inw:
    mov rdx, rdi
    xor eax, eax
    in ax, dx
    ret

global io_wait
io_wait:
    mov al, 0
    out 0x80, al
    ret

global cpu_halt
cpu_halt:
    cli
.loop:
    hlt
    jmp .loop

global read_cr3
read_cr3:
    mov rax, cr3
    ret
