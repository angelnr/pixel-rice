# Hardware del equipo original

<p align="center">
  <b>Español</b> · <a href="en/HARDWARE.md">English</a>
</p>

Configuración de referencia donde se probó el rice:

- **Equipo**: Lenovo IdeaPad 5 15IIL05.
- **CPU/GPU**: Intel Core i7-1065G7 / Intel Iris Plus Graphics G7.
- **Salida Wayland**: `eDP-1` (1920x1080).
- **Batería**: `BAT0`.
- **Brillo**: `intel_backlight`.
- **Sesión**: Wayland + Niri 26.04.

## Qué puede cambiar en otro equipo

- El nombre del output (`eDP-1`, `HDMI-A-1`, etc.) y los workspaces fijos.
- El control de brillo (`brightnessctl` y el dispositivo de backlight).
- La batería y los perfiles de energía.
- `xwayland-satellite` y el arranque de Steam/Discord.
- La disponibilidad de `wlsunset` (necesita gamma-control).
- Los atajos de teclas especiales (volumen, brillo, micrófono).

## Dónde ajustar

- Salidas y reglas de ventanas: `~/.config/niri/config.kdl`.
- Brillo: `~/.local/bin/brightness.sh`.
- Audio: `~/.local/bin/volume.sh`.
- Batería y sistema: `~/.config/waybar/config.jsonc` y `sys-status.sh`.
- Night light: `~/.config/systemd/user/wlsunset.service`.
- Wallpapers por nivel: `~/.config/rice/` y `wallpaperctl.sh`.
