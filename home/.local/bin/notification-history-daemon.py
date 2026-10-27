#!/usr/bin/env python3
"""Registra las notificaciones de mako/dbus en un historial JSONL."""

from __future__ import annotations

import json
import os
import subprocess
import time
from pathlib import Path

HIST = Path.home() / ".cache/rice/notification-history.jsonl"
MAX_ENTRIES = 200
SKIP_APPS = {"rice-osd", "rice-game", "rice-clip", "rice-screenshot", "rice-notif"}


def append(entry: dict) -> None:
    HIST.parent.mkdir(parents=True, exist_ok=True)
    with HIST.open("a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    try:
        os.chmod(HIST, 0o600)
    except OSError:
        pass
    try:
        lines = HIST.read_text(encoding="utf-8", errors="replace").splitlines()
        if len(lines) > MAX_ENTRIES:
            tmp = HIST.with_suffix(".tmp")
            tmp.write_text("\n".join(lines[-MAX_ENTRIES:]) + "\n", encoding="utf-8")
            os.chmod(tmp, 0o600)
            tmp.replace(HIST)
    except OSError:
        pass


def is_closed(raw: str) -> bool:
    """Comprueba si la cadena DBus ya tiene la comilla de cierre."""
    quotes = 0
    escaped = False
    for ch in raw:
        if escaped:
            escaped = False
            continue
        if ch == "\\":
            escaped = True
        elif ch == '"':
            quotes += 1
    return quotes >= 2 and quotes % 2 == 0


def unescape(raw: str) -> str:
    s = raw.strip()
    if s.startswith('"'):
        s = s[1:]
    if s.endswith('"'):
        s = s[:-1]
    out: list[str] = []
    i = 0
    while i < len(s):
        if s[i] == "\\" and i + 1 < len(s):
            n = s[i + 1]
            mapping = {"n": "\n", "t": "\t", "r": "\r", '"': '"', "\\": "\\"}
            if n in mapping:
                out.append(mapping[n])
                i += 2
                continue
            if n == "x" and i + 3 < len(s):
                try:
                    out.append(chr(int(s[i + 2:i + 4], 16)))
                    i += 4
                    continue
                except ValueError:
                    pass
            out.append(n)
            i += 2
            continue
        out.append(s[i])
        i += 1
    return "".join(out)


def main() -> None:
    proc = subprocess.Popen(
        ["dbus-monitor", "interface='org.freedesktop.Notifications',member='Notify'"],
        stdout=subprocess.PIPE,
        text=True,
        bufsize=1,
    )
    assert proc.stdout is not None

    collecting = False
    strings: list[str] = []
    for line in proc.stdout:
        if "member=Notify" in line:
            collecting = True
            strings = []
            continue
        if not collecting:
            continue
        if line.strip().startswith("string "):
            raw = line.strip()[7:]
            # Las cadenas con saltos de línea ocupan varias líneas.
            while not is_closed(raw):
                nxt = proc.stdout.readline()
                if not nxt:
                    break
                raw += "\n" + nxt.rstrip("\n")
            strings.append(unescape(raw))
            if len(strings) >= 4:
                app, _icon, summary, body = strings[:4]
                if app not in SKIP_APPS:
                    append({
                        "ts": int(time.time()),
                        "app": app,
                        "summary": summary,
                        "body": body,
                    })
                collecting = False
                strings = []


if __name__ == "__main__":
    main()
