import json
from pathlib import Path

index = Path('frontend/assets/data/puzzles.json')
assets_root = Path('frontend/assets/data')

if not index.exists():
    print('Index not found:', index)
    raise SystemExit(2)

with index.open(encoding='utf-8') as f:
    entries = json.load(f)

missing = []
for e in entries:
    p = assets_root / e
    if not p.exists():
        missing.append(str(e))

print(f'Total entries: {len(entries)}')
print(f'Missing files: {len(missing)}')
if missing:
    print('Sample missing (first 20):')
    for m in missing[:20]:
        print('  ', m)

# Exit code non-zero if missing
if missing:
    raise SystemExit(1)
