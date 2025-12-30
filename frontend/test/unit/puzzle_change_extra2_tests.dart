import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/features/game/providers/game_board_provider.dart';
import 'package:croiz/features/game/providers/game_state_providers.dart';
import 'package:croiz/features/game/providers/game_timer_provider.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('Puzzle change extra tests', () {
    test(
      'Hive stored foundWords and lockedCells are restored on puzzle load',
      () async {
        final entries = [
          const PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 1,
            answer: 'A',
          ),
        ];

        final board = GameBoard(
          id: 'restore-1',
          title: 'restore',
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
          entries: entries,
          solutionGrid: [
            ['A'],
          ],
        );

        final tempDir = Directory.systemTemp.createTempSync('hive_test2');
        Hive.init(tempDir.path);
        final box = await Hive.openBox<String>('puzzle_progress');

        final payload = {
          'foundWords': ['0,0,across'],
          'lockedCells': ['0,0'],
        };
        await box.put(board.id, jsonEncode(payload));

        final container = ProviderContainer(
          overrides: [
            puzzleLoaderProvider.overrideWith((ref) async => board),
            flashClearDelayProvider.overrideWithValue(Duration.zero),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(() async {
          await box.delete(board.id);
          await box.close();
          await Hive.close();
          try {
            tempDir.deleteSync(recursive: true);
          } on Object {
            // Ignored: best-effort cleanup of temp dir in tests.
          }
          container.dispose();
        });

        await container.read(puzzleLoaderProvider.future);
        // ensure provider initialised
        container.read(gameBoardProvider);
        // allow async restore from Hive to complete
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(container.read(foundWordsProvider), contains('0,0,across'));
        expect(
          container.read(lockedCellsProvider),
          contains(const CellKey(0, 0)),
        );
      },
    );

    test('SelectedPuzzleIdNotifier.setSelected updates state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedPuzzleIdProvider), isNull);
      container
          .read(selectedPuzzleIdProvider.notifier)
          .setSelected('my-puzzle');
      expect(container.read(selectedPuzzleIdProvider), equals('my-puzzle'));
    });

    test(
      'GameTimer.finalizeSync returns elapsed seconds after setElapsed',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final timer = container.read(gameTimerProvider('t1'));
        await timer.setElapsed(7);
        final res = timer.finalizeSync();
        expect(res, equals(7));
      },
    );
  });
}
