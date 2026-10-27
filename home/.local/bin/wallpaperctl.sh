#!/bin/sh
# wallpaperctl.sh rotate | rotate-all | set LEVEL PATH | set-current PATH | reload | quit
FIFO="${XDG_RUNTIME_DIR:-/tmp}/rice-wallpaper.fifo"
if [ ! -p "$FIFO" ]; then
    FIFO="$HOME/.cache/rice/wallpaperd.fifo"
fi
[ -p "$FIFO" ] || exit 1

cmd="$*"
[ -n "$cmd" ] || exit 1

timeout 0.5 sh -c 'printf "%s\n" "$1" > "$2"' _ "$cmd" "$FIFO" 2>/dev/null || true
