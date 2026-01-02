import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets('EndGameOverlay appears when loading a completed puzzle', (
    tester,
  ) async {
    final board = GameBoard(
      id: 'completed',
      title: 'Completed',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: [
        ['C', 'A', 'T'],
        [null, null, null],
        [null, null, null],
      ],
      clues: {},
      blackCells: [
        [false, false, false],
        [false, false, false],
        [false, false, false],
      ],
      difficulty: 1,
      entries: [
        const PuzzleEntryData(
          number: 1,
          direction: 'across',
          x: 0,
          y: 0,
          length: 3,
          answer: 'CAT',
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Sizer(
          builder:
              (context, orientation, deviceType) =>
                  const MaterialApp(home: Scaffold(body: EndGameOverlay())),
        ),
      ),
    );

    // Allow microtasks/listeners to run and providers to settle
    await tester.pumpAndSettle();

    expect(find.text('Congratulations!'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
  });
}
