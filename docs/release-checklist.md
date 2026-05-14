# Bytefall Release Checklist

Release: `Bytefall 0.1 Aurora`

## Build

- [ ] Build host is Arch Linux and fully updated.
- [ ] `./scripts/validate-bytefall-tree.sh` passes.
- [ ] `./scripts/build-bytefall-iso.sh` completes.
- [ ] ISO size is at least 3 GiB.
- [ ] `out/SHA256SUMS` exists.

## VM QA

- [ ] ISO boots in UEFI mode.
- [ ] ISO boots in BIOS mode.
- [ ] Live session reaches SDDM.
- [ ] Live user can open KDE Plasma.
- [ ] NetworkManager connects to a network.
- [ ] Bytefall Welcome opens.
- [ ] GPU selection in Bytefall Welcome works.
- [ ] Installer launcher opens Calamares.
- [ ] Graphical install completes.
- [ ] Installed system boots.
- [ ] Installed user reaches KDE Plasma.

## Visual QA

- [ ] GRUB shows Bytefall theme.
- [ ] Plymouth shows Bytefall splash.
- [ ] KDE desktop theme is FairyWren Dark.
- [ ] KWin decoration is FairyWren Dark.
- [ ] KDE color scheme is FairyWren Dark.
- [ ] Konsole uses Bytefall profile.
- [ ] GTK apps do not look visually alien.
- [ ] Font defaults use JetBrains Mono or Iosevka where expected.
- [ ] Welcome app uses Bytefall branding.
- [ ] Wallpapers show only the intended Bytefall packages.

## Package QA

- [ ] No package in `packages.x86_64` lacks a reason in `docs/package-policy.md`.
- [ ] No package install conflicts appear in Calamares logs.
- [ ] No missing icon or font warnings appear in common desktop apps.
- [ ] `pacman -Qk` reports no broken package files on the installed system.

## Distribution

- [ ] ISO uploaded.
- [ ] `SHA256SUMS` uploaded.
- [ ] Release notes published.
- [ ] Known issues published.
- [ ] Download page identifies architecture and checksum.
