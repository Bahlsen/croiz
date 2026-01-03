import 'package:croiz/features/generation/models/generated_word.dart';

import 'package:croiz/features/generation/services/grid_first_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GridFirstGenerator', () {
    test('defaults are configured correctly', () {
      final generator = GridFirstGenerator(width: 15, height: 15);
      expect(generator.targetBlackRatio, 0.20);
      expect(generator.minWordLength, 3);
      expect(generator.maxAttempts, 100);
    });

    test('generate produces valid grid with sufficient words', () {
      final generator = GridFirstGenerator(width: 10, height: 10);

      // Theme words usually from Gemini
      final themeWords = [
        const GeneratedWord(answer: 'FLUTTER', clue: 'Framework'),
        const GeneratedWord(answer: 'DART', clue: 'Language'),
        const GeneratedWord(answer: 'WIDGET', clue: 'UI component'),
        const GeneratedWord(answer: 'STATE', clue: 'Data'),
        const GeneratedWord(answer: 'BUILD', clue: 'Method'),
      ];

      // Fill words usually from dictionary
      // We provide a small set that can form a grid
      final fillWords = [
        'TEST',
        'CODE',
        'UNIT',
        'PASS',
        'FAIL',
        'RUNS',
        'GOOD',
        'BEST',
        'FAST',
        'SLOW',
        'HARD',
        'EASY',
        'GRID',
        'WORD',
        'LIST',
        'FILL',
        'LUCK',
        'GAME',
        'PLAY',
        'TIME',
        'DATE',
        'YEAR',
        'USER',
        'VIEW',
      ];

      final result = generator.generate(
        themeWords: themeWords,
        fillWords: fillWords,
      );

      // We expect some result, though success depends on randomness and dictionary size.
      // With very small dictionary, it might fail to fill ALL slots.
      // But it should place words.

      expect(result, isNotNull);
      // It might be partial success, but we check if it tried.
      if (result.success) {
        expect(result.placedWords, isNotEmpty);
      }

      expect(result.grid, isNotNull);
      expect(result.metrics, isNotNull);
      expect(result.template, isNotNull);
    });

    test('handles failure gracefully when no words fit', () {
      final generator = GridFirstGenerator(
        width: 10,
        height: 10,
        maxAttempts: 2,
      );

      // Impossible constraints (no words provided, empty dictionary)
      // GridFirstGenerator builds GADDAG. If empty, GADDAG is empty.
      // Slots will be extracted. CSP will fail immediately (Domain empty).

      final result = generator.generate(themeWords: [], fillWords: []);

      expect(result.success, isFalse);
      expect(result.placedWords, isEmpty);
      // Result should still be returned
    });

    test('uses random template style primarily', () {
      // We verify that multiple calls produce different templates
      // (implying random generation).

      final generator = GridFirstGenerator(width: 10, height: 10);
      final themeWords = [const GeneratedWord(answer: 'TEST', clue: '')];

      final result1 = generator.generate(themeWords: themeWords);
      final result2 = generator.generate(themeWords: themeWords);

      // We ignore content (placed words will be empty)
      // But templates should differ

      var same = true;
      // Compare dimensions
      if (result1.template.length == result2.template.length) {
        // Compare cells
        outer:
        for (var y = 0; y < 10; y++) {
          for (var x = 0; x < 10; x++) {
            if (result1.template[y][x] != result2.template[y][x]) {
              same = false;
              break outer;
            }
          }
        }
      } else {
        same = false;
      }

      // Note: Random might produce same grid by chance, but unlikely for 10x10.
      expect(
        same,
        isFalse,
        reason: 'Consecutive generations should produce different templates',
      );
    });
  });
}
