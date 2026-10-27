#!/bin/sh
# nightlight-status.sh — estado de wlsunset para Waybar (JSON).

if systemctl --user is-active --quiet wlsunset.service; then
    printf '{"text":"// NIGHT","class":"on","tooltip":"Luz nocturna: ON (3500K)"}'
else
    printf '{"text":"// DAY","class":"off","tooltip":"Luz nocturna: OFF"}'
fi
