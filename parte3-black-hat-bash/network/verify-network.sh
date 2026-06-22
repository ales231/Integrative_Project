#!/bin/bash
# network/verify-network.sh — Pruebas de conectividad entre redes
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

echo "=== Verificación de redes ==="

check() {
    local desc="$1"
    shift
    if docker compose exec -T attacker "$@" >/dev/null 2>&1; then
        echo "OK: ${desc}"
        return 0
    fi
    echo "FAIL: ${desc}"
    return 1
}

FAIL=0

check "attacker → victim-web (dmz)" \
    curl -fsS --max-time 5 http://victim-web/ \
    || FAIL=$((FAIL + 1))

check "attacker → victim-ftp (dmz)" \
    curl -fsS --max-time 5 http://172.28.10.11/ \
    || FAIL=$((FAIL + 1))

check "attacker → jumpbox SSH (dmz)" \
    bash -c 'timeout 3 bash -c "</dev/tcp/jumpbox/22"' \
    || FAIL=$((FAIL + 1))

# victim-db en red internal no debe ser alcanzable desde attacker (solo dmz)
if docker compose exec -T attacker timeout 3 bash -c 'cat < /dev/null > /dev/tcp/172.28.20.15/5432' 2>/dev/null; then
    echo "FAIL: attacker alcanzó victim-db (debería estar segmentado)"
    FAIL=$((FAIL + 1))
else
    echo "OK: attacker → victim-db bloqueado (red internal)"
fi

if [[ "${FAIL}" -gt 0 ]]; then
    echo "FAIL: ${FAIL} prueba(s) de red fallaron"
    exit 1
fi

echo "OK: verificación de redes completada"
