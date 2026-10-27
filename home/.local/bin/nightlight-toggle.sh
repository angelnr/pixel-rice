#!/bin/sh
# nightlight-toggle.sh — activa/desactiva wlsunset (luz cálida 3500K).

if systemctl --user is-active --quiet wlsunset.service; then
    systemctl --user stop wlsunset.service
    "$HOME/.local/bin/notify.sh" "rice-night" "NIGHT LIGHT" "Desactivada"
else
    systemctl --user start wlsunset.service
    "$HOME/.local/bin/notify.sh" "rice-night" "NIGHT LIGHT" "Activada · 3500K"
fi
