import sys
import os

def main():
    threshold_val = 70.0
    for arg in sys.argv:
        if arg.startswith('--threshold='):
            try:
                threshold_val = float(arg.split('=')[1])
            except ValueError:
                pass

    lcov_file = 'coverage/lcov.info'
    if not os.path.exists(lcov_file):
        print('coverage/lcov.info not found. Run `flutter test --coverage` first.', file=sys.stderr)
        sys.exit(2)

    with open(lcov_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    files = {}
    current = None
    for line in lines:
        line = line.strip()
        if line.startswith('SF:'):
            current = line[3:]
            files[current] = []
        elif current is not None:
            files[current].append(line)

    total_all = 0
    covered_all = 0

    print('Per-file coverage:')
    for fname, data in files.items():
        total = 0
        covered = 0
        for line in data:
            if line.startswith('DA:'):
                parts = line[3:].split(',')
                if len(parts) >= 2:
                    total += 1
                    try:
                        hits = int(parts[1])
                        if hits > 0:
                            covered += 1
                    except ValueError:
                        pass
        
        if total > 0:
            pct = covered / total * 100.0
            display_name = '/'.join(fname.replace('\\', '/').split('/')[-3:])
            print(f'{display_name} : {covered}/{total} = {pct:.2f}%')
        
        total_all += total
        covered_all += covered

    if total_all == 0:
        print('No DA lines found in lcov.info; coverage unknown.')
        sys.exit(3)

    pct_all = covered_all / total_all * 100.0
    result = f'{covered_all}/{total_all} = {pct_all:.2f}%'
    print(f'\nOverall coverage: {result}')

    if pct_all < threshold_val:
        print(f'Coverage {result} is below threshold {threshold_val:.2f}%', file=sys.stderr)
        sys.exit(4)
    
    print(f'Coverage meets threshold {threshold_val:.2f}%')
    sys.exit(0)

if __name__ == "__main__":
    main()
