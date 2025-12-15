from pathlib import Path
p=Path('frontend/build/web')
if not p.exists():
    print('build/web not found')
    raise SystemExit(2)
count=0
for f in p.rglob('*'):
    if f.is_file() and f.suffix in ('.js','.html','.json','.map'):
        try:
            s=f.read_text(encoding='utf-8', errors='ignore')
        except Exception:
            continue
        if 'assets/assets/data' in s:
            count+=1
            print(f'{f}:{s.count("assets/assets/data")}')
            for i,line in enumerate(s.splitlines()):
                if 'assets/assets/data' in line:
                    print(f'  {i+1}: {line.strip()}')
                    break
print(f'Found in {count} file(s)')
