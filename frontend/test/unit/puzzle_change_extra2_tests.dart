import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/features/game/providers/game_board_provider.dart';
// import removed: not needed in this unit test
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/puzzles/puzzles_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Puzzle switch persistence', () {
    test('progress is saved on switch and restored when returning', () async {
      // Small 1x1 boards for simplicity
      final boardA = GameBoard(
        id: 'board-a',
        title: 'A',
        gridSize: 1,
        createdAt: DateTime.now(),
        grid: [ [null] ],
        clues: {},
        blackCells: [ [false] ],
        difficulty: 1,
        entries: const [ PuzzleEntryData(number: 1, direction: 'across', x: 0, y: 0, length: 1, answer: 'A') ],
        solutionGrid: [ ['A'] ],
      );

      final boardB = GameBoard(
        id: 'board-b',
        title: 'B',
        gridSize: 1,
        createdAt: DateTime.now(),
        grid: [ [null] ],
        clues: {},
        blackCells: [ [false] ],
        difficulty: 1,
        entries: const [],
        solutionGrid: [ [null] ],
      );

      final tempDir = Directory.systemTemp.createTempSync('hive_test');
      Hive.init(tempDir.path);
      final box = await Hive.openBox<String>('puzzle_progress');

      final container = ProviderContainer(
        overrides: [
          // Provide a loader that returns boardA or boardB based on selected id.
          puzzlesProvider.overrideWithValue(
            AsyncValue.data([
              PuzzleDescriptor(id: 'board-a', title: 'A', path: 'board-a.json'),
              PuzzleDescriptor(id: 'board-b', title: 'B', path: 'board-b.json'),
            ]),
          ),
          puzzleAssetLoaderProvider.overrideWithValue((String path) async {
            if (path.contains('board-a')) {
              return boardA;
            }
            return boardB;
          }),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(() async {
        try {
          await box.delete(boardA.id);
          await box.delete(boardB.id);
          await box.close();
          await Hive.close();
          tempDir.deleteSync(recursive: true);
        } on Object {
          // best-effort cleanup
        }
        container.dispose();
      });

      // Select A and wait for load
      container.read(selectedPuzzleIdProvider.notifier).setSelected('board-a');
      await container.read(puzzleLoaderProvider.future);
      // Ensure gameBoard provider initialised
      container.read(gameBoardProvider);

      // Make a change on board A
      container.read(gameBoardProvider.notifier).setLetter(0, 0, 'X');

      // Wait for the debounced persist to complete (simulate normal typing)
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Verify Hive stored board A progress
      // (no prints in tests)
      final raw = box.get(boardA.id);
      expect(raw, isNotNull, reason: 'Expected debounce-driven persist to save progress');
      final stored = jsonDecode(raw!) as Map<String, dynamic>;
      expect(stored['grid'][0][0], equals('X'));

      // Now switch to B and back to A; restore should pick up saved progress
      container.read(selectedPuzzleIdProvider.notifier).setSelected('board-b');
      await container.read(puzzleLoaderProvider.future);

      container.read(selectedPuzzleIdProvider.notifier).setSelected('board-a');
      await container.read(puzzleLoaderProvider.future);
      // ensure stored payload still present
      final raw2 = box.get(boardA.id);
      expect(raw2, isNotNull, reason: 'stored payload should still exist after switching back');

      // wait up to 2s for async restore to apply
      var restored = false;
      for (var i = 0; i < 40; i++) {
        final val = container.read(gameBoardProvider).grid[0][0];
        if (val == 'X') {
          restored = true;
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      expect(restored, isTrue, reason: 'expected restored letter X in grid');
    });
  });
}
