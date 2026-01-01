import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/puzzles/puzzle_filter_provider.dart';
import 'package:croiz/features/puzzles/filtered_puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/language_filter_chips.dart';

void main() {
  testWidgets('renders chips for each available language', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableLanguagesProvider.overrideWithValue({'en', 'fr', 'uk'}),
          puzzleFilterProvider.overrideWith(
            () => _TestFilterNotifier(selectedLanguages: {'en', 'fr', 'uk'}),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: LanguageFilterChips())),
      ),
    );

    // Should have 3 FilterChip widgets
    expect(find.byType(FilterChip), findsNWidgets(3));
  });

  testWidgets('chips show language names', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableLanguagesProvider.overrideWithValue({'en', 'fr'}),
          puzzleFilterProvider.overrideWith(
            () => _TestFilterNotifier(selectedLanguages: {'en', 'fr'}),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: LanguageFilterChips())),
      ),
    );

    expect(find.text('English'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
  });

  testWidgets('shows Ukrainian language chip', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableLanguagesProvider.overrideWithValue({'en', 'uk'}),
          puzzleFilterProvider.overrideWith(
            () => _TestFilterNotifier(selectedLanguages: {'en', 'uk'}),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: LanguageFilterChips())),
      ),
    );

    expect(find.text('Українська'), findsOneWidget);
  });

  testWidgets('tapping chip toggles selection', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableLanguagesProvider.overrideWithValue({'en', 'fr'}),
          puzzleFilterProvider.overrideWith(
            () => _TestFilterNotifier(selectedLanguages: {'en', 'fr'}),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(puzzleFilterProvider);
                return Column(
                  children: [
                    const LanguageFilterChips(),
                    Text(
                      'Selected: ${state.selectedLanguages.toList()..sort()}',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    // Initially both selected
    expect(find.text('Selected: [en, fr]'), findsOneWidget);

    // Tap on French to deselect
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    // Should no longer contain fr
    expect(find.text('Selected: [en]'), findsOneWidget);
  });

  testWidgets('selected chips are visually distinct', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableLanguagesProvider.overrideWithValue({'en', 'fr'}),
          puzzleFilterProvider.overrideWith(
            () => _TestFilterNotifier(selectedLanguages: {'en', 'fr'}),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: LanguageFilterChips())),
      ),
    );

    // All chips should be selected by default
    final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
    for (final chip in chips) {
      expect(chip.selected, isTrue);
    }

    // Tap one to deselect
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // Find the English chip again
    final englishChip = tester.widget<FilterChip>(
      find.ancestor(
        of: find.text('English'),
        matching: find.byType(FilterChip),
      ),
    );
    expect(englishChip.selected, isFalse);
  });

  testWidgets('does not render when only one language available', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableLanguagesProvider.overrideWithValue({'en'}),
          puzzleFilterProvider.overrideWith(
            () => _TestFilterNotifier(selectedLanguages: {'en'}),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: LanguageFilterChips())),
      ),
    );

    // Should not render any chips when there's only one language
    expect(find.byType(FilterChip), findsNothing);
  });
}

/// Test notifier that allows overriding the initial state.
class _TestFilterNotifier extends PuzzleFilterNotifier {
  _TestFilterNotifier({required Set<String> selectedLanguages})
    : _selectedLanguages = selectedLanguages;

  final Set<String> _selectedLanguages;

  @override
  PuzzleFilterState build() =>
      PuzzleFilterState(selectedLanguages: _selectedLanguages);
}
