import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:croiz/features/puzzles/puzzle_filter_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset SharedPreferences for each test
    SharedPreferences.setMockInitialValues({});
  });

  group('PuzzleFilterNotifier initial state', () {
    test('has all difficulties selected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(puzzleFilterProvider);
      expect(state.selectedDifficulties, {1, 2, 3, 4, 5});
    });

    test('has all languages selected (empty set) by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(puzzleFilterProvider);
      // Default languages is empty (implies all)
      expect(state.selectedLanguages, isEmpty);
    });

    test('showCompleted is false by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(puzzleFilterProvider);
      expect(state.showCompleted, isFalse);
    });
  });

  group('toggleDifficulty', () {
    test('removes difficulty when present', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state has all difficulties
      expect(
        container.read(puzzleFilterProvider).selectedDifficulties,
        contains(3),
      );

      // Toggle difficulty 3 (Hard)
      container.read(puzzleFilterProvider.notifier).toggleDifficulty(3);

      // Should no longer contain 3
      expect(
        container.read(puzzleFilterProvider).selectedDifficulties,
        isNot(contains(3)),
      );
    });

    test('adds difficulty when absent', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // First remove difficulty 3
      container.read(puzzleFilterProvider.notifier).toggleDifficulty(3);
      expect(
        container.read(puzzleFilterProvider).selectedDifficulties,
        isNot(contains(3)),
      );

      // Toggle again to add it back
      container.read(puzzleFilterProvider.notifier).toggleDifficulty(3);
      expect(
        container.read(puzzleFilterProvider).selectedDifficulties,
        contains(3),
      );
    });
  });

  group('toggleLanguage', () {
    test('removes language when present', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // We need to set initial state to have 'en' selected first
      // But default is {}, which means "All".
      // To test 'removing' (unchecking), we rely on toggle logic:
      // If we pass {'en'} as available, and current is {}, it materializes {'en'}.
      // Then it removes 'en', so result should be empty... wait.
      // If result is empty, it means "All" again.
      // So if available is {'en'}, toggling 'en' off -> empty -> all -> 'en' checked?
      // Wait. If I have {'en'} only. "All" means {'en'}.
      // If I uncheck 'en', selected becomes {}. "All".
      // So effectively, if only 1 language available, filters don't do much visually except if we allowed 0 selection.
      // But UI LanguageFilterSelector hides itself if <= 1 language.

      // Let's test with 2 languages: en, fr.
      final available = {'en', 'fr'};

      // Initial: {} (All).

      // Toggle 'en' (user unchecks 'en').
      // Logic: Materialize -> {en, fr}. Remove 'en' -> {fr}.
      container
          .read(puzzleFilterProvider.notifier)
          .toggleLanguage('en', available);

      expect(container.read(puzzleFilterProvider).selectedLanguages, {'fr'});

      // Toggle 'en' again (user checks 'en').
      // Current: {fr}. Add 'en' -> {en, fr}.
      // Optimization: {en, fr} == available -> {} (All).
      container
          .read(puzzleFilterProvider.notifier)
          .toggleLanguage('en', available);
      expect(container.read(puzzleFilterProvider).selectedLanguages, isEmpty);
    });
  });

  group('resetLanguages', () {
    test('resets logic to "All"', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final available = {'en', 'fr'};

      // Select just 'fr'
      container
          .read(puzzleFilterProvider.notifier)
          .toggleLanguage('en', available);
      expect(container.read(puzzleFilterProvider).selectedLanguages, {'fr'});

      // Reset
      container.read(puzzleFilterProvider.notifier).resetLanguages();
      expect(container.read(puzzleFilterProvider).selectedLanguages, isEmpty);
    });
  });

  group('setShowCompleted', () {
    test('updates flag to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(puzzleFilterProvider.notifier)
          .setShowCompleted(showCompleted: false);

      expect(container.read(puzzleFilterProvider).showCompleted, isFalse);
    });

    test('updates flag to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // First set to false
      container
          .read(puzzleFilterProvider.notifier)
          .setShowCompleted(showCompleted: false);
      expect(container.read(puzzleFilterProvider).showCompleted, isFalse);

      // Then set back to true
      container
          .read(puzzleFilterProvider.notifier)
          .setShowCompleted(showCompleted: true);
      expect(container.read(puzzleFilterProvider).showCompleted, isTrue);
    });
  });

  group('clearFilters', () {
    test('resets to defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Modify state
      container.read(puzzleFilterProvider.notifier)
        ..toggleDifficulty(1)
        ..toggleDifficulty(2)
        ..setShowCompleted(showCompleted: false);

      // Verify modifications
      expect(
        container.read(puzzleFilterProvider).selectedDifficulties,
        isNot(contains(1)),
      );
      expect(container.read(puzzleFilterProvider).showCompleted, isFalse);

      // Clear filters
      container.read(puzzleFilterProvider.notifier).clearFilters();

      // Should be back to defaults
      expect(container.read(puzzleFilterProvider).selectedDifficulties, {
        1,
        2,
        3,
        4,
        5,
      });
      expect(container.read(puzzleFilterProvider).showCompleted, isFalse);
    });
  });

  group('persistence', () {
    test('state persists to SharedPreferences on change', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Make a change
      container.read(puzzleFilterProvider.notifier).toggleDifficulty(3);

      // Wait for async persistence
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedDifficulties = prefs.getStringList(
        'puzzle_filter_difficulties',
      );
      expect(savedDifficulties, isNotNull);
      expect(savedDifficulties, isNot(contains('3')));
    });

    test('state restores from SharedPreferences on init', () async {
      // Pre-set preferences
      SharedPreferences.setMockInitialValues({
        'puzzle_filter_difficulties': ['1', '2'],
        'puzzle_filter_languages': ['fr'],
        'puzzle_filter_show_completed': false,
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger loading from prefs
      await container.read(puzzleFilterProvider.notifier).loadFromPrefs();

      final state = container.read(puzzleFilterProvider);
      expect(state.selectedDifficulties, {1, 2});
      expect(state.selectedLanguages, {'fr'});
      expect(state.showCompleted, isFalse);
    });
  });

  group('hasActiveFilters', () {
    test('returns false when all defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(puzzleFilterProvider).hasActiveFilters, isFalse);
    });

    test('returns true when difficulty filtered', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(puzzleFilterProvider.notifier).toggleDifficulty(1);

      expect(container.read(puzzleFilterProvider).hasActiveFilters, isTrue);
    });

    test('returns true when showCompleted is true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(puzzleFilterProvider.notifier)
          .setShowCompleted(showCompleted: true);

      expect(container.read(puzzleFilterProvider).hasActiveFilters, isTrue);
    });
  });
}
