#!/usr/bin/env python3
"""
Generate `assets/data/puzzles.json` listing all JSON puzzle asset paths.
Run from repo root (or adapt paths):

python frontend/tools/generate_puzzles_index.py

This will walk `frontend/assets/data` and write `frontend/assets/data/puzzles.json`
with a JSON array of POSIX paths relative to `assets/data` (e.g. "tribune/1999/tri1999-01-01.json").
"""
import os
import json

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
ASSETS_DATA = os.path.join(ROOT, 'assets', 'data')
OUT = os.path.join(ASSETS_DATA, 'puzzles.json')

paths = []
for dirpath, dirnames, filenames in os.walk(ASSETS_DATA):
    for f in filenames:
        if not f.lower().endswith('.json'):
            continue
        # path relative to the `assets/data` folder (no leading 'assets/' or 'data/')
        rel = os.path.relpath(os.path.join(dirpath, f), ASSETS_DATA).replace('\\', '/')
        # skip the index file itself if it exists
        if rel == 'puzzles.json':
            continue
        paths.append(rel)

paths.sort()
with open(OUT, 'w', encoding='utf-8') as fh:
    json.dump(paths, fh, indent=2, ensure_ascii=False)

print(f'Wrote {len(paths)} entries to {OUT}')
