#!/bin/sh
# game-mode.sh — modo juego: perfil performance, DND e idle inhibido.
# Se puede lanzar desde Waybar, desde el menú de energía o con Mod+Shift+G.

STATE="${XDG_RUNTIME_DIR:-/tmp}/rice-game-mode"
NOTIFY_APP="rice-game"

notify() {
    gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "$NOTIFY_APP" 0 "" "GAME MODE" "$1" "[]" "{}" 2500 \
        >/dev/null 2>&1
}

if [ -f "$STATE/active" ]; then
    if [ -f "$STATE/inhibit.pid" ]; then
        kill "$(cat "$STATE/inhibit.pid")" 2>/dev/null || true
    fi
    previous=$(cat "$STATE/previous-profile" 2>/dev/null || echo balanced)
    previous_mode=$(cat "$STATE/previous-mode" 2>/dev/null || true)
    powerprofilesctl set "$previous" >/dev/null 2>&1 || true
    if [ -n "$previous_mode" ]; then
        makoctl mode -s "$previous_mode" >/dev/null 2>&1 || true
    else
        makoctl mode -s default >/dev/null 2>&1 || true
    fi
    rm -rf "$STATE"
    notify "OFF // perfil $previous // notificaciones ON"
    exit 0
fi

mkdir -p "$STATE"
: > "$STATE/active"
previous=$(powerprofilesctl get 2>/dev/null || echo balanced)
previous_mode=$(makoctl mode 2>/dev/null | tr -d '\n')
printf '%s\n' "$previous" > "$STATE/previous-profile"
printf '%s\n' "$previous_mode" > "$STATE/previous-mode"

powerprofilesctl set performance >/dev/null 2>&1 || true
makoctl mode -s do-not-disturb >/dev/null 2>&1 || true
systemd-inhibit --what=idle:sleep --why="Rice game mode" sleep infinity \
    >/dev/null 2>&1 &
printf '%s\n' "$!" > "$STATE/inhibit.pid"

notify "ON // performance // DND // idle inhibido"
