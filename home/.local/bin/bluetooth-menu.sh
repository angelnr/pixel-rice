#!/bin/sh
# bluetooth-menu.sh — conecta/desconecta dispositivos Bluetooth emparejados.
# Se lanza desde el módulo Bluetooth de Waybar.

if ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then
    bluetoothctl power on >/dev/null 2>&1
    exit 0
fi

devices=$(bluetoothctl devices Paired 2>/dev/null)
if [ -z "$devices" ]; then
    gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "rice" 0 "" "BLUETOOTH" "No hay dispositivos emparejados" "[]" "{}" 3000 \
        >/dev/null 2>&1
    exit 0
fi

choice=$(printf '%s\n' "$devices" \
    | sed 's/^Device //' \
    | fuzzel --dmenu --prompt='BLUETOOTH > ' --lines=10 --width=42 2>/dev/null)

[ -n "$choice" ] || exit 0

mac=${choice%% *}
if bluetoothctl info "$mac" 2>/dev/null | grep -q 'Connected: yes'; then
    bluetoothctl disconnect "$mac" >/dev/null 2>&1
else
    bluetoothctl connect "$mac" >/dev/null 2>&1
fi
