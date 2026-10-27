#!/bin/sh
# finamp-launch.sh — cliente de música Jellyfin (solo biblioteca musical).
if command -v finamp >/dev/null 2>&1; then
    exec finamp
fi
if flatpak info com.unicornsonlsd.finamp >/dev/null 2>&1; then
    exec flatpak run com.unicornsonlsd.finamp
fi
"$HOME/.local/bin/notify.sh" rice-finamp "FINAMP" "Finamp no está instalado"
exit 0
