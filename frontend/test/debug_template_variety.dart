// ignore_for_file: avoid_print
import 'dart:math';
import 'package:croiz/features/generation/services/grid_template.dart';

void main() {
  final random = Random(42);
  final generator = GridTemplateGenerator(
    width: 10,
    height: 10,
    targetBlackRatio: 0.18,
    random: random,
  );

  final templates = <String>{};
  for (var i = 0; i < 100; i++) {
    final grid = generator.generate();
    final s = grid
        .map((row) => row.map((c) => c ? '#' : '.').join())
        .join('\n');
    templates.add(s);
  }

  print('Unique templates in 100 runs: ${templates.length}');
  if (templates.length > 1) {
    print('Variety is OK');
  } else {
    print('NO VARIETY!');
    print('Template:\n${templates.first}');
  }
}
