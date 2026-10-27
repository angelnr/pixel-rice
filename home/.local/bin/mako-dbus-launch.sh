#!/bin/sh
# mako-dbus-launch.sh — arranca Mako desde D-Bus con entorno Wayland.
# D-Bus no siempre hereda WAYLAND_DISPLAY; lo descubrimos aquí.

set -u

if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
    XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export XDG_RUNTIME_DIR
fi

if [ -z "${WAYLAND_DISPLAY:-}" ]; then
    for sock in "$XDG_RUNTIME_DIR"/wayland-*; do
        [ -S "$sock" ] || continue
        WAYLAND_DISPLAY=${sock##*/}
        export WAYLAND_DISPLAY
        break
    done
fi

exec "$HOME/.local/bin/mako" "$@"
