# ISO Build Host

This page is the short build-host reference.

For the full workflow, read [building-bytefall.md](D:/Bytefall/docs/building-bytefall.md).

## Supported Host Types

- Arch Linux
- Arch-based VM
- WSL2 with the `archlinux` distro

## Minimum Arch Packages

```bash
sudo pacman -Syu --needed archiso git rsync squashfs-tools xorriso mtools dosfstools
```

## Build Commands

Incremental:

```bash
sudo ./scripts/build-bytefall-iso.sh --incremental
```

Clean:

```bash
sudo ./scripts/build-bytefall-iso.sh --clean
```

## WSL Entry Point

```powershell
.\scripts\build-bytefall-iso-wsl.ps1
```

## Output

```text
out/bytefall-0.1-YYYY.MM.DD-x86_64.iso
out/SHA256SUMS
```
