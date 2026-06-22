# Defensa oral — Preguntas y respuestas recomendadas

Preparación para la presentación y defensa del proyecto integrador. Las
respuestas están alineadas con la [rúbrica](rubrica.md) y el contenido real
del repositorio.

---

## Parte 1 — Distro Linux (Cubic)

### P1. ¿Por qué eligieron Linux Mint y no Ubuntu vanilla?

**Respuesta recomendada:** Linux Mint Cinnamon ofrece un escritorio estable y
familiar para el equipo, con buena compatibilidad con Cubic y herramientas de
desarrollo. Cumple el requisito de basarse en Ubuntu/Mint. Cinnamon permite
personalización vía `gschema`, que era un criterio explícito de persistencia.

### P2. ¿Cuáles son las tres modificaciones principales y por qué persisten?

**Respuesta recomendada:**

1. **LibreWolf** — instalado por APT y registrado con `update-alternatives`; persiste a nivel de sistema en la imagen.
2. **Neovim configurado** — binario por APT; `init.lua` en `/etc/skel` se copia al home de cada usuario nuevo.
3. **Tema Mint-Y-Dark** — override en `/usr/share/glib-2.0/schemas/` compilado con `glib-compile-schemas`, más `dconf` en skel para el primer login.

Además instalamos VS Code y plantilla de usuario en skel; la prueba crítica es
crear un usuario **después** del build y verificar que hereda la configuración.

### P3. ¿Qué diferencia hay entre gschema y `/etc/skel`?

**Respuesta recomendada:** `gschema` define **valores por defecto del sistema**
para todos los usuarios (p. ej. tema GTK global). `/etc/skel` es la plantilla
que se copia al crear un usuario nuevo (`useradd`/`adduser`); afecta dotfiles
personales como `~/.config/nvim/` y preferencias `dconf` del usuario. Usamos
ambos porque Cinnamon lee configuración en las dos capas.

### P4. ¿Por qué la ISO no está en el repositorio?

**Respuesta recomendada:** Por tamaño (varios GB) y buenas prácticas de Git.
Entregamos el **checksum SHA256** en `docs/evidencias/parte1/` para verificar
integridad. El evaluador puede regenerar la ISO siguiendo los scripts de Cubic
documentados en el README.

### P5. ¿Cómo verificaron que Firefox fue eliminado correctamente?

**Respuesta recomendada:** En el chroot ejecutamos purge de `firefox` en
`04-repos-and-packages.sh`. En la VM verificamos con `dpkg -l firefox` (no
debe estar en estado `ii`) y comprobamos que LibreWolf es `x-www-browser` con
`update-alternatives --display`.

---

## Parte 2 — Kernel x86_64

### P6. ¿Qué es Multiboot2 y qué papel juega GRUB?

**Respuesta recomendada:** Multiboot2 es el estándar que permite a un
bootloader cargar nuestro kernel. El header en `header.asm` (magic `0xE85250D6`,
checksum, end tag) es validado por GRUB antes de saltar a `_start`. En
`grub.cfg` usamos `multiboot2 /boot/kernel.bin` dentro de la ISO generada con
`grub-mkrescue`.

### P7. Explique el flujo de Episode 1 a Episode 2.

**Respuesta recomendada:** Episode 1 (`main_ep1.asm`) solo demuestra que GRUB
carga el kernel y escribimos `OK` en `0xB8000`. Episode 2 añade verificaciones
(Multiboot magic, CPUID, long mode), paginación identidad con huge pages de
2 MiB, GDT de 64 bits, far jump a `long_mode_start` y llamada a `kernel_main()`
en C con `print()` sobre VGA.

### P8. ¿Por qué usan huge pages de 2 MiB en lugar de 4 KiB?

**Respuesta recomendada:** Para mapear 1 GiB identidad con menos entradas de
tabla: 512 entradas PD × 2 MiB = 1 GiB. Simplifica el código inicial de
paginación en un kernel educativo. Las tablas PML4/PDPT/PD están en `.bss`
alineadas a 4 KiB en `paging.asm`.

### P9. ¿Qué verificaciones hace el kernel antes de entrar en long mode?

**Respuesta recomendada:**

1. Magic Multiboot2 en EAX (`0x36D76289`)
2. CPUID disponible (bit ID en EFLAGS)
3. Soporte long mode (CPUID hoja `0x80000001`, bit LM en EDX)

Si fallan, escribimos `ERR: 0/1/2` en VGA y ejecutamos `hlt`.

### P10. ¿Cómo garantizan build reproducible?

**Respuesta recomendada:** Dockerfile con toolchain fija (Ubuntu 24.04, NASM,
GCC, GRUB, xorriso). Targets `make docker-episode2` compilan siempre en el mismo
entorno. Alternativa: script `setup-local-toolchain.sh` para NASM/xorriso locales
con versiones documentadas.

### P11. ¿Por qué la ISO lleva el ELF y no un binario plano?

**Respuesta recomendada:** GRUB Multiboot2 espera un ELF con secciones y header
Multiboot al inicio. Si usamos `objcopy -O binary` perdemos metadatos y GRUB
muestra errores como `invalid ELF magic`. `build-iso.sh` copia el `.elf` a
`/boot/kernel.bin` en la ISO.

---

## Parte 3 — Black Hat Bash

### P12. Describa la topología de red del laboratorio.

**Respuesta recomendada:** Dos redes Docker: **dmz** (`172.28.10.0/24`, con
salida) e **internal** (`172.28.20.0/24`, `internal: true`, sin internet).
Ocho contenedores: attacker, victim-web, victim-ftp, jumpbox en dmz; victim-db,
dns, mail, monitor solo en internal. victim-ftp y jumpbox tienen doble interfaz.
El atacante no alcanza victim-db; lo verificamos con `verify-network.sh`.

### P13. ¿Qué hace `make test` exactamente?

**Respuesta recomendada:** Ejecuta tres scripts en orden:

1. `test-containers.sh` — los 8 contenedores están Up
2. `test-networks.sh` — conectividad permitida y bloqueada según matriz
3. `test-offensive.sh` — playbook `exploit.sh` y hallazgos esperados

Es la verificación automatizada de la rúbrica.

### P14. ¿Cuál fue la técnica ofensiva y qué hallazgo fue más crítico?

**Respuesta recomendada:** Cadena RustScan → Nmap → WhatWeb → Dirsearch →
Nuclei → FTP anónimo. El hallazgo más crítico es **FTP anónimo** en
victim-ftp (`anonymous_enable=YES`), que permite listar y descargar el directorio
`backup/` con información sensible. También relevantes: `.git` expuesto y
directory indexing en `/backup/`.

### P15. ¿Cómo mitigarían esos hallazgos en producción?

**Respuesta recomendada:**

| Hallazgo | Mitigación |
|----------|------------|
| FTP anónimo | Deshabilitar anonymous; usar SFTP + MFA |
| `.git` expuesto | Denegar `/.git` en el servidor web |
| Directory indexing | `Options -Indexes` en Apache |
| WP user enum | Restringir REST API; actualizar WP |
| Segmentación | DB solo en VLAN interna; firewall entre dmz e internal |

Documentado en `offensive/tecnica.md`.

### P16. ¿Por qué el atacante no puede llegar a la base de datos?

**Respuesta recomendada:** victim-db solo está en la red `internal`, marcada
como `internal: true` en Docker Compose. El contenedor attacker solo tiene
interfaz en `dmz`. Sin jumpbox comprometido o misconfiguración de rutas, no hay
camino L3 hacia `172.28.20.15`. Es segmentación deliberada del escenario.

### P17. ¿Es ético lo que demostraron?

**Respuesta recomendada:** Sí, porque todo ocurre en un **lab aislado** definido
en Docker Compose, sin objetivos reales ni redes externas. El playbook está
documentado, es reproducible y cada hallazgo incluye mitigación. No publicamos
exploits contra terceros; simulamos vulnerabilidades intencionales para
aprendizaje.

---

## Documentación, repositorio y trabajo en equipo

### P18. ¿Cómo está organizado el repositorio para el evaluador?

**Respuesta recomendada:** Tres carpetas `parte1/`, `parte2/`, `parte3/` con
README independiente, `docs/` con rúbrica, arquitectura, diagrama de redes,
lista de evidencias, guion de video y esta guía de defensa. Script
`verify-all.sh` valida estructura mínima. Convención de commits en
`CONTRIBUTING.md`.

### P19. ¿Cómo dividieron el trabajo entre integrantes?

**Respuesta recomendada:** Matriz en `docs/equipo.md`: un líder por parte
(Cubic, Kernel, BHB) y un integrante de integración/DevOps. Cada persona con
mínimo 5 commits en su área y 1 commit de evidencia. Revisiones cruzadas en
READMEs y tests.

### P20. Si tuvieran una semana más, ¿qué mejorarían?

**Respuesta recomendada (honesta y técnica):**

- **Parte 1:** Branding completo y automatizar post-build checksum en CI.
- **Parte 2:** Interrupciones (IDT), timer o driver serial más completo.
- **Parte 3:** Pivot real desde jumpbox a DB, IDS en monitor, playbook en
  modo defensivo (detección de RustScan).

Demuestra madurez sin invalidar lo entregado.

---

## Preguntas transversales (conceptuales)

### P21. ¿Qué aprendizaje integran las tres partes?

**Respuesta recomendada:** La Parte 1 enseña **personalización y persistencia**
de un SO de escritorio. La Parte 2 muestra **arranque y hardware** desde
cero (bootloader → modo 64 bits → C). La Parte 3 aplica **redes y seguridad**
en un entorno moderno containerizado. Juntas cubren stack completo: usuario,
kernel y infraestructura.

### P22. ¿Cuál fue el mayor obstáculo técnico?

**Respuesta recomendada (adaptar a experiencia real del equipo):**

- Ejemplo Kernel: alinear header Multiboot2 y linker para que GRUB acepte el ELF.
- Ejemplo BHB: timing de healthchecks y IPs fijas en Compose.
- Ejemplo Cubic: orden de scripts y compilación de gschema en chroot.

### P23. ¿Cómo reproduciría el proyecto un evaluador en una máquina limpia?

**Respuesta recomendada:**

```bash
git clone [URL]
cd Integrative_Project

# Parte 2
cd parte2-kernel-x86_64 && make docker-build && make docker-episode2 && make docker-run

# Parte 3
cd ../parte3-black-hat-bash && cp .env.example .env && make deploy && make test

# Parte 1: Cubic en host con GUI — ver parte1-distro-linux/README.md
```

Requisitos en README principal; evidencias en `docs/evidencias/`.

---

## Consejos para la defensa

1. **Asignar preguntas por parte** al integrante responsable.
2. **Tener terminal lista** con `make test` y QEMU previamente probados.
3. **Mostrar diagrama de redes** ante cualquier duda de Parte 3.
4. **Mencionar mitigaciones** al hablar de ataques — demuestra pensamiento defensivo.
5. **No memorizar** respuestas literales; usar los archivos del repo como referencia.
