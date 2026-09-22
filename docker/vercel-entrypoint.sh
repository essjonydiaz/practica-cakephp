#!/bin/sh
set -e

# El filesystem del contenedor en Vercel es efimero: recreamos los directorios
# escribibles que CakePHP necesita en cada arranque en frio.
for dir in \
    /app/tmp \
    /app/tmp/cache \
    /app/tmp/cache/models \
    /app/tmp/cache/persistent \
    /app/tmp/cache/views \
    /app/tmp/sessions \
    /app/logs
do
    mkdir -p "$dir" 2>/dev/null || true
    chmod 0777 "$dir" 2>/dev/null || true
done

exec "$@"
