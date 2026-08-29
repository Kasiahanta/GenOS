bits 64

extern kmain
extern __bss_start
extern __bss_end
extern __init_array_start
extern __init_array_end

section .text.boot
global _start
_start:
    mov r15, rdi

    mov rdi, __bss_start
    mov rcx, __bss_end
    sub rcx, rdi
    xor eax, eax
    rep stosb

    mov rsp, stack_top
    xor ebp, ebp

    mov rbx, __init_array_start
.ctors:
    mov rax, __init_array_end
    cmp rbx, rax
    jae .ctors_done
    call [rbx]
    add rbx, 8
    jmp .ctors
.ctors_done:

    mov rdi, r15
    call kmain

.hang:
    cli
    hlt
    jmp .hang

section .bss
align 16
stack_bottom:
    resb 65536
stack_top:
