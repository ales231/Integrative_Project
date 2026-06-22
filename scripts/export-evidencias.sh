#!/bin/bash
# scripts/export-evidencias.sh — Empaqueta evidencias ligeras para entrega
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/docs/evidencias"
ARCHIVE="evidencias-$(date +%Y%m%d).tar.gz"

cd "$ROOT"
tar -czvf "$ARCHIVE" \
    --exclude='*.iso' \
    --exclude='*.pcap' \
    --exclude='*.mp4' \
    docs/evidencias/

echo "Archivo generado: $ARCHIVE"
echo "Subir solo si el tamaño es aceptable para el curso; preferir enlaces para videos."
