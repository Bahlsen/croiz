import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('arrow navigation skips cells that do not belong to any word', () {
    const size = 5;
    final board = GameBoard(
      id: 'test',
      title: 'Test',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: List.generate(size, (_) => List<String?>.filled(size, null)),
      clues: const {},
      blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
      difficulty: 1,
      entries: const [
        PuzzleEntryData(number: 1, direction: 'across', x: 0, y: 0, length: 3),
        PuzzleEntryData(number: 2, direction: 'down', x: 2, y: 0, length: 3),
        PuzzleEntryData(number: 3, direction: 'across', x: 4, y: 0, length: 1),
      ],
    );

    final container = createTestContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );
    addTearDown(container.dispose);

    // Start at cell (0,2) - end of word 1
    container
        .read(selectedCellProvider.notifier)
        .select(const SelectedCell(0, 2));

    final controller = CrosswordInputController.fromContainer(container);

    // Press arrow right -> should skip (0,3) and land on (0,4)
    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.arrowRight,
      physicalKey: PhysicalKeyboardKey.arrowRight,
      timeStamp: Duration(milliseconds: 1),
    );
    controller.handleKey(event);

    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    // Should skip isolated cell (0,3) and land on (0,4)
    expect(sel!.row, 0);
    expect(sel.col, 4);
  });

  test(
    'arrow navigation works when no entries are defined (legacy behavior)',
    () {
      const size = 5;
      final board = GameBoard(
        id: 'test',
        title: 'Test',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: List.generate(size, (_) => List<String?>.filled(size, null)),
        clues: const {},
        blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
        difficulty: 1,
      );

      final container = createTestContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
      addTearDown(container.dispose);

      // Board with no entries (legacy mode)
      container
          .read(selectedCellProvider.notifier)
          .select(const SelectedCell(0, 0));

      final controller = CrosswordInputController.fromContainer(container);
      const event = KeyDownEvent(
        logicalKey: LogicalKeyboardKey.arrowRight,
        physicalKey: PhysicalKeyboardKey.arrowRight,
        timeStamp: Duration(milliseconds: 1),
      );
      controller.handleKey(event);

      final sel = container.read(selectedCellProvider);
      expect(sel, isNotNull);
      // Should move to next cell as before
      expect(sel!.row, 0);
      expect(sel.col, 1);
    },
  );

  test('arrow navigation wraps around when skipping isolated cells', () {
    const size = 5;
    final board = GameBoard(
      id: 'test',
      title: 'Test',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: List.generate(size, (_) => List<String?>.filled(size, null)),
      clues: const {},
      blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
      difficulty: 1,
      entries: const [
        PuzzleEntryData(number: 1, direction: 'across', x: 1, y: 1, length: 2),
      ],
    );

    final container = createTestContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );
    addTearDown(container.dispose);

    // Start at cell (1,2) - end of the only word
    container
        .read(selectedCellProvider.notifier)
        .select(const SelectedCell(1, 2));

    final controller = CrosswordInputController.fromContainer(container);

    // Press arrow right -> should wrap and skip isolated cells, landing back at word start (1,1)
    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.arrowRight,
      physicalKey: PhysicalKeyboardKey.arrowRight,
      timeStamp: Duration(milliseconds: 1),
    );
    controller.handleKey(event);

    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    // Should wrap to start of word
    expect(sel!.row, 1);
    expect(sel.col, 1);
  });
}
