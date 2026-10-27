#!/bin/sh
# game-mode-status.sh — solo muestra el módulo de Waybar si el modo juego está activo.

STATE="${XDG_RUNTIME_DIR:-/tmp}/rice-game-mode"
if [ -f "$STATE/active" ]; then
    printf '{"text":"// GAME ON","class":"game","tooltip":"Modo juego activo\\nPerformance + DND + idle inhibido\\nClic: desactivar"}'
fi
