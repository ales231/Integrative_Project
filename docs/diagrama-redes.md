# Diagrama de redes

Documentación de topología de red del laboratorio ofensivo (Parte 3) y visión
de cómo se despliegan las partes del proyecto en el entorno del evaluador.

---

## 1. Visión global del proyecto (entorno del evaluador)

```mermaid
flowchart TB
    subgraph host ["Máquina host del equipo"]
        subgraph p1 ["Parte 1 — Cubic"]
            CUBIC["Cubic GUI"]
            ISO["integrative.iso"]
            VM1["VM VirtualBox/QEMU"]
            CUBIC --> ISO --> VM1
        end

        subgraph p2 ["Parte 2 — Kernel"]
            DOCKER2["Docker toolchain"]
            QEMU["QEMU"]
            ISO2["kernel.iso"]
            DOCKER2 --> ISO2 --> QEMU
        end

        subgraph p3 ["Parte 3 — Black Hat Bash"]
            COMPOSE["Docker Compose"]
            subgraph dmz ["Red dmz 172.28.10.0/24"]
                ATT["attacker .2"]
                WEB["victim-web .10"]
                FTP["victim-ftp .11"]
                JUMP["jumpbox .13"]
            end
            subgraph internal ["Red internal 172.28.20.0/24"]
                DB["victim-db .15"]
                DNS["dns .53"]
                MAIL["mail .25"]
                MON["monitor .30"]
                FTPi["victim-ftp .11"]
            end
            COMPOSE --> dmz
            COMPOSE --> internal
            FTP --- FTPi
            JUMP --- dmz
            JUMP --- internal
        end
    end

    EVAL["Evaluador / docente"] --> host
```

---

## 2. Topología Docker — Parte 3 (detalle)

### Diagrama lógico

```mermaid
flowchart LR
    subgraph dmz_net ["dmz — 172.28.10.0/24 (bridge, salida a host)"]
        ATT["attacker\n172.28.10.2"]
        WEB["victim-web\n172.28.10.10\n:8080→host"]
        FTP_D["victim-ftp\n172.28.10.11"]
        JUMP_D["jumpbox\n172.28.10.13\n:2222→host"]
    end

    subgraph int_net ["internal — 172.28.20.0/24 (internal: true)"]
        FTP_I["victim-ftp\n172.28.20.11"]
        JUMP_I["jumpbox\n172.28.20.12"]
        DB["victim-db\n172.28.20.15"]
        DNS["dns\n172.28.20.53"]
        MAIL["mail\n172.28.20.25"]
        MON["monitor\n172.28.20.30"]
    end

    ATT -->|"HTTP 80/8081"| WEB
    ATT -->|"FTP 21, HTTP 80"| FTP_D
    ATT -->|"SSH 22"| JUMP_D
  ATT -.->|"✗ bloqueado"| DB

    JUMP_D --- JUMP_I
    FTP_D --- FTP_I
    JUMP_I -->|"PostgreSQL 5432"| DB
    WEB -.->|"backend futuro"| DB
```

### Diagrama ASCII (referencia rápida)

```
                    ┌─────────────────────────────────────────┐
                    │           HOST (puertos publicados)      │
                    │   localhost:8080 ──► victim-web:80     │
                    │   localhost:2222 ──► jumpbox:22        │
                    └─────────────────────────────────────────┘
                                        │
        ┌───────────────────────────────┴───────────────────────────────┐
        │                    RED dmz — 172.28.10.0/24                    │
        │  .2 attacker    .10 victim-web    .11 victim-ftp    .13 jumpbox │
        └───────────────────────────────┬───────────────────────────────┘
                                        │ (dual-homed: ftp, jumpbox)
        ┌───────────────────────────────┴───────────────────────────────┐
        │              RED internal — 172.28.20.0/24 (aislada)         │
        │  .11 ftp   .12 jumpbox   .15 db   .53 dns   .25 mail  .30 mon │
        └───────────────────────────────────────────────────────────────┘

Leyenda:
  attacker ──► victim-web, victim-ftp, jumpbox     (dmz)
  attacker ──X victim-db                           (sin ruta a internal)
  jumpbox  ──► victim-db                           (pivot legítimo de lab)
```

---

## 3. Matriz de conectividad

| Origen | Destino | Red | Puerto | Permitido | Notas |
|--------|---------|-----|--------|-----------|-------|
| attacker | victim-web | dmz | 80, 8081 | Sí | Superficie web principal |
| attacker | victim-ftp | dmz | 21, 80 | Sí | FTP anónimo + Apache backup |
| attacker | jumpbox | dmz | 22 | Sí | Bastión SSH |
| attacker | victim-db | internal | 5432 | **No** | Segmentación verificada |
| attacker | dns, mail, monitor | internal | varios | **No** | Red internal sin gateway desde dmz |
| jumpbox | victim-db | internal | 5432 | Sí | Doble interfaz dmz+internal |
| victim-web | victim-db | internal | 5432 | Sí* | Backend simulado (*futuro) |
| host | victim-web | NAT | 8080→80 | Sí | Acceso desde navegador local |
| host | jumpbox | NAT | 2222→22 | Sí | SSH al bastión |

Verificación automatizada: `parte3-black-hat-bash/network/verify-network.sh`

---

## 4. Flujo del ataque documentado

```mermaid
sequenceDiagram
    participant A as attacker
    participant W as victim-web
    participant F as victim-ftp
    participant J as jumpbox
    participant D as victim-db

    A->>A: RustScan 172.28.10.0/24
    A->>W: Nmap -sV (80, 8081)
    A->>F: Nmap ftp-anon (21)
    A->>W: WhatWeb + Dirsearch
    A->>F: Dirsearch /backup
    A->>W: Nuclei (WP, uploads)
    A->>F: lftp anonymous → backup/
    Note over A,D: attacker NO alcanza victim-db
    A->>J: SSH (enum auth methods)
    J->>D: PostgreSQL (solo desde internal)
```

---

## 5. Parte 2 — Kernel (sin red)

El kernel no implementa stack de red en esta entrega. La “red” relevante es la
interfaz serial QEMU (`-serial stdio`) y el buffer VGA en `0xB8000`.

```mermaid
flowchart LR
    GRUB["GRUB Multiboot2"] --> KERN["kernel.bin ELF64"]
    KERN --> VGA["VGA 0xB8000"]
    KERN --> SER["COM1 serial"]
    QEMU["QEMU x86_64"] --- GRUB
```

---

## 6. Parte 1 — Red en la ISO

La ISO personalizada es un sistema de escritorio estándar; no define topología
de laboratorio. Requisitos de red para el build:

| Fase | Red | Uso |
|------|-----|-----|
| Chroot Cubic | Internet | APT: LibreWolf, VS Code, neovim |
| VM post-install | NAT/bridge | Verificación de boot y paquetes |

---

## Referencias

- [parte3-black-hat-bash/network/topology.md](../parte3-black-hat-bash/network/topology.md)
- [parte3-black-hat-bash/docker-compose.yml](../parte3-black-hat-bash/docker-compose.yml)
- [docs/arquitectura-laboratorio.md](arquitectura-laboratorio.md)
