# Original hardware

<p align="center">
  <a href="../HARDWARE.md">Español</a> · <b>English</b>
</p>

Reference configuration where the rice was tested:

- **Machine**: Lenovo IdeaPad 5 15IIL05.
- **CPU/GPU**: Intel Core i7-1065G7 / Intel Iris Plus Graphics G7.
- **Wayland output**: `eDP-1` (1920x1080).
- **Battery**: `BAT0`.
- **Backlight**: `intel_backlight`.
- **Session**: Wayland + Niri 26.04.

## What may change on another machine

- The output name (`eDP-1`, `HDMI-A-1`, etc.) and fixed workspaces.
- Brightness control (`brightnessctl` and the backlight device).
- Battery and power profiles.
- `xwayland-satellite` and Steam/Discord startup.
- `wlsunset` availability (it requires gamma-control).
- Special key shortcuts (volume, brightness, microphone).

## Where to adjust

- Outputs and window rules: `~/.config/niri/config.kdl`.
- Brightness: `~/.local/bin/brightness.sh`.
- Audio: `~/.local/bin/volume.sh`.
- Battery and system: `~/.config/waybar/config.jsonc` and `sys-status.sh`.
- Night light: `~/.config/systemd/user/wlsunset.service`.
- Per-workspace wallpapers: `~/.config/rice/` and `wallpaperctl.sh`.
