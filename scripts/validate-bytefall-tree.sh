#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
profile="$repo_root/archiso/bytefall"

required=(
  "$profile/profiledef.sh"
  "$profile/packages.x86_64"
  "$profile/pacman.conf"
  "$profile/airootfs/root/customize_airootfs.sh"
  "$profile/airootfs/etc/mkinitcpio.conf.d/archiso.conf"
  "$profile/airootfs/etc/mkinitcpio.d/linux-zen.preset"
  "$repo_root/calamares/settings.conf"
  "$repo_root/apps/bytefall-welcome/main.cpp"
  "$repo_root/apps/bytefall-welcome/Main.qml"
  "$repo_root/apps/bytefall-welcome/bytefall-welcome.desktop"
  "$repo_root/configs/skel/.config/kdeglobals"
  "$repo_root/branding/ascii/bytefall.ansi"
)

for path in "${required[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "Missing required file: $path" >&2
    exit 1
  fi
done

if ! grep -q "iso_name=\"bytefall\"" "$profile/profiledef.sh"; then
  echo "profiledef.sh does not identify the ISO as bytefall." >&2
  exit 1
fi

echo "Bytefall tree validation passed."
