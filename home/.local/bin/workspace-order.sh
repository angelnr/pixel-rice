#!/bin/sh
# workspace-order.sh — fija el orden de los niveles del HUD.
# Niri crea los workspaces con nombre en un orden que puede variar al
# recargar la configuración; este script los deja siempre igual al arrancar.

for _ in $(seq 1 40); do
    niri msg version >/dev/null 2>&1 && break
    sleep 0.2
done

idx=1
for name in HOME DEV MUSIC GAME; do
    niri msg action move-workspace-to-index "$idx" --reference "$name" >/dev/null 2>&1 || true
    idx=$((idx + 1))
done

niri msg action focus-workspace "HOME" >/dev/null 2>&1 || true
