#!/bin/sh
# palette-status.sh — paleta activa para Waybar (JSON).

python3 - <<'PY'
import json
from pathlib import Path
try:
    d = json.loads((Path.home() / ".config/rice/palettes.json").read_text())
    name = d.get("current", "cyber")
    label = d["palettes"].get(name, {}).get("label", name.upper())
except Exception:
    name, label = "cyber", "CYBER"
print(json.dumps({"text": f"// {label}", "class": name, "tooltip": f"Paleta HUD: {label}"}))
PY
