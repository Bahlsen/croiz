// ignore_for_file: avoid_print
// This is a manual benchmark/comparison script

import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/grid_first_generator.dart';
import 'package:croiz/features/generation/services/grid_generator.dart';
import 'package:croiz/features/generation/services/grid_quality_calculator.dart';

/// Benchmark comparing the legacy GridGenerator with the new GridFirstGenerator.
///
/// Run with: dart test/manual/grid_first_benchmark.dart
void main() {
  print('🧪 Grid Generation Algorithm Comparison - January 2026\n');
  print('=' * 70);

  // Test words
  final testWords = _generateTestWords();

  print('\n📊 Configuration:');
  print('  - Words available: ${testWords.length}');
  print('  - Grid size: 15×15 (225 cells)');
  print('');

  // Run both algorithms
  print('🔄 Running legacy algorithm (GridGenerator)...');
  final legacyResults = _runLegacy(testWords);

  print('🔄 Running new algorithm (GridFirstGenerator)...');
  final newResults = _runGridFirst(testWords);

  // Compare results
  print('\n${'=' * 70}');
  print('\n📈 RESULTS COMPARISON:\n');

  _printComparisonTable([
    ['Metric', 'Legacy (v2.1)', 'New (v3.0)', 'Improvement'],
    [
      'Words Placed',
      legacyResults.wordsPlaced.toString(),
      newResults.wordsPlaced.toString(),
      _improvement(legacyResults.wordsPlaced, newResults.wordsPlaced),
    ],
    [
      'Placement Rate',
      '${(legacyResults.placementRate * 100).toStringAsFixed(1)}%',
      '${(newResults.placementRate * 100).toStringAsFixed(1)}%',
      _improvement(legacyResults.placementRate, newResults.placementRate),
    ],
    [
      'Letter Density',
      '${(legacyResults.letterDensity * 100).toStringAsFixed(1)}%',
      '${(newResults.letterDensity * 100).toStringAsFixed(1)}%',
      _improvement(legacyResults.letterDensity, newResults.letterDensity),
    ],
    [
      'Black Square Ratio',
      '${(legacyResults.blackSquareRatio * 100).toStringAsFixed(1)}%',
      '${(newResults.blackSquareRatio * 100).toStringAsFixed(1)}%',
      _improvement(
        newResults.blackSquareRatio,
        legacyResults.blackSquareRatio,
      ), // Lower is better
    ],
    [
      'Row Coverage',
      '${(legacyResults.rowCoverage * 100).toStringAsFixed(1)}%',
      '${(newResults.rowCoverage * 100).toStringAsFixed(1)}%',
      _improvement(legacyResults.rowCoverage, newResults.rowCoverage),
    ],
    [
      'Column Coverage',
      '${(legacyResults.columnCoverage * 100).toStringAsFixed(1)}%',
      '${(newResults.columnCoverage * 100).toStringAsFixed(1)}%',
      _improvement(legacyResults.columnCoverage, newResults.columnCoverage),
    ],
    [
      'Avg Intersections/Word',
      legacyResults.avgIntersectionsPerWord.toStringAsFixed(2),
      newResults.avgIntersectionsPerWord.toStringAsFixed(2),
      _improvement(
        legacyResults.avgIntersectionsPerWord,
        newResults.avgIntersectionsPerWord,
      ),
    ],
  ]);

  print('\n${'=' * 70}');
  print('\n🎯 Quality Thresholds Check:\n');

  print('  Legacy Algorithm:');
  print(
    '    Meets Quality Thresholds: ${legacyResults.meetsQualityThresholds ? '✅' : '❌'}',
  );
  print('    Is Viable: ${legacyResults.isViable ? '✅' : '❌'}');

  print('\n  New Algorithm:');
  print(
    '    Meets Quality Thresholds: ${newResults.meetsQualityThresholds ? '✅' : '❌'}',
  );
  print('    Is Viable: ${newResults.isViable ? '✅' : '❌'}');

  print('\n${'=' * 70}\n');
}

BenchmarkResult _runLegacy(List<GeneratedWord> words) {
  final stopwatch = Stopwatch()..start();

  final generator = GridGenerator(width: 15, height: 15);
  final placed = generator.generate(words, language: 'fr');

  stopwatch.stop();

  final metrics = GridQualityCalculator.calculate(
    placedWords: placed,
    gridWidth: 15,
    gridHeight: 15,
    totalWordsAttempted: words.length,
  );

  print('    ⏱️  Time: ${stopwatch.elapsedMilliseconds}ms');
  print('    📝 Placed: ${placed.length} / ${words.length} words');

  return BenchmarkResult(
    wordsPlaced: metrics.wordsPlaced,
    placementRate: metrics.placementRate,
    letterDensity: metrics.letterDensity,
    blackSquareRatio: metrics.blackSquareRatio,
    rowCoverage: metrics.rowCoverage,
    columnCoverage: metrics.columnCoverage,
    avgIntersectionsPerWord: metrics.avgIntersectionsPerWord,
    meetsQualityThresholds: metrics.meetsQualityThresholds,
    isViable: metrics.isViable,
    timeMs: stopwatch.elapsedMilliseconds,
  );
}

BenchmarkResult _runGridFirst(List<GeneratedWord> words) {
  final stopwatch = Stopwatch()..start();

  // Build fill dictionary with additional common words
  final fillWords = [
    // Common 3-letter
    'THE', 'AND', 'FOR', 'ARE', 'BUT', 'NOT', 'YOU', 'ALL', 'CAN', 'HER',
    'WAS', 'ONE', 'OUR', 'OUT', 'DAY', 'HAD', 'HOT', 'HAS', 'HIS', 'HOW',
    // Common 4-letter
    'THAT', 'WITH', 'HAVE', 'THIS', 'WILL', 'YOUR', 'FROM', 'THEY', 'BEEN',
    'CALL', 'COME', 'MADE', 'FIND', 'ONLY', 'INTO', 'TIME', 'VERY', 'WHEN',
    // Common 5-letter
    'THERE', 'THEIR', 'ABOUT', 'WOULD', 'THESE', 'OTHER', 'WORDS', 'COULD',
    'WRITE', 'FIRST', 'WATER', 'SOUND', 'PLACE', 'THINK', 'WHERE', 'AFTER',
    // Common 6-letter
    'PEOPLE', 'CALLED', 'BEFORE', 'NUMBER', 'AROUND', 'SHOULD', 'LITTLE',
    // Common 7-letter
    'BETWEEN', 'THROUGH', 'BECAUSE', 'ANOTHER', 'PICTURE', 'CHANGED',
  ];

  final generator = GridFirstGenerator(width: 15, height: 15, maxAttempts: 5);

  // Add theme words and fill words
  final allWords = words.map((w) => w.answer).toList()..addAll(fillWords);
  generator.buildDictionary(allWords);

  final result = generator.generate(themeWords: words, fillWords: fillWords);

  stopwatch.stop();

  print('    ⏱️  Time: ${stopwatch.elapsedMilliseconds}ms');
  print('    📝 Placed: ${result.placedWords.length} words');
  print('    ✅ Success: ${result.success}');
  if (!result.success) {
    print('    ⚠️  Reason: ${result.failureReason}');
  }

  return BenchmarkResult(
    wordsPlaced: result.metrics.wordsPlaced,
    placementRate: result.metrics.placementRate,
    letterDensity: result.metrics.letterDensity,
    blackSquareRatio: result.metrics.blackSquareRatio,
    rowCoverage: result.metrics.rowCoverage,
    columnCoverage: result.metrics.columnCoverage,
    avgIntersectionsPerWord: result.metrics.avgIntersectionsPerWord,
    meetsQualityThresholds: result.metrics.meetsQualityThresholds,
    isViable: result.metrics.isViable,
    timeMs: stopwatch.elapsedMilliseconds,
  );
}

void _printComparisonTable(List<List<String>> rows) {
  // Calculate column widths
  final widths = List.generate(
    rows[0].length,
    (col) => rows.map((row) => row[col].length).reduce((a, b) => a > b ? a : b),
  );

  // Print header
  final header = rows[0];
  print('  ${_formatRow(header, widths)}');
  print('  ${widths.map((w) => '-' * (w + 2)).join('+')}');

  // Print data rows
  for (var i = 1; i < rows.length; i++) {
    print('  ${_formatRow(rows[i], widths)}');
  }
}

String _formatRow(List<String> row, List<int> widths) =>
    row.asMap().entries.map((e) => e.value.padRight(widths[e.key])).join(' | ');

String _improvement(num oldValue, num newValue) {
  if (oldValue == 0 && newValue == 0) {
    return '-';
  }
  if (oldValue == 0) {
    return '+∞';
  }

  final diff = ((newValue - oldValue) / oldValue * 100).round();
  if (diff > 0) {
    return '+$diff%';
  }
  if (diff < 0) {
    return '$diff%';
  }
  return '0%';
}

List<GeneratedWord> _generateTestWords() {
  final words = [
    // Short words (3-5 letters) - 40%
    'CHAT', 'PAIN', 'LUNE', 'VENT', 'PEUR', 'JOIE', 'REVE', 'PAIX',
    'FLEUR', 'ARBRE', 'SOLEIL', 'TERRE', 'OCEAN', 'NUAGE',

    // Medium words (6-8 letters) - 40%
    'MAISON', 'JARDIN', 'FENETRE', 'LUMIERE', 'MUSIQUE', 'HISTOIRE',
    'SCIENCE', 'CULTURE', 'NATURE', 'VOYAGE', 'MONTAGNE', 'RIVIERE',
    'ETOILE', 'PLANETE',

    // Long words (9-15 letters) - 20%
    'ORDINATEUR', 'TELEPHONE', 'UNIVERSITE', 'BIBLIOTHEQUE',
    'MATHEMATIQUE', 'PHILOSOPHIE', 'ARCHITECTURE', 'PHOTOGRAPHIE',
  ];

  return words
      .map((word) => GeneratedWord(answer: word, clue: 'Clue for $word'))
      .toList();
}

class BenchmarkResult {
  const BenchmarkResult({
    required this.wordsPlaced,
    required this.placementRate,
    required this.letterDensity,
    required this.blackSquareRatio,
    required this.rowCoverage,
    required this.columnCoverage,
    required this.avgIntersectionsPerWord,
    required this.meetsQualityThresholds,
    required this.isViable,
    required this.timeMs,
  });

  final int wordsPlaced;
  final double placementRate;
  final double letterDensity;
  final double blackSquareRatio;
  final double rowCoverage;
  final double columnCoverage;
  final double avgIntersectionsPerWord;
  final bool meetsQualityThresholds;
  final bool isViable;
  final int timeMs;
}
