import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    container.read(foundWordsProvider.notifier).value = {'0,0,across'};

    final controller = CrosswordInputController.fromContainer(container);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: SafeArea(child: SizedBox.expand())),
        ),
      ),
    );

    // Insert the crossword content into the existing tree
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SafeArea(child: CrosswordContent(controller: controller)),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    // Overlay text should appear and block interaction area
    expect(find.text('Congratulations!'), findsOneWidget);
    // At least one ModalBarrier should be present (may include SafeArea or other barriers)
    expect(find.byType(ModalBarrier), findsWidgets);
  });
}
