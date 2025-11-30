// ignore_for_file: eol_at_end_of_file

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

  final files = <String, List<String>>{};
  String? current;
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      current = line.substring(3);
      files[current] = [];
    } else if (current != null) {
      files[current]!.add(line);
    }
  }

  var totalAll = 0;
  var coveredAll = 0;

  stdout.writeln('Per-file coverage:');
  for (final entry in files.entries) {
    final fname = entry.key;
    var total = 0;
    var covered = 0;
    for (final line in entry.value) {
      if (line.startsWith('DA:')) {
        final parts = line.substring(3).split(',');
        if (parts.length >= 2) {
          total++;
          final hits = int.tryParse(parts[1]) ?? 0;
          if (hits > 0) {
            covered++;
          }
        }
      }
    }
    if (total > 0) {
      final pct = covered / total * 100.0;
      stdout.writeln('${fname.replaceAll(r'\\', '/').split('/').takeLast(3).join('/')} : $covered/$total = ${pct.toStringAsFixed(2)}%');
    }
    totalAll += total;
    coveredAll += covered;
  }

  if (totalAll == 0) {
    stdout.writeln('No DA lines found in lcov.info; coverage unknown.');
    exit(3);
  }

  final pctAll = coveredAll / totalAll * 100.0;
  final result = '$coveredAll/$totalAll = ${pctAll.toStringAsFixed(2)}%';
  stdout.writeln('\nOverall coverage: $result');

  if (pctAll < threshold) {
    stderr.writeln('Coverage $result is below threshold ${threshold.toStringAsFixed(2)}%');
    exit(4);
  }
  stdout.writeln('Coverage meets threshold ${threshold.toStringAsFixed(2)}%');
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


