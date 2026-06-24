# Parte 3 — Black Hat Bash: Laboratorio Ofensivo

Laboratorio de seguridad ofensiva basado en el proyecto oficial **[Black Hat Bash](https://github.com/dolevf/Black-Hat-Bash)** (dolevf). Despliega una red corporativa simulada con 8 contenedores en dos segmentos de red, y se ejecuta un playbook ofensivo de 7 fases con evidencia documentada.

---

## Topología del laboratorio

```
  Internet / Atacante
       │
  br_public  (172.16.10.0/24)
  ┌────┴──────────────────────────────────────┐
  │  p-web-01   172.16.10.10  (HTTP :80)      │
  │  p-ftp-01   172.16.10.11  (FTP :21)       │
  │  p-web-02   172.16.10.12  (WordPress :80) │
  │  p-jumpbox-01 172.16.10.13 (SSH :22)      │
  └───────┬───────────────────────────────────┘
          │  p-jumpbox-01 y p-web-02 hacen bridge
  br_corporate (10.1.0.0/24) — red interna
  ┌────┴──────────────────────────────────────┐
  │  c-backup-01  10.1.0.13   (scripts)       │
  │  c-redis-01   10.1.0.14   (Redis :6379)   │
  │  c-db-01      10.1.0.15   (MySQL :3306)   │
  │  c-db-02      10.1.0.16   (MySQL :3306)   │
  └───────────────────────────────────────────┘
```

---

## Inicio rápido

### Requisitos

- Docker ≥ 24 y Docker Compose v2
- `make`

### Desplegar el laboratorio

```bash
# Construir imágenes e iniciar contenedores
sudo make deploy

# Verificar que el lab está activo
sudo make test
# Salida esperada: Lab is up.

# Ver estado de todos los contenedores
sudo make status
```

### Derribar el laboratorio

```bash
sudo make teardown   # detiene contenedores (preserva imágenes)
sudo make clean      # elimina contenedores e imágenes
```

### Comandos disponibles

| Comando | Descripción |
|---------|-------------|
| `make deploy` | Construye imágenes e inicia el lab |
| `make teardown` | Detiene los contenedores |
| `make rebuild` | Reconstruye desde cero |
| `make clean` | Elimina contenedores e imágenes |
| `make status` | Muestra estado del lab |
| `make test` | Verifica que el lab está activo |
| `make init` | Construye lab + herramientas de hacking |

---

## Playbook ofensivo — 7 fases

El script `offensive/exploit.sh` ejecuta un reconocimiento y explotación completo contra la red pública del laboratorio.

### Fase 1 — Descubrimiento de hosts (RustScan)

Escaneo de velocidad sobre la subred pública para identificar hosts activos.

```bash
rustscan -a 172.16.10.10,172.16.10.11,172.16.10.12,172.16.10.13 \
         --range 1-9000 --ulimit 5000 -- -sV
```

**Resultado:** Hosts activos en `.10`, `.11`, `.12`, `.13` con puertos 21, 22, 80 abiertos.

### Fase 2 — Enumeración de servicios (Nmap)

Detección detallada de versiones, SO y scripts NSE.

```bash
nmap -sV -sC -O -oA evidencia/03-nmap-servicios 172.16.10.10-13
```

**Hallazgos:**
- `p-ftp-01 :21` — vsFTPd 3.0.3, **login anónimo permitido**
- `p-jumpbox-01 :22` — OpenSSH
- `p-web-01 :80` — nginx, directorio `/backup/` expuesto
- `p-web-02 :80` — Apache + WordPress

### Fase 3 — Fingerprinting web (WhatWeb)

```bash
whatweb http://172.16.10.10 http://172.16.10.11 http://172.16.10.12
```

**Hallazgos:** WordPress detectado en p-web-02; nginx en p-web-01 con cabeceras que revelan versión.

### Fase 4 — Fuzzing de directorios (Dirsearch)

```bash
dirsearch -u http://172.16.10.10 -e php,html,txt,json -o evidencia/09-dirsearch-web01.txt
dirsearch -u http://172.16.10.12 -e php,html,txt,json -o evidencia/12-dirsearch-web02.txt
```

**Hallazgos:**
- `/backup/acme-impact-alliance/` — directorio Git expuesto
- `/backup/acme-hyper-branding/` — directorio Git expuesto
- `/uploads` — endpoint sin autenticación (p-web-01)

### Fase 5 — Escaneo de vulnerabilidades (Nuclei)

Plantillas personalizadas contra todos los hosts públicos.

```bash
nuclei -t /tmp/nuclei-templates/ -u http://172.16.10.10 -severity high,medium,info
```

**Hallazgos confirmados:**

| Severidad | Template | Host | Descripción |
|-----------|----------|------|-------------|
| HIGH | `git-config-exposure` | p-web-01 :80 | `.git/config` accesible en `/backup/acme-*/` |
| HIGH | `unauthenticated-file-upload` | p-web-01 :80 | `/uploads` sin autenticación |
| MEDIUM | `directory-listing` | p-web-01 :80 | Apache directory indexing en `/backup/` |
| INFO | `wordpress-login-panel` | p-web-02 :80 | Panel `/wp-login.php` expuesto |
| INFO | `ftp-anonymous-login` | p-ftp-01 :21 | FTP anónimo permite lista y descarga |

### Fase 6 — Acceso FTP anónimo

```bash
lftp -e "ls; ls backup/; ls backup/acme-impact-alliance/; quit" 172.16.10.11
```

**Hallazgos:**
- `backup/acme-impact-alliance/` — repositorio Git con código fuente interno
- `backup/acme-hyper-branding/` — repositorio Git con assets corporativos
- Descarga de archivos sin credenciales confirmada

### Fase 7 — Enumeración de usuarios WordPress (REST API)

```bash
curl "http://172.16.10.12/?rest_route=/wp/v2/users"
```

**Resultado:** Endpoint REST habilitado; retorna lista de usuarios registrados en JSON.

---

## Evidencia capturada

Todos los archivos están en `offensive/evidencia/`:

| Archivo | Contenido |
|---------|-----------|
| `01-rustscan-subred.txt` | Hosts activos (RustScan) |
| `02-rustscan-nmap.log` | Log de RustScan con Nmap integrado |
| `03-nmap-servicios.*` | Escaneo completo Nmap (nmap/gnmap/xml) |
| `04-nmap-ftp-anon.txt` | Verificación FTP anónimo |
| `05-nmap-ssh-jumpbox.txt` | SSH en jumpbox |
| `06-whatweb-web01.txt` | Fingerprint p-web-01 |
| `07-whatweb-ftp-http.txt` | Fingerprint p-ftp-01 (HTTP) |
| `08-whatweb-web02.txt` | Fingerprint p-web-02 WordPress |
| `09-dirsearch-web01.txt` | Fuzzing p-web-01 |
| `10-dirsearch-git-impact.txt` | Git expuesto: acme-impact-alliance |
| `11-dirsearch-git-hyper.txt` | Git expuesto: acme-hyper-branding |
| `12-dirsearch-web02.txt` | Fuzzing p-web-02 WordPress |
| `13-nuclei-web01.txt` | Nuclei p-web-01 |
| `14-nuclei-ftp-http.txt` | Nuclei p-ftp-01 (HTTP) |
| `15-nuclei-web02.txt` | Nuclei p-web-02 WordPress |
| `16-nuclei-ftp.txt` | Nuclei p-ftp-01 (FTP protocol) |
| `17-ftp-anon-listado.txt` | Listado FTP anónimo |
| `18-wp-user-enum.json` | Enumeración usuarios WordPress |
| `19-backup-directory-index-headers.txt` | Cabeceras HTTP directorio backup |

---

## Mitigaciones recomendadas

| Vulnerabilidad | Mitigación |
|---------------|-----------|
| FTP anónimo | Deshabilitar `anonymous_enable=YES` en vsftpd.conf |
| Repositorios `.git` expuestos | Bloquear en nginx: `location ~ /\.git { deny all; }` |
| Directory indexing | `Options -Indexes` en Apache / `autoindex off` en nginx |
| `/uploads` sin auth | Requerir autenticación; validar tipo MIME en servidor |
| WP REST API usuarios | Deshabilitar con plugin o `remove_action('rest_api_init', ...)` |

---

## Estructura de archivos

```
parte3-black-hat-bash/
├── docker-compose.yml      # 8 servicios (p-*, c-*) en dos redes
├── Makefile                # deploy / test / teardown / clean
├── run.sh                  # lógica de orquestación
├── init.sh                 # inicialización del lab
├── provision.sh            # aprovisionamiento de servicios
├── machines/               # Dockerfile por contenedor
│   ├── p-web-01/
│   ├── p-web-02/
│   ├── p-ftp-01/
│   ├── p-jumpbox-01/
│   ├── c-backup-01/
│   ├── c-redis-01/
│   ├── c-db-01/
│   └── c-db-02/
├── tests/                  # test-networks.sh y otros
├── offensive/
│   ├── exploit.sh          # playbook ofensivo (7 fases)
│   └── evidencia/          # 19 archivos de evidencia
└── README-bhb.md           # README original del proyecto Black Hat Bash
```

---

## Créditos

Lab base: [Black Hat Bash](https://github.com/dolevf/Black-Hat-Bash) por Dolev Farhi & Nick Aleks.  
Integración ofensiva: Parte 3 del Proyecto Integrador UIDE 2026-Q1.
