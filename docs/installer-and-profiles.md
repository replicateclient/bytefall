# Installer And Profiles

This page explains how Bytefall installation works today.

## Two Install Paths

Bytefall currently has two installation paths:

1. the live graphical installer path through Calamares
2. the manual base install path through `scripts/install-bytefall-base.sh`

They serve different needs.

## Live Installer Flow

The live session starts in KDE Plasma and opens Bytefall Welcome.

Before install:

- the welcome app asks for a GPU choice
- the welcome app asks for an install profile
- the install button stays locked until the choice is set
- the installer launcher also handles the bootloader choice prompt for BIOS or UEFI context

Then Calamares opens.

## What Calamares Does

Calamares is used for:

- language and locale
- keyboard
- partitioning
- user creation
- filesystem copy
- post-install cleanup
- bootloader setup

Bytefall-specific configuration lives in:

- `calamares/settings.conf`
- `calamares/modules/`
- `calamares/branding/`

## What Calamares Does Not Do

Bytefall no longer relies on Calamares package-profile pages inside the UI because that path proved unstable in practice. Profile selection happens in Bytefall Welcome before Calamares starts.

That means:

- no package profile selection page in Calamares today
- no GPU selector inside Calamares
- GPU, profile, and bootloader choices are handled outside Calamares, before it opens

## Bootloader Behavior

Current logic:

- BIOS live session: Bytefall explains that GRUB will be used
- UEFI live session: Bytefall can offer GRUB or systemd-boot

The ISO itself supports:

- BIOS boot through syslinux
- UEFI boot through systemd-boot

## GPU Selection

The welcome app offers:

- `Auto`
- `AMD`
- `NVIDIA`
- `None`

The selection is used to decide which graphics packages are installed.

This is handled before Calamares starts so the installer stays simpler and less fragile.

## Manual Base Install Profiles

Bytefall's script-based install path still supports package profiles.

Current profiles:

- `default`
- `dev`
- `server`

The graphical installer uses those same profile names:

- `default` installs the lean Plasma workstation profile
- `dev` keeps the full development workstation package set
- `server` installs the lightweight LXQt desktop, removes Plasma workstation branding, and keeps the system focused on services

Files:

- `packages/profiles/default.txt`
- `packages/profiles/dev.txt`
- `packages/profiles/server.txt`

Run it from an Arch live environment with the target already mounted at `/mnt`:

```bash
BYTEFALL_PROFILE=default BYTEFALL_CONFIRM=install ./scripts/install-bytefall-base.sh
```

## Why The Two Systems Differ

The manual install path can safely compose package lists from plain text profiles.

The Calamares path needs a stable UI and a stable runtime, and some of the earlier profile-page experiments caused startup crashes. Bytefall now keeps the graphical path simpler on purpose.

## Installed-System Cleanup

After graphical install, Bytefall removes live-only installer pieces from the target system.

That cleanup includes:

- live-only launcher files
- live polkit rules
- Calamares package removal path
- live service cleanup
- initramfs regeneration

See:

- `calamares/modules/shellprocess.conf`

## Files To Know

- `apps/bytefall-welcome/`
- `archiso/bytefall/airootfs/usr/local/bin/bytefall-installer`
- `archiso/bytefall/airootfs/usr/local/bin/bytefall-calamares-root`
- `calamares/settings.conf`
- `calamares/modules/`
- `scripts/install-bytefall-base.sh`

## Verification

For the graphical path:

1. boot the ISO
2. confirm welcome app opens
3. confirm GPU choice is required
4. confirm installer launches
5. complete an install
6. confirm installed system boots

For the manual path:

1. mount target storage
2. run `install-bytefall-base.sh`
3. complete bootloader and user setup
4. boot the installed system
