#!/bin/sh
# yazi-shell.sh — abre Yazi y al salir deja una shell en el último directorio.
tmp=$(mktemp -t yazi-cwd.XXXXXX)
yazi --cwd-file="$tmp"
if [ -s "$tmp" ]; then
    cwd=$(cat "$tmp")
    [ -n "$cwd" ] && cd "$cwd" 2>/dev/null || true
fi
rm -f "$tmp"
exec bash -l
