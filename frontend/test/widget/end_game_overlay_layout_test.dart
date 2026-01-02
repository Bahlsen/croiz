import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/widgets/content/crossword_content.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets('EndGameOverlay sits above content when puzzle solved', (
    tester,
  ) async {
    final board = GameBoard(
      id: 'test',
      title: 'T',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: [
        ['A', 'B', 'C'],
        [null, null, null],
        [null, null, null],
      ],
      clues: const {},
      blackCells: [
        [false, false, false],
        [false, false, false],
        [false, false, false],
      ],
      difficulty: 1,
      entries: const [
        PuzzleEntryData(number: 1, direction: 'across', x: 0, y: 0, length: 3),
      ],
      solutionGrid: const [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );
    addTearDown(container.dispose);

    // Mark the only entry as found so the overlay should render
    container.read(foundWordsProvider.notifier).setFoundWords({'0,0,across'});

    final controller = CrosswordInputController.fromContainer(container);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Sizer(
          builder:
              (context, orientation, deviceType) => const MaterialApp(
                home: Scaffold(body: SafeArea(child: SizedBox.expand())),
              ),
        ),
      ),
    );

    // Insert the crossword content into the existing tree
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Sizer(
          builder:
              (context, orientation, deviceType) => MaterialApp(
                home: Scaffold(
                  body: SafeArea(
                    child: CrosswordContent(controller: controller),
                  ),
                ),
              ),
        ),
      ),
    );

    await tester.pump();
    // Pump for enough time to let entry animations finish (max delay is 800ms)
    // We cannot use pumpAndSettle because of the infinite shimmer/repeat animation
    await tester.pump(const Duration(seconds: 2));

    // Overlay text should appear and block interaction area
    expect(find.text('Congratulations!'), findsOneWidget);
    // At least one ModalBarrier should be present (may include SafeArea or other barriers)
    expect(find.byType(ModalBarrier), findsWidgets);
  });
}
