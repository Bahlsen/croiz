#!/usr/bin/env python3
import json
from shutil import copyfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INDEX = ROOT / 'assets' / 'data' / 'puzzles_index.json'
BACKUP = ROOT / 'assets' / 'data' / 'puzzles_index.json.bak'

print(f'Loading {INDEX}')
if not INDEX.exists():
    raise SystemExit(f'Index file not found: {INDEX}')

# backup
copyfile(INDEX, BACKUP)
print(f'Backup written to {BACKUP}')

with INDEX.open('r', encoding='utf-8-sig') as f:
    data = json.load(f)

changed = False

# Normalize items: expect list at data['items']
if 'items' in data and isinstance(data['items'], dict) and 'value' in data['items'] and isinstance(data['items']['value'], list):
    items_obj = data['items']
    data['items'] = items_obj['value']
    if 'Count' in items_obj:
        data['items_count'] = items_obj['Count']
    changed = True

# Normalize origins: expect list at data['origins']
if 'origins' in data and isinstance(data['origins'], dict) and 'value' in data['origins'] and isinstance(data['origins']['value'], list):
    origins_obj = data['origins']
    data['origins'] = origins_obj['value']
    if 'Count' in origins_obj:
        data['origins_count'] = origins_obj['Count']
    changed = True

if not changed:
    print('No changes required; index already normalized.')
else:
    # Write back with pretty formatting
    with INDEX.open('w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print('Index normalized and written.')

# Quick sanity checks
if not isinstance(data.get('items'), list):
    raise SystemExit('Sanity check failed: items is not a list')
if not isinstance(data.get('origins'), list):
    raise SystemExit('Sanity check failed: origins is not a list')

print('Sanity check passed: items and origins are lists.')
print('Done.')
