#!/bin/sh
# ts-status.sh — estado de Tailscale para Waybar (JSON).

json=$(tailscale status --json 2>/dev/null)
if [ -z "$json" ]; then
    printf '{"text":"// TS OFF","class":"off","tooltip":"Tailscale no disponible"}'
    exit 0
fi

state=$(printf '%s' "$json" | jq -r '.BackendState // "Unknown"')
ip=$(printf '%s' "$json" | jq -r '.Self.TailscaleIPs[0] // ""')
online=$(printf '%s' "$json" | jq -r '[.Peer[]? | select(.Online == true) | .HostName] | join(", ")')

if [ "$state" = "Running" ]; then
    text="// TS"
    cls="on"
else
    text="// TS OFF"
    cls="off"
fi

tooltip="Tailscale: $state"
[ -n "$ip" ] && tooltip="$tooltip\nIP: $ip"
[ -n "$online" ] && tooltip="$tooltip\nOnline: $online"

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$cls" "$tooltip"
