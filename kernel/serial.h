#ifndef SERIAL_H
#define SERIAL_H

#include "types.h"

#ifdef __cplusplus
extern "C" {
#endif

int serial_init(void);
void serial_putc(char c);
void serial_write(const char *s);

#ifdef __cplusplus
}
#endif

#endif
