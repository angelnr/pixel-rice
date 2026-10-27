#!/usr/bin/env python3
"""palette-apply.py <nombre> — cambia los acentos del HUD sin tocar la base oscura."""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

HOME = Path.home()
STATE = HOME / ".config/rice/palettes.json"
ROLES = ("accent", "accent2", "accent_dark", "amber", "red", "lilac")

TARGETS = [
    HOME / ".config/waybar/style.css",
    HOME / ".config/gtk-3.0/gtk.css",
    HOME / ".config/gtk-4.0/gtk.css",
    HOME / ".config/mako/config",
    HOME / ".config/mako/mako-colors",
    HOME / ".config/kitty/themes/Matugen.conf",
    HOME / ".config/fuzzel/colors.ini",
    HOME / ".config/niri/colors.kdl",
    HOME / ".config/niri/wall.kdl",
    HOME / ".config/cava/config",
    HOME / ".config/swaylock/config",
    HOME / ".config/matugen/templates/mako",
    HOME / ".config/matugen/templates/kitty.conf",
    HOME / ".config/matugen/templates/fuzzel.ini",
    HOME / ".config/matugen/templates/niri.kdl",
    HOME / ".config/matugen/templates/cava-full.ini",
    HOME / ".config/matugen/templates/swaylock",
]


def run(args: list[str]) -> None:
    try:
        subprocess.run(args, check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except FileNotFoundError:
        pass


def main() -> int:
    if len(sys.argv) != 2:
        print("uso: palette-apply.py <cyber|magenta|amber|matrix|ice>")
        return 2

    name = sys.argv[1].lower()
    data = json.loads(STATE.read_text(encoding="utf-8"))
    if name not in data["palettes"]:
        print("paleta desconocida:", name)
        return 1

    current = data.get("current", "cyber")
    old = data["palettes"][current]
    new = data["palettes"][name]

    replacements: list[tuple[str, str]] = []
    token_to_new: dict[str, str] = {}
    for i, role in enumerate(ROLES):
        old_hex, new_hex = old[role].lstrip("#"), new[role].lstrip("#")
        if old_hex.lower() != new_hex.lower():
            token = f"__PALETTE_{i}__"
            replacements.append((old_hex, token))
            token_to_new[token] = new_hex

    for path in TARGETS:
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for old_hex, token in replacements:
            text = re.sub(re.escape(old_hex), token, text, flags=re.IGNORECASE)
        for token, new_hex in token_to_new.items():
            text = text.replace(token, new_hex)
        path.write_text(text, encoding="utf-8")

    data["current"] = name
    STATE.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    run(["makoctl", "reload"])
    run(["niri", "msg", "action", "load-config-file"])
    run(["systemctl", "--user", "restart", "waybar"])
    run(["pkill", "-SIGUSR1", "kitty"])
    run(["pkill", "-USR1", "cava"])
    run([str(HOME / ".local/bin/notify.sh"), "rice-palette", "PALETTE", new["label"]])
    print(f"palette: {name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
