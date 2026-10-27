# Secrets and data that must not be published

<p align="center">
  <a href="../SECRETS.md">Español</a> · <b>English</b>
</p>

Before publishing the repository, check that none of these slipped in:

- `~/.ssh` (private keys, `known_hosts`, config with internal hosts).
- `~/.config/BraveSoftware` (cookies, tokens, history, web permissions).
- `~/.config/Code` (extension tokens, history, synced settings).
- `~/.config/opencode` (sessions, credentials, history).
- `~/.config/jfsh` and `~/.local/state/jfsh` (server, user, token).
- `~/.local/share/flatpak` and Finamp/Steam/Discord data.
- `~/.config/gh`, `~/.git-credentials`, `~/.netrc`.
- `~/.cache/rice/*`, `level-wallpapers.json`, clipboard histories.
- Tailscale, Docker, GitHub or API tokens in `.bashrc`/`.profile`.
- Tailscale authentication keys or certificates.

## Quick check

```sh
grep -RInE 'token|password|secret|api[_-]?key|BEGIN .*PRIVATE' \
  --exclude-dir=.git --exclude-dir=assets .
```

If you want to publish a version containing secrets, use a private repository or
encrypt it with `age`/`chezmoi`. Do not commit a real `.env`; use
`.env.example`.

## Publication criteria

### Published

- Declarative configuration: Niri, Waybar, Mako, Yazi, Kitty, Fuzzel, GTK,
  matugen, Cava and Swaylock.
- Custom scripts in `home/.local/bin/*.sh` and `*.py`.
- Installers, the Mako patch and documentation.
- Small assets: SDDM theme, cursor, `pixora-dark` icons, sounds,
  `terminal_image.png` and a sample of wallpapers.

### Not published

| Data | Why |
|---|---|
| SSH keys, `known_hosts` | They allow identity impersonation or infrastructure disclosure. |
| Brave/Code/opencode profiles | Cookies, sessions, tokens and personal history. |
| `jfsh`, Finamp, Tailscale, Docker | Credentials and service state. |
| `~/.local/share/flatpak` | Private data from Flatpak apps. |
| `~/.cache`, logs, PIDs, sockets, `.swp` | Noise, local paths and potentially sensitive information. |
| `level-wallpapers.json`, histories | Session state, not reproducible configuration. |
| Third-party binaries and full icon/wallpaper sets | Large, architecture-specific and under their own licenses. |

The practical rule is: **if cloning the repo means signing in again or
generating a key, that file is not published**. If it is configuration that can
be copied and adapted, it is published.

`.gitignore` is a safety net, not an audit. Before publishing:

```sh
git status --ignored
git ls-files
grep -RInE 'token|password|secret|api[_-]?key|BEGIN .*PRIVATE' \
  --exclude-dir=.git --exclude-dir=assets .
```

The `palette-apply.py` hits (`token_to_new`, `__PALETTE_*`) are variable names,
not credentials. The `neofetch` and Niri comments are documentation text. The
`neofetch` `.bak` file is removed and ignored.
