import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/models/placed_word.dart';
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
}
