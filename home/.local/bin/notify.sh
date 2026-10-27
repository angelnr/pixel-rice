#!/bin/sh
# notify.sh <app> <summary> <body>
app=${1:-rice}
summary=${2:-PIXEL HUD}
body=${3:-}
gdbus call --session \
    --dest org.freedesktop.Notifications \
    --object-path /org/freedesktop/Notifications \
    --method org.freedesktop.Notifications.Notify \
    "$app" 0 "" "$summary" "$body" "[]" "{}" 2500 \
    >/dev/null 2>&1
