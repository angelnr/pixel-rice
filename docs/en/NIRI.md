# Niri 26.04 installation

<p align="center">
  <a href="../NIRI.md">Español</a> · <b>English</b>
</p>

This rice is tested with **Niri 26.04**. On the original machine it is installed
at `/usr/local/bin/niri`, not `/usr/bin`, and it does not depend on the Debian
package.

## Option 1: distribution package

If your Debian/derivative already packages Niri 26.04, install it with APT and
check:

```sh
niri --version
niri validate -c ~/.config/niri/config.kdl
```

## Option 2: build from the official tag

Install the build dependencies. On Debian 13 they are usually:

```sh
sudo apt install build-essential cargo git pkg-config \
  libseat-dev libinput-dev libgbm-dev libdrm-dev libegl1-mesa-dev \
  libgles2-mesa-dev libxkbcommon-dev libwayland-dev wayland-protocols \
  libpango1.0-dev libsystemd-dev libpipewire-0.3-dev libdisplay-info-dev \
  libudev-dev libxcb-composite0-dev libxcb-res0-dev
```

Then:

```sh
cargo install --git https://github.com/YaLTeR/niri.git \
  --tag v26.04 --locked --root "$HOME/.local"
```

Make sure `~/.local/bin` is in `PATH` and that the session launcher points to
the right binary. If you use SDDM, create/edit the Wayland session so it runs
`niri-session` or the command that matches your installation.

## xwayland-satellite

Steam and Discord are X11 Flatpaks. The rice uses `xwayland-satellite` to
integrate them into Niri:

```sh
# check the project's current instructions
# https://github.com/Supreeeme/xwayland-satellite
```

The original machine's binary is at `~/.local/bin/xwayland-satellite`, and
`xwayland-env.sh` exports `DISPLAY` for systemd/D-Bus. Without this step, Steam
and Discord may fail to start or receive keyboard input.

## Checks

```sh
niri validate
niri msg workspaces
niri msg layers
```
