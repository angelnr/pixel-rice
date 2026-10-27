#!/bin/sh
# xdisplay.sh — imprime el DISPLAY de xwayland-satellite del usuario.
for sock in /tmp/.X11-unix/X*; do
    [ -S "$sock" ] || continue
    [ "$(stat -c %U "$sock" 2>/dev/null)" = "$(id -un)" ] || continue
    printf ':%s\n' "${sock##*X}"
    exit 0
done
