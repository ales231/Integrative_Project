#!/bin/bash
# cubic/scripts/05-browser-and-alternatives.sh
# Navegador por defecto a nivel de sistema (antes del primer login).
set -euo pipefail

echo "[05-browser-and-alternatives] Configurar LibreWolf como navegador predeterminado..."

if [[ -x /usr/bin/librewolf ]]; then
  update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/librewolf 200
  update-alternatives --set x-www-browser /usr/bin/librewolf
fi

# Evitar que el instalador de Mint vuelva a ofrecer Firefox en sesiones live
if [[ -f /etc/skel/.mozilla/firefox/profiles.ini ]]; then
  rm -rf /etc/skel/.mozilla
fi

echo "[05-browser-and-alternatives] Listo."
