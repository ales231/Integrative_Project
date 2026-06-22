# Servicio: victim-ftp

FTP anónimo + Apache con directory indexing en `/backup/`.

- **vsFTPd :21** — `anonymous` sin contraseña, raíz `/var/www/html`
- **Apache :80** — `/backup/acme-*/` con repos `.git` expuestos
- Redes: `dmz` (`172.28.10.11`) + `internal` (`172.28.20.11`)

```bash
lftp -u anonymous, -e "ls; cd backup; ls; bye" 172.28.10.11
curl http://172.28.10.11/backup/
```
