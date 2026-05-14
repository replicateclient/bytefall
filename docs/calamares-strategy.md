# Bytefall Calamares Strategy

Calamares is not in the official Arch repositories, so Bytefall must not list it in `packages.x86_64` until a trusted package source exists.

## Upstream

- Current upstream home: https://codeberg.org/Calamares/calamares
- Current documentation: https://calamares.codeberg.page/docs/documentation/
- Old GitHub mirror: https://github.com/calamares/calamares

The GitHub repository is archived and points users to Codeberg. The Calamares website says development is now on Codeberg and lists 3.4.2 as the first actually tagged Codeberg release.

## Bytefall Plan

1. Keep Bytefall's installer configuration in `calamares/`.
2. Build or import a `calamares` pacman package into `repo/x86_64`.
3. Run `scripts/make-pacman-repo.sh`.
4. Rebuild the ISO.

When `repo/x86_64/bytefall.db` exists, the ISO build script automatically enables a local `[bytefall]` pacman repo. If that repo contains a `calamares-*.pkg.tar.*` package, the build script also appends `calamares` to the ISO package list for that build.

## Short-Term Package Sources

- Preferred: package Calamares ourselves from Codeberg tags and sign it in the Bytefall repo.
- Acceptable for testing: build an AUR `calamares` package locally, inspect the PKGBUILD first, and place the resulting package in `repo/x86_64`.
- Avoid for release: shipping another distro's modified Calamares package unless we explicitly audit and document its patches.

The current AUR `calamares` recipe builds Calamares 3.4.2 from Codeberg, but skips some modules Bytefall's config expects. `scripts/build-calamares-aur-package.sh` patches that local build to keep `initramfs`, `packagechooser`, and `packagechooserq` enabled before running `makepkg`.

Bytefall also ships `archinstall` as an immediate official fallback installer. Until Calamares is packaged into `repo/x86_64`, `Install Bytefall` opens `archinstall` in Konsole.

## Current UX

The live ISO ships `bytefall-installer` and `Bytefall Welcome`. If Calamares is missing, the installer launcher now fails clearly instead of pretending installation can continue.
