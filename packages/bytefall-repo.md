# Bytefall Repository Strategy

Phase 1 keeps custom Bytefall files in this Git repository and copies them into the ISO.

Phase 2 should create pacman packages:

- `bytefall-branding`
- `bytefall-calamares-config`
- `calamares`
- `bytefall-kde-settings`
- `bytefall-kvantum-theme`
- `bytefall-plymouth-theme`
- `bytefall-grub-theme`
- `bytefall-welcome`

For local development builds, place packages in `repo/x86_64` and run:

```bash
./scripts/make-pacman-repo.sh
```

The ISO build script detects `repo/x86_64/bytefall.db` and enables it as `[bytefall]`.

When package signing is ready, enable this block in `archiso/bytefall/pacman.conf`:

```ini
[bytefall]
SigLevel = Required DatabaseOptional
Server = https://repo.bytefall.dev/$arch
```
