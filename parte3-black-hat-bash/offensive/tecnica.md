# Técnica ofensiva — Documentación

## Metadatos

| Campo | Valor |
|-------|-------|
| Técnica | RustScan + Nmap + WhatWeb + Dirsearch + Nuclei + FTP anónimo |
| Referencia | Black Hat Bash (Farhi & Aleks), Cap. 4–5 |
| Puntuación objetivo | 15/15 — sección hacking |
| Entorno | Docker Compose (`make deploy`) |

## Objetivo del laboratorio

Demostrar una cadena de ataque de **reconocimiento activo** y **enumeración**
en una red segmentada (DMZ + internal), con evidencia reproducible de:

- Superficie de ataque (puertos y servicios)
- Tecnologías web y rutas ocultas
- Vulnerabilidades automatizadas (Nuclei)
- Acceso no autorizado controlado (FTP anónimo)

## Topología de objetivos (modo integrative)

| IP / Host | Rol | Puertos |
|-----------|-----|---------|
| `172.28.10.10` / victim-web | Flask + WordPress simulado | 80, 8081 |
| `172.28.10.11` / victim-ftp | vsFTPd + Apache `/backup` | 21, 80 |
| `172.28.10.13` / jumpbox | SSH bastión | 22 |
| `172.28.20.15` / victim-db | PostgreSQL (solo internal) | 5432 |

El atacante (`172.28.10.2`) está solo en **dmz** y no alcanza la base de datos
en **internal** (segmentación verificada con `network/verify-network.sh`).

## Pasos ejecutados

### 1. Reconocimiento — RustScan + Nmap

```bash
docker compose exec attacker bash /lab/offensive/exploit.sh
```

Comandos equivalentes manuales:

```bash
rustscan -g -a 172.28.10.0/24 -r 1-65535
rustscan -g -a 172.28.10.0/24 -- -sV -sC --open -oA evidencia/02-rustscan-nmap
nmap -sV -sC --open -iL evidencia/targets-integrative.txt -oA evidencia/03-nmap-servicios
nmap -p21 --script ftp-anon,ftp-syst 172.28.10.11
nmap --script ssh-auth-methods -p22 172.28.10.13
```

### 2. Fingerprinting — WhatWeb

```bash
whatweb -v http://victim-web:8081
whatweb -v http://172.28.10.11/
whatweb -v http://victim-web/
```

### 3. Enumeración — Dirsearch

```bash
dirsearch -u http://victim-web:8081/
dirsearch -u http://172.28.10.11/backup/acme-impact-alliance/
dirsearch -u http://172.28.10.11/backup/acme-hyper-branding/
dirsearch -u http://victim-web/ -e php,html,txt
```

### 4. Vulnerabilidades — Nuclei

```bash
nuclei -u http://victim-web:8081 -severity medium,high,critical
nuclei -tags apache,git -u http://172.28.10.11
nuclei -tags wordpress -u http://victim-web
nuclei -tags ftp -u 172.28.10.11 -silent
```

### 5. Explotación controlada — FTP anónimo

```bash
lftp -u anonymous, -e "ls -la; cd backup; ls -la; bye" 172.28.10.11
curl -s "http://victim-web/?rest_route=/wp/v2/users" | jq
```

## Hallazgos esperados

| Hallazgo | Severidad | Herramienta |
|----------|-----------|-------------|
| Puertos 21/80/8081/22 abiertos | Info | RustScan / Nmap |
| FTP anónimo (`anonymous_enable=YES`) | Alta | Nmap / Nuclei / lftp |
| Directory indexing en `/backup/` | Media | Dirsearch / curl |
| Repositorio `.git` expuesto | Alta | Dirsearch / Nuclei |
| Endpoints `/upload`, `/uploads` | Media | Dirsearch |
| Enumeración usuarios WP (`jtorres`) | Media | Nuclei / curl |
| SSH con autenticación por contraseña | Media | Nmap NSE |

## Evidencia

Salidas automáticas en:

- `offensive/evidencia/` — generadas por `exploit.sh`
- `docs/evidencias/parte3/` — capturas y copias para el evaluador

Archivos clave:

| Archivo | Contenido |
|---------|-----------|
| `01-rustscan-subred.txt` | Puertos abiertos por host |
| `03-nmap-servicios.*` | Versiones de servicios |
| `04-nmap-ftp-anon.txt` | Script `ftp-anon` |
| `09-dirsearch-web01.txt` | Rutas `/upload` |
| `10-dirsearch-git-impact.txt` | `/.git/config` |
| `17-ftp-anon-listado.txt` | Listado `backup/` |
| `18-wp-user-enum.json` | Usuario `jtorres` |

## Mitigación

| Hallazgo | Mitigación |
|----------|------------|
| FTP anónimo | Deshabilitar `anonymous_enable`; usar SFTP + MFA |
| Directory indexing | `Options -Indexes` en Apache |
| `.git` expuesto | Denegar `/.git` en el servidor web |
| WP user enum | Restringir REST API; actualizar WordPress |
| SSH password auth | Solo claves públicas; fail2ban |
| Segmentación | Mantener DB solo en internal sin ruta desde dmz |

## Comandos reproducibles

```bash
cd parte3-black-hat-bash
cp .env.example .env
make deploy
make test                    # contenedores + redes + playbook ofensivo

# Solo fase ofensiva
docker compose exec attacker bash /lab/offensive/exploit.sh

# Lab oficial del libro (172.16.10.0/24)
LAB_MODE=bhb docker compose exec -e LAB_MODE=bhb attacker bash /lab/offensive/exploit.sh
```

## Modo lab oficial (Black Hat Bash book)

Si desplegaste el lab del repositorio `b1ackmartian/black-hat-bash`:

```bash
export LAB_MODE=bhb
./offensive/exploit.sh
```

Objetivos: `172.16.10.10:8081`, `172.16.10.11`, `172.16.10.12`, `172.16.10.13`.
