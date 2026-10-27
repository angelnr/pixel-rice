#!/bin/sh
# cava-toggle.sh — abre/cierra el visualizador CAVA en una ventana flotante.
# La regla de niri hace flotante la ventana con título CAVA.

if pgrep -x cava >/dev/null 2>&1; then
    pkill -x cava
    exit 0
fi

exec kitty \
    --title CAVA \
    --class cava \
    -o background_opacity=1.0 \
    -o window_padding_width=0 \
    -o confirm_os_window_close=0 \
    -e cava
