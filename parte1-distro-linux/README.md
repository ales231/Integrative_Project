# Parte 1 — Distro Linux personalizada (Cubic)

**Puntos:** 25 · **Responsable:** [Nombre B]

ISO personalizada basada en Ubuntu o Linux Mint, con modificaciones persistentes
mediante `/etc/skel` y `gschema`.

## Base elegida

| Campo | Valor |
|-------|-------|
| Distribución base | [Ubuntu 24.04 LTS / Linux Mint 22] |
| Justificación | [Por qué esta base] |
| Versión Cubic | [X.Y] |

## Requisitos

- Cubic instalado en host con GUI
- ISO base descargada (no incluida en el repo)
- ~8 GB espacio para el build
- VM (VirtualBox/QEMU) para verificar boot

## Modificaciones (mínimo 3)

| # | Modificación | Mecanismo | Archivos en repo | Justificación |
|---|--------------|-----------|------------------|---------------|
| 1 | Branding (nombre, wallpaper) | `/etc/skel` + `assets/` | `skel/`, `assets/` | Identidad del proyecto |
| 2 | Paquetes preinstalados | `cubic/packages.list` | `cubic/packages.list` | Entorno dev listo |
| 3 | Escritorio persistente | `gschema` overrides | `gschema/` | Personalización Cinnamon/GNOME |
| 4 | (Opcional) MOTD / bienvenida | `/etc/skel/.bashrc` | `skel/.bashrc` | Demostración en video |

## Build con Cubic

1. Abrir Cubic y seleccionar la ISO base.
2. En la fase de personalización, copiar contenido de `skel/` → `/etc/skel`.
3. Ejecutar scripts de `cubic/scripts/` en el orden numérico.
4. Aplicar overrides de `gschema/` según [gschema/README.md](gschema/README.md).
5. Generar ISO y guardar en `build/` (carpeta ignorada por Git).
6. Registrar checksum: `sha256sum build/*.iso > ../../docs/evidencias/parte1/SHA256SUMS`

Instrucciones detalladas: [build/INSTRUCCIONES-BUILD.md](build/INSTRUCCIONES-BUILD.md).

## Verificación

- [ ] La ISO bootea en VM sin errores
- [ ] Usuario nuevo recibe configuración de `skel`
- [ ] Cambios `gschema` visibles tras login
- [ ] Las 3+ modificaciones son demostrables

## Video de demostración

- Guion: [demo/guion-video.md](demo/guion-video.md)
- Enlace: [demo/enlaces.md](demo/enlaces.md)

## Estructura de esta parte

```
parte1-distro-linux/
├── README.md
├── cubic/
│   ├── packages.list
│   └── scripts/
├── skel/
├── gschema/
├── assets/
├── build/          # ISO generada (NO en Git)
└── demo/
```

## Nota sobre la ISO

La ISO **no se sube a Git**. Solo checksum y evidencias en
[docs/evidencias/parte1/](../docs/evidencias/parte1/).
