#!/usr/bin/env python3
"""
Simple Riverpod audit script.
Scans `frontend/lib` for common Riverpod patterns and emits a report.
"""
import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'lib'
OUT = Path(__file__).resolve().parents[1] / 'riverpod_audit_report.txt'

PATTERNS = {
    'context.watch/read': re.compile(r"context\.\s*(watch|read)\s*\(") ,
    'ref.watch_in_controllers_or_services': re.compile(r"ref\.watch\s*\(") ,
    'context_usage': re.compile(r"context\."),
    'providercontainer_in_lib': re.compile(r"ProviderContainer\b"),
    'ref.read_notifier_set': re.compile(r"\.notifier\)"),
}

# Directories considered non-widget long-lived code where `ref.watch` is discouraged
NON_WIDGET_DIR_HINTS = ['controllers', 'services', 'persistence']

results = []

for p in ROOT.rglob('*.dart'):
    rel = p.relative_to(Path(__file__).resolve().parents[1])
    text = p.read_text(encoding='utf-8')
    for name, pat in PATTERNS.items():
        for m in pat.finditer(text):
            line_no = text.count('\n', 0, m.start()) + 1
            # Skip matches that occur on lines where the token appears after a '//' comment
            line_start = text.rfind('\n', 0, m.start()) + 1
            line_end = text.find('\n', m.start())
            if line_end == -1:
                line_end = len(text)
            line_text = text[line_start:line_end]
            match_pos_in_line = m.start() - line_start
            cpos = line_text.find('//')
            if cpos != -1 and cpos < match_pos_in_line:
                continue
            results.append((str(rel), line_no, name, m.group(0)))

# Heuristic: find ref.watch within non-widget dirs
heuristic_issues = []
for p in ROOT.rglob('*.dart'):
    if any(h in str(p.parts) for h in NON_WIDGET_DIR_HINTS):
        text = p.read_text(encoding='utf-8')
        for m in re.finditer(r"ref\.watch\s*\(", text):
            line_no = text.count('\n', 0, m.start()) + 1
            # skip if in line comment
            line_start = text.rfind('\n', 0, m.start()) + 1
            line_end = text.find('\n', m.start())
            if line_end == -1:
                line_end = len(text)
            line_text = text[line_start:line_end]
            match_pos_in_line = m.start() - line_start
            cpos = line_text.find('//')
            if cpos != -1 and cpos < match_pos_in_line:
                continue
            heuristic_issues.append((str(p.relative_to(Path(__file__).resolve().parents[1])), line_no, 'ref.watch in non-widget dir'))

has_heuristic = bool(heuristic_issues)

with OUT.open('w', encoding='utf-8') as f:
    f.write('Riverpod Audit Report\n')
    f.write('Root: {}\n\n'.format(ROOT))
    if results:
        f.write('Matches:\n')
        for r in results:
            f.write(f"- {r[0]}:{r[1]} -> {r[2]} -> {r[3]!r}\n")
    else:
        f.write('No pattern matches found.\n')

    f.write('\nHeuristic issues (ref.watch in controllers/services):\n')
    if heuristic_issues:
        for h in heuristic_issues:
            f.write(f"- {h[0]}:{h[1]} -> {h[2]}\n")
    else:
        f.write('No heuristic issues found.\n')

print('Audit complete. Report written to', OUT)
if has_heuristic:
    print('Heuristic issues found; exiting with status 2')
    raise SystemExit(2)
else:
    print('No heuristic issues found')
