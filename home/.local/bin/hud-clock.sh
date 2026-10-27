#!/bin/sh
# hud-clock.sh — reloj del HUD: HH:MM | MON 26 OCT (siempre en inglés).
LC_TIME=C date '+%H:%M | %^a %d %^b'
