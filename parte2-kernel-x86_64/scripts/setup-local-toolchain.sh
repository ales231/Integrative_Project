#!/usr/bin/env bash
# scripts/setup-local-toolchain.sh — Instala NASM y xorriso en .toolchain/ sin sudo
#
# Uso: ./scripts/setup-local-toolchain.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLCHAIN="${ROOT}/.toolchain"
LOCAL="${TOOLCHAIN}/local"
NASM_PREFIX="${TOOLCHAIN}/nasm-local"
NASM_VERSION="2.16.03"
MIRROR="${ARCH_MIRROR:-https://geo.mirror.pkgbuild.com/extra/os/x86_64}"

echo "==> Toolchain local en ${TOOLCHAIN}"

mkdir -p "${TOOLCHAIN}"
cd "${TOOLCHAIN}"

if [[ -x "${NASM_PREFIX}/bin/nasm" ]]; then
    echo "NASM ya instalado: $("${NASM_PREFIX}/bin/nasm" -v | head -1)"
else
    echo "==> Compilando NASM ${NASM_VERSION}..."
    curl -fsSLO "https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.xz"
    tar -xf "nasm-${NASM_VERSION}.tar.xz"
    cd "nasm-${NASM_VERSION}"
    ./configure --prefix="${NASM_PREFIX}"
    make -j"$(nproc)"
    make install
    cd "${TOOLCHAIN}"
fi

if [[ -x "${LOCAL}/usr/bin/xorriso" ]]; then
    echo "xorriso ya instalado: $("${LOCAL}/usr/bin/xorriso" -version 2>&1 | head -1)"
else
    echo "==> Descargando libisofs, libburn, libisoburn (xorriso)..."
    mkdir -p "${LOCAL}"
    cd "${TOOLCHAIN}"
    for pkg in libisofs libburn libisoburn; do
        file="$(curl -fsSL "${MIRROR}/" | sed -n "s/.*href=\"\\(${pkg}-[^\"]*-x86_64\\.pkg\\.tar\\.zst\\)\".*/\\1/p" | sort -V | tail -1)"
        echo "    ${file}"
        curl -fsSLO "${MIRROR}/${file}"
        tar -xf "${file}" -C "${LOCAL}"
    done
fi

echo ""
echo "Listo. El Makefile detecta automáticamente .toolchain/"
echo "  make episode2"
echo "  make run"
