#!/usr/bin/env bash
# rice.sh — control rápido del daemon de wallpapers por nivel.
#
# Uso:
#   rice.sh                     # wallpaper aleatorio para el nivel actual
#   rice.sh /ruta/imagen.png    # fija esa imagen en el nivel actual
#   rice.sh --all               # rota todos los niveles
#
# La rotación automática cada 30 min la hace wallpaper-rotate.timer.
set -euo pipefail

CTL="$HOME/.local/bin/wallpaperctl.sh"

if [ "${1:-}" = "--all" ]; then
    "$CTL" rotate-all
elif [ "$#" -ge 1 ]; then
    "$CTL" set-current "$1"
else
    "$CTL" rotate
fi
