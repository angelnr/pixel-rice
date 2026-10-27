#!/bin/sh
# brightness.sh up|down|slider

pick_percent() {
  cur="$1"
  prompt="$2"
  p=0
  while [ "$p" -le 100 ]; do
    filled=$((p / 5))
    bar=""
    i=0
    while [ "$i" -lt 20 ]; do
      if [ "$i" -lt "$filled" ]; then bar="$bar█"; else bar="$bar░"; fi
      i=$((i + 1))
    done
    mark=""
    [ "$p" -eq "$cur" ] && mark="  ←"
    printf '%s  %s%%%s\n' "$bar" "$p" "$mark"
    p=$((p + 5))
  done | fuzzel --dmenu --lines=21 --prompt="$prompt "
}

case "${1:-up}" in
  up)
    brightnessctl --class=backlight set 5%+ -q ;;
  down)
    brightnessctl --class=backlight set 5%- -q ;;
  slider)
    cur=$(brightnessctl --class=backlight get 2>/dev/null || echo 0)
    max=$(brightnessctl --class=backlight max 2>/dev/null || echo 1)
    [ "$max" -gt 0 ] || max=1
    pct=$((cur * 100 / max))
    chosen=$(pick_percent "$pct" "Brillo")
    [ -n "$chosen" ] || exit 0
    new=$(printf '%s' "$chosen" | grep -oE '[0-9]+%' | tr -d '%')
    [ -n "$new" ] || exit 0
    brightnessctl --class=backlight set "${new}%" -q ;;
  *)
    echo "uso: brightness.sh up|down|slider" >&2; exit 1 ;;
esac

pct=$(brightnessctl --class=backlight -m | awk -F, '{gsub(/%/,"",$4); print $4}')
"$HOME/.local/bin/osd.sh" "Brillo" "$pct"
