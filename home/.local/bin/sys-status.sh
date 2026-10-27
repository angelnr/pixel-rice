#!/bin/sh
# sys-status.sh — CPU + RAM compactos para el HUD.
# vmstat 1 2 da una medida instantánea; free da el uso de memoria.

cpu=$(vmstat 1 2 2>/dev/null | tail -1 | awk '{printf "%.0f", 100 - $15}')
[ -n "$cpu" ] || cpu=0

mem_info=$(free -h | awk '/^Mem:/ {print $3, $2}')
mem_pct=$(free | awk '/^Mem:/ {printf "%.0f", $3 / $2 * 100}')
used=$(free -h | awk '/^Mem:/ {print $3}')
total=$(free -h | awk '/^Mem:/ {print $2}')
load=$(cut -d' ' -f1-3 /proc/loadavg)
disk=$(df -h / 2>/dev/null | awk 'NR==2 {print $3" / "$2" ("$5")"}')
[ -n "$disk" ] || disk="n/d"

printf '{"text":"// SYS %s/%s","class":"sys","tooltip":"CPU: %s%%\\nRAM: %s / %s (%s%%)\\nDisco: %s\\nLoad: %s\\nClic: monitor de sistema"}\n' \
    "$cpu" "$mem_pct" "$cpu" "$used" "$total" "$mem_pct" "$disk" "$load"
