#!/usr/bin/env python3
"""Genera un pequeño tema de sonidos chiptune para el escritorio.

Salida: ~/.local/share/sounds/pixel/stereo/*.wav
Los nombres siguen la especificación de freedesktop sound theme para que
libcanberra/GTK puedan usarlos. Además lock.sh usa service-login/logout.
"""

from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

RATE = 44100
ROOT = Path.home() / ".local/share/sounds/pixel"
STEREO = ROOT / "stereo"

# Notas (Hz)
C5, D5, E5, G5, A5, C6, E6, G6 = 523.25, 587.33, 659.25, 783.99, 880.0, 1046.5, 1318.5, 1568.0


def square(freq: float, dur: float, volume: float = 0.18) -> list[float]:
    n = int(RATE * dur)
    out: list[float] = []
    for i in range(n):
        # envolvente corta para evitar clics
        env = min(1.0, i / (RATE * 0.008), (n - i) / (RATE * 0.012))
        phase = (i * freq / RATE) % 1.0
        out.append((volume if phase < 0.5 else -volume) * max(0.0, env))
    return out


def silence(dur: float) -> list[float]:
    return [0.0] * int(RATE * dur)


def sequence(notes: list[tuple[float, float]], gap: float = 0.025) -> list[float]:
    out: list[float] = []
    for freq, dur in notes:
        out.extend(square(freq, dur))
        out.extend(silence(gap))
    return out


def write(name: str, samples: list[float]) -> None:
    path = STEREO / f"{name}.wav"
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        frames = bytearray()
        for s in samples:
            v = max(-1.0, min(1.0, s))
            frames.extend(struct.pack("<h", int(v * 32767)))
        w.writeframes(bytes(frames))


def main() -> None:
    STEREO.mkdir(parents=True, exist_ok=True)

    write("bell", sequence([(C6, 0.09), (G6, 0.16)]))
    write("message", sequence([(E5, 0.06), (A5, 0.06), (C6, 0.12)]))
    write("dialog-information", sequence([(C5, 0.06), (E5, 0.06), (G5, 0.14)]))
    write("dialog-warning", sequence([(A5, 0.10), (E5, 0.10), (A5, 0.16)]))
    write("dialog-error", sequence([(E5, 0.08), (C5, 0.08), (E5, 0.18)]))
    write("button-pressed", sequence([(G5, 0.025)], gap=0.0))
    write("audio-volume-change", sequence([(C6, 0.035)], gap=0.0))
    write("service-login", sequence([(C5, 0.07), (E5, 0.07), (G5, 0.07), (C6, 0.20)]))
    write("service-logout", sequence([(C6, 0.07), (G5, 0.07), (E5, 0.07), (C5, 0.20)]))
    write("complete", sequence([(G5, 0.06), (C6, 0.06), (E6, 0.18)]))

    (ROOT / "index.theme").write_text(
        "[Sound Theme]\n"
        "Name=Pixel HUD\n"
        "Comment=Chiptune UI sounds\n"
        "Directories=stereo\n"
        "\n"
        "[stereo]\n"
        "OutputProfile=stereo\n",
        encoding="utf-8",
    )
    print(f"Sonidos generados en {STEREO}")


if __name__ == "__main__":
    main()
