# Topología de red — Black Hat Bash

## Redes Docker

| Red | Subred | Internal | Propósito |
|-----|--------|----------|-----------|
| `dmz` | 172.28.10.0/24 | no | Atacante, web, FTP (cara pública), jumpbox |
| `internal` | 172.28.20.0/24 | sí | DB, DNS, mail, monitor, backend FTP |

## Direcciones IP asignadas

| Contenedor | dmz | internal |
|------------|-----|----------|
| attacker | 172.28.10.2 | — |
| victim-web | 172.28.10.10 | — |
| victim-ftp | 172.28.10.11 | 172.28.20.11 |
| jumpbox | 172.28.10.13 | 172.28.20.12 |
| victim-db | — | 172.28.20.15 |
| dns | — | 172.28.20.53 |
| mail | — | 172.28.20.25 |
| monitor | — | 172.28.20.30 |

## Matriz de conectividad

| Origen → Destino | dmz | internal | Notas |
|------------------|-----|----------|-------|
| attacker → victim-web | ✓ | — | HTTP 80 / Flask 8081 |
| attacker → victim-ftp | ✓ | — | FTP 21 + HTTP 80 (IP dmz) |
| attacker → victim-db | ✗ | — | Solo red internal |
| attacker → jumpbox | ✓ | — | SSH 22 |
| jumpbox → victim-db | ✓ | ✓ | Pivot desde bastión |
| victim-web → victim-db | — | ✓ | Backend legítimo (futuro) |

Verificación automatizada: `network/verify-network.sh`
