#!/usr/bin/env python3
"""Genera un tema de cursor pixel art (PixelCursor) usando xcursorgen.

No necesita PIL: escribe PPM y deja que ImageMagick los convierta a PNG.
Los cursores que no se generan heredan de breeze_cursors.
"""

from __future__ import annotations

import shutil
import subprocess
import tempfile
from pathlib import Path

HOME = Path.home()
THEME = HOME / ".icons/PixelCursor"
CURSORS = THEME / "cursors"

OUTLINE = (14, 20, 24)
FILL = (223, 231, 232)
CYAN = (92, 200, 215)

# 16x16. B = borde oscuro, W = relleno claro, C = cian.
ARROW = [
    "B...............",
    "BB..............",
    "BWB.............",
    "BWWB............",
    "BWWWB...........",
    "BWWWWB..........",
    "BWWWWWB.........",
    "BWWWWWWB........",
    "BWWWWWWWB.......",
    "BWWWWWWWWB......",
    "BWWWWWBBBB......",
    "BWWBWWB.........",
    "BWB.BWWB........",
    "BB..BWWB........",
    "B....BWWB.......",
    ".....BWWB.......",
]

TEXT = [
    "....BBBBBB......",
    "......BB........",
    "......BB........",
    "......BB........",
    "......BB........",
    "......BB........",
    "......BB........",
    "......BB........",
    "......BB........",
    "......BB........",
    "......BB........",
    "......BB........",
    "......BB........",
    "....BBBBBB......",
    "................",
    "................",
]

HAND = [
    "................",
    ".....BB.........",
    "....BWWB........",
    "....BWWB........",
    "....BWWBBBB.....",
    "....BWWBWWBB....",
    "....BWWBWWBWB...",
    "....BWWBWWBWWB..",
    "....BWWBWWBWWB..",
    "....BWWBWWBWWB..",
    "....BWWWWWWWWB..",
    ".....BWWWWWWB...",
    ".....BWWWWWWB...",
    "......BWWWWB....",
    ".......BBBB.....",
    "................",
]

CROSS = [
    ".......CC.......",
    ".......CC.......",
    ".......CC.......",
    ".......CC.......",
    ".......CC.......",
    ".......CC.......",
    "CCCCCCCCCCCCCCCC",
    "CCCCCCCCCCCCCCCC",
    ".......CC.......",
    ".......CC.......",
    ".......CC.......",
    ".......CC.......",
    ".......CC.......",
    ".......CC.......",
    ".......CC.......",
    "................",
]

WAIT = [
    "..CCCCCCCCCCCC..",
    "..C..........C..",
    "...C........C...",
    "....C......C....",
    ".....C....C.....",
    "......C..C......",
    ".......CC.......",
    ".......CC.......",
    ".......CC.......",
    "......C..C......",
    ".....C....C.....",
    "....C......C....",
    "...C........C...",
    "..C..........C..",
    "..CCCCCCCCCCCC..",
    "................",
]

SPECS = {
    "arrow": (ARROW, (1, 1)),
    "text": (TEXT, (8, 8)),
    "hand": (HAND, (5, 1)),
    "cross": (CROSS, (8, 8)),
    "wait": (WAIT, (8, 8)),
}

ARROW_ALIASES = [
    "default",
    "left_ptr",
    "arrow",
    "top_left_arrow",
    "right_ptr",
    "draft",
    "openhand",
    "closedhand",
    "move",
    "fleur",
    "copy",
    "link",
    "context-menu",
    "help",
    "progress",
]
TEXT_ALIASES = ["text", "xterm", "vertical-text"]
HAND_ALIASES = ["pointer", "hand", "hand1", "hand2", "pointing_hand"]
CROSS_ALIASES = ["crosshair", "cross", "tcross", "cell", "precision"]
WAIT_ALIASES = ["wait", "watch", "hourglass"]


def write_ppm(path: Path, mask: list[str], size: int) -> None:
    data = bytearray()
    src_h = len(mask)
    src_w = len(mask[0])
    for y in range(size):
        sy = min(src_h - 1, y * src_h // size)
        row = mask[sy]
        for x in range(size):
            sx = min(src_w - 1, x * src_w // size)
            ch = row[sx]
            color = {"B": OUTLINE, "W": FILL, "C": CYAN}.get(ch, (0, 0, 0))
            data.extend(color)
    with path.open("wb") as f:
        f.write(f"P6\n{size} {size}\n255\n".encode())
        f.write(data)


def build_cursor(name: str, mask: list[str], hotspot: tuple[int, int], tmp: Path) -> None:
    lines = []
    for size in (24, 32, 48):
        ppm = tmp / f"{name}-{size}.ppm"
        png = tmp / f"{name}-{size}.png"
        write_ppm(ppm, mask, size)
        subprocess.run(
            ["magick", str(ppm), f"png:{png}"],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        hx = round(hotspot[0] * size / 16)
        hy = round(hotspot[1] * size / 16)
        lines.append(f"{size} {hx} {hy} {png}")
    cfg = tmp / f"{name}.cursor"
    cfg.write_text("\n".join(lines) + "\n", encoding="utf-8")
    subprocess.run(
        ["xcursorgen", str(cfg), str(CURSORS / name)],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def main() -> None:
    if not shutil.which("xcursorgen") or not shutil.which("magick"):
        raise SystemExit("Faltan xcursorgen o ImageMagick")
    if THEME.exists():
        shutil.rmtree(THEME)
    CURSORS.mkdir(parents=True)

    with tempfile.TemporaryDirectory(prefix="pixelcursor-") as td:
        tmp = Path(td)
        for name, (mask, hotspot) in SPECS.items():
            build_cursor(name, mask, hotspot, tmp)

    for alias in ARROW_ALIASES:
        if not (CURSORS / alias).exists():
            (CURSORS / alias).symlink_to("arrow")
    for alias in TEXT_ALIASES:
        if not (CURSORS / alias).exists():
            (CURSORS / alias).symlink_to("text")
    for alias in HAND_ALIASES:
        if not (CURSORS / alias).exists():
            (CURSORS / alias).symlink_to("hand")
    for alias in CROSS_ALIASES:
        if not (CURSORS / alias).exists():
            (CURSORS / alias).symlink_to("cross")
    for alias in WAIT_ALIASES:
        if not (CURSORS / alias).exists():
            (CURSORS / alias).symlink_to("wait")

    (THEME / "index.theme").write_text(
        "[Icon Theme]\n"
        "Name=PixelCursor\n"
        "Comment=Pixel art cursors\n"
        "Inherits=breeze_cursors\n",
        encoding="utf-8",
    )
    print(f"Cursor pixel art generado en {THEME}")


if __name__ == "__main__":
    main()
