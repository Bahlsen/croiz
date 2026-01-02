import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/screens/crossword_screen.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('CrosswordScreen loads and displays with puzzle data', (
    tester,
  ) async {
    // Wrap in ProviderScope for Riverpod
    // Provide a mock board with entries to satisfy numbering requirement.
    const size = 5;
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final black = List.generate(size, (_) => List<bool>.filled(size, false));
    final boardWithEntries = GameBoard(
      id: 'test-empty',
      title: 'Test',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: const {},
      blackCells: black,
      difficulty: 1,
      entries: const [
        PuzzleEntryData(number: 1, direction: 'across', x: 0, y: 0, length: 3),
        PuzzleEntryData(number: 2, direction: 'down', x: 2, y: 1, length: 4),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzleLoaderProvider.overrideWith((ref) async => boardWithEntries),
        ],
        child: Sizer(
          builder:
              (context, orientation, deviceType) =>
                  const MaterialApp(home: CrosswordScreen()),
        ),
      ),
    );

    // Initial pump to start async loading
    await tester.pump();

    // Wait for puzzle to load (FutureProvider)
    await tester.pumpAndSettle();

    // Verify the screen builds without errors
    expect(find.byType(CrosswordScreen), findsOneWidget);

    // Verify the main grid is present (visual assertion instead of AppBar)
    expect(find.byType(CrosswordGrid), findsOneWidget);

    // Note: The grid will be empty initially since we don't pre-fill solutions by default.
    // The test validates that the widget tree builds successfully with the JSON-loaded puzzle.
  });
}
