#!/bin/sh
# lock.sh — genera una pantalla de bloqueo pixel art (Gengar + HUD) y lanza
# swaylock. El reloj se dibuja al bloquear porque swaylock 1.8 no tiene reloj
# en vivo; el indicador de contraseña sigue siendo el nativo y discreto.

set -u

OUT="${XDG_RUNTIME_DIR:-/tmp}/rice-lock.png"
SRC="$HOME/Imágenes/terminal_image.png"
SOUNDS="$HOME/.local/share/sounds/pixel/stereo"

size=$(niri msg outputs 2>/dev/null | awk '/Logical size:/{print $3; exit}')
case "$size" in
    *x*) W=${size%x*}; H=${size#*x} ;;
    *)   W=1920; H=1080 ;;
esac
case "${W}${H}" in
    *[!0-9]*) W=1920; H=1080 ;;
esac

if [ -f "$SRC" ]; then
    LC_TIME=C magick -size "${W}x${H}" xc:'#0b1014' \
        \( "$SRC" -filter point -resize '700x700' \) \
        -gravity east -geometry +120+20 -composite \
        -font 'Spleen-16x32' -fill '#5cc8d7' -pointsize 64 \
        -gravity northwest -annotate +110+105 'SYSTEM LOCKED' \
        -font 'Spleen-32x64' -fill '#dfe7e8' -pointsize 150 \
        -gravity northwest -annotate +100+190 "$(date +%H:%M)" \
        -font 'Spleen-8x16' -fill '#b48ead' -pointsize 30 \
        -gravity northwest -annotate +112+390 "$(LC_TIME=C date '+%^a %d %^b')" \
        -fill '#e0af68' -pointsize 22 \
        -gravity southwest -annotate +110+110 'ENTER PASSWORD // PRESS ENTER' \
        -fill none -stroke '#5cc8d7' -strokewidth 2 \
        -draw "rectangle 24,24 $((W - 24)),$((H - 24))" \
        -depth 8 "$OUT" 2>/dev/null
else
    LC_TIME=C magick -size "${W}x${H}" xc:'#0b1014' \
        -font 'Spleen-16x32' -fill '#5cc8d7' -pointsize 64 \
        -gravity northwest -annotate +110+105 'SYSTEM LOCKED' \
        -font 'Spleen-32x64' -fill '#dfe7e8' -pointsize 150 \
        -gravity northwest -annotate +100+190 "$(date +%H:%M)" \
        -fill none -stroke '#5cc8d7' -strokewidth 2 \
        -draw "rectangle 24,24 $((W - 24)),$((H - 24))" \
        -depth 8 "$OUT" 2>/dev/null
fi

if [ ! -s "$OUT" ]; then
    exec swaylock -f
fi

chmod 600 "$OUT" 2>/dev/null || true
[ -f "$SOUNDS/service-logout.wav" ] && paplay "$SOUNDS/service-logout.wav" >/dev/null 2>&1 &
swaylock -f -i "$OUT" -s fill -c 0b1014
[ -f "$SOUNDS/service-login.wav" ] && paplay "$SOUNDS/service-login.wav" >/dev/null 2>&1 &
exit 0
