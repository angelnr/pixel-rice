#!/bin/sh
# steam-launch.sh — abre Steam nativo o Flatpak; si no está, ofrece instalarlo.

if [ -z "${DISPLAY:-}" ]; then
    DISPLAY=$("$HOME/.local/bin/xdisplay.sh")
    export DISPLAY
fi

if command -v steam >/dev/null 2>&1; then
    exec steam
fi

if flatpak info com.valvesoftware.Steam >/dev/null 2>&1; then
    exec flatpak run com.valvesoftware.Steam
fi

choice=$(printf '%s\n' 'INSTALL STEAM (FLATPAK)' 'CANCEL' \
    | fuzzel --dmenu --prompt='STEAM > ' --lines=2 --width=30 2>/dev/null)

case "$choice" in
    'INSTALL STEAM (FLATPAK)')
        exec kitty --title STEAM-INSTALL -e sh -c \
            'flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; flatpak install --user -y flathub com.valvesoftware.Steam; printf "\n\nPulsa Enter para cerrar..."; read -r _'
        ;;
esac
