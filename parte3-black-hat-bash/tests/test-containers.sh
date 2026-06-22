#!/bin/bash
# tests/test-containers.sh — Verifica que los 8 contenedores estén Up
set -euo pipefail

EXPECTED=8
RUNNING=$(docker compose ps -q | wc -l)

if [ "$RUNNING" -lt "$EXPECTED" ]; then
    echo "FAIL: esperados $EXPECTED contenedores, encontrados $RUNNING"
    exit 1
fi

echo "OK: $RUNNING contenedores en ejecución"
