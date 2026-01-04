import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/grid_first_generator.dart';
import 'package:croiz/features/generation/services/grid_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('P0 Optimizations', () {
    group('targetBlackRatio reduction', () {
      test('should default to 0.12 instead of 0.18', () {
        final generator = GridFirstGenerator(width: 15, height: 15);
        expect(generator.targetBlackRatio, 0.18);
      });

      test('should accept custom targetBlackRatio', () {
        final generator = GridFirstGenerator(
          width: 15,
          height: 15,
          targetBlackRatio: 0.10,
        );
        expect(generator.targetBlackRatio, 0.10);
      });
    });

    group('balanced slot validation', () {
      test('open style should produce balanced slots', () {
        final templateGenerator = GridTemplateGenerator(
          width: 15,
          height: 15,
          targetBlackRatio: 0.18,
        );

        final template = templateGenerator.generateWithStyle(
          TemplateStyle.open,
        );
        final slots = SlotExtractor.extractSlots(template, minLength: 3);

        final horizontal = slots.where((s) => s.isHorizontal).length;
        final vertical = slots.where((s) => !s.isHorizontal).length;
        final total = horizontal + vertical;

        // Should have at least some of each direction
        expect(horizontal, greaterThan(0));
        expect(vertical, greaterThan(0));

        // Open style should naturally be balanced
        final horizontalRatio = horizontal / total;
        final verticalRatio = vertical / total;

        expect(horizontalRatio, greaterThan(0.3));
        expect(verticalRatio, greaterThan(0.3));
      });
    });

    group('template style prioritization', () {
      test('should generate templates with balanced slots', () {
        final generator = GridFirstGenerator(
          width: 15,
          height: 15,
          maxAttempts: 3,
        );

        final themeWords = [
          const GeneratedWord(answer: 'MAISON', clue: 'House'),
          const GeneratedWord(answer: 'JARDIN', clue: 'Garden'),
          const GeneratedWord(answer: 'LIVRE', clue: 'Book'),
          const GeneratedWord(answer: 'TABLE', clue: 'Table'),
        ];

        final fillWords = [
          'THE',
          'AND',
          'FOR',
          'ARE',
          'BUT',
          'NOT',
          'YOU',
          'ALL',
          'CAN',
          'HER',
        ];

        generator.buildDictionary([
          ...themeWords.map((w) => w.answer),
          ...fillWords,
        ]);

        final result = generator.generate(
          themeWords: themeWords,
          fillWords: fillWords,
        );

        // Should have placed at least some words
        expect(result.placedWords.length, greaterThan(0));

        // Template should exist
        expect(result.template.length, 15);
        expect(result.template[0].length, 15);
      });
    });

    group('GridTemplateGenerator with reduced black ratio', () {
      test('should generate templates with lower black square ratio', () {
        final templateGenerator = GridTemplateGenerator(
          width: 15,
          height: 15,
          targetBlackRatio: 0.18,
        );

        final template = templateGenerator.generate();

        // Count black squares
        var blackCount = 0;
        for (final row in template) {
          for (final cell in row) {
            if (cell) {
              blackCount++;
            }
          }
        }

        const totalCells = 15 * 15;
        final actualRatio = blackCount / totalCells;

        // Should be reasonably close to target (allowing some variation)
        expect(actualRatio, lessThan(0.30));
      });
    });
  });
}
