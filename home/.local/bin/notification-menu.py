#!/usr/bin/env python3
"""Menú Fuzzel para el historial de notificaciones."""

from __future__ import annotations

import json
import re
import subprocess
import tempfile
import time
from pathlib import Path

HIST = Path.home() / ".cache/rice/notification-history.jsonl"


def load() -> list[dict]:
    if not HIST.exists():
        return []
    out = []
    for line in HIST.read_text(encoding="utf-8", errors="replace").splitlines():
        try:
            e = json.loads(line)
            if isinstance(e, dict) and "summary" in e:
                out.append(e)
        except json.JSONDecodeError:
            continue
    return out


def preview(text: str, width: int = 80) -> str:
    text = " ".join(text.replace("\n", " ⏎ ").split())
    return text[:width] + ("…" if len(text) > width else "")


def main() -> None:
    entries = load()
    lines = ["#0  CLEAR HISTORY"]
    for i, e in enumerate(reversed(entries), 1):
        when = time.strftime("%H:%M", time.localtime(e.get("ts", 0)))
        lines.append(f"#{i}  {when}  {e.get('app', '')}  {preview(e.get('summary', ''))}")

    proc = subprocess.run(
        ["fuzzel", "--dmenu", "--prompt=NOTIFICATIONS > ", "--lines=14", "--width=78"],
        input="\n".join(lines) + "\n",
        text=True,
        capture_output=True,
    )
    choice = proc.stdout.strip()
    if not choice:
        return
    m = re.match(r"#(\d+)", choice)
    if not m:
        return
    idx = int(m.group(1))
    if idx == 0:
        HIST.unlink(missing_ok=True)
        return
    rev = list(reversed(entries))
    if idx > len(rev):
        return
    e = rev[idx - 1]
    body = e.get("body") or "(sin cuerpo)"
    text = (
        f"APP: {e.get('app', '')}\n"
        f"HORA: {time.strftime('%Y-%m-%d %H:%M', time.localtime(e.get('ts', 0)))}\n"
        f"TÍTULO: {e.get('summary', '')}\n\n"
        f"{body}\n"
    )
    with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False, encoding="utf-8") as f:
        f.write(text)
        path = f.name
    subprocess.run(["kdialog", "--title", "NOTIFICATION // " + e.get("app", ""), "--textbox", path, "760", "440"])
    Path(path).unlink(missing_ok=True)


if __name__ == "__main__":
    main()
