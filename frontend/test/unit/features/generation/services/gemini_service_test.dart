import 'dart:convert';
import 'package:croiz/core/exceptions/user_friendly_exception.dart';
import 'package:croiz/features/generation/services/gemini_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGeminiClient extends Mock implements GeminiClient {}

void main() {
  group('GeminiPuzzleService', () {
    late MockGeminiClient mockClient;
    late GeminiPuzzleService service;

    setUp(() {
      mockClient = MockGeminiClient();
      service = GeminiPuzzleService(client: mockClient);
    });

    group('generateWords', () {
      test('should return a list of words on success', () async {
        final jsonResponse = jsonEncode([
          {'word': 'APPLE', 'clue': 'A fruit'},
          {'word': 'BANANA', 'clue': 'Another fruit'},
        ]);

        when(
          () => mockClient.generateContent(any()),
        ).thenAnswer((_) async => jsonResponse);

        final result = await service.generateWords(
          topic: 'Fruit',
          language: 'en',
        );

        expect(result, hasLength(2));
        expect(result[0].answer, 'APPLE');
        expect(result[1].answer, 'BANANA');
      });

      test(
        'should throw UserFriendlyException when response is null',
        () async {
          when(
            () => mockClient.generateContent(any()),
          ).thenAnswer((_) async => null);

          expect(
            () => service.generateWords(topic: 'Test', language: 'en'),
            throwsA(
              isA<UserFriendlyException>().having(
                (e) => e.userMessage,
                'userMessage',
                contains('Unable to generate puzzle'),
              ),
            ),
          );
        },
      );

      test('should handle generic errors', () async {
        when(
          () => mockClient.generateContent(any()),
        ).thenThrow(Exception('test error'));

        expect(
          () => service.generateWords(topic: 'Test', language: 'en'),
          throwsA(
            isA<UserFriendlyException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('Unable to generate puzzle'),
            ),
          ),
        );
      });

      test('should handle service errors (firebase/api/etc)', () async {
        when(
          () => mockClient.generateContent(any()),
        ).thenThrow(Exception('firebase_ai: permission denied'));

        expect(
          () => service.generateWords(topic: 'Test', language: 'en'),
          throwsA(
            isA<UserFriendlyException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('Service temporarily unavailable'),
            ),
          ),
        );
      });
    });

    group('parseResponse', () {
      test('should parse valid JSON', () {
        final jsonResponse = jsonEncode([
          {'word': 'APPLE', 'clue': 'A fruit'},
        ]);

        final result = service.parseResponse(jsonResponse);

        expect(result, hasLength(1));
        expect(result[0].answer, 'APPLE');
      });

      test('should handle markdown-wrapped JSON (```json)', () {
        const jsonResponse =
            '```json\n[{"word": "CAR", "clue": "Vehicle"}]\n```';
        final result = service.parseResponse(jsonResponse);
        expect(result, hasLength(1));
        expect(result[0].answer, 'CAR');
      });

      test('should throw UserFriendlyException on invalid JSON', () {
        expect(
          () => service.parseResponse('invalid json'),
          throwsA(
            isA<UserFriendlyException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('An error occurred during generation'),
            ),
          ),
        );
      });
    });

    group('buildPrompt', () {
      test('should include topic and count', () {
        final prompt = service.buildPrompt('Space', 'en', 10, 3);
        expect(prompt, contains('topic: "Space"'));
        expect(prompt, contains('list of 10 distinct'));
      });

      test('should include difficulty instructions for all levels', () {
        for (var i = 1; i <= 5; i++) {
          final prompt = service.buildPrompt('Test', 'en', 10, i);
          expect(prompt, contains('Difficulty Level: $i/5'));
        }
      });
    });
  });
}
