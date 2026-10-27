#!/bin/sh
# install-sddm-theme.sh — instala el tema Pixel HUD en SDDM.
# Requiere sudo (te pedirá la contraseña). No reinicia la sesión.

set -eu

SRC="$HOME/.config/sddm/themes/pixel-hud"
DST="/usr/share/sddm/themes/pixel-hud"
CONF="/etc/sddm.conf.d/zz-pixel-hud.conf"

[ -d "$SRC" ] || { echo "No existe $SRC" >&2; exit 1; }

sudo rm -rf "$DST"
sudo cp -r "$SRC" "$DST"
sudo chmod -R a+rX "$DST"

# Avatar pixel art para el usuario (SDDM no puede leer $HOME por permisos)
if [ -f "$HOME/Imágenes/terminal_image.png" ]; then
    sudo cp "$HOME/Imágenes/terminal_image.png" /usr/share/sddm/faces/angel.face.icon
    sudo chmod 644 /usr/share/sddm/faces/angel.face.icon
fi

sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=pixel-hud\n' | sudo tee "$CONF" >/dev/null

echo "Tema instalado en $DST"
echo "Configuración: $CONF"
echo "Reinicia SDDM o el equipo para verlo:"
echo "  sudo systemctl restart sddm"
