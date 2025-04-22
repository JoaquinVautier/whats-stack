#!/usr/bin/env bash
set -e

# --- 1) Obtener la IP pública ---
# • primero probamos ipify   • si falla, tomamos la 1.ª IP de 'hostname -I'
PUB_IP=$(curl -s --max-time 5 https://api.ipify.org || hostname -I | awk '{print $1}')

# --- 2) Exportar variables si el usuario NO las fijó en docker‑compose ---
export PUBLIC_IP="${PUBLIC_IP:-$PUB_IP}"
export HUB_API_KEY="${HUB_API_KEY:-$PUBLIC_IP}"   # usamos la IP como API‑key

echo "[entrypoint] PUBLIC_IP=$PUBLIC_IP  HUB_API_KEY=$HUB_API_KEY"

# --- 3) Lanzar la app ---
exec node index.js

