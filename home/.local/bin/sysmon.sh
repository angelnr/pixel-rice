#!/bin/sh
# sysmon.sh — monitor de sistema en una ventana flotante con estética HUD.
# htop no está instalado, así que usamos top (siempre presente en Debian).

exec kitty \
    --title SYS-MON \
    --class sysmon \
    -o background_opacity=1.0 \
    -o window_padding_width=4 \
    -e top -d 1
