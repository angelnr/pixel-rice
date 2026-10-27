#!/bin/sh
# dock-toggle.sh — muestra/oculta el dock manualmente.
systemctl --user kill --kill-whom=main --signal=SIGUSR1 pixel-dock.service 2>/dev/null || true
