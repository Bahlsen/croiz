import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/services/game_audio_service.dart';

/// Mock audio service that tracks calls for verification
class MockGameAudioService implements GameAudioService {
  int successCount = 0;
  int victoryCount = 0;
  int typeCount = 0;
  int deleteCount = 0;

  void reset() {
    successCount = 0;
    victoryCount = 0;
    typeCount = 0;
    deleteCount = 0;
  }

  @override
  Future<void> playSuccess() async {
    successCount++;
  }

  @override
  Future<void> playVictory() async {
    victoryCount++;
  }

  @override
  Future<void> playType() async {
    typeCount++;
  }

  @override
  Future<void> playDelete() async {
    deleteCount++;
  }

  @override
  Future<void> get ready => Future<void>.value();

  @override
  Future<void> dispose() async {}
}

void main() {
  group('Multi-word completion tests', () {
    late MockGameAudioService mockAudio;

    setUp(() {
      mockAudio = MockGameAudioService();
    });

    test(
      'completing a single horizontal word flashes its cells and plays success once',
      () {
        final container = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudio),
            flashClearDelayProvider.overrideWithValue(Duration.zero),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        // 3x3 grid with one horizontal word "CAT" at row 0
        const size = 3;
        final grid = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );
        final solution = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );
        solution[0][0] = 'C';
        solution[0][1] = 'A';
        solution[0][2] = 'T';

        final board = GameBoard(
          id: 'single-h',
          title: 'single-h',
          gridSize: size,
          createdAt: DateTime.now(),
          grid: grid,
          clues: const {},
          blackCells: List.generate(
            size,
            (_) => List<bool>.filled(size, false),
          ),
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
          ],
          solutionGrid: solution,
        );

        container.read(gameBoardProvider.notifier).state = board;
        container.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 0);
        container.read(wordDirectionProvider.notifier).value =
            WordDirection.horizontal;

        final controller = CrosswordInputController.fromContainer(container);

        fakeAsync((async) {
          controller
            ..setLetterAndAdvance('C')
            ..setLetterAndAdvance('A')
            ..setLetterAndAdvance('T');

          // Success sound should play exactly once
          expect(mockAudio.successCount, 1);

          // All 3 cells should be flashing
          final flashing = container.read(flashingCellsProvider);
          expect(flashing.length, 3);
          expect(
            flashing,
            containsAll([
              const CellKey(0, 0),
              const CellKey(0, 1),
              const CellKey(0, 2),
            ]),
          );

          // All 3 cells should be locked
          final locked = container.read(lockedCellsProvider);
          expect(locked.length, 3);

          // Word should be found
          final found = container.read(foundWordsProvider);
          expect(found.length, 1);

          async.elapse(const Duration(milliseconds: 100));
        });
      },
    );

    test(
      'completing a single vertical word flashes its cells and plays success once',
      () {
        final container = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudio),
            flashClearDelayProvider.overrideWithValue(Duration.zero),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        // 3x3 grid with one vertical word "DOG" at col 0
        const size = 3;
        final grid = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );
        final solution = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );
        solution[0][0] = 'D';
        solution[1][0] = 'O';
        solution[2][0] = 'G';

        final board = GameBoard(
          id: 'single-v',
          title: 'single-v',
          gridSize: size,
          createdAt: DateTime.now(),
          grid: grid,
          clues: const {},
          blackCells: List.generate(
            size,
            (_) => List<bool>.filled(size, false),
          ),
          difficulty: 1,
          entries: const [
            PuzzleEntryData(
              number: 1,
              direction: 'down',
              x: 0,
              y: 0,
              length: 3,
              answer: 'DOG',
            ),
          ],
          solutionGrid: solution,
        );

        container.read(gameBoardProvider.notifier).state = board;
        container.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 0);
        container.read(wordDirectionProvider.notifier).value =
            WordDirection.vertical;

        final controller = CrosswordInputController.fromContainer(container);

        fakeAsync((async) {
          controller
            ..setLetterAndAdvance('D')
            ..setLetterAndAdvance('O')
            ..setLetterAndAdvance('G');

          expect(mockAudio.successCount, 1);

          final flashing = container.read(flashingCellsProvider);
          expect(flashing.length, 3);
          expect(
            flashing,
            containsAll([
              const CellKey(0, 0),
              const CellKey(1, 0),
              const CellKey(2, 0),
            ]),
          );

          final locked = container.read(lockedCellsProvider);
          expect(locked.length, 3);

          async.elapse(const Duration(milliseconds: 100));
        });
      },
    );

    test(
      'completing two words at intersection flashes ALL cells and plays success ONCE',
      () {
        final container = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudio),
            flashClearDelayProvider.overrideWithValue(Duration.zero),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        // 3x3 grid with:
        // - Horizontal word "CAT" at row 0 (C-A-T)
        // - Vertical word "ACE" at col 1 (A-C-E)
        // Intersection at (0,1) with letter 'A'
        const size = 3;
        final grid = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );
        final solution = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );

        // Horizontal: CAT
        solution[0][0] = 'C';
        solution[0][1] = 'A';
        solution[0][2] = 'T';

        // Vertical: ACE (shares 'A' at (0,1))
        // solution[0][1] = 'A'; // already set
        solution[1][1] = 'C';
        solution[2][1] = 'E';

        // Pre-fill all but intersection
        grid[0][0] = 'C';
        grid[0][2] = 'T';
        grid[1][1] = 'C';
        grid[2][1] = 'E';

        final board = GameBoard(
          id: 'intersection',
          title: 'intersection',
          gridSize: size,
          createdAt: DateTime.now(),
          grid: grid,
          clues: const {},
          blackCells: List.generate(
            size,
            (_) => List<bool>.filled(size, false),
          ),
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
            PuzzleEntryData(
              number: 2,
              direction: 'down',
              x: 1,
              y: 0,
              length: 3,
              answer: 'ACE',
            ),
          ],
          solutionGrid: solution,
        );

        container.read(gameBoardProvider.notifier).state = board;
        container.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 1);
        container.read(wordDirectionProvider.notifier).value =
            WordDirection.horizontal;

        final controller = CrosswordInputController.fromContainer(container);

        fakeAsync((async) {
          // Type 'A' at intersection - should complete BOTH words
          controller.setLetterAndAdvance('A');

          // Success sound should play exactly ONCE (not twice!)
          expect(
            mockAudio.successCount,
            1,
            reason: 'Success sound should play only once for multiple words',
          );

          // ALL cells from BOTH words should be flashing
          final flashing = container.read(flashingCellsProvider);
          expect(
            flashing.length,
            5,
            reason:
                'Should flash 5 unique cells (3 from CAT + 3 from ACE - 1 shared)',
          );
          expect(
            flashing,
            containsAll([
              const CellKey(0, 0), // C from CAT
              const CellKey(0, 1), // A (intersection)
              const CellKey(0, 2), // T from CAT
              const CellKey(1, 1), // C from ACE
              const CellKey(2, 1), // E from ACE
            ]),
          );

          // ALL cells should be locked
          final locked = container.read(lockedCellsProvider);
          expect(locked.length, 5);

          // Both words should be found
          final found = container.read(foundWordsProvider);
          expect(
            found.length,
            2,
            reason: 'Both words should be marked as found',
          );

          async.elapse(const Duration(milliseconds: 100));
        });
      },
    );

    test(
      'completing only one word when typing at intersection (other word incomplete)',
      () {
        final container = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudio),
            flashClearDelayProvider.overrideWithValue(Duration.zero),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        // 3x3 grid with:
        // - Horizontal word "CAT" at row 0 (pre-filled C, T, missing A)
        // - Vertical word "ACE" at col 1 (missing A, C, E)
        const size = 3;
        final grid = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );
        final solution = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );

        solution[0][0] = 'C';
        solution[0][1] = 'A';
        solution[0][2] = 'T';
        solution[1][1] = 'C';
        solution[2][1] = 'E';

        // Only pre-fill horizontal word's non-intersection cells
        grid[0][0] = 'C';
        grid[0][2] = 'T';
        // Vertical word cells (1,1) and (2,1) are empty

        final board = GameBoard(
          id: 'partial-intersection',
          title: 'partial-intersection',
          gridSize: size,
          createdAt: DateTime.now(),
          grid: grid,
          clues: const {},
          blackCells: List.generate(
            size,
            (_) => List<bool>.filled(size, false),
          ),
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
            PuzzleEntryData(
              number: 2,
              direction: 'down',
              x: 1,
              y: 0,
              length: 3,
              answer: 'ACE',
            ),
          ],
          solutionGrid: solution,
        );

        container.read(gameBoardProvider.notifier).state = board;
        container.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 1);
        container.read(wordDirectionProvider.notifier).value =
            WordDirection.horizontal;

        final controller = CrosswordInputController.fromContainer(container);

        fakeAsync((async) {
          // Type 'A' at intersection - should complete only CAT (ACE is incomplete)
          controller.setLetterAndAdvance('A');

          // Success should play once (for CAT)
          expect(mockAudio.successCount, 1);

          // Only CAT cells should flash
          final flashing = container.read(flashingCellsProvider);
          expect(flashing.length, 3);
          expect(
            flashing,
            containsAll([
              const CellKey(0, 0),
              const CellKey(0, 1),
              const CellKey(0, 2),
            ]),
          );

          // Only one word found
          final found = container.read(foundWordsProvider);
          expect(found.length, 1);

          async.elapse(const Duration(milliseconds: 100));
        });
      },
    );

    test(
      'typing a letter that does not complete any word does not trigger flash or sound',
      () {
        final container = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudio),
            flashClearDelayProvider.overrideWithValue(Duration.zero),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        const size = 3;
        final grid = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );
        final solution = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );
        solution[0][0] = 'C';
        solution[0][1] = 'A';
        solution[0][2] = 'T';

        final board = GameBoard(
          id: 'no-complete',
          title: 'no-complete',
          gridSize: size,
          createdAt: DateTime.now(),
          grid: grid,
          clues: const {},
          blackCells: List.generate(
            size,
            (_) => List<bool>.filled(size, false),
          ),
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
          ],
          solutionGrid: solution,
        );

        container.read(gameBoardProvider.notifier).state = board;
        container.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 0);
        container.read(wordDirectionProvider.notifier).value =
            WordDirection.horizontal;

        final controller = CrosswordInputController.fromContainer(container);

        fakeAsync((async) {
          // Type only first letter - word not complete
          controller.setLetterAndAdvance('C');

          // No success sound
          expect(mockAudio.successCount, 0);

          // No flashing
          final flashing = container.read(flashingCellsProvider);
          expect(flashing, isEmpty);

          // No found words
          final found = container.read(foundWordsProvider);
          expect(found, isEmpty);

          async.elapse(const Duration(milliseconds: 100));
        });
      },
    );

    test('already found word is skipped when typing at intersection', () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudio),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      const size = 3;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final solution = List.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );

      // Two horizontal words
      solution[0][0] = 'C';
      solution[0][1] = 'A';
      solution[0][2] = 'T';
      solution[1][0] = 'D';
      solution[1][1] = 'O';
      solution[1][2] = 'G';

      // Pre-fill first word completely
      grid[0][0] = 'C';
      grid[0][1] = 'A';
      grid[0][2] = 'T';

      final board = GameBoard(
        id: 'already-found',
        title: 'already-found',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
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
          PuzzleEntryData(
            number: 2,
            direction: 'across',
            x: 0,
            y: 1,
            length: 3,
            answer: 'DOG',
          ),
        ],
        solutionGrid: solution,
      );

      container.read(gameBoardProvider.notifier).state = board;

      // Mark first word as already found
      container.read(foundWordsProvider.notifier).value = {'0,0,across'};
      container.read(lockedCellsProvider.notifier).value = {
        const CellKey(0, 0),
        const CellKey(0, 1),
        const CellKey(0, 2),
      };

      container.read(selectedCellProvider.notifier).value = const SelectedCell(
        1,
        0,
      );
      container.read(wordDirectionProvider.notifier).value =
          WordDirection.horizontal;

      final controller = CrosswordInputController.fromContainer(container);

      fakeAsync((async) {
        controller
          ..setLetterAndAdvance('D')
          ..setLetterAndAdvance('O')
          ..setLetterAndAdvance('G');

        // Only one success (for DOG, not CAT which was already found)
        expect(mockAudio.successCount, 1);

        // Only DOG cells should flash
        final flashing = container.read(flashingCellsProvider);
        expect(flashing.length, 3);
        expect(
          flashing,
          containsAll([
            const CellKey(1, 0),
            const CellKey(1, 1),
            const CellKey(1, 2),
          ]),
        );

        // Now both words should be in found
        final found = container.read(foundWordsProvider);
        expect(found.length, 2);

        async.elapse(const Duration(milliseconds: 100));
      });
    });

    test('completing all words triggers victory sound', () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudio),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      const size = 3;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final solution = List.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );

      // Single word puzzle
      solution[0][0] = 'A';
      solution[0][1] = 'B';
      solution[0][2] = 'C';

      final board = GameBoard(
        id: 'victory',
        title: 'victory',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            answer: 'ABC',
          ),
        ],
        solutionGrid: solution,
      );

      container.read(gameBoardProvider.notifier).state = board;
      container.read(selectedCellProvider.notifier).value = const SelectedCell(
        0,
        0,
      );
      container.read(wordDirectionProvider.notifier).value =
          WordDirection.horizontal;

      final controller = CrosswordInputController.fromContainer(container);

      fakeAsync((async) {
        controller
          ..setLetterAndAdvance('A')
          ..setLetterAndAdvance('B')
          ..setLetterAndAdvance('C');

        expect(mockAudio.successCount, 1);
        expect(
          mockAudio.victoryCount,
          1,
          reason: 'Victory sound should play when all words are found',
        );

        async.elapse(const Duration(milliseconds: 100));
      });
    });

    test('flashing cells clear after delay', () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudio),
          // Use actual delay to test clearing
          flashClearDelayProvider.overrideWithValue(
            const Duration(milliseconds: 500),
          ),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      const size = 3;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final solution = List.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );
      solution[0][0] = 'A';
      solution[0][1] = 'B';
      solution[0][2] = 'C';

      final board = GameBoard(
        id: 'flash-clear',
        title: 'flash-clear',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            answer: 'ABC',
          ),
        ],
        solutionGrid: solution,
      );

      container.read(gameBoardProvider.notifier).state = board;
      container.read(selectedCellProvider.notifier).value = const SelectedCell(
        0,
        0,
      );
      container.read(wordDirectionProvider.notifier).value =
          WordDirection.horizontal;

      final controller = CrosswordInputController.fromContainer(container);

      fakeAsync((async) {
        controller
          ..setLetterAndAdvance('A')
          ..setLetterAndAdvance('B')
          ..setLetterAndAdvance('C');

        // Immediately after, cells should be flashing
        expect(container.read(flashingCellsProvider).length, 3);

        // Before delay, still flashing
        async.elapse(const Duration(milliseconds: 400));
        expect(container.read(flashingCellsProvider).length, 3);

        // After delay, should be cleared
        async.elapse(const Duration(milliseconds: 200));
        expect(container.read(flashingCellsProvider), isEmpty);
      });
    });

    test('completing three words at once with shared cells', () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudio),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      // Complex grid:
      // A B C
      // D E F
      // G H I
      //
      // Words:
      // - Horizontal: ABC (row 0), DEF (row 1), GHI (row 2)
      // - If we pre-fill all but 'E', typing 'E' completes DEF
      //
      // Simpler: create 2 horizontals and 1 vertical all sharing 'E' at center
      const size = 3;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final solution = List.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );

      // Horizontal DEF at row 1
      solution[1][0] = 'D';
      solution[1][1] = 'E';
      solution[1][2] = 'F';

      // Vertical BEH at col 1
      solution[0][1] = 'B';
      // solution[1][1] = 'E'; // already set
      solution[2][1] = 'H';

      // Pre-fill all except center 'E'
      grid[1][0] = 'D';
      grid[1][2] = 'F';
      grid[0][1] = 'B';
      grid[2][1] = 'H';

      final board = GameBoard(
        id: 'double-intersection',
        title: 'double-intersection',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 1,
            length: 3,
            answer: 'DEF',
          ),
          PuzzleEntryData(
            number: 2,
            direction: 'down',
            x: 1,
            y: 0,
            length: 3,
            answer: 'BEH',
          ),
        ],
        solutionGrid: solution,
      );

      container.read(gameBoardProvider.notifier).state = board;
      container.read(selectedCellProvider.notifier).value = const SelectedCell(
        1,
        1,
      );
      container.read(wordDirectionProvider.notifier).value =
          WordDirection.horizontal;

      final controller = CrosswordInputController.fromContainer(container);

      fakeAsync((async) {
        // Type 'E' at center - completes BOTH DEF and BEH
        controller.setLetterAndAdvance('E');

        // Success sound only once
        expect(mockAudio.successCount, 1);

        // All 5 unique cells flash (DEF: 3 cells, BEH: 3 cells, 1 shared = 5)
        final flashing = container.read(flashingCellsProvider);
        expect(flashing.length, 5);
        expect(
          flashing,
          containsAll([
            const CellKey(1, 0), // D
            const CellKey(1, 1), // E (center)
            const CellKey(1, 2), // F
            const CellKey(0, 1), // B
            const CellKey(2, 1), // H
          ]),
        );

        // Both words found
        final found = container.read(foundWordsProvider);
        expect(found.length, 2);

        // Victory should trigger since all words are complete
        expect(mockAudio.victoryCount, 1);

        async.elapse(const Duration(milliseconds: 100));
      });
    });

    test('wrong letter does not complete word or flash', () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudio),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      const size = 3;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final solution = List.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );
      solution[0][0] = 'C';
      solution[0][1] = 'A';
      solution[0][2] = 'T';

      // Pre-fill C and T, missing A
      grid[0][0] = 'C';
      grid[0][2] = 'T';

      final board = GameBoard(
        id: 'wrong-letter',
        title: 'wrong-letter',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
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
        ],
        solutionGrid: solution,
      );

      container.read(gameBoardProvider.notifier).state = board;
      container.read(selectedCellProvider.notifier).value = const SelectedCell(
        0,
        1,
      );
      container.read(wordDirectionProvider.notifier).value =
          WordDirection.horizontal;

      final controller = CrosswordInputController.fromContainer(container);

      fakeAsync((async) {
        // Type wrong letter 'X' instead of 'A'
        controller.setLetterAndAdvance('X');

        // Letter should be placed
        expect(container.read(gameBoardProvider).grid[0][1], 'X');

        // No success (word not complete with wrong letter)
        expect(mockAudio.successCount, 0);

        // No flashing
        expect(container.read(flashingCellsProvider), isEmpty);

        // No found words
        expect(container.read(foundWordsProvider), isEmpty);

        async.elapse(const Duration(milliseconds: 100));
      });
    });

    test('cells are locked after word completion and cannot be modified', () {
      final container = ProviderContainer(
        overrides: [
          gameAudioServiceProvider.overrideWithValue(mockAudio),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      const size = 3;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final solution = List.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );
      solution[0][0] = 'A';
      solution[0][1] = 'B';
      solution[0][2] = 'C';
      solution[1][0] = 'D';
      solution[1][1] = 'E';
      solution[1][2] = 'F';

      final board = GameBoard(
        id: 'lock-test',
        title: 'lock-test',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            answer: 'ABC',
          ),
          PuzzleEntryData(
            number: 2,
            direction: 'across',
            x: 0,
            y: 1,
            length: 3,
            answer: 'DEF',
          ),
        ],
        solutionGrid: solution,
      );

      container.read(gameBoardProvider.notifier).state = board;
      container.read(selectedCellProvider.notifier).value = const SelectedCell(
        0,
        0,
      );
      container.read(wordDirectionProvider.notifier).value =
          WordDirection.horizontal;

      final controller = CrosswordInputController.fromContainer(container);

      fakeAsync((async) {
        // Complete first word
        controller
          ..setLetterAndAdvance('A')
          ..setLetterAndAdvance('B')
          ..setLetterAndAdvance('C');

        // Cells should be locked
        final locked = container.read(lockedCellsProvider);
        expect(
          locked,
          containsAll([
            const CellKey(0, 0),
            const CellKey(0, 1),
            const CellKey(0, 2),
          ]),
        );

        // Selection should have moved to next word (row 1)
        final sel = container.read(selectedCellProvider);
        expect(sel?.row, 1);

        async.elapse(const Duration(milliseconds: 100));
      });
    });

    test(
      'partial word with correct letters does not complete until all filled',
      () {
        final container = ProviderContainer(
          overrides: [
            gameAudioServiceProvider.overrideWithValue(mockAudio),
            flashClearDelayProvider.overrideWithValue(Duration.zero),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        const size = 4;
        final grid = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );
        final solution = List.generate(
          size,
          (_) => List<String?>.filled(size, null),
        );
        solution[0][0] = 'T';
        solution[0][1] = 'E';
        solution[0][2] = 'S';
        solution[0][3] = 'T';

        final board = GameBoard(
          id: 'partial',
          title: 'partial',
          gridSize: size,
          createdAt: DateTime.now(),
          grid: grid,
          clues: const {},
          blackCells: List.generate(
            size,
            (_) => List<bool>.filled(size, false),
          ),
          difficulty: 1,
          entries: const [
            PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 0,
              y: 0,
              length: 4,
              answer: 'TEST',
            ),
          ],
          solutionGrid: solution,
        );

        container.read(gameBoardProvider.notifier).state = board;
        container.read(selectedCellProvider.notifier).value =
            const SelectedCell(0, 0);
        container.read(wordDirectionProvider.notifier).value =
            WordDirection.horizontal;

        final controller = CrosswordInputController.fromContainer(container);

        fakeAsync((async) {
          // Type first three letters
          controller
            ..setLetterAndAdvance('T')
            ..setLetterAndAdvance('E')
            ..setLetterAndAdvance('S');

          // Word not complete yet
          expect(mockAudio.successCount, 0);
          expect(container.read(flashingCellsProvider), isEmpty);
          expect(container.read(foundWordsProvider), isEmpty);

          // Now type last letter
          controller.setLetterAndAdvance('T');

          // Now complete
          expect(mockAudio.successCount, 1);
          expect(container.read(flashingCellsProvider).length, 4);
          expect(container.read(foundWordsProvider).length, 1);

          async.elapse(const Duration(milliseconds: 100));
        });
      },
    );
  });
}
