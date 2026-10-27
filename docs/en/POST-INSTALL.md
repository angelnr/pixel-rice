# Post-installation

<p align="center">
  <a href="../POST-INSTALL.md">Español</a> · <b>English</b>
</p>

After `bootstrap.sh`, some things **cannot** be automated because they are user
state, secrets or external services.

## 1. Niri

Check that Niri 26.04 is installed and that the session starts. See
[`NIRI.md`](NIRI.md).

```sh
niri validate
niri msg layers
```

## 2. Tailscale

The Waybar `// TS` module and the Tailscale menu need an authenticated session.
Install Tailscale from its official repository and run:

```sh
sudo tailscale up
tailscale status
```

Do not copy `tailscaled.state` or authentication keys into the repository.

## 3. SSH

The repository does not include keys. Create one and configure it:

```sh
ssh-keygen -t ed25519 -C "angel@$(hostname)"
ssh-copy-id servidor-angel
ssh-copy-id santiserver
```

Example `~/.ssh/config` (using Tailscale MagicDNS names):

```sshconfig
Host servidor-angel
    HostName servidor-angel
    User YOUR_USER
    IdentityFile ~/.ssh/id_ed25519

Host santiserver
    HostName santiserver
    User YOUR_USER
    IdentityFile ~/.ssh/id_ed25519
```

## 4. Docker

The user must belong to the `docker` group; the change requires a new login:

```sh
sudo usermod -aG docker "$USER"
docker run --rm hello-world
```

## 5. Jellyfin / Finamp / jfsh

Tokens and server addresses are not in the repository.

```sh
flatpak install --user flathub com.unicornsonlsd.finamp io.mpv.Mpv
flatpak run com.unicornsonlsd.finamp
jfsh
```

In Finamp, enter the Jellyfin host (over Tailscale it is usually
`http://servidor-angel:8096`). On first run, `jfsh` asks for host, username and
password.

## 6. Brave notifications

Open `brave://settings/content/notifications` and allow:

- `https://web.whatsapp.com`
- `https://mail.google.com`
- `https://calendar.google.com`

Then, on each site:

1. Padlock → **Notifications** → **Allow**.
2. WhatsApp Web: **Settings → Notifications**.
3. Gmail: **Settings → General → Desktop notifications**.
4. Calendar: **Settings → Notifications**.
5. Keep the tabs open or pinned.

Test the popup without depending on the browser:

```sh
~/.local/bin/notify.sh "TEST" "Notification" "Cyberpunk HUD"
```

## 7. Brave, VS Code and other apps

The repository does not include profiles or extensions. Install the apps from
their official repositories and sign in again. Do not copy
`~/.config/BraveSoftware` or `~/.config/Code` from the original machine: they
contain tokens, history and state.

## 8. Wallpapers and icons

The repository includes **six sample wallpapers** and the `pixora-dark` icon
theme. The full `~/Imágenes/pixel_art` set and the `Tela-circle` theme are not
versioned because of their size.

```sh
mkdir -p ~/Imágenes/pixel_art
cp pixel-rice/assets/wallpapers/* ~/Imágenes/pixel_art/
~/.local/bin/wallpaperctl.sh rotate-all
```

For Tela-circle, install it from its usual repository/source and select it in
the icon settings.

## 9. Flatpaks

```sh
flatpak install --user -y flathub com.valvesoftware.Steam \
  com.discordapp.Discord com.unicornsonlsd.finamp io.mpv.Mpv
```

Steam and Discord require their own login. Finamp requires the Jellyfin
server.

## 10. SDDM

`install/system.sh` copies the theme and
`/etc/sddm.conf.d/zz-pixel-hud.conf`. To enable it:

```sh
sudo systemctl enable sddm
sudo systemctl restart sddm
```

## 11. Final checks

```sh
niri validate
systemctl --user status waybar
systemctl --user status mako
systemctl --user status pixel-dock
makoctl reload
~/.local/bin/palette-status.sh
~/.local/bin/nightlight-status.sh
```
