#!/bin/sh
# cal-popup.sh — calendario estilo HUD en fuzzel (sin dependencias extra)
text=$(python3 -c 'import calendar, datetime; d = datetime.date.today(); print(calendar.month(d.year, d.month))')
printf '%s\n' "$text" | fuzzel --dmenu --lines=9 --width=24 --prompt='CALENDAR // ' >/dev/null 2>&1
