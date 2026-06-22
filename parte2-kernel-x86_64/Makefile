# =============================================================================
# Makefile — Parte 2 Kernel x86_64
# Episode 1: Multiboot2 + GRUB + QEMU + VGA 0xB8000 ("OK")
# Episode 2: GDT + paging + long mode + C (futuro)
# =============================================================================

SHELL := /bin/bash
.DEFAULT_GOAL := help

# --- Docker ------------------------------------------------------------------
DOCKER_COMPOSE := docker compose
DOCKER_IMAGE   := integrative-kernel-toolchain:24.04
DOCKER_RUN     := $(DOCKER_COMPOSE) run --rm toolchain

# --- Toolchain (host o contenedor) -------------------------------------------
ASM      := nasm
LD       := ld
GRUB_MK  := grub-mkrescue

# Episode 1 arranca en 32 bits (Multiboot2); Episode 2 enlaza en 64 bits
ASMFLAGS_EP1 := -f elf32
ASMFLAGS_EP2 := -f elf64
LDFLAGS_EP1  := -m elf_i386 -n -T linker.ld
LDFLAGS_EP2  := -n -T linker.ld

# --- Rutas -------------------------------------------------------------------
SRC_BOOT   := src/boot
SRC_ARCH   := src/arch
SRC_KERNEL := src/kernel

BUILD_DIR  := build
OUTPUT_DIR := output
ISO_STAGING := iso

# Episode 1 — solo arranque Multiboot2
EP1_ASM := $(SRC_BOOT)/header.asm $(SRC_BOOT)/main.asm
EP1_OBJ := $(BUILD_DIR)/header.o $(BUILD_DIR)/main.o

# Episode 2 — arranque + arquitectura + kernel C (se activará más adelante)
EP2_ASM := $(EP1_ASM) $(SRC_ARCH)/gdt.asm $(SRC_ARCH)/paging.asm
EP2_C   := $(SRC_KERNEL)/main.c $(SRC_KERNEL)/vga.c
EP2_OBJ := $(EP1_OBJ) \
           $(BUILD_DIR)/gdt.o $(BUILD_DIR)/paging.o \
           $(BUILD_DIR)/main.o $(BUILD_DIR)/vga.o

KERNEL_ELF_EP1 := $(BUILD_DIR)/kernel-ep1.elf
KERNEL_ELF_EP2 := $(BUILD_DIR)/kernel-ep2.elf
KERNEL_BIN     := $(OUTPUT_DIR)/kernel.bin
KERNEL_ISO     := $(OUTPUT_DIR)/kernel.iso

GRUB_CFG := grub.cfg

# --- Phony -------------------------------------------------------------------
.PHONY: help docker-build docker-shell docker-episode1 docker-run build run episode1 episode2 clean distclean

help:
	@echo "Parte 2 — Kernel x86_64"
	@echo ""
	@echo "  make docker-build     Construye la imagen Docker de la toolchain"
	@echo "  make docker-shell     Shell interactivo dentro del contenedor"
	@echo "  make docker-episode1  Compila Episode 1 dentro de Docker"
	@echo "  make docker-run       Ejecuta QEMU dentro de Docker"
	@echo "  make build          Compila kernel.bin y kernel.iso (Episode 1)"
	@echo "  make run            Ejecuta kernel.iso en QEMU"
	@echo "  make episode1       Alias de build (solo Episode 1)"
	@echo "  make episode2       Build Episode 2 (long mode + C) — pendiente"
	@echo "  make clean          Elimina artefactos de compilación"
	@echo "  make distclean      clean + elimina staging ISO"

# --- Docker wrappers ---------------------------------------------------------
docker-build:
	$(DOCKER_COMPOSE) build

docker-shell:
	$(DOCKER_RUN) bash

docker-episode1:
	$(DOCKER_RUN) make episode1

docker-run:
	$(DOCKER_RUN) make run

# Targets públicos: ejecutar en host (requiere toolchain local)
build: episode1

run:
	@./scripts/run-qemu.sh "$(KERNEL_ISO)"

episode1: $(KERNEL_ISO)
	@echo "Episode 1 listo: $(KERNEL_ISO)"

episode2:
	@echo "Episode 2 aún no implementado (GDT, paging, long mode, C)."
	@echo "Usa 'make episode1' por ahora."
	@exit 1

# --- Ensamblado y enlazado (Episode 1) ---------------------------------------
$(BUILD_DIR)/%.o: $(SRC_BOOT)/%.asm | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS_EP1) $< -o $@

$(KERNEL_ELF_EP1): $(EP1_OBJ) linker.ld | $(BUILD_DIR)
	$(LD) $(LDFLAGS_EP1) -o $@ $(EP1_OBJ)

$(KERNEL_BIN): $(KERNEL_ELF_EP1) | $(OUTPUT_DIR)
	objcopy -O binary $< $@
	@echo "Generado: $@"

$(KERNEL_ISO): $(KERNEL_BIN) $(GRUB_CFG) | $(OUTPUT_DIR) $(ISO_STAGING)
	./scripts/build-iso.sh "$(KERNEL_BIN)" "$(GRUB_CFG)" "$(KERNEL_ISO)" "$(ISO_STAGING)"

# --- Directorios de salida ---------------------------------------------------
$(BUILD_DIR) $(OUTPUT_DIR) $(ISO_STAGING):
	mkdir -p $@

# --- Limpieza ----------------------------------------------------------------
clean:
	rm -rf $(BUILD_DIR) $(ISO_STAGING)
	rm -f $(OUTPUT_DIR)/kernel.bin $(OUTPUT_DIR)/kernel.iso

distclean: clean
	rm -rf $(OUTPUT_DIR)
