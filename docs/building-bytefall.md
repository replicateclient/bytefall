# Building Bytefall

This page explains how to produce a Bytefall ISO from source.

## What This Page Covers

- build host requirements
- Arch host builds
- WSL builds
- incremental versus clean builds
- output files
- common failure patterns

## Supported Build Environments

Bytefall is meant to build on:

- Arch Linux
- an Arch-based VM
- Arch Linux under WSL2 on Windows

The real ISO build still happens in Linux because `mkarchiso` needs Linux mount, loop, squashfs, and boot image tooling.

## Required Scripts

The main scripts are:

- `scripts/build-bytefall-iso.sh`
- `scripts/build-bytefall-iso-wsl.ps1`
- `scripts/validate-bytefall-tree.sh`
- `scripts/install-build-deps.sh`

## Arch Host Build

Install dependencies:

```bash
sudo pacman -Syu --needed archiso git rsync squashfs-tools xorriso mtools dosfstools
```

Optional helper:

```bash
./scripts/install-build-deps.sh
```

Validate the tree:

```bash
./scripts/validate-bytefall-tree.sh
```

Incremental build:

```bash
sudo ./scripts/build-bytefall-iso.sh --incremental
```

Clean build:

```bash
sudo ./scripts/build-bytefall-iso.sh --clean
```

## Windows WSL Build

Use:

```powershell
.\scripts\build-bytefall-iso-wsl.ps1
```

That path:

1. ensures the `archlinux` WSL distro exists
2. syncs the Windows repo into a Linux build tree
3. runs the normal validation and build scripts
4. syncs the finished ISO back into `out/`

## Incremental Build Behavior

Bytefall intentionally keeps a persistent `mkarchiso` work tree to reduce rebuild time.

Important behavior:

- package changes trigger a package refresh
- boot profile changes trigger boot artifact refresh
- branding and config changes are synced as overlays
- stale mount cleanup runs before a build

This is why incremental builds are usually much faster than rebuilding the world every time.

## Output

Expected output:

```text
out/bytefall-0.1-YYYY.MM.DD-x86_64.iso
out/SHA256SUMS
```

Bytefall also enforces a minimum ISO size of 3 GiB as a release guard.

## Build Inputs

The build script assembles the ISO from these sources:

- `archiso/bytefall/`
- `calamares/`
- `configs/skel/`
- `configs/system/`
- `branding/`
- `apps/bytefall-welcome/`
- `repo/x86_64/` when a local Bytefall pacman repo exists

## Build Ownership

If you need to change a build output, edit the source of truth instead of hacking the generated work tree.

Examples:

- package list: `archiso/bytefall/packages.x86_64`
- ISO boot modes and compression: `archiso/bytefall/profiledef.sh`
- installer config: `calamares/`
- live user and service customization: `archiso/bytefall/airootfs/root/customize_airootfs.sh`
- user defaults: `configs/skel/`

## Common Problems

### `mkarchiso not found`

Install `archiso` on the Arch build host.

### Huge fake file counts during squashfs

That usually means an interrupted build left pseudo-filesystems mounted in the persistent work root. Bytefall's build script now tries to clean those automatically before the next build.

### Changes not appearing in the ISO

Check whether the relevant directory is part of the incremental overlay sync in `scripts/build-bytefall-iso.sh`.

### WSL says virtualization is disabled

Enable hardware virtualization in BIOS or UEFI, reboot Windows, then retry the WSL build.

## Verification

After any build-system change:

1. run `./scripts/validate-bytefall-tree.sh`
2. produce an ISO
3. confirm `out/SHA256SUMS` exists
4. confirm the ISO boots in a VM
