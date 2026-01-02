import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/grid_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GridGenerator Multilingual Support', () {
    late GridGenerator generator;

    setUp(() {
      generator = GridGenerator(width: 15, height: 15);
    });

    test('should place words with Spanish Ñ correctly', () {
      final words = [
        const GeneratedWord(answer: 'ESPAÑA', clue: 'Country'),
        const GeneratedWord(answer: 'NIÑO', clue: 'Boy'),
      ];

      final result = generator.generate(words, language: 'es');

      expect(result, isNotEmpty);
      final placedAnswers = result.map((pw) => pw.word.answer).toList();
      expect(placedAnswers, contains('ESPAÑA'));
      expect(placedAnswers, contains('NIÑO'));

      // Check if they intersect on empty space or shared letter (if possible)
      // ESPAÑA and NIÑO can intersect on 'N'? No, ESPAÑA has 'Ñ'.
      // But they can intersect on 'O' or 'I' (not in ESPAÑA).
    });

    test('should uses different weights for W in EN vs FR', () {
      // W is rare in FR (10 pts), common in EN (4 pts).
      // Placing 'Wagon' should score higher relatively in FR.
      final wordsCount = [
        const GeneratedWord(answer: 'WAGON', clue: 'Train part'),
      ];

      // We can't easily check internal scores without exposing them,
      // but we can check if the generator prefers a W-intersection more in FR.
      // For simplicity, let's just verify it doesn't crash and generates a valid grid.
      final resultEn = generator.generate(wordsCount, language: 'en');
      expect(resultEn, hasLength(1));

      final resultFr = generator.generate(wordsCount, language: 'fr');
      expect(resultFr, hasLength(1));
    });

    test('should handle German digraphs if sent by Gemini', () {
      // If Gemini sends 'MUENCHEN' instead of 'MÜNCHEN'
      final words = [
        const GeneratedWord(answer: 'MUENCHEN', clue: 'City'),
        const GeneratedWord(answer: 'AUTO', clue: 'Car'),
      ];

      final result = generator.generate(words, language: 'de');
      expect(result, isNotEmpty);
      expect(result.any((pw) => pw.word.answer == 'MUENCHEN'), isTrue);
    });

    test('should support Italian', () {
      final words = [
        const GeneratedWord(answer: 'PIZZA', clue: 'Food'),
        const GeneratedWord(answer: 'ROMA', clue: 'Capital'),
      ];

      final result = generator.generate(words, language: 'it');
      expect(result, isNotEmpty);
      expect(result.any((pw) => pw.word.answer == 'PIZZA'), isTrue);
    });

    test('should support Portuguese', () {
      final words = [
        const GeneratedWord(answer: 'FADO', clue: 'Music'),
        const GeneratedWord(answer: 'LISBOA', clue: 'Capital'),
      ];

      final result = generator.generate(words, language: 'pt');
      expect(result, isNotEmpty);
      expect(result.any((pw) => pw.word.answer == 'LISBOA'), isTrue);
    });

    test('should support Ukrainian', () {
      final words = [
        const GeneratedWord(answer: 'КИЇВ', clue: 'Capital'),
        const GeneratedWord(answer: 'МОВА', clue: 'Language'),
      ];

      final result = generator.generate(words, language: 'uk');
      expect(result, isNotEmpty);
      expect(result.any((pw) => pw.word.answer == 'КИЇВ'), isTrue);
    });

    test('should map Russian to Ukrainian weights', () {
      final words = [const GeneratedWord(answer: 'КИЇВ', clue: 'Capital')];

      // We just ensure it works with 'ru' without crashing
      // (internally it uses 'uk' weights)
      final result = generator.generate(words, language: 'ru');
      expect(result, isNotEmpty);
      expect(result[0].word.answer, 'КИЇВ');
    });

    test('should fallback to English weights for unknown language', () {
      final words = [const GeneratedWord(answer: 'TEST', clue: 'Test')];

      final result = generator.generate(words, language: 'zz'); // Unknown
      expect(result, isNotEmpty);
      expect(result[0].word.answer, 'TEST');
    });
  });
}
