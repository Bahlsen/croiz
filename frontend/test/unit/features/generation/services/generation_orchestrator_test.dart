import 'package:croiz/core/exceptions/user_friendly_exception.dart';
import 'package:croiz/features/generation/data/generated_puzzles_repository.dart';
import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/gemini_service.dart';
import 'package:croiz/features/generation/services/generation_orchestrator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockGeminiPuzzleService extends Mock implements GeminiPuzzleService {}

class MockGeneratedPuzzlesRepository extends Mock
    implements GeneratedPuzzlesRepository {}

void main() {
  group('PuzzleGenerationOrchestrator', () {
    late MockGeminiPuzzleService mockGeminiService;
    late MockGeneratedPuzzlesRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockGeminiService = MockGeminiPuzzleService();
      mockRepository = MockGeneratedPuzzlesRepository();

      container = ProviderContainer(
        overrides: [
          geminiPuzzleServiceProvider.overrideWithValue(mockGeminiService),
          generatedPuzzlesRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('generateAndSave', () {
      test('should generate and save a puzzle successfully', () async {
        // Arrange
        final words = [
          const GeneratedWord(answer: 'FRANCE', clue: 'European country'),
          const GeneratedWord(answer: 'PARIS', clue: 'Capital'),
          const GeneratedWord(answer: 'LYON', clue: 'Second city'),
          const GeneratedWord(answer: 'NICE', clue: 'Coastal city'),
          const GeneratedWord(answer: 'CAFE', clue: 'Coffee shop'),
          const GeneratedWord(answer: 'WINE', clue: 'Beverage'),
        ];

        when(
          () => mockGeminiService.generateWords(
            topic: any(named: 'topic'),
            language: any(named: 'language'),
            difficultyLevel: any(named: 'difficultyLevel'),
            count: any(named: 'count'),
          ),
        ).thenAnswer((_) async => words);

        when(
          () => mockRepository.savePuzzle(any()),
        ).thenAnswer((_) async => {});

        final orchestrator = container.read(
          puzzleGenerationOrchestratorProvider,
        );

        // Act
        final puzzleId = await orchestrator.generateAndSave(
          topic: 'France',
          language: 'fr',
          difficulty: 2,
          size: 15,
        );

        // Assert
        expect(puzzleId, isNotEmpty);

        // Verify Gemini was called with correct parameters
        verify(
          () => mockGeminiService.generateWords(
            topic: 'France',
            language: 'fr',
            difficultyLevel: 2,
            count: 30, // size * 2
          ),
        ).called(1);

        // Verify puzzle was saved
        final captured = verify(
          () => mockRepository.savePuzzle(captureAny()),
        ).captured;
        expect(captured, hasLength(1));

        final savedPuzzle = captured.first as Map<String, dynamic>;
        expect(savedPuzzle['id'], puzzleId);
        expect(savedPuzzle['source'], 'local');
        expect(savedPuzzle['metadata']['title'], 'France');
        expect(savedPuzzle['metadata']['language'], 'fr');
        expect(savedPuzzle['metadata']['difficulty'], 2);
        expect(savedPuzzle['metadata']['author'], 'AI');
        expect(savedPuzzle['rows'], 15);
        expect(savedPuzzle['cols'], 15);
        expect(savedPuzzle['cells'], isNotEmpty);
        expect(savedPuzzle['entries'], isNotEmpty);
      });

      test('should throw exception when not enough words generated', () async {
        // Arrange
        final words = [
          const GeneratedWord(answer: 'ONE', clue: 'First'),
          const GeneratedWord(answer: 'TWO', clue: 'Second'),
        ];

        when(
          () => mockGeminiService.generateWords(
            topic: any(named: 'topic'),
            language: any(named: 'language'),
            difficultyLevel: any(named: 'difficultyLevel'),
            count: any(named: 'count'),
          ),
        ).thenAnswer((_) async => words);

        final orchestrator = container.read(
          puzzleGenerationOrchestratorProvider,
        );

        // Act & Assert
        expect(
          () => orchestrator.generateAndSave(topic: 'Test', language: 'en'),
          throwsA(
            isA<UserFriendlyException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('Unable to generate enough words'),
            ),
          ),
        );

        // Verify repository was not called
        verifyNever(() => mockRepository.savePuzzle(any()));
      });

      test('should propagate Gemini service errors', () async {
        // Arrange
        when(
          () => mockGeminiService.generateWords(
            topic: any(named: 'topic'),
            language: any(named: 'language'),
            difficultyLevel: any(named: 'difficultyLevel'),
            count: any(named: 'count'),
          ),
        ).thenThrow(Exception('API Error'));

        final orchestrator = container.read(
          puzzleGenerationOrchestratorProvider,
        );

        // Act & Assert
        expect(
          () => orchestrator.generateAndSave(topic: 'Test', language: 'en'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('API Error'),
            ),
          ),
        );

        // Verify repository was not called
        verifyNever(() => mockRepository.savePuzzle(any()));
      });

      test('should create valid puzzle JSON structure', () async {
        // Arrange
        final words = [
          const GeneratedWord(answer: 'HELLO', clue: 'Greeting'),
          const GeneratedWord(answer: 'HELP', clue: 'Assistance'),
          const GeneratedWord(answer: 'WORLD', clue: 'Earth'),
          const GeneratedWord(answer: 'WORD', clue: 'Text unit'),
          const GeneratedWord(answer: 'HOLD', clue: 'Grasp'),
          const GeneratedWord(answer: 'HERO', clue: 'Champion'),
        ];

        when(
          () => mockGeminiService.generateWords(
            topic: any(named: 'topic'),
            language: any(named: 'language'),
            difficultyLevel: any(named: 'difficultyLevel'),
            count: any(named: 'count'),
          ),
        ).thenAnswer((_) async => words);

        when(
          () => mockRepository.savePuzzle(any()),
        ).thenAnswer((_) async => {});

        final orchestrator = container.read(
          puzzleGenerationOrchestratorProvider,
        );

        // Act
        await orchestrator.generateAndSave(
          topic: 'test topic',
          language: 'en',
          difficulty: 3,
          size: 10,
        );

        // Assert
        final captured = verify(
          () => mockRepository.savePuzzle(captureAny()),
        ).captured;
        final savedPuzzle = captured.first as Map<String, dynamic>;

        // Check metadata
        final metadata = savedPuzzle['metadata'] as Map<String, dynamic>;
        expect(metadata['title'], 'Test topic'); // Capitalized
        expect(metadata['author'], 'AI');
        expect(metadata['language'], 'en');
        expect(metadata['difficulty'], 3);
        expect(metadata['difficulty_label'], 'Generated');
        expect(metadata['width'], 10);
        expect(metadata['height'], 10);

        // Check grid structure
        expect(savedPuzzle['rows'], 10);
        expect(savedPuzzle['cols'], 10);
        expect(savedPuzzle['cells'], hasLength(100)); // 10x10 grid

        // Check cells structure
        final cells = savedPuzzle['cells'] as List;
        for (final cell in cells) {
          expect(cell, isA<Map<String, dynamic>>());
          expect(cell, containsPair('x', isA<int>()));
          expect(cell, containsPair('y', isA<int>()));
          expect(cell, containsPair('is_black', isA<bool>()));
        }

        // Check entries
        final entries = savedPuzzle['entries'] as List;
        expect(entries, isNotEmpty);

        for (final entry in entries) {
          expect(entry, isA<Map<String, dynamic>>());
          expect(entry, containsPair('id', isA<String>()));
          expect(entry, containsPair('number', isA<int>()));
          expect(entry, containsPair('direction', isIn(['across', 'down'])));
          expect(entry, containsPair('x', isA<int>()));
          expect(entry, containsPair('y', isA<int>()));
          expect(entry, containsPair('length', isA<int>()));
          expect(entry, containsPair('answer', isA<String>()));
          expect(entry, containsPair('clue', isA<String>()));
        }
      });
    });
  });
}
