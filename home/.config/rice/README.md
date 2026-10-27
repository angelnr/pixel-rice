# Rice pixel art / HUD de videojuego

## Paleta definitiva

| Rol | Color |
|---|---|
| Fondo HUD | `#0e1418` |
| Panel | `#142126` |
| Línea / borde inactivo | `#223138` |
| Texto | `#dfe7e8` |
| Cian (foco / acento) | `#5cc8d7` |
| Lila (secundario / música) | `#b48ead` |
| Ámbar (alertas) | `#e0af68` |
| Rojo (crítico) | `#e06c75` |

La paleta de acentos es fija. Al rotar el wallpaper solo cambia la imagen de
fondo; las plantillas de matugen también escriben estos colores fijos.

## Niveles (workspaces niri)

| Nivel | Nombre | Uso |
|---|---|---|
| 1 | HOME | Navegador y uso diario |
| 2 | DEV | Terminal, editor y documentación |
| 3 | MUSIC | CAVA, reproductor y audio |
| 4 | GAME | Steam, emuladores y ocio |

`workspace-order.sh` fuerza este orden al arrancar. Niri deja además un
workspace dinámico extra al final, que aparece como un punto tenue en la barra.

## Componentes

- **Waybar HUD**: corazón, niveles, reloj central, música MPRIS, CAVA, volumen,
  brillo, batería, Wi-Fi, Bluetooth, perfil de energía, inhibidor de idle,
  SYS (CPU/RAM/disco, con disco en el tooltip), DND, modo juego y bandeja.
- **Fuzzel**: `SELECT PROGRAM >`, borde de 2 px, iconos Pixora Dark.
- **Niri**: focus ring cian, borde lila, gaps de 8 px, ventanas flotantes para
  CAVA, SYS-MON, selector de wallpapers e instalador de Steam.
- **Kitty**: Spleen 8x16, paleta HUD fija, prompt pixel, saludo con
  `~/Imágenes/terminal_image.png` (con detección de cambios por fecha/tamaño).
- **Mako**: notificaciones HUD cyberpunk pixel-art, con Spleen.
  Panel oscuro cian/magenta, entrada desde arriba y fade-out de 2 s; 6 s visible.
- **Swaylock**: pantalla generada con Gengar, `SYSTEM LOCKED`, reloj y fecha.
- **GTK/KDE**: color scheme `PixelHUD`, CSS GTK3/GTK4, iconos Pixora Dark,
  cursor PixelCursor y sonidos chiptune `pixel`.
- **Wallpapers**: daemon `pixel-wallpaperd.py` con un wallpaper aleatorio por
  nivel y crossfade de 1,2 s. La rotación cada 30 min la dispara
  `wallpaper-rotate.timer` y el daemon hace la transición.
- **Selector de wallpapers**: rejilla de miniaturas con `Mod+W`.
- **Portapapeles/notificaciones**: historial propio y visor con `Mod+N`.
- **Dock inferior**: apps favoritas en `~/.config/rice/dock.json`, servicio
  `pixel-dock.service`. Visible por defecto; solo se muestra/oculta con
  `Mod+Shift+D`. No reserva espacio en fullscreen.
- **Steam/Discord**: Flatpaks instalados; se abren en GAME y usan `xwayland-satellite`.
- **Tailscale**: módulo `// TS` en Waybar; clic para estado, up/down, copiar IP
  y SSH a peers online.
- **Dev toolkit**: `fzf`, `zoxide`, `ble.sh`, `fd`, `rg`, `bat`, `yazi`.
- **Yazi**: previews de PDF/imagen/vídeo y `.docx` con `docx2txt`/`pandoc`; `ouch` para archivos.
- **Confort visual**: luz nocturna con `wlsunset` (`Mod+Alt+N`, `// DAY`/`// NIGHT`)
  y selector de paletas HUD (`Mod+Alt+P`, indicador `// CYBER`).
- **Finamp**: app de música de Jellyfin (solo biblioteca musical), en MUSIC.
- **Jellyfin CLI**: `jfsh` + `mpv` Flatpak, con `Mod+Alt+J` o `jellyfin`.

## Notificaciones

Mako es el daemon (`mako.service`). La versión de Debian no tiene animaciones,
así que se compiló **Mako 1.11 con un parche local** que hace slide-in y fade-out:

- Binario: `~/.local/bin/mako` (y `~/.local/bin/makoctl`).
- Override de systemd: `~/.config/systemd/user/mako.service.d/exec.conf`.
- Activación D-Bus: `~/.local/share/dbus-1/services/fr.emersion.mako.service`,
  que usa `~/.local/bin/mako-dbus-launch.sh` para recuperar `WAYLAND_DISPLAY`.
- Parche reproducible: `~/.config/rice/mako-anim.patch`.
- Animación: entrada desde arriba en 300 ms + `6 s` visible + `2 s` de fade.
- Sin icono de app (`icons=0`); el título usa `x-large` y la cabecera es
  `▚ SYS.NOTIFY` en texto cian, con la app en magenta.
- Config: `~/.config/mako/config`; colores: `~/.config/mako/mako-colors`.
- Recargar: `makoctl reload`; cerrar todas: `makoctl dismiss --all`.

El popup usa un panel `#0a0f14`, borde cian de 4 px, cabecera
`▚ SYS.NOTIFY // app` y línea inferior magenta. Las urgencias alta/crítica
cambian el marco a ámbar/rojo.
El modo no molestar sigue en `Mod+Shift+N` y en el indicador `// NTF` / `// DND`.

### WhatsApp Web, Gmail y Google Calendar

Las notificaciones de navegador necesitan permiso por sitio; no se puede
conceder desde fuera del navegador por seguridad. En Brave:

1. Abrir `brave://settings/content/notifications`.
2. En **Permitir**, añadir:
   - `https://web.whatsapp.com`
   - `https://mail.google.com`
   - `https://calendar.google.com`
3. Abrir cada sitio, pulsar el candado → **Notificaciones** → **Permitir**.
4. WhatsApp Web: **Ajustes → Notificaciones** → activar notificaciones.
5. Gmail: **Configuración → General → Notificaciones de escritorio** → activar
   “Nuevo correo” o “Correo importante”.
6. Calendar: **Configuración → Notificaciones** → activar recordatorios.
7. Mantener las pestañas abiertas o fijadas; WhatsApp Web y Gmail necesitan la
   pestaña activa. En Brave, permitir que siga en segundo plano al cerrar.

Para probar el estilo sin depender de los sitios:

```sh
~/.local/bin/notify.sh "Brave" "WhatsApp: Ana" "Mensaje de prueba"
```

## Atajos

| Atajo | Acción |
|---|---|
| `Mod+D` | Launcher Fuzzel (`SELECT PROGRAM >`) |
| `Mod+T` | Terminal Kitty |
| `Mod+1..4` | Ir a HOME / DEV / MUSIC / GAME |
| `Mod+2` | Ir a DEV + lanzar VS Code y terminal |
| `Mod+3` | Ir a MUSIC + lanzar Finamp |
| `Mod+Shift+2` | Relanzar el grupo DEV |
| `Mod+Shift+3` | Relanzar Finamp en MUSIC |
| `Mod+Ctrl+1..4` | Mover columna a ese nivel |
| `Mod+W` | Selector visual de wallpapers |
| `Mod+Shift+W` | Wallpaper aleatorio para el nivel actual |
| `Mod+Shift+M` | Abrir/cerrar CAVA |
| `Mod+Shift+S` | Menú de capturas / cuentagotas |
| `Mod+N` | Portapapeles e historial de notificaciones |
| `Mod+Shift+N` | Activar/desactivar no molestar |
| `Mod+Alt+N` | Activar/desactivar luz nocturna |
| `Mod+Alt+P` | Selector de paleta HUD |
| `Mod+4` | Ir a GAME y lanzar su grupo de apps |
| `Mod+Shift+4` | Relanzar el grupo GAME |
| `Mod+Shift+G` | Activar/desactivar modo juego |
| `Mod+Shift+D` | Mostrar/ocultar el dock |
| `Mod+Shift+Y` | Abrir Yazi en Kitty |
| `Mod+Alt+J` | Abrir Jellyfin TUI (jfsh) |
| `Mod+Shift+Q` | Menú de sistema |
| `Super+Alt+L` | Bloquear pantalla pixel art |
| `Mod+Shift+A` | Escuchar el tema de sonidos pixel |
| `Mod+Alt+W` | Columnas con pestañas (antes era `Mod+W`) |
| `Mod+O` | Overview |
| `Mod+Shift+/` | Lista de atajos |

## Wallpapers por nivel

El estado se guarda en `~/.cache/rice/level-wallpapers.json`. El daemon
escucha los eventos de niri y hace crossfade al entrar en cada nivel.

Control manual:

```sh
wallpaperctl.sh rotate        # aleatorio para el nivel actual
wallpaperctl.sh rotate-all    # rota todos los niveles
wallpaperctl.sh set LEVEL PATH
wallpaperctl.sh set-current PATH
```


## DEV y GAME grupos

`~/.config/rice/groups.json` define qué lanza cada nivel:

```json
{
  "GAME": [
    "~/.local/bin/steam-launch.sh",
    "~/.local/bin/discord-launch.sh",
    "brave-browser --new-window https://www.youtube.com"
  ],
  "DEV": [
    "code --new-window",
    "kitty --title DEV-SHELL"
  ],
  "MUSIC": [
    "~/.local/bin/finamp-launch.sh"
  ]
}
```

`ordered-group.sh` lanza las apps en orden y coloca las columnas de izquierda a
derecha (Steam → Discord → YouTube en GAME; VS Code → terminal en DEV).

- `Mod+2` / `Mod+3` / `Mod+4`: lanzan el grupo una vez por sesión.
- `Mod+Shift+2` / `Mod+Shift+3` / `Mod+Shift+4`: fuerzan el relanzamiento.
- Las apps que no existen se omiten.

## Terminal / desarrollo

- `ble.sh`: autosugerencias, resaltado y menú de autocompletado en Bash.
- `zoxide`: `z <ruta>` para saltar a directorios frecuentes; `zi` interactivo.
- `fzf`: `Ctrl+R` historial, `Ctrl+T` archivos, `Alt+C` cd interactivo.
  `fzf --bash` ya está cargado en `.bashrc`.
- `yazi` / `y` / `fm`: gestor de archivos TUI con previews; `Mod+Shift+Y` abre
  Yazi y al salir deja una shell en el último directorio.
- `fd`, `rg`, `bat`: búsqueda y visualización rápida.
- Yazi: `ffmpeg`/`ffprobe` para vídeo, `pdftoppm` para PDF, `docx2txt` para
  `.docx` (plugin `docx-preview.yazi`), `ouch` para comprimir/descomprimir.
- `jellyfin` o `Mod+Alt+J`: `jfsh` con `mpv` Flatpak. La primera vez pide host,
  usuario y contraseña de Jellyfin.

### Atajos de Yazi

- `q` salir; `Q` salir sin escribir cwd; `Ctrl+C` cerrar pestaña; `Esc` limpiar selección.
- `h`/`l` padre/entrar; `H`/`L` atrás/adelante; `j`/`k` mover; `gg`/`G` inicio/final.
- `Espacio` seleccionar; `v` modo visual; `Ctrl+A` seleccionar todo; `Ctrl+R` invertir.
- `y` copiar; `x` cortar; `p` pegar; `P` pegar sobrescribiendo; `Y`/`X` cancelar.
- `d` papelera; `D` borrar definitivamente; `r` renombrar; `a` crear; `A` crear en lote.
- `s` buscar por nombre con fd; `S` buscar contenido con rg; `z` fzf; `Z` zoxide.
- `/` buscar siguiente; `?` anterior; `n`/`N` siguiente/anterior.
- `t t` nueva pestaña; `1..9` cambiar; `[`/`]` anterior/siguiente; `w` tareas; `~` ayuda.

### Editores y visores de Yazi

- Texto y código (`text/*`): **nano** en primer plano (`Enter`).
- Imágenes (`image/*`): **Gwenview**.
- PDF (`application/pdf`): **Okular**.
- Audio y vídeo: **mpv** Flatpak.
- Otros archivos: `xdg-open` como último recurso.

`EDITOR` y `VISUAL` valen `nano` en `~/.bashrc` y `~/.profile`. Además,
`xdg-open` ya no manda imágenes ni PDF a Photopea:

```text
image/*          -> org.kde.gwenview.desktop
application/pdf  -> okularApplication_pdf.desktop
text/plain       -> nano.desktop
```

Se puede comprobar con `xdg-mime query default image/png` o `gio mime
application/pdf`. Si Brave/Photopea vuelve a registrarse como predeterminado,
basta repetir:

```sh
xdg-mime default org.kde.gwenview.desktop image/png image/jpeg image/webp
xdg-mime default okularApplication_pdf.desktop application/pdf
xdg-mime default nano.desktop text/plain
```

Yazi y Kitty no son redundantes: Kitty es el emulador de terminal; Yazi es una
app TUI que corre dentro de Kitty. Yazi puede previsualizar texto/código,
PDF, imágenes y archivos; para miniaturas de audio/vídeo y `.docx` hacen falta
dependencias extra (`ffmpegthumbnailer`, `docx2txt`/`pandoc`).

## SDDM

El tema está en `~/.config/sddm/themes/pixel-hud`.

Para instalarlo (pide contraseña):

```sh
~/.local/bin/install-sddm-theme.sh
```

Después reinicia SDDM o el equipo:

```sh
sudo systemctl restart sddm
```

## Steam / gaming

Steam ya está instalado como Flatpak de usuario (`com.valvesoftware.Steam`).
También se compiló `xwayland-satellite` en `~/.local/bin`, porque niri lo necesita
para integrar apps X11. `xwayland-env.sh` exporta `DISPLAY` a systemd/dbus y
`xdisplay.sh` lo detecta al lanzar apps X11. Steam abre en GAME.

Comandos de instalación usados:

```sh
flatpak install --user flathub com.valvesoftware.Steam
flatpak install --user flathub com.discordapp.Discord
```

## Tareas pendientes / hoja de ruta

- [x] **3. Mako reproducible**: `build/mako.sh` + `patches/mako-anim.patch` en
  `~/pixel-rice`; el binario local se puede reconstruir sin depender de /tmp.
- [x] **4. Yazi**: `ffmpeg`, `ffprobe`, `ffmpegthumbnailer`, `docx2txt`,
  `pandoc`, `ouch`, plugin `docx-preview.yazi` y reglas en `yazi.toml`.
- [x] **6. Confort visual**: `wlsunset` con `Mod+Alt+N`, módulo `// DAY`/`// NIGHT`
  y selector de paletas con `Mod+Alt+P` / `// CYBER`.
- [ ] **1. Backup**: `restic` hacia `servidor-angel`/`santiserver` por Tailscale.
- [ ] **2. SSH**: claves SSH y aliases para los servidores de Tailscale.
- [ ] **5. Utilidades**: `lazygit`, `delta`, `direnv`, `btop`, `tealdeer`,
  `zellij`, `satty`, `tesseract`, `wf-recorder`.
- [ ] **7. Repositorio**: publicar `~/pixel-rice` y probarlo en una VM Debian 13.

## Scripts nuevos

- `media-status.sh`, `sys-status.sh`, `hud-clock.sh`
- `nightlight-toggle.sh`, `nightlight-status.sh`
- `palette-apply.py`, `palette-menu.sh`, `palette-status.sh`
- `cava-toggle.sh`, `sysmon.sh`, `game-mode.sh`, `game-mode-status.sh`
- `bluetooth-menu.sh`, `dnd-status.sh`, `dnd-toggle.sh`
- `lock.sh`, `sound-test.sh`, `workspace-order.sh`
- `clipboard-store.py`, `clipboard-menu.py`
- `notification-history-daemon.py`, `notification-menu.py`, `archive-menu.sh`
- `mako-dbus-launch.sh`, `mako-anim.patch` (Mako local con slide-in + fade-out)
- `pixel-wallpaperd.py`, `wallpaperctl.sh`, `wallpaper-thumbs.sh`,
  `wallpaper-picker.py`, `wallpaper-picker.sh`
- `screenshot-menu.sh`, `notify.sh`
- `pixel-dock.py`, `dock-toggle.sh`, `ordered-group.sh`, `group-launch.sh`
- `yazi-shell.sh`
- `steam-launch.sh`, `discord-launch.sh`, `retroarch-launch.sh`, `finamp-launch.sh`
- `tailscale-menu.sh`, `ts-status.sh`
- `jellyfin-shell.sh`
- `xwayland-satellite`, `xwayland-env.sh`, `xdisplay.sh`
- `install-sddm-theme.sh`
- `make-pixel-cursor.py`, `make-pixel-sounds.py`
