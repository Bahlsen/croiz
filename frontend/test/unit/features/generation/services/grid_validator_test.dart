import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/grid_generator.dart';
import 'package:croiz/features/generation/utils/grid_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GridValidator', () {
    test('should validate a simple cross', () {
      final placed = [
        PlacedWord(
          word: const GeneratedWord(answer: 'HELLO', clue: ''),
          startX: 0,
          startY: 2,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'HELP', clue: ''),
          startX: 2,
          startY: 0,
          isHorizontal: false,
        ),
      ];

      final result = GridValidator.validate(placed, 10, 10);
      expect(result.isValid, isTrue, reason: result.errors.toString());
    });

    test('should detect collisions', () {
      final placed = [
        PlacedWord(
          word: const GeneratedWord(answer: 'HELLO', clue: ''),
          startX: 0,
          startY: 2,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'WATER', clue: ''),
          startX: 2,
          startY: 0,
          isHorizontal: false,
        ),
      ];
      // At (2,2): 'L' from HELLO vs 'T' from WATER

      final result = GridValidator.validate(placed, 10, 10);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('Collision')), isTrue);
    });

    test('should detect disconnected islands', () {
      final placed = [
        PlacedWord(
          word: const GeneratedWord(answer: 'HELLO', clue: ''),
          startX: 0,
          startY: 0,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'WORLD', clue: ''),
          startX: 5,
          startY: 5,
          isHorizontal: true,
        ),
      ];

      final result = GridValidator.validate(placed, 10, 10);
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.contains('not fully connected')),
        isTrue,
      );
    });

    test('should detect illegal horizontal adjacency', () {
      // Two words side by side without intersecting
      final placed = [
        PlacedWord(
          word: const GeneratedWord(answer: 'CAT', clue: ''),
          startX: 0,
          startY: 0,
          isHorizontal: true,
        ),
        // DOG starts at (4,0), so CAT ends at (2,0).
        // If we put something at (3,0)? No, let's put them literally touching.
        PlacedWord(
          word: const GeneratedWord(answer: 'DOG', clue: ''),
          startX: 3,
          startY: 0,
          isHorizontal: true,
        ),
      ];
      // CAT is at (0,0), (1,0), (2,0)
      // DOG is at (3,0), (4,0), (5,0)
      // Cell (2,0) and (3,0) are adjacent but not in the same word.

      final result = GridValidator.validate(placed, 10, 10);
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.contains('Illegal horizontal adjacency')),
        isTrue,
      );
    });

    test('should detect illegal vertical adjacency (parallel words)', () {
      final placed = [
        PlacedWord(
          word: const GeneratedWord(answer: 'HELLO', clue: ''),
          startX: 0,
          startY: 0,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'WORLD', clue: ''),
          startX: 0,
          startY: 1, // Directly below HELLO
          isHorizontal: true,
        ),
      ];

      final result = GridValidator.validate(placed, 10, 10);
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.contains('Illegal vertical adjacency')),
        isTrue,
      );
    });

    test('should detect out of bounds', () {
      final placed = [
        PlacedWord(
          word: const GeneratedWord(answer: 'VERYLONGWORD', clue: ''),
          startX: 5,
          startY: 0,
          isHorizontal: true,
        ),
      ];

      final result = GridValidator.validate(placed, 10, 10);
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.contains('exceeds grid dimensions')),
        isTrue,
      );
    });
  });

  group('GridGenerator Strict Validity Integration', () {
    test('Generated puzzles should ALWAYS be valid (100 iterations)', () {
      final generator = GridGenerator(width: 15, height: 15);
      final words =
          [
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
          ].map((w) => GeneratedWord(answer: w, clue: 'Clue')).toList();

      for (var i = 0; i < 100; i++) {
        final result = generator.generate(words, attempts: 20);
        if (result.isEmpty) {
          continue;
        }

        final validation = GridValidator.validate(result, 15, 15);
        expect(
          validation.isValid,
          isTrue,
          reason:
              'Iteration $i failed: ${validation.errors}\n'
              'Words placed: ${result.length}\n'
              '${_renderGrid(result, 15, 15)}',
        );
      }
    });
  });
}

String _renderGrid(List<PlacedWord> placed, int width, int height) {
  final grid = List.generate(height, (_) => List<String>.filled(width, '.'));
  for (final pw in placed) {
    for (var i = 0; i < pw.word.answer.length; i++) {
      final x = pw.isHorizontal ? pw.startX + i : pw.startX;
      final y = pw.isHorizontal ? pw.startY : pw.startY + i;
      grid[y][x] = pw.word.answer[i];
    }
  }
  return grid.map((row) => row.join(' ')).join('\n');
}
