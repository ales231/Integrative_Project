# Instrucciones de build — Cubic

## 1. Preparación

1. Instalar Cubic: `sudo apt install cubic` (Ubuntu/Mint).
2. Descargar ISO base oficial (misma arquitectura: amd64).
3. Clonar este repositorio.

## 2. Flujo en Cubic

1. **Project location:** carpeta temporal fuera del repo (ej. `~/cubic-build`).
2. **Original ISO:** seleccionar ISO base descargada.
3. **Extract:** esperar extracción del sistema de archivos.
4. **Terminal / Customization:**
   - Copiar `../skel/*` → `/etc/skel/`
   - Ejecutar scripts de `../cubic/scripts/` en orden
   - Instalar paquetes de `../cubic/packages.list`
5. **Generate:** guardar ISO en `parte1-distro-linux/build/`.

## 3. Post-build

```bash
cd parte1-distro-linux/build
sha256sum *.iso | tee ../../docs/evidencias/parte1/SHA256SUMS
```

## 4. Prueba

Boot en VirtualBox o QEMU. Crear usuario nuevo y verificar personalizaciones.

**La carpeta `build/` está en `.gitignore`. No commitear la ISO.**
