# Archivos para `/etc/skel`

Se copian al chroot con `cubic/scripts/02-skel-setup.sh`. Cada usuario **nuevo**
recibe este contenido en su `$HOME` al crearse la cuenta.

## Contenido

| Ruta en skel | Propósito |
|--------------|-----------|
| `.config/nvim/init.lua` | Neovim con números de línea, tabs 4 espacios, atajos básicos |
| `.config/dconf/user` | Tema Mint-Y-Dark y LibreWolf como navegador en Cinnamon |
| `.bashrc.d/10-integrative.sh` | Alias (`ll`, `nv`, `c`) y mensaje de bienvenida |
| `.bashrc.append` | Se fusiona al final del `.bashrc` de plantilla Mint (no lo reemplaza) |

## Añadir más dotfiles

Coloca archivos bajo `skel/` respetando la estructura de `$HOME` (ej. `.config/`, `Desktop/`).
Vuelve a ejecutar `02-skel-setup.sh` en Cubic.
