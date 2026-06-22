# Topología de red — Black Hat Bash

## Redes Docker

| Red | Driver | Internal | Propósito |
|-----|--------|----------|-----------|
| `dmz` | bridge | no | Servicios expuestos / atacante |
| `internal` | bridge | sí | Backend sin salida directa a Internet |

## Matriz de conectividad esperada

| Origen → Destino | dmz | internal | Notas |
|------------------|-----|----------|-------|
| attacker → victim-web | ✓ | — | Escaneo / explotación web |
| attacker → victim-db | ✗ | — | Debe fallar desde dmz |
| jumpbox → internal | ✓ | ✓ | Pivot |
| victim-web → victim-db | ✓ | ✓ | Backend legítimo |

Actualizar tras implementar `docker-compose.yml`.
