#!/usr/bin/env bash
set -euo pipefail

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

sed -i 's/#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen

if id -u bytefall >/dev/null 2>&1; then
  usermod -aG wheel,network,video,audio,storage,optical -s /usr/bin/fish bytefall
else
  useradd -m -G wheel,network,video,audio,storage,optical -s /usr/bin/fish bytefall
fi
install -d -o bytefall -g bytefall -m 0750 /home/bytefall
rsync -a --delete /etc/skel/ /home/bytefall/
chown -R bytefall:bytefall /home/bytefall
chmod 0750 /home/bytefall
passwd -d bytefall

sed -i 's#^SHELL=.*#SHELL=/usr/bin/fish#' /etc/default/useradd || true
printf 'Bytefall 0.1 Aurora\n' >/etc/bytefall-release
rm -f /etc/arch-release
cat >/etc/lsb-release <<'EOF'
DISTRIB_ID=Bytefall
DISTRIB_RELEASE=0.1
DISTRIB_CODENAME=Aurora
DISTRIB_DESCRIPTION="Bytefall 0.1 Aurora"
EOF

mkdir -p /etc/neofetch
cat >/etc/neofetch/config.conf <<'EOF'
print_info() {
    info title
    info underline
    info "OS" distro
    info "Kernel" kernel
    info "Uptime" uptime
    info "Packages" packages
    info "Shell" shell
    info "DE" de
    info "WM" wm
    info "Terminal" term
    info "CPU" cpu
    info "GPU" gpu
    info "Memory" memory
    info cols
}

image_backend="ascii"
image_source="/usr/share/bytefall/branding/ascii/bytefall.txt"
ascii_colors=(6 6 7 7 6 6)
ascii_bold="on"
distro_shorthand="off"
os_arch="on"
package_managers="on"
EOF

systemctl enable NetworkManager.service
systemctl enable sddm.service
systemctl enable pacman-init.service
systemctl enable bytefall-live.service
systemctl disable systemd-networkd.service systemd-networkd.socket systemd-networkd-wait-online.service 2>/dev/null || true
systemctl disable systemd-resolved.service systemd-resolved.socket 2>/dev/null || true

if command -v plymouth-set-default-theme >/dev/null 2>&1; then
  plymouth-set-default-theme bytefall || true
fi

if [[ -f /usr/src/bytefall-welcome/main.cpp ]]; then
  moc_tool=""
  if [[ -x /usr/lib/qt6/moc ]]; then
    moc_tool=/usr/lib/qt6/moc
  else
    moc_tool="$(command -v moc6 || true)"
  fi
  if [[ -z "$moc_tool" ]]; then
    echo "Qt moc was not found; cannot build Bytefall Welcome." >&2
    exit 1
  fi
  "$moc_tool" /usr/src/bytefall-welcome/main.cpp -o /usr/src/bytefall-welcome/main.moc
  g++ -std=c++20 -O2 -pipe -fPIC /usr/src/bytefall-welcome/main.cpp -o /usr/bin/bytefall-welcome $(pkg-config --cflags --libs Qt6Gui Qt6Qml Qt6Quick)
  chmod 0755 /usr/bin/bytefall-welcome
fi

cat >/usr/src/bytefall-install-launcher.c <<'EOF'
#include <stdio.h>
#include <unistd.h>

int main(void)
{
    execl("/usr/bin/bash", "/usr/bin/bash", "/usr/local/bin/bytefall-installer", (char *) NULL);
    perror("bytefall-install-launcher");
    return 127;
}
EOF

gcc -O2 -pipe /usr/src/bytefall-install-launcher.c -o /usr/bin/bytefall-install-launcher
chmod 0755 /usr/bin/bytefall-install-launcher

chmod 0755 /usr/local/bin/bytefall-installer
chmod 0755 /usr/local/bin/bytefall-calamares-root
chmod 0755 /usr/local/bin/bytefall-plasma-setup

if [[ -x /usr/bin/calamares ]]; then
  if [[ ! -x /usr/bin/calamares.real ]]; then
    mv /usr/bin/calamares /usr/bin/calamares.real
  fi

  cat >/usr/bin/calamares <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

read_choice() {
  local file_name="$1"
  local base path

  for base in "${HOME:-}" /home/bytefall /root; do
    [[ -n "$base" ]] || continue
    path="$base/.config/bytefall/$file_name"
    if [[ -r "$path" ]]; then
      tr '[:upper:]' '[:lower:]' < "$path" | head -n 1 | tr -d '[:space:]'
      return 0
    fi
  done

  return 1
}

setup_complete() {
  local gpu profile
  gpu="$(read_choice gpu-selection.conf || true)"
  profile="$(read_choice install-profile.conf || true)"

  case "$gpu" in
    auto|amd|nvidia|none) ;;
    *) return 1 ;;
  esac

  case "$profile" in
    default|dev|server) return 0 ;;
    *) return 1 ;;
  esac
}

if [[ "${BYTEFALL_ALLOW_CALAMARES:-0}" == "1" ]]; then
  exec /usr/bin/calamares.real "$@"
fi

if setup_complete; then
  exec /usr/local/bin/bytefall-installer "$@"
fi

if command -v bytefall-welcome >/dev/null 2>&1 && [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
  exec bytefall-welcome
fi

echo "Finish Bytefall Welcome first: choose a graphics driver and install profile." >&2
exit 1
EOF
  chmod 0755 /usr/bin/calamares
fi

rm -f /usr/bin/plasma-welcome
rm -f /usr/share/applications/org.kde.plasma-welcome.desktop
rm -f /usr/lib/qt6/plugins/kf6/kded/kded_plasma_welcome.so
rm -f /etc/xdg/autostart/bytefall-installer.desktop
rm -rf /usr/bin/__pycache__ /usr/local/bin/__pycache__ /root/.cache/Bytefall\ Welcome

mkdir -p /etc/sddm.conf.d
cat >/etc/sddm.conf.d/10-bytefall.conf <<'EOF'
[Autologin]
User=bytefall
Session=plasma

[Theme]
Current=breeze
CursorTheme=breeze_cursors
Font=JetBrains Mono,10,-1,5,50,0,0,0,0,0
EOF

mkdir -p /etc/xdg/autostart
cat >/etc/xdg/autostart/bytefall-welcome.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Bytefall Welcome
Comment=Open the Bytefall live-session welcome app
Exec=bytefall-welcome
Icon=bytefall
Terminal=false
X-KDE-autostart-after=panel
OnlyShowIn=KDE;
EOF

mkdir -p /usr/share/applications
cat >/usr/share/applications/calamares.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Install Bytefall
GenericName=System Installer
Comment=Install Bytefall to disk
Exec=/usr/bin/bytefall-install-launcher
TryExec=/usr/bin/bytefall-install-launcher
Icon=bytefall
Terminal=false
Categories=Qt;System;
StartupNotify=true
EOF
