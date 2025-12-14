#!/usr/bin/env python3
"""Generate a compact puzzles metadata index for web builds.

Writes frontend/assets/data/puzzles_index.json with entries containing:
  id, title, subtitle, path, origin, year

Usage: python frontend/tools/generate_puzzles_metadata_index.py
"""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets' / 'data'
INDEX_IN = ASSETS / 'puzzles.json'
INDEX_OUT = ASSETS / 'puzzles_index.json'
ORIGINS_OUT = ASSETS / 'puzzles_index_origins.json'
ORIGINS_DIR = ASSETS / 'puzzles_index_by_origin'


def token_from_path(path: str) -> str:
    file = Path(path).name
    if file.lower().endswith('.json'):
        return file[:-5]
    return file


def title_from_json(obj: dict, fallback: str) -> str:
    direct = obj.get('title')
    if isinstance(direct, str) and direct.strip():
        return direct.strip()
    metadata = obj.get('metadata')
    if isinstance(metadata, dict):
        mt = metadata.get('title')
        if isinstance(mt, str) and mt.strip():
            return mt.strip()
    meta = obj.get('meta')
    if isinstance(meta, dict):
        mt = meta.get('title')
        if isinstance(mt, str) and mt.strip():
            return mt.strip()
    return fallback


def main():
    if not INDEX_IN.exists():
        print('Missing', INDEX_IN)
        return
    raw = json.loads(INDEX_IN.read_text(encoding='utf-8'))
    paths = [p for p in raw if isinstance(p, str)]
    out = []
    total = len(paths)
    print(f'Indexing {total} puzzle paths...')
    for i, path in enumerate(paths, 1):
        pfile = ROOT / Path(path)
        token = token_from_path(path)
        origin = 'unknown'
        year = ''
        parts = Path(path).parts
        # assets/data/<origin>/<year>/file.json
        if len(parts) >= 3:
            origin = parts[2]
        if len(parts) >= 4:
            year = parts[3]
        title = token
        subtitle = ''
        if pfile.exists():
            try:
                j = json.loads(pfile.read_text(encoding='utf-8'))
                title = title_from_json(j, fallback=token)
                subtitle = str(j.get('subtitle') or '')
            except Exception:
                pass
        out.append({
            'id': token,
            'title': title,
            'subtitle': subtitle,
            'path': path,
            'origin': origin,
            'year': year,
        })
        if i % 1000 == 0:
            print(f'  processed {i}/{total}')
    INDEX_OUT.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding='utf-8')
    print('Wrote', INDEX_OUT)

    # Group by origin and write per-origin indexes
    ORIGINS_DIR.mkdir(parents=True, exist_ok=True)
    origins = {}
    for e in out:
        origins.setdefault(e['origin'], []).append(e)

    summary = []
    for origin, items in origins.items():
        # write file name safe origin
        fname = ORIGINS_DIR / f"{origin}.json"
        fname.write_text(json.dumps(items, ensure_ascii=False, indent=2), encoding='utf-8')
        summary.append({'origin': origin, 'count': len(items)})
    ORIGINS_OUT.write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding='utf-8')
    print('Wrote', ORIGINS_OUT, 'and per-origin indexes under', ORIGINS_DIR)


if __name__ == '__main__':
    main()
