# Overrides gschema — Cinnamon

El archivo `90_integrative-cinnamon.gschema.override` define valores **por defecto**
del escritorio para todos los usuarios.

## Claves configuradas

| Esquema | Clave | Valor |
|---------|-------|-------|
| `org.cinnamon.desktop.interface` | `gtk-theme` | `Mint-Y-Dark` |
| `org.cinnamon.desktop.interface` | `icon-theme` | `Mint-Y` |
| `org.cinnamon.desktop.interface` | `cursor-theme` | `Bibata-Modern-Classic` |
| `org.cinnamon.theme` | `name` | `Mint-Y-Dark` |
| `org.gnome.desktop.default-applications` | `web-browser` | `librewolf.desktop` |

## Flujo en Cubic

Ejecutar `cubic/scripts/03-gschema.sh`, que copia los overrides a
`/usr/share/glib-2.0/schemas/` y corre `glib-compile-schemas`.

## Inspeccionar claves en un sistema Mint de referencia

```bash
gsettings list-recursively org.cinnamon.desktop.interface
dconf dump /org/cinnamon/ > referencia-cinnamon.ini
```
