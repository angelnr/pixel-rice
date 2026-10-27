#!/bin/sh
# group-launch.sh [--force] GROUP
# Enfoca el workspace del grupo y lanza sus apps una vez por sesión.
# Configuración: ~/.config/rice/groups.json

force=0
if [ "${1:-}" = "--force" ]; then
    force=1
    shift
fi

group=${1:-}
[ -n "$group" ] || exit 1

if [ -z "${DISPLAY:-}" ]; then
    DISPLAY=$("$HOME/.local/bin/xdisplay.sh")
    export DISPLAY
fi

# Primero enfocamos el nivel, así las apps abren ahí.
niri msg action focus-workspace "$group" >/dev/null 2>&1 || true

runtime="${XDG_RUNTIME_DIR:-/tmp}"
marker="$runtime/rice-group-${group}.done"
if [ "$force" = "1" ]; then
    rm -f "$marker"
fi
[ -f "$marker" ] && exit 0
: > "$marker"

conf="$HOME/.config/rice/groups.json"
[ -f "$conf" ] || exit 0

command -v jq >/dev/null 2>&1 || exit 0

jq -r --arg g "$group" '.[$g][]?' "$conf" 2>/dev/null |
while IFS= read -r cmd; do
    [ -n "$cmd" ] || continue
    first=$(printf '%s' "$cmd" | awk '{print $1}')
    case "$first" in
        /*) [ -x "$first" ] || continue ;;
        *) command -v "$first" >/dev/null 2>&1 || continue ;;
    esac
    unit="rice-group-${group}-$(date +%s%N)"
    systemd-run --user --scope --no-block --collect --quiet \
        --unit="$unit" sh -c "$cmd" >/dev/null 2>&1 &
done
