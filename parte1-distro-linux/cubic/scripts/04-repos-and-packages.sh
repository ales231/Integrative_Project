#!/bin/bash
# cubic/scripts/04-repos-and-packages.sh
# Ejecutar dentro del chroot de Cubic, después de copiar el repo a /root/custom/
set -euo pipefail

CUSTOM_ROOT="${CUSTOM_ROOT:-/root/custom}"
PACKAGES_FILE="${CUSTOM_ROOT}/cubic/packages.list"

echo "[04-repos-and-packages] Configurar repositorios e instalar paquetes..."

export DEBIAN_FRONTEND=noninteractive

# --- Visual Studio Code (Microsoft) ---
install -d -m 0755 /usr/share/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor -o /usr/share/keyrings/packages-microsoft.gpg
cat > /etc/apt/sources.list.d/vscode.list <<'EOF'
deb [arch=amd64 signed-by=/usr/share/keyrings/packages-microsoft.gpg] https://packages.microsoft.com/repos/code stable main
EOF

# --- LibreWolf ---
curl -fsSL https://deb.librewolf.net/keyring.gpg \
  | gpg --dearmor -o /usr/share/keyrings/librewolf.gpg
CODENAME="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"
cat > /etc/apt/sources.list.d/librewolf.list <<EOF
deb [signed-by=/usr/share/keyrings/librewolf.gpg arch=amd64] https://deb.librewolf.net ${CODENAME} main
EOF

apt-get update

# Paquetes del listado del repo
if [[ -f "${PACKAGES_FILE}" ]]; then
  mapfile -t PKG_LINES < <(grep -v '^\s*#' "${PACKAGES_FILE}" | grep -v '^\s*$' || true)
  if ((${#PKG_LINES[@]})); then
    apt-get install -y "${PKG_LINES[@]}"
  fi
fi

apt-get install -y code librewolf

# Quitar Firefox (reemplazo por LibreWolf)
apt-get remove -y --purge firefox firefox-locale-en firefox-locale-es 2>/dev/null || true
apt-get autoremove -y

echo "[04-repos-and-packages] Listo."
