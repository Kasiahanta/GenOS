BUILD    := build
CC       := gcc
CXX      := g++
LD       := ld
NASM     := nasm
OBJCOPY  := objcopy

WARN     := -Wall -Wextra
FREE     := -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-pie \
            -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -mno-80387 -O2 -g
CFLAGS   := $(WARN) $(FREE) -std=c17
CXXFLAGS := $(WARN) $(FREE) -std=c++20 -fno-exceptions -fno-rtti \
            -fno-threadsafe-statics -fno-use-cxa-atexit
LDFLAGS  := -n -T linker.ld -z max-page-size=0x1000 --build-id=none -nostdlib

OBJS := $(BUILD)/entry.o $(BUILD)/io.o $(BUILD)/vga.o $(BUILD)/serial.o \
        $(BUILD)/string.o $(BUILD)/console.o $(BUILD)/cxx.o $(BUILD)/main.o

all: $(BUILD)/os.img

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/%.o: kernel/%.asm | $(BUILD)
	$(NASM) -f elf64 -g -F dwarf $< -o $@

$(BUILD)/%.o: kernel/%.c | $(BUILD)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/%.o: kernel/%.cpp | $(BUILD)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD)/kernel.elf: $(OBJS) linker.ld
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

$(BUILD)/kernel.bin: $(BUILD)/kernel.elf
	$(OBJCOPY) -O binary $< $@

$(BUILD)/stage1.bin: boot/stage1.asm | $(BUILD)
	$(NASM) -f bin $< -o $@

$(BUILD)/stage2.bin: boot/stage2.asm $(BUILD)/kernel.bin
	sectors=$$(( ($$(stat -c %s $(BUILD)/kernel.bin) + 511) / 512 )); \
	echo "kernel: $$(stat -c %s $(BUILD)/kernel.bin) bytes -> $$sectors sectors"; \
	$(NASM) -f bin -DKERNEL_SECTORS=$$sectors $< -o $@

$(BUILD)/os.img: $(BUILD)/stage1.bin $(BUILD)/stage2.bin $(BUILD)/kernel.bin
	dd if=/dev/zero of=$@ bs=512 count=2880 status=none
	dd if=$(BUILD)/stage1.bin of=$@ conv=notrunc status=none
	dd if=$(BUILD)/stage2.bin of=$@ seek=1 conv=notrunc status=none
	dd if=$(BUILD)/kernel.bin of=$@ seek=17 conv=notrunc status=none
	echo "image ready: $@"

run: $(BUILD)/os.img
	qemu-system-x86_64 -drive format=raw,file=$(BUILD)/os.img -m 256 -display gtk,zoom-to-fit=on -serial stdio -no-reboot

headless: $(BUILD)/os.img
	qemu-system-x86_64 -drive format=raw,file=$(BUILD)/os.img -m 256 \
		-serial stdio -display none -no-reboot

debug: $(BUILD)/os.img
	qemu-system-x86_64 -drive format=raw,file=$(BUILD)/os.img -m 256 \
		-serial stdio -s -S

clean:
	rm -rf $(BUILD)

.PHONY: all run headless debug clean
