#!/usr/bin/env python3
"""Generate a compact puzzles metadata index for web builds.

Writes frontend/assets/data/puzzles_index.json with entries containing:
  id, title, subtitle, path, origin, year, difficulty, difficulty_label

Usage: python frontend/tools/generate_puzzles_metadata_index.py
"""
from pathlib import Path
import json
import sys

# Add tools directory to path for difficulty_calculator import
TOOLS_DIR = Path(__file__).resolve().parents[2] / 'tools'
sys.path.insert(0, str(TOOLS_DIR))
from difficulty_calculator import DifficultyCalculator, PuzzleDifficulty

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets' / 'data'
INDEX_IN = ASSETS / 'puzzles.json'
INDEX_OUT = ASSETS / 'puzzles_index.json'
ORIGINS_OUT = ASSETS / 'puzzles_index_origins.json'
ORIGINS_DIR = ASSETS / 'puzzles_index_by_origin'

# Origin to language mapping
ORIGIN_LANGUAGE_MAP = {
    'atlantic': 'en',
    'latimes': 'en',
    'newsday': 'en',
    'newyorker': 'en',
    'nytimes': 'en',
    'slate': 'en',
    'universal': 'en',
    'usatoday': 'en',
    'wsj': 'en',
    'crossynergy': 'en',
    # Future:
    # 'lemonde': 'fr',
    # 'el_pais': 'es',
}
DEFAULT_LANGUAGE = 'en'


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
    calculator = DifficultyCalculator()
    print(f'Indexing {total} puzzle paths with difficulty calculation...')
    difficulty_stats = {d.value: 0 for d in PuzzleDifficulty}
    for i, path in enumerate(paths, 1):
        # paths in puzzles.json are relative to assets/data
        pfile = ASSETS / Path(path)
        token = token_from_path(path)
        origin = 'unknown'
        year = ''
        parts = Path(path).parts
        # expected structure: <origin>/<year>/file.json
        if len(parts) >= 1:
            origin = parts[0]
        if len(parts) >= 2:
            year = parts[1]
        title = token
        subtitle = ''
        difficulty = 2  # Default: medium
        difficulty_label = 'Medium'
        language = ORIGIN_LANGUAGE_MAP.get(origin, DEFAULT_LANGUAGE)
        if pfile.exists():
            try:
                # Handle UTF-8 BOM files
                content = pfile.read_text(encoding='utf-8-sig')
                j = json.loads(content)
                title = title_from_json(j, fallback=token)
                subtitle = str(j.get('subtitle') or '')
                # Calculate difficulty
                result = calculator.calculate_from_puzzle(j)
                difficulty = result.level
                difficulty_label = result.label
                difficulty_stats[difficulty] += 1
                # Get language from metadata if present, else use origin mapping
                metadata = j.get('metadata', {})
                if isinstance(metadata, dict) and metadata.get('language'):
                    language = metadata['language']
            except Exception as e:
                if i <= 5:  # Only log first few errors
                    print(f'  Warning: {path}: {e}')
        out.append({
            'id': token,
            'title': title,
            'subtitle': subtitle,
            'path': path,
            'origin': origin,
            'year': year,
            'difficulty': difficulty,
            'difficulty_label': difficulty_label,
            'language': language,
        })
        if i % 1000 == 0:
            print(f'  processed {i}/{total}')

    # Collect all unique origins for the index wrapper
    all_origins = sorted({e['origin'] for e in out})

    # Write as object with items and origins
    index_wrapper = {
        'items': out,
        'origins': all_origins,
    }
    INDEX_OUT.write_text(json.dumps(index_wrapper, ensure_ascii=False, indent=2), encoding='utf-8')
    print('Wrote', INDEX_OUT)
    print(f'Difficulty distribution:')
    for level, count in sorted(difficulty_stats.items()):
        label = PuzzleDifficulty(level).label
        pct = count / total * 100 if total > 0 else 0
        print(f'  {label} ({level}): {count} ({pct:.1f}%)')

    # Group by origin and write per-origin indexes
    ORIGINS_DIR.mkdir(parents=True, exist_ok=True)
    origins = {}
    for e in out:
        origins.setdefault(e['origin'], []).append(e)

    summary = []
    for origin, items in origins.items():
        # Calculate difficulty distribution per origin
        origin_diff = {d.value: 0 for d in PuzzleDifficulty}
        for item in items:
            origin_diff[item['difficulty']] += 1
        # write file name safe origin
        fname = ORIGINS_DIR / f"{origin}.json"
        fname.write_text(json.dumps(items, ensure_ascii=False, indent=2), encoding='utf-8')
        summary.append({
            'origin': origin,
            'count': len(items),
            'difficulty_distribution': origin_diff,
        })
    ORIGINS_OUT.write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding='utf-8')
    print('Wrote', ORIGINS_OUT, 'and per-origin indexes under', ORIGINS_DIR)


if __name__ == '__main__':
    main()
