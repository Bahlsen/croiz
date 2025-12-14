#!/usr/bin/env python3
"""
Convert a .xd file into our canonical puzzle JSON format.

Usage:
  python tools/xd_to_canonical.py tools/samples/example.xd --out tools/samples/example.json

This parser supports the v3 .xd format basics: Metadata, ## Grid, Rebus,
and ## Clues sections. It fills `cells`, `entries`, and `clues` with full
solutions (rebus expansions applied) and preserves metadata.
"""
import argparse
import json
import re
from pathlib import Path
from typing import List, Dict, Any, Optional


def parse_xd(text: str) -> Dict[str, Any]:
    # Split into explicit sections if headers used, else by triple-newline
    sections = {}

    # Normalize CRLF
    text = text.replace('\r\n', '\n')

    # Try explicit headers
    header_re = re.compile(r'^##+\s*(.+)$', re.MULTILINE)
    headers = [(m.start(), m.group(1).strip()) for m in header_re.finditer(text)]
    if headers:
        # extract ranges
        for i, (pos, name) in enumerate(headers):
            start = pos + text[pos:text.find('\n', pos)].__len__()
            end = len(text)
            if i + 1 < len(headers):
                end = headers[i + 1][0]
            body = text[start:end].strip('\n')
            sections[name.lower()] = body.strip()
    # If headers were not present or grid ended up empty, try a robust fallback
    if not sections.get('grid') or not sections.get('grid').strip():
        lines = text.splitlines()
        meta_lines = []
        i = 0
        # consume leading metadata lines (contain ':'), skip empty lines
        while i < len(lines):
            L = lines[i].strip()
            if not L:
                i += 1
                continue
            if ':' in L:
                meta_lines.append(L)
                i += 1
                continue
            if re.match(r'^[A-Z#\. _0-9]+$', L):
                break
            meta_lines.append(L)
            i += 1

        # collect grid lines
        grid_lines_block = []
        while i < len(lines):
            L = lines[i].rstrip()
            if not L:
                i += 1
                break
            if re.match(r'^[A-Z#\. _0-9]+$', L):
                grid_lines_block.append(L)
                i += 1
                continue
            break

        clues_block = '\n'.join(lines[i:]).strip()
        sections['metadata'] = '\n'.join(meta_lines).strip()
        sections['grid'] = '\n'.join(grid_lines_block).strip()
        sections['clues'] = clues_block
    else:
        # fallback: many .xd files (like NYT dumps) don't use '##' headers.
        # Heuristic: metadata are leading key:value lines; grid is a contiguous
        # block of rows containing letters and '#' characters; clues are the
        # remainder after the grid. We'll scan line-by-line to robustly split.
        lines = text.splitlines()
        meta_lines = []
        i = 0
        # consume leading metadata lines (contain ':'), skip empty lines
        while i < len(lines):
            L = lines[i].strip()
            if not L:
                i += 1
                continue
            if ':' in L:
                meta_lines.append(L)
                i += 1
                continue
            # if line looks like a grid row (letters and # and length > 1), break
            if re.match(r'^[A-Z#\. _0-9]+$', L):
                break
            # otherwise treat as metadata until we detect grid
            meta_lines.append(L)
            i += 1

        # collect grid lines: contiguous block of non-empty lines that look like grid rows
        grid_lines_block = []
        while i < len(lines):
            L = lines[i].rstrip()
            if not L:
                # stop grid on blank line
                i += 1
                break
            if re.match(r'^[A-Z#\. _0-9]+$', L):
                grid_lines_block.append(L)
                i += 1
                continue
            # encountered a line that doesn't look like grid -> stop
            break

        # remaining lines are clues/notes
        clues_block = '\n'.join(lines[i:]).strip()

        sections['metadata'] = '\n'.join(meta_lines).strip()
        sections['grid'] = '\n'.join(grid_lines_block).strip()
        sections['clues'] = clues_block

    # Parse metadata key:value pairs from sections['metadata']
    metadata = {}
    meta_text = sections.get('metadata', '')
    for line in meta_text.splitlines():
        line = line.strip()
        if not line or ':' not in line:
            continue
        k, v = line.split(':', 1)
        metadata[k.strip().lower()] = v.strip()

    # Parse Rebus header if present (e.g. Rebus: 1=HEART 2=DIAMOND)
    rebus_map: Dict[str, str] = {}
    rebus_line = None
    for k in list(metadata.keys()):
        if k.lower() == 'rebus':
            rebus_line = metadata[k]
            break
    # Support multiline Rebus: header where lines following 'Rebus:' contain '1=HEART' entries
    if rebus_line is not None and not rebus_line.strip():
        parts = []
        for line in meta_text.splitlines():
            l = line.strip()
            # match '1=HEART' (single-char key or digit keys)
            if re.match(r'^[^\s:]+=.+$', l):
                parts.append(l)
        if parts:
            rebus_line = ' '.join(parts)
    if rebus_line:
        # Accept multiple separators: newlines, spaces, or commas. Keys must be single characters.
        for part in re.split(r'[\s,]+', rebus_line.strip()):
            if not part:
                continue
            if '=' in part:
                key, val = part.split('=', 1)
                key = key.strip()
                val = val.strip()
                if len(key) != 1:
                    # ignore invalid multi-char keys but keep processing
                    continue
                rebus_map[key] = val

    # Grid parsing
    grid_lines: List[str] = []
    grid_text = sections.get('grid', '')
    for line in grid_text.splitlines():
        l = line.strip()
        if not l:
            continue
        grid_lines.append(l)

    rows = len(grid_lines)
    cols = max((len(r) for r in grid_lines), default=0)

    # If metadata declares rows/cols (some XD exports include dimensions),
    # prefer to honor those by padding the parsed grid with '#' rows/cols
    # so the output JSON includes explicit cells for the declared area.
    def try_int(v):
        try:
            return int(v)
        except Exception:
            return None

    declared_rows = try_int(metadata.get('rows')) if metadata else None
    declared_cols = try_int(metadata.get('cols')) if metadata else None
    if declared_rows is not None and declared_rows > rows:
        # pad grid_lines with full-black rows
        pad_count = declared_rows - rows
        for _ in range(pad_count):
            grid_lines.append('#' * cols if cols > 0 else '#')
        rows = declared_rows
        print(f'Warning: metadata.rows={declared_rows} > detected rows; padding with {pad_count} black rows')
    if declared_cols is not None and declared_cols > cols:
        # pad each existing row to declared_cols with trailing '#'
        for i in range(len(grid_lines)):
            if len(grid_lines[i]) < declared_cols:
                grid_lines[i] = grid_lines[i].ljust(declared_cols, '#')
        cols = declared_cols
        print(f'Warning: metadata.cols={declared_cols} > detected cols; padding rows to {declared_cols} columns')

    # Build cell objects
    cells: List[Dict[str, Any]] = []
    grid = [[None for _ in range(cols)] for _ in range(rows)]
    for y, row in enumerate(grid_lines):
        for x in range(cols):
            ch = row[x] if x < len(row) else '#'
            if ch == '#':
                cells.append({'x': x, 'y': y, 'is_black': True, 'solution': None})
                grid[y][x] = None
            else:
                # rebus digits or other symbols
                if ch.isdigit() and ch in rebus_map:
                    # store rebus expansion separately but keep a single-letter solution
                    val = rebus_map[ch]
                    # pick a single-letter representation for the visible solution: first alpha char
                    repl = None
                    m = re.search(r'[A-Za-z]', val)
                    if m:
                        repl = m.group(0).upper()
                    else:
                        repl = val[0].upper() if val else ch
                    cells.append({'x': x, 'y': y, 'is_black': False, 'solution': repl, 'rebus': val})
                    grid[y][x] = val
                else:
                    # uppercase letters indicate solution letter
                    if ch == '.' or ch == '_':
                        cells.append({'x': x, 'y': y, 'is_black': False, 'solution': None})
                        grid[y][x] = None
                    else:
                        # Normal letter or special-lowercase: keep as single-letter solution
                        cells.append({'x': x, 'y': y, 'is_black': False, 'solution': ch})
                        grid[y][x] = ch

    # Numbering
    number_map = {}
    current_number = 1
    for y in range(rows):
        for x in range(cols):
            idx = y * cols + x
            if cells[idx]['is_black']:
                continue
            # start of across
            is_start_across = (x == 0 or cells[y * cols + (x - 1)]['is_black']) and (x < cols - 1 and not cells[y * cols + (x + 1)]['is_black'])
            is_start_down = (y == 0 or cells[(y - 1) * cols + x]['is_black']) and (y < rows - 1 and not cells[(y + 1) * cols + x]['is_black'])
            if is_start_across or is_start_down:
                number_map[f"{y},{x}"] = current_number
                current_number += 1

    # Parse clues
    clues_text = sections.get('clues', '')
    across_clues = []
    down_clues = []
    cur_group = None
    for line in clues_text.splitlines():
        line = line.rstrip()
        if not line.strip():
            cur_group = None
            continue

        # Use last '~' as separator for answer (matches reference parser)
        answer_idx = line.rfind('~')
        if answer_idx >= 0:
            left = line[:answer_idx].strip()
            right = line[answer_idx + 1 :].strip()
        else:
            left = line.strip()
            right = ''

        # left should contain the position like 'A1. ' — find first dot
        dot = left.find('.')
        if dot > 0:
            pos = left[:dot].strip()
            clue_body = left[dot + 1 :].strip()
            # parse pos into direction and number if possible
            if len(pos) >= 2 and pos[0].isalpha() and pos[1:].isdigit():
                prefix = pos[0].upper()
                num = int(pos[1:])
            else:
                # fallback: set prefix empty and use pos as number (non-numeric allowed)
                prefix = ''
                try:
                    num = int(pos)
                except Exception:
                    num = pos
        else:
            # no dot — attempt a best-effort parse: split leading alnum token
            mpos = re.match(r'^([A-Za-z]?\d+)\b', left)
            if mpos:
                pos = mpos.group(1)
                prefix = pos[0].upper() if pos and pos[0].isalpha() else ''
                try:
                    num = int(pos[1:]) if prefix else int(pos)
                except Exception:
                    num = pos
                clue_body = left[mpos.end():].strip()
            else:
                # couldn't parse position; skip this line
                continue

        entry = {'number': num, 'clue': clue_body, 'answer': (right if right else None)}
        if prefix == 'D':
            down_clues.append(entry)
        else:
            across_clues.append(entry)

    # Post-process clues to handle answers on the following line (common in some .xd files)
    def attach_following_answers(clues_list: List[Dict[str, Any]], raw_lines: List[str]):
        # Build mapping from number -> clue entry for quick lookup
        num_to_idx = {c['number']: i for i, c in enumerate(clues_list) if c.get('number') is not None}
        for i, line in enumerate(raw_lines):
            m = re.match(r'^([A-Za-z]?)(\d+)\.\s*(.*)$', line.strip())
            if m:
                prefix = m.group(1).upper()
                num = int(m.group(2))
                rest = m.group(3)
                if ' ~ ' not in rest:
                    # look at next non-empty line
                    j = i + 1
                    while j < len(raw_lines) and raw_lines[j].strip() == '':
                        j += 1
                    if j < len(raw_lines):
                        cand = raw_lines[j].strip()
                        # if candidate looks like an answer (mostly uppercase and letters/digits/spaces)
                        if re.match(r'^[A-Z0-9\s]+$', cand):
                            # find in across or down depending on prefix
                            if num in num_to_idx:
                                idx = num_to_idx[num]
                                if not clues_list[idx].get('answer'):
                                    clues_list[idx]['answer'] = cand.strip()
        return clues_list

    # Run attach on both across and down using the raw clues_text lines
    raw_clue_lines = [l for l in clues_text.splitlines()]
    across_clues = attach_following_answers(across_clues, raw_clue_lines)
    down_clues = attach_following_answers(down_clues, raw_clue_lines)

    # Build entries from grid using numbering map and fill answers from cell solutions
    entries = []
    for y in range(rows):
        for x in range(cols):
            idx = y * cols + x
            if cells[idx]['is_black']:
                continue

            # across entries
            if (x == 0 or cells[y * cols + (x - 1)]['is_black']) and (x < cols - 1 and not cells[y * cols + (x + 1)]['is_black']):
                number = number_map.get(f"{y},{x}", 0)
                lx = x
                while lx < cols and not cells[y * cols + lx]['is_black']:
                    lx += 1
                # build expanded answer from cells x..lx-1
                expanded = []
                for ix in range(x, lx):
                    cell = cells[y * cols + ix]
                    if cell.get('rebus'):
                        expanded.append(cell['rebus'])
                    else:
                        expanded.append(cell.get('solution') or '')
                answer = ''.join(expanded)
                clue_text = None
                clue_answer = None
                for c in across_clues:
                    if c.get('number') == number:
                        clue_text = c.get('clue')
                        clue_answer = c.get('answer')
                        break
                if clue_text is None:
                    clue_text = 'Clue unavailable'
                # If the clue itself provides an explicit answer (via '~'), prefer it
                if clue_answer:
                    answer = clue_answer
                entries.append({'id': f'a{number}', 'number': number, 'direction': 'across', 'x': x, 'y': y, 'length': (lx - x), 'answer': answer, 'clue': clue_text})

            # down entries
            if (y == 0 or cells[(y - 1) * cols + x]['is_black']) and (y < rows - 1 and not cells[(y + 1) * cols + x]['is_black']):
                number = number_map.get(f"{y},{x}", 0)
                ly = y
                while ly < rows and not cells[ly * cols + x]['is_black']:
                    ly += 1
                expanded = []
                for iy in range(y, ly):
                    cell = cells[iy * cols + x]
                    if cell.get('rebus'):
                        expanded.append(cell['rebus'])
                    else:
                        expanded.append(cell.get('solution') or '')
                answer = ''.join(expanded)
                clue_text = None
                clue_answer = None
                for c in down_clues:
                    if c.get('number') == number:
                        clue_text = c.get('clue')
                        clue_answer = c.get('answer')
                        break
                if clue_text is None:
                    clue_text = 'Clue unavailable'
                if clue_answer:
                    answer = clue_answer
                entries.append({'id': f'd{number}', 'number': number, 'direction': 'down', 'x': x, 'y': y, 'length': (ly - y), 'answer': answer, 'clue': clue_text})

    puzzle = {
        'id': metadata.get('title', 'xd_import'),
        'version': '1.0',
        'metadata': metadata,
        'rows': rows,
        'cols': cols,
        'cells': cells,
        'entries': entries,
        'clues': {'across': across_clues, 'down': down_clues}
    }

    return puzzle


def main():
    parser = argparse.ArgumentParser(description='Convert .xd to canonical JSON')
    parser.add_argument('input', help='.xd input file')
    parser.add_argument('--out', '-o', default=None, help='Output JSON file')
    args = parser.parse_args()

    text = Path(args.input).read_text(encoding='utf-8')
    puzzle = parse_xd(text)

    outpath = args.out or (Path(args.input).with_suffix('.json'))
    Path(outpath).write_text(json.dumps(puzzle, ensure_ascii=False, indent=2), encoding='utf-8')
    print('Wrote', outpath)


if __name__ == '__main__':
    main()
