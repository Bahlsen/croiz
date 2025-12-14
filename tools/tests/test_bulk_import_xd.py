import json
import subprocess
from pathlib import Path
import shutil
from tools.bulk_import_xd import discover_xd_files, import_file


def test_discover_xd_files(tmp_path):
    d = tmp_path / "gxd"
    d.mkdir()
    p = d / "a1.xd"
    p.write_text("ABC#DEF\n")
    f = discover_xd_files(d, recursive=False)
    assert len(f) == 1


def test_import_and_validate(tmp_path):
    # Use tools sample .xd
    src = tmp_path / "gxd"
    src.mkdir()
    sample_xd = Path(__file__).parent.parent / "samples" / "nyt2005-01-01.xd"
    assert sample_xd.exists()
    dst_xd = src / "nyt2005-01-01.xd"
    shutil.copy(sample_xd, dst_xd)

    dest = tmp_path / "out"
    dest.mkdir()
    outpath, ok, msg, details = import_file(dst_xd, dest, src, group_by="source-folder", pretty=True)
    assert ok is True
    assert outpath.exists()
    assert details.get('parsed') is True
    assert details.get('validator_returncode') == 0
    # ensure JSON is readable
    data = json.loads(outpath.read_text(encoding='utf-8'))
    assert 'cells' in data
    assert 'entries' in data


def test_cli_runs_and_writes_report(tmp_path):
    # copy sample into tmp input dir
    src = tmp_path / "gxd"
    src.mkdir()
    sample_xd = Path(__file__).parent.parent / "samples" / "nyt2005-01-01.xd"
    dst_xd = src / "nyt2005-01-01.xd"
    shutil.copy(sample_xd, dst_xd)

    dest = tmp_path / "out"
    dest.mkdir()
    report = tmp_path / "report.json"
    cmd = ["python", "tools/bulk_import_xd.py", "--src", str(src), "--dest", str(dest), "--group-by", "source-folder", "--recursive", "--pretty", "--report", str(report)]
    p = subprocess.run(cmd, capture_output=True, text=True)
    assert p.returncode == 0
    assert report.exists()
    jr = json.loads(report.read_text(encoding='utf-8'))
    assert isinstance(jr, list)
    assert len(jr) == 1
    assert jr[0]['ok'] is True
