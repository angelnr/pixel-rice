#!/bin/sh
# install/flatpak.sh — apps Flatpak del rice.
set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
command -v flatpak >/dev/null 2>&1 || { echo "flatpak no instalado" >&2; exit 1; }

flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
while IFS= read -r app; do
    [ -n "$app" ] || continue
    flatpak install --user -y flathub "$app"
done < "$REPO/packages/flatpak.txt"
