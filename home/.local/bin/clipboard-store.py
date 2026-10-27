#!/usr/bin/env python3
"""Guarda el portapapeles de texto en un historial JSONL.

Se ejecuta desde: wl-paste --type text --watch clipboard-store.py
"""

from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

HIST = Path.home() / ".cache/rice/clipboard-history.jsonl"
MAX_ENTRIES = 80
MAX_CHARS = 200_000


def load() -> list[dict]:
    if not HIST.exists():
        return []
    entries = []
    for line in HIST.read_text(encoding="utf-8", errors="replace").splitlines():
        try:
            e = json.loads(line)
            if isinstance(e, dict) and "text" in e:
                entries.append(e)
        except json.JSONDecodeError:
            continue
    return entries


def save(entries: list[dict]) -> None:
    HIST.parent.mkdir(parents=True, exist_ok=True)
    tmp = HIST.with_suffix(".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        for e in entries:
            f.write(json.dumps(e, ensure_ascii=False) + "\n")
    os.chmod(tmp, 0o600)
    tmp.replace(HIST)


def main() -> None:
    data = sys.stdin.buffer.read()
    if not data:
        return
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError:
        return
    if text.endswith("\n"):
        text = text[:-1]
    if not text.strip():
        return
    if len(text) > MAX_CHARS:
        text = text[:MAX_CHARS]

    entries = load()
    if entries and entries[0].get("text") == text:
        return
    entries = [e for e in entries if e.get("text") != text]
    entries.insert(0, {"ts": int(time.time()), "text": text})
    save(entries[:MAX_ENTRIES])


if __name__ == "__main__":
    main()
