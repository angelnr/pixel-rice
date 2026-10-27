# Secretos y datos que no deben publicarse

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
