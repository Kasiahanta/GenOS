#include "types.h"

void *memset(void *dst, int value, size_t count)
{
    uint8_t *p = (uint8_t *)dst;

    while (count--)
        *p++ = (uint8_t)value;

    return dst;
}

void *memcpy(void *dst, const void *src, size_t count)
{
    uint8_t *d = (uint8_t *)dst;
    const uint8_t *s = (const uint8_t *)src;

    while (count--)
        *d++ = *s++;

    return dst;
}

int memcmp(const void *a, const void *b, size_t count)
{
    const uint8_t *x = (const uint8_t *)a;
    const uint8_t *y = (const uint8_t *)b;

    while (count--) {
        if (*x != *y)
            return (int)*x - (int)*y;
        x++;
        y++;
    }

    return 0;
}

size_t strlen(const char *s)
{
    const char *p = s;

    while (*p)
        p++;

    return (size_t)(p - s);
}
