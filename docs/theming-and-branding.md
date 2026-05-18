# Theming And Branding

This page explains how Bytefall's visual system is assembled.

## Goals

Bytefall should not feel like stock Arch KDE with a wallpaper dropped on top.

The visual system is supposed to be coherent across:

- Plasma
- KWin decoration
- GTK apps
- terminal
- boot splash
- login branding
- installer branding

## Current Default Theme Stack

Bytefall 0.1 Aurora currently uses:

- Plasma theme: `FairyWren-Dark`
- Color scheme: `FairyWrenDark`
- Window decoration: `Windows 10 Dark`
- Icon theme: `Papirus-Dark`
- GTK theme: `Breeze-Dark`
- Kvantum: Bytefall-owned config
- Fonts: JetBrains Mono and Iosevka where appropriate

## Ownership Map

### Plasma and KWin defaults

User defaults live in:

- `configs/skel/.config/kdeglobals`
- `configs/skel/.config/kwinrc`
- `configs/skel/.config/plasmarc`
- `configs/skel/.config/ksplashrc`

### Plasma theme and look-and-feel assets

- `configs/skel/.local/share/plasma/desktoptheme/`
- `branding/plasma/look-and-feel/`
- `branding/plasma/aurorae/themes/`

### Wallpapers

- `branding/wallpapers/BytefallAurora/`
- `branding/wallpapers/BytefallClassic/`

### Shell branding

- `branding/ascii/`
- `configs/skel/.bashrc`
- `configs/skel/.config/fish/config.fish`
- `configs/skel/.config/fastfetch/bytefall.jsonc`

### Boot branding

- `branding/grub/`
- `branding/plymouth/`
- `branding/boot/`

## Wallpaper Behavior

Bytefall ships wallpaper packages, not just loose image files.

Current packages:

- `BytefallAurora`
- `BytefallClassic`

The live desktop setup picks a random default from the Aurora set. It does not default to Plasma stock wallpaper.

## Welcome App And Icon Branding

The live session welcome app and launcher use the Bytefall icon:

- `bytefall.svg`

The shell-facing identity uses the Bytefall ASCII and ANSI assets from:

- `branding/ascii/`

## Installer Branding

Calamares branding is separate from Plasma branding.

Relevant files live under:

- `calamares/branding/`

That is where installer colors, icons, welcome assets, and slideshow assets belong.

## How To Change A Theme Safely

When changing theme defaults:

1. update the owning files in `configs/skel/` or `branding/`
2. rebuild the ISO
3. test the live session
4. test a fresh installed user

Do not patch generated config inside the build root and call it finished.

## Verification

After theming changes, check:

1. Plasma desktop theme
2. window decoration
3. icon theme
4. GTK app appearance
5. Konsole and Kitty appearance
6. fastfetch or shell branding
7. installer appearance
8. GRUB and Plymouth appearance
