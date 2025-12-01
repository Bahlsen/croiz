import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  test('arrow navigation skips cells that do not belong to any word', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final boardNotifier = container.read(gameBoardProvider.notifier);
    
    // Create a 5x5 grid with specific entries:
    // - Word 1: horizontal at (0,0) length 3 -> cells (0,0), (0,1), (0,2)
    // - Word 2: vertical at (2,0) length 3 -> cells (0,2), (1,2), (2,2)
    // - Cell (0,3) is NOT black but doesn't belong to any word
    // - Word 3: horizontal at (0,4) length 1 -> cell (0,4)
    
    final board = boardNotifier.state.copyWith(
      entries: const [
        PuzzleEntryData(number: 1, direction: 'across', x: 0, y: 0, length: 3),
        PuzzleEntryData(number: 2, direction: 'down', x: 2, y: 0, length: 3),
        PuzzleEntryData(number: 3, direction: 'across', x: 4, y: 0, length: 1),
      ],
    );
    
    container.read(gameBoardProvider.notifier).state = board;
    
    // Start at cell (0,2) - end of word 1
    container.read(selectedCellProvider.notifier).state = const SelectedCell(0, 2);
    
    final controller = CrosswordInputController.fromContainer(container);
    
    // Press arrow right -> should skip (0,3) and land on (0,4)
    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.arrowRight,
      physicalKey: PhysicalKeyboardKey.arrowRight,
      timeStamp: Duration(milliseconds: 1),
    );
    controller.handleKey(event, boardNotifier.state.gridSize);

    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    // Should skip isolated cell (0,3) and land on (0,4)
    expect(sel!.row, 0);
    expect(sel.col, 4);
  });

  test('arrow navigation works when no entries are defined (legacy behavior)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Board with no entries (legacy mode)
    container.read(selectedCellProvider.notifier).state = const SelectedCell(0, 0);

    final controller = CrosswordInputController.fromContainer(container);
    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.arrowRight,
      physicalKey: PhysicalKeyboardKey.arrowRight,
      timeStamp: Duration(milliseconds: 1),
    );
    controller.handleKey(event, container.read(gameBoardProvider).gridSize);

    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    // Should move to next cell as before
    expect(sel!.row, 0);
    expect(sel.col, 1);
  });

  test('arrow navigation wraps around when skipping isolated cells', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final boardNotifier = container.read(gameBoardProvider.notifier);
    
    // Only one word at (1,1) horizontal length 2
    // Cell (0,0) is isolated (not part of any word)
    final board = boardNotifier.state.copyWith(
      entries: const [
        PuzzleEntryData(number: 1, direction: 'across', x: 1, y: 1, length: 2),
      ],
    );
    
    container.read(gameBoardProvider.notifier).state = board;
    
    // Start at cell (1,2) - end of the only word
    container.read(selectedCellProvider.notifier).state = const SelectedCell(1, 2);
    
    final controller = CrosswordInputController.fromContainer(container);
    
    // Press arrow right -> should wrap and skip isolated cells, landing back at word start (1,1)
    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.arrowRight,
      physicalKey: PhysicalKeyboardKey.arrowRight,
      timeStamp: Duration(milliseconds: 1),
    );
    controller.handleKey(event, boardNotifier.state.gridSize);

    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    // Should wrap to start of word
    expect(sel!.row, 1);
    expect(sel.col, 1);
  });
}
