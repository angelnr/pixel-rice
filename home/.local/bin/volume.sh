#!/bin/sh
# volume.sh up|down|mute|slider

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
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0 ;;
  down)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
  slider)
    cur=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2*100}')
    chosen=$(pick_percent "$cur" "Volumen")
    [ -n "$chosen" ] || exit 0
    pct=$(printf '%s' "$chosen" | grep -oE '[0-9]+%' | tr -d '%')
    [ -n "$pct" ] || exit 0
    wpctl set-volume @DEFAULT_AUDIO_SINK@ "$(awk -v n="$pct" 'BEGIN{printf "%.2f", n/100}')" ;;
  *)
    echo "uso: volume.sh up|down|mute|slider" >&2; exit 1 ;;
esac

info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
pct=$(printf '%s\n' "$info" | awk '{printf "%.0f", $2*100}')
if printf '%s' "$info" | grep -q MUTED; then
  "$HOME/.local/bin/osd.sh" "Volumen (mudo)" "$pct"
else
  "$HOME/.local/bin/osd.sh" "Volumen" "$pct"
fi
