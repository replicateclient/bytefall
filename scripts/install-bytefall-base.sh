#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
target="${BYTEFALL_TARGET:-/mnt}"
profile="${BYTEFALL_PROFILE:-dev}"
confirm="${BYTEFALL_CONFIRM:-}"

case "$profile" in
  default|dev|server) ;;
  *)
    echo "Unknown BYTEFALL_PROFILE=$profile. Use default, dev, or server." >&2
    exit 1
    ;;
esac

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root from an Arch live environment." >&2
  exit 1
fi

if ! mountpoint -q "$target"; then
  echo "$target is not a mountpoint. Partition, format, and mount the target system first." >&2
  exit 1
fi

if [[ "$confirm" != "install" ]]; then
  echo "Refusing to install without BYTEFALL_CONFIRM=install." >&2
  echo "Example: BYTEFALL_PROFILE=dev BYTEFALL_CONFIRM=install $0" >&2
  exit 1
fi

read_profile() {
  local file="$1"
  grep -Ev '^\s*(#|$)' "$repo_root/packages/profiles/$file.txt"
}

packages=()
case "$profile" in
  default)
    while IFS= read -r pkg; do packages+=("$pkg"); done < <(read_profile default)
    ;;
  dev)
    while IFS= read -r pkg; do packages+=("$pkg"); done < <(read_profile default)
    while IFS= read -r pkg; do packages+=("$pkg"); done < <(read_profile dev)
    ;;
  server)
    while IFS= read -r pkg; do packages+=("$pkg"); done < <(read_profile server)
    ;;
esac

pacstrap -K "$target" "${packages[@]}"
genfstab -U "$target" >> "$target/etc/fstab"

cp "$repo_root/configs/system/os-release" "$target/etc/os-release"
cp "$repo_root/configs/system/issue" "$target/etc/issue"
cp "$repo_root/configs/system/motd" "$target/etc/motd"
cp "$repo_root/configs/system/pacman.conf" "$target/etc/pacman.conf"
printf '%s\n' "$profile" > "$target/etc/bytefall-profile"

install -d "$target/etc/profile.d" "$target/etc/default" "$target/etc/pacman.d/hooks"
cp -a "$repo_root/configs/system/profile.d/." "$target/etc/profile.d/"
cp "$repo_root/configs/system/default/grub" "$target/etc/default/grub"
cp -a "$repo_root/configs/system/pacman.d/hooks/." "$target/etc/pacman.d/hooks/"

install -d "$target/etc/skel" "$target/usr/share/bytefall/branding"
cp -a "$repo_root/configs/skel/." "$target/etc/skel/"
cp -a "$repo_root/branding/." "$target/usr/share/bytefall/branding/"

install -d "$target/usr/share/plymouth/themes/bytefall" "$target/usr/share/grub/themes/bytefall"
cp -a "$repo_root/branding/plymouth/." "$target/usr/share/plymouth/themes/bytefall/"
cp -a "$repo_root/branding/grub/." "$target/usr/share/grub/themes/bytefall/"
if [[ -e "$repo_root/branding/boot/splash.png" ]]; then
  cp "$repo_root/branding/boot/splash.png" "$target/usr/share/grub/themes/bytefall/background.png"
fi

if [[ -d "$repo_root/branding/plasma/look-and-feel" ]]; then
  install -d "$target/usr/share/plasma/look-and-feel"
  cp -a "$repo_root/branding/plasma/look-and-feel/." "$target/usr/share/plasma/look-and-feel/"
fi

if [[ -d "$repo_root/branding/plasma/aurorae/themes" ]]; then
  install -d "$target/usr/share/aurorae/themes"
  cp -a "$repo_root/branding/plasma/aurorae/themes/." "$target/usr/share/aurorae/themes/"
fi

arch-chroot "$target" systemctl enable NetworkManager.service sddm.service
arch-chroot "$target" systemctl disable systemd-networkd.service systemd-networkd.socket systemd-networkd-wait-online.service 2>/dev/null || true
arch-chroot "$target" systemctl disable systemd-resolved.service systemd-resolved.socket 2>/dev/null || true
arch-chroot "$target" bash -lc 'plymouth-set-default-theme bytefall || true'
arch-chroot "$target" mkinitcpio -P

echo "Bytefall base install complete. Create users and install GRUB for your firmware mode."
