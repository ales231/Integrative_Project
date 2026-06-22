# Evidencias — Parte 3 (Black Hat Bash)

Colocar aquí capturas y copias para el evaluador.

## Generación automática

```bash
cd parte3-black-hat-bash
make deploy
make test
cp -r offensive/evidencia/* docs/evidencias/parte3/
```

## Capturas recomendadas

1. Salida de `make test` completa
2. `01-rustscan-subred.txt` — puertos descubiertos
3. `04-nmap-ftp-anon.txt` — FTP anónimo
4. `09-dirsearch-web01.txt` — `/upload`
5. `10-dirsearch-git-impact.txt` — `/.git`
6. `17-ftp-anon-listado.txt` — carpeta `backup`
7. Navegador en `http://localhost:8080` (victim-web)
8. Navegador en `http://172.28.10.11/backup` (directory indexing, desde attacker)

## Checksum (opcional)

```bash
sha256sum offensive/evidencia/* > docs/evidencias/parte3/SHA256SUMS
```
