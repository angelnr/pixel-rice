# pixel-rice

<p align="center">
  <a href="README.md">Español</a> · <b>English</b>
</p>

A personal **Niri + Waybar + Mako + Yazi + Kitty** rice with a pixel-art
cyberpunk/HUD look on **Debian 13 (trixie)**.

This repository contains the user configuration, custom scripts, SDDM theme and
installers needed to rebuild the desktop on another Debian machine. It does not
contain secrets, browser profiles, Jellyfin tokens or third-party binaries.

> English documentation lives under `docs/en/`; the Spanish originals are under `docs/`.

## What it includes

- **Niri 26.04**: HOME / DEV / MUSIC / GAME workspaces, columns, keybinds and
  window rules.
- **Waybar HUD**: clock, music, CAVA, network, Tailscale, Bluetooth, battery,
  DND, night light, active palette, game mode and system stats.
- **Mako 1.11 + patch**: notifications slide in from the top, fade out over
  2 s, cyberpunk panel and large title.
- **Fuzzel** launcher, **Kitty** terminal and **Yazi** file manager with PDF,
  image, video and `.docx` previews.
- **Pixel dock** and per-workspace wallpapers with crossfade.
- **SDDM** with the `pixel-hud` theme.
- **Visual comfort**: `wlsunset` (`Mod+Alt+N`) and a palette selector
  (`Mod+Alt+P`): CYBER, MAGENTA, AMBER, MATRIX and ICE.
- Clipboard, notification history, screenshot, CAVA, Tailscale, Jellyfin and
  app-group scripts.

## Requirements

- **Debian 13 trixie** (tested on an IdeaPad 5 15IIL05, Intel Iris Plus,
  Wayland).
- **Niri 26.04** installed on the system (on the original machine it lives at
  `/usr/local/bin/niri`; it is not provided by the Debian repository).
- `sudo` access for packages and SDDM.
- A Wayland session using `niri` as the compositor.
- `xdg-desktop-portal-gtk` and `pipewire` working.

Exact versions of external components are listed in `packages/external.tsv`.

## Quick install

```sh
git clone https://github.com/angelnr/pixel-rice.git
cd pixel-rice
chmod +x bootstrap.sh build/mako.sh install/*.sh
./bootstrap.sh
```

`bootstrap.sh` runs, in order:

1. APT packages + SDDM theme (`install/system.sh`, asks for `sudo`).
2. External binaries: Yazi, matugen, jfsh, ble.sh and ouch
   (`install/external.sh`).
3. Builds Mako 1.11 with the patch (`build/mako.sh`).
4. Copies dotfiles/assets and enables user services (`install/user.sh`).
5. Installs the Flatpaks (`install/flatpak.sh`).

There are mandatory manual steps afterwards: Tailscale, SSH, Jellyfin/Finamp,
Brave profile and Steam/Discord login. They are documented in
[`docs/en/POST-INSTALL.md`](docs/en/POST-INSTALL.md).

## Manual install

If you prefer to control every step:

```sh
# 1. Niri 26.04: install it first, see docs/en/NIRI.md
# 2. Packages and SDDM
./install/system.sh

# 3. External binaries
./install/external.sh

# 4. Patched Mako
./build/mako.sh

# 5. Dotfiles and user services
./install/user.sh

# 6. Flatpaks
./install/flatpak.sh
```

### Mako build dependencies

`build/mako.sh` needs:

```sh
sudo apt install build-essential meson ninja-build pkg-config \
  libcairo2-dev libpango1.0-dev libglib2.0-dev libgdk-pixbuf-2.0-dev \
  libwayland-dev wayland-protocols libsystemd-dev
```

It builds Mako **1.11.0** from the official tag, applies
`patches/mako-anim.patch` and installs `mako`/`makoctl` into `~/.local/bin`.
The user service runs `~/.local/bin/mako` through the drop-in
`home/.config/systemd/user/mako.service.d/exec.conf`.

## Repository layout

```text
pixel-rice/
├── bootstrap.sh
├── build/mako.sh
├── install/
│   ├── system.sh       # APT + SDDM
│   ├── external.sh     # yazi, matugen, jfsh, blesh, ouch
│   ├── user.sh         # dotfiles + assets + services
│   └── flatpak.sh
├── packages/
│   ├── apt-essential.txt
│   ├── apt-manual-full.txt
│   ├── flatpak.txt
│   └── external.tsv
├── patches/mako-anim.patch
├── home/               # copied over $HOME
│   ├── .bashrc
│   ├── .profile
│   ├── .config/
│   └── .local/
├── assets/
│   ├── sddm/pixel-hud/
│   ├── cursors/PixelCursor/
│   ├── icons/pixora-dark/
│   ├── sounds/pixel/
│   └── wallpapers/     # samples; the full set is not versioned
├── docs/
│   ├── POST-INSTALL.md
│   ├── NIRI.md
│   ├── HARDWARE.md
│   ├── SECRETS.md
│   ├── ROADMAP.md
│   └── en/             # English translations
├── README.md
└── README.en.md
```

Files containing `@HOME@` are templates: `install/user.sh` copies them and
replaces `@HOME@` with the real `$HOME`. Systemd units use `%h`.

## Customization

### Change palette

```sh
palette-menu.sh          # or Mod+Alt+P
palette-apply.py magenta # cyber, magenta, amber, matrix, ice
palette-status.sh
```

The palette is stored in `~/.config/rice/palettes.json` and applied to Waybar,
Mako, Kitty, Fuzzel, Niri, Cava, Swaylock, GTK and the matugen templates, so it
survives wallpaper rotation.

### Night light

```sh
nightlight-toggle.sh     # or Mod+Alt+N
systemctl --user status wlsunset
```

It enables `wlsunset` at 3500 K; the Waybar indicator shows `// NIGHT` or
`// DAY`.

### Notifications

```sh
makoctl reload
makoctl dismiss --all
~/.local/bin/notify.sh "TEST" "Title" "Body"
```

The theme lives in `~/.config/mako/config` and
`~/.config/mako/mako-colors`.

### Yazi

`yazi` previews text/code, PDF, images and video. The `docx-preview.yazi` plugin
converts `.docx` with `docx2txt`. `ouch` is available for compressing and
extracting archives from the terminal.

## What is NOT in the repository

- `~/.ssh`, private keys and `known_hosts`.
- `~/.config/BraveSoftware`, `~/.config/Code`, `~/.config/opencode`.
- Jellyfin, Finamp, Tailscale, Docker or GitHub tokens.
- `~/.local/share/flatpak`, Steam/Discord profiles and logins.
- `~/.cache`, histories, `level-wallpapers.json` and `.bak-*` backups.
- Downloaded third-party binaries and the original 78 MB wallpaper set.
- The Tela-circle icon theme (45 MB); install it separately.

Before publishing, read [`docs/en/SECRETS.md`](docs/en/SECRETS.md).

## Pinned versions

| Component | Version |
|---|---|
| Debian | 13 trixie |
| Niri | 26.04 |
| Waybar | 0.12.x |
| Kitty | 0.41.x |
| Mako | 1.11.0 + local patch |
| Yazi | 26.9.1 |
| matugen | 4.2.0 |
| jfsh | 0.2.1 |
| ble.sh | 0.4.0-devel3 |
| ouch | 0.8.3 |
| pandoc | 3.1.11 |

## Expected differences on another machine

This rice targets the original hardware. On another laptop, expect changes in:

- The output name (`eDP-1`) and monitor configuration.
- Brightness, battery, function keys and `xwayland-satellite`.
- Tailscale, Jellyfin, Brave, Steam and Discord logins.
- Web notification permissions, which live in the Brave profile.
- Wallpapers and icon themes if the full assets are not copied.

## Quick diagnostics

```sh
niri validate
systemctl --user status waybar
systemctl --user status mako
makoctl list
journalctl --user -u mako -b --no-pager | tail -30
```

Rebuild Mako:

```sh
./build/mako.sh
```

## License and credits

The custom scripts and configurations are distributed under the MIT license
(see `LICENSE`). Third-party themes, fonts, icons and wallpapers keep their
original licenses; check `assets/` and the links under `docs/` before
redistributing them.
