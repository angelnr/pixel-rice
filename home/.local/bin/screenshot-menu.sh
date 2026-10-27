#!/bin/sh
# screenshot-menu.sh — capturas de región/pantalla y cuentagotas HUD.

DIR="$HOME/Imágenes/Capturas"
mkdir -p "$DIR"

choice=$(printf '%s\n' \
    'REGION // FILE' \
    'REGION // CLIPBOARD' \
    'FULL // FILE' \
    'FULL // CLIPBOARD' \
    'WINDOW // FILE' \
    'COLOR // HEX' \
    | fuzzel --dmenu --prompt='CAPTURE > ' --lines=6 --width=30 2>/dev/null)

[ -n "$choice" ] || exit 0

name="Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"

case "$choice" in
    'REGION // FILE')
        geom=$(slurp -d -b '#0e1418cc' -c '#5cc8d7ff' -s '#5cc8d733' -w 2) || exit 0
        [ -n "$geom" ] || exit 0
        grim -g "$geom" "$DIR/$name" || exit 0
        "$HOME/.local/bin/notify.sh" rice-screenshot "CAPTURE" "Región guardada: $name"
        ;;
    'REGION // CLIPBOARD')
        geom=$(slurp -d -b '#0e1418cc' -c '#5cc8d7ff' -s '#5cc8d733' -w 2) || exit 0
        [ -n "$geom" ] || exit 0
        grim -g "$geom" - | wl-copy || exit 0
        "$HOME/.local/bin/notify.sh" rice-screenshot "CAPTURE" "Región copiada al portapapeles"
        ;;
    'FULL // FILE')
        grim "$DIR/$name" || exit 0
        "$HOME/.local/bin/notify.sh" rice-screenshot "CAPTURE" "Pantalla guardada: $name"
        ;;
    'FULL // CLIPBOARD')
        grim - | wl-copy || exit 0
        "$HOME/.local/bin/notify.sh" rice-screenshot "CAPTURE" "Pantalla copiada al portapapeles"
        ;;
    'WINDOW // FILE')
        niri msg action screenshot-window >/dev/null 2>&1 || exit 0
        "$HOME/.local/bin/notify.sh" rice-screenshot "CAPTURE" "Ventana guardada en $DIR"
        ;;
    'COLOR // HEX')
        color=$(niri msg pick-color 2>/dev/null | grep -oE '#[0-9a-fA-F]{6}' | head -1)
        [ -n "$color" ] || exit 0
        printf '%s' "$color" | wl-copy
        "$HOME/.local/bin/notify.sh" rice-screenshot "COLOR PICKER" "HEX copiado: $color"
        ;;
esac
