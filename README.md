# Bytefall

Bytefall is an opinionated Arch-based KDE Plasma distribution with a dark visual identity, a live installer, and a build pipeline that is meant to be reproducible instead of magical.

Website:

- [bytefallspace.vercel.app](https://bytefallspace.vercel.app)

Current release line:

- `Bytefall 0.1 Aurora`

Core stack:

- Arch Linux
- KDE Plasma
- `linux-zen`
- `systemd`
- `NetworkManager`
- Calamares

## Read This First

If you want the public-facing project site, start here:

- [Bytefall Website](https://bytefallspace.vercel.app)

The documentation set lives in [docs/README.md](docs/README.md).

If you are trying to do one specific thing, start here:

- Build the ISO: [docs/building-bytefall.md](docs/building-bytefall.md)
- Understand the repo: [docs/repository-layout.md](docs/repository-layout.md)
- Understand install flow: [docs/installer-and-profiles.md](docs/installer-and-profiles.md)
- Understand theming and branding: [docs/theming-and-branding.md](docs/theming-and-branding.md)
- Prepare a release: [docs/release-guide.md](docs/release-guide.md)

## Repository Layout

```text
apps/                     Bytefall apps, including the welcome app
archiso/bytefall/         ArchISO profile used by mkarchiso
branding/                 Wallpapers, logos, boot assets, Plasma assets
calamares/                Installer configuration copied into the ISO
configs/                  System and user defaults
docs/                     Project documentation
packages/                 Package profiles and repo notes
repo/                     Local pacman repo output
scripts/                  Build, validation, and helper scripts
```

## Fast Build Notes

Arch host:

```bash
sudo pacman -Syu --needed archiso git rsync squashfs-tools xorriso mtools dosfstools
sudo ./scripts/build-bytefall-iso.sh --incremental
```

Windows with WSL:

```powershell
.\scripts\build-bytefall-iso-wsl.ps1
```

Output:

```text
out/bytefall-0.1-YYYY.MM.DD-x86_64.iso
out/SHA256SUMS
```

## What Bytefall Ships Today

- FairyWren Dark Plasma theme defaults
- FairyWren Dark Aurorae window decoration
- Papirus Dark icons
- Fish as the default shell
- Kitty and Konsole preinstalled
- Bytefall wallpapers and shell branding
- Custom welcome app
- Custom Plymouth and Plasma splash branding

## Build Policy

Bytefall is built to be repeatable.

- The ISO is assembled from the ArchISO profile in `archiso/bytefall/`.
- Canonical configs come from `configs/`, `branding/`, and `calamares/`.
- The build script reuses a persistent work root when it is safe, and refreshes overlays with `rsync`.
- The release ISO must be at least 3 GiB.

## Package Policy

Every default package needs a reason.

See [docs/package-policy.md](docs/package-policy.md).
