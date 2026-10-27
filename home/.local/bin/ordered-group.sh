#!/bin/sh
# ordered-group.sh [--force] GROUP
# Enfoca un nivel, lanza sus apps en orden y coloca las columnas de izquierda
# a derecha. Configuración: ~/.config/rice/groups.json

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

wsid=$(niri msg -j workspaces 2>/dev/null | jq -r --arg g "$group" '.[] | select(.name==$g) | .id' | head -1)
[ -n "$wsid" ] || wsid=0

find_window() {
    app=$1
    title=$2
    niri msg -j windows 2>/dev/null | jq -r --arg app "$app" --arg title "$title" --argjson ws "$wsid" '
        [ .[]
          | select($ws == 0 or .workspace_id == $ws)
          | select((.app_id // "" | test($app))
                   or ($title != "" and (.title // "" | test($title; "i"))))
          | .id
        ] | max // empty'
}

find_new_window() {
    app=$1
    title=$2
    old=$3
    niri msg -j windows 2>/dev/null | jq -r --arg app "$app" --arg title "$title" --argjson ws "$wsid" --arg old "$old" '
        [ .[]
          | select($ws == 0 or .workspace_id == $ws)
          | select((.app_id // "" | test($app))
                   or ($title != "" and (.title // "" | test($title; "i"))))
          | select((.id | tostring) as $i | ($old | split(" ") | index($i)) | not)
          | .id
        ] | max // empty'
}

launch_wait() {
    cmd=$1
    app=$2
    title=$3
    require_new=${4:-0}

    first=$(printf '%s' "$cmd" | awk '{print $1}')
    case "$first" in
        /*) [ -x "$first" ] || return 1 ;;
        *) command -v "$first" >/dev/null 2>&1 || return 1 ;;
    esac

    old_ids=""
    if [ "$require_new" = "1" ] && { [ -n "$app" ] || [ -n "$title" ]; }; then
        old_ids=$(niri msg -j windows 2>/dev/null | jq -r --arg app "$app" --arg title "$title" --argjson ws "$wsid" '
            [ .[]
              | select($ws == 0 or .workspace_id == $ws)
              | select((.app_id // "" | test($app))
                       or ($title != "" and (.title // "" | test($title; "i"))))
              | .id
            ] | join(" ")')
    fi

    unit="rice-group-${group}-$(date +%s%N)"
    systemd-run --user --scope --no-block --collect --quiet \
        --unit="$unit" sh -c "$cmd" >/dev/null 2>&1 &

    if [ -n "$app" ] || [ -n "$title" ]; then
        i=0
        while [ "$i" -lt 50 ]; do
            if [ "$require_new" = "1" ]; then
                id=$(find_new_window "$app" "$title" "$old_ids")
            else
                id=$(find_window "$app" "$title")
            fi
            if [ -n "$id" ]; then
                printf '%s\n' "$id" >> "$ids"
                return 0
            fi
            sleep 0.4
            i=$((i + 1))
        done
        # Fallback: si no apareció una ventana nueva, usa la existente.
        id=$(find_window "$app" "$title")
        [ -n "$id" ] && printf '%s\n' "$id" >> "$ids"
    fi
    return 0
}

ids=$(mktemp)
trap 'rm -f "$ids"' EXIT

jq -r --arg g "$group" '.[$g][]?' "$conf" 2>/dev/null |
while IFS= read -r cmd; do
    [ -n "$cmd" ] || continue
    case "$cmd" in
        *steam*)          app='^steam$'; title='^Steam'; req=0 ;;
        *discord*)        app='^discord$'; title='Discord'; req=0 ;;
        *brave-browser*)  app='^brave-browser$'; title='YouTube'; req=1 ;;
        *retroarch*)      app='retroarch|org\.libretro\.RetroArch'; title='RetroArch'; req=0 ;;
        *finamp*)         app='finamp|com\.unicornsonlsd\.finamp'; title='Finamp'; req=1 ;;
        *code*)           app='^(code|com\.microsoft\.VSCode)$'; title='Visual Studio Code|Release Notes'; req=1 ;;
        *kitty*)          app='^kitty$'; title='DEV-SHELL'; req=1 ;;
        *)                app=''; title=''; req=0 ;;
    esac
    launch_wait "$cmd" "$app" "$title" "$req"
done

# Ordena las columnas en el orden en que se encontraron las ventanas.
niri msg action focus-workspace "$group" >/dev/null 2>&1 || true
sleep 0.2
idx=1
while IFS= read -r id; do
    [ -n "$id" ] || continue
    niri msg action focus-window --id "$id" >/dev/null 2>&1 || continue
    sleep 0.15
    niri msg action move-column-to-index "$idx" >/dev/null 2>&1 || true
    sleep 0.15
    idx=$((idx + 1))
done < "$ids"

printf "group=%s ws=%s ids=%s\n" "$group" "$wsid" "$(tr "\n" " " < "$ids")" >> "$HOME/.cache/rice/group-launch.log" 2>/dev/null || true

first=$(head -n 1 "$ids" 2>/dev/null || true)
[ -n "$first" ] && niri msg action focus-window --id "$first" >/dev/null 2>&1 || true
