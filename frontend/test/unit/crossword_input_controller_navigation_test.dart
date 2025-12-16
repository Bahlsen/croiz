import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import '../test_utils/test_board.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/services/game_audio_service.dart';

// Mock pour le service audio
class MockGameAudioService implements GameAudioService {
  @override
  Future<void> playType() async {}

  @override
  Future<void> playDelete() async {}

  @override
  Future<void> playSuccess() async {}
  @override
  Future<void> playVictory() async {}
  @override
  Future<void> get ready => Future<void>.value();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('arrow right skips black cells and wraps to next row', () {
    final testBoard = makeEmptyBoard();
    final container = ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(testBoard)),
      ],
    );
    addTearDown(container.dispose);

    final boardNotifier = container.read(gameBoardProvider.notifier);
    // Make entire first row except (0,0) black to force wrap.
    for (var c = 1; c < boardNotifier.state.gridSize; c++) {
      boardNotifier.toggleBlackCell(0, c);
    }
    container.read(selectedCellProvider.notifier).state = const SelectedCell(
      0,
      0,
    );

    final controller = CrosswordInputController.fromContainer(container);
    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.arrowRight,
      physicalKey: PhysicalKeyboardKey.arrowRight,
      timeStamp: Duration(milliseconds: 1),
    );
    controller.handleKey(event, boardNotifier.state.gridSize);

    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    // Should wrap to row 1 col 0
    expect(sel!.row, 1);
    expect(sel.col, 0);
  });

  test('arrow down skips a black cell directly below', () {
    final testBoard = makeEmptyBoard();
    final container = ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(testBoard)),
      ],
    );
    addTearDown(container.dispose);
    final boardNotifier = container.read(gameBoardProvider.notifier)
      // Put a black cell at (1,0)
      ..toggleBlackCell(1, 0);
    container.read(selectedCellProvider.notifier).state = const SelectedCell(
      0,
      0,
    );

    final controller = CrosswordInputController.fromContainer(container);
    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.arrowDown,
      physicalKey: PhysicalKeyboardKey.arrowDown,
      timeStamp: Duration(milliseconds: 2),
    );
    controller.handleKey(event, boardNotifier.state.gridSize);

    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    // Should skip (1,0) and land on (2,0)
    expect(sel!.row, 2);
    expect(sel.col, 0);
  });

  test('arrow down from bottom row wraps vertically to next column', () {
    final testBoard = makeEmptyBoard();
    final container = ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(testBoard)),
      ],
    );
    addTearDown(container.dispose);
    final boardNotifier = container.read(gameBoardProvider.notifier);
    // Ensure (0,1) is free and several cells in column 0 are black except bottom
    for (var r = 0; r < boardNotifier.state.gridSize - 1; r++) {
      if (r != boardNotifier.state.gridSize - 1) {
        boardNotifier.toggleBlackCell(r, 0);
      }
    }
    // Select bottom cell in column 0
    final lastRow = boardNotifier.state.gridSize - 1;
    container.read(selectedCellProvider.notifier).state = SelectedCell(
      lastRow,
      0,
    );

    final controller = CrosswordInputController.fromContainer(container);
    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.arrowDown,
      physicalKey: PhysicalKeyboardKey.arrowDown,
      timeStamp: Duration(milliseconds: 3),
    );
    controller.handleKey(event, boardNotifier.state.gridSize);

    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    // Vertical wrap should advance to column 1 top row if available.
    expect(sel!.row, 0);
    expect(sel.col, 1);
  });

  test('backspace clears letter without moving selection', () {
    final testBoard = makeEmptyBoard();
    final container = ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(testBoard)),
      ],
    );
    addTearDown(container.dispose);
    final boardNotifier = container.read(gameBoardProvider.notifier);
    container.read(selectedCellProvider.notifier).state = const SelectedCell(
      0,
      0,
    );
    final controller = CrosswordInputController.fromContainer(container);

    // Type a letter first
    const typeEvent = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.keyB,
      physicalKey: PhysicalKeyboardKey.keyB,
      timeStamp: Duration(milliseconds: 4),
    );
    controller.handleKey(typeEvent, boardNotifier.state.gridSize);
    final afterBoard = container.read(gameBoardProvider);
    expect(afterBoard.grid[0][0], 'B');

    // Move selection back to (0,0) for deterministic check (it advanced)
    container.read(selectedCellProvider.notifier).state = const SelectedCell(
      0,
      0,
    );

    const backspaceEvent = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.backspace,
      physicalKey: PhysicalKeyboardKey.backspace,
      timeStamp: Duration(milliseconds: 5),
    );
    controller.handleKey(backspaceEvent, boardNotifier.state.gridSize);
    final afterBoard2 = container.read(gameBoardProvider);
    expect(afterBoard2.grid[0][0], isNull);

    final sel = container.read(selectedCellProvider);
    // Selection should remain at (0,0)
    expect(sel!.row, 0);
    expect(sel.col, 0);
  });

  test('arrow right moves to next word and selects its first empty cell', () {
    const size = 5;
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final black = List.generate(size, (_) => List<bool>.filled(size, false));
    final boardWithEntries = GameBoard(
      id: 'test-entries',
      title: 'Test Entries',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: const {},
      blackCells: black,
      difficulty: 1,
      entries: const [
        PuzzleEntryData(number: 1, direction: 'across', x: 0, y: 0, length: 1),
        PuzzleEntryData(number: 2, direction: 'across', x: 2, y: 0, length: 3),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
        puzzleLoaderProvider.overrideWithValue(
          AsyncValue.data(boardWithEntries),
        ),
      ],
    );
    addTearDown(container.dispose);

    final boardNotifier = container.read(gameBoardProvider.notifier);

    // Select the single-cell first word at (0,0)
    container.read(selectedCellProvider.notifier).state = const SelectedCell(
      0,
      0,
    );

    final controller = CrosswordInputController.fromContainer(container);
    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.arrowRight,
      physicalKey: PhysicalKeyboardKey.arrowRight,
      timeStamp: Duration(milliseconds: 10),
    );
    controller.handleKey(event, boardNotifier.state.gridSize);

    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    // Next across word starts at (0,2); its first empty cell should be (0,2)
    expect(sel!.row, 0);
    expect(sel.col, 2);
  });
}
