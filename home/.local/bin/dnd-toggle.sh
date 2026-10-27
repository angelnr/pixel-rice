#!/bin/sh
# dnd-toggle.sh — alterna el modo do-not-disturb de mako.

makoctl mode -t do-not-disturb >/dev/null 2>&1 || true
exec "$HOME/.local/bin/dnd-status.sh"
