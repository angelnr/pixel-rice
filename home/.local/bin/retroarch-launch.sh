#!/bin/sh
# retroarch-launch.sh — abre RetroArch nativo o Flatpak si está instalado.
if command -v retroarch >/dev/null 2>&1; then
    exec retroarch
fi
if flatpak info org.libretro.RetroArch >/dev/null 2>&1; then
    exec flatpak run org.libretro.RetroArch
fi
exit 0
