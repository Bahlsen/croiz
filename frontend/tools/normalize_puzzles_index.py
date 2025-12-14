import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'assets' / 'data'

if not ROOT.exists():
    print(f"Data directory not found: {ROOT}")
    raise SystemExit(1)

total_changed = 0
files_processed = 0

for path in sorted(ROOT.rglob('*.json')):
    try:
        with path.open('r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        # skip non-JSON or unreadable files
        continue

    if not isinstance(data, list):
        continue

    changed = 0
    for item in data:
        if isinstance(item, dict):
            p = item.get('path')
            if isinstance(p, str):
                newp = p.lstrip('/\\')
                if newp.startswith('assets/data/'):
                    newp = newp[len('assets/data/'):]
                elif newp.startswith('assets/'):
                    newp = newp[len('assets/'):]
                newp = newp.replace('\\', '/')
                if newp != p:
                    item['path'] = newp
                    changed += 1

    if changed > 0:
        with path.open('w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    total_changed += changed
    files_processed += 1

print(f'Processed {files_processed} JSON file(s); normalized {total_changed} path(s) under {ROOT}')
