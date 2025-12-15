import json
from pathlib import Path

root = Path('.').resolve()
index_path = root / 'frontend' / 'assets' / 'data' / 'puzzles_index.json'
build_assets_root = root / 'frontend' / 'build' / 'web' / 'assets' / 'assets' / 'data'

with index_path.open('r', encoding='utf-8') as f:
    data = json.load(f)

missing = []
checked = 0
for item in data:
    checked += 1
    p = item.get('path')
    if not p:
        missing.append((p, 'no-path'))
        continue
    target = build_assets_root / p
    if not target.exists():
        missing.append((p, str(target)))

print(f"Checked {checked} index entries.")
print(f"Missing: {len(missing)}")
if missing:
    print("First 20 missing:")
    for p, t in missing[:20]:
        print(p, '->', t)
else:
    print('All indexed paths are present in the build assets.')

# exit code: 0 if none missing, 2 if missing
import sys
sys.exit(0 if not missing else 2)
