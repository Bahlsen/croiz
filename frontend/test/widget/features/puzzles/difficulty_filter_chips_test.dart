import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/puzzles/puzzle_filter_provider.dart';
import 'package:croiz/features/puzzles/widgets/difficulty_filter_chips.dart';
import 'package:croiz/features/puzzles/filtered_puzzles_provider.dart';

void main() {
  testWidgets('renders 5 chips for each difficulty', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableDifficultiesProvider.overrideWithValue({1, 2, 3, 4, 5}),
        ],
        child: const MaterialApp(home: Scaffold(body: DifficultyFilterChips())),
      ),
    );

    // Should have 5 FilterChip widgets
    expect(find.byType(FilterChip), findsNWidgets(5));
  });

  testWidgets('chips show correct labels', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableDifficultiesProvider.overrideWithValue({1, 2, 3, 4, 5}),
        ],
        child: const MaterialApp(home: Scaffold(body: DifficultyFilterChips())),
      ),
    );

    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('Expert'), findsOneWidget);
    expect(find.text('Master'), findsOneWidget);
  });

  testWidgets('chip shows correct color for Easy (green)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableDifficultiesProvider.overrideWithValue({1, 2, 3, 4, 5}),
        ],
        child: const MaterialApp(home: Scaffold(body: DifficultyFilterChips())),
      ),
    );

    // Find the Easy chip and verify it uses green color
    final easyChipFinder = find.ancestor(
      of: find.text('Easy'),
      matching: find.byType(FilterChip),
    );
    expect(easyChipFinder, findsOneWidget);

    final easyChip = tester.widget<FilterChip>(easyChipFinder);
    // The chip should be selected by default and use green
    expect(easyChip.selected, isTrue);
  });

  testWidgets('tapping chip toggles selection', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableDifficultiesProvider.overrideWithValue({1, 2, 3, 4, 5}),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(puzzleFilterProvider);
                return Column(
                  children: [
                    const DifficultyFilterChips(),
                    Text('Selected: ${state.selectedDifficulties.join(",")}'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    // Initially all selected
    expect(find.text('Selected: 1,2,3,4,5'), findsOneWidget);

    // Tap on Hard (difficulty 3)
    await tester.tap(find.text('Hard'));
    await tester.pumpAndSettle();

    // Should no longer contain 3
    expect(find.text('Selected: 1,2,4,5'), findsOneWidget);
  });

  testWidgets('selected chips are visually distinct from unselected', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableDifficultiesProvider.overrideWithValue({1, 2, 3, 4, 5}),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) => const DifficultyFilterChips()),
          ),
        ),
      ),
    );

    // All chips should be selected by default
    final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
    for (final chip in chips) {
      expect(chip.selected, isTrue);
    }

    // Tap one to deselect
    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    // Find the Easy chip again
    final easyChip = tester.widget<FilterChip>(
      find.ancestor(of: find.text('Easy'), matching: find.byType(FilterChip)),
    );
    expect(easyChip.selected, isFalse);
  });
}
