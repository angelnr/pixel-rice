#!/bin/sh
# install/user.sh — copia la configuración de usuario y activa servicios.
set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BACKUP="$HOME/rice-backup-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share/applications" \
         "$HOME/.local/share/dbus-1/services" "$HOME/.local/libexec"

echo "== backup de configuraciones existentes: $BACKUP"
mkdir -p "$BACKUP"
for d in "$HOME/.config/niri" "$HOME/.config/waybar" "$HOME/.config/mako" \
         "$HOME/.config/yazi" "$HOME/.config/kitty" "$HOME/.config/fuzzel" \
         "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/cava" \
         "$HOME/.config/swaylock" "$HOME/.config/matugen" "$HOME/.config/rice" \
         "$HOME/.config/systemd" "$HOME/.local/bin" "$HOME/.local/libexec" \
         "$HOME/.bashrc" "$HOME/.profile"; do
    [ -e "$d" ] && cp -a "$d" "$BACKUP/" 2>/dev/null || true
done

echo "== copiando dotfiles"
cp -a "$REPO/home/.config/." "$HOME/.config/"
cp -a "$REPO/home/.bashrc" "$REPO/home/.profile" "$HOME/"
cp -a "$REPO/home/.local/bin/." "$HOME/.local/bin/"
cp -a "$REPO/home/.local/share/applications/." "$HOME/.local/share/applications/"
cp -a "$REPO/home/.local/share/dbus-1/services/." "$HOME/.local/share/dbus-1/services/"
cp -a "$REPO/home/.local/libexec/." "$HOME/.local/libexec/"
chmod +x "$HOME/.local/bin/"*.sh "$HOME/.local/bin/"*.py 2>/dev/null || true
chmod +x "$HOME/.local/libexec/mpv" 2>/dev/null || true

echo "== assets"
mkdir -p "$HOME/.local/share/icons" "$HOME/.local/share/sounds" "$HOME/.icons" "$HOME/Imágenes/pixel_art"
cp -a "$REPO/assets/icons/." "$HOME/.local/share/icons/"
cp -a "$REPO/assets/cursors/PixelCursor" "$HOME/.icons/"
cp -a "$REPO/assets/sounds/pixel" "$HOME/.local/share/sounds/"
cp -n "$REPO/assets/wallpapers/"* "$HOME/Imágenes/pixel_art/" 2>/dev/null || true
cp -n "$REPO/assets/terminal_image.png" "$HOME/Imágenes/" 2>/dev/null || true

echo "== sustituyendo @HOME@"
find "$HOME/.config" "$HOME/.local/share" "$HOME/.local/bin" -type f -print0 2>/dev/null |
    xargs -0 -r grep -Il '@HOME@' 2>/dev/null |
    xargs -0 -r sed -i "s|@HOME@|$HOME|g"

# Compatibilidad Debian: fdfind/batcat -> fd/bat
[ -x /usr/bin/fdfind ] && [ ! -e "$HOME/.local/bin/fd" ] && ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd" || true
[ -x /usr/bin/batcat ] && [ ! -e "$HOME/.local/bin/bat" ] && ln -sf /usr/bin/batcat "$HOME/.local/bin/bat" || true

echo "== servicios de usuario"
systemctl --user daemon-reload 2>/dev/null || true
for s in mako waybar pixel-dock pixel-wallpaper clipboard-history notification-history rice-osd; do
    if systemctl --user cat "$s" >/dev/null 2>&1; then
        systemctl --user enable "$s" >/dev/null 2>&1 || true
        systemctl --user restart "$s" >/dev/null 2>&1 || true
    fi
done
systemctl --user enable --now wallpaper-rotate.timer >/dev/null 2>&1 || true

if [ ! -x "$HOME/.local/bin/mako" ]; then
    echo "== Mako no instalado; ejecutando build/mako.sh"
    "$REPO/build/mako.sh" || {
        echo "AVISO: Mako no se pudo compilar. Instala las dependencias de build/mako.sh." >&2
    }
fi

echo
echo "Configuración de usuario instalada."
echo "Backup: $BACKUP"
echo "Siguiente: revisa docs/POST-INSTALL.md"
