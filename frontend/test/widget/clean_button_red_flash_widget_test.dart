import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/widgets/grid/crossword_cell.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets('Clear button triggers red flash on incorrect cells', (
    WidgetTester tester,
  ) async {
    const entries = [
      PuzzleEntryData(
        number: 1,
        direction: 'across',
        x: 0,
        y: 0,
        length: 3,
        answer: 'CAT',
      ),
    ];

    final initialGrid = <List<String?>>[
      <String?>['C', 'X', 'T'], // X is incorrect at (0,1)
      <String?>[null, null, null],
      <String?>[null, null, null],
    ];

    final board = GameBoard(
      id: 't',
      title: 't',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: initialGrid,
      clues: const {},
      blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
      difficulty: 1,
      entries: entries,
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        // Keep default flash delay (> 0) so red flash persists for inspection
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              // Directly render the cell that should flash red after cleaning
              child: CrosswordCell(row: 0, col: 1, key: Key('cell-0-1')),
            ),
          ),
        ),
      ),
    );

    // Trigger cleaning which should clear (0,1) and set flashing-cleared state
    container.read(gameBoardProvider.notifier).clearIncorrectLetters();

    // Pump a single frame to apply new decoration but avoid clearing by timer
    await tester.pump();

    // Fetch the Container decorating the cell
    // (AnimatedContainer was removed for performance - now uses plain Container)
    final cellFinder = find.byKey(const Key('cell-0-1'));
    expect(cellFinder, findsOneWidget);

    final containerFinder = find.descendant(
      of: cellFinder,
      matching: find.byWidgetPredicate(
        (w) => w is Container && w.decoration is BoxDecoration,
      ),
    );
    expect(containerFinder, findsOneWidget);

    final containerWidget = tester.widget<Container>(containerFinder);
    final decoration =
        (containerWidget.decoration ?? const BoxDecoration()) as BoxDecoration;

    // Border should be red accent during cleared flash
    final border =
        (decoration.border ?? Border.all(color: Colors.transparent)) as Border;
    expect(border.top.color, equals(Colors.redAccent));

    // Background should have a reddish tint (exact value match)
    expect(decoration.color, isNotNull);
    expect(decoration.color, equals(Colors.redAccent.withValues(alpha: 0.48)));

    // After delay, the flash should clear; advance beyond default (500ms)
    await tester.pump(const Duration(milliseconds: 600));

    // Re-fetch Container after flash clears
    final containerFinderAfter = find.descendant(
      of: cellFinder,
      matching: find.byWidgetPredicate(
        (w) => w is Container && w.decoration is BoxDecoration,
      ),
    );
    expect(containerFinderAfter, findsOneWidget);

    final containerWidgetAfter = tester.widget<Container>(containerFinderAfter);
    final decorationAfter =
        (containerWidgetAfter.decoration ?? const BoxDecoration())
            as BoxDecoration;
    final borderAfter =
        (decorationAfter.border ?? Border.all(color: Colors.transparent))
            as Border;

    // No longer red border after flash clears
    expect(borderAfter.top.color, isNot(Colors.redAccent));
  });
}
