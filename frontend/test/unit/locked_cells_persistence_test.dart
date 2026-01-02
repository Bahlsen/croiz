import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/features/game/providers/game_board_notifier.dart';
import 'package:croiz/features/game/providers/game_state_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Locked cells persistence on puzzle switch', () {
    late Directory tempDir;
    late Box<String> box;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('hive_locked_test');
      Hive.init(tempDir.path);
      box = await Hive.openBox<String>('puzzle_progress');
    });

    tearDown(() async {
      try {
        await box.clear();
        await box.close();
        await Hive.close();
        tempDir.deleteSync(recursive: true);
      } on Object {
        // best-effort cleanup
      }
    });

    test(
      'locked cells are persisted when switching puzzles and restored when returning',
      () async {
        // Board A: 3x3 with an entry "ABC" across the top row
        final boardA = GameBoard(
          id: 'locked-test-a',
          title: 'A',
          gridSize: 3,
          createdAt: DateTime.now(),
          grid: [
            [null, null, null],
            [null, null, null],
            [null, null, null],
          ],
          clues: {'1-across': 'Test clue'},
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
              answer: 'ABC',
            ),
          ],
          solutionGrid: [
            ['A', 'B', 'C'],
            [null, null, null],
            [null, null, null],
          ],
        );

        // Board B: simple 1x1 board
        final boardB = GameBoard(
          id: 'locked-test-b',
          title: 'B',
          gridSize: 1,
          createdAt: DateTime.now(),
          grid: [
            [null],
          ],
          clues: {},
          blackCells: [
            [false],
          ],
          difficulty: 1,
          entries: const [],
          solutionGrid: [
            [null],
          ],
        );

        final container = ProviderContainer(
          overrides: [
            puzzlesProvider.overrideWithValue(
              AsyncValue.data([
                PuzzleDescriptor(
                  id: 'locked-test-a',
                  title: 'A',
                  path: 'locked-test-a.json',
                ),
                PuzzleDescriptor(
                  id: 'locked-test-b',
                  title: 'B',
                  path: 'locked-test-b.json',
                ),
              ]),
            ),
            puzzleAssetLoaderProvider.overrideWithValue((String path) async {
              if (path.contains('locked-test-a')) {
                return boardA;
              }
              return boardB;
            }),
            flashClearDelayProvider.overrideWithValue(Duration.zero),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        // Select puzzle A and wait for load
        container
            .read(selectedPuzzleIdProvider.notifier)
            .setSelected('locked-test-a');
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});
        // Initialize controller for input
        final controller = CrosswordInputController.fromContainer(container);
        // Ensure first cell is selected
        container
            .read(selectedCellProvider.notifier)
            .select(const SelectedCell(0, 0));
        container
            .read(wordDirectionProvider.notifier)
            .setDirection(WordDirection.horizontal);

        // Fill in the first row with 'A', 'B', 'C' to complete the word
        controller
          ..setLetterAndAdvance('A')
          ..setLetterAndAdvance('B')
          ..setLetterAndAdvance('C');

        // Wait for word check debounce to detect the found word
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Verify that the word was found and cells are locked
        final foundWordsBefore = container.read(foundWordsProvider);
        final lockedCellsBefore = container.read(lockedCellsProvider);

        expect(
          foundWordsBefore,
          isNotEmpty,
          reason: 'Word ABC should be found after typing',
        );
        expect(
          lockedCellsBefore,
          containsAll([
            const CellKey(0, 0),
            const CellKey(0, 1),
            const CellKey(0, 2),
          ]),
          reason:
              'Cells (0,0), (0,1), (0,2) should be locked after finding word',
        );

        // Wait for debounced persist to complete
        await Future<void>.delayed(const Duration(milliseconds: 500));

        // Now switch to puzzle B
        container
            .read(selectedPuzzleIdProvider.notifier)
            .setSelected('locked-test-b');
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});
        container.read(gameBoardProvider);

        // Wait for persistence of puzzle A to complete before switching
        await Future<void>.delayed(const Duration(milliseconds: 200));

        // Verify the stored data for puzzle A includes lockedCells
        final storedRaw = box.get('locked-test-a');
        expect(
          storedRaw,
          isNotNull,
          reason: 'Puzzle A progress should be saved when switching away',
        );

        final stored = jsonDecode(storedRaw!) as Map<String, dynamic>;
        expect(
          stored['lockedCells'],
          isNotNull,
          reason: 'lockedCells should be saved in storage',
        );
        expect(
          stored['lockedCells'],
          isNotEmpty,
          reason: 'lockedCells should contain the locked cells from puzzle A',
        );

        // BUG TEST: The lockedCells should contain 3 cells
        final lockedCellsList = stored['lockedCells'] as List;
        expect(
          lockedCellsList.length,
          equals(3),
          reason:
              'BUG: lockedCells should have 3 cells (0,0), (0,1), (0,2) but was saved after being cleared',
        );

        // Now switch back to puzzle A
        container
            .read(selectedPuzzleIdProvider.notifier)
            .setSelected('locked-test-a');
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});
        container.read(gameBoardProvider);

        // Wait for restore to complete (longer delay for async restore)
        for (var i = 0; i < 20; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          final locked = container.read(lockedCellsProvider);
          if (locked.isNotEmpty) {
            break;
          }
        }

        // Verify that locked cells are restored
        final lockedCellsAfter = container.read(lockedCellsProvider);
        expect(
          lockedCellsAfter,
          containsAll([
            const CellKey(0, 0),
            const CellKey(0, 1),
            const CellKey(0, 2),
          ]),
          reason:
              'BUG: Locked cells should be restored when returning to puzzle A',
        );

        // Also verify the grid is restored
        final gridAfter = container.read(gameBoardProvider).grid;
        expect(gridAfter[0][0], equals('A'));
        expect(gridAfter[0][1], equals('B'));
        expect(gridAfter[0][2], equals('C'));
      },
    );
  });
}
