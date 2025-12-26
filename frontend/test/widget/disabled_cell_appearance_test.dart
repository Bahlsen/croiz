import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/grid/crossword_cell.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/core/theme.dart';

void main() {
  testWidgets('disabled cell matches scaffold background color (light)', (
    WidgetTester tester,
  ) async {
    const size = 3;
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
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
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          home: const Scaffold(
            body: CrosswordCell(row: 0, col: 1, key: Key('cell-0-1')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final containerFinder = find.descendant(
      of: find.byKey(const Key('cell-0-1')),
      matching: find.byType(Container),
    );

    expect(containerFinder, findsWidgets);

    final containerWidget = tester.widget<Container>(containerFinder);
    final boxDecoration = containerWidget.decoration as BoxDecoration?;
    expect(boxDecoration, isNotNull);

    expect(
      boxDecoration!.color,
      equals(AppTheme.lightTheme().scaffoldBackgroundColor),
    );
  });
}
