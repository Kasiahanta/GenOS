bits 16
org 0x7e00

%ifndef KERNEL_SECTORS
%define KERNEL_SECTORS 64
%endif

KERNEL_LBA      equ 17
KERNEL_BUFFER   equ 0x10000
KERNEL_DEST     equ 0x100000
MMAP_COUNT      equ 0x5000
MMAP_ENTRIES    equ 0x5010
PML4            equ 0x1000
PDPT            equ 0x2000
PD              equ 0x3000

stage2_start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    mov [boot_drive], dl

    mov si, msg_stage2
    call print

    call enable_a20
    call detect_memory
    call read_kernel

    mov si, msg_pmode
    call print

    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:protected_mode

print:
.loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0e
    mov bx, 0x0007
    int 0x10
    jmp .loop
.done:
    ret

enable_a20:
    in al, 0x92
    test al, 2
    jnz .done
    or al, 2
    and al, 0xfe
    out 0x92, al
.done:
    ret

detect_memory:
    mov di, MMAP_ENTRIES
    xor ebx, ebx
    xor bp, bp
    mov edx, 0x534d4150
    mov eax, 0xe820
    mov dword [es:di + 20], 1
    mov ecx, 24
    int 0x15
    jc .failed
    mov edx, 0x534d4150
    cmp eax, edx
    jne .failed
    test ebx, ebx
    je .failed
    jmp .process
.next:
    mov eax, 0xe820
    mov dword [es:di + 20], 1
    mov ecx, 24
    mov edx, 0x534d4150
    int 0x15
    jc .done
    mov edx, 0x534d4150
.process:
    jcxz .skip
    cmp cl, 20
    jbe .store
    test byte [es:di + 20], 1
    je .skip
.store:
    mov ecx, [es:di + 8]
    or ecx, [es:di + 12]
    jz .skip
    inc bp
    add di, 24
.skip:
    test ebx, ebx
    jne .next
.done:
    movzx eax, bp
    mov [MMAP_COUNT], eax
    clc
    ret
.failed:
    mov dword [MMAP_COUNT], 0
    ret

read_kernel:
    mov dword [sectors_left], KERNEL_SECTORS
    mov dword [current_lba], KERNEL_LBA
    mov word [current_seg], KERNEL_BUFFER >> 4
.loop:
    mov eax, [sectors_left]
    test eax, eax
    jz .done
    cmp eax, 32
    jbe .use
    mov eax, 32
.use:
    mov [chunk], eax
    mov word [dap_size], 0x0010
    mov ax, [chunk]
    mov [dap_count], ax
    mov word [dap_offset], 0
    mov ax, [current_seg]
    mov [dap_segment], ax
    mov eax, [current_lba]
    mov [dap_lba], eax
    mov dword [dap_lba + 4], 0

    mov si, dap
    mov ah, 0x42
    mov dl, [boot_drive]
    int 0x13
    jc .error

    mov eax, [chunk]
    sub [sectors_left], eax
    add [current_lba], eax
    shl eax, 5
    add [current_seg], ax
    jmp .loop
.done:
    ret
.error:
    mov si, msg_disk
    call print
.hang:
    cli
    hlt
    jmp .hang

msg_stage2   db "GenOS: Kernel wird geladen", 13, 10, 0
msg_pmode    db "GenOS: Wechsel in den Long Mode", 13, 10, 0
msg_disk     db "GenOS: Datentraegerfehler", 13, 10, 0
boot_drive   db 0
sectors_left dd 0
current_lba  dd 0
chunk        dd 0
current_seg  dw 0

align 4
dap:
dap_size     dw 0x0010
dap_count    dw 0
dap_offset   dw 0
dap_segment  dw 0
dap_lba      dq 0

align 8
gdt:
    dq 0x0000000000000000
    dq 0x00cf9a000000ffff
    dq 0x00cf92000000ffff
    dq 0x00af9a000000ffff
    dq 0x00af92000000ffff
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt - 1
    dd gdt

bits 32
protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x7c00

    mov esi, KERNEL_BUFFER
    mov edi, KERNEL_DEST
    mov ecx, KERNEL_SECTORS * 128
    rep movsd

    mov edi, PML4
    mov ecx, 3072
    xor eax, eax
    rep stosd

    mov dword [PML4], PDPT | 3
    mov dword [PDPT], PD | 3

    mov edi, PD
    mov eax, 0x83
    mov ecx, 512
.map:
    mov [edi], eax
    add eax, 0x200000
    add edi, 8
    loop .map

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov eax, PML4
    mov cr3, eax

    mov ecx, 0xc0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    jmp 0x18:long_mode

bits 64
long_mode:
    mov ax, 0x20
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rsp, 0x90000

    mov rdi, MMAP_COUNT
    mov rax, KERNEL_DEST
    jmp rax

times (16 * 512) - ($ - $$) db 0
