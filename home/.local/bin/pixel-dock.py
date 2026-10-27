#!/usr/bin/env python3
"""Dock inferior pixel HUD (estilo Mac), solo con toggle manual.

- Visible por defecto.
- `SIGUSR1` (Mod+Shift+D) muestra/oculta.
- No reserva espacio: fullscreen usa toda la pantalla.
- Sin auto-hide ni hot edge.
"""

from __future__ import annotations

import ctypes
import json
import os
import shlex
import signal
import subprocess
import time
from pathlib import Path

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import Gdk, GdkPixbuf, GLib, Gtk  # noqa: E402

HOME = Path.home()
CONFIG = HOME / ".config/rice/dock.json"
LAUNCHER_ICON = HOME / ".config/rice/dock-launcher.png"

# GtkLayerShellEdge: LEFT=0, RIGHT=1, TOP=2, BOTTOM=3
_lib = ctypes.CDLL("libgtk-layer-shell.so.0")
_lib.gtk_layer_init_for_window.argtypes = [ctypes.c_void_p]
_lib.gtk_layer_set_namespace.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
_lib.gtk_layer_set_layer.argtypes = [ctypes.c_void_p, ctypes.c_int]
_lib.gtk_layer_set_anchor.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_bool]
_lib.gtk_layer_set_keyboard_interactivity.argtypes = [ctypes.c_void_p, ctypes.c_bool]
_lib.gtk_layer_set_exclusive_zone.argtypes = [ctypes.c_void_p, ctypes.c_int]
_lib.gtk_layer_set_margin.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]

CSS = b"""
#pixel-dock {
    background-color: rgba(14, 20, 24, 0.96);
    border: 2px solid #5cc8d7;
}
button.dock-item {
    background-color: transparent;
    border: 2px solid transparent;
    border-radius: 0;
    padding: 3px;
    box-shadow: none;
}
button.dock-item:hover {
    background-color: #142126;
    border-color: #5cc8d7;
}
button.dock-item:active {
    background-color: #5cc8d7;
}
"""


def load_items() -> list[dict]:
    try:
        data = json.loads(CONFIG.read_text(encoding="utf-8"))
        items = data.get("items", [])
        return [i for i in items if isinstance(i, dict) and "exec" in i]
    except Exception:
        return []


def icon_pixbuf(name: str, size: int = 36) -> GdkPixbuf.Pixbuf | None:
    if name.startswith("/"):
        try:
            return GdkPixbuf.Pixbuf.new_from_file_at_scale(name, size, size, True)
        except Exception:
            return None
    if name == "__launcher__" and LAUNCHER_ICON.is_file():
        try:
            return GdkPixbuf.Pixbuf.new_from_file_at_scale(
                str(LAUNCHER_ICON), size, size, True
            )
        except Exception:
            pass
    theme = Gtk.IconTheme.get_default()
    for candidate in (name, "image-missing"):
        try:
            return theme.load_icon(candidate, size, Gtk.IconLookupFlags.FORCE_SIZE)
        except Exception:
            continue
    return None


def xdisplay() -> str | None:
    for sock in Path("/tmp/.X11-unix").glob("X*"):
        try:
            if sock.is_socket() and sock.stat().st_uid == os.getuid():
                return ":" + sock.name[1:]
        except OSError:
            continue
    return None


class Dock:
    def __init__(self) -> None:
        settings = Gtk.Settings.get_default()
        if settings is not None:
            settings.set_property("gtk-icon-theme-name", "pixora-dark")
            settings.set_property("gtk-cursor-theme-name", "PixelCursor")

        self.items = load_items()
        width = max(240, len(self.items) * 58 + 20)
        height = 64
        self.visible = True
        self.fade_timeout: int | None = None
        self.fade_start = 0.0
        self.fade_from = 1.0
        self.fade_target = 1.0

        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self.win = Gtk.Window()
        self.win.set_name("pixel-dock")
        self.win.set_decorated(False)
        self.win.set_default_size(width, height)
        self.win.set_skip_taskbar_hint(True)
        self.win.set_skip_pager_hint(True)
        self.win.set_accept_focus(False)
        self.win.set_can_focus(False)
        self.win.connect("destroy", Gtk.main_quit)

        ptr = ctypes.c_void_p(hash(self.win))
        _lib.gtk_layer_init_for_window(ptr)
        _lib.gtk_layer_set_namespace(ptr, b"pixel-dock")
        _lib.gtk_layer_set_layer(ptr, 2)  # top
        _lib.gtk_layer_set_anchor(ptr, 3, True)  # bottom
        _lib.gtk_layer_set_margin(ptr, 3, 12)
        _lib.gtk_layer_set_exclusive_zone(ptr, 0)  # no reserva espacio
        _lib.gtk_layer_set_keyboard_interactivity(ptr, False)

        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=2)
        box.set_margin_start(6)
        box.set_margin_end(6)
        box.set_margin_top(4)
        box.set_margin_bottom(4)
        for item in self.items:
            box.pack_start(self.make_button(item), False, False, 0)
        self.win.add(box)
        self.win.show_all()
        self.set_dock_opacity(1.0)
        self.set_pass_through(False)

        GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGUSR1, self.toggle_signal)

    def make_button(self, item: dict) -> Gtk.Button:
        btn = Gtk.Button()
        btn.get_style_context().add_class("dock-item")
        btn.set_relief(Gtk.ReliefStyle.NONE)
        btn.set_tooltip_text(item.get("name", item.get("exec", "")))
        pixbuf = icon_pixbuf(item.get("icon", ""), 36)
        if pixbuf is not None:
            btn.set_image(Gtk.Image.new_from_pixbuf(pixbuf))
        else:
            btn.set_label((item.get("name") or "?")[:2])
        btn.connect("clicked", lambda *_: self.launch(item.get("exec", "")))
        return btn

    def launch(self, command: str) -> None:
        args = shlex.split(command)
        if not args:
            return
        env = os.environ.copy()
        disp = xdisplay()
        if disp:
            env["DISPLAY"] = disp
        unit = f"rice-dock-{os.getpid()}-{time.time_ns()}"
        scope = [
            "systemd-run", "--user", "--scope", "--no-block", "--collect",
            "--quiet", f"--unit={unit}", *args,
        ]
        try:
            subprocess.Popen(
                scope,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
                env=env,
            )
            return
        except Exception:
            pass
        try:
            subprocess.Popen(
                args,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
                env=env,
            )
        except Exception:
            pass

    def gdk_window(self):
        try:
            return self.win.get_window()
        except Exception:
            return None

    def set_pass_through(self, enabled: bool) -> None:
        w = self.gdk_window()
        if w is not None:
            try:
                w.set_pass_through(enabled)
            except Exception:
                pass

    def set_dock_opacity(self, opacity: float) -> None:
        self.win.set_opacity(max(0.0, min(1.0, opacity)))

    def fade_to(self, target: float, duration_ms: int = 140) -> None:
        if self.fade_timeout is not None:
            GLib.source_remove(self.fade_timeout)
            self.fade_timeout = None
        self.fade_start = time.monotonic()
        self.fade_from = self.win.get_opacity()
        self.fade_target = target

        def step() -> bool:
            p = min(1.0, (time.monotonic() - self.fade_start) / (duration_ms / 1000))
            self.set_dock_opacity(self.fade_from + (self.fade_target - self.fade_from) * p)
            if p >= 1.0:
                self.fade_timeout = None
                return False
            return True

        self.fade_timeout = GLib.timeout_add(16, step)

    def show_dock(self) -> None:
        if self.visible:
            return
        self.win.show_all()
        self.set_dock_opacity(1.0)
        self.set_pass_through(False)
        self.visible = True

    def hide_dock(self) -> None:
        if not self.visible:
            return
        self.set_pass_through(True)
        self.win.hide()
        self.visible = False

    def toggle_signal(self) -> bool:
        if self.visible:
            self.hide_dock()
        else:
            self.show_dock()
        return True


def main() -> None:
    Dock()
    Gtk.main()


if __name__ == "__main__":
    main()
