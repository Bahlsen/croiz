import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
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

  test('typing a letter sets it and advances selection', () {
    final container = ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
      ],
    );
    addTearDown(container.dispose);

    // Initialize board and selection
    final board = container.read(gameBoardProvider);
    container.read(selectedCellProvider.notifier).state = const SelectedCell(
      0,
      0,
    );

    final controller = CrosswordInputController.fromContainer(container);

    // Build a KeyDownEvent for letter 'a'
    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.keyA,
      physicalKey: PhysicalKeyboardKey.keyA,
      timeStamp: Duration(milliseconds: 1),
    );

    controller.handleKey(event, board.gridSize);

    final updated = container.read(gameBoardProvider);
    expect(updated.grid[0][0], 'A');

    final sel = container.read(selectedCellProvider);
    expect(sel != null, true);
    // After typing horizontally, selection should move to col 1
    expect(sel!.row, 0);
    expect(sel.col, 1);
  });

  test('typing on a locked cell inserts into next selectable cell', () {
    final container = ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
      ],
    );
    addTearDown(container.dispose);

    // ensure selection
    container.read(selectedCellProvider.notifier).state = const SelectedCell(
      0,
      0,
    );

    // lock the current cell
    container.read(lockedCellsProvider.notifier).value = <String>{'0,0'};

    final controller = CrosswordInputController.fromContainer(container);

    // Build a KeyDownEvent for letter 'b'
    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.keyB,
      physicalKey: PhysicalKeyboardKey.keyB,
      timeStamp: Duration(milliseconds: 1),
    );

    controller.handleKey(event, container.read(gameBoardProvider).gridSize);

    final updated = container.read(gameBoardProvider);
    // The locked cell remains empty
    expect(updated.grid[0][0], isNull);
    // The next cell should have the inserted letter
    expect(updated.grid[0][1], 'B');

    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    // After inserting into next cell, selection advances to the following cell
    expect(sel!.row, 0);
    expect(sel.col, 2);
  });

  test(
    'typing the final missing letter in the middle of a word does not advance into newly locked cells',
    () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
          // Avoid real timers in word-complete flashes.
          flashClearDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      const size = 5;
      final grid = List<List<String?>>.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );
      final blacks = List<List<bool>>.generate(
        size,
        (_) => List<bool>.filled(size, false),
      );

      // Make the remainder of row 0 black so the across entry ends at col 2.
      blacks[0][3] = true;
      blacks[0][4] = true;

      // Across entry 1: row 0, col 0..2 => solution "CAT".
      // Across entry 2: row 1, col 0..1 => solution "HI".
      final entries = <PuzzleEntryData>[
        const PuzzleEntryData(
          number: 1,
          direction: 'across',
          x: 0,
          y: 0,
          length: 3,
        ),
        const PuzzleEntryData(
          number: 2,
          direction: 'across',
          x: 0,
          y: 1,
          length: 2,
        ),
      ];

      final solutionGrid = List<List<String?>>.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );
      solutionGrid[0][0] = 'C';
      solutionGrid[0][1] = 'A';
      solutionGrid[0][2] = 'T';
      solutionGrid[1][0] = 'H';
      solutionGrid[1][1] = 'I';

      // Pre-fill the word except its middle letter.
      grid[0][0] = 'C';
      grid[0][2] = 'T';

      final board = GameBoard(
        id: 'mid-lock',
        title: 'mid-lock',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: blacks,
        difficulty: 1,
        entries: entries,
        solutionGrid: solutionGrid,
      );
      container.read(gameBoardProvider.notifier).state = board;

      // Select the missing middle letter of the across word.
      container.read(selectedCellProvider.notifier).state = const SelectedCell(
        0,
        1,
      );
      container.read(wordDirectionProvider.notifier).state =
          WordDirection.horizontal;

      final controller = CrosswordInputController.fromContainer(container);

      // Type the missing letter 'A' -> completes word 1 and locks its cells.
      const event = KeyDownEvent(
        logicalKey: LogicalKeyboardKey.keyA,
        physicalKey: PhysicalKeyboardKey.keyA,
        timeStamp: Duration(milliseconds: 1),
      );
      controller.handleKey(event, size);

      final updated = container.read(gameBoardProvider);
      expect(updated.grid[0][1], 'A');

      final locked = container.read(lockedCellsProvider);
      expect(locked, containsAll(<String>{'0,0', '0,1', '0,2'}));

      // Selection should NOT end up in the just-locked word.
      final sel = container.read(selectedCellProvider);
      expect(sel, isNotNull);
      expect(locked.contains('${sel!.row},${sel.col}'), isFalse);

      // With horizontal movement + wrap, next editable cell should be (1,0).
      expect(sel.row, 1);
      expect(sel.col, 0);
    },
  );

  test(
    'typing last letter of vertical entry moves to next entry first cell',
    () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
        ],
      );
      addTearDown(container.dispose);

      // Build a simple board with two vertical entries (numbers 5 and 6)
      const size = 5;
      final grid = List<List<String?>>.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );
      final blacks = List<List<bool>>.generate(
        size,
        (_) => List<bool>.filled(size, false),
      );
      final entries = <PuzzleEntryData>[
        const PuzzleEntryData(
          number: 5,
          direction: 'down',
          x: 0,
          y: 0,
          length: 2,
        ),
        const PuzzleEntryData(
          number: 6,
          direction: 'down',
          x: 2,
          y: 0,
          length: 2,
        ),
      ];

      final board = GameBoard(
        id: 't',
        title: 't',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: {},
        blackCells: blacks,
        difficulty: 1,
        entries: entries,
        solutionGrid: List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        ),
      );

      container.read(gameBoardProvider.notifier).state = board;

      // Select the last cell of entry 5 (row=1,col=0) and set vertical mode
      container.read(selectedCellProvider.notifier).state = const SelectedCell(
        1,
        0,
      );
      container.read(wordDirectionProvider.notifier).state =
          WordDirection.vertical;

      final controller = CrosswordInputController.fromContainer(container);

      // Type a letter 'c'
      const event = KeyDownEvent(
        logicalKey: LogicalKeyboardKey.keyC,
        physicalKey: PhysicalKeyboardKey.keyC,
        timeStamp: Duration(milliseconds: 1),
      );

      controller.handleKey(event, size);

      final updated = container.read(gameBoardProvider);
      expect(updated.grid[1][0], 'C');

      final sel = container.read(selectedCellProvider);
      expect(sel, isNotNull);
      // Next vertical entry (number 6) starts at y=0,x=2
      expect(sel!.row, 0);
      expect(sel.col, 2);
    },
  );

  test(
    'typing last vertical entry with no next vertical moves to first across and switches direction',
    () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
        ],
      );
      addTearDown(container.dispose);

      // Build a simple board with one vertical entry and one across entry
      const size = 5;
      final grid = List<List<String?>>.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );
      final blacks = List<List<bool>>.generate(
        size,
        (_) => List<bool>.filled(size, false),
      );
      final entries = <PuzzleEntryData>[
        const PuzzleEntryData(
          number: 5,
          direction: 'down',
          x: 0,
          y: 0,
          length: 1,
        ),
        const PuzzleEntryData(
          number: 1,
          direction: 'across',
          x: 2,
          y: 0,
          length: 3,
        ),
      ];

      final board = GameBoard(
        id: 't2',
        title: 't2',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: {},
        blackCells: blacks,
        difficulty: 1,
        entries: entries,
        solutionGrid: List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        ),
      );

      container.read(gameBoardProvider.notifier).state = board;

      // Select the only cell of vertical entry (row=0,col=0) and set vertical mode
      container.read(selectedCellProvider.notifier).state = const SelectedCell(
        0,
        0,
      );
      container.read(wordDirectionProvider.notifier).state =
          WordDirection.vertical;

      final controller = CrosswordInputController.fromContainer(container);

      // Type a letter 'd'
      const event = KeyDownEvent(
        logicalKey: LogicalKeyboardKey.keyD,
        physicalKey: PhysicalKeyboardKey.keyD,
        timeStamp: Duration(milliseconds: 1),
      );

      controller.handleKey(event, size);

      final updated = container.read(gameBoardProvider);
      expect(updated.grid[0][0], 'D');

      final sel = container.read(selectedCellProvider);
      expect(sel, isNotNull);
      // Should move to first across entry at y=0,x=2
      expect(sel!.row, 0);
      expect(sel.col, 2);

      // And word direction should have switched to horizontal
      final dir = container.read(wordDirectionProvider);
      expect(dir, WordDirection.horizontal);
    },
  );

  test('skip next entry when it is already found and choose next available', () {
    final container = ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
      ],
    );
    addTearDown(container.dispose);

    // Build a board with three across entries: 5,6,7 at x=0,2,4
    const size = 5;
    final grid = List<List<String?>>.generate(
      size,
      (_) => List<String?>.filled(size, null),
    );
    final blacks = List<List<bool>>.generate(
      size,
      (_) => List<bool>.filled(size, false),
    );
    const e5 = PuzzleEntryData(
      number: 5,
      direction: 'across',
      x: 0,
      y: 0,
      length: 1,
    );
    const e6 = PuzzleEntryData(
      number: 6,
      direction: 'across',
      x: 2,
      y: 0,
      length: 1,
    );
    const e7 = PuzzleEntryData(
      number: 7,
      direction: 'across',
      x: 4,
      y: 0,
      length: 1,
    );
    final entries = <PuzzleEntryData>[e5, e6, e7];

    final board = GameBoard(
      id: 't3',
      title: 't3',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: {},
      blackCells: blacks,
      difficulty: 1,
      entries: entries,
      solutionGrid: List.generate(
        size,
        (_) => List<String?>.filled(size, null),
      ),
    );

    container.read(gameBoardProvider.notifier).state = board;

    // Mark entry 7 as already found
    final wordCheck = container.read(wordCheckServiceProvider);
    final key7 = wordCheck.getWordKey(e7);
    container.read(foundWordsProvider.notifier).value = <String>{key7};

    // Select last cell of entry 6 (row=0,col=2) and horizontal
    container.read(selectedCellProvider.notifier).state = const SelectedCell(
      0,
      2,
    );
    container.read(wordDirectionProvider.notifier).state =
        WordDirection.horizontal;

    final controller = CrosswordInputController.fromContainer(container);

    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.keyX,
      physicalKey: PhysicalKeyboardKey.keyX,
      timeStamp: Duration(milliseconds: 1),
    );

    controller.handleKey(event, size);

    // After typing at entry 6, entry 7 is skipped (found) and should move to entry 5
    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    expect(sel!.row, 0);
    expect(sel.col, 0);
  });
}
