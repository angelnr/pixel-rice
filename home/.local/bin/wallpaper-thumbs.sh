#!/usr/bin/env bash
# wallpaper-thumbs.sh — genera miniaturas para el selector de wallpapers.
set -eu
DIR="$HOME/Imágenes/pixel_art"
OUT="$HOME/.cache/rice/wall-thumbs"
mkdir -p "$OUT"

find "$DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) -print0 |
while IFS= read -r -d '' img; do
    name=$(basename "$img")
    thumb="$OUT/$name.jpg"
    if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
        magick "$img" -thumbnail '320x180^' -gravity center -extent 320x180 \
            -quality 85 "$thumb" 2>/dev/null || true
    fi
done
