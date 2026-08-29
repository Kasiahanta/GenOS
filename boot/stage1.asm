bits 16
org 0x7c00

STAGE2_LBA      equ 1
STAGE2_SECTORS  equ 16
STAGE2_ADDR     equ 0x7e00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov [boot_drive], dl

    mov ah, 0x41
    mov bx, 0x55aa
    int 0x13
    jc no_lba

    mov si, dap
    mov ah, 0x42
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    mov dl, [boot_drive]
    jmp 0x0000:STAGE2_ADDR

no_lba:
    mov si, msg_nolba
    jmp fail

disk_error:
    mov si, msg_disk

fail:
.print:
    lodsb
    test al, al
    jz .hang
    mov ah, 0x0e
    mov bx, 0x0007
    int 0x10
    jmp .print
.hang:
    cli
    hlt
    jmp .hang

msg_disk   db "GenOS: Bootfehler", 0
msg_nolba  db "GenOS: Kein LBA", 0
boot_drive db 0

align 4
dap:
    db 0x10
    db 0
    dw STAGE2_SECTORS
    dw STAGE2_ADDR
    dw 0
    dd STAGE2_LBA
    dd 0

times 510-($-$$) db 0
dw 0xaa55
