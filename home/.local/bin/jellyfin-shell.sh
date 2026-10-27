#!/bin/sh
# jellyfin-shell.sh — abre jfsh (TUI de Jellyfin) con mpv Flatpak.
exec kitty --title JELLYFIN -e env PATH="$HOME/.local/libexec:$PATH" jfsh
