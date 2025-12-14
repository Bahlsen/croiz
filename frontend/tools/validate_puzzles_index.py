import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1] / 'assets' / 'data'

def check_file(path: Path):
    try:
        data = json.loads(path.read_text(encoding='utf-8'))
    except Exception as e:
        print(f"Skipping {path} (not valid JSON): {e}")
        return 0
    bad = 0
    if isinstance(data, list):
        # list of dicts or list of strings
        for i, item in enumerate(data):
            if isinstance(item, dict):
                p = item.get('path')
                if isinstance(p, str) and (p.startswith('assets/') or p.startswith('data/')):
                    print(f"Bad path in {path}: index {i} -> {p}")
                    bad += 1
            elif isinstance(item, str):
                s = item
                if s.startswith('assets/') or s.startswith('data/'):
                    print(f"Bad string entry in {path}: index {i} -> {s}")
                    bad += 1
    return bad

if not ROOT.exists():
    print(f"Data directory not found: {ROOT}")
    sys.exit(2)

total_bad = 0
for p in sorted(ROOT.rglob('*.json')):
    total_bad += check_file(p)

if total_bad > 0:
    print(f"Validation failed: {total_bad} bad path(s) found")
    sys.exit(1)

print("Validation OK: no assets/data prefixes found in index files")
sys.exit(0)
