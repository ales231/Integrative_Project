# Guía de contribución

Este documento define convenciones de nombres, ramas y commits para que cada
integrante deje evidencia clara de su trabajo (rúbrica: documentación y repo).

## Integrantes y prefijos de autor

| Integrante | Rol | Prefijo commit (opcional) | Ramas principales |
|------------|-----|---------------------------|-------------------|
| [Nombre A] | DevOps / Integración | `a:` | `main`, `scripts/*` |
| [Nombre B] | Sistemas / Linux (Parte 1) | `b:` | `parte1/*` |
| [Nombre C] | Bajo nivel (Parte 2) | `c:` | `parte2/*` |
| [Nombre D] | Seguridad / Redes (Parte 3) | `d:` | `parte3/*` |

## Convención de nombres

### Carpetas y archivos

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Carpetas de parte | `parte{N}-<tema-kebab>` | `parte2-kernel-x86_64` |
| Scripts shell | `kebab-case.sh` | `verify-network.sh` |
| Fuentes ASM | `snake_case.asm` | `boot.asm`, `header.asm` |
| Fuentes C | `snake_case.c` | `main.c`, `vga.c` |
| Headers C | `snake_case.h` | `gdt.h` |
| Docker | `Dockerfile`, `docker-compose.yml` | — |
| Documentación | `UPPER.md` o `kebab-case.md` | `README.md`, `tecnica.md` |
| Evidencias | `YYYY-MM-DD_descripcion.ext` | `2026-06-22_qemu-ok.png` |
| Servicios Docker | nombre corto en minúsculas | `attacker/`, `victim-web/` |

### Ramas

```
main                          # Entrega estable
parte1/<tarea>                # Ej: parte1/gschema-overrides
parte2/<tarea>                # Ej: parte2/episode1-vga-ok
parte3/<tarea>                # Ej: parte3/network-verification
docs/<tarea>                  # Ej: docs/evidencias-parte2
```

Flujo: rama de feature → Pull Request (o merge directo si el equipo acuerda) → `main`.

## Convención de commits

### Formato obligatorio

```
parte{N}|docs|chore|scripts: <tipo>: <descripción en imperativo>
```

### Tipos permitidos

| Tipo | Uso |
|------|-----|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de error |
| `docs` | Solo documentación |
| `test` | Pruebas o scripts de verificación |
| `chore` | Mantenimiento, .gitignore, estructura |
| `refactor` | Cambio sin alterar comportamiento |
| `evidencia` | Capturas, logs, checksums en `docs/evidencias/` |

### Ejemplos por integrante

```text
parte1: feat: agregar wallpaper y tema en /etc/skel
parte1: docs: documentar modificacion 3 (gschema)
parte1: evidencia: checksum SHA256 de ISO final

parte2: feat: episode 1 imprimir OK por VGA
parte2: feat: configurar GDT y paging para long mode
parte2: fix: corregir alineacion Multiboot2 header

parte3: feat: agregar contenedor victim-ftp en red internal
parte3: test: script verify-network.sh con 8 contenedores
parte3: docs: documentar tecnica ofensiva en offensive/tecnica.md

docs: chore: actualizar cronograma dia 4
scripts: feat: agregar verify-all.sh
```

## Estrategia de commits para evidencia de trabajo

### Reglas del equipo

1. **Mínimo 5 commits significativos por integrante** en su parte principal.
2. **Nunca un solo commit gigante** el día de entrega; el historial debe mostrar progresión.
3. **Commits atómicos**: un cambio lógico por commit.
4. **Autor real**: cada persona commitea desde su cuenta de GitHub/GitLab.
5. **Evidencias en commits separados** con tipo `evidencia` para facilitar revisión.

### Plantilla de progresión sugerida (Parte 2, ejemplo)

```text
parte2: chore: estructura inicial Dockerfile y Makefile
parte2: feat: header Multiboot2 y boot.asm
parte2: feat: episode 1 salida OK en QEMU
parte2: feat: GDT y transicion a long mode
parte2: feat: paging e integracion con main.c
parte2: feat: generar kernel.iso con GRUB
parte2: test: script run-qemu.sh
parte2: evidencia: captura QEMU mostrando OK
```

### Tag de entrega final

```bash
git tag -a v1.0-entrega -m "Entrega final proyecto integrador"
git push origin v1.0-entrega
```

## Qué NO commitear

Ver [.gitignore](.gitignore). Resumen:

- Archivos `.iso`, `.img`, binarios compilados (`.o`, `.bin`, `.elf`)
- `.env` con credenciales reales
- Videos (subir enlace externo)
- PCAPs grandes (opcional: solo enlace o muestra reducida)
- Carpetas de IDE (`.vscode/`, `.idea/`) salvo configuración compartida acordada

## Qué SÍ commitear

- Todo el código fuente, scripts, Dockerfiles, `docker-compose.yml`
- READMEs y documentación en `docs/`
- `.env.example` (sin secretos)
- Capturas PNG/JPG de evidencia (tamaño razonable, < 2 MB c/u)
- Checksums (`SHA256SUMS`) de artefactos generados
- Guiones de video y enlaces en `demo/enlaces.md`

## Revisión antes de merge a main

- [ ] El README de la parte está actualizado
- [ ] `make build` / `make deploy` / instrucciones Cubic funcionan
- [ ] No hay secretos ni binarios pesados
- [ ] El mensaje de commit sigue la convención
