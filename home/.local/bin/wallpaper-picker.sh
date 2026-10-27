#!/bin/sh
# wallpaper-picker.sh — abre el selector visual de wallpapers.
"$HOME/.local/bin/wallpaper-thumbs.sh" >/dev/null 2>&1 || true
exec "$HOME/.local/bin/wallpaper-picker.py"
