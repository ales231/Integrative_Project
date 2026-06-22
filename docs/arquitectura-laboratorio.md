# Tabla de arquitectura del laboratorio

Visión técnica del proyecto integrador: tres subsistemas independientes que
comparten documentación, convenciones de repo y evidencias reproducibles.

---

## Arquitectura global

| Capa | Componente | Tecnología | Propósito | Parte |
|------|------------|------------|-----------|-------|
| Sistema operativo | ISO personalizada | Linux Mint + Cubic | Escritorio listo para desarrollo con persistencia | 1 |
| Bootloader | GRUB Multiboot2 | grub-mkrescue | Carga del kernel desde `kernel.iso` | 2 |
| Kernel | Boot + arch + C | NASM, GCC freestanding | Arranque 32→64 bits, VGA, mensaje del grupo | 2 |
| Virtualización dev | QEMU | x86_64 softmmu | Ejecución del kernel sin hardware físico | 2 |
| Contenedores | 8 servicios | Docker Compose | Simulación de infraestructura corporativa | 3 |
| Redes | dmz + internal | Bridge Docker | Segmentación DMZ / red interna | 3 |
| Ofensiva | Playbook | Bash + RustScan/Nmap/… | Cadena recon → enum → explotación controlada | 3 |
| CI local | Make + scripts | Bash | `make test`, `verify-all.sh` | 2, 3 |
| Evidencias | docs/evidencias | PNG, logs, SHA256 | Trazabilidad para evaluación | Todas |

---

## Parte 1 — Distro Linux (Cubic)

| Elemento | Detalle |
|----------|---------|
| Base | Linux Mint 22.x Cinnamon (amd64) |
| Herramienta de build | Cubic (chroot sobre ISO base) |
| Mecanismos de personalización | APT, `/etc/skel`, `gschema` override, `dconf` |
| Artefacto de salida | `*.iso` (no en Git; checksum sí) |
| Verificación | Boot en VM + usuario nuevo post-build |

### Modificaciones del sistema

| # | Modificación | Capa | Persistencia |
|---|--------------|------|--------------|
| 1 | LibreWolf (reemplaza Firefox) | Paquetes APT + alternatives | Sistema |
| 2 | Neovim con `init.lua` | APT + skel | Usuario nuevo |
| 3 | Visual Studio Code | Repo Microsoft APT | Sistema |
| 4 | Tema Mint-Y-Dark por defecto | gschema + dconf en skel | Sistema + usuario |
| 5 | Plantilla de usuario (alias, bienvenida) | `/etc/skel` | Usuario nuevo |
| 6 | Branding (opcional) | Scripts + assets | Sistema |

### Pipeline de build Cubic

```
ISO Mint base → Cubic chroot → scripts 04→02→03→05 → Generate → build/*.iso
                                      ↓
                              SHA256 → docs/evidencias/parte1/
```

---

## Parte 2 — Kernel x86_64

| Elemento | Detalle |
|----------|---------|
| Arquitectura objetivo | x86_64 (long mode) |
| Formato de arranque | ELF64 Multiboot2 |
| Toolchain | NASM 2.16, GCC freestanding, LD, GRUB, xorriso |
| Entorno reproducible | Docker `integrative-kernel-toolchain:24.04` |
| Artefactos | `build/kernel-ep2.elf`, `output/kernel.iso` |
| Runtime | QEMU (`-serial stdio`, VGA texto `0xB8000`) |

### Episodios

| Episodio | Archivo arranque | Objetivo | Salida visible |
|----------|------------------|----------|----------------|
| 1 | `main_ep1.asm` | Validar Multiboot2 | `OK` en VGA |
| 2 | `main.asm` + arch + C | GDT, paging 2 MiB, long mode | Banner del grupo |

### Flujo de arranque (Episode 2)

| Etapa | Modo | Componente | Acción |
|-------|------|------------|--------|
| 1 | — | GRUB | Carga ELF, magic Multiboot2 en EAX |
| 2 | 32-bit | `main.asm` | Stack, checks CPUID/long mode |
| 3 | 32-bit | `paging.asm` | Mapa identidad 1 GiB (huge pages) |
| 4 | 32-bit | `gdt.asm` | `lgdt` + far jump |
| 5 | 64-bit | `long_mode.asm` | Limpia segmentos, `call kernel_main` |
| 6 | 64-bit | `main.c` + `vga.c` | `print()` banner, bucle `hlt` |

---

## Parte 3 — Black Hat Bash

| Elemento | Detalle |
|----------|---------|
| Orquestación | Docker Compose v2 |
| Contenedores | 8 (attacker, victim-web, victim-ftp, victim-db, dns, mail, monitor, jumpbox) |
| Redes | `dmz` (172.28.10.0/24), `internal` (172.28.20.0/24, aislada) |
| Puertos host | 8080 → victim-web:80, 2222 → jumpbox:22 |
| Tests | `test-containers.sh`, `test-networks.sh`, `test-offensive.sh` |
| Ataque | `offensive/exploit.sh` (15/15 hacking) |

### Matriz de servicios

| Contenedor | Imagen / build | Red(es) | IP | Rol |
|------------|----------------|---------|-----|-----|
| attacker | build | dmz | 172.28.10.2 | Estación ofensiva (RustScan, Nmap, Nuclei…) |
| victim-web | build | dmz | 172.28.10.10 | Flask + WP simulado, puertos 80/8081 |
| victim-ftp | build | dmz + internal | .10.11 / .20.11 | vsFTPd anónimo + Apache `/backup` |
| jumpbox | build | dmz + internal | .10.13 / .20.12 | Bastión SSH (pivot) |
| victim-db | postgres:16-alpine | internal | 172.28.20.15 | PostgreSQL (no alcanzable desde attacker) |
| dns | strm/dnsmasq | internal | 172.28.20.53 | Resolución interna |
| mail | boky/postfix | internal | 172.28.20.25 | SMTP relay lab.local |
| monitor | build | internal | 172.28.20.30 | Captura y logs |

### Cadena ofensiva documentada

| Fase | Herramientas | Objetivo |
|------|--------------|----------|
| Reconocimiento | RustScan, Nmap | Puertos y versiones en subred dmz |
| Fingerprinting | WhatWeb | Stack web (Flask, Apache, WP) |
| Enumeración | Dirsearch | `/upload`, `/.git`, `/backup` |
| Vulnerabilidades | Nuclei | Templates FTP, Apache, WordPress |
| Explotación | lftp, curl | FTP anónimo, enum usuarios WP |

---

## Dependencias entre partes

Las tres partes son **independientes en ejecución** (no comparten runtime), pero
se integran conceptualmente en el proyecto:

| Relación | Descripción |
|----------|-------------|
| Parte 1 → 2 | La ISO puede usarse como host de desarrollo con Docker/QEMU |
| Parte 1 → 3 | Misma base Debian/Ubuntu para entender paquetes y servicios |
| Parte 2 → 3 | Conocimiento de red/stack bajo nivel complementa segmentación Docker |
| Repo común | Evidencias, rúbrica, video final y defensa oral unificados |

---

## Comandos de verificación por parte

| Parte | Comando | Resultado esperado |
|-------|---------|-------------------|
| 1 | Boot ISO + `adduser testuser` | skel, tema, LibreWolf, nvim, code |
| 2 | `make episode2 && make run` | Banner en QEMU |
| 3 | `make deploy && make test` | 8 contenedores UP, redes OK, playbook OK |
| Global | `./scripts/verify-all.sh` | Estructura del repo OK |
