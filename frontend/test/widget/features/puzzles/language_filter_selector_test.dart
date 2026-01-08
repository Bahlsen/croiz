import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/puzzles/puzzle_filter_provider.dart';
import 'package:croiz/features/puzzles/filtered_puzzles_provider.dart';
import 'package:croiz/features/puzzles/widgets/language_filter_selector.dart';

void main() {
  testWidgets('renders button when multiple languages available', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableLanguagesProvider.overrideWithValue({'en', 'fr', 'uk'}),
          puzzleFilterProvider.overrideWith(
            () =>
                _TestFilterNotifier(selectedLanguages: const {}), // Empty = All
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: LanguageFilterSelector()),
        ),
      ),
    );

    // Should have a button
    expect(find.byType(OutlinedButton), findsOneWidget);
    // Should say "All Languages (3)" because selected is empty (All) and available is 3
    expect(find.text('All Languages (3)'), findsOneWidget);
  });

  testWidgets('shows checkbox list in bottom sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableLanguagesProvider.overrideWithValue({'en', 'fr'}),
          puzzleFilterProvider.overrideWith(
            () => _TestFilterNotifier(selectedLanguages: const {}),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: LanguageFilterSelector()),
        ),
      ),
    );

    // Tap the button
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle(); // Wait for sheet animation

    // Should find the sheet content
    expect(find.text('Select Languages'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(2));
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
  });

  testWidgets('checks boxes based on selection', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableLanguagesProvider.overrideWithValue({'en', 'fr'}),
          puzzleFilterProvider.overrideWith(
            () => _TestFilterNotifier(
              selectedLanguages: {'en'},
            ), // Only En selected
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: LanguageFilterSelector()),
        ),
      ),
    );

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    // English should be checked
    final enTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'English'),
    );
    expect(enTile.value, isTrue);

    // French should NOT be checked
    final frTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Français'),
    );
    expect(frTile.value, isFalse);
  });

  testWidgets('Select All button works', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableLanguagesProvider.overrideWithValue({'en', 'fr'}),
          puzzleFilterProvider.overrideWith(
            () => _TestFilterNotifier(selectedLanguages: {'en'}),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: LanguageFilterSelector()),
        ),
      ),
    );

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    // Verify initial state (French unchecked)
    expect(
      tester
          .widget<CheckboxListTile>(
            find.widgetWithText(CheckboxListTile, 'Français'),
          )
          .value,
      isFalse,
    );

    // Tap Select All
    await tester.tap(find.text('Select All'));
    await tester.pumpAndSettle();

    // Now French should be checked (because All implies checked)
    expect(
      tester
          .widget<CheckboxListTile>(
            find.widgetWithText(CheckboxListTile, 'Français'),
          )
          .value,
      isTrue,
    );
  });

  testWidgets('does not render when only one language available', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableLanguagesProvider.overrideWithValue({'en'}),
          puzzleFilterProvider.overrideWith(
            () => _TestFilterNotifier(selectedLanguages: const {}),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: LanguageFilterSelector()),
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsNothing);
  });
}

/// Test notifier that allows overriding the initial state.
class _TestFilterNotifier extends PuzzleFilter {
  _TestFilterNotifier({required Set<String> selectedLanguages})
    : _selectedLanguages = selectedLanguages;

  final Set<String> _selectedLanguages;

  @override
  PuzzleFilterState build() =>
      PuzzleFilterState(selectedLanguages: _selectedLanguages);
}
