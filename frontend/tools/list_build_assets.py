from pathlib import Path
p=Path('frontend/build/web/assets/assets/data')
if not p.exists():
    print('build assets data dir missing')
    raise SystemExit(2)
print('entries under build/web/assets/assets/data:')
for i,child in enumerate(sorted(p.iterdir())):
    print(' ', child.name, '(dir)' if child.is_dir() else '')
