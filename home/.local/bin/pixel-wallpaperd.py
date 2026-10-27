#!/usr/bin/env python3
"""Wallpaper daemon pixel HUD.

- Un wallpaper aleatorio por nivel (HOME, DEV, MUSIC, SYS, VOID).
- Crossfade suave al cambiar de nivel o al rotar.
- Control por FIFO: rotate, rotate-all, set, set-current, reload, quit.
- Sustituye a swaybg; usa una superficie layer-shell de fondo.
"""

from __future__ import annotations

import ctypes
import json
import os
import random
import signal
import subprocess
import threading
import time
from pathlib import Path

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, GdkPixbuf, GLib, Gtk  # noqa: E402

HOME = Path.home()
WALL_DIR = HOME / "Imágenes/pixel_art"
CACHE = HOME / ".cache/rice"
STATE = CACHE / "level-wallpapers.json"
FIFO = CACHE / "wallpaperd.fifo"
SYMLINK = HOME / ".cache/current-wallpaper"
LEVELS = ["HOME", "DEV", "MUSIC", "SYS", "VOID"]
FADE_MS = 1200

# GtkLayerShellEdge: LEFT=0, RIGHT=1, TOP=2, BOTTOM=3
_lib = ctypes.CDLL("libgtk-layer-shell.so.0")
_lib.gtk_layer_init_for_window.argtypes = [ctypes.c_void_p]
_lib.gtk_layer_set_namespace.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
_lib.gtk_layer_set_layer.argtypes = [ctypes.c_void_p, ctypes.c_int]
_lib.gtk_layer_set_anchor.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_bool]
_lib.gtk_layer_set_keyboard_interactivity.argtypes = [ctypes.c_void_p, ctypes.c_bool]
_lib.gtk_layer_set_exclusive_zone.argtypes = [ctypes.c_void_p, ctypes.c_int]


def log(msg: str) -> None:
    print(msg, flush=True)


def images() -> list[Path]:
    if not WALL_DIR.is_dir():
        return []
    return sorted(
        p for p in WALL_DIR.iterdir()
        if p.is_file() and p.suffix.lower() in {".png", ".jpg", ".jpeg"}
    )


def random_image(exclude: str | None = None) -> str | None:
    pool = images()
    if not pool:
        return None
    if exclude:
        filtered = [p for p in pool if str(p) != exclude]
        if filtered:
            pool = filtered
    return str(random.choice(pool))


def load_state() -> dict[str, str]:
    data: dict[str, str] = {}
    if STATE.exists():
        try:
            raw = json.loads(STATE.read_text(encoding="utf-8"))
            if isinstance(raw, dict):
                data = {k: v for k, v in raw.items() if isinstance(v, str)}
        except (OSError, json.JSONDecodeError):
            pass
    changed = False
    for level in LEVELS:
        path = data.get(level)
        if not path or not Path(path).is_file():
            data[level] = random_image() or ""
            changed = True
    if changed:
        save_state(data)
    return data


def save_state(data: dict[str, str]) -> None:
    CACHE.mkdir(parents=True, exist_ok=True)
    tmp = STATE.with_suffix(".tmp")
    tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    tmp.replace(STATE)


def set_symlink(path: str) -> None:
    try:
        if SYMLINK.is_symlink() or SYMLINK.exists():
            SYMLINK.unlink()
        SYMLINK.symlink_to(path)
    except OSError:
        pass


def cover_pixbuf(path: str, width: int, height: int) -> GdkPixbuf.Pixbuf | None:
    try:
        pb = GdkPixbuf.Pixbuf.new_from_file(path)
    except GLib.Error as exc:
        log(f"[wallpaperd] no puedo cargar {path}: {exc}")
        return None
    iw, ih = pb.get_width(), pb.get_height()
    if iw <= 0 or ih <= 0:
        return None
    scale = max(width / iw, height / ih)
    nw, nh = max(1, round(iw * scale)), max(1, round(ih * scale))
    interp = GdkPixbuf.InterpType.NEAREST if scale >= 2 else GdkPixbuf.InterpType.BILINEAR
    pb = pb.scale_simple(nw, nh, interp)
    x = max(0, (nw - width) // 2)
    y = max(0, (nh - height) // 2)
    return pb.new_subpixbuf(x, y, width, height)


class WallpaperWindow:
    def __init__(self) -> None:
        screen = Gdk.Screen.get_default()
        display = screen.get_display()
        monitor = display.get_primary_monitor() or display.get_monitor(0)
        geometry = monitor.get_geometry()
        self.width, self.height = geometry.width, geometry.height

        self.win = Gtk.Window()
        self.win.set_decorated(False)
        self.win.set_app_paintable(True)
        self.win.set_default_size(self.width, self.height)
        self.win.set_skip_taskbar_hint(True)
        self.win.set_skip_pager_hint(True)
        self.win.set_accept_focus(False)
        self.win.set_can_focus(False)
        self.win.set_name("pixel-wallpaper")

        ptr = ctypes.c_void_p(hash(self.win))
        _lib.gtk_layer_init_for_window(ptr)
        _lib.gtk_layer_set_namespace(ptr, b"pixel-wallpaper")
        _lib.gtk_layer_set_layer(ptr, 0)  # background
        for edge in (0, 1, 2, 3):
            _lib.gtk_layer_set_anchor(ptr, edge, True)
        _lib.gtk_layer_set_keyboard_interactivity(ptr, False)
        _lib.gtk_layer_set_exclusive_zone(ptr, -1)

        self.bottom = Gtk.Image()
        self.top = Gtk.Image()
        for img in (self.bottom, self.top):
            img.set_hexpand(True)
            img.set_vexpand(True)
            img.set_halign(Gtk.Align.FILL)
            img.set_valign(Gtk.Align.FILL)

        self.overlay = Gtk.Overlay()
        self.overlay.add(self.bottom)
        self.overlay.add_overlay(self.top)
        self.win.add(self.overlay)
        self.win.connect("destroy", Gtk.main_quit)
        self.win.show_all()
        self.top.set_opacity(0)

        gdkwin = self.win.get_window()
        if gdkwin is not None:
            try:
                gdkwin.set_pass_through(True)
            except Exception:
                pass

        self.current_pixbuf: GdkPixbuf.Pixbuf | None = None
        self.current_path: str | None = None
        self.timeout: int | None = None

    def show_initial(self, path: str) -> None:
        pb = cover_pixbuf(path, self.width, self.height)
        if pb is None:
            return
        self.bottom.set_from_pixbuf(pb)
        self.top.set_from_pixbuf(pb)
        self.top.set_opacity(0)
        self.current_pixbuf = pb
        self.current_path = path
        set_symlink(path)

    def fade_to(self, path: str) -> None:
        if path == self.current_path:
            return
        pb = cover_pixbuf(path, self.width, self.height)
        if pb is None:
            return
        if self.timeout is not None:
            GLib.source_remove(self.timeout)
            self.timeout = None
        if self.current_pixbuf is not None:
            self.bottom.set_from_pixbuf(self.current_pixbuf)
        self.top.set_from_pixbuf(pb)
        self.top.set_opacity(0)
        self.current_path = path
        set_symlink(path)
        started = time.monotonic()

        def step() -> bool:
            p = min(1.0, (time.monotonic() - started) / (FADE_MS / 1000.0))
            eased = p * p * (3.0 - 2.0 * p)
            self.top.set_opacity(eased)
            if p >= 1.0:
                self.bottom.set_from_pixbuf(pb)
                self.top.set_opacity(0)
                self.current_pixbuf = pb
                self.timeout = None
                return False
            return True

        self.timeout = GLib.timeout_add(16, step)


class Controller:
    def __init__(self) -> None:
        CACHE.mkdir(parents=True, exist_ok=True)
        self.state = load_state()
        self.window = WallpaperWindow()
        self.current_level = self.detect_level()
        initial = self.state.get(self.current_level) or random_image()
        if initial:
            self.state[self.current_level] = initial
            save_state(self.state)
            self.window.show_initial(initial)
        self.workspaces: dict[int, dict] = {}
        threading.Thread(target=self.watch_niri, daemon=True).start()
        self.start_fifo()

    def detect_level(self) -> str:
        try:
            out = subprocess.run(
                ["niri", "msg", "-j", "workspaces"],
                capture_output=True, text=True, timeout=2, check=True,
            ).stdout
            for w in json.loads(out):
                if w.get("is_focused"):
                    return self.level_of(w)
        except Exception:
            pass
        return "HOME"

    def level_of(self, workspace: dict) -> str:
        name = workspace.get("name")
        if name in LEVELS:
            return name
        idx = workspace.get("idx")
        if isinstance(idx, int) and 1 <= idx <= len(LEVELS):
            return LEVELS[idx - 1]
        return "HOME"

    def watch_niri(self) -> None:
        while True:
            try:
                proc = subprocess.Popen(
                    ["niri", "msg", "--json", "event-stream"],
                    stdout=subprocess.PIPE, text=True, bufsize=1,
                )
                assert proc.stdout is not None
                for line in proc.stdout:
                    try:
                        event = json.loads(line)
                    except json.JSONDecodeError:
                        continue
                    GLib.idle_add(self.handle_event, event)
            except Exception as exc:
                log(f"[wallpaperd] niri event-stream: {exc}")
            time.sleep(1.0)

    def handle_event(self, event: dict) -> bool:
        if "WorkspacesChanged" in event:
            for w in event["WorkspacesChanged"].get("workspaces", []):
                self.workspaces[w["id"]] = w
            focused = next((w for w in self.workspaces.values() if w.get("is_focused")), None)
            if focused:
                self.activate(self.level_of(focused))
        elif "WorkspaceActivated" in event:
            act = event["WorkspaceActivated"]
            if act.get("focused"):
                w = self.workspaces.get(act.get("id"))
                if w:
                    self.activate(self.level_of(w))
        return False

    def activate(self, level: str) -> None:
        if level not in LEVELS:
            level = "HOME"
        self.current_level = level
        path = self.state.get(level)
        if not path or not Path(path).is_file():
            path = random_image()
            if not path:
                return
            self.state[level] = path
            save_state(self.state)
        self.window.fade_to(path)

    def rotate_current(self) -> None:
        old = self.state.get(self.current_level)
        new = random_image(exclude=old)
        if not new:
            return
        self.state[self.current_level] = new
        save_state(self.state)
        self.window.fade_to(new)
        log(f"[wallpaperd] rotate {self.current_level}: {Path(new).name}")

    def rotate_all(self) -> None:
        for level in LEVELS:
            old = self.state.get(level)
            new = random_image(exclude=old)
            if new:
                self.state[level] = new
        save_state(self.state)
        path = self.state.get(self.current_level)
        if path:
            self.window.fade_to(path)
        log("[wallpaperd] rotate-all")

    def set_level(self, level: str, path: str) -> None:
        if level not in LEVELS or not Path(path).is_file():
            return
        self.state[level] = path
        save_state(self.state)
        if level == self.current_level:
            self.window.fade_to(path)
        log(f"[wallpaperd] set {level}: {Path(path).name}")

    def set_current(self, path: str) -> None:
        self.set_level(self.current_level, path)

    def reload_state(self) -> None:
        self.state = load_state()
        path = self.state.get(self.current_level)
        if path:
            self.window.fade_to(path)

    def start_fifo(self) -> None:
        if FIFO.exists() and not FIFO.is_fifo():
            FIFO.unlink()
        if not FIFO.exists():
            os.mkfifo(FIFO, 0o600)

        def loop() -> None:
            while True:
                try:
                    with FIFO.open("r", encoding="utf-8") as f:
                        for line in f:
                            cmd = line.strip()
                            if cmd:
                                GLib.idle_add(self.handle_command, cmd)
                except OSError as exc:
                    log(f"[wallpaperd] fifo: {exc}")
                    time.sleep(0.5)

        threading.Thread(target=loop, daemon=True).start()

    def handle_command(self, cmd: str) -> bool:
        parts = cmd.split(maxsplit=2)
        if not parts:
            return False
        op = parts[0]
        if op == "rotate":
            self.rotate_current()
        elif op == "rotate-all":
            self.rotate_all()
        elif op == "set" and len(parts) >= 3:
            self.set_level(parts[1], parts[2])
        elif op == "set-current" and len(parts) >= 2:
            self.set_current(parts[1])
        elif op == "reload":
            self.reload_state()
        elif op == "quit":
            Gtk.main_quit()
        return False


def main() -> None:
    controller = Controller()
    GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGTERM, Gtk.main_quit)
    GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGINT, Gtk.main_quit)
    Gtk.main()


if __name__ == "__main__":
    main()
