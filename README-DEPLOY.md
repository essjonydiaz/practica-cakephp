# practica-cakephp — despliegue

Laboratorio CakePHP 5.4 + MariaDB. Dos entornos, mismo codigo.

## Desarrollo local (Docker Compose, sin cambios)

```bash
docker compose up -d --build
# http://localhost:8765
```

Usa `Dockerfile` (php:8.3-apache) y el servicio `db` (mariadb:11.4).
La conexion sale de `app/config/app_local.php`, cuyos defaults apuntan al servicio `db`.

## Produccion (Vercel, runtime container)

| Archivo | Para que sirve |
| --- | --- |
| `Dockerfile.vercel` | Imagen de produccion con FrankenPHP (Caddy + PHP 8.3) |
| `Caddyfile` | Sirve `app/webroot` y escucha en `$PORT` |
| `vercel.json` | Declara el servicio con `"runtime": "container"` |
| `docker/vercel-entrypoint.sh` | Recrea `tmp/` y `logs/` en cada arranque en frio |

```bash
vercel deploy --prod
```

Vercel no tiene almacenamiento persistente, asi que la base de datos vive
fuera (proveedor MySQL/MariaDB gestionado) y se inyecta por variables de entorno.

### Variables de entorno

| Variable | Obligatoria en produccion | Default local |
| --- | --- | --- |
| `DATABASE_URL` | si (DSN completo, gana sobre las demas) | — |
| `DB_HOST` | no | `db` |
| `DB_PORT` | no | `3306` |
| `DB_USERNAME` | no | `cake_user` |
| `DB_PASSWORD` | no | `cake_password` |
| `DB_DATABASE` | no | `cake_db` |
| `SECURITY_SALT` | si | valor de `app_local.php` |
| `DEBUG` | `true` para ver la pagina de bienvenida con los chequeos | `true` |

Formato del DSN:

```
mysql://usuario:password@host:3306/base?encoding=utf8mb4&timezone=UTC&cacheMetadata=true
```

### Migraciones

Se corren contra la base remota desde local:

```bash
docker compose run --rm -e DATABASE_URL="<dsn>" app bin/cake migrations migrate
```
