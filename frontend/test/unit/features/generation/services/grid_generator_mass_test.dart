import 'dart:math';
import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/grid_generator.dart';
import 'package:flutter_test/flutter_test.dart';

// Helper to calculate density
double calculateDensity(List<PlacedWord> placed, int width, int height) {
  final grid = List.generate(height, (_) => List.filled(width, false));
  var filledCount = 0;

  // Mark filled cells
  for (final pw in placed) {
    for (var i = 0; i < pw.word.answer.length; i++) {
      final x = pw.isHorizontal ? pw.startX + i : pw.startX;
      final y = pw.isHorizontal ? pw.startY : pw.startY + i;
      if (!grid[y][x]) {
        grid[y][x] = true;
        filledCount++;
      }
    }
  }

  // Determine bounding box of the actual puzzle to calculate density relative to the "used area"
  // vs entire grid. Users care about black squares *inside* the puzzle bounds.
  var minX = width;
  var maxX = 0;
  var minY = height;
  var maxY = 0;

  if (filledCount == 0) {
    return 0;
  }

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      if (grid[y][x]) {
        if (x < minX) {
          minX = x;
        }
        if (x > maxX) {
          maxX = x;
        }
        if (y < minY) {
          minY = y;
        }
        if (y > maxY) {
          maxY = y;
        }
      }
    }
  }

  final area = (maxX - minX + 1) * (maxY - minY + 1);
  return filledCount / area;
}

void main() {
  test('Mass Generation Benchmark', () {
    final generator = GridGenerator(width: 15, height: 15);
    final random = Random(42); // Fixed seed for reproducibility

    // Sample words pool (simulate AI output)
    final commonWords = [
      'APPLE',
      'BANANA',
      'CHERRY',
      'DATE',
      'ELDERBERRY',
      'FIG',
      'GRAPE',
      'HONEYDEW',
      'KIWI',
      'LEMON',
      'MANGO',
      'NECTARINE',
      'ORANGE',
      'PAPAYA',
      'QUINCE',
      'RASPBERRY',
      'STRAWBERRY',
      'TANGERINE',
      'UGLI',
      'VANILLA',
      'WATERMELON',
      'XIGUA',
      'YAM',
      'ZUCCHINI',
      'BERRY',
      'MELON',
      'FRUIT',
      'SWEET',
      'SOUR',
      'FRESH',
      'JUICY',
      'RIPE',
      'GREEN',
      'RED',
      'YELLOW',
      'LION',
      'TIGER',
      'BEAR',
      'WOLF',
      'FOX',
      'ZEBRA',
      'GIRAFFE',
      'ELEPHANT',
      'MONKEY',
      'APE',
      'GORILLA',
      'CHIMP',
      'LEMUR',
      'KOALA',
      'KANGAROO',
      'PANDA',
      'SLOTH',
      'OTTER',
      'BEAVER',
      'RACCOON',
      'SKUNK',
      'BADGER',
      'DOG',
      'CAT',
      'MOUSE',
      'RAT',
      'HAMSTER',
      'GERBIL',
      'GUINEA',
      'PIG',
    ];

    var totalDensity = 0.0;
    // var totalWordsPlaced = 0;
    var successCount = 0;
    const iterations = 50;

    // debugPrint('Starting Mass Generation Benchmark ($iterations iterations)...');

    for (var i = 0; i < iterations; i++) {
      // Pick 20 random words
      final currentWords = List<GeneratedWord>.from(
        (commonWords..shuffle(random))
            .take(60)
            .map((w) => GeneratedWord(answer: w, clue: 'Clue')),
      );

      final result = generator.generate(currentWords, attempts: 20);

      if (result.isNotEmpty) {
        final density = calculateDensity(result, 15, 15);
        totalDensity += density;
        // totalWordsPlaced += result.length;
        successCount++;
        // print('Run $i: ${result.length} words, Density: ${density.toStringAsFixed(2)}');
      }
    }

    final avgDensity = totalDensity / successCount;
    // final avgWords = totalWordsPlaced / successCount;

    // debugPrint('--------------------------------------------------');
    // debugPrint('Benchmark Results:');
    // debugPrint('Average Density: ${avgDensity.toStringAsFixed(2)}');
    // debugPrint('Average Words Placed: ${avgWords.toStringAsFixed(1)}');
    // debugPrint('--------------------------------------------------');

    // Fail if density is too low to force us to improve it.
    // Current rough estimate of "bad" density is < 0.25 (25% filled)
    // A good crossword is usually > 30-40% filled relative to bounding box?
    // Let's set a baseline expectation.
    expect(
      avgDensity,
      greaterThan(0.25),
      reason: 'Average density should be decent',
    );
  });
}
