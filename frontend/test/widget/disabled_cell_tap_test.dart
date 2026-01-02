import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/widgets/grid/crossword_cell.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets('tapping a disabled (black) cell does not select it', (
    WidgetTester tester,
  ) async {
    const size = 3;
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    // Make cell at row 0, col 1 disabled/black
    final black = List.generate(size, (_) => List<bool>.filled(size, false));
    black[0][1] = true;

    final board = GameBoard(
      id: 'test-board',
      title: 'Test',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: const {},
      blackCells: black,
      difficulty: 1,
      entries: const [],
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Sizer(
          builder:
              (context, orientation, deviceType) => const MaterialApp(
                home: Scaffold(
                  body: CrosswordCell(row: 0, col: 1, key: Key('cell-0-1')),
                ),
              ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap the disabled cell
    await tester.tap(find.byKey(const Key('cell-0-1')));
    await tester.pumpAndSettle();

    // The selected cell provider should remain null (no selection)
    final selected = container.read(selectedCellProvider);
    expect(selected, isNull);
  });
}
