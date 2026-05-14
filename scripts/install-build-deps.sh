#!/usr/bin/env bash
set -euo pipefail

if ! command -v pacman >/dev/null 2>&1; then
  echo "Bytefall build dependencies must be installed on Arch Linux." >&2
  exit 1
fi

sudo pacman -Syu --needed \
  archiso \
  mkinitcpio-archiso \
  git \
  grub \
  rsync \
  squashfs-tools \
  syslinux \
  xorriso \
  mtools \
  dosfstools
