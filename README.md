# Proyecto Integrador — Ingeniería en Sistemas

**Equipo:** [Nombre 1], [Nombre 2], [Nombre 3], [Nombre 4]
**Curso:** [Asignatura]
**Período:** [Año-Semestre]
**Docente:** [Nombre del docente]

Proyecto integrador en tres partes: distro Linux personalizada con Cubic, kernel
x86_64 desde cero y laboratorio ofensivo con Docker. Todo el material es
reproducible desde este repositorio.

## Índice de partes

| Parte | Puntos | Carpeta | Estado |
|-------|--------|---------|--------|
| 1 — Distro Linux (Cubic) | 25 | [parte1-distro-linux/](parte1-distro-linux/) | Pendiente |
| 2 — Kernel x86_64 | 30 | [parte2-kernel-x86_64/](parte2-kernel-x86_64/) | Pendiente |
| 3 — Black Hat Bash | 35 | [parte3-black-hat-bash/](parte3-black-hat-bash/) | Pendiente |
| Documentación y repo | 10 | Este README + [docs/](docs/) | En progreso |

## Requisitos globales

| Herramienta | Parte | Versión mínima sugerida |
|-------------|-------|-------------------------|
| Git | Todas | 2.40+ |
| Docker + Docker Compose | 2, 3 | 24+ / v2 |
| QEMU | 2 | 8.0+ |
| Cubic (GUI) | 1 | Última estable |
| NASM, GCC (cross) | 2 | vía Docker |
| Make | 2, 3 | 4.3+ |

Espacio en disco recomendado: **20 GB** libres para builds e ISO.

## Inicio rápido

```bash
# Parte 2 — Kernel
cd parte2-kernel-x86_64
make build
make run

# Parte 3 — Laboratorio ofensivo
cd parte3-black-hat-bash
cp .env.example .env
make deploy
make test
```

La Parte 1 requiere Cubic en máquina host con interfaz gráfica. Ver
[parte1-distro-linux/README.md](parte1-distro-linux/README.md).

## Estructura del repositorio

```
Integrative_Project/
├── README.md                    # Este archivo
├── LICENSE
├── CONTRIBUTING.md              # Convenciones de commits y ramas
├── docs/                        # Rúbrica, cronograma, equipo, evidencias
├── parte1-distro-linux/         # ISO personalizada (Cubic)
├── parte2-kernel-x86_64/        # Kernel Multiboot2 + GRUB + QEMU
├── parte3-black-hat-bash/         # 8 contenedores + técnica ofensiva
└── scripts/                     # Verificación global del repo
```

## Evidencias y demostración

| Entregable | Ubicación |
|------------|-----------|
| Video Parte 1 | [parte1-distro-linux/demo/enlaces.md](parte1-distro-linux/demo/enlaces.md) |
| SHA256 de la ISO | [docs/evidencias/parte1/](docs/evidencias/parte1/) |
| Capturas QEMU (Parte 2) | [docs/evidencias/parte2/](docs/evidencias/parte2/) |
| Salida `make test` (Parte 3) | [docs/evidencias/parte3/](docs/evidencias/parte3/) |

## Convenciones de commits

Formato: `parte{N}|docs|chore: <tipo>: <descripción>`

Ejemplos:

- `parte1: feat: agregar overrides gschema para Cinnamon`
- `parte2: feat: implementar paging y transición a long mode`
- `parte3: test: automatizar verificación de 8 contenedores`
- `docs: evidencia: capturas QEMU episode 1`

Detalle completo en [CONTRIBUTING.md](CONTRIBUTING.md).

## Equipo y responsabilidades

Ver [docs/equipo.md](docs/equipo.md).

## Licencia

GPL-3.0 — ver [LICENSE](LICENSE).
