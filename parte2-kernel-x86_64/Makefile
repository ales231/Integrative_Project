# =============================================================================
# Makefile — Parte 2 Kernel x86_64
# Episode 1: Multiboot2 + GRUB + QEMU + VGA 0xB8000 ("OK")
# Episode 2: GDT + paging + long mode + C (print + mensaje del grupo)
# =============================================================================

SHELL := /bin/bash
.DEFAULT_GOAL := help

DOCKER_COMPOSE := docker compose
DOCKER_RUN     := $(DOCKER_COMPOSE) run --rm toolchain

ASM      := nasm
CC       := gcc
LD       := ld
OBJCOPY  := objcopy

# Toolchain local (sin sudo): NASM y xorriso extraídos en .toolchain/
LOCAL_TOOLCHAIN := $(abspath .toolchain/local)
ifneq ($(wildcard .toolchain/nasm-local/bin/nasm),)
ASM := .toolchain/nasm-local/bin/nasm
endif
ifneq ($(wildcard .toolchain/local/usr/bin/xorriso),)
export LD_LIBRARY_PATH := $(LOCAL_TOOLCHAIN)/usr/lib$(if $(LD_LIBRARY_PATH),:$(LD_LIBRARY_PATH),)
export XORRISO := $(LOCAL_TOOLCHAIN)/usr/bin/xorriso
endif

SRC_BOOT   := src/boot
SRC_ARCH   := src/arch
SRC_KERNEL := src/kernel

ASMFLAGS_EP1 := -f elf32
LDFLAGS_EP1  := -m elf_i386 -n -T linker.ld

ASMFLAGS_EP2 := -f elf64
CFLAGS_EP2   := -m64 -ffreestanding -fno-stack-protector -fno-pic -fno-pie \
                -mno-red-zone -mno-mmx -mno-sse -mno-sse2 \
                -nostdlib -Wall -Wextra -I$(SRC_KERNEL)
LDFLAGS_EP2  := -no-pie -n -T linker.ld

BUILD_DIR   := build
OUTPUT_DIR  := output
ISO_STAGING := iso

EP1_OBJ := $(BUILD_DIR)/header.o $(BUILD_DIR)/main_ep1.o
EP2_OBJ := $(BUILD_DIR)/ep2/header.o \
           $(BUILD_DIR)/ep2/boot_main.o \
           $(BUILD_DIR)/ep2/gdt.o \
           $(BUILD_DIR)/ep2/paging.o \
           $(BUILD_DIR)/ep2/long_mode.o \
           $(BUILD_DIR)/ep2/kernel_main.o \
           $(BUILD_DIR)/ep2/vga.o \
           $(BUILD_DIR)/ep2/serial.o

KERNEL_ELF_EP1 := $(BUILD_DIR)/kernel-ep1.elf
KERNEL_ELF_EP2 := $(BUILD_DIR)/kernel-ep2.elf
KERNEL_BIN     := $(OUTPUT_DIR)/kernel.bin
KERNEL_ISO     := $(OUTPUT_DIR)/kernel.iso
GRUB_CFG       := grub.cfg

# GRUB Multiboot2 requiere ELF; el .bin plano (objcopy) no arranca.
ISO_KERNEL_EP1 := $(OUTPUT_DIR)/kernel-ep1.elf
ISO_KERNEL_EP2 := $(OUTPUT_DIR)/kernel-ep2.elf

.PHONY: help all docker-build docker-shell docker-episode1 docker-episode2 \
        docker-run setup-toolchain run episode1 episode2 clean distclean

help:
	@echo "Parte 2 — Kernel x86_64"
	@echo ""
	@echo "  make docker-build      Construye la imagen Docker de la toolchain"
	@echo "  make docker-shell      Shell interactivo dentro del contenedor"
	@echo "  make docker-episode1   Compila Episode 1 dentro de Docker"
	@echo "  make docker-episode2   Compila Episode 2 dentro de Docker"
	@echo "  make docker-run        Ejecuta QEMU dentro de Docker"
	@echo "  make setup-toolchain   Instala NASM + xorriso en .toolchain/ (sin sudo)"
	@echo "  make all               Alias de episode2"
	@echo "  make run               Compila Episode 2 y ejecuta QEMU"
	@echo "  make episode1          Multiboot2 + OK en VGA"
	@echo "  make episode2          Long mode + C + mensaje del grupo"
	@echo "  make clean             Elimina artefactos de compilación"
	@echo "  make distclean         clean + elimina output/"

docker-build:
	$(DOCKER_COMPOSE) build

docker-shell:
	$(DOCKER_RUN) bash

docker-episode1:
	$(DOCKER_RUN) make episode1

docker-episode2:
	$(DOCKER_RUN) make episode2

docker-run:
	$(DOCKER_RUN) make run

all: episode2

setup-toolchain:
	@./scripts/setup-local-toolchain.sh

run: episode2
	@./scripts/run-qemu.sh "$(KERNEL_ISO)"

# --- Episode 1 ---------------------------------------------------------------
episode1: $(KERNEL_ELF_EP1) | $(OUTPUT_DIR) $(ISO_STAGING)
	cp $(KERNEL_ELF_EP1) $(ISO_KERNEL_EP1)
	./scripts/build-iso.sh "$(ISO_KERNEL_EP1)" "$(GRUB_CFG)" "$(KERNEL_ISO)" "$(ISO_STAGING)"
	@echo "Episode 1 listo: $(KERNEL_ISO)"

$(BUILD_DIR)/header.o: $(SRC_BOOT)/header.asm
	@mkdir -p $(BUILD_DIR)
	$(ASM) $(ASMFLAGS_EP1) $< -o $@

$(BUILD_DIR)/main_ep1.o: $(SRC_BOOT)/main_ep1.asm
	@mkdir -p $(BUILD_DIR)
	$(ASM) $(ASMFLAGS_EP1) $< -o $@

$(KERNEL_ELF_EP1): $(EP1_OBJ) linker.ld
	@mkdir -p $(BUILD_DIR)
	$(LD) $(LDFLAGS_EP1) -o $@ $(EP1_OBJ)

# --- Episode 2 ---------------------------------------------------------------
episode2: $(KERNEL_ELF_EP2) | $(OUTPUT_DIR) $(ISO_STAGING)
	cp $(KERNEL_ELF_EP2) $(ISO_KERNEL_EP2)
	./scripts/build-iso.sh "$(ISO_KERNEL_EP2)" "$(GRUB_CFG)" "$(KERNEL_ISO)" "$(ISO_STAGING)"
	@echo "Episode 2 listo: $(KERNEL_ISO)"

$(BUILD_DIR)/ep2:
	mkdir -p $@

$(BUILD_DIR)/ep2/header.o: $(SRC_BOOT)/header.asm | $(BUILD_DIR)/ep2
	$(ASM) $(ASMFLAGS_EP2) $< -o $@

$(BUILD_DIR)/ep2/boot_main.o: $(SRC_BOOT)/main.asm | $(BUILD_DIR)/ep2
	$(ASM) $(ASMFLAGS_EP2) $< -o $@

$(BUILD_DIR)/ep2/gdt.o: $(SRC_ARCH)/gdt.asm | $(BUILD_DIR)/ep2
	$(ASM) $(ASMFLAGS_EP2) $< -o $@

$(BUILD_DIR)/ep2/paging.o: $(SRC_ARCH)/paging.asm | $(BUILD_DIR)/ep2
	$(ASM) $(ASMFLAGS_EP2) $< -o $@

$(BUILD_DIR)/ep2/long_mode.o: $(SRC_ARCH)/long_mode.asm | $(BUILD_DIR)/ep2
	$(ASM) $(ASMFLAGS_EP2) $< -o $@

$(BUILD_DIR)/ep2/kernel_main.o: $(SRC_KERNEL)/main.c $(SRC_KERNEL)/vga.h $(SRC_KERNEL)/serial.h | $(BUILD_DIR)/ep2
	$(CC) $(CFLAGS_EP2) -c $< -o $@

$(BUILD_DIR)/ep2/vga.o: $(SRC_KERNEL)/vga.c $(SRC_KERNEL)/vga.h $(SRC_KERNEL)/serial.h | $(BUILD_DIR)/ep2
	$(CC) $(CFLAGS_EP2) -c $< -o $@

$(BUILD_DIR)/ep2/serial.o: $(SRC_KERNEL)/serial.c $(SRC_KERNEL)/serial.h | $(BUILD_DIR)/ep2
	$(CC) $(CFLAGS_EP2) -c $< -o $@

$(KERNEL_ELF_EP2): $(EP2_OBJ) linker.ld
	@mkdir -p $(BUILD_DIR)
	$(LD) $(LDFLAGS_EP2) -o $@ $(EP2_OBJ)

$(OUTPUT_DIR) $(ISO_STAGING):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR) $(ISO_STAGING)
	rm -f $(OUTPUT_DIR)/kernel.bin $(OUTPUT_DIR)/kernel.iso \
	      $(OUTPUT_DIR)/kernel-ep1.elf $(OUTPUT_DIR)/kernel-ep2.elf

distclean: clean
	rm -rf $(OUTPUT_DIR)
