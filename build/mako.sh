#!/bin/sh
# build/mako.sh — compila Mako 1.11.0 + parche de animaciones (slide-in + fade-out).
#
# Dependencias Debian 13:
#   sudo apt install build-essential meson ninja-build pkg-config \
#     libcairo2-dev libpango1.0-dev libglib2.0-dev libgdk-pixbuf-2.0-dev \
#     libwayland-dev wayland-protocols libsystemd-dev
#
# Uso:
#   ./build/mako.sh
#   MAKO_SRC=/ruta/a/mako MAKO_BUILD=/tmp/build MAKO_PREFIX=/tmp/prefix ./build/mako.sh
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO=$(CDPATH= cd -- "$HERE/.." && pwd)
PATCH="$REPO/patches/mako-anim.patch"
VERSION="1.11.0"
SRC=${MAKO_SRC:-"$HOME/.local/src/mako"}
BUILD=${MAKO_BUILD:-"$HOME/.local/src/mako-build"}
PREFIX=${MAKO_PREFIX:-"$HOME/.local"}

for c in git meson ninja cc pkg-config; do
    command -v "$c" >/dev/null 2>&1 || {
        echo "falta '$c'" >&2
        echo "instala: sudo apt install build-essential meson ninja-build pkg-config libcairo2-dev libpango1.0-dev libglib2.0-dev libgdk-pixbuf-2.0-dev libwayland-dev wayland-protocols libsystemd-dev" >&2
        exit 1
    }
done

[ -f "$PATCH" ] || { echo "no existe $PATCH" >&2; exit 1; }

if [ ! -d "$SRC/.git" ]; then
    mkdir -p "$(dirname "$SRC")"
    git clone --depth 1 --branch "v$VERSION" https://github.com/emersion/mako.git "$SRC"
fi

git -C "$SRC" fetch --depth 1 origin "v$VERSION" 2>/dev/null || true
git -C "$SRC" checkout -f "v$VERSION"
git -C "$SRC" reset --hard "v$VERSION"
git -C "$SRC" clean -fdx
git -C "$SRC" apply --check "$PATCH"
git -C "$SRC" apply "$PATCH"

rm -rf "$BUILD"
meson setup "$BUILD" "$SRC" \
    --prefix="$PREFIX" \
    --buildtype=release \
    -Dicons=enabled
ninja -C "$BUILD"

install -d "$PREFIX/bin"
install -m755 "$BUILD/mako" "$PREFIX/bin/mako"
install -m755 "$BUILD/makoctl" "$PREFIX/bin/makoctl"

if [ "$PREFIX" = "$HOME/.local" ]; then
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user restart mako 2>/dev/null || true
fi

echo "Mako $VERSION + animaciones instalado en $PREFIX/bin"
"$PREFIX/bin/mako" --help >/dev/null 2>&1 || true
