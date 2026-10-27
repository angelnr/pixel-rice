#!/bin/sh
# install/external.sh — binarios que no están en los repos de Debian.
set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BIN="$HOME/.local/bin"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$BIN" "$HOME/.local/share"

need() {
    command -v "$1" >/dev/null 2>&1 || { echo "falta $1" >&2; exit 1; }
}
need curl
need tar
need unzip

echo "== Yazi 26.9.1"
curl -L --fail -o "$TMP/yazi.zip" \
    https://github.com/sxyazi/yazi/releases/download/v26.9.1/yazi-x86_64-unknown-linux-gnu.zip
unzip -q "$TMP/yazi.zip" -d "$TMP/yazi"
find "$TMP/yazi" -type f -name yazi -exec install -m755 {} "$BIN/yazi" \;
find "$TMP/yazi" -type f -name ya -exec install -m755 {} "$BIN/ya" \;

echo "== matugen 4.2.0"
curl -L --fail -o "$TMP/matugen.tar.gz" \
    https://github.com/InioX/matugen/releases/download/v4.2.0/matugen-4.2.0-x86_64.tar.gz
tar -xzf "$TMP/matugen.tar.gz" -C "$TMP"
find "$TMP" -type f -name matugen -exec install -m755 {} "$BIN/matugen" \;

echo "== jfsh 0.2.1"
curl -L --fail -o "$TMP/jfsh.tar.gz" \
    https://github.com/hacel/jfsh/releases/download/v0.2.1/jfsh_0.2.1_linux_amd64.tar.gz
tar -xzf "$TMP/jfsh.tar.gz" -C "$TMP"
find "$TMP" -type f -name jfsh -exec install -m755 {} "$BIN/jfsh" \;

echo "== ble.sh 0.4.0-devel3"
curl -L --fail -o "$TMP/ble.tar.xz" \
    https://github.com/akinomyoga/ble.sh/releases/download/v0.4.0-devel3/ble-0.4.0-devel3.tar.xz
rm -rf "$HOME/.local/share/blesh"
mkdir -p "$HOME/.local/share/blesh"
tar -xJf "$TMP/ble.tar.xz" -C "$TMP"
cp -a "$TMP"/ble-0.4.0-devel3/. "$HOME/.local/share/blesh/"

echo "== ouch 0.8.3"
curl -L --fail -o "$TMP/ouch.tar.gz" \
    https://github.com/ouch-org/ouch/releases/download/0.8.3/ouch-x86_64-unknown-linux-musl.tar.gz
tar -xzf "$TMP/ouch.tar.gz" -C "$TMP"
find "$TMP" -type f -name ouch -exec install -m755 {} "$BIN/ouch" \;

echo "Binarios externos instalados en $BIN"
echo "niri 26.04 y xwayland-satellite se instalan aparte (ver README)."
