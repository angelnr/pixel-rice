#!/bin/sh
# tailscale-menu.sh — estado, up/down, IP y SSH a peers de Tailscale.

json=$(tailscale status --json 2>/dev/null)
peers=$(printf '%s' "$json" | jq -r '.Peer[]? | select(.Online == true) | .HostName + "|" + (.TailscaleIPs[0] // "")' 2>/dev/null | sort -u)

menu=$(printf '%s\n' 'STATUS' 'UP' 'DOWN' 'COPY IP')
if [ -n "$peers" ]; then
    while IFS='|' read -r host ip; do
        [ -n "$host" ] || continue
        menu="$menu
SSH $host"
    done <<EOF
$peers
EOF
fi

choice=$(printf '%s\n' "$menu" | fuzzel --dmenu --prompt='TAILSCALE > ' --lines=14 --width=42 2>/dev/null)
[ -n "$choice" ] || exit 0

case "$choice" in
    STATUS)
        exec kitty --title TAILSCALE -e sh -c 'tailscale status; printf "\n\nPulsa Enter para cerrar..."; read -r _'
        ;;
    UP)
        exec kitty --title TAILSCALE -e sh -c 'tailscale up; printf "\n\nPulsa Enter para cerrar..."; read -r _'
        ;;
    DOWN)
        tailscale down >/dev/null 2>&1
        "$HOME/.local/bin/notify.sh" rice-tailscale "TAILSCALE" "VPN desactivada"
        ;;
    'COPY IP')
        ip=$(tailscale ip -4 2>/dev/null | head -1)
        [ -n "$ip" ] && printf '%s' "$ip" | wl-copy
        "$HOME/.local/bin/notify.sh" rice-tailscale "TAILSCALE" "IP copiada: ${ip:-n/d}"
        ;;
    SSH\ *)
        host=${choice#SSH }
        exec kitty --title "SSH $host" -e ssh "$host"
        ;;
esac
