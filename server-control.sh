#!/bin/bash
#
# Script para administrar servicios PM2 (WPPConnect-Server, wpp-db-server,
# React-frontend y wpp-webhook).
# Uso:
#   ./server-control.sh iniciar   - Levanta todos los servicios
#   ./server-control.sh reiniciar - Reinicia todos
#   ./server-control.sh detener   - Detiene todos
#   ./server-control.sh logs      - Muestra logs en vivo

# Edita estas variables o comandos según tus rutas reales
WPPCONNECT_SERVER_PATH="$HOME/wpp-hub/wppconnect-server/dist/server.js"
WPPCONNECT_SERVER_NAME="wppconnect-server"

WPP_DB_SERVER_PATH="$HOME/wpp-hub/wpp-db-server/index.js"
WPP_DB_SERVER_NAME="wpp-db-server"

REACT_SERVE_CMD="serve -s $HOME/wpp-hub/wpp-frontend/build -l 3000"
REACT_SERVE_NAME="react-frontend"

# Agregamos el webhook:
WEBHOOK_SERVER_PATH="$HOME/wpp-hub/wpp-webhook/webhook.js"  # Ajusta la ruta si es diferente
WEBHOOK_SERVER_NAME="wpp-webhook"

case "$1" in
  iniciar)
    echo "=== Iniciando WPPConnect-Server ==="
    pm2 start "$WPPCONNECT_SERVER_PATH" --name "$WPPCONNECT_SERVER_NAME"

    echo "=== Iniciando wpp-db-server ==="
    pm2 start "$WPP_DB_SERVER_PATH" --name "$WPP_DB_SERVER_NAME"

    echo "=== Iniciando React-frontend (modo producción) ==="
    pm2 start "$REACT_SERVE_CMD" --name "$REACT_SERVE_NAME"

    echo "=== Iniciando wpp-webhook ==="
    pm2 start "$WEBHOOK_SERVER_PATH" --name "$WEBHOOK_SERVER_NAME"

    pm2 save
    echo "=== Todos los servicios fueron levantados ==="
    ;;

  reiniciar)
    echo "=== Reiniciando servicios PM2 ==="
    pm2 restart "$WPPCONNECT_SERVER_NAME" "$WPP_DB_SERVER_NAME" "$REACT_SERVE_NAME" "$WEBHOOK_SERVER_NAME"
    pm2 save
    ;;

  detener)
    echo "=== Deteniendo servicios PM2 ==="
    pm2 stop "$WPPCONNECT_SERVER_NAME" "$WPP_DB_SERVER_NAME" "$REACT_SERVE_NAME" "$WEBHOOK_SERVER_NAME"
    ;;

  logs)
    echo "=== Mostrando logs PM2 en vivo (Ctrl+C para salir) ==="
    pm2 logs
    ;;

  *)
    echo "Uso: $0 {iniciar|reiniciar|detener|logs}"
    exit 1
   ;;
esac

