#!/usr/bin/env python3
import re
import shutil
import subprocess
import sys
from pathlib import Path


def set_show_sequence(settings_text: str, modules: list[str]) -> str:
    replacement = "  - show:\n" + "".join(f"      - {m}\n" for m in modules)
    new_text, count = re.subn(
        r"  - show:\n(?:      - .+\n)+",
        replacement,
        settings_text,
        count=1,
    )
    if count != 1:
        raise RuntimeError("Could not replace show sequence in settings.conf")
    return new_text


def run_test(root: Path, modules: list[str]) -> tuple[int, str]:
    settings = root / "etc/calamares/settings.conf"
    original = settings.read_text(encoding="utf-8")
    settings.write_text(set_show_sequence(original, modules), encoding="utf-8")
    try:
        shell_cmd = (
            f"timeout 8 chroot '{root.as_posix()}' "
            "/usr/bin/env QT_QPA_PLATFORM=offscreen XDG_RUNTIME_DIR=/tmp HOME=/root "
            "/usr/bin/calamares -d >/tmp/bytefall-calamares-bisect.log 2>&1; "
            "status=$?; tail -n 80 /tmp/bytefall-calamares-bisect.log; exit $status"
        )
        if shutil.which("wsl"):
            cmd = ["wsl", "sh", "-lc", shell_cmd]
        else:
            cmd = ["sh", "-lc", shell_cmd]
        proc = subprocess.run(cmd, capture_output=True, text=True)
        return proc.returncode, proc.stdout + proc.stderr
    finally:
        settings.write_text(original, encoding="utf-8")


def main() -> int:
    if len(sys.argv) < 3:
        print("usage: bisect-calamares-start.py <root> <module-set> [<module-set>...]", file=sys.stderr)
        print("module-set format: welcome,locale or welcome", file=sys.stderr)
        return 2

    root = Path(sys.argv[1])
    if not root.exists():
        print(f"root not found: {root}", file=sys.stderr)
        return 2

    for raw in sys.argv[2:]:
        modules = [m for m in raw.split(",") if m]
        code, output = run_test(root, modules)
        print(f"=== TEST {raw} ===")
        print(f"exit={code}")
        print(output[-4000:])
        print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
