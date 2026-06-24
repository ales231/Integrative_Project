# Toolchain reproducible — Parte 2 Kernel x86_64
# Episode 1: NASM + GRUB (Multiboot2) + QEMU
#
# Build imagen:  docker compose build
# Shell:         docker compose run --rm toolchain bash
# Compilar:      make docker-build   (o make build dentro del contenedor)

FROM ubuntu:24.04

LABEL org.opencontainers.image.title="integrative-kernel-toolchain"
LABEL org.opencontainers.image.description="NASM, GRUB, QEMU para kernel Multiboot2"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    nasm \
    binutils \
    gcc \
    make \
    grub-pc-bin \
    grub-common \
    xorriso \
    mtools \
    qemu-system-x86 \
    && rm -rf /var/lib/apt/lists/*

# Registro de versiones instaladas (auditoría de reproducibilidad)
RUN printf '%s\n' \
    "nasm $(nasm -v | head -1)" \
    "ld $(ld --version | head -1)" \
    "gcc $(gcc --version | head -1)" \
    "grub-mkrescue $(grub-mkrescue --version | head -1)" \
    "qemu $(qemu-system-x86_64 --version | head -1)" \
    > /etc/kernel-toolchain.versions \
    && cat /etc/kernel-toolchain.versions

RUN groupadd --gid 1001 builder \
    && useradd --uid 1001 --gid builder --create-home --shell /bin/bash builder

WORKDIR /build

USER builder

CMD ["bash"]
