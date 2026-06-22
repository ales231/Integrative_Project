#!/bin/bash
# cubic/scripts/00-stage-repo.sh
# Copia el contenido del repo desde el host al chroot (ejecutar primero).
# Ajusta HOST_REPO si montas el proyecto en otra ruta.
set -euo pipefail

HOST_REPO="${HOST_REPO:-/media/$(whoami)/*/Integrative_Project/parte1-distro-linux}"
CUSTOM_ROOT="/root/custom"

echo "[00-stage-repo] Buscando repo en el host..."

# En Cubic, el proyecto suele estar accesible vía bind; si no, copiar manualmente:
#   cp -a /ruta/en/host/parte1-distro-linux /root/custom
if compgen -G "${HOST_REPO}" > /dev/null; then
  HOST_REPO="$(ls -d ${HOST_REPO} 2>/dev/null | head -1)"
fi

if [[ ! -d "${HOST_REPO}/cubic" ]]; then
  echo "Copia manualmente el repo a ${CUSTOM_ROOT} y vuelve a ejecutar." >&2
  echo "  mkdir -p ${CUSTOM_ROOT}" >&2
  echo "  cp -a /ruta/parte1-distro-linux/* ${CUSTOM_ROOT}/" >&2
  exit 1
fi

mkdir -p "${CUSTOM_ROOT}"
rsync -a --delete "${HOST_REPO}/" "${CUSTOM_ROOT}/"
echo "[00-stage-repo] Repo disponible en ${CUSTOM_ROOT}"
