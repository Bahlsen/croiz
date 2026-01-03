import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/grid_generator.dart';
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
      final analysis = analyzeGridStructure(placedWords, 12, 15);

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
      final analysis = analyzeGridStructure(placedWords, 10, 10);

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
      final analysis = analyzeGridStructure(placedWords, 10, 10);

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
      final analysis = analyzeGridStructure(placedWords, 20, 10);

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
      final analysis = analyzeGridStructure(placedWords, 10, 10);

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
      final analysis = analyzeGridStructure(placedWords, 10, 10);

      // Assert
      expect(analysis.minIntersectionsPerWord, greaterThanOrEqualTo(1));
    });
  });

  group('Grid Quality Validation - GridGenerator Integration', () {
    // A set of highly interconnectable words (lots of E, A, R, S, T, L)
    // This ensures that any failure is due to the algorithm, not poor word choice.
    final highConnectivityWords = [
      const GeneratedWord(answer: 'EAST', clue: 'Direction'),
      const GeneratedWord(answer: 'SEAT', clue: 'Chair'),
      const GeneratedWord(answer: 'TEAS', clue: 'Drinks'),
      const GeneratedWord(answer: 'EATS', clue: 'Consumes'),
      const GeneratedWord(answer: 'REST', clue: 'Relax'),
      const GeneratedWord(answer: 'TEST', clue: 'Exam'),
      const GeneratedWord(answer: 'RATE', clue: 'Speed'),
      const GeneratedWord(answer: 'TEAR', clue: 'Rip'),
      const GeneratedWord(answer: 'EARS', clue: 'Hearing'),
      const GeneratedWord(answer: 'AREA', clue: 'Region'),
      const GeneratedWord(answer: 'ARTS', clue: 'Crafts'),
      const GeneratedWord(answer: 'STAR', clue: 'Celestial body'),
      const GeneratedWord(answer: 'SALE', clue: 'Discount'),
      const GeneratedWord(answer: 'LESS', clue: 'Fewer'),
      const GeneratedWord(answer: 'ELSE', clue: 'Otherwise'),
    ];

    // Regression Test: Diversity Bonus + Anti-Spine Penalty ensures no spine
    test('generated grid should NOT have spine pattern', () {
      // Arrange
      final generator = GridGenerator(width: 15, height: 15);
      final words = highConnectivityWords; // Use good words

      // Act
      final result = generator.generate(words);
      final analysis = analyzeGridStructure(result, 15, 15);

      // Assert
      if (result.length >= 5) {
        expect(
          analysis.hasSpinePattern,
          isFalse,
          reason: 'Generated puzzle should not have a spine pattern: $analysis',
        );
      }
    });

    // Regression Test: Diversity Bonus helps balance orientation
    test('generated grid should have balanced orientation', () {
      // Arrange
      final generator = GridGenerator(width: 15, height: 15);
      final words = highConnectivityWords; // Use good words

      // Act
      final result = generator.generate(words);
      final analysis = analyzeGridStructure(result, 15, 15);

      // Assert
      if (result.length >= 6) {
        // Allow some imbalance but not extreme (max 3:1 ratio)
        expect(
          analysis.orientationRatio,
          lessThanOrEqualTo(3.0),
          reason:
              'Orientation should be balanced: ${analysis.horizontalCount}H vs ${analysis.verticalCount}V',
        );
      }
    });

    // Regression Test: Better connectivity through diversity bonus
    test('generated grid should not have isolated words', () {
      // Arrange
      final generator = GridGenerator(width: 15, height: 15);
      final words = highConnectivityWords; // Use good words

      // Act
      final result = generator.generate(words);
      final analysis = analyzeGridStructure(result, 15, 15);

      // Assert
      // First word is always allowed to be "isolated" as the anchor
      if (result.length >= 3) {
        expect(
          analysis.isolatedWordCount,
          lessThanOrEqualTo(1),
          reason: 'Only the first word can be isolated (as anchor)',
        );
      }
    });

    // Regression Test: Better intersection distribution
    test('generated grid should have good average intersections', () {
      // Arrange
      final generator = GridGenerator(width: 15, height: 15);
      final words = highConnectivityWords; // Use good words

      // Act
      final result = generator.generate(words);
      final metrics = GridQualityCalculator.calculate(
        placedWords: result,
        gridWidth: 15,
        gridHeight: 15,
        totalWordsAttempted: words.length,
      );

      // Assert
      if (result.length >= 4) {
        expect(
          metrics.avgIntersectionsPerWord,
          greaterThanOrEqualTo(0.7),
          reason:
              'Average intersections should be at least 0.7, got ${metrics.avgIntersectionsPerWord}',
        );
      }
    });
  });
}

/// Analyzes the structural quality of a crossword grid.
GridStructureAnalysis analyzeGridStructure(
  List<PlacedWord> placedWords,
  int gridWidth,
  int gridHeight,
) {
  if (placedWords.isEmpty) {
    return const GridStructureAnalysis.empty();
  }

  // Count orientations
  final horizontalWords = placedWords.where((pw) => pw.isHorizontal).toList();
  final verticalWords = placedWords.where((pw) => !pw.isHorizontal).toList();

  // Build cell map for intersection detection
  final horizontalCells = <String, List<PlacedWord>>{};
  final verticalCells = <String, List<PlacedWord>>{};

  for (final pw in placedWords) {
    for (var i = 0; i < pw.word.answer.length; i++) {
      final x = pw.isHorizontal ? pw.startX + i : pw.startX;
      final y = pw.isHorizontal ? pw.startY : pw.startY + i;
      final key = '$x,$y';

      if (pw.isHorizontal) {
        horizontalCells.putIfAbsent(key, () => []).add(pw);
      } else {
        verticalCells.putIfAbsent(key, () => []).add(pw);
      }
    }
  }

  // Find intersection cells
  final intersectionCells = horizontalCells.keys.toSet().intersection(
    verticalCells.keys.toSet(),
  );
  final totalIntersections = intersectionCells.length;

  // Count intersections per word
  final wordIntersections = <PlacedWord, int>{};
  for (final pw in placedWords) {
    var count = 0;
    for (var i = 0; i < pw.word.answer.length; i++) {
      final x = pw.isHorizontal ? pw.startX + i : pw.startX;
      final y = pw.isHorizontal ? pw.startY : pw.startY + i;
      final key = '$x,$y';

      if (intersectionCells.contains(key)) {
        count++;
      }
    }
    wordIntersections[pw] = count;
  }

  // Detect spine pattern: one word has >70% of intersections
  PlacedWord? spineWord;
  double spineRatio = 0;
  if (totalIntersections > 0) {
    for (final entry in wordIntersections.entries) {
      final ratio = entry.value / totalIntersections;
      if (ratio > spineRatio) {
        spineRatio = ratio;
        spineWord = entry.key;
      }
    }
  }

  // Count isolated words (0 intersections)
  final isolatedWords =
      wordIntersections.entries.where((e) => e.value == 0).length;

  // Find minimum intersections per word
  final minIntersections =
      wordIntersections.values.isEmpty
          ? 0
          : wordIntersections.values.reduce((a, b) => a < b ? a : b);

  return GridStructureAnalysis(
    horizontalCount: horizontalWords.length,
    verticalCount: verticalWords.length,
    totalIntersections: totalIntersections,
    spineWord: spineWord,
    spineIntersectionRatio: spineRatio,
    isolatedWordCount: isolatedWords,
    minIntersectionsPerWord: minIntersections,
    wordIntersections: wordIntersections,
  );
}

/// Analysis result for grid structure quality.
class GridStructureAnalysis {
  const GridStructureAnalysis({
    required this.horizontalCount,
    required this.verticalCount,
    required this.totalIntersections,
    required this.spineWord,
    required this.spineIntersectionRatio,
    required this.isolatedWordCount,
    required this.minIntersectionsPerWord,
    required this.wordIntersections,
  });

  const GridStructureAnalysis.empty()
    : horizontalCount = 0,
      verticalCount = 0,
      totalIntersections = 0,
      spineWord = null,
      spineIntersectionRatio = 0,
      isolatedWordCount = 0,
      minIntersectionsPerWord = 0,
      wordIntersections = const {};

  final int horizontalCount;
  final int verticalCount;
  final int totalIntersections;
  final PlacedWord? spineWord;
  final double spineIntersectionRatio;
  final int isolatedWordCount;
  final int minIntersectionsPerWord;
  final Map<PlacedWord, int> wordIntersections;

  /// Has spine pattern when one word has >70% of all intersections
  bool get hasSpinePattern =>
      spineIntersectionRatio > 0.7 && totalIntersections >= 3;

  String? get spineWordAnswer => spineWord?.word.answer;

  /// Orientation is unbalanced when ratio is >3:1
  bool get isOrientationUnbalanced {
    if (horizontalCount == 0 && verticalCount == 0) {
      return false;
    }
    return orientationRatio > 3.0;
  }

  double get orientationRatio {
    if (horizontalCount == 0 && verticalCount == 0) {
      return 1;
    }
    if (horizontalCount == 0 || verticalCount == 0) {
      return (horizontalCount + verticalCount).toDouble();
    }
    final max =
        horizontalCount > verticalCount ? horizontalCount : verticalCount;
    final min =
        horizontalCount < verticalCount ? horizontalCount : verticalCount;
    return max / min;
  }

  /// Has isolated words if any word has 0 intersections
  bool get hasIsolatedWords => isolatedWordCount > 0;

  @override
  String toString() => '''
GridStructureAnalysis(
  horizontal: $horizontalCount, vertical: $verticalCount,
  orientationRatio: ${orientationRatio.toStringAsFixed(2)},
  totalIntersections: $totalIntersections,
  spineWord: ${spineWordAnswer ?? 'none'}, spineRatio: ${(spineIntersectionRatio * 100).toStringAsFixed(1)}%,
  isolatedWords: $isolatedWordCount,
  minIntersections: $minIntersectionsPerWord
)''';
}
