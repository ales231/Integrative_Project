#!/bin/bash
# tests/test-offensive.sh — Ejecuta playbook y valida evidencia mínima
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVID_DIR="${ROOT}/offensive/evidencia"
LAB_MODE="${LAB_MODE:-integrative}"

cd "${ROOT}"

echo "=== Test ofensivo (modo: ${LAB_MODE}) ==="

if ! docker compose ps --status running -q attacker >/dev/null 2>&1; then
    echo "FAIL: contenedor attacker no está en ejecución"
    exit 1
fi

docker compose exec -T -e LAB_MODE="${LAB_MODE}" attacker \
    bash /lab/offensive/exploit.sh

REQUIRED=(
    "00-RESUMEN.txt"
    "01-rustscan-subred.txt"
    "03-nmap-servicios.gnmap"
    "04-nmap-ftp-anon.txt"
    "06-whatweb-web01.txt"
    "17-ftp-anon-listado.txt"
)

MISSING=0
for f in "${REQUIRED[@]}"; do
    if [[ ! -f "${EVID_DIR}/${f}" ]]; then
        echo "FAIL: falta evidencia ${f}"
        MISSING=$((MISSING + 1))
    fi
done

if [[ "${MISSING}" -gt 0 ]]; then
    echo "FAIL: ${MISSING} archivo(s) de evidencia requeridos ausentes"
    exit 1
fi

# Validar hallazgo FTP anónimo
if ! grep -qiE 'anonymous|230 Login|backup' "${EVID_DIR}/17-ftp-anon-listado.txt" 2>/dev/null; then
    echo "FAIL: no se detectó acceso FTP anónimo en la evidencia"
    exit 1
fi

# Validar RustScan encontró al menos un puerto
if ! grep -qE '->|Open |open' "${EVID_DIR}/01-rustscan-subred.txt" 2>/dev/null; then
    echo "WARN: RustScan no reportó puertos (revisar manualmente)"
fi

echo "OK: playbook ofensivo ejecutado y evidencia mínima validada"
echo "Evidencias en: ${EVID_DIR}/"
