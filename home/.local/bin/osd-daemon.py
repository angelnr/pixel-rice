#!/usr/bin/env python3
"""Daemon OSD: recibe 'etiqueta|porcentaje' por un FIFO y actualiza UNA
notificación (misma conexión D-Bus => replaces_id funciona). Evita el spam
de paneles al hacer scroll o mantener pulsada una tecla."""
import os
import sys
import time

import gi
from gi.repository import Gio, GLib

RT = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
FIFO = os.path.join(RT, "rice-osd.fifo")
BUS = "org.freedesktop.Notifications"
OBJ = "/org/freedesktop/Notifications"
IFACE = "org.freedesktop.Notifications"


def main():
    try:
        os.mkfifo(FIFO, 0o600)
    except FileExistsError:
        pass

    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    proxy = Gio.DBusProxy.new_sync(
        bus, Gio.DBusProxyFlags.NONE, None, BUS, OBJ, IFACE, None
    )
    last_id = 0

    while True:
        # Abrir bloquea hasta que alguien escriba; al cerrarse, reabrimos.
        try:
            f = open(FIFO, "r", encoding="utf-8")
        except OSError:
            time.sleep(0.5)
            continue

        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                label, pct = line.rsplit("|", 1)
                pct = max(0, min(100, int(float(pct))))
            except ValueError:
                continue

            filled = pct // 5
            body = "█" * filled + "░" * (20 - filled) + f"  {pct}%"
            try:
                if last_id:
                    proxy.call_sync(
                        "CloseNotification",
                        GLib.Variant("(u)", (last_id,)),
                        Gio.DBusCallFlags.NONE,
                        300,
                        None,
                    )
                    last_id = 0
                res = proxy.call_sync(
                    "Notify",
                    GLib.Variant(
                        "(susssasa{sv}i)",
                        (
                            "rice-osd",
                            last_id,
                            "",
                            label,
                            body,
                            [],
                            {},
                            1500,
                        ),
                    ),
                    Gio.DBusCallFlags.NONE,
                    500,
                    None,
                )
                last_id = res.unpack()[0]
            except Exception as e:  # mako puede no estar listo aún
                print(f"notify: {e}", file=sys.stderr)
                time.sleep(1.0)
        f.close()


if __name__ == "__main__":
    sys.exit(main())
