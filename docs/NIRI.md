# Instalación de Niri 26.04

El rice está probado con **Niri 26.04**. En el equipo original está instalado en
`/usr/local/bin/niri`, no en `/usr/bin`, y no depende del paquete de Debian.

## Opción 1: paquete de tu distribución

Si tu Debian/derivada ya empaqueta Niri 26.04, instálalo con APT y comprueba:

```sh
niri --version
niri validate -c ~/.config/niri/config.kdl
```

## Opción 2: compilar desde el tag oficial

Instala dependencias de compilación. En Debian 13 suelen ser:

```sh
sudo apt install build-essential cargo git pkg-config \
  libseat-dev libinput-dev libgbm-dev libdrm-dev libegl1-mesa-dev \
  libgles2-mesa-dev libxkbcommon-dev libwayland-dev wayland-protocols \
  libpango1.0-dev libsystemd-dev libpipewire-0.3-dev libdisplay-info-dev \
  libudev-dev libxcb-composite0-dev libxcb-res0-dev
```

Después:

```sh
cargo install --git https://github.com/YaLTeR/niri.git \
  --tag v26.04 --locked --root "$HOME/.local"
```

Asegúrate de que `~/.local/bin` está en `PATH` y de que el lanzador de sesión
apunta al binario correcto. Si usas SDDM, crea/edita la sesión de Wayland para
que ejecute `niri-session` o el comando que corresponda a tu instalación.

## xwayland-satellite

Steam y Discord son Flatpaks X11. El rice usa `xwayland-satellite` para
integrarlos en Niri:

```sh
# consulta las instrucciones actuales del proyecto
# https://github.com/Supreeeme/xwayland-satellite
```

El binario del equipo original está en `~/.local/bin/xwayland-satellite` y
`xwayland-env.sh` exporta `DISPLAY` para systemd/D-Bus. Sin este paso, Steam y
Discord pueden no arrancar o no recibir teclado.

## Comprobaciones

```sh
niri validate
niri msg workspaces
niri msg layers
```
