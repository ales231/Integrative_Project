# TODO: Dockerfile reproducible para toolchain NASM + GCC cross + GRUB
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    nasm \
    gcc \
    make \
    grub-pc-bin \
    xorriso \
    qemu-system-x86 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
