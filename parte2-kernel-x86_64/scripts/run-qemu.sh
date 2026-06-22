#!/usr/bin/env bash
# scripts/run-qemu.sh — Lanza QEMU con la ISO del kernel
#
# Uso: run-qemu.sh [ruta-a-kernel.iso]
#
# Si no hay backend gráfico (gtk/sdl), usa -display none -serial stdio
# y el banner se ve en la terminal (COM1 del kernel).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO="${1:-${ROOT}/output/kernel.iso}"
QEMU_ARGS_FILE="${ROOT}/config/qemu.args"
QEMU_BIN="${QEMU_BIN:-qemu-system-x86_64}"

if [[ ! -f "${ISO}" ]]; then
    echo "No se encontró ${ISO}. Ejecuta 'make episode2' primero." >&2
    exit 1
fi

pick_display() {
    local help backends preferred backend
    help="$("${QEMU_BIN}" -display help 2>&1 || true)"

    if [[ -n "${QEMU_DISPLAY:-}" ]]; then
        echo "${QEMU_DISPLAY}"
        return
    fi

    preferred=(gtk sdl cocoa dbus egl-headless curses)
    for backend in "${preferred[@]}"; do
        if grep -qw "${backend}" <<< "${help}"; then
            echo "${backend}"
            return
        fi
    done

    echo "none"
}

DISPLAY_BACKEND="$(pick_display)"

QEMU_OPTS=(-cdrom "${ISO}" -m 128M)

if [[ "${DISPLAY_BACKEND}" == "none" ]]; then
    echo "Aviso: QEMU sin backend gráfico (solo 'none')."
    echo "  → Salida del kernel en esta terminal (-serial stdio)."
    echo "  → Para ventana VGA: sudo pacman -S qemu-ui-gtk   # Arch"
    echo "                      sudo apt install qemu-system-gui # Debian/Ubuntu"
    QEMU_OPTS+=(-display none -serial stdio)
else
    echo "QEMU display: ${DISPLAY_BACKEND}"
    QEMU_OPTS+=(-display "${DISPLAY_BACKEND}" -serial stdio)
fi

if [[ -f "${QEMU_ARGS_FILE}" ]]; then
    mapfile -t EXTRA < <(grep -v '^\s*#' "${QEMU_ARGS_FILE}" | grep -v '^\s*$')
    if ((${#EXTRA[@]} > 0)); then
        QEMU_OPTS+=("${EXTRA[@]}")
    fi
fi

exec "${QEMU_BIN}" "${QEMU_OPTS[@]}"
