# Servicio: attacker

Imagen con herramientas ofensivas: **nmap**, **rustscan**, **whatweb**, **dirsearch**, **nuclei**, **lftp**.

- Red: `dmz` (`172.28.10.2`)
- Volumen: `./offensive` montado en `/lab/offensive`

```bash
docker compose exec attacker bash
bash /lab/offensive/exploit.sh
```
