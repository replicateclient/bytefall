# Release Guide

This page explains how to turn a working Bytefall tree into a release candidate.

## Release Identity

Current line:

- `Bytefall 0.1 Aurora`

Main release output:

- ISO
- `SHA256SUMS`
- release notes
- known issues

## Release Workflow

### 1. Validate the tree

```bash
./scripts/validate-bytefall-tree.sh
```

### 2. Produce a release-style ISO

```bash
sudo ./scripts/build-bytefall-iso.sh --clean
```

Use a clean build for release candidates unless you are debugging the build system itself.

### 3. Run VM QA

At minimum:

- BIOS boot
- UEFI boot
- live desktop reaches Plasma
- installer opens
- install completes
- installed system boots
- network works in live and installed sessions

### 4. Run visual QA

Check:

- wallpapers
- splash screens
- window decoration
- Plasma theme
- icons
- shell branding
- installer branding

### 5. Publish artifacts

Upload:

- ISO
- `SHA256SUMS`
- release notes
- known issues

## Files Involved In A Release

- `archiso/bytefall/profiledef.sh`
- `scripts/build-bytefall-iso.sh`
- `docs/release-checklist.md`
- `out/`

## Version Naming

Bytefall uses a numbered line plus a codename.

Example:

- `Bytefall 0.1 Aurora`

The ISO filename still uses the numeric line and date:

```text
bytefall-0.1-YYYY.MM.DD-x86_64.iso
```

## Common Release Mistakes

- shipping from a dirty build root without checking the staged image
- forgetting to verify the installer after UI or theme work
- updating live-session assets without testing an installed user
- assuming a VM network failure is always just the VM

## Final Rule

If the ISO boots but the install path is broken, the release is not done.
