#!/bin/sh
# dnd-status.sh — estado de "no molestar" para Waybar (JSON).

if makoctl mode 2>/dev/null | grep -qx 'do-not-disturb'; then
    printf '{"text":"// DND","class":"dnd","tooltip":"No molestar: ON"}'
else
    printf '{"text":"// NTF","class":"normal","tooltip":"Notificaciones: ON"}'
fi
