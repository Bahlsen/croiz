import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeneratedWord', () {
    group('fromJson', () {
      test('should parse valid JSON with word field', () {
        const jsonData = {'word': 'PARIS', 'clue': 'Capital of France'};

        final word = GeneratedWord.fromJson(jsonData);

        expect(word.answer, 'PARIS');
        expect(word.clue, 'Capital of France');
      });

      test('should parse valid JSON with answer field', () {
        const jsonData = {'answer': 'LYON', 'clue': 'Second largest city'};

        final word = GeneratedWord.fromJson(jsonData);

        expect(word.answer, 'LYON');
        expect(word.clue, 'Second largest city');
      });

      test('should normalize to uppercase', () {
        const jsonData = {'word': 'paris', 'clue': 'Capital'};

        final word = GeneratedWord.fromJson(jsonData);

        expect(word.answer, 'PARIS');
      });

      test('should trim whitespace from answer and clue', () {
        const jsonData = {'word': '  PARIS  ', 'clue': '  Capital  '};

        final word = GeneratedWord.fromJson(jsonData);

        expect(word.answer, 'PARIS');
        expect(word.clue, 'Capital');
      });

      test('should handle empty clue', () {
        const jsonData = {'word': 'TEST', 'clue': ''};

        final word = GeneratedWord.fromJson(jsonData);

        expect(word.answer, 'TEST');
        expect(word.clue, '');
      });

      test('should handle missing word and answer fields', () {
        const jsonData = {'clue': 'Some clue'};

        final word = GeneratedWord.fromJson(jsonData);

        expect(word.answer, ''); // Falls back to empty string
        expect(word.clue, 'Some clue');
      });

      test('should handle missing clue field', () {
        const jsonData = {'word': 'TEST'};

        final word = GeneratedWord.fromJson(jsonData);

        expect(word.answer, 'TEST');
        expect(word.clue, '');
      });

      test('should prefer word field over answer field', () {
        const jsonData = {'word': 'WORD', 'answer': 'ANSWER', 'clue': 'Test'};

        final word = GeneratedWord.fromJson(jsonData);

        expect(word.answer, 'WORD');
      });
    });

    group('constructor', () {
      test('should create word with answer and clue', () {
        const word = GeneratedWord(answer: 'HELLO', clue: 'Greeting');

        expect(word.answer, 'HELLO');
        expect(word.clue, 'Greeting');
      });

      test('should be immutable', () {
        const word1 = GeneratedWord(answer: 'TEST', clue: 'Exam');
        const word2 = GeneratedWord(answer: 'TEST', clue: 'Exam');

        expect(word1.answer, word2.answer);
        expect(word1.clue, word2.clue);
      });
    });
  });
}
