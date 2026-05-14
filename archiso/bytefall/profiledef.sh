#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="bytefall"
iso_label="BYTEFALL_0_1"
iso_publisher="Bytefall Project <https://bytefall.dev>"
iso_application="Bytefall 0.1 Aurora Live/Rescue DVD"
iso_version="0.1-$(date +%Y.%m.%d)"
install_dir="bytefall"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '6' '-b' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/usr/local/bin/bytefall-calamares-root"]="0:0:755"
  ["/usr/local/bin/bytefall-installer"]="0:0:755"
  ["/usr/local/bin/bytefall-plasma-setup"]="0:0:755"
)
