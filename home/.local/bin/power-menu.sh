#!/bin/sh
# power-menu.sh — menú de sistema con estética de menú de videojuego.

choice=$(printf '%s\n' \
    '▶ RESUME' \
    '♥ LOCK' \
    '◆ LOG OUT' \
    '■ SUSPEND' \
    '▲ REBOOT' \
    '× SHUTDOWN' \
    '▶ GAME MODE' \
    | fuzzel --dmenu --prompt='SYSTEM MENU > ' --lines=7 --width=28 2>/dev/null)

[ -n "$choice" ] || exit 0

case "$choice" in
    *"GAME MODE") exec "$HOME/.local/bin/game-mode.sh" ;;
    *LOCK)      exec "$HOME/.local/bin/lock.sh" ;;
    *"LOG OUT") exec niri msg action quit ;;
    *SUSPEND)   exec systemctl suspend ;;
    *REBOOT)    exec systemctl reboot ;;
    *SHUTDOWN)  exec systemctl poweroff ;;
esac
