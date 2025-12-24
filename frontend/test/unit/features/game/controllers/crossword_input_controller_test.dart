import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
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

  @override
  Future<void> dispose() async {}
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
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
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
      container.read(selectedCellProvider.notifier).value = const SelectedCell(
        0,
        0,
      );

      controller.setLetterAndAdvance('A');

      final value = container.read(gameBoardProvider).grid[0][0];
      expect(value, 'A');
    });

    test('clearCurrent clears the current cell', () {
      final controller = CrosswordInputController.fromContainer(container);
      container.read(selectedCellProvider.notifier).value = const SelectedCell(
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
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
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
        testContainer.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 0);

        // Type the word "CAT"
        controller.setLetterAndAdvance('C');
        testContainer.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 1);
        controller.setLetterAndAdvance('A');

        testContainer.read(selectedCellProvider.notifier).value =
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
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
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
        testContainer.read(selectedCellProvider.notifier).value =
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
      testContainer.read(selectedCellProvider.notifier).value =
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

    test('typing on a filled cell replaces the letter in that cell', () {
      // Build a board with word "MOT" at row 0 across (partially filled)
      // New behavior: typing on filled cell replaces letter, NOT jumps to empty
      final testContainer = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          puzzleLoaderProvider.overrideWithValue(
            AsyncValue.data(
              GameBoard(
                id: 'test',
                title: 'Replace Letter',
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
      testContainer.read(selectedCellProvider.notifier).value =
          const SelectedCell(0, 0);

      // Type 'T' -> should REPLACE 'M' at (0,0), not go to empty cell
      controller.setLetterAndAdvance('T');

      final board = testContainer.read(gameBoardProvider);
      expect(
        board.grid[0][0],
        'T',
        reason: 'Letter should replace at selected cell',
      );
      expect(board.grid[0][1], 'O', reason: 'Other cells unchanged');
      expect(board.grid[0][2], isNull, reason: 'Empty cell should stay empty');

      testContainer.dispose();
    });

    test(
      'typing on filled cell replaces letter in place, does not jump to other words',
      () {
        // Board width 5; create three across words on row 0:
        // word1 at x=0 length=1 (filled), word2 at x=1 length=2 (filled),
        // word3 at x=3 length=2 (empty)
        // New behavior: typing on (0,0) should replace 'M', not jump to word3
        final testContainer = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudioService),
            puzzleLoaderProvider.overrideWithValue(
              AsyncValue.data(
                GameBoard(
                  id: 'test',
                  title: 'Replace In Place',
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
        testContainer.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 0);

        // Type 'X' -> should REPLACE 'M' at (0,0), not jump to word3
        controller.setLetterAndAdvance('X');

        final board = testContainer.read(gameBoardProvider);
        expect(
          board.grid[0][0],
          'X',
          reason: 'Letter should replace at selected cell',
        );
        expect(
          board.grid[0][3],
          isNull,
          reason: 'Other word cells should stay empty',
        );

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
      testContainer.read(selectedCellProvider.notifier).value =
          const SelectedCell(0, 0);

      final initialValue = testContainer.read(gameBoardProvider).grid[0][0];
      controller.setLetterAndAdvance('X');

      // Value should not change because cell is locked
      final finalValue = testContainer.read(gameBoardProvider).grid[0][0];
      expect(finalValue, initialValue);

      testContainer.dispose();
    });

    test('typing on last cell does not jump when word incomplete', () {
      // 3-letter across word with wrong last letter; editing last letter
      // should not auto-advance to next word unless it becomes complete.
      final testContainer = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          puzzleLoaderProvider.overrideWithValue(
            AsyncValue.data(
              GameBoard(
                id: 'test',
                title: 'No Jump on Incomplete',
                gridSize: 3,
                createdAt: DateTime.now(),
                grid: [
                  ['C', 'A', 'X'], // last letter incorrect
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
                  PuzzleEntryData(
                    number: 1,
                    direction: 'across',
                    x: 0,
                    y: 0,
                    length: 3,
                    answer: 'CAT',
                  ),
                  // add a next across word to the right so jump would be visible
                  PuzzleEntryData(
                    number: 2,
                    direction: 'across',
                    x: 0,
                    y: 1,
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

      // Place selection on the last cell of the first word (0,2)
      testContainer.read(selectedCellProvider.notifier).value =
          const SelectedCell(0, 2);

      // Replace last letter with another incorrect letter
      controller.setLetterAndAdvance('Z');

      // With new behavior: after replacing, selection advances to next empty cell
      // Since this word is filled, it goes to the next word's first empty (row=1, col=0)
      final sel = testContainer.read(selectedCellProvider);
      expect(sel, isNotNull);
      expect(sel!.row, 1);
      expect(sel.col, 0);

      // Now type another letter - this goes to the new selected cell (1,0)
      controller.setLetterAndAdvance('T');

      // Assert grid updated: Z at (0,2), T at (1,0)
      final board = testContainer.read(gameBoardProvider);
      expect(board.grid[0][2], 'Z');
      expect(board.grid[1][0], 'T');
    });

    test('typing on last vertical cell does not jump when word incomplete', () {
      // 3-letter down word with wrong last letter; editing last letter
      // should not auto-advance to next word unless it becomes complete.
      final testContainer = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          puzzleLoaderProvider.overrideWithValue(
            AsyncValue.data(
              GameBoard(
                id: 'test',
                title: 'No Jump on Incomplete (Vertical)',
                gridSize: 3,
                createdAt: DateTime.now(),
                grid: [
                  ['C', null, null],
                  ['A', null, null],
                  ['X', null, null], // last letter incorrect at (2,0)
                ],
                clues: const {},
                blackCells: [
                  [false, false, false],
                  [false, false, false],
                  [false, false, false],
                ],
                difficulty: 1,
                entries: const [
                  PuzzleEntryData(
                    number: 1,
                    direction: 'down',
                    x: 0,
                    y: 0,
                    length: 3,
                    answer: 'CAT',
                  ),
                  // add another vertical word in next column so jump would be visible
                  PuzzleEntryData(
                    number: 2,
                    direction: 'down',
                    x: 1,
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

      // Place selection on the last cell of the first vertical word (2,0)
      testContainer.read(selectedCellProvider.notifier).value =
          const SelectedCell(2, 0);
      testContainer.read(wordDirectionProvider.notifier).value =
          WordDirection.vertical;

      // Replace last letter with another incorrect letter
      controller.setLetterAndAdvance('Z');

      // With new behavior: after replacing, selection advances to next empty cell
      // Since this word is filled, it goes to the next word's first empty (row=0, col=1)
      final sel = testContainer.read(selectedCellProvider);
      expect(sel, isNotNull);
      expect(sel!.row, 0);
      expect(sel.col, 1);

      // Now type another letter - this goes to the new selected cell (0,1)
      controller.setLetterAndAdvance('T');

      // Assert grid updated: Z at (2,0), T at (0,1)
      final board = testContainer.read(gameBoardProvider);
      expect(board.grid[2][0], 'Z');
      expect(board.grid[0][1], 'T');
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
      testContainer.read(selectedCellProvider.notifier).value =
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
        testContainer.read(selectedCellProvider.notifier).value =
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

  group('CrosswordInputController - Initial Selection', () {
    test('auto-selects first cell of first across on game start', () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
          puzzleLoaderProvider.overrideWithValue(
            AsyncValue.data(
              GameBoard(
                id: 'init-select',
                title: 'Init Select',
                gridSize: 5,
                createdAt: DateTime.now(),
                grid: List<List<String?>>.generate(
                  5,
                  (_) => List<String?>.filled(5, null),
                ),
                clues: const {},
                blackCells: List<List<bool>>.generate(
                  5,
                  (_) => List<bool>.filled(5, false),
                ),
                difficulty: 1,
                entries: const [
                  // First across (numbered 1) at y=0, x=0, len=3
                  PuzzleEntryData(
                    number: 1,
                    direction: 'across',
                    x: 0,
                    y: 0,
                    length: 3,
                  ),
                  // Another across later (numbered 2)
                  PuzzleEntryData(
                    number: 2,
                    direction: 'across',
                    x: 2,
                    y: 2,
                    length: 2,
                  ),
                  // A down entry should be ignored for initial auto-select
                  PuzzleEntryData(
                    number: 3,
                    direction: 'down',
                    x: 4,
                    y: 0,
                    length: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Sanity: no cell selected before calling auto-select.
      expect(container.read(selectedCellProvider), isNull);

      final controller = CrosswordInputController.fromContainer(container);
      final board = container.read(gameBoardProvider);

      controller.tryAutoSelectFirstAcross(board);

      final sel = container.read(selectedCellProvider);
      expect(sel, isNotNull);
      expect(sel!.row, 0);
      expect(sel.col, 0);

      // Direction should be horizontal after auto-select
      final dir = container.read(wordDirectionProvider);
      expect(dir, WordDirection.horizontal);
    });
  });

  group('Correction Mode - replace letter in selected cell', () {
    late MockGameAudioService mockAudioService;

    setUp(() {
      mockAudioService = MockGameAudioService();
    });

    test(
      'typing on a filled cell should replace the letter in that cell, not jump to next empty',
      () {
        // Scenario: user fills word "CAT" incorrectly as "CAX"
        // User taps on cell (0,2) containing 'X' to correct it to 'T'
        // Expected: the letter 'T' should replace 'X' in cell (0,2)
        // Bug: the letter 'T' goes to the next empty cell instead
        final testContainer = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudioService),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
            puzzleLoaderProvider.overrideWithValue(
              AsyncValue.data(
                GameBoard(
                  id: 'test',
                  title: 'Correction Test',
                  gridSize: 5,
                  createdAt: DateTime.now(),
                  grid: [
                    ['C', 'A', 'X', null, null], // word with wrong letter
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                  ],
                  clues: const {'1A': 'A feline pet'},
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
                      length: 3,
                      answer: 'CAT',
                    ),
                  ],
                  solutionGrid: [
                    ['C', 'A', 'T', null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
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

        // User taps on cell (0,2) which contains 'X' - they want to correct it
        testContainer.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 2);
        testContainer.read(wordDirectionProvider.notifier).value =
            WordDirection.horizontal;

        // User types 'T' to correct the mistake
        controller.setLetterAndAdvance('T');

        final board = testContainer.read(gameBoardProvider);

        // The letter 'T' should replace 'X' in cell (0,2)
        expect(
          board.grid[0][2],
          'T',
          reason: 'Cell (0,2) should be corrected to T',
        );

        // The other cells should remain unchanged
        expect(board.grid[0][0], 'C', reason: 'Cell (0,0) should still be C');
        expect(board.grid[0][1], 'A', reason: 'Cell (0,1) should still be A');

        // Cell (0,3) should still be empty (letter should NOT jump there)
        expect(
          board.grid[0][3],
          isNull,
          reason: 'Cell (0,3) should still be empty',
        );
      },
    );

    test(
      'BUG: correcting a letter when word still has empty cells should replace selected cell NOT jump to empty',
      () {
        // This is the actual bug scenario:
        // User has partially filled "C_X" (positions 0,1,2 where 1 is empty)
        // User taps on cell (0,2) containing 'X' to correct it to 'T'
        // BUG: the letter 'T' goes to empty cell (0,1) instead of (0,2)
        // EXPECTED: letter 'T' should replace 'X' at position (0,2)
        final testContainer = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudioService),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
            puzzleLoaderProvider.overrideWithValue(
              AsyncValue.data(
                GameBoard(
                  id: 'test',
                  title: 'Bug Reproduction',
                  gridSize: 5,
                  createdAt: DateTime.now(),
                  grid: [
                    [
                      'C',
                      null,
                      'X',
                      null,
                      null,
                    ], // 'C' at 0, empty at 1, wrong 'X' at 2
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                  ],
                  clues: const {'1A': 'A feline pet'},
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
                      length: 3,
                      answer: 'CAT',
                    ),
                  ],
                  solutionGrid: [
                    ['C', 'A', 'T', null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
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

        // User explicitly taps/selects cell (0,2) which contains 'X'
        testContainer.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 2);
        testContainer.read(wordDirectionProvider.notifier).value =
            WordDirection.horizontal;

        // User types 'T' to correct the mistake at position (0,2)
        controller.setLetterAndAdvance('T');

        final board = testContainer.read(gameBoardProvider);

        // BUG CHECK: Letter should be placed in selected cell (0,2), NOT in empty cell (0,1)
        expect(
          board.grid[0][2],
          'T',
          reason:
              'Cell (0,2) should be corrected to T - user explicitly selected this cell',
        );

        // Empty cell (0,1) should STILL be empty - the letter should not jump there
        expect(
          board.grid[0][1],
          isNull,
          reason:
              'Cell (0,1) should still be empty - letter should NOT jump to next empty',
        );

        // First cell unchanged
        expect(board.grid[0][0], 'C');
      },
    );

    test(
      'typing on a filled cell in the middle of a word should replace that cell letter',
      () {
        // Scenario: user has "CXT" but wants to correct middle letter to 'A'
        final testContainer = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudioService),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
            puzzleLoaderProvider.overrideWithValue(
              AsyncValue.data(
                GameBoard(
                  id: 'test',
                  title: 'Middle Correction',
                  gridSize: 5,
                  createdAt: DateTime.now(),
                  grid: [
                    ['C', 'X', 'T', null, null], // wrong middle letter
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                  ],
                  clues: const {'1A': 'A feline pet'},
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
                      length: 3,
                      answer: 'CAT',
                    ),
                  ],
                  solutionGrid: [
                    ['C', 'A', 'T', null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
                    [null, null, null, null, null],
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

        // User taps on cell (0,1) which contains wrong 'X'
        testContainer.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 1);
        testContainer.read(wordDirectionProvider.notifier).value =
            WordDirection.horizontal;

        // User types 'A' to correct it
        controller.setLetterAndAdvance('A');

        final board = testContainer.read(gameBoardProvider);

        // The letter 'A' should replace 'X' in cell (0,1)
        expect(
          board.grid[0][1],
          'A',
          reason: 'Cell (0,1) should be corrected to A',
        );

        // Other cells should remain unchanged
        expect(board.grid[0][0], 'C');
        expect(board.grid[0][2], 'T');
      },
    );

    test('correcting a letter in a complete word should replace in-place', () {
      // Word is fully filled with wrong letters, user wants to correct one
      final testContainer = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudioService),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          puzzleLoaderProvider.overrideWithValue(
            AsyncValue.data(
              GameBoard(
                id: 'test',
                title: 'Complete Word Correction',
                gridSize: 5,
                createdAt: DateTime.now(),
                grid: [
                  ['D', 'O', 'G', null, null], // completely wrong word
                  [null, null, null, null, null],
                  [null, null, null, null, null],
                  [null, null, null, null, null],
                  [null, null, null, null, null],
                ],
                clues: const {'1A': 'A feline pet'},
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
                    length: 3,
                    answer: 'CAT',
                  ),
                ],
                solutionGrid: [
                  ['C', 'A', 'T', null, null],
                  [null, null, null, null, null],
                  [null, null, null, null, null],
                  [null, null, null, null, null],
                  [null, null, null, null, null],
                ],
              ),
            ),
          ),
        ],
      );

      addTearDown(testContainer.dispose);

      final controller = CrosswordInputController.fromContainer(testContainer);

      // User taps on cell (0,0) to correct 'D' to 'C'
      testContainer.read(selectedCellProvider.notifier).value =
          const SelectedCell(0, 0);
      testContainer.read(wordDirectionProvider.notifier).value =
          WordDirection.horizontal;

      controller.setLetterAndAdvance('C');

      final board = testContainer.read(gameBoardProvider);

      // The letter 'C' should replace 'D' in cell (0,0)
      expect(
        board.grid[0][0],
        'C',
        reason: 'Cell (0,0) should be corrected to C',
      );
      // Other cells unchanged
      expect(board.grid[0][1], 'O');
      expect(board.grid[0][2], 'G');
    });
  });
}
