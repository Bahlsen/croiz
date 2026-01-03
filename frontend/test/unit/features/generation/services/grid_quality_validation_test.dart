import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/models/placed_word.dart';
import 'package:croiz/features/generation/services/grid_quality_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Grid Quality Validation - Spine Pattern Detection', () {
    test('should detect spine pattern when one word has all intersections', () {
      // Arrange: Create a "spine" pattern manually
      // Vertical "spine" word with horizontal words only connecting to it
      final placedWords = <PlacedWord>[
        // Long vertical "spine" word
        PlacedWord(
          word: const GeneratedWord(answer: 'ARCHITECTURE', clue: 'The spine'),
          startX: 5,
          startY: 0,
          isHorizontal: false,
        ),
        // Horizontal words only connecting to the spine
        PlacedWord(
          word: const GeneratedWord(answer: 'ARM', clue: 'Clue A'),
          startX: 5,
          startY: 0,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'RAT', clue: 'Clue R'),
          startX: 3,
          startY: 1,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'CAT', clue: 'Clue C'),
          startX: 3,
          startY: 2,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'HAT', clue: 'Clue H'),
          startX: 3,
          startY: 3,
          isHorizontal: true,
        ),
      ];

      // Act: Analyze the structure
      final analysis = GridQualityCalculator.analyzeStructure(placedWords);

      // Assert: Should detect spine pattern
      expect(
        analysis.hasSpinePattern,
        isTrue,
        reason: 'Should detect spine pattern when one word dominates',
      );
      expect(analysis.spineWordAnswer, 'ARCHITECTURE');
      expect(
        analysis.spineIntersectionRatio,
        greaterThan(0.7),
        reason: 'Spine word should have >70% of all intersections',
      );
    });

    test('should accept well-connected crossword without spine', () {
      // Arrange: Create a well-connected grid
      final placedWords = <PlacedWord>[
        // Multiple words forming a dense network
        PlacedWord(
          word: const GeneratedWord(answer: 'PARIS', clue: 'City'),
          startX: 0,
          startY: 0,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'APPLE', clue: 'Fruit'),
          startX: 0,
          startY: 0,
          isHorizontal: false,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'PLANE', clue: 'Aircraft'),
          startX: 0,
          startY: 2,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'ITALY', clue: 'Country'),
          startX: 3,
          startY: 0,
          isHorizontal: false,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'SUPER', clue: 'Great'),
          startX: 1,
          startY: 4,
          isHorizontal: true,
        ),
      ];

      // Act
      final analysis = GridQualityCalculator.analyzeStructure(placedWords);

      // Assert
      expect(
        analysis.hasSpinePattern,
        isFalse,
        reason: 'Well-connected grid should not have spine pattern',
      );
    });

    test('should detect when horizontal-vertical ratio is unbalanced', () {
      // Arrange: Too many horizontal words
      final placedWords = <PlacedWord>[
        PlacedWord(
          word: const GeneratedWord(answer: 'WORD1', clue: 'C1'),
          startX: 0,
          startY: 0,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'VERTICAL', clue: 'C2'),
          startX: 0,
          startY: 0,
          isHorizontal: false,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'WORD2', clue: 'C3'),
          startX: 0,
          startY: 2,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'WORD3', clue: 'C4'),
          startX: 0,
          startY: 4,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'WORD4', clue: 'C5'),
          startX: 0,
          startY: 6,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'WORD5', clue: 'C6'),
          startX: 0,
          startY: 8,
          isHorizontal: true,
        ),
      ];

      // Act
      final analysis = GridQualityCalculator.analyzeStructure(placedWords);

      // Assert
      expect(
        analysis.isOrientationUnbalanced,
        isTrue,
        reason: 'Should detect unbalanced orientation ratio (5:1)',
      );
      expect(analysis.horizontalCount, 5);
      expect(analysis.verticalCount, 1);
    });
  });

  group('Grid Quality Validation - Word Connectivity', () {
    test('should detect isolated words (no intersections)', () {
      // Arrange: Words placed far apart on a big grid
      final placedWords = <PlacedWord>[
        PlacedWord(
          word: const GeneratedWord(answer: 'ISOLATED', clue: 'Alone'),
          startX: 0,
          startY: 0,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'FARAWAY', clue: 'Distant'),
          startX: 0,
          startY: 5,
          isHorizontal: true,
        ),
      ];

      // Act
      final analysis = GridQualityCalculator.analyzeStructure(placedWords);

      // Assert
      expect(analysis.hasIsolatedWords, isTrue);
      expect(
        analysis.isolatedWordCount,
        2,
        reason: 'Both words are isolated from each other',
      );
    });

    test('should accept fully connected grid', () {
      // Arrange: Properly connected words
      final placedWords = <PlacedWord>[
        PlacedWord(
          word: const GeneratedWord(answer: 'CROSS', clue: 'X'),
          startX: 0,
          startY: 2,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'WORD', clue: 'Term'),
          startX: 0,
          startY: 0,
          isHorizontal: false,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'ORDER', clue: 'Sequence'),
          startX: 2,
          startY: 2,
          isHorizontal: false,
        ),
      ];

      // Act
      final analysis = GridQualityCalculator.analyzeStructure(placedWords);

      // Assert
      expect(
        analysis.hasIsolatedWords,
        isFalse,
        reason: 'All words should be connected',
      );
    });

    test('should calculate minimum intersections per word', () {
      // Arrange: Create grid where some words have only 1 intersection
      final placedWords = <PlacedWord>[
        PlacedWord(
          word: const GeneratedWord(answer: 'ANCHOR', clue: 'Ship'),
          startX: 0,
          startY: 0,
          isHorizontal: true,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'ARM', clue: 'Limb'),
          startX: 0,
          startY: 0,
          isHorizontal: false,
        ),
        PlacedWord(
          word: const GeneratedWord(answer: 'NORMAL', clue: 'Ordinary'),
          startX: 1,
          startY: 0,
          isHorizontal: false,
        ),
      ];

      // Act
      final analysis = GridQualityCalculator.analyzeStructure(placedWords);

      // Assert
      expect(analysis.minIntersectionsPerWord, greaterThanOrEqualTo(1));
    });
  });
}
