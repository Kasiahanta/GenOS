#ifndef CONSOLE_HPP
#define CONSOLE_HPP

#include "types.h"

struct Hex {
    uint64_t value;
    int width;
};

inline Hex hex(uint64_t value, int width = 16)
{
    Hex h;
    h.value = value;
    h.width = width;
    return h;
}

class OutputSink {
public:
    virtual void put(char c) = 0;
};

class VgaSink : public OutputSink {
public:
    VgaSink();
    void put(char c) override;
    bool ready;
};

class SerialSink : public OutputSink {
public:
    SerialSink();
    void put(char c) override;
    bool ready;
};

class Console {
public:
    Console();

    void attach(OutputSink *sink);
    void put(char c);
    void write(const char *text);

    Console &operator<<(const char *text);
    Console &operator<<(char c);
    Console &operator<<(uint64_t value);
    Console &operator<<(Hex value);

private:
    static const int max_sinks = 4;

    OutputSink *sinks[max_sinks];
    int count;
};

extern VgaSink vga_sink;
extern SerialSink serial_sink;
extern Console console;

#endif
