#!/bin/sh
# discord-launch.sh — abre Discord nativo o Flatpak si está instalado.
if [ -z "${DISPLAY:-}" ]; then
    DISPLAY=$("$HOME/.local/bin/xdisplay.sh")
    export DISPLAY
fi
if command -v discord >/dev/null 2>&1; then
    exec discord
fi
if flatpak info com.discordapp.Discord >/dev/null 2>&1; then
    exec flatpak run com.discordapp.Discord
fi
exit 0
