import 'package:croiz/features/generation/data/generated_puzzles_repository.dart';
import 'package:croiz/features/generation/models/generated_word.dart';
import 'package:croiz/features/generation/services/gemini_service.dart';
import 'package:croiz/features/generation/services/fill_dictionary_service.dart';
import 'package:croiz/features/generation/services/generation_orchestrator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockGeminiPuzzleService extends Mock implements GeminiPuzzleService {}

class MockGeneratedPuzzlesRepository extends Mock
    implements GeneratedPuzzlesRepository {}

class MockFillDictionaryService extends Mock implements FillDictionaryService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GeneratedWord(answer: '', clue: ''));
  });

  group('PuzzleGenerationOrchestrator', () {
    late MockGeminiPuzzleService mockGeminiService;
    late MockGeneratedPuzzlesRepository mockRepository;
    late MockFillDictionaryService mockFillService;
    late ProviderContainer container;

    // Create a very robust dictionary of words of all lengths (2 to 10)
    // to ensure the CSP solver can ALWAYS find a word for any slot.
    final robustWords = <GeneratedWord>[];
    for (var len = 2; len <= 10; len++) {
      for (var i = 0; i < 5; i++) {
        final word = String.fromCharCodes(
          Iterable.generate(len, (_) => 65 + len),
        ); // AAAA, BBBB, etc.
        robustWords.add(GeneratedWord(answer: word, clue: 'Clue for $word'));
      }
    }

    final robustFill = <String>[];
    for (var len = 2; len <= 10; len++) {
      for (var i = 0; i < 20; i++) {
        robustFill.add(
          String.fromCharCodes(Iterable.generate(len, (_) => 88)),
        ); // XXXX
      }
    }

    setUp(() {
      mockGeminiService = MockGeminiPuzzleService();
      mockRepository = MockGeneratedPuzzlesRepository();
      mockFillService = MockFillDictionaryService();

      container = ProviderContainer(
        overrides: [
          geminiPuzzleServiceProvider.overrideWithValue(mockGeminiService),
          generatedPuzzlesRepositoryProvider.overrideWithValue(mockRepository),
          fillDictionaryServiceProvider.overrideWithValue(mockFillService),
        ],
      );

      when(
        () => mockFillService.loadDictionary(any()),
      ).thenAnswer((_) async => robustFill);

      when(
        () => mockGeminiService.generateClues(
          words: any(named: 'words'),
          language: any(named: 'language'),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) async => []);
    });

    tearDown(() {
      container.dispose();
    });

    group('generateAndSave', () {
      test('should generate and save a puzzle successfully', () async {
        when(
          () => mockGeminiService.generateWords(
            topic: any(named: 'topic'),
            language: any(named: 'language'),
            difficultyLevel: any(named: 'difficultyLevel'),
            count: any(named: 'count'),
          ),
        ).thenAnswer((_) async => robustWords);

        when(
          () => mockRepository.savePuzzle(any()),
        ).thenAnswer((_) async => {});

        final orchestrator = container.read(
          puzzleGenerationOrchestratorProvider,
        );

        // Fixed seed ensures deterministic generation even with a small dictionary
        final puzzleId = await orchestrator.generateAndSave(
          topic: 'Test',
          language: 'en',
          size: 7,
          seed: 42,
        );
        expect(puzzleId, isNotEmpty);
      });

      test('should create valid puzzle JSON structure', () async {
        when(
          () => mockGeminiService.generateWords(
            topic: any(named: 'topic'),
            language: any(named: 'language'),
            difficultyLevel: any(named: 'difficultyLevel'),
            count: any(named: 'count'),
          ),
        ).thenAnswer((_) async => robustWords);

        when(
          () => mockRepository.savePuzzle(any()),
        ).thenAnswer((_) async => {});

        final orchestrator = container.read(
          puzzleGenerationOrchestratorProvider,
        );
        await orchestrator.generateAndSave(
          topic: 'Test',
          language: 'en',
          size: 7,
          seed: 42,
        );

        final captured =
            verify(() => mockRepository.savePuzzle(captureAny())).captured;
        final savedPuzzle = captured.last as Map<String, dynamic>;
        expect(savedPuzzle['rows'], 7);
      });
    });
  });
}
