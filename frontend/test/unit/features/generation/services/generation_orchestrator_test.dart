import 'package:croiz/core/exceptions/user_friendly_exception.dart';
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

    final franceWords = [
      const GeneratedWord(answer: 'FRANCE', clue: 'C'),
      const GeneratedWord(answer: 'PARIS', clue: 'C'),
      const GeneratedWord(answer: 'LYON', clue: 'C'),
      const GeneratedWord(answer: 'NICE', clue: 'C'),
      const GeneratedWord(answer: 'CAFE', clue: 'C'),
      const GeneratedWord(answer: 'WINE', clue: 'C'),
      const GeneratedWord(answer: 'BREAD', clue: 'C'),
      const GeneratedWord(answer: 'CHEESE', clue: 'C'),
      const GeneratedWord(answer: 'EIFFEL', clue: 'C'),
      const GeneratedWord(answer: 'LOUVRE', clue: 'C'),
    ];

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
      ).thenAnswer((_) async => ['THE', 'AND', 'FOR']);

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
        ).thenAnswer((_) async => franceWords);

        when(
          () => mockRepository.savePuzzle(any()),
        ).thenAnswer((_) async => {});

        final orchestrator = container.read(
          puzzleGenerationOrchestratorProvider,
        );
        final puzzleId = await orchestrator.generateAndSave(
          topic: 'F',
          language: 'fr',
          size: 10,
        );
        expect(puzzleId, isNotEmpty);
      });

      test('should throw exception when not enough words generated', () async {
        when(
          () => mockGeminiService.generateWords(
            topic: any(named: 'topic'),
            language: any(named: 'language'),
            difficultyLevel: any(named: 'difficultyLevel'),
            count: any(named: 'count'),
          ),
        ).thenAnswer((_) async => [franceWords[0]]);

        final orchestrator = container.read(
          puzzleGenerationOrchestratorProvider,
        );
        expect(
          orchestrator
              .generateAndSave(topic: 'T', language: 'en')
              .timeout(const Duration(seconds: 5)),
          throwsA(
            isA<UserFriendlyException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('enough words'),
            ),
          ),
        );
      });

      test('should propagate Gemini service errors', () async {
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
        expect(
          orchestrator.generateAndSave(topic: 'T', language: 'en'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('API Error'),
            ),
          ),
        );
      });

      test('should create valid puzzle JSON structure', () async {
        when(
          () => mockGeminiService.generateWords(
            topic: any(named: 'topic'),
            language: any(named: 'language'),
            difficultyLevel: any(named: 'difficultyLevel'),
            count: any(named: 'count'),
          ),
        ).thenAnswer((_) async => franceWords);

        when(
          () => mockRepository.savePuzzle(any()),
        ).thenAnswer((_) async => {});

        final orchestrator = container.read(
          puzzleGenerationOrchestratorProvider,
        );
        await orchestrator.generateAndSave(
          topic: 't',
          language: 'en',
          size: 10,
        );

        final captured =
            verify(() => mockRepository.savePuzzle(captureAny())).captured;
        final savedPuzzle = captured.last as Map<String, dynamic>;
        expect(savedPuzzle['rows'], 10);
      });

      test('should throw exception when no words could be placed', () async {
        final longWords = List.generate(
          10,
          (i) => GeneratedWord(answer: 'AAAAAAAAA' * 10 + '$i', clue: 'L'),
        );

        when(
          () => mockGeminiService.generateWords(
            topic: any(named: 'topic'),
            language: any(named: 'language'),
            difficultyLevel: any(named: 'difficultyLevel'),
            count: any(named: 'count'),
          ),
        ).thenAnswer((_) async => longWords);

        final orchestrator = container.read(
          puzzleGenerationOrchestratorProvider,
        );
        expect(
          orchestrator
              .generateAndSave(topic: 'T', language: 'en', size: 5)
              .timeout(const Duration(seconds: 5)),
          throwsA(
            isA<UserFriendlyException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('create a puzzle grid'),
            ),
          ),
        );
      });

      test('should throw exception when density is too low', () async {
        final crossWords = [
          const GeneratedWord(answer: 'CENTER', clue: 'H'),
          const GeneratedWord(answer: 'CAT', clue: 'V'),
          const GeneratedWord(answer: 'EAT', clue: 'V'),
          const GeneratedWord(answer: 'NET', clue: 'V'),
          const GeneratedWord(answer: 'TEN', clue: 'V'),
          const GeneratedWord(answer: 'ELL', clue: 'V'),
          const GeneratedWord(answer: 'ROT', clue: 'V'),
        ];

        when(
          () => mockGeminiService.generateWords(
            topic: any(named: 'topic'),
            language: any(named: 'language'),
            difficultyLevel: any(named: 'difficultyLevel'),
            count: any(named: 'count'),
          ),
        ).thenAnswer((_) async => crossWords);

        final orchestrator = container.read(
          puzzleGenerationOrchestratorProvider,
        );

        expect(
          orchestrator
              .generateAndSave(topic: 'T', language: 'en', size: 20)
              .timeout(const Duration(seconds: 10)),
          throwsA(
            isA<UserFriendlyException>().having(
              (e) => e.userMessage,
              'userMessage',
              contains('not dense enough'),
            ),
          ),
        );
      });
    });
  });
}
