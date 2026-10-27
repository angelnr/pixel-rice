#!/bin/sh
# sound-test.sh — escucha el tema de sonidos pixel con fuzzel.
# Uso: sound-test.sh  ·  también disponible en Mod+Shift+A

DIR="$HOME/.local/share/sounds/pixel/stereo"
[ -d "$DIR" ] || exit 0

choice=$(
    {
        printf '%s\n' '▶ PLAY ALL'
        for f in "$DIR"/*.wav; do
            [ -f "$f" ] && basename "$f" .wav
        done | sort
    } | fuzzel --dmenu --prompt='SOUND TEST > ' --lines=13 --width=34 2>/dev/null
)

[ -n "$choice" ] || exit 0

case "$choice" in
    *"PLAY ALL")
        for f in "$DIR"/*.wav; do
            [ -f "$f" ] && paplay "$f"
        done
        ;;
    *)
        [ -f "$DIR/$choice.wav" ] && paplay "$DIR/$choice.wav"
        ;;
esac
