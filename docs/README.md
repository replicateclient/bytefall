# Bytefall Documentation

This folder is the handbook for Bytefall builders, maintainers, and contributors.

It is written as a small distro manual, not as scattered notes.

## Documentation Layout

The docs are grouped by job.

### 1. Project overview

These pages explain what Bytefall is and how the repository is organized.

- [architecture.md](architecture.md)
- [repository-layout.md](repository-layout.md)

### 2. Build and install work

These pages explain how to build the ISO, how the installer works, and how the non-Calamares install path works.

- [building-bytefall.md](building-bytefall.md)
- [installer-and-profiles.md](installer-and-profiles.md)
- [iso-build-host.md](iso-build-host.md)

### 3. Visual system

These pages explain themes, branding, and the default desktop identity.

- [theming-and-branding.md](theming-and-branding.md)
- [package-policy.md](package-policy.md)

### 4. Release and packaging

These pages explain release work, Calamares packaging, GitHub publishing, and QA.

- [release-guide.md](release-guide.md)
- [release-checklist.md](release-checklist.md)
- [calamares-strategy.md](calamares-strategy.md)
- [github-publishing.md](github-publishing.md)

## Recommended Reading Order

If you are new to Bytefall:

1. Read [architecture.md](architecture.md)
2. Read [repository-layout.md](repository-layout.md)
3. Read [building-bytefall.md](building-bytefall.md)
4. Read [installer-and-profiles.md](installer-and-profiles.md)
5. Read [theming-and-branding.md](theming-and-branding.md)

If you are preparing a release:

1. Read [release-guide.md](release-guide.md)
2. Complete [release-checklist.md](release-checklist.md)

## Page Design Rules

Each page should answer four things:

1. What this part of Bytefall is for
2. Which files own it
3. How it behaves today
4. How to verify it after a change

That keeps the docs useful during real work instead of turning into decoration.
