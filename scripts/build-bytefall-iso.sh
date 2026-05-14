#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
profile_src="$repo_root/archiso/bytefall"
work_root="$repo_root/build"
profile_work="$work_root/work-profile"
mkarchiso_work="$work_root/mkarchiso-work"
state_dir="$work_root/state"
out_dir="$repo_root/out"
min_iso_bytes=$((3 * 1024 * 1024 * 1024))
clean_build=0

cleanup_stale_mounts() {
  local root="$mkarchiso_work/x86_64/airootfs"
  local mounts=()
  local target

  [[ -d "$root" ]] || return 0

  mapfile -t mounts < <(findmnt -Rrn -o TARGET "$root" 2>/dev/null | sort -r)
  if (( ${#mounts[@]} == 0 )) && [[ -r /proc/1/mountinfo ]]; then
    mapfile -t mounts < <(awk -v root="$root" '$5 ~ ("^" root "(/.*)?$") { print $5 }' /proc/1/mountinfo | sort -r)
  fi
  if (( ${#mounts[@]} == 0 )); then
    for target in \
      "$root/tmp" \
      "$root/run" \
      "$root/dev/shm" \
      "$root/dev/pts" \
      "$root/dev" \
      "$root/proc" \
      "$root/sys"; do
      if [[ -e "$target" ]] && mountpoint -q "$target" 2>/dev/null; then
        mounts+=("$target")
      fi
    done
  fi
  if (( ${#mounts[@]} == 0 )); then
    return 0
  fi

  echo "Cleaning stale mountpoints in $root."
  for target in "${mounts[@]}"; do
    umount "$target" 2>/dev/null || umount -l "$target" 2>/dev/null || true
  done

  mapfile -t mounts < <(findmnt -Rrn -o TARGET "$root" 2>/dev/null | sort -r)
  if (( ${#mounts[@]} == 0 )) && [[ -r /proc/1/mountinfo ]]; then
    mapfile -t mounts < <(awk -v root="$root" '$5 ~ ("^" root "(/.*)?$") { print $5 }' /proc/1/mountinfo | sort -r)
  fi
  if (( ${#mounts[@]} != 0 )); then
    echo "Failed to unmount stale mountpoints in $root:" >&2
    printf '  %s\n' "${mounts[@]}" >&2
    return 1
  fi
}

usage() {
  cat <<'EOF'
Usage: scripts/build-bytefall-iso.sh [--incremental|--clean]

  --incremental  Reuse the existing mkarchiso work tree and refresh Bytefall overlays.
  --clean        Remove the mkarchiso work tree first for a full release-style rebuild.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --incremental)
      clean_build=0
      ;;
    --clean|--fresh)
      clean_build=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! command -v mkarchiso >/dev/null 2>&1; then
  echo "mkarchiso not found. Install build dependencies with scripts/install-build-deps.sh on Arch Linux." >&2
  exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
  echo "mkarchiso must run as root. Re-run with sudo." >&2
  exit 1
fi

cleanup_stale_mounts

if (( clean_build )); then
  echo "Clean build requested; removing $mkarchiso_work."
  rm -rf "$mkarchiso_work" "$state_dir"
else
  echo "Incremental build enabled; reusing $mkarchiso_work when possible."
fi

rm -rf "$profile_work"
mkdir -p "$work_root" "$out_dir"
find "$out_dir" -maxdepth 1 -type f \( -name 'bytefall-*.iso' -o -name 'SHA256SUMS' \) -delete
cp -a "$profile_src" "$profile_work"

for boot_dir in syslinux efiboot grub; do
  if [[ ! -e "$profile_work/$boot_dir" && -e "/usr/share/archiso/configs/releng/$boot_dir" ]]; then
    cp -a "/usr/share/archiso/configs/releng/$boot_dir" "$profile_work/$boot_dir"
  fi
done

if [[ -e "$repo_root/repo/x86_64/bytefall.db" || -e "$repo_root/repo/x86_64/bytefall.db.tar.gz" ]]; then
  cat >>"$profile_work/pacman.conf" <<EOF

[bytefall]
SigLevel = Optional TrustAll
Server = file://$repo_root/repo/\$arch
EOF
  if find "$repo_root/repo/x86_64" -maxdepth 1 -type f -name 'calamares-*.pkg.tar.*' | grep -q .; then
    if ! grep -qx 'calamares' "$profile_work/packages.x86_64"; then
      printf '\n# Bytefall local repo packages\ncalamares\n' >>"$profile_work/packages.x86_64"
    fi
  fi
fi

find "$profile_work"/syslinux "$profile_work"/efiboot "$profile_work"/grub -type f -print0 2>/dev/null |
  xargs -0 sed -i \
    -e 's/vmlinuz-linux/vmlinuz-linux-zen/g' \
    -e 's/initramfs-linux\.img/initramfs-linux-zen.img/g' \
    -e 's/Arch Linux install medium/Bytefall live medium/g' \
    -e 's/Arch Linux live medium/Bytefall live medium/g' \
    -e 's/install Arch Linux/install Bytefall/g' \
    -e 's/Install Arch Linux/Install Bytefall/g' \
    -e 's/Install Arch Linux/Start Bytefall/g' \
    -e 's/MENU TITLE Arch Linux/MENU TITLE Bytefall/g'

mkdir -p "$profile_work/airootfs/etc/calamares"
cp -a "$repo_root/calamares/." "$profile_work/airootfs/etc/calamares/"

mkdir -p "$profile_work/airootfs/usr/lib/calamares/modules"
for module_dir in "$repo_root"/calamares/modules/*; do
  if [[ -d "$module_dir" && -f "$module_dir/module.desc" ]]; then
    cp -a "$module_dir" "$profile_work/airootfs/usr/lib/calamares/modules/"
    find "$profile_work/airootfs/usr/lib/calamares/modules/$(basename "$module_dir")" \
      -name '__pycache__' -type d -prune -exec rm -rf {} +
    find "$profile_work/airootfs/usr/lib/calamares/modules/$(basename "$module_dir")" \
      -name '*.pyc' -type f -delete
  fi
done

mkdir -p "$profile_work/airootfs/etc/skel"
cp -a "$repo_root/configs/skel/." "$profile_work/airootfs/etc/skel/"

mkdir -p "$profile_work/airootfs/usr/share/bytefall"
cp -a "$repo_root/branding/." "$profile_work/airootfs/usr/share/bytefall/branding/"

mkdir -p "$profile_work/airootfs/usr/share/icons/hicolor/scalable/apps"
if [[ -e "$repo_root/branding/logo/bytefall-icon.svg" ]]; then
  cp "$repo_root/branding/logo/bytefall-icon.svg" "$profile_work/airootfs/usr/share/icons/hicolor/scalable/apps/bytefall.svg"
elif [[ -e "$repo_root/bytefall.svg" ]]; then
  cp "$repo_root/bytefall.svg" "$profile_work/airootfs/usr/share/icons/hicolor/scalable/apps/bytefall.svg"
fi

if [[ -d "$repo_root/branding/wallpapers" ]]; then
  mkdir -p "$profile_work/airootfs/usr/share/wallpapers"
  cp -a "$repo_root/branding/wallpapers/." "$profile_work/airootfs/usr/share/wallpapers/"
fi

mkdir -p "$profile_work/airootfs/usr/share/bytefall/welcome"
cp "$repo_root/apps/bytefall-welcome/Main.qml" "$profile_work/airootfs/usr/share/bytefall/welcome/Main.qml"
mkdir -p "$profile_work/airootfs/usr/src/bytefall-welcome"
cp "$repo_root/apps/bytefall-welcome/main.cpp" "$profile_work/airootfs/usr/src/bytefall-welcome/main.cpp"
mkdir -p "$profile_work/airootfs/usr/share/applications"
cp "$repo_root/apps/bytefall-welcome/bytefall-welcome.desktop" "$profile_work/airootfs/usr/share/applications/bytefall-welcome.desktop"

mkdir -p "$profile_work/airootfs/etc"
cp "$repo_root/configs/system/issue" "$profile_work/airootfs/etc/issue"
cp "$repo_root/configs/system/motd" "$profile_work/airootfs/etc/motd"
cp "$repo_root/configs/system/os-release" "$profile_work/airootfs/etc/os-release"
cp "$repo_root/configs/system/pacman.conf" "$profile_work/airootfs/etc/pacman.conf"

mkdir -p "$profile_work/airootfs/etc/profile.d"
cp -a "$repo_root/configs/system/profile.d/." "$profile_work/airootfs/etc/profile.d/"

mkdir -p "$profile_work/airootfs/etc/default"
cp "$repo_root/configs/system/default/grub" "$profile_work/airootfs/etc/default/grub"

mkdir -p "$profile_work/airootfs/etc/pacman.d/hooks"
cp -a "$repo_root/configs/system/pacman.d/hooks/." "$profile_work/airootfs/etc/pacman.d/hooks/"

mkdir -p "$profile_work/airootfs/usr/share/plymouth/themes/bytefall"
cp -a "$repo_root/branding/plymouth/." "$profile_work/airootfs/usr/share/plymouth/themes/bytefall/"

mkdir -p "$profile_work/airootfs/usr/share/grub/themes/bytefall"
cp -a "$repo_root/branding/grub/." "$profile_work/airootfs/usr/share/grub/themes/bytefall/"
if [[ -e "$repo_root/branding/boot/splash.png" ]]; then
  cp "$repo_root/branding/boot/splash.png" "$profile_work/airootfs/usr/share/grub/themes/bytefall/background.png"
fi

if [[ -d "$repo_root/branding/plasma/look-and-feel" ]]; then
  mkdir -p "$profile_work/airootfs/usr/share/plasma/look-and-feel"
  cp -a "$repo_root/branding/plasma/look-and-feel/." "$profile_work/airootfs/usr/share/plasma/look-and-feel/"
fi

if [[ -d "$repo_root/branding/plasma/aurorae/themes" ]]; then
  mkdir -p "$profile_work/airootfs/usr/share/aurorae/themes"
  cp -a "$repo_root/branding/plasma/aurorae/themes/." "$profile_work/airootfs/usr/share/aurorae/themes/"
fi

if [[ -e "$repo_root/branding/boot/splash.png" ]]; then
  cp "$repo_root/branding/boot/splash.png" "$profile_work/syslinux/splash.png"
fi

find "$profile_work/airootfs" -type d -exec chmod 755 {} +
find "$profile_work/airootfs" -type f -exec chmod 644 {} +
chmod 750 "$profile_work/airootfs/etc/sudoers.d"
chmod 750 "$profile_work/airootfs/etc/polkit-1/rules.d"
chmod 755 "$profile_work/airootfs/root/customize_airootfs.sh"
chmod 755 "$profile_work/airootfs/usr/local/bin/bytefall-calamares-root"
chmod 755 "$profile_work/airootfs/usr/local/bin/bytefall-installer"
chmod 755 "$profile_work/airootfs/usr/local/bin/bytefall-plasma-setup"
chmod 440 "$profile_work/airootfs/etc/sudoers.d/10-bytefall-live"

hash_existing_paths() {
  local paths=()
  local path

  for path in "$@"; do
    [[ -e "$path" ]] && paths+=("$path")
  done

  if (( ${#paths[@]} == 0 )); then
    echo "none"
    return
  fi

  find "${paths[@]}" -type f -print0 |
    sort -z |
    xargs -0 sha256sum |
    sha256sum |
    awk '{print $1}'
}

root_has_critical_packages() {
  local pacstrap_dir="$mkarchiso_work/x86_64/airootfs"

  [[ -x "$pacstrap_dir/usr/bin/calamares" ]] || return 1
  [[ -d "$pacstrap_dir/usr/share/plasma/look-and-feel" ]] || return 1
  [[ -x "$pacstrap_dir/usr/bin/plasmashell" ]] || return 1
  return 0
}

drop_run_once_marker() {
  rm -f "$mkarchiso_work/$1"
}

invalidate_overlay_build() {
  drop_run_once_marker base._make_custom_airootfs
  drop_run_once_marker base._make_customize_airootfs
  drop_run_once_marker base._make_pkglist
  drop_run_once_marker base._make_version
  drop_run_once_marker base._cleanup_pacstrap_dir
  drop_run_once_marker base._prepare_airootfs_image
  drop_run_once_marker base._mkairootfs_squashfs
  drop_run_once_marker build._build_buildmode_iso
  drop_run_once_marker iso._build_iso_image
}

invalidate_package_build() {
  drop_run_once_marker base._make_pacman_conf
  drop_run_once_marker base._make_packages
  drop_run_once_marker base._check_if_initramfs_has_ucode
  drop_run_once_marker base._make_boot_on_iso9660
  drop_run_once_marker base._make_bootmode_bios.syslinux
  drop_run_once_marker base._make_bootmode_uefi.systemd-boot
  drop_run_once_marker base._make_boot_on_fat
  drop_run_once_marker base._make_common_grubenv_and_loopbackcfg
  invalidate_overlay_build
}

sync_incremental_overlay() {
  local pacstrap_dir="$mkarchiso_work/x86_64/airootfs"
  local src dst

  [[ -d "$pacstrap_dir" ]] || return 0

  for rel in \
    etc/calamares \
    etc/NetworkManager \
    etc/skel \
    usr/share/bytefall \
    usr/share/wallpapers \
    usr/share/plasma/look-and-feel \
    usr/share/aurorae/themes \
    usr/share/plymouth/themes/bytefall \
    usr/share/grub/themes/bytefall; do
    src="$profile_work/airootfs/$rel"
    dst="$pacstrap_dir/$rel"
    if [[ -d "$src" ]]; then
      mkdir -p "$(dirname "$dst")"
      rsync -a --delete "$src/" "$dst/"
    fi
  done

  rsync -a "$profile_work/airootfs/." "$pacstrap_dir/"
}

mkdir -p "$state_dir"
package_hash="$(hash_existing_paths \
  "$profile_work/packages.x86_64" \
  "$profile_work/pacman.conf" \
  "$repo_root/repo/x86_64")"
boot_hash="$(hash_existing_paths \
  "$profile_work/profiledef.sh" \
  "$profile_work/airootfs/etc/mkinitcpio.conf.d" \
  "$profile_work/airootfs/etc/mkinitcpio.d" \
  "$profile_work/syslinux" \
  "$profile_work/efiboot" \
  "$profile_work/grub")"

if (( ! clean_build )) && [[ -d "$mkarchiso_work/x86_64/airootfs" ]]; then
  if ! root_has_critical_packages; then
    echo "Persistent build root is missing critical packages; forcing package refresh."
    invalidate_package_build
  elif [[ -e "$state_dir/package.sha256" ]] && [[ "$(cat "$state_dir/package.sha256")" != "$package_hash" ]]; then
    echo "Package inputs changed; pacstrap will refresh the persistent build root."
    invalidate_package_build
  elif [[ -e "$state_dir/boot.sha256" ]] && [[ "$(cat "$state_dir/boot.sha256")" != "$boot_hash" ]]; then
    echo "Boot/profile inputs changed; boot artifacts will be refreshed."
    invalidate_package_build
  else
    invalidate_overlay_build
  fi

  sync_incremental_overlay
fi

mkarchiso -v -w "$mkarchiso_work" -o "$out_dir" "$profile_work"

hook_root="$mkarchiso_work/x86_64/airootfs/usr/lib/initcpio"
required_hooks=(
  archiso
  archiso_loop_mnt
  archiso_pxe_common
  archiso_pxe_nbd
  archiso_pxe_http
  archiso_pxe_nfs
)

for hook in "${required_hooks[@]}"; do
  if [[ ! -e "$hook_root/hooks/$hook" || ! -e "$hook_root/install/$hook" ]]; then
    echo "Live ISO initramfs hook '$hook' is missing from $hook_root." >&2
    echo "Install/add mkinitcpio-archiso before trusting this ISO." >&2
    exit 1
  fi
done

printf '%s\n' "$package_hash" > "$state_dir/package.sha256"
printf '%s\n' "$boot_hash" > "$state_dir/boot.sha256"

iso_path="$(find "$out_dir" -maxdepth 1 -type f -name 'bytefall-*.iso' -printf '%T@ %p\n' | sort -nr | awk 'NR == 1 {print $2}')"
if [[ -z "${iso_path:-}" ]]; then
  echo "mkarchiso finished but no Bytefall ISO was found in $out_dir." >&2
  exit 1
fi

iso_size="$(stat -c '%s' "$iso_path")"
if (( iso_size < min_iso_bytes )); then
  echo "ISO is smaller than 3 GiB: $iso_size bytes." >&2
  echo "Add packages/assets intentionally; do not pad the ISO with junk data for release." >&2
  exit 1
fi

(
  cd "$out_dir"
  sha256sum "$(basename "$iso_path")" > SHA256SUMS
)

echo "Built $iso_path"
echo "Wrote $out_dir/SHA256SUMS"
