#!/bin/bash
# cubic/scripts/03-gschema.sh
# Compila overrides de gschema para valores por defecto del escritorio Cinnamon.
set -euo pipefail

CUSTOM_ROOT="${CUSTOM_ROOT:-/root/custom}"
GSCHEMA_SRC="${CUSTOM_ROOT}/gschema"

echo "[03-gschema] Aplicar overrides dconf/gsettings..."

if [[ -d "${GSCHEMA_SRC}" ]]; then
  install -m 0644 "${GSCHEMA_SRC}"/*.gschema.override /usr/share/glib-2.0/schemas/ 2>/dev/null || true
fi

glib-compile-schemas /usr/share/glib-2.0/schemas/

echo "[03-gschema] Listo."
