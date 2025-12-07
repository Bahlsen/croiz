#!/usr/bin/env python3
"""Validate conversion between .xd and generated JSON.

Usage: python tools/validate_xd_json.py path/to/file.xd path/to/file.json

Prints mismatches for black cells, letters, and entries.
"""
import json
import re
import sys
from pathlib import Path


def read_xd_grid(text):
    lines = text.replace('\r\n','\n').splitlines()
    # find first contiguous block of lines that look like grid rows
    grid_lines = []
    in_grid = False
    for i, L in enumerate(lines):
        s = L.rstrip()
        if not s:
            if in_grid:
                break
            continue
        if re.match(r'^[A-Z#\. _0-9]+$', s):
            # to avoid matching clue lines like "A1. ..." we require there's at least one # or letter
            if re.search(r'[A-Z#]', s):
                grid_lines.append(s)
                in_grid = True
                continue
        if in_grid:
            break
    return grid_lines


def build_grid_map(grid_lines):
    rows = len(grid_lines)
    cols = max((len(r) for r in grid_lines), default=0)
    grid = [['#' for _ in range(cols)] for _ in range(rows)]
    for y, row in enumerate(grid_lines):
        for x in range(cols):
            ch = row[x] if x < len(row) else '#'
            grid[y][x] = ch
    return grid


def compute_numbering(grid):
    rows = len(grid)
    cols = len(grid[0]) if rows else 0
    number_map = {}
    current = 1
    for y in range(rows):
        for x in range(cols):
            if grid[y][x] == '#':
                continue
            left_black = (x == 0) or (grid[y][x-1] == '#')
            right_open = (x < cols-1) and (grid[y][x+1] != '#')
            up_black = (y == 0) or (grid[y-1][x] == '#')
            down_open = (y < rows-1) and (grid[y+1][x] != '#')
            if (left_black and right_open) or (up_black and down_open):
                number_map[f"{y},{x}"] = current
                current += 1
    return number_map


def main():
    if len(sys.argv) < 3:
        print('Usage: validate_xd_json.py file.xd file.json')
        sys.exit(2)

    xd_path = Path(sys.argv[1])
    json_path = Path(sys.argv[2])
    xd_text = xd_path.read_text(encoding='utf-8')
    json_data = json.loads(json_path.read_text(encoding='utf-8'))

    grid_lines = read_xd_grid(xd_text)
    if not grid_lines:
        print('Could not locate grid in .xd file')
        sys.exit(2)

    grid = build_grid_map(grid_lines)
    rows = len(grid)
    cols = len(grid[0]) if rows else 0

    print(f'Parsed grid: {rows} rows x {cols} cols from .xd')

    # build map of json cells by coords
    json_cells = {(c['y'], c['x']): c for c in json_data.get('cells', [])}

    diffs = []
    # compare per-cell
    for y in range(rows):
        for x in range(cols):
            ch = grid[y][x]
            is_black = (ch == '#')
            jc = json_cells.get((y, x))
            if jc is None:
                diffs.append(f'Missing JSON cell at {x},{y}')
                continue
            if jc.get('is_black') != is_black:
                diffs.append(f'is_black mismatch at {x},{y}: xd={is_black} json={jc.get("is_black")}')
            # compare solution letters (if not black)
            if not is_black:
                xd_letter = ch
                json_sol = jc.get('solution')
                # allow None vs '' mismatch
                if json_sol is None:
                    json_letter = None
                else:
                    json_letter = str(json_sol)
                if json_letter is None:
                    diffs.append(f'JSON has no solution at {x},{y} (xd="{xd_letter}")')
                else:
                    if json_letter.upper() != xd_letter.upper():
                        diffs.append(f'Letter mismatch at {x},{y}: xd="{xd_letter}" json="{json_letter}"')

    # compute numbering from xd and compare with entries numbers
    number_map = compute_numbering(grid)

    entries = json_data.get('entries', [])
    entry_errors = []
    for e in entries:
        x = e['x']
        y = e['y']
        length = e['length']
        dir = e['direction']
        num = e['number']
        # reconstruct answer from grid
        chars = []
        if dir == 'across':
            for ix in range(x, x+length):
                if ix >= cols:
                    chars.append('?')
                else:
                    chars.append(grid[y][ix])
        else:
            for iy in range(y, y+length):
                if iy >= rows:
                    chars.append('?')
                else:
                    chars.append(grid[iy][x])
        recon = ''.join([c if c != '#' else '?' for c in chars])
        json_answer = e.get('answer') or ''
        if recon.replace('?', '') != json_answer.replace('?', ''):
            entry_errors.append(f"Entry {e.get('id')} at {x},{y} {dir} length={length}: json answer='{json_answer}' vs xd='{recon}'")
        # check numbering
        expected_num = number_map.get(f"{y},{x}")
        if expected_num != num:
            entry_errors.append(f"Number mismatch for entry {e.get('id')} at {x},{y}: json={num} expected={expected_num}")

    # check clues presence
    clues = json_data.get('clues', {})
    across_clues = { (c.get('number')):c for c in clues.get('across', []) }
    down_clues = { (c.get('number')):c for c in clues.get('down', []) }
    clue_errors = []
    for e in entries:
        num = e['number']
        if e['direction'] == 'across':
            if num not in across_clues:
                clue_errors.append(f'Missing across clue for number {num} (entry {e.get("id")})')
        else:
            if num not in down_clues:
                clue_errors.append(f'Missing down clue for number {num} (entry {e.get("id")})')

    # report
    print('\nSummary:')
    if not diffs and not entry_errors and not clue_errors:
        print('No mismatches detected — conversion looks consistent.')
        sys.exit(0)
    if diffs:
        print('\nCell mismatches:')
        for d in diffs:
            print('-', d)
    if entry_errors:
        print('\nEntry mismatches:')
        for d in entry_errors:
            print('-', d)
    if clue_errors:
        print('\nClue mismatches:')
        for d in clue_errors:
            print('-', d)
    sys.exit(1)


if __name__ == '__main__':
    main()
