# Proyecto Integrador — Ingeniería en Sistemas

**Equipo:** Arthur Beltran · Alex Alban · Pedro Cañar
**Período:** Marzo – Julio 2026 · UIDE
**Docente:** Ing. Jonathan E. Tito O., MSc.

| Integrante | Responsabilidad |
|------------|----------------|
| Arthur Beltran | Parte 1 — Distro Linux (Cubic) |
| Pedro Cañar | Parte 2 — Kernel x86_64 |
| Alex Alban | **Parte 3 — Black Hat Bash + documentación** |

Proyecto integrador en tres partes: distro Linux personalizada con **Cubic**,
kernel **x86_64** desde cero y laboratorio ofensivo con **Docker**. Todo el
material es reproducible desde este repositorio.

---

## Resumen ejecutivo

| Parte | Puntos (rúbrica) | Tecnologías clave | Estado |
|-------|------------------|-------------------|--------|
| [1 — Distro Linux (Cubic)](parte1-distro-linux/) | 25 | Linux Mint, Cubic, skel, gschema | Completada |
| [2 — Kernel x86_64](parte2-kernel-x86_64/) | 30 | NASM, Multiboot2, GRUB, QEMU, Docker | Completada |
| [3 — Black Hat Bash](parte3-black-hat-bash/) | 35 | Docker Compose, 8 contenedores, pentest | Completada |
| Documentación y repositorio | 10 | READMEs, evidencias, commits | Completada |

**Puntuación máxima:** 100 puntos. Detalle de criterios en [docs/rubrica.md](docs/rubrica.md).

---

## Mapa de documentación

| Documento | Descripción |
|-----------|-------------|
| [parte1-distro-linux/README.md](parte1-distro-linux/README.md) | README Cubic — ISO, modificaciones, persistencia |
| [parte2-kernel-x86_64/README.md](parte2-kernel-x86_64/README.md) | README Kernel — build, episodes, QEMU |
| [parte3-black-hat-bash/README.md](parte3-black-hat-bash/README.md) | README Black Hat Bash — lab, redes, ataque |
| [docs/arquitectura-laboratorio.md](docs/arquitectura-laboratorio.md) | Tabla de arquitectura del proyecto completo |
| [docs/diagrama-redes.md](docs/diagrama-redes.md) | Diagramas de red (Parte 3 y visión global) |
| [docs/evidencias/lista-evidencias.md](docs/evidencias/lista-evidencias.md) | Lista maestra de evidencias por parte |


---

## Requisitos globales

| Herramienta | Partes | Versión mínima |
|-------------|--------|----------------|
| Git | Todas | 2.40+ |
| Docker + Docker Compose | 2, 3 | 24+ / v2 |
| QEMU | 2 | 8.0+ |
| Cubic (GUI) | 1 | Última estable |
| NASM, GCC (cross) | 2 | vía Docker o toolchain local |
| Make | 2, 3 | 4.3+ |

Espacio en disco recomendado: **20 GB** libres (ISO, builds de kernel, imágenes Docker).

---

## Inicio rápido

### Parte 1 — Cubic (host con GUI)

```bash
# Ver instrucciones completas en parte1-distro-linux/README.md
# 1. Abrir Cubic con ISO Linux Mint Cinnamon amd64
# 2. Copiar scripts al chroot y ejecutar en orden
# 3. Generar ISO → parte1-distro-linux/build/
```

### Parte 2 — Kernel

```bash
cd parte2-kernel-x86_64
make docker-build      # una vez
make docker-episode2   # compila kernel.iso
make docker-run        # QEMU
```

Alternativa sin Docker:

```bash
./scripts/setup-local-toolchain.sh
make episode2 && make run
```

### Parte 3 — Black Hat Bash

**Requisitos:** Docker 24+, Docker Compose v2, 4 GB RAM, 10 GB disco.

```bash
cd parte3-black-hat-bash
cp .env.example .env
make deploy          # construye imágenes y levanta 8 contenedores
make test            # verifica contenedores, redes y ejecuta playbook ofensivo
```

Salida esperada de `make test`:
```
OK: 8 contenedores en ejecución
OK: attacker → victim-web (dmz)
OK: attacker → victim-ftp (dmz)
OK: attacker → jumpbox SSH (dmz)
OK: attacker → victim-db bloqueado (red internal)
OK: verificación de redes completada
```

Para ejecutar solo la fase ofensiva:
```bash
make offensive
# equivalente a:
docker compose exec attacker bash /lab/offensive/exploit.sh
```

Evidencias generadas en `parte3-black-hat-bash/offensive/evidencia/` (19 archivos).

### Verificación global del repositorio

```bash
./scripts/verify-all.sh
```

---

## Estructura del repositorio

```
Integrative_Project/
├── README.md                         # Este archivo
├── LICENSE
├── CONTRIBUTING.md
├── docs/
│   ├── rubrica.md
│   ├── equipo.md
│   ├── cronograma.md
│   ├── arquitectura-laboratorio.md
│   ├── diagrama-redes.md
│   ├── guion-video-final.md
│   ├── defensa-oral.md
│   └── evidencias/
│       ├── lista-evidencias.md
│       ├── parte1/
│       ├── parte2/
│       └── parte3/
├── parte1-distro-linux/              # ISO personalizada (Cubic)
├── parte2-kernel-x86_64/             # Kernel Multiboot2 + GRUB + QEMU
├── parte3-black-hat-bash/            # 8 contenedores + técnica ofensiva
└── scripts/
    ├── verify-all.sh
    └── export-evidencias.sh
```

---

## Alineación con la rúbrica

### Parte 1 — Distro Linux (25 pts)

| Criterio | Evidencia |
|----------|-----------|
| ISO basada en Ubuntu/Mint | Linux Mint 22.x Cinnamon |
| Boot correcto en VM | Capturas en `docs/evidencias/parte1/` |
| ≥ 3 modificaciones justificadas | LibreWolf, Neovim, VS Code, tema oscuro, skel |
| Persistencia skel/gschema | Scripts Cubic + verificación con usuario nuevo |
| Video de demostración | [demo/enlaces.md](parte1-distro-linux/demo/enlaces.md) |

### Parte 2 — Kernel x86_64 (30 pts)

| Criterio | Evidencia |
|----------|-----------|
| Build reproducible con Docker | `Dockerfile`, `make docker-episode2` |
| Multiboot2, NASM, GRUB, QEMU | `src/boot/header.asm`, `grub.cfg`, `run-qemu.sh` |
| Episode 1: imprimir `OK` | `make episode1` → VGA `0xB8000` |
| Episode 2: long mode, paging, GDT, C | `EPISODE2.md`, capturas QEMU |
| Generación de `kernel.iso` | `output/kernel.iso` |

### Parte 3 — Black Hat Bash (35 pts)

**3.A — Lab up and running (20 pts)**

| Criterio | Pts | Evidencia real |
|----------|-----|----------------|
| Docker + Compose, repo clonado, `make deploy` exitoso | 6 | 8 imágenes construidas; `docker compose ps` muestra todos `Up` |
| `make test` = Lab is up + 8 contenedores verificados | 6 | `OK: 8 contenedores en ejecución` — `tests/test-containers.sh` |
| Redes validadas (dmz 172.28.10.0/24 + internal 172.28.20.0/24) | 4 | `OK: attacker → victim-db bloqueado` — `tests/test-networks.sh` |
| Tabla de arquitectura + `docker exec` demostrado | 4 | Tabla completa en `parte3-black-hat-bash/README.md` |

**3.B — Técnica ofensiva (15 pts)**

Cadena de ataque de nivel **avanzado**: RustScan → Nmap → WhatWeb → Dirsearch → Nuclei → FTP anónimo → WP user enum.

| Criterio | Pts | Evidencia real |
|----------|-----|----------------|
| Técnica ejecutada con evidencia | 6 | 19 archivos en `offensive/evidencia/`; 9 hallazgos documentados |
| Interpretación técnica correcta | 5 | Análisis por paso en `parte3-black-hat-bash/README.md` |
| Nivel/ambición de la técnica | 4 | Nivel avanzado: Nuclei (3 HIGH, 2 MEDIUM), `.git` expuesto, RCE potencial |

**Hallazgos principales:**

| Severidad | Vulnerabilidad | Host |
|-----------|---------------|------|
| ALTA | FTP anónimo habilitado (vsftpd 3.0.3) | 172.28.10.11:21 |
| ALTA | Repositorios `.git` expuestos vía HTTP (×2) | 172.28.10.11:80 |
| ALTA | Endpoint `/upload` sin autenticación (Flask) | 172.28.10.10:8081 |
| MEDIA | Directory indexing en `/backup/` (Apache) | 172.28.10.11:80 |
| MEDIA | SSH con autenticación por contraseña | 172.28.10.13:22 |
| MEDIA | Enumeración de usuarios WordPress (`jtorres`) | 172.28.10.10:80 |

Documentación completa: [`parte3-black-hat-bash/README.md`](parte3-black-hat-bash/README.md) · [`offensive/tecnica.md`](parte3-black-hat-bash/offensive/tecnica.md)

### Documentación y repositorio (10 pts)

| Criterio | Evidencia |
|----------|-----------|
| README principal | Este archivo |
| README por cada parte | Carpetas `parte1/`, `parte2/`, `parte3/` |
| Evidencia reproducible | `docs/evidencias/`, comandos en cada README |
| Historial de commits claro | Convención en `CONTRIBUTING.md` |

---

## Evidencias y demostración

| Entregable | Ubicación |
|------------|-----------|
| Video Parte 1 (detalle) | [parte1-distro-linux/demo/enlaces.md](parte1-distro-linux/demo/enlaces.md) |
| SHA256 de la ISO | [docs/evidencias/parte1/](docs/evidencias/parte1/) |
| Capturas QEMU (Parte 2) | [docs/evidencias/parte2/](docs/evidencias/parte2/) |
| Salida `make test` (Parte 3) | [docs/evidencias/parte3/](docs/evidencias/parte3/) |
| Archivos de evidencia ofensiva (19 archivos) | [parte3-black-hat-bash/offensive/evidencia/](parte3-black-hat-bash/offensive/evidencia/) |
| Lista completa | [docs/evidencias/lista-evidencias.md](docs/evidencias/lista-evidencias.md) |

---

Detalle en [CONTRIBUTING.md](CONTRIBUTING.md).

---



---

## Licencia

GPL-3.0 — ver [LICENSE](LICENSE).
