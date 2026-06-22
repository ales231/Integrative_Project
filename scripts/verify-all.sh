#!/bin/bash
# scripts/verify-all.sh — Smoke test global del repositorio
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0

echo "========================================"
echo " Verificación global — Integrative_Project"
echo "========================================"

check_dir() {
    if [ -d "$1" ]; then
        echo "  OK  directorio: $2"
    else
        echo "  FAIL directorio: $2"
        FAILED=1
    fi
}

check_file() {
    if [ -f "$1" ]; then
        echo "  OK  archivo: $2"
    else
        echo "  FAIL archivo: $2"
        FAILED=1
    fi
}

echo ""
echo "[Documentación]"
check_file "$ROOT/README.md" "README.md"
check_file "$ROOT/CONTRIBUTING.md" "CONTRIBUTING.md"
check_dir  "$ROOT/docs/evidencias" "docs/evidencias"

echo ""
echo "[Parte 1]"
check_file "$ROOT/parte1-distro-linux/README.md" "parte1 README"

echo ""
echo "[Parte 2]"
check_file "$ROOT/parte2-kernel-x86_64/Makefile" "parte2 Makefile"
check_file "$ROOT/parte2-kernel-x86_64/Dockerfile" "parte2 Dockerfile"

echo ""
echo "[Parte 3]"
check_file "$ROOT/parte3-black-hat-bash/Makefile" "parte3 Makefile"
check_file "$ROOT/parte3-black-hat-bash/docker-compose.yml" "docker-compose.yml"

echo ""
if [ "$FAILED" -eq 0 ]; then
    echo "RESULTADO: estructura base OK"
    exit 0
else
    echo "RESULTADO: faltan elementos — revisar arriba"
    exit 1
fi
