#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
build_root="${BYTEFALL_AUR_BUILD_ROOT:-/var/tmp/bytefall-aur}"
repo_dir="$repo_root/repo/x86_64"
pkgbase="calamares"
aur_url="https://aur.archlinux.org/${pkgbase}.git"

if ! command -v pacman >/dev/null 2>&1; then
  echo "This helper must run on Arch Linux or an Arch-compatible build host." >&2
  exit 1
fi

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root so dependencies can be installed and the package can be copied into repo/x86_64." >&2
  exit 1
fi

pacman -Syu --needed --noconfirm \
  base-devel \
  extra-cmake-modules \
  git \
  kcoreaddons \
  kpmcore \
  libglvnd \
  libpwquality \
  ninja \
  pacman-contrib \
  qt6-declarative \
  qt6-svg \
  qt6-tools \
  qt6-translations \
  yaml-cpp

install -d -m 0755 "$build_root" "$repo_dir"

if ! id -u bytefall-build >/dev/null 2>&1; then
  useradd -m -r -s /bin/bash bytefall-build
fi

chown -R bytefall-build:bytefall-build "$build_root"

runuser -u bytefall-build -- bash <<EOF
set -euo pipefail
cd "$build_root"
if [[ -d "$pkgbase/.git" ]]; then
  git -C "$pkgbase" pull --ff-only
else
  git clone "$aur_url" "$pkgbase"
fi
cd "$pkgbase"
python - <<'PY'
from pathlib import Path

path = Path("PKGBUILD")
text = path.read_text()
for module in ("initramfs", "packagechooser", "packagechooserq"):
    text = text.replace(f"\n    {module}", "")
path.write_text(text)
PY
makepkg -s --noconfirm --needed
EOF

find "$build_root/$pkgbase" -maxdepth 1 -type f -name '*.pkg.tar.*' -exec cp -f {} "$repo_dir/" \;
"$repo_root/scripts/make-pacman-repo.sh"

echo "Calamares package copied to $repo_dir and Bytefall repo metadata refreshed."
