import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/l10n/app_localizations.dart';

void main() {
  testWidgets('CrosswordControlsBar Reveal All requires confirmation', (
    tester,
  ) async {
    // Setup a simple board
    final board = GameBoard(
      id: 'test',
      title: 'T',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: [
        [null, null, null],
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
      entries: const [],
      solutionGrid: [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        flashClearDelayProvider.overrideWithValue(Duration.zero),
        wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Sizer(
          builder:
              (context, orientation, deviceType) => MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: Scaffold(
                  body: CrosswordControlsBar(onKey: (_) {}, onBackspace: () {}),
                ),
              ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Open the Reveal Menu
    await tester.tap(find.byKey(const Key('reveal_button')));
    await tester.pumpAndSettle();

    // 2. Verify "Reveal all" option is PRESENT (meaning menu opened)
    expect(find.text('Reveal all'), findsOneWidget);

    // 3. Tap "Reveal all"
    await tester.tap(find.text('Reveal all'));
    await tester.pumpAndSettle();

    // 4. Verify Confirmation Dialog
    expect(find.text('Confirm Reveal All'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);

    // 5. Cancel
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm Reveal All'), findsNothing);

    // 6. Reveal again
    // Reopen menu
    await tester.tap(find.byKey(const Key('reveal_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reveal all'));
    await tester.pumpAndSettle();

    // 7. Confirm
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    // Check solved
    final currentBoard = container.read(gameBoardProvider);
    expect(currentBoard.grid[0][0], equals('A'));
  });
}
