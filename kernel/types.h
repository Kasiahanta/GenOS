#ifndef TYPES_H
#define TYPES_H

typedef unsigned char      uint8_t;
typedef signed char        int8_t;
typedef unsigned short     uint16_t;
typedef signed short       int16_t;
typedef unsigned int       uint32_t;
typedef signed int         int32_t;
typedef unsigned long long uint64_t;
typedef signed long long   int64_t;
typedef unsigned long      size_t;

#define NULL ((void *)0)

#ifdef __cplusplus
extern "C" {
#endif

void outb(uint16_t port, uint8_t value);
uint8_t inb(uint16_t port);
void outw(uint16_t port, uint16_t value);
uint16_t inw(uint16_t port);
void io_wait(void);
void cpu_halt(void);
uint64_t read_cr3(void);

void *memset(void *dst, int value, size_t count);
void *memcpy(void *dst, const void *src, size_t count);
int memcmp(const void *a, const void *b, size_t count);
size_t strlen(const char *s);

#ifdef __cplusplus
}
#endif

#endif
