# Post-instalación

Después de `bootstrap.sh` hay cosas que **no** se pueden automatizar porque son
estado de usuario, secretos o servicios externos.

## 1. Niri

Comprueba que Niri 26.04 está instalado y que la sesión arranca. Ver
[`NIRI.md`](NIRI.md).

```sh
niri validate
niri msg layers
```

## 2. Tailscale

El módulo `// TS` de Waybar y el menú de Tailscale necesitan una sesión
autenticada. Instala Tailscale desde su repositorio oficial y ejecuta:

```sh
sudo tailscale up
tailscale status
```

No copies `tailscaled.state` ni claves de autenticación al repositorio.

## 3. SSH

El repo no incluye claves. Crea una clave y configúrala:

```sh
ssh-keygen -t ed25519 -C "angel@$(hostname)"
ssh-copy-id servidor-angel
ssh-copy-id santiserver
```

Ejemplo de `~/.ssh/config` (usa los nombres MagicDNS de Tailscale):

```sshconfig
Host servidor-angel
    HostName servidor-angel
    User TU_USUARIO
    IdentityFile ~/.ssh/id_ed25519

Host santiserver
    HostName santiserver
    User TU_USUARIO
    IdentityFile ~/.ssh/id_ed25519
```

## 4. Docker

El usuario debe pertenecer al grupo `docker`; el cambio requiere cerrar sesión:

```sh
sudo usermod -aG docker "$USER"
docker run --rm hello-world
```

## 5. Jellyfin / Finamp / jfsh

Los tokens y servidores no están en el repo.

```sh
flatpak install --user flathub com.unicornsonlsd.finamp io.mpv.Mpv
flatpak run com.unicornsonlsd.finamp
jfsh
```

En Finamp introduce el host de Jellyfin (por Tailscale suele ser
`http://servidor-angel:8096`). En `jfsh`, la primera ejecución pide host,
usuario y contraseña.

## 6. Notificaciones de Brave

Abre `brave://settings/content/notifications` y permite:

- `https://web.whatsapp.com`
- `https://mail.google.com`
- `https://calendar.google.com`

Después, en cada web:

1. Candado → **Notificaciones** → **Permitir**.
2. WhatsApp Web: **Ajustes → Notificaciones**.
3. Gmail: **Configuración → General → Notificaciones de escritorio**.
4. Calendar: **Configuración → Notificaciones**.
5. Mantén las pestañas abiertas o fijadas.

Prueba el popup sin depender del navegador:

```sh
~/.local/bin/notify.sh "TEST" "Notificación" "HUD cyberpunk"
```

## 7. Brave, VS Code y otras apps

El repositorio no incluye perfiles ni extensiones. Instala las apps desde sus
repositorios oficiales y vuelve a iniciar sesión. No copies
`~/.config/BraveSoftware` ni `~/.config/Code` desde el equipo original: contienen
tokens, historial y estado.

## 8. Wallpapers e iconos

El repo incluye **seis wallpapers de muestra** y el tema de iconos
`pixora-dark`. El set completo de `~/Imágenes/pixel_art` y el tema
`Tela-circle` no se versionan por tamaño.

```sh
mkdir -p ~/Imágenes/pixel_art
cp pixel-rice/assets/wallpapers/* ~/Imágenes/pixel_art/
~/.local/bin/wallpaperctl.sh rotate-all
```

Para Tela-circle, instálalo desde su repositorio/origen habitual y selecciónalo
en la configuración de iconos.

## 9. Flatpaks

```sh
flatpak install --user -y flathub com.valvesoftware.Steam \
  com.discordapp.Discord com.unicornsonlsd.finamp io.mpv.Mpv
```

Steam y Discord requieren login propio. Finamp requiere el servidor Jellyfin.

## 10. SDDM

`install/system.sh` copia el tema y el archivo
`/etc/sddm.conf.d/zz-pixel-hud.conf`. Para activarlo:

```sh
sudo systemctl enable sddm
sudo systemctl restart sddm
```

## 11. Comprobación final

```sh
niri validate
systemctl --user status waybar
systemctl --user status mako
systemctl --user status pixel-dock
makoctl reload
~/.local/bin/palette-status.sh
~/.local/bin/nightlight-status.sh
```
