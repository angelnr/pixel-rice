#!/bin/sh
# bootstrap.sh — instalación completa en Debian 13 (ejecutar como usuario normal).
set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

echo "== 1/5 paquetes del sistema + SDDM"
"$REPO/install/system.sh"

echo "== 2/5 binarios externos"
"$REPO/install/external.sh"

echo "== 3/5 Mako 1.11 + animaciones"
"$REPO/build/mako.sh"

echo "== 4/5 dotfiles + servicios"
"$REPO/install/user.sh"

echo "== 5/5 Flatpaks"
"$REPO/install/flatpak.sh"

echo
echo "Instalación base terminada."
echo "Revisa docs/POST-INSTALL.md para Tailscale, Jellyfin, Brave, SSH y niri."
