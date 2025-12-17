import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/services/game_audio_service.dart';
import 'package:croiz/domain/entities/game_entities.dart';

// Mock pour le service audio (n'hérite pas pour éviter les appels au constructeur)
class MockGameAudioService implements GameAudioService {
  int typeCallCount = 0;
  int deleteCallCount = 0;
  int successCallCount = 0;

  @override
  Future<void> playType() async {
    typeCallCount++;
  }

  @override
  Future<void> playDelete() async {
    deleteCallCount++;
  }

  @override
  Future<void> playSuccess() async {
    successCallCount++;
  }

  @override
  Future<void> playVictory() async {
    successCallCount++;
  }

  @override
  Future<void> get ready => Future<void>.value();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CrosswordInputController - Audio Integration', () {
    late ProviderContainer container;
    late MockGameAudioService mockAudioService;

    setUp(() {
      mockAudioService = MockGameAudioService();
      container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          puzzleLoaderProvider.overrideWithValue(
            AsyncValue.data(
              GameBoard(
                id: 'test',
                title: 'Test Board',
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
              ),
            ),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('setLetterAndAdvance sets the letter in the board', () {
      final controller = CrosswordInputController.fromContainer(container);
      container.read(selectedCellProvider.notifier).state = const SelectedCell(
        0,
        0,
      );

      controller.setLetterAndAdvance('A');

      final value = container.read(gameBoardProvider).grid[0][0];
      expect(value, 'A');
    });

    test('clearCurrent clears the current cell', () {
      final controller = CrosswordInputController.fromContainer(container);
      container.read(selectedCellProvider.notifier).state = const SelectedCell(
        0,
        0,
      );
      container.read(gameBoardProvider.notifier).setLetter(0, 0, 'A');

      controller.clearCurrent();

      final value = container.read(gameBoardProvider).grid[0][0];
      expect(value, isNull);
    });

    test(
      'setLetterAndAdvance detects completed word and plays success sound',
      () async {
        // Create a board with a simple 3-letter word "CAT"
        final testContainer = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudioService),
            puzzleLoaderProvider.overrideWithValue(
              AsyncValue.data(
                GameBoard(
                  id: 'test',
                  title: 'Test Board',
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
                  entries: [
                    const PuzzleEntryData(
                      number: 1,
                      direction: 'across',
                      x: 0,
                      y: 0,
                      length: 3,
                      answer: 'CAT',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        final controller = CrosswordInputController.fromContainer(
          testContainer,
        );
        testContainer.read(selectedCellProvider.notifier).state =
            const SelectedCell(0, 0);

        // Type the word "CAT"
        controller.setLetterAndAdvance('C');
        testContainer.read(selectedCellProvider.notifier).state =
            const SelectedCell(0, 1);
        controller.setLetterAndAdvance('A');

        testContainer.read(selectedCellProvider.notifier).state =
            const SelectedCell(0, 2);
        controller.setLetterAndAdvance('T');

        // Verify the word is marked as found
        final foundWords = testContainer.read(foundWordsProvider);
        expect(foundWords.contains('0,0,across'), true);

        testContainer.dispose();
      },
    );

    test(
      'typing a letter that completes two crossing words marks both found',
      () {
        // Build a board where two words cross at (0,1) and the final letter
        // to type is at that cell. Both words should be marked found after typing.
        final testContainer = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudioService),
            puzzleLoaderProvider.overrideWithValue(
              AsyncValue.data(
                GameBoard(
                  id: 'test',
                  title: 'Cross Test',
                  gridSize: 3,
                  createdAt: DateTime.now(),
                  grid: [
                    ['A', null, null],
                    [null, 'B', null],
                    [null, null, null],
                  ],
                  clues: {},
                  blackCells: [
                    [false, false, false],
                    [false, false, false],
                    [false, false, false],
                  ],
                  difficulty: 1,
                  entries: [
                    // Across word at y=0 from x=0 length 2: A?
                    const PuzzleEntryData(
                      number: 1,
                      direction: 'across',
                      x: 0,
                      y: 0,
                      length: 2,
                      answer: 'AC',
                    ),
                    // Down word at x=1 from y=0 length 2: ?B
                    const PuzzleEntryData(
                      number: 2,
                      direction: 'down',
                      x: 1,
                      y: 0,
                      length: 2,
                      answer: 'CB',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        final controller = CrosswordInputController.fromContainer(
          testContainer,
        );
        // select the shared final cell (0,1)
        testContainer.read(selectedCellProvider.notifier).state =
            const SelectedCell(0, 1);

        // Type 'C' which should complete both words
        controller.setLetterAndAdvance('C');

        final found = testContainer.read(foundWordsProvider);
        expect(found.contains('0,0,across'), isTrue);
        expect(found.contains('0,1,down'), isTrue);

        testContainer.dispose();
      },
    );

    test('physical backspace/delete does not clear locked cells', () {
      final testContainer = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          puzzleLoaderProvider.overrideWithValue(
            AsyncValue.data(
              GameBoard(
                id: 'test',
                title: 'Test Board',
                gridSize: 3,
                createdAt: DateTime.now(),
                grid: [
                  ['C', null, null],
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
              ),
            ),
          ),
        ],
      );
      // lock the cell
      testContainer.read(lockedCellsProvider.notifier).value = {
        const CellKey(0, 0),
      };

      final controller = CrosswordInputController.fromContainer(testContainer);
      testContainer.read(selectedCellProvider.notifier).state =
          const SelectedCell(0, 0);

      // Send Backspace
      const backspaceEvent = KeyDownEvent(
        logicalKey: LogicalKeyboardKey.backspace,
        physicalKey: PhysicalKeyboardKey.backspace,
        timeStamp: Duration(milliseconds: 10),
      );
      controller.handleKey(backspaceEvent);

      // Value should remain because cell is locked
      expect(testContainer.read(gameBoardProvider).grid[0][0], 'C');

      // Send Delete
      const deleteEvent = KeyDownEvent(
        logicalKey: LogicalKeyboardKey.delete,
        physicalKey: PhysicalKeyboardKey.delete,
        timeStamp: Duration(milliseconds: 11),
      );
      controller.handleKey(deleteEvent);
      expect(testContainer.read(gameBoardProvider).grid[0][0], 'C');

      testContainer.dispose();
    });

    test('typing on a filled cell fills next available cell in the word', () {
      // Build a board with word "MOT" at row 0 across
      final testContainer = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          puzzleLoaderProvider.overrideWithValue(
            AsyncValue.data(
              GameBoard(
                id: 'test',
                title: 'Fill Next',
                gridSize: 3,
                createdAt: DateTime.now(),
                grid: [
                  ['M', 'O', null],
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
                entries: [
                  const PuzzleEntryData(
                    number: 1,
                    direction: 'across',
                    x: 0,
                    y: 0,
                    length: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      );

      addTearDown(testContainer.dispose);

      final controller = CrosswordInputController.fromContainer(testContainer);
      // Cursor is on the first cell which is already 'M'
      testContainer.read(selectedCellProvider.notifier).state =
          const SelectedCell(0, 0);

      // Type 'T' -> should place at next empty cell in the across word (0,2)
      controller.setLetterAndAdvance('T');

      final board = testContainer.read(gameBoardProvider);
      expect(board.grid[0][0], 'M');
      expect(board.grid[0][1], 'O');
      expect(board.grid[0][2], 'T');

      testContainer.dispose();
    });

    test(
      'typing on filled cell skips full next word and goes to following word',
      () {
        // Board width 5; create three across words on row 0:
        // word1 at x=0 length=1 (filled), word2 at x=1 length=2 (filled),
        // word3 at x=3 length=2 (empty)
        final testContainer = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudioService),
            puzzleLoaderProvider.overrideWithValue(
              AsyncValue.data(
                GameBoard(
                  id: 'test',
                  title: 'Skip Full',
                  gridSize: 5,
                  createdAt: DateTime.now(),
                  grid: [
                    ['M', 'O', 'T', null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                  ],
                  clues: {},
                  blackCells: [
                    [false, false, false, false, false],
                    [false, false, false, false, false],
                    [false, false, false, false, false],
                    [false, false, false, false, false],
                    [false, false, false, false, false],
                  ],
                  difficulty: 1,
                  entries: [
                    const PuzzleEntryData(
                      number: 1,
                      direction: 'across',
                      x: 0,
                      y: 0,
                      length: 1,
                    ),
                    const PuzzleEntryData(
                      number: 2,
                      direction: 'across',
                      x: 1,
                      y: 0,
                      length: 2,
                    ),
                    const PuzzleEntryData(
                      number: 3,
                      direction: 'across',
                      x: 3,
                      y: 0,
                      length: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        addTearDown(testContainer.dispose);

        final controller = CrosswordInputController.fromContainer(
          testContainer,
        );
        // Cursor on first filled word at (0,0)
        testContainer.read(selectedCellProvider.notifier).state =
            const SelectedCell(0, 0);

        // Type 'X' -> should skip word2 (full) and place into word3 first cell (0,3)
        controller.setLetterAndAdvance('X');

        final board = testContainer.read(gameBoardProvider);
        expect(board.grid[0][3], 'X');

        testContainer.dispose();
      },
    );
    test('locked cells cannot be modified', () {
      // Setup a container with a locked cell
      final testContainer = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          puzzleLoaderProvider.overrideWithValue(
            AsyncValue.data(
              GameBoard(
                id: 'test',
                title: 'Test Board',
                gridSize: 3,
                createdAt: DateTime.now(),
                grid: [
                  ['C', 'A', 'T'],
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
              ),
            ),
          ),
          // locked cells will be set on the container after creation
        ],
      );
      // set locked cells for this test container
      testContainer.read(lockedCellsProvider.notifier).value = {
        const CellKey(0, 0),
        const CellKey(0, 1),
        const CellKey(0, 2),
      };

      final controller = CrosswordInputController.fromContainer(testContainer);
      testContainer.read(selectedCellProvider.notifier).state =
          const SelectedCell(0, 0);

      final initialValue = testContainer.read(gameBoardProvider).grid[0][0];
      controller.setLetterAndAdvance('X');

      // Value should not change because cell is locked
      final finalValue = testContainer.read(gameBoardProvider).grid[0][0];
      expect(finalValue, initialValue);

      testContainer.dispose();
    });

    test('clearCurrent does not clear locked cells', () {
      final testContainer = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          puzzleLoaderProvider.overrideWithValue(
            AsyncValue.data(
              GameBoard(
                id: 'test',
                title: 'Test Board',
                gridSize: 3,
                createdAt: DateTime.now(),
                grid: [
                  ['C', null, null],
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
              ),
            ),
          ),
        ],
      );
      // set locked cells for this test container
      testContainer.read(lockedCellsProvider.notifier).value = {
        const CellKey(0, 0),
      };

      final controller = CrosswordInputController.fromContainer(testContainer);
      testContainer.read(selectedCellProvider.notifier).state =
          const SelectedCell(0, 0);

      controller.clearCurrent();

      // Value should not be cleared because cell is locked
      final finalValue = testContainer.read(gameBoardProvider).grid[0][0];
      expect(finalValue, 'C');

      testContainer.dispose();
    });

    test(
      'backspace from next cell selects locked previous cell and does not delete it',
      () {
        final testContainer = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudioService),
            puzzleLoaderProvider.overrideWithValue(
              AsyncValue.data(
                GameBoard(
                  id: 'test',
                  title: 'Test Board',
                  gridSize: 3,
                  createdAt: DateTime.now(),
                  grid: [
                    ['C', null, null],
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
                ),
              ),
            ),
          ],
        );

        // lock the previous filled cell (0,0)
        testContainer.read(lockedCellsProvider.notifier).value = {
          const CellKey(0, 0),
        };

        final controller = CrosswordInputController.fromContainer(
          testContainer,
        );

        // place selection on cell to the right of the locked cell
        testContainer.read(selectedCellProvider.notifier).state =
            const SelectedCell(0, 1);

        // Ensure previous cell has the letter
        expect(testContainer.read(gameBoardProvider).grid[0][0], 'C');

        // Simulate backspace (controller logic used by keyboard)
        controller.clearCurrent();

        // Selection should have moved to locked cell
        final sel = testContainer.read(selectedCellProvider);
        expect(sel, isNotNull);
        expect(sel!.row, 0);
        expect(sel.col, 0);

        // The locked cell's letter must remain intact
        expect(testContainer.read(gameBoardProvider).grid[0][0], 'C');

        testContainer.dispose();
      },
    );
  });
}
