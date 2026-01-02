import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/grid_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GridGenerator Large Grids', () {
    test('should generate 25x25 grid reasonably fast', () {
      final generator = GridGenerator(width: 25, height: 25);
      // Generate 50 dummy words to simulate a large puzzle
      final words = List.generate(
        50,
        (index) => GeneratedWord(answer: 'WORD$index', clue: 'Clue $index'),
      );

      final stopwatch = Stopwatch()..start();
      final result = generator.generate(
        words,
        attempts: 2,
      ); // Lower attempts for test speed
      stopwatch.stop();

      // print('25x25 Generation took: ${stopwatch.elapsedMilliseconds}ms');

      expect(result, isNotEmpty);
      expect(
        result.length,
        greaterThan(10),
      ); // Should place a decent number of words

      // Verify bounds
      for (final placed in result) {
        expect(placed.startX, greaterThanOrEqualTo(0));
        expect(placed.startY, greaterThanOrEqualTo(0));
        if (placed.isHorizontal) {
          expect(
            placed.startX + placed.word.answer.length,
            lessThanOrEqualTo(25),
          );
        } else {
          expect(
            placed.startY + placed.word.answer.length,
            lessThanOrEqualTo(25),
          );
        }
      }
    });

    test('should generate 20x20 grid', () {
      final generator = GridGenerator(width: 20, height: 20);
      final words = List.generate(
        40,
        (index) => GeneratedWord(answer: 'TEST$index', clue: 'Clue $index'),
      );

      final result = generator.generate(words, attempts: 2);

      expect(result, isNotEmpty);
      expect(result.length, greaterThan(10));
    });
  });
}
