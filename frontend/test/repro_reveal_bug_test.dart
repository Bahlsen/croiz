// ignore_for_file: avoid_print
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/monetization/services/ad_service.dart';
import 'helpers/fake_monetization_service.dart';

void main() {
  testWidgets('Watching ad replenishes letter reveals and allows reveal', (
    tester,
  ) async {
    // 1. Setup board with 0 lettersUntilAd
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
      lettersUntilAd: 0, // No reveals left
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        flashClearDelayProvider.overrideWithValue(Duration.zero),
        wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        monetizationServiceProvider.overrideWithValue(
          FakeMonetizationService(),
        ),
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

    // Select a cell
    container
        .read(selectedCellProvider.notifier)
        .select(const SelectedCell(0, 0));
    await tester.pump();

    // 2. Open Reveal Menu
    await tester.tap(find.byKey(const Key('reveal_button')));
    await tester.pumpAndSettle();

    // 3. Tap "Reveal letter"
    await tester.tap(find.text('Reveal letter'));
    await tester.pumpAndSettle();

    // 4. Verify "Watch Ad?" dialog appears
    expect(find.text('Watch Ad?'), findsOneWidget);

    // 5. Tap "Yes" (FakeMonetizationService will grant reward)
    await tester.tap(find.text('Yes'));
    final adService =
        container.read(monetizationServiceProvider) as FakeMonetizationService;
    adService.autoDismiss = false; // We want to control it manually
    await tester.pump(); // Start the async call

    // Simulate ad dismissal
    adService.simulateAdDismissal();

    await tester.pumpAndSettle();

    // 6. Verify that the letter was revealed (meaning revealLetterAt was called)
    final updatedBoard = container.read(gameBoardProvider);
    expect(
      updatedBoard.grid[0][0],
      equals('A'),
      reason: 'Letter should be revealed',
    );

    // 7. Verify that reveals were replenished (to 10) and one was used (result: 9)
    expect(
      updatedBoard.lettersUntilAd,
      equals(9),
      reason: 'Reveals should be 9 (10 - 1 used)',
    );
  });
}
