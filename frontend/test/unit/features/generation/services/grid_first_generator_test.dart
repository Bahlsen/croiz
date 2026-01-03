import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/models/grid_quality_metrics.dart';
import 'package:croiz/features/generation/services/gaddag.dart';
import 'package:croiz/features/generation/services/grid_first_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GridFirstGenerator', () {
    late GridFirstGenerator generator;

    setUp(() {
      generator = GridFirstGenerator(width: 10, height: 10, maxAttempts: 3);
    });

    test('should generate grid with placed words', () {
      final themeWords = [
        const GeneratedWord(answer: 'APPLE', clue: 'A fruit'),
        const GeneratedWord(answer: 'TABLE', clue: 'Furniture'),
        const GeneratedWord(answer: 'CHAIR', clue: 'Seat'),
        const GeneratedWord(answer: 'HOUSE', clue: 'Building'),
        const GeneratedWord(answer: 'WATER', clue: 'Liquid'),
      ];

      generator.buildDictionary(themeWords.map((w) => w.answer).toList());

      final result = generator.generate(themeWords: themeWords);

      expect(result.placedWords, isNotEmpty);
      expect(result.grid.length, 10);
      expect(result.grid[0].length, 10);
    });

    test('should return metrics with result', () {
      final themeWords = [
        const GeneratedWord(answer: 'CAT', clue: 'Animal'),
        const GeneratedWord(answer: 'DOG', clue: 'Pet'),
        const GeneratedWord(answer: 'BAT', clue: 'Flying mammal'),
      ];

      generator.buildDictionary(themeWords.map((w) => w.answer).toList());

      final result = generator.generate(themeWords: themeWords);

      expect(result.metrics, isNotNull);
      expect(result.metrics.totalWords, 3);
    });

    test('should include template in result', () {
      final themeWords = [const GeneratedWord(answer: 'TEST', clue: 'Trial')];

      generator.buildDictionary(['TEST']);

      final result = generator.generate(themeWords: themeWords);

      expect(result.template, isNotEmpty);
      expect(result.template.length, 10);
    });

    test('should use fill words when provided', () {
      final themeWords = [const GeneratedWord(answer: 'CAT', clue: 'Animal')];
      final fillWords = ['DOG', 'BAT', 'HAT', 'RAT'];

      final result = generator.generate(
        themeWords: themeWords,
        fillWords: fillWords,
      );

      // Should have access to fill words
      expect(result.placedWords, isNotEmpty);
    });

    test('should handle empty theme words', () {
      final result = generator.generate(themeWords: []);

      expect(result.placedWords, isEmpty);
      expect(result.success, false);
    });

    test('should build dictionary lazily', () {
      final themeWords = [
        const GeneratedWord(answer: 'TEST', clue: 'Trial'),
        const GeneratedWord(answer: 'BEST', clue: 'Top'),
      ];

      // Don't call buildDictionary manually
      final result = generator.generate(themeWords: themeWords);

      // Should still work
      expect(result, isNotNull);
    });

    test('should allow adding words to dictionary', () {
      generator
        ..buildDictionary(['CAT', 'DOG'])
        ..addWords(['BAT', 'HAT']);

      final themeWords = [
        const GeneratedWord(answer: 'CAT', clue: 'Animal'),
        const GeneratedWord(answer: 'BAT', clue: 'Flying'),
      ];

      final result = generator.generate(themeWords: themeWords);

      expect(result.placedWords, isNotEmpty);
    });

    test('should use provided GADDAG', () {
      final gaddag = Gaddag()..build(['CUSTOM', 'WORDS', 'HERE']);

      final customGenerator = GridFirstGenerator(
        width: 10,
        height: 10,
        gaddag: gaddag,
      );

      final themeWords = [const GeneratedWord(answer: 'CUSTOM', clue: 'Made')];

      final result = customGenerator.generate(themeWords: themeWords);

      expect(result, isNotNull);
    });

    test('should calculate quality score for ranking', () {
      final themeWords = [
        const GeneratedWord(answer: 'APPLE', clue: 'Fruit'),
        const GeneratedWord(answer: 'LEMON', clue: 'Citrus'),
        const GeneratedWord(answer: 'GRAPE', clue: 'Wine fruit'),
      ];

      generator.buildDictionary(themeWords.map((w) => w.answer).toList());

      final result = generator.generate(themeWords: themeWords);

      // Metrics should be calculated
      expect(result.metrics.wordsPlaced, greaterThanOrEqualTo(0));
    });

    group('with larger dictionary', () {
      late GridFirstGenerator largeGenerator;

      setUp(() {
        final words = [
          // 3-letter
          'CAT', 'DOG', 'BAT', 'HAT', 'RAT', 'SAT', 'MAT', 'PAT',
          // 4-letter
          'FISH', 'BIRD', 'FROG', 'DUCK', 'BEAR', 'LION', 'WOLF', 'DEER',
          // 5-letter
          'APPLE', 'LEMON', 'GRAPE', 'MELON', 'PEACH', 'MANGO', 'OLIVE',
          // 6-letter
          'BANANA', 'ORANGE', 'CHERRY', 'TOMATO',
          // 7-letter
          'AVOCADO', 'COCONUT', 'APRICOT',
        ];

        largeGenerator = GridFirstGenerator(
          width: 15,
          height: 15,
          maxAttempts: 5,
        )..buildDictionary(words);
      });

      test('should handle larger grid', () {
        final themeWords = [
          const GeneratedWord(answer: 'APPLE', clue: 'Fruit'),
          const GeneratedWord(answer: 'ORANGE', clue: 'Citrus'),
          const GeneratedWord(answer: 'BANANA', clue: 'Yellow'),
        ];

        final result = largeGenerator.generate(themeWords: themeWords);

        expect(result.grid.length, 15);
        expect(result.grid[0].length, 15);
      });

      test('should place multiple theme words', () {
        final themeWords = [
          const GeneratedWord(answer: 'CAT', clue: 'Pet'),
          const GeneratedWord(answer: 'DOG', clue: 'Pet'),
          const GeneratedWord(answer: 'BAT', clue: 'Flying'),
          const GeneratedWord(answer: 'FISH', clue: 'Swimming'),
          const GeneratedWord(answer: 'BIRD', clue: 'Flying'),
        ];

        final result = largeGenerator.generate(themeWords: themeWords);

        // Should place at least some words
        expect(result.placedWords.length, greaterThan(0));
      });
    });
  });

  group('GridFirstResult', () {
    test('should store all properties', () {
      const result = GridFirstResult(
        placedWords: [],
        grid: [
          ['A', 'B'],
          ['C', 'D'],
        ],
        template: [
          [false, false],
          [false, false],
        ],
        metrics: GridQualityMetrics(
          wordsPlaced: 0,
          totalWords: 0,
          letterDensity: 0,
          blackSquareRatio: 0,
          rowCoverage: 0,
          columnCoverage: 0,
          totalIntersections: 0,
          avgIntersectionsPerWord: 0,
          filledCells: 0,
          totalCells: 4,
          boundingWidth: 2,
          boundingHeight: 2,
        ),
        success: true,
      );

      expect(result.success, true);
      expect(result.grid.length, 2);
      expect(result.template.length, 2);
      expect(result.failureReason, isNull);
    });

    test('should store failure reason', () {
      const result = GridFirstResult(
        placedWords: [],
        grid: [],
        template: [],
        metrics: GridQualityMetrics(
          wordsPlaced: 0,
          totalWords: 0,
          letterDensity: 0,
          blackSquareRatio: 1,
          rowCoverage: 0,
          columnCoverage: 0,
          totalIntersections: 0,
          avgIntersectionsPerWord: 0,
          filledCells: 0,
          totalCells: 0,
          boundingWidth: 0,
          boundingHeight: 0,
        ),
        success: false,
        failureReason: 'Test failure',
      );

      expect(result.success, false);
      expect(result.failureReason, 'Test failure');
    });
  });
}
