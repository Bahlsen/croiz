#!/usr/bin/env python3
import os
import shutil
from pathlib import Path

repo_root = Path(__file__).resolve().parents[1]
src = repo_root / 'assets' / 'data'
dst = repo_root / 'build' / 'web' / 'assets' / 'assets' / 'data'

if not src.exists():
    print(f"Source path does not exist: {src}")
    raise SystemExit(2)

os.makedirs(dst, exist_ok=True)

copied = 0
skipped = 0
for root, dirs, files in os.walk(src):
    rel = Path(root).relative_to(src)
    target_dir = dst / rel
    target_dir.mkdir(parents=True, exist_ok=True)
    for f in files:
        s = Path(root) / f
        t = target_dir / f
        try:
            shutil.copy2(s, t)
            copied += 1
        except Exception as e:
            print(f"Failed to copy {s} -> {t}: {e}")
            skipped += 1

print(f"Copied {copied} files, skipped {skipped}.")
if skipped:
    raise SystemExit(1)
else:
    raise SystemExit(0)
