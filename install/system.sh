#!/bin/sh
# install/system.sh — paquetes base y tema SDDM. Requiere sudo.
set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SUDO=""
[ "$(id -u)" -eq 0 ] || SUDO="sudo"

echo "== APT"
$SUDO apt-get update
# shellcheck disable=SC2046
$SUDO apt-get install -y $(grep -vE '^\s*(#|$)' "$REPO/packages/apt-essential.txt" | tr '\n' ' ')

echo "== tema SDDM"
$SUDO install -d /usr/share/sddm/themes /etc/sddm.conf.d
$SUDO rm -rf /usr/share/sddm/themes/pixel-hud
$SUDO cp -a "$REPO/assets/sddm/pixel-hud" /usr/share/sddm/themes/
$SUDO install -m644 "$REPO/install/zz-pixel-hud.conf" /etc/sddm.conf.d/zz-pixel-hud.conf

echo "== SDDM habilitado"
$SUDO systemctl enable sddm >/dev/null 2>&1 || true

echo "Paquetes y SDDM instalados."
echo "Falta: niri 26.04, binarios externos, Mako, Flatpaks y pasos manuales."
