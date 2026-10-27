#!/bin/sh
# palette-menu.sh — selector de paletas HUD con Fuzzel.

choice=$(printf '%s\n' CYBER MAGENTA AMBER MATRIX ICE |
    fuzzel --dmenu --prompt='PALETTE > ' --lines=5 --width=30 2>/dev/null)
[ -n "$choice" ] || exit 0
exec "$HOME/.local/bin/palette-apply.py" "$(printf '%s' "$choice" | tr '[:upper:]' '[:lower:]')"
