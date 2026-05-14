#!/usr/bin/env bash
set -euo pipefail

root="${1:?usage: debug-calamares-start.sh <airootfs-root>}"

echo "ROOT=$root"
echo
echo "== Custom modules =="
find "$root/usr/lib/calamares/modules/bytefallbootselect" -maxdepth 2 -type f -print || true
find "$root/usr/lib/calamares/modules/bytefalllimine" -maxdepth 2 -type f -print || true

echo
echo "== Import test =="
chroot "$root" /usr/bin/python3 - <<'PY' || true
import os
import importlib.util

mods = ["bytefallbootselect", "bytefalllimine"]
for m in mods:
    p = f"/usr/lib/calamares/modules/{m}/main.py"
    print("MODULE", m, os.path.exists(p), p)
    spec = importlib.util.spec_from_file_location(m, p)
    mod = importlib.util.module_from_spec(spec)
    try:
        spec.loader.exec_module(mod)
        print("IMPORT_OK", m)
    except Exception as e:
        print("IMPORT_FAIL", m, type(e).__name__, e)
PY

echo
echo "== Calamares startup tail =="
chroot "$root" /usr/bin/env QT_QPA_PLATFORM=offscreen XDG_RUNTIME_DIR=/tmp HOME=/root /usr/bin/calamares -d >/tmp/bytefall-calamares-start.log 2>&1 || true
tail -n 200 /tmp/bytefall-calamares-start.log
