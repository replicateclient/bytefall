# Bytefall Repository Layout

This page explains what each top-level directory owns.

## Top-Level Tree

```text
apps/
archiso/
branding/
calamares/
configs/
docs/
packages/
repo/
scripts/
```

## apps

`apps/` contains Bytefall-specific applications.

Current example:

- `apps/bytefall-welcome/`

That app controls the live-session welcome flow, GPU selection, installer launch, and startup preference behavior.

## archiso

`archiso/bytefall/` is the base ArchISO profile.

It owns:

- package list
- ISO identity
- boot modes
- live root files under `airootfs/`

This is the foundation that `mkarchiso` consumes.

## branding

`branding/` holds visual assets that are copied into the image.

Examples:

- wallpapers
- ASCII and ANSI logos
- GRUB assets
- Plymouth assets
- Plasma look-and-feel assets
- Aurorae theme files

If a thing is visual and distro-owned, it probably belongs here.

## calamares

`calamares/` is the canonical installer configuration tree.

It includes:

- `settings.conf`
- module configs
- branding files
- any custom installer-side config needed by Bytefall

The build script mirrors this into the ISO under `/etc/calamares`.

## configs

`configs/` is the configuration system for Bytefall defaults.

It is split into:

- `configs/skel/` for new-user defaults
- `configs/system/` for system-wide files

Examples:

- shell config
- KDE config
- GTK config
- OS identity files
- GRUB defaults

## docs

`docs/` is the project handbook.

It explains how Bytefall works, how to build it, how to release it, and how to reason about the repo without guessing.

## packages

`packages/` contains package profile definitions and repo notes.

Examples:

- `packages/profiles/default.txt`
- `packages/profiles/dev.txt`
- `packages/profiles/server.txt`
- `packages/bytefall-repo.md`

This is where the non-ISO install profiles live.

## repo

`repo/` is the local pacman repository output area for Bytefall packages.

If you place a `calamares` package here and update the repo database, the ISO build can automatically consume it.

## scripts

`scripts/` contains the real operational tooling.

Examples:

- ISO build scripts
- validation scripts
- repo generation scripts
- Calamares package build helpers
- base install script

If the docs describe a workflow, the implementation usually lives here.

## Generated Directories

These are important, but they are build output rather than source:

- `build/`
- `out/`
- `_tmp/`

Do not treat them as the source of truth.

## Reading The Repo In Practice

A good way to follow Bytefall ownership is:

1. start with `scripts/build-bytefall-iso.sh`
2. see which directories it copies into the ISO
3. edit those source directories, not the generated work tree
