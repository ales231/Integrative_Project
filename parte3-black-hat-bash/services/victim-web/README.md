# Servicio: victim-web

- **Nginx :80** — WordPress simulado (`/wp-login.php`, REST API users)
- **Flask :8081** — `/upload`, `/uploads` (Werkzeug)
- Red: `dmz` · Puerto host: `8080` → `80`

```bash
curl http://localhost:8080/
curl http://localhost:8080/?rest_route=/wp/v2/users
# Desde attacker:
curl http://victim-web:8081/upload
```
