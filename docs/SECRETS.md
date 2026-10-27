# Secretos y datos que no deben publicarse

<p align="center">
  <b>Español</b> · <a href="en/SECRETS.md">English</a>
</p>

Antes de subir el repositorio, revisa que no se hayan colado:

- `~/.ssh` (claves privadas, `known_hosts`, config con hosts internos).
- `~/.config/BraveSoftware` (cookies, tokens, historial, permisos web).
- `~/.config/Code` (tokens de extensiones, historial, settings sincronizados).
- `~/.config/opencode` (sesiones, credenciales, historial).
- `~/.config/jfsh` y `~/.local/state/jfsh` (servidor, usuario, token).
- `~/.local/share/flatpak` y datos de Finamp/Steam/Discord.
- `~/.config/gh`, `~/.git-credentials`, `~/.netrc`.
- `~/.cache/rice/*`, `level-wallpapers.json`, historiales de portapapeles.
- Tokens de Tailscale, Docker, GitHub o APIs en `.bashrc`/`.profile`.
- Claves de autenticación de Tailscale o certificados.

## Comprobación rápida

```sh
grep -RInE 'token|password|secret|api[_-]?key|BEGIN .*PRIVATE' \
  --exclude-dir=.git --exclude-dir=assets .
```

Si quieres publicar una versión con secretos, usa un repo privado o cifra con
`age`/`chezmoi`. No subas un `.env` real; usa `.env.example`.

## Criterio de publicación

### Sí se publica

- Configuración declarativa: Niri, Waybar, Mako, Yazi, Kitty, Fuzzel, GTK,
  matugen, Cava y Swaylock.
- Scripts propios en `home/.local/bin/*.sh` y `*.py`.
- Instaladores, parche de Mako y documentación.
- Assets pequeños: tema SDDM, cursor, iconos `pixora-dark`, sonidos,
  `terminal_image.png` y una muestra de wallpapers.

### No se publica

| Dato | Por qué |
|---|---|
| Claves SSH, `known_hosts` | Permiten suplantar identidades o revelar infraestructura. |
| Perfiles de Brave/Code/opencode | Cookies, sesiones, tokens e historial personal. |
| `jfsh`, Finamp, Tailscale, Docker | Credenciales y estado de servicios. |
| `~/.local/share/flatpak` | Datos privados de las apps Flatpak. |
| `~/.cache`, logs, PID, sockets, `.swp` | Ruido, rutas locales y posible información sensible. |
| `level-wallpapers.json`, historiales | Estado de la sesión, no configuración reproducible. |
| Binarios de terceros y sets completos de iconos/wallpapers | Pesan, cambian por arquitectura y tienen sus propias licencias. |

La regla práctica es: **si al clonar el repo hay que volver a iniciar sesión o
generar una clave, ese fichero no se publica**. Si es configuración que se puede
copiar y adaptar, sí se publica.

`.gitignore` es una red de seguridad, no una auditoría. Antes de publicar:

```sh
git status --ignored
git ls-files
grep -RInE 'token|password|secret|api[_-]?key|BEGIN .*PRIVATE' \
  --exclude-dir=.git --exclude-dir=assets .
```

Los resultados de `palette-apply.py` (`token_to_new`, `__PALETTE_*`) son
nombres de variables, no credenciales. Los comentarios de `neofetch` y Niri son
texto de documentación. El `.bak` de neofetch se elimina y queda ignorado.
