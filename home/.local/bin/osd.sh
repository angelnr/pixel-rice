#!/bin/sh
# osd.sh <titulo> <porcentaje> — envía la barra al daemon OSD (una sola notificación)
label="$1"
pct=$(printf '%.0f' "${2:-0}" 2>/dev/null || echo 0)
[ "$pct" -lt 0 ] && pct=0
[ "$pct" -gt 100 ] && pct=100

FIFO="${XDG_RUNTIME_DIR:-/tmp}/rice-osd.fifo"

if [ -p "$FIFO" ]; then
  timeout 0.3 sh -c 'printf "%s|%s\n" "$1" "$2" > "$3"' _ "$label" "$pct" "$FIFO" 2>/dev/null || true
fi
exit 0
