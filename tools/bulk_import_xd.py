#!/usr/bin/env python3
"""Bulk import .xd files into frontend/assets/data and validate them.

Usage:
  python tools/bulk_import_xd.py --src "C:/Users/frede/Downloads/xd-puzzles/gxd" --dest ../frontend/assets/data --group-by source-folder

The script will parse each .xd, convert to canonical JSON using parse_xd,
write the JSON to the destination, and run the validator to verify correctness.
"""
import argparse
import sys
import json
import os
import subprocess
from pathlib import Path
from typing import List

# If running the script directly (python tools/bulk_import_xd.py) ensure project root
if __package__ is None:
    repo_root = Path(__file__).parent.parent.resolve()
    if str(repo_root) not in sys.path:
        sys.path.insert(0, str(repo_root))

from tools.xd_to_canonical import parse_xd


def discover_xd_files(src_dir: Path, recursive: bool = True) -> List[Path]:
    if recursive:
        return [p for p in src_dir.rglob("*.xd") if p.is_file()]
    else:
        return [p for p in src_dir.glob("*.xd") if p.is_file()]


def import_file(xd_path: Path, dest_base: Path, src_base: Path, group_by: str = "none", pretty: bool = True):
    """Parse .xd and write canonical JSON to dest. Return tuple (json_path, validation_ok, validator_output)
    """
    rel = xd_path.relative_to(src_base) if src_base in xd_path.parents or xd_path == src_base else xd_path.name
    if group_by == "source-folder":
        # preserve subfolders relative to src_base
        jdir = dest_base / rel.parent
    else:
        jdir = dest_base
    jdir.mkdir(parents=True, exist_ok=True)
    jsname = xd_path.with_suffix(".json").name
    outpath = jdir / jsname

    details = {
        "xd": str(xd_path),
        "json": str(outpath),
        "parsed": False,
        "parse_error": None,
        "validator_returncode": None,
        "validator_stdout": None,
        "validator_stderr": None,
    }
    try:
        text = xd_path.read_text(encoding='utf-8')
        puzzle = parse_xd(text)
        details['parsed'] = True
    except Exception as e:
        details['parse_error'] = str(e)
        return outpath, False, f"Parse exception: {e}", details

    out_text = json.dumps(puzzle, ensure_ascii=False, indent=2 if pretty else None)
    outpath.write_text(out_text, encoding='utf-8')

    # Validate using validator script as subprocess
    validator = Path(__file__).parent / "validate_xd_json.py"
    cmd = ["python", str(validator), str(xd_path), str(outpath)]
    try:
        p = subprocess.run(cmd, capture_output=True, text=True)
        details['validator_returncode'] = p.returncode
        details['validator_stdout'] = p.stdout
        details['validator_stderr'] = p.stderr
        ok = p.returncode == 0
        return outpath, ok, p.stdout + p.stderr, details
    except Exception as e:
        details['validator_stderr'] = f"Validator exception: {e}"
        return outpath, False, f"Validator exception: {e}", details


def main():
    parser = argparse.ArgumentParser(description="Bulk-import .xd files into assets/data")
    parser.add_argument("--src", required=True, help="Source folder containing .xd files")
    parser.add_argument("--dest", default="../frontend/assets/data", help="Destination base folder (default ../frontend/assets/data)")
    parser.add_argument("--group-by", choices=["none", "source-folder", "year-folder"], default="source-folder", help="How to group imported JSON files")
    parser.add_argument("--recursive", action="store_true", help="Search recursively in source folder")
    parser.add_argument("--pretty", action="store_true", help="Pretty-print JSON output")
    parser.add_argument("--report", default=None, help="Write a JSON report of results to file")
    parser.add_argument("--stop-on-failure", action="store_true", help="Abort on first parse/validation failure")
    parser.add_argument("--move-original", action="store_true", help="Move original .xd files into an 'imported' or 'failed' subfolder after processing")

    args = parser.parse_args()
    src = Path(args.src).expanduser().resolve()
    dest = Path(args.dest).expanduser().resolve()
    dest.mkdir(parents=True, exist_ok=True)

    # Reorganize-only path: don't import, just move existing JSONs under dest
    if args.group_by == "year-folder" and not src.exists():
        # Allow running without a valid src when reorganizing
        pass
    if args.group_by == "year-folder" and (src == dest or not src.exists()):
        moved = 0
        examined = 0
        import re as _re
        for j in dest.rglob("*.json"):
            examined += 1
            try:
                rel = j.relative_to(dest)
            except Exception:
                rel = Path(j.name)
            parts = rel.parts
            source_top = parts[0] if len(parts) > 1 else "misc"
            year = None
            m = _re.search(r"(19|20)\d{2}", j.name)
            if m:
                year = m.group(0)
            else:
                for p in j.parents:
                    pm = _re.search(r"(19|20)\d{2}", p.name)
                    if pm:
                        year = pm.group(0)
                        break
            if not year:
                try:
                    data = json.loads(j.read_text(encoding='utf-8'))
                    title = (data.get('metadata', {}) or {}).get('title') or data.get('id') or ''
                    tm = _re.search(r"(19|20)\d{2}", str(title))
                    year = tm.group(0) if tm else None
                except Exception:
                    year = None
            if not year:
                year = "unknown"
            target_dir = dest / source_top / year
            target_dir.mkdir(parents=True, exist_ok=True)
            target_path = target_dir / j.name
            if j.resolve() != target_path.resolve():
                try:
                    j.replace(target_path)
                    moved += 1
                except Exception as e:
                    print(f"Failed to move {j} -> {target_path}: {e}")
        print(f"Reorganized {moved} file(s) out of {examined} examined under {dest}")
        return 0

    if not src.exists():
        print(f"Source folder does not exist: {src}")
        return 2
    files = discover_xd_files(src, recursive=args.recursive)
    results = []
    print(f"Discovered {len(files)} .xd file(s) in {src}")
    for xd in files:
        print(f"Importing {xd} -> {dest}")
        outpath, ok, msg, details = import_file(xd, dest, src, group_by=args.group_by, pretty=args.pretty)
        print("OK" if ok else "FAILED")
        if msg:
            print(msg)
        # Optionally move original files
        if args.move_original:
            target_sub = "imported" if ok else "failed"
            target_dir = src / target_sub
            target_dir.mkdir(parents=True, exist_ok=True)
            try:
                xd.rename(target_dir / xd.name)
            except Exception as e:
                print(f"Failed to move original {xd}: {e}")

        results.append({"xd": str(xd), "json": str(outpath), "ok": ok, "log": msg, "details": details})
        if args.stop_on_failure and not ok:
            print("Stopping on first failure (--stop-on-failure enabled)")
            break

    if args.report:
        Path(args.report).write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding='utf-8')
        print(f"Wrote report to {args.report}")

    failures = [r for r in results if not r['ok']]
    if failures:
        print(f"{len(failures)} failure(s) during import/validation")
        return 1
    print("All imported and validated successfully.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
