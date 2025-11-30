import 'dart:io';

void main(List<String> args) {
  final thresholdArg = args.firstWhere(
    (a) => a.startsWith('--threshold='),
    orElse: () => '--threshold=70',
  );
  final threshold = double.tryParse(thresholdArg.split('=')[1]) ?? 70.0;

  final f = File('coverage/lcov.info');
  if (!f.existsSync()) {
    stderr.writeln('coverage/lcov.info not found. Run `flutter test --coverage` first.');
    exit(2);
  }

  final lines = f.readAsLinesSync();

  final Map<String, List<String>> files = {};
  String? current;
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      current = line.substring(3);
      files[current] = [];
    } else if (current != null) {
      files[current]!.add(line);
    }
  }

  int totalAll = 0;
  int coveredAll = 0;

  print('Per-file coverage:');
  for (final entry in files.entries) {
    final fname = entry.key;
    int total = 0;
    int covered = 0;
    for (final line in entry.value) {
      if (line.startsWith('DA:')) {
        final parts = line.substring(3).split(',');
        if (parts.length >= 2) {
          total++;
          final hits = int.tryParse(parts[1]) ?? 0;
          if (hits > 0) covered++;
        }
      }
    }
    if (total > 0) {
      final pct = covered / total * 100.0;
      print('${fname.replaceAll('\\\\', '/').split('/').takeLast(3).join('/')} : ${covered}/${total} = ${pct.toStringAsFixed(2)}%');
    }
    totalAll += total;
    coveredAll += covered;
  }

  if (totalAll == 0) {
    print('No DA lines found in lcov.info; coverage unknown.');
    exit(3);
  }

  final pctAll = coveredAll / totalAll * 100.0;
  final result = '${coveredAll}/${totalAll} = ${pctAll.toStringAsFixed(2)}%';
  print('\nOverall coverage: $result');

  if (pctAll < threshold) {
    stderr.writeln('Coverage $result is below threshold ${threshold.toStringAsFixed(2)}%');
    exit(4);
  }

  print('Coverage meets threshold ${threshold.toStringAsFixed(2)}%');
  exit(0);
}

extension<T> on Iterable<T> {
  Iterable<T> takeLast(int n) sync* {
    final list = toList();
    final start = list.length - n;
    for (var i = start < 0 ? 0 : start; i < list.length; i++) {
      yield list[i];
    }
  }
}

