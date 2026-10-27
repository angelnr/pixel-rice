#!/bin/sh
# media-status.sh — salida JSON para el módulo custom/music de Waybar.
# Requiere playerctl. Si no hay reproductor, no imprime nada y Waybar oculta
# el módulo (hide-empty-text).

status=$(playerctl status 2>/dev/null) || exit 0
case "$status" in
    Playing|Paused) ;;
    *) exit 0 ;;
esac

title=$(playerctl metadata --format '{{title}}' 2>/dev/null)
artist=$(playerctl metadata --format '{{artist}}' 2>/dev/null)
case "$title" in
    ""|"No title"|"Unknown"|"unknown") exit 0 ;;
esac

json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

t=$(json_escape "$title")
a=$(json_escape "$artist")
cls=$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')

if [ -n "$artist" ]; then
    tooltip="$t\\n$a"
else
    tooltip="$t"
fi

# El artista va al tooltip para que el módulo no ocupe media barra.
printf '{"text":"// ♪ %s","class":"%s","tooltip":"%s"}\n' "$t" "$cls" "$tooltip"
