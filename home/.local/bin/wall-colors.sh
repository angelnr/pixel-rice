#!/usr/bin/env bash
# wall-colors.sh <imagen>
# Extrae hasta 8 colores dominantes del wallpaper y los aplica a:
#   - waybar  -> ~/.config/waybar/wall-colors.css (@wall1..@wall8)
#   - niri    -> ~/.config/niri/wall.kdl (acentos fijos del HUD)
# CAVA usa un gradiente fijo definido en la plantilla de matugen.
set -euo pipefail

img="${1:?uso: wall-colors.sh <imagen>}"

python3 - "$img" <<'PY'
import subprocess
import sys
import colorsys
import pathlib

img = sys.argv[1]
home = pathlib.Path.home()

out = subprocess.run(
    ["magick", img, "-resize", "160x160", "-colors", "48",
     "-format", "%c", "histogram:info:-"],
    capture_output=True, text=True, check=True,
).stdout

entries = []
for line in out.splitlines():
    line = line.strip()
    if not line or ":" not in line:
        continue
    try:
        count = int(line.split(":", 1)[0].strip())
        hx = next(t for t in line.split() if t.startswith("#"))[1:7]
        r, g, b = (int(hx[i:i + 2], 16) / 255 for i in (0, 2, 4))
    except (StopIteration, ValueError):
        continue
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    entries.append({"count": count, "hex": hx, "h": h, "s": s, "v": v})

cand = [e for e in entries if e["v"] >= 0.08 and e["s"] >= 0.12]
if not cand:
    cand = entries
if not cand:
    cand = [{"count": 1, "hex": "888888", "h": 0.0, "s": 0.5, "v": 0.6}]

cand.sort(key=lambda e: e["count"] * (0.35 + e["s"]), reverse=True)

picked = []
used = []
for e in cand:
    if len(picked) >= 8:
        break
    hue = e["h"] * 360.0
    if any(min(abs(hue - u), 360.0 - abs(hue - u)) < 14.0 for u in used):
        continue
    picked.append(e)
    used.append(hue)

while len(picked) < 8:
    base = picked[0] if picked else cand[0]
    hue = (base["h"] * 360.0 + len(picked) * 27.0) % 360.0
    picked.append({"count": 1, "hex": base["hex"], "h": hue / 360.0,
                   "s": base["s"], "v": base["v"]})

accents = []
for e in picked:
    s = min(0.95, max(0.50, e["s"]))
    v = min(0.98, max(0.72, e["v"]))
    r, g, b = colorsys.hsv_to_rgb(e["h"], s, v)
    accents.append((e["h"] * 360.0,
                    "#%02x%02x%02x" % (round(r * 255), round(g * 255), round(b * 255))))

accents.sort(key=lambda t: t[0])
hexes = [h for _, h in accents]

# 1) waybar
wb = home / ".config/waybar"
wb.mkdir(parents=True, exist_ok=True)
css = ["/* Colores dominantes del wallpaper (wall-colors.sh) */"]
css += [f"@define-color wall{i} {h};" for i, h in enumerate(hexes, 1)]
(wb / "wall-colors.css").write_text("\n".join(css) + "\n")

# 2) niri: acentos del HUD según la paleta activa
niri = home / ".config/niri/wall.kdl"
try:
    import json
    palette = json.loads((home / ".config/rice/palettes.json").read_text())
    current = palette["palettes"][palette.get("current", "cyber")]
    accent = current["accent"]
    secondary = current["accent2"]
except Exception:
    accent, secondary = "#5cc8d7", "#b48ead"
niri.write_text(
    "// Colores fijos del HUD pixel art (wall-colors.sh)\n"
    "layout {\n"
    "    focus-ring {\n"
    f'        active-color "{accent}"\n'
    "    }\n"
    "    tab-indicator {\n"
    f'        active-color "{secondary}"\n'
    "    }\n"
    "    insert-hint {\n"
    f'        color "{accent}80"\n'
    "    }\n"
    "}\n"
)

print("wall-colors: " + " ".join(hexes))
PY
