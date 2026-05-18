# Bytefall Architecture

Bytefall is an Arch-based KDE Plasma distribution assembled from a small number of source-owned layers.

The important rule is simple:

generated build trees are disposable, source directories are authoritative.

## System Base

Bytefall starts from:

- Arch Linux
- `linux-zen`
- `systemd`
- `NetworkManager`

Primary ownership:

- `archiso/bytefall/packages.x86_64`
- `archiso/bytefall/profiledef.sh`
- `archiso/bytefall/airootfs/`

## Build System

The ISO is built through ArchISO and `mkarchiso`.

Primary ownership:

- `scripts/build-bytefall-iso.sh`
- `scripts/build-bytefall-iso-wsl.ps1`
- `scripts/validate-bytefall-tree.sh`

Key behavior:

- persistent work root for faster rebuilds
- incremental overlay sync through `rsync`
- clean rebuild option for release candidates
- zstd compression

## Desktop Layer

Bytefall uses KDE Plasma with a curated default session.

Primary ownership:

- `configs/skel/.config/`
- `archiso/bytefall/airootfs/usr/local/bin/bytefall-plasma-setup`

Key behavior:

- one bottom panel
- centered fit-content layout
- floating translucent panel behavior
- custom launcher icon
- custom splash setup

## Theme Layer

Bytefall 0.1 Aurora currently uses:

- FairyWren Dark Plasma theme
- Windows 10 Dark Aurorae window decoration
- Papirus Dark icons
- Bytefall shell and boot branding

Primary ownership:

- `branding/`
- `configs/skel/`

## Installer Layer

The graphical install path is built around Calamares, but Bytefall keeps some decisions outside Calamares for stability.

Primary ownership:

- `calamares/`
- `apps/bytefall-welcome/`
- `archiso/bytefall/airootfs/usr/local/bin/bytefall-installer`

Current flow:

1. boot live ISO
2. enter Plasma
3. choose GPU setup in Bytefall Welcome
4. choose bootloader context outside Calamares
5. run Calamares
6. perform post-install cleanup and boot prep

## Configuration Layer

Bytefall splits defaults into:

- `configs/system/` for system-wide files
- `configs/skel/` for user defaults

That separation makes it easier to reason about live behavior versus installed-user behavior.

## Package Profile Layer

There are currently two profile concepts:

1. live graphical install path, which is intentionally kept simpler
2. script-based base install path, which still supports package profiles

Script install profiles:

- `default`
- `dev`
- `server`

Primary ownership:

- `packages/profiles/`
- `scripts/install-bytefall-base.sh`

## Branding And Identity Layer

Bytefall branding is not just the wallpaper.

It includes:

- shell ASCII and ANSI logo
- fastfetch defaults
- installer branding
- GRUB branding
- Plymouth branding
- Plasma splash branding
- distro identity files such as `os-release`, `bytefall-release`, and `lsb-release`

## Release Layer

A Bytefall release is considered real only when:

- the ISO builds cleanly
- the live session works
- the installer works
- the installed system boots
- the visual identity survives the full path

Primary ownership:

- `docs/release-guide.md`
- `docs/release-checklist.md`
