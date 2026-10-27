#!/bin/sh
# archive-menu.sh — portapapeles e historial de notificaciones (Mod+N).

choice=$(printf '%s\n' \
    'CLIPBOARD // HISTORIAL' \
    'NOTIFICATIONS // HISTORIAL' \
    'RESTORE LAST NOTIFICATION' \
    'CLEAR CLIPBOARD' \
    'CLEAR NOTIFICATIONS' \
    | fuzzel --dmenu --prompt='ARCHIVE > ' --lines=5 --width=38 2>/dev/null)

[ -n "$choice" ] || exit 0

case "$choice" in
    'CLIPBOARD // HISTORIAL') exec "$HOME/.local/bin/clipboard-menu.py" ;;
    'NOTIFICATIONS // HISTORIAL') exec "$HOME/.local/bin/notification-menu.py" ;;
    'RESTORE LAST NOTIFICATION') exec makoctl restore ;;
    'CLEAR CLIPBOARD') rm -f "$HOME/.cache/rice/clipboard-history.jsonl" ;;
    'CLEAR NOTIFICATIONS') rm -f "$HOME/.cache/rice/notification-history.jsonl" ;;
esac
