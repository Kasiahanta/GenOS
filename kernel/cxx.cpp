extern "C" void __cxa_pure_virtual()
{
    for (;;)
        __asm__ volatile("cli; hlt");
}

extern "C" int __cxa_atexit(void (*)(void *), void *, void *)
{
    return 0;
}

extern "C" void __cxa_finalize(void *)
{
}

void *__dso_handle = 0;
