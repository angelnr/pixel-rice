#!/usr/bin/env python3
"""Menú Fuzzel para el historial del portapapeles."""

from __future__ import annotations

import json
import re
import subprocess
import sys
import time
from pathlib import Path

HIST = Path.home() / ".cache/rice/clipboard-history.jsonl"


def load() -> list[dict]:
    if not HIST.exists():
        return []
    out = []
    for line in HIST.read_text(encoding="utf-8", errors="replace").splitlines():
        try:
            e = json.loads(line)
            if isinstance(e, dict) and "text" in e:
                out.append(e)
        except json.JSONDecodeError:
            continue
    return out


def preview(text: str, width: int = 96) -> str:
    text = text.replace("\n", " ⏎ ").replace("\t", " ")
    text = " ".join(text.split())
    return text[:width] + ("…" if len(text) > width else "")


def notify(msg: str) -> None:
    subprocess.run(
        [
            "gdbus", "call", "--session",
            "--dest", "org.freedesktop.Notifications",
            "--object-path", "/org/freedesktop/Notifications",
            "--method", "org.freedesktop.Notifications.Notify",
            "rice-clip", "0", "", "CLIPBOARD", msg, "[]", "{}", "1800",
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def main() -> None:
    entries = load()
    lines = ["#0  CLEAR HISTORY"]
    for i, e in enumerate(entries, 1):
        when = time.strftime("%H:%M", time.localtime(e.get("ts", 0)))
        lines.append(f"#{i}  {when}  {preview(e['text'])}")

    proc = subprocess.run(
        ["fuzzel", "--dmenu", "--prompt=CLIPBOARD > ", "--lines=14", "--width=76"],
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
        notify("Historial borrado")
        return
    if idx > len(entries):
        return
    text = entries[idx - 1]["text"]
    subprocess.run(["wl-copy"], input=text, text=True)
    notify("Copiado: " + preview(text, 60))


if __name__ == "__main__":
    main()
