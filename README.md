# pixel-rice

<p align="center">
  <b>Español</b> · <a href="README.en.md">English</a>
</p>

Rice personal de **Niri + Waybar + Mako + Yazi + Kitty** con estética pixel-art
cyberpunk/HUD sobre **Debian 13 (trixie)**.

Este repositorio contiene la configuración de usuario, los scripts propios, el
tema de SDDM y los instaladores necesarios para reconstruir el escritorio en
otro equipo Debian. No contiene secretos, perfiles de navegador, tokens de
Jellyfin ni binarios de terceros.

## Qué incluye

- **Niri 26.04**: workspaces HOME / DEV / MUSIC / GAME, columnas, atajos y
  reglas de ventanas.
- **Waybar HUD**: reloj, música, CAVA, red, Tailscale, Bluetooth, batería,
  DND, luz nocturna, paleta activa, modo juego y sistema.
- **Mako 1.11 + parche**: notificaciones con entrada desde arriba, fade-out de
  2 s, panel cyberpunk y título grande.
- **Fuzzel** como launcher, **Kitty** como terminal, **Yazi** como gestor de
  archivos con previews de PDF, imágenes, vídeo y `.docx`.
- **Dock pixel** y wallpapers por nivel con crossfade.
- **SDDM** con tema `pixel-hud`.
- **Confort visual**: `wlsunset` (`Mod+Alt+N`) y selector de paletas
  (`Mod+Alt+P`): CYBER, MAGENTA, AMBER, MATRIX e ICE.
- Scripts de portapapeles, historial de notificaciones, capturas, CAVA,
  Tailscale, Jellyfin y grupos de apps.

## Requisitos

- **Debian 13 trixie** (probado en un IdeaPad 5 15IIL05, Intel Iris Plus,
  Wayland).
- **Niri 26.04** instalado en el sistema (en el equipo original está en
  `/usr/local/bin/niri`; no viene del repositorio de Debian).
- Acceso a `sudo` para paquetes y SDDM.
- Sesión Wayland con `niri` como compositor.
- `xdg-desktop-portal-gtk` y `pipewire` funcionando.

Las versiones exactas de los componentes externos están en
`packages/external.tsv`.

## Instalación rápida

```sh
git clone https://github.com/angelnr/pixel-rice.git
cd pixel-rice
chmod +x bootstrap.sh build/mako.sh install/*.sh
./bootstrap.sh
```

`bootstrap.sh` hace, en orden:

1. Paquetes APT + tema SDDM (`install/system.sh`, pide `sudo`).
2. Binarios externos: Yazi, matugen, jfsh, ble.sh y ouch
   (`install/external.sh`).
3. Compila Mako 1.11 con el parche (`build/mako.sh`).
4. Copia dotfiles, assets y activa servicios de usuario (`install/user.sh`).
5. Instala los Flatpaks (`install/flatpak.sh`).

Después hay pasos manuales obligatorios: Tailscale, SSH, Jellyfin/Finamp,
perfil de Brave y login de Steam/Discord. Están en
[`docs/POST-INSTALL.md`](docs/POST-INSTALL.md).

## Instalación manual

Si prefieres controlar cada paso:

```sh
# 1. Niri 26.04: instálalo antes según docs/NIRI.md
# 2. Paquetes y SDDM
./install/system.sh

# 3. Binarios externos
./install/external.sh

# 4. Mako parcheado
./build/mako.sh

# 5. Dotfiles y servicios de usuario
./install/user.sh

# 6. Flatpaks
./install/flatpak.sh
```

### Dependencias de Mako

`build/mako.sh` necesita:

```sh
sudo apt install build-essential meson ninja-build pkg-config \
  libcairo2-dev libpango1.0-dev libglib2.0-dev libgdk-pixbuf-2.0-dev \
  libwayland-dev wayland-protocols libsystemd-dev
```

Compila Mako **1.11.0** desde el tag oficial, aplica
`patches/mako-anim.patch` y deja `mako` y `makoctl` en `~/.local/bin`.
El servicio de usuario usa `~/.local/bin/mako` mediante el drop-in
`home/.config/systemd/user/mako.service.d/exec.conf`.

## Estructura

```text
pixel-rice/
├── bootstrap.sh
├── build/mako.sh
├── install/
│   ├── system.sh       # APT + SDDM
│   ├── external.sh     # yazi, matugen, jfsh, blesh, ouch
│   ├── user.sh         # dotfiles + assets + servicios
│   └── flatpak.sh
├── packages/
│   ├── apt-essential.txt
│   ├── apt-manual-full.txt
│   ├── flatpak.txt
│   └── external.tsv
├── patches/mako-anim.patch
├── home/               # se copia sobre $HOME
│   ├── .bashrc
│   ├── .profile
│   ├── .config/
│   └── .local/
├── assets/
│   ├── sddm/pixel-hud/
│   ├── cursors/PixelCursor/
│   ├── icons/pixora-dark/
│   ├── sounds/pixel/
│   └── wallpapers/     # muestra; el set completo no se versiona
├── docs/
│   ├── POST-INSTALL.md
│   ├── NIRI.md
│   ├── HARDWARE.md
│   ├── SECRETS.md
│   ├── ROADMAP.md
│   └── en/             # traducciones al inglés
├── README.md
└── README.en.md
```

Los ficheros que contienen `@HOME@` son plantillas: `install/user.sh` los copia
y sustituye `@HOME@` por el `$HOME` real. Los servicios systemd usan `%h`.

## Personalización

### Cambiar paleta

```sh
palette-menu.sh          # o Mod+Alt+P
palette-apply.py magenta # cyber, magenta, amber, matrix, ice
palette-status.sh
```

La paleta se guarda en `~/.config/rice/palettes.json` y se aplica a Waybar,
Mako, Kitty, Fuzzel, Niri, Cava, Swaylock, GTK y a las plantillas de matugen.
Así no se pierde cuando rota el wallpaper.

### Luz nocturna

```sh
nightlight-toggle.sh     # o Mod+Alt+N
systemctl --user status wlsunset
```

Activa `wlsunset` a 3500 K; el indicador de Waybar muestra `// NIGHT` o
`// DAY`.

### Notificaciones

```sh
makoctl reload
makoctl dismiss --all
~/.local/bin/notify.sh "TEST" "Título" "Cuerpo"
```

El tema está en `~/.config/mako/config` y `~/.config/mako/mako-colors`.

### Yazi

`yazi` incluye previews de texto/código, PDF, imagen y vídeo. El plugin
`docx-preview.yazi` convierte `.docx` con `docx2txt`. `ouch` está disponible
para comprimir/descomprimir desde terminal.

## Qué NO está en el repositorio

- `~/.ssh`, claves privadas y `known_hosts`.
- `~/.config/BraveSoftware`, `~/.config/Code`, `~/.config/opencode`.
- Tokens de Jellyfin, Finamp, Tailscale, Docker o GitHub.
- `~/.local/share/flatpak`, perfiles de Steam/Discord y sus logins.
- `~/.cache`, historiales, `level-wallpapers.json` y backups `.bak-*`.
- Binarios descargados de terceros y los 78 MB de wallpapers originales.
- El tema de iconos Tela-circle (45 MB); se instala aparte.

Antes de publicar, revisa [`docs/SECRETS.md`](docs/SECRETS.md).

## Versiones fijadas

| Componente | Versión |
|---|---|
| Debian | 13 trixie |
| Niri | 26.04 |
| Waybar | 0.12.x |
| Kitty | 0.41.x |
| Mako | 1.11.0 + parche local |
| Yazi | 26.9.1 |
| matugen | 4.2.0 |
| jfsh | 0.2.1 |
| ble.sh | 0.4.0-devel3 |
| ouch | 0.8.3 |
| pandoc | 3.1.11 |

## Diferencias esperadas en otro equipo

El rice está pensado para el hardware original. En otro portátil puede cambiar:

- El nombre del output (`eDP-1`) y la configuración de monitores.
- Brillo, batería, teclas de función y `xwayland-satellite`.
- El login de Tailscale, Jellyfin, Brave, Steam y Discord.
- Los permisos de notificaciones web, que viven en el perfil de Brave.
- Los wallpapers y temas de iconos si no se copian los assets completos.

## Diagnóstico rápido

```sh
niri validate
systemctl --user status waybar
systemctl --user status mako
makoctl list
journalctl --user -u mako -b --no-pager | tail -30
```

Para reconstruir Mako:

```sh
./build/mako.sh
```

## Licencia y créditos

Los scripts y configuraciones propias se distribuyen bajo MIT (ver `LICENSE`).
Los temas, fuentes, iconos y wallpapers de terceros conservan sus licencias
originales; revisa `assets/` y los enlaces de `docs/` antes de redistribuirlos.
