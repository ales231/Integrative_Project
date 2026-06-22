#!/bin/bash
# cubic/scripts/02-skel-setup.sh
# Copia la plantilla de usuario desde el staging del repo hacia /etc/skel.
set -euo pipefail

CUSTOM_ROOT="${CUSTOM_ROOT:-/root/custom}"
SKEL_SRC="${CUSTOM_ROOT}/skel"

echo "[02-skel-setup] Configurar /etc/skel desde ${SKEL_SRC}..."

if [[ ! -d "${SKEL_SRC}" ]]; then
  echo "ERROR: no existe ${SKEL_SRC}. Copia el repo a /root/custom/ antes de ejecutar." >&2
  exit 1
fi

# Preservar archivos base de Mint/Ubuntu y fusionar los nuestros encima
rsync -a "${SKEL_SRC}/" /etc/skel/

# Permisos coherentes para plantilla de usuario
chown -R root:root /etc/skel
find /etc/skel -type d -exec chmod 755 {} \;
find /etc/skel -type f -exec chmod 644 {} \;

# Scripts ejecutables en skel (si los hay)
[[ -f /etc/skel/.local/bin/welcome ]] && chmod 755 /etc/skel/.local/bin/welcome

# Añadir fragmentos al .bashrc de plantilla sin sobrescribir el de Mint
if [[ -f "${SKEL_SRC}/.bashrc.append" ]]; then
  MARKER="# integrative-project-skel"
  if ! grep -qF "${MARKER}" /etc/skel/.bashrc 2>/dev/null; then
    {
      echo ""
      echo "${MARKER}"
      cat "${SKEL_SRC}/.bashrc.append"
    } >> /etc/skel/.bashrc
  fi
fi

echo "[02-skel-setup] Listo."
