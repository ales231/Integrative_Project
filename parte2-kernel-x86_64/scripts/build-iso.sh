#!/usr/bin/env bash
# scripts/build-iso.sh — Empaqueta el kernel ELF en una ISO booteable con GRUB (Multiboot2)
#
# Uso: build-iso.sh <kernel.elf> <grub.cfg> <salida.iso> <staging-dir>

set -euo pipefail

KERNEL_ELF="${1:?kernel.elf requerido}"
GRUB_CFG="${2:?grub.cfg requerido}"
OUTPUT_ISO="${3:?kernel.iso requerido}"
STAGING="${4:?directorio staging requerido}"

BOOT_DIR="${STAGING}/boot/grub"

rm -rf "${STAGING}"
mkdir -p "${BOOT_DIR}"

cp "${KERNEL_ELF}" "${STAGING}/boot/kernel.elf"
cp "${GRUB_CFG}" "${BOOT_DIR}/grub.cfg"

XORRISO_BIN="${XORRISO:-xorriso}"
grub-mkrescue --xorriso="${XORRISO_BIN}" -o "${OUTPUT_ISO}" "${STAGING}"

echo "ISO generada: ${OUTPUT_ISO}"
