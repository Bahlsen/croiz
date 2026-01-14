import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/puzzles/puzzle_filter_provider.dart';
import 'package:croiz/features/puzzles/filtered_puzzles_provider.dart';
import 'package:croiz/services/persistence/storage_provider.dart';
import '../../../helpers/fake_puzzle_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Create a list of test puzzles with various difficulties and languages.
  List<PuzzleDescriptor> createTestPuzzles() => [
    PuzzleDescriptor(
      id: 'easy-en',
      title: 'Easy English',
      path: 'test/easy-en.json',
      difficulty: 1,
      difficultyLabel: 'Easy',
      language: 'en',
    ),
    PuzzleDescriptor(
      id: 'medium-en',
      title: 'Medium English',
      path: 'test/medium-en.json',
      difficulty: 2,
      difficultyLabel: 'Medium',
      language: 'en',
    ),
    PuzzleDescriptor(
      id: 'hard-en',
      title: 'Hard English',
      path: 'test/hard-en.json',
      difficulty: 3,
      difficultyLabel: 'Hard',
      language: 'en',
    ),
    PuzzleDescriptor(
      id: 'easy-fr',
      title: 'Easy French',
      path: 'test/easy-fr.json',
      difficulty: 1,
      difficultyLabel: 'Easy',
      language: 'fr',
    ),
    PuzzleDescriptor(
      id: 'medium-fr',
      title: 'Medium French',
      path: 'test/medium-fr.json',
      difficulty: 2,
      difficultyLabel: 'Medium',
      language: 'fr',
    ),
    PuzzleDescriptor(
      id: 'expert-en',
      title: 'Expert English',
      path: 'test/expert-en.json',
      difficulty: 4,
      difficultyLabel: 'Expert',
      language: 'en',
    ),
    PuzzleDescriptor(
      id: 'master-en',
      title: 'Master English',
      path: 'test/master-en.json',
      difficulty: 5,
      difficultyLabel: 'Master',
      language: 'en',
    ),
  ];

  /// Helper to create a ProviderContainer with the required storage override.
  ProviderContainer createContainer(List<PuzzleDescriptor> puzzles) =>
      ProviderContainer(
        overrides: [
          puzzlesProvider.overrideWithValue(AsyncValue.data(puzzles)),
          puzzleStorageProvider.overrideWith((ref) => FakePuzzleStorage()),
        ],
      );

  group('filteredPuzzlesProvider', () {
    test('returns all when no filter active', () {
      final testPuzzles = createTestPuzzles();
      final container = createContainer(testPuzzles);
      addTearDown(container.dispose);

      // Set all difficulties and available languages
      container.read(puzzleFilterProvider.notifier)
        ..setDifficulties({1, 2, 3, 4, 5})
        ..setAvailableLanguages({'en', 'fr'});

      final filtered = container.read(filteredPuzzlesProvider);
      expect(filtered.length, testPuzzles.length);
    });

    test('filters by difficulty', () {
      final testPuzzles = createTestPuzzles();
      final container = createContainer(testPuzzles);
      addTearDown(container.dispose);

      // Set available languages first, and filter to Easy (1) and Medium (2)
      container.read(puzzleFilterProvider.notifier)
        ..setDifficulties({1, 2})
        ..setAvailableLanguages({'en', 'fr'});

      final filtered = container.read(filteredPuzzlesProvider);

      // Should only have Easy and Medium puzzles
      expect(filtered.length, 4); // easy-en, medium-en, easy-fr, medium-fr
      expect(filtered.every((p) => p.difficulty <= 2), isTrue);
    });

    test('filters by language', () {
      final testPuzzles = createTestPuzzles();
      final container = createContainer(testPuzzles);
      addTearDown(container.dispose);

      // Set all difficulties, languages, then filter to French only
      container.read(puzzleFilterProvider.notifier)
        ..setDifficulties({1, 2})
        ..setAvailableLanguages({'en', 'fr'})
        ..toggleLanguage('en', {'en', 'fr'}); // Remove English

      final filtered = container.read(filteredPuzzlesProvider);

      // Should only have French puzzles
      expect(filtered.length, 2); // easy-fr, medium-fr
      expect(filtered.every((p) => p.language == 'fr'), isTrue);
    });

    test('combines difficulty and language filters', () {
      final testPuzzles = createTestPuzzles();
      final container = createContainer(testPuzzles);
      addTearDown(container.dispose);

      // Filter to Easy only, English only
      container.read(puzzleFilterProvider.notifier)
        ..setDifficulties({1})
        ..setAvailableLanguages({'en', 'fr'})
        ..toggleLanguage('fr', {'en', 'fr'});

      final filtered = container.read(filteredPuzzlesProvider);

      // Should only have Easy English
      expect(filtered.length, 1);
      expect(filtered[0].id, 'easy-en');
    });

    test('updates reactively on filter change', () {
      final testPuzzles = createTestPuzzles();
      final container = createContainer(testPuzzles);
      addTearDown(container.dispose);

      // Set all difficulties and available languages first
      container.read(puzzleFilterProvider.notifier)
        ..setDifficulties({1, 2, 3, 4, 5})
        ..setAvailableLanguages({'en', 'fr'});

      // Initially all puzzles
      expect(container.read(filteredPuzzlesProvider).length, 7);

      // Remove Hard difficulty
      container.read(puzzleFilterProvider.notifier).toggleDifficulty(3);

      // Should now have 6 puzzles (no hard-en)
      expect(container.read(filteredPuzzlesProvider).length, 6);
    });

    test('returns empty when no puzzles match filters', () {
      final testPuzzles = createTestPuzzles();
      final container = createContainer(testPuzzles);
      addTearDown(container.dispose);

      // Filter to only Master difficulty, French only
      container.read(puzzleFilterProvider.notifier)
        ..setDifficulties({5})
        ..setAvailableLanguages({'en', 'fr'})
        ..toggleLanguage('en', {'en', 'fr'});

      final filtered = container.read(filteredPuzzlesProvider);

      // No French Master puzzle exists
      expect(filtered.isEmpty, isTrue);
    });

    group('completion status filtering', () {
      test('hides completed puzzles when showCompleted is false', () {
        final testPuzzles = createTestPuzzles();
        final container = ProviderContainer(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(testPuzzles)),
            puzzleStorageProvider.overrideWith((ref) => FakePuzzleStorage()),
            // Mark easy-en and medium-en as completed
            completedPuzzleIdsProvider.overrideWithValue(
              const AsyncValue.data({'easy-en', 'medium-en'}),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Set all difficulties and available languages, hide completed
        container.read(puzzleFilterProvider.notifier)
          ..setDifficulties({1, 2, 3, 4, 5})
          ..setAvailableLanguages({'en', 'fr'})
          ..setShowCompleted(showCompleted: false);

        final filtered = container.read(filteredPuzzlesProvider);

        // Should exclude easy-en and medium-en
        expect(filtered.length, 5);
        expect(filtered.any((p) => p.id == 'easy-en'), isFalse);
        expect(filtered.any((p) => p.id == 'medium-en'), isFalse);
      });

      test('combines completion filter with difficulty filter', () {
        final testPuzzles = createTestPuzzles();
        final container = ProviderContainer(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(testPuzzles)),
            puzzleStorageProvider.overrideWith((ref) => FakePuzzleStorage()),
            // Mark easy-en as completed
            completedPuzzleIdsProvider.overrideWithValue(
              const AsyncValue.data({'easy-en'}),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Filter to Easy only and hide completed
        container.read(puzzleFilterProvider.notifier)
          ..setDifficulties({1})
          ..setAvailableLanguages({'en', 'fr'})
          ..setShowCompleted(showCompleted: false);

        final filtered = container.read(filteredPuzzlesProvider);

        // Only easy-fr should remain (easy-en is completed)
        expect(filtered.length, 1);
        expect(filtered[0].id, 'easy-fr');
      });

      test('returns all uncompleted when completedPuzzleIds is empty', () {
        final testPuzzles = createTestPuzzles();
        final container = ProviderContainer(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(testPuzzles)),
            completedPuzzleIdsProvider.overrideWithValue(
              const AsyncValue.data(<String>{}),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(puzzleFilterProvider.notifier)
          ..setDifficulties({1, 2, 3, 4, 5})
          ..setAvailableLanguages({'en', 'fr'})
          ..setShowCompleted(showCompleted: false);

        final filtered = container.read(filteredPuzzlesProvider);

        // All puzzles should show since none are completed
        expect(filtered.length, 7);
      });

      test('handles loading state for completedPuzzleIds gracefully', () {
        final testPuzzles = createTestPuzzles();
        final container = ProviderContainer(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(testPuzzles)),
            completedPuzzleIdsProvider.overrideWithValue(
              const AsyncValue.loading(),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(puzzleFilterProvider.notifier)
          ..setDifficulties({1, 2, 3, 4, 5})
          ..setAvailableLanguages({'en', 'fr'})
          ..setShowCompleted(showCompleted: false);

        final filtered = container.read(filteredPuzzlesProvider);

        // When loading, show all (don't filter by completion)
        expect(filtered.length, 7);
      });
    });
    group('generated and search filtering', () {
      test('filters generated puzzles only', () {
        final testPuzzles = [
          PuzzleDescriptor(
            id: 'gen-1',
            title: 'Generated 1',
            path: 'test/gen1.json',
            difficulty: 1,
            difficultyLabel: 'Easy',
            language: 'en',
            origin: 'generated',
          ),
          PuzzleDescriptor(
            id: 'ai-1',
            title: 'AI 1',
            path: 'test/ai1.json',
            difficulty: 1,
            difficultyLabel: 'Easy',
            language: 'en',
            origin: 'ai',
          ),
          PuzzleDescriptor(
            id: 'human-1',
            title: 'Human 1',
            path: 'test/human1.json',
            difficulty: 1,
            difficultyLabel: 'Easy',
            language: 'en',
            origin: 'human',
          ),
        ];
        final container = ProviderContainer(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(testPuzzles)),
            puzzleStorageProvider.overrideWith((ref) => FakePuzzleStorage()),
          ],
        );
        addTearDown(container.dispose);

        container.read(puzzleFilterProvider.notifier)
          ..setDifficulties({1})
          ..setAvailableLanguages({'en'})
          ..setShowGeneratedOnly(showGeneratedOnly: true);

        final filtered = container.read(filteredPuzzlesProvider);

        expect(filtered.length, 2);
        expect(filtered.any((p) => p.id == 'gen-1'), isTrue);
        expect(filtered.any((p) => p.id == 'ai-1'), isTrue);
        expect(filtered.any((p) => p.id == 'human-1'), isFalse);
      });

      test('filters by search query', () {
        final testPuzzles = [
          PuzzleDescriptor(
            id: 'p1',
            title: 'Crossword Apple',
            path: 'test/p1.json',
            difficulty: 1,
            difficultyLabel: 'Easy',
            language: 'en',
          ),
          PuzzleDescriptor(
            id: 'p2',
            title: 'Crossword Banana',
            path: 'test/p2.json',
            difficulty: 1,
            difficultyLabel: 'Easy',
            language: 'en',
          ),
        ];
        final container = ProviderContainer(
          overrides: [
            puzzlesProvider.overrideWithValue(AsyncValue.data(testPuzzles)),
            puzzleStorageProvider.overrideWith((ref) => FakePuzzleStorage()),
          ],
        );
        addTearDown(container.dispose);

        container.read(puzzleFilterProvider.notifier)
          ..setDifficulties({1})
          ..setAvailableLanguages({'en'})
          ..setSearchQuery('apple');

        final filtered = container.read(filteredPuzzlesProvider);

        expect(filtered.length, 1);
        expect(filtered.first.id, 'p1');
      });
    });
  });

  group('availableDifficultiesProvider', () {
    test('returns all difficulties present in puzzles', () {
      final testPuzzles = createTestPuzzles();
      // testPuzzles has difficulties: 1, 2, 3, 4, 5
      final container = createContainer(testPuzzles);
      addTearDown(container.dispose);

      final difficulties = container.read(availableDifficultiesProvider);
      expect(difficulties, {1, 2, 3, 4, 5});
    });

    test('returns subset of difficulties when not all are present', () {
      final testPuzzles = [
        PuzzleDescriptor(
          id: 'easy-en',
          title: 'Easy English',
          path: 'test/easy-en.json',
          difficulty: 1,
          difficultyLabel: 'Easy',
          language: 'en',
        ),
        PuzzleDescriptor(
          id: 'hard-fr',
          title: 'Hard French',
          path: 'test/hard-fr.json',
          difficulty: 3,
          difficultyLabel: 'Hard',
          language: 'fr',
        ),
      ];
      final container = createContainer(testPuzzles);
      addTearDown(container.dispose);

      final difficulties = container.read(availableDifficultiesProvider);
      expect(difficulties, {1, 3});
    });

    test('returns empty set when loading', () {
      final container = ProviderContainer(
        overrides: [
          puzzlesProvider.overrideWithValue(const AsyncValue.loading()),
        ],
      );
      addTearDown(container.dispose);

      final difficulties = container.read(availableDifficultiesProvider);
      expect(difficulties, isEmpty);
    });
  });
}
