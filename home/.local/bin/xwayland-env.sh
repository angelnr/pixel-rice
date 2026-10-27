#!/bin/sh
# xwayland-env.sh — exporta DISPLAY de xwayland-satellite a systemd/dbus.
# Steam Flatpak y systemd-run lo necesitan para abrir ventanas X11.

DISPLAY_NUM=""
for _ in $(seq 1 100); do
    for sock in /tmp/.X11-unix/X*; do
        [ -S "$sock" ] || continue
        # Preferimos un socket del usuario actual; X0 puede ser de root/SDDM.
        [ "$(stat -c %U "$sock" 2>/dev/null)" = "$(id -un)" ] || continue
        DISPLAY_NUM=${sock##*X}
        break 2
    done
    sleep 0.2
done

[ -n "$DISPLAY_NUM" ] || exit 0
export DISPLAY=":$DISPLAY_NUM"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

systemctl --user set-environment DISPLAY="$DISPLAY" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" 2>/dev/null || true
dbus-update-activation-environment --systemd DISPLAY="$DISPLAY" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" 2>/dev/null || true
