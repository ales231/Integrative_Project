# Guion — Video de demostración final (8 minutos)

Video único que cubre las **tres partes** del proyecto integrador. Duración
objetivo: **8:00** (margen ±30 s). Resolución mínima: **1080p**. Audio claro.

Enlace de publicación: actualizar [parte1-distro-linux/demo/enlaces.md](../parte1-distro-linux/demo/enlaces.md).

---

## Distribución del tiempo

| Bloque | Tiempo | Contenido |
|--------|--------|-----------|
| Introducción | 0:00 – 0:45 | Equipo, curso, visión del proyecto |
| Parte 1 — Cubic | 0:45 – 3:00 | ISO, modificaciones, persistencia |
| Parte 2 — Kernel | 3:00 – 5:15 | Build, Episode 1, Episode 2 |
| Parte 3 — BHB | 5:15 – 7:30 | Deploy, redes, ataque documentado |
| Cierre | 7:30 – 8:00 | Resumen, repo, créditos |

---

## 0:00 – 0:45 · Introducción

**Pantalla:** README del repositorio en GitHub o árbol de carpetas.

**Narración sugerida:**

> Somos [nombres del equipo], del curso [asignatura], período [semestre].
> Presentamos el proyecto integrador en tres partes: una distro Linux
> personalizada con Cubic, un kernel x86_64 desde cero y un laboratorio
> ofensivo con Docker. Todo es reproducible desde este repositorio con los
> comandos documentados en cada README.

**Mostrar en pantalla:**

- Estructura: `parte1-distro-linux/`, `parte2-kernel-x86_64/`, `parte3-black-hat-bash/`
- Tabla de puntos de la rúbrica (breve)

---

## 0:45 – 3:00 · Parte 1 — Distro Linux (Cubic)

### 0:45 – 1:15 · Base y build

**Pantalla:** Cubic o diagrama del pipeline.

**Narración:**

> La Parte 1 parte de Linux Mint Cinnamon 22. Usamos Cubic para personalizar
> el chroot. Los scripts del repo instalan paquetes, configuran `/etc/skel` y
> aplican overrides gschema para que los cambios persistan en usuarios nuevos.

**Mostrar:**

- `cubic/scripts/` (orden 04 → 02 → 03 → 05)
- Mencionar que la ISO no está en Git, solo el checksum

### 1:15 – 1:45 · Modificación 1 — LibreWolf

**Pantalla:** Menú de aplicaciones o terminal.

```bash
librewolf --version
update-alternatives --display x-www-browser | grep librewolf
dpkg -l firefox   # no instalado
```

**Narración:** Firefox fue reemplazado por LibreWolf vía repositorio APT firmado.

### 1:45 – 2:15 · Modificaciones 2 y 3 — Neovim y VS Code

```bash
nvim --headless +'lua print(vim.o.number)' +qa
code --version
ls ~/.config/nvim/init.lua   # en usuario nuevo
```

### 2:15 – 2:45 · Modificación 4 — Tema oscuro (gschema + dconf)

```bash
gsettings get org.cinnamon.desktop.interface gtk-theme
# → 'Mint-Y-Dark'
```

**Mostrar:** escritorio con tema oscuro.

### 2:45 – 3:00 · Persistencia con usuario nuevo

```bash
sudo adduser --gecos "" demo
# Login como demo → mostrar skel, tema, herramientas
```

**Narración:** La prueba crítica es un usuario creado después del build, no solo el live user.

---

## 3:00 – 5:15 · Parte 2 — Kernel x86_64

### 3:00 – 3:30 · Build reproducible

**Pantalla:** Terminal en `parte2-kernel-x86_64/`.

```bash
make docker-build
make docker-episode2
ls -lh output/kernel.iso
```

**Narración:** Toolchain en Docker: NASM, GRUB, GCC freestanding. Salida: `kernel.iso`.

### 3:30 – 4:00 · Episode 1 — Multiboot2 y OK

```bash
make episode1
make run   # o captura pregrabada
```

**Pantalla:** QEMU con **OK** en VGA (`0xB8000`).

**Narración:** Episode 1 valida el header Multiboot2 y escribe OK en memoria de video.

### 4:00 – 4:45 · Episode 2 — Long mode

**Pantalla:** Diagrama o `EPISODE2.md` (flujo 32→64 bits).

**Narración:**

> Episode 2 verifica CPUID y long mode, configura paginación con huge pages de
> 2 MiB para 1 GiB identidad, carga la GDT de 64 bits y salta a `kernel_main` en C.

**Mostrar archivos clave (rápido):**

- `src/boot/header.asm`, `src/arch/paging.asm`, `src/kernel/main.c`

### 4:45 – 5:15 · Resultado en QEMU

```bash
make episode2 && make run
```

**Pantalla:** Banner del grupo en consola VGA.

**Narración:** Mensaje personalizado del equipo; bucle `hlt` al final.

---

## 5:15 – 7:30 · Parte 3 — Black Hat Bash

### 5:15 – 5:45 · Despliegue

**Pantalla:** `parte3-black-hat-bash/`.

```bash
cp .env.example .env
make deploy
docker compose ps   # 8 contenedores running
```

**Narración:** Ocho contenedores en dos redes: dmz e internal aislada.

### 5:45 – 6:15 · Topología de red

**Pantalla:** [docs/diagrama-redes.md](diagrama-redes.md) o `network/topology.md`.

**Narración:**

> El atacante está solo en dmz. No alcanza la base de datos en internal.
> El jumpbox tiene doble interfaz para simular un bastión.

```bash
./network/verify-network.sh
```

### 6:15 – 7:00 · Técnica ofensiva

```bash
make test
# o:
docker compose exec attacker bash /lab/offensive/exploit.sh
```

**Mostrar salidas clave (scroll rápido):**

- RustScan: puertos 21, 80, 8081, 22
- Nmap `ftp-anon` en victim-ftp
- Dirsearch: `/upload`, `/.git`
- lftp anonymous → carpeta `backup/`

**Narración:** Cadena reconocimiento → enumeración → hallazgos → FTP anónimo. Solo en lab aislado.

### 7:00 – 7:30 · Evidencias y mitigación

**Pantalla:** `offensive/tecnica.md` — tabla de mitigaciones.

**Narración:** Cada hallazgo tiene mitigación: deshabilitar FTP anónimo, bloquear `.git`, segmentación.

---

## 7:30 – 8:00 · Cierre

**Pantalla:** README principal + enlaces a evidencias.

**Narración:**

> Las tres partes cumplen la rúbrica: ISO persistente, kernel con long mode y
> laboratorio ofensivo reproducible con `make test`. Repositorio, evidencias y
> documentación en `docs/`. Gracias.

**Mostrar:**

- `docs/evidencias/lista-evidencias.md`
- URL del repositorio
- Nombres del equipo

---

## Checklist de grabación

- [ ] Duración total ≈ 8 minutos
- [ ] 1080p, cursor visible, fuente terminal legible
- [ ] Audio sin ruido de fondo
- [ ] Cada criterio de rúbrica mencionado al menos una vez
- [ ] Comandos reales ejecutados (no solo slides)
- [ ] Aviso ético Parte 3: “solo entorno de laboratorio”
- [ ] Enlace subido y documentado en `demo/enlaces.md`

---

## Material de apoyo (pre-grabar)

| Recurso | Uso |
|---------|-----|
| Capturas en `docs/evidencias/` | Backup si QEMU/Docker fallan en vivo |
| [docs/arquitectura-laboratorio.md](arquitectura-laboratorio.md) | Slide de arquitectura |
| [docs/diagrama-redes.md](diagrama-redes.md) | Slide de redes Parte 3 |

---

## Versión corta Parte 1 (opcional)

Si el evaluador pide video **solo de Cubic** (3–5 min), usar
[parte1-distro-linux/demo/guion-video.md](../parte1-distro-linux/demo/guion-video.md).
