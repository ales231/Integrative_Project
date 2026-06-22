# Instrucciones de build — Cubic + Linux Mint Cinnamon

## 1. Preparación en el host

```bash
sudo apt update
sudo apt install cubic rsync git
# Descargar ISO: https://linuxmint.com/download.php
# Elegir edición Cinnamon, amd64
```

## 2. Flujo en Cubic

1. **Project location:** carpeta temporal (ej. `~/cubic-build-mint`).
2. **Original ISO:** ISO de Linux Mint Cinnamon descargada.
3. **Extract:** esperar a que Cubic monte el chroot.
4. **Terminal (customization)** — copiar repo y ejecutar scripts:

```bash
mkdir -p /root/custom
cp -a /ruta/completa/Integrative_Project/parte1-distro-linux/* /root/custom/

export CUSTOM_ROOT=/root/custom
chmod +x "${CUSTOM_ROOT}/cubic/scripts/"*.sh

bash "${CUSTOM_ROOT}/cubic/scripts/04-repos-and-packages.sh"
bash "${CUSTOM_ROOT}/cubic/scripts/02-skel-setup.sh"
bash "${CUSTOM_ROOT}/cubic/scripts/03-gschema.sh"
bash "${CUSTOM_ROOT}/cubic/scripts/05-browser-and-alternatives.sh"
```

5. **Generate:** guardar la ISO en `parte1-distro-linux/build/`.

> **Red:** los scripts 04 y 05 requieren Internet para descargar claves GPG y paquetes.

## 3. Post-build

```bash
cd parte1-distro-linux/build
sha256sum *.iso | tee ../../docs/evidencias/parte1/SHA256SUMS
```

## 4. Prueba en VM

1. Arrancar la ISO en VirtualBox/QEMU.
2. Instalar o usar sesión live.
3. Crear usuario **nuevo** (`testuser`) y verificar checklist del README.
4. Grabar evidencias en `docs/evidencias/parte1/`.

**La carpeta `build/` está en `.gitignore`. No commitear la ISO.**
