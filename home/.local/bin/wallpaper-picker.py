#!/usr/bin/env python3
"""Selector visual de wallpapers para el nivel actual."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, Gtk  # noqa: E402

HOME = Path.home()
WALL_DIR = HOME / "Imágenes/pixel_art"
THUMB_DIR = HOME / ".cache/rice/wall-thumbs"
STATE = HOME / ".cache/rice/level-wallpapers.json"
LEVELS = ["HOME", "DEV", "MUSIC", "SYS", "VOID"]

CSS = b"""
#wallpaper-picker {
    background-color: #0e1418;
    border: 2px solid #5cc8d7;
}
#picker-title {
    font-family: "Spleen 8x16";
    font-size: 18px;
    color: #5cc8d7;
    padding: 8px;
}
#picker-hint {
    font-family: "Spleen 6x12";
    font-size: 12px;
    color: #8a9ba3;
    padding: 8px;
}
button.wall {
    background-color: #142126;
    border: 2px solid #223138;
    border-radius: 0;
    padding: 6px;
    box-shadow: none;
}
button.wall:hover {
    border-color: #5cc8d7;
    background-color: #1b2c32;
}
button.wall.active {
    border-color: #e0af68;
}
button.top {
    background-color: #142126;
    border: 2px solid #5cc8d7;
    border-radius: 0;
    color: #dfe7e8;
    font-family: "Spleen 6x12";
    padding: 6px 12px;
}
button.top:hover {
    background-color: #5cc8d7;
    color: #0e1418;
}
label.thumb-name {
    font-family: "Spleen 6x12";
    font-size: 11px;
    color: #dfe7e8;
}
label.thumb-active {
    font-family: "Spleen 6x12";
    font-size: 11px;
    color: #e0af68;
}
"""


def current_level() -> str:
    try:
        out = subprocess.run(
            ["niri", "msg", "-j", "workspaces"],
            capture_output=True, text=True, timeout=2, check=True,
        ).stdout
        for w in json.loads(out):
            if w.get("is_focused"):
                name = w.get("name")
                if name in LEVELS:
                    return name
                idx = w.get("idx")
                if isinstance(idx, int) and 1 <= idx <= len(LEVELS):
                    return LEVELS[idx - 1]
    except Exception:
        pass
    return "HOME"


def current_path(level: str) -> str | None:
    try:
        data = json.loads(STATE.read_text(encoding="utf-8"))
        p = data.get(level)
        return p if isinstance(p, str) else None
    except Exception:
        return None


def run_ctl(*args: str) -> None:
    subprocess.run([str(HOME / ".local/bin/wallpaperctl.sh"), *args], check=False)


class Picker:
    def __init__(self) -> None:
        self.level = current_level()
        self.active = current_path(self.level)
        self.images = sorted(
            p for p in WALL_DIR.iterdir()
            if p.is_file() and p.suffix.lower() in {".png", ".jpg", ".jpeg"}
        )

        self.win = Gtk.Window()
        self.win.set_title(f"SELECT WALLPAPER // {self.level}")
        self.win.set_name("wallpaper-picker")
        self.win.set_decorated(False)
        self.win.set_default_size(1100, 760)
        self.win.set_position(Gtk.WindowPosition.CENTER_ALWAYS)
        self.win.set_skip_taskbar_hint(True)

        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.win.add(outer)

        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        title = Gtk.Label(label=f"SELECT WALLPAPER // {self.level}")
        title.set_name("picker-title")
        title.set_xalign(0)
        header.pack_start(title, True, True, 0)

        random_btn = Gtk.Button(label="RANDOM")
        random_btn.get_style_context().add_class("top")
        random_btn.connect("clicked", self.on_random)
        header.pack_start(random_btn, False, False, 0)

        close_btn = Gtk.Button(label="X")
        close_btn.get_style_context().add_class("top")
        close_btn.connect("clicked", lambda *_: self.win.destroy())
        header.pack_start(close_btn, False, False, 0)
        outer.pack_start(header, False, False, 0)

        hint = Gtk.Label(label="CLICK: aplicar   ·   R: aleatorio   ·   ESC: cerrar")
        hint.set_name("picker-hint")
        hint.set_xalign(0)
        outer.pack_start(hint, False, False, 0)

        scroll = Gtk.ScrolledWindow()
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        outer.pack_start(scroll, True, True, 0)

        flow = Gtk.FlowBox()
        flow.set_max_children_per_line(4)
        flow.set_min_children_per_line(4)
        flow.set_selection_mode(Gtk.SelectionMode.NONE)
        flow.set_homogeneous(True)
        flow.set_margin_start(10)
        flow.set_margin_end(10)
        flow.set_margin_bottom(10)
        flow.set_row_spacing(8)
        flow.set_column_spacing(8)
        scroll.add(flow)

        for img in self.images:
            flow.add(self.make_tile(img))

        self.win.connect("key-press-event", self.on_key)
        self.win.connect("destroy", Gtk.main_quit)
        self.win.show_all()

    def make_tile(self, img: Path) -> Gtk.Button:
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        thumb = THUMB_DIR / f"{img.name}.jpg"
        picture = Gtk.Image()
        if thumb.is_file():
            pb = Gtk.Image.new_from_file(str(thumb)).get_pixbuf()
            if pb is not None:
                picture.set_from_pixbuf(pb.scale_simple(256, 144, 2))
        else:
            pb = Gtk.Image.new_from_file(str(img)).get_pixbuf()
            if pb is not None:
                picture.set_from_pixbuf(pb.scale_simple(256, 144, 2))
        box.pack_start(picture, False, False, 0)

        is_active = self.active is not None and Path(self.active) == img
        label = Gtk.Label(label=("▶ " if is_active else "") + img.name)
        label.get_style_context().add_class("thumb-active" if is_active else "thumb-name")
        label.set_ellipsize(3)
        label.set_max_width_chars(28)
        box.pack_start(label, False, False, 0)

        btn = Gtk.Button()
        btn.add(box)
        btn.get_style_context().add_class("wall")
        if is_active:
            btn.get_style_context().add_class("active")
        btn.connect("clicked", lambda *_: self.apply(img))
        return btn

    def apply(self, img: Path) -> None:
        run_ctl("set-current", str(img))
        self.win.destroy()

    def on_random(self, *_args) -> None:
        run_ctl("rotate")
        self.win.destroy()

    def on_key(self, _win, event) -> bool:
        if event.keyval == Gdk.KEY_Escape:
            self.win.destroy()
            return True
        if event.keyval in (Gdk.KEY_r, Gdk.KEY_R):
            self.on_random()
            return True
        return False


def main() -> None:
    Picker()
    Gtk.main()


if __name__ == "__main__":
    main()
