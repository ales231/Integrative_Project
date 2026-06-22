# Evidencias del proyecto

Capturas, logs y checksums para el evaluador. Los videos y archivos pesados
van por enlace externo; aquí solo referencias y pruebas ligeras.

**Lista completa:** [lista-evidencias.md](lista-evidencias.md)

## Convención de nombres

```
YYYY-MM-DD_<parte>_<descripcion>.<ext>
```

Ejemplos:

- `2026-06-22_parte1_checksum-sha256.txt`
- `2026-06-23_parte2_qemu-episode1-ok.png`
- `2026-06-24_parte3_make-test-output.log`

## Por parte

| Carpeta | Contenido esperado |
|---------|-------------------|
| [parte1/](parte1/) | SHA256 de ISO, capturas de boot, guion cumplido |
| [parte2/](parte2/) | Screenshots QEMU, log de `make build` |
| [parte3/](parte3/) | Salida de `make test`, capturas del ataque |

## No subir a Git

- Videos (`.mp4`, `.mkv`) → enlace en `parte1-distro-linux/demo/enlaces.md`
- ISO completa → solo checksum en `parte1/`
- PCAPs grandes → enlace o extracto; ver `.gitignore`
