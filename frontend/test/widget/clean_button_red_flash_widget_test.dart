import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
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
        // Override flash delay to a longer known duration to reliably test before/after
        flashClearDelayProvider.overrideWithValue(const Duration(seconds: 2)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Sizer(
          builder:
              (context, orientation, deviceType) => const MaterialApp(
                home: Scaffold(
                  body: Center(
                    // Directly render the cell that should flash red after cleaning
                    child: CrosswordCell(row: 0, col: 1, key: Key('cell-0-1')),
                  ),
                ),
              ),
        ),
      ),
    );

    // Trigger cleaning which should clear (0,1) and set flashing-cleared state
    container.read(gameBoardProvider.notifier).clearIncorrectLetters();

    // Pump and settle to let the initial state (red flash) apply and animations finish.
    // Since we set delay to 2 seconds, this will settle animations (~200ms) but NOT expire the flash.
    await tester.pumpAndSettle();

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
    // CrosswordThemeColors.defaults uses Colors.redAccent for clearedFlashingBorderColor
    expect(border.top.color, equals(Colors.redAccent));

    // Background should have a reddish tint (matches CrosswordThemeColors.defaults.clearedFlashingBgColor)
    expect(decoration.color, isNotNull);
    expect(decoration.color, equals(const Color.fromRGBO(255, 82, 82, 0.48)));

    // Advance time past the 2-second delay to clear the flash
    await tester.pump(const Duration(milliseconds: 2100));
    // Pump and settle to let the "fade out" animation finish (AnimatedContainer takes ~200ms)
    await tester.pumpAndSettle();

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
